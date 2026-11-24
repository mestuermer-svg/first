#!/usr/bin/env python3
"""
Hybrid-LLM-Router fuer das SimRig / Git-Labor-System.

Verknuepft die beiden lokalen Ollama-Knoten (SimRacer RTX 5070 Ti & Laptop RTX 5060)
sicher mit der offiziellen Google Cloud / Google Antigravity SDK Intelligenz
(ohne inoffizielle OAuth-Proxies oder fest einprogrammierte API-Keys).

Routing-Logik:
1. Prueft den Live-Betriebsmodus auf StrikerPi (:8080/health -> ENGINEERING vs. LIVE_RACE).
2. Waehlt bei task_tier="auto"|"local":
   - SimRacer Ollama (192.168.178.68:11434), wenn mode != "LIVE_RACE" und erreichbar.
   - Sonst Laptop Ollama (127.0.0.1:11434) als LIVE_RACE- oder Mobil-Fallback.
   - Bei task_tier="auto" und offline gehenden Ollama-Knoten Eskalation in die Cloud.
3. Cloud-Pfad nutzt Vertex AI via Application Default Credentials (ADC) oder
   optional die Umgebungsvariable GEMINI_API_KEY.

Beispiele:
  python hybrid_llm_router.py --check
  python hybrid_llm_router.py --tier auto --workload code --check
  python hybrid_llm_router.py --tier local --prompt "Pruefe meinen Setup-Workflow."
"""

from __future__ import annotations

import argparse
import asyncio
import importlib.util
import json
import os
import sys
import urllib.error
import urllib.request
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Literal

STRIKERPI_STATUS_URL = os.getenv(
    "STRIKERPI_STATUS_URL", "http://192.168.178.86:8080/health"
)
SIMRACER_OLLAMA_BASE = os.getenv(
    "SIMRACER_OLLAMA_BASE", "http://192.168.178.68:11434"
)
LAPTOP_OLLAMA_BASE = os.getenv("LAPTOP_OLLAMA_BASE", "http://127.0.0.1:11434")

GCP_PROJECT = os.getenv("GOOGLE_CLOUD_PROJECT", "gen-lang-client-0668043276")
GCP_LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "europe-west3")

SIMRACER_CHAT_MODEL = os.getenv("SIMRACER_CHAT_MODEL", "gemma4:12b")
SIMRACER_CODE_MODEL = os.getenv("SIMRACER_CODE_MODEL", "qwen3.5:9b")
LAPTOP_CHAT_MODEL = os.getenv("LAPTOP_CHAT_MODEL", "gemma4:e4b")
LAPTOP_CODE_MODEL = os.getenv("LAPTOP_CODE_MODEL", "qwen3.5:4b")

TaskTier = Literal["auto", "local", "cloud"]
WorkloadType = Literal["general", "code"]
WeightClass = Literal["low", "medium", "high"]

HIGH_WEIGHT_QUEUE_DIR = Path(__file__).resolve().parents[2] / "Systemtests" / "high_weight_queue"
CLOUD_BUDGET_LIMIT_PER_DAY = int(os.getenv("HYBRID_CLOUD_DAILY_BUDGET", "50"))


@dataclass
class WeightAssessment:
    weight_score: int
    weight_class: WeightClass
    attached_files: int
    line_count: int
    json_depth: int
    estimated_tokens: int


@dataclass
class RouteDecision:
    target: Literal["simracer_ollama", "laptop_ollama", "vertex_adc", "gemini_api_env", "high_weight_queue", "offline"]
    model: str | None
    base_url: str | None
    project: str | None
    location: str | None
    simrig_mode: str
    workload: WorkloadType
    reason: str
    warning: str | None = None
    weight_score: int = 0
    weight_class: WeightClass = "low"


def _calc_json_depth(obj: Any, current: int = 0) -> int:
    if isinstance(obj, dict):
        if not obj:
            return current + 1
        return max(_calc_json_depth(v, current + 1) for v in obj.values())
    if isinstance(obj, list):
        if not obj:
            return current + 1
        return max(_calc_json_depth(v, current + 1) for v in obj)
    return current


def assess_payload_weight(prompt: str = "", files_count: int = 0) -> WeightAssessment:
    """Deterministische Complexity & Token Assessment Heuristik (< 1 ms, ohne LLM-Call)."""
    import re

    text = prompt or ""
    lines = text.count("\n") + (1 if text else 0)
    inferred_files = len(re.findall(r"\b[\w\-/\\]+\.(?:py|ps1|sh|ini|json|md|ts|js|yml|yaml)\b", text))
    total_files = max(files_count, inferred_files)
    depth = 1
    if text.strip().startswith("{") and text.strip().endswith("}"):
        try:
            depth = _calc_json_depth(json.loads(text))
        except Exception:
            depth = 2
    est_tokens = max(1, len(text) // 4)
    score = (total_files * 18) + (lines // 8) + (depth * 5) + (est_tokens // 120)
    if score >= 75 or total_files >= 4 or lines >= 250:
        w_class: WeightClass = "high"
    elif score >= 22 or total_files >= 2 or lines >= 40:
        w_class = "medium"
    else:
        w_class = "low"
    return WeightAssessment(
        weight_score=score,
        weight_class=w_class,
        attached_files=total_files,
        line_count=lines,
        json_depth=depth,
        estimated_tokens=est_tokens,
    )


def enqueue_high_weight_task(prompt: str, workload: WorkloadType, assessment: WeightAssessment) -> Path:
    """Parkt einen schweren Auftrag in der High-Weight Queue, wenn LIVE_RACE aktiv und Cloud-Budget erschöpft ist."""
    from datetime import datetime, timezone

    HIGH_WEIGHT_QUEUE_DIR.mkdir(parents=True, exist_ok=True)
    ts = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    q_file = HIGH_WEIGHT_QUEUE_DIR / f"hwq_{ts}_score{assessment.weight_score}.json"
    payload = {
        "queued_at": datetime.now(timezone.utc).isoformat(),
        "workload": workload,
        "weight_score": assessment.weight_score,
        "weight_class": assessment.weight_class,
        "attached_files": assessment.attached_files,
        "line_count": assessment.line_count,
        "prompt": prompt,
        "status": "queued_for_post_race",
    }
    q_file.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")
    return q_file


def _http_get_json(url: str, timeout: float = 1.5) -> dict[str, Any] | None:
    req = urllib.request.Request(url, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read().decode("utf-8", errors="replace")
            data = json.loads(raw)
            return data if isinstance(data, dict) else None
    except (urllib.error.URLError, TimeoutError, ValueError, OSError):
        return None


def fetch_simrig_status(timeout: float = 1.5) -> dict[str, Any]:
    data = _http_get_json(STRIKERPI_STATUS_URL, timeout=timeout)
    if not data:
        return {"online": False, "mode": "ENGINEERING"}
    mode = str(data.get("mode") or "ENGINEERING").strip().upper()
    return {"online": True, "mode": mode}


def fetch_simrig_mode(timeout: float = 1.5) -> str:
    return str(fetch_simrig_status(timeout=timeout)["mode"])


def probe_ollama(base_url: str, timeout: float = 1.5) -> dict[str, Any]:
    clean_base = base_url.rstrip("/")
    tags = _http_get_json(f"{clean_base}/api/tags", timeout=timeout)
    if tags is None:
        return {
            "online": False,
            "base_url": clean_base,
            "installed_models": [],
            "loaded_models": [],
        }

    installed = [
        str(m.get("name"))
        for m in (tags.get("models") or [])
        if isinstance(m, dict) and m.get("name")
    ]
    ps = _http_get_json(f"{clean_base}/api/ps", timeout=timeout) or {}
    loaded = [
        str(m.get("name"))
        for m in (ps.get("models") or [])
        if isinstance(m, dict) and m.get("name")
    ]
    return {
        "online": True,
        "base_url": clean_base,
        "installed_models": installed,
        "loaded_models": loaded,
    }


def _pick_ollama_model(installed: list[str], preferred: str) -> tuple[str, str | None]:
    if not installed:
        return (
            preferred,
            f"Ollama laeuft, aber Modell '{preferred}' muss noch via 'ollama pull {preferred}' geladen werden.",
        )
    if preferred in installed or f"{preferred}:latest" in installed:
        match = preferred if preferred in installed else f"{preferred}:latest"
        return match, None
    pref_prefix = preferred.split(":", 1)[0]
    for candidate in installed:
        if candidate.startswith(f"{pref_prefix}:") or candidate == pref_prefix:
            return candidate, f"Bevorzugtes Tag '{preferred}' fehlt; verwende installiertes '{candidate}'."
    return installed[0], f"Bevorzugtes Modell '{preferred}' fehlt; Fallback auf '{installed[0]}'."


def _adc_candidate_paths() -> list[Path]:
    paths: list[Path] = []
    explicit = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "").strip()
    if explicit:
        paths.append(Path(explicit))
    appdata = os.getenv("APPDATA", "").strip()
    if appdata:
        paths.append(Path(appdata) / "gcloud" / "application_default_credentials.json")
    paths.append(Path.home() / ".config" / "gcloud" / "application_default_credentials.json")
    return paths


def has_vertex_adc() -> bool:
    return any(p.is_file() for p in _adc_candidate_paths())


def has_gemini_api_key() -> bool:
    return bool(os.getenv("GEMINI_API_KEY", "").strip())


def has_antigravity_sdk() -> bool:
    try:
        if importlib.util.find_spec("google") is None:
            return False
        return importlib.util.find_spec("google.antigravity") is not None
    except (ImportError, ValueError, AttributeError):
        return False


def select_route(
    task_tier: TaskTier = "auto",
    workload: WorkloadType = "general",
    simrig_mode: str | None = None,
    prefer_vertex: bool = True,
    timeout: float = 1.5,
    prompt: str = "",
    files_count: int = 0,
    cloud_budget_exhausted: bool = False,
) -> RouteDecision:
    mode = (simrig_mode or fetch_simrig_mode(timeout=timeout)).strip().upper()
    adc_ok = has_vertex_adc()
    key_ok = has_gemini_api_key()
    weight = assess_payload_weight(prompt=prompt, files_count=files_count)

    # Praediktives Ressourcen-Dispatching bei High-Weight Tasks im Auto-Modus:
    if task_tier == "auto" and weight.weight_class == "high" and mode == "LIVE_RACE":
        if cloud_budget_exhausted or (not adc_ok and not key_ok):
            q_path = enqueue_high_weight_task(prompt=prompt, workload=workload, assessment=weight)
            return RouteDecision(
                target="high_weight_queue",
                model=None,
                base_url=None,
                project=None,
                location=None,
                simrig_mode=mode,
                workload=workload,
                reason=f"LIVE_RACE aktiv + High-Weight Task (Score={weight.weight_score}) + Cloud-Budget erschöpft -> in High-Weight Queue geparkt ({q_path.name}).",
                weight_score=weight.weight_score,
                weight_class=weight.weight_class,
            )
        cloud_dec = select_route(
            task_tier="cloud",
            workload=workload,
            simrig_mode=mode,
            prefer_vertex=prefer_vertex,
            timeout=timeout,
        )
        cloud_dec.reason = f"High-Weight Task (Score={weight.weight_score}, Dateien={weight.attached_files}) waehrend LIVE_RACE -> Eskalation an Cloud ({cloud_dec.target}) zum Schutz der Laptop-GPU."
        cloud_dec.weight_score = weight.weight_score
        cloud_dec.weight_class = weight.weight_class
        return cloud_dec

    # Low-Weight Telemetrie/Coaching-Tasks (z. B. Sarah Sektordeltas) direkt auf Laptop-Ollama halten, um 5070 Ti zu schonen
    if task_tier == "auto" and weight.weight_class == "low" and prompt and len(prompt) < 180 and workload == "general":
        laptop_fast = probe_ollama(LAPTOP_OLLAMA_BASE, timeout=timeout)
        if laptop_fast["online"]:
            chosen, warn = _pick_ollama_model(laptop_fast["installed_models"], LAPTOP_CHAT_MODEL)
            return RouteDecision(
                target="laptop_ollama",
                model=chosen,
                base_url=LAPTOP_OLLAMA_BASE,
                project=None,
                location=None,
                simrig_mode=mode,
                workload=workload,
                reason=f"Low-Weight Micro-Task (Score={weight.weight_score}) -> direkt auf Laptop Ollama ({chosen}), schont RTX 5070 Ti.",
                warning=warn,
                weight_score=weight.weight_score,
                weight_class=weight.weight_class,
            )

    if task_tier == "cloud":
        if prefer_vertex and (adc_ok or not key_ok):
            warn = None if adc_ok else "Keine gcloud ADC gefunden ('gcloud auth application-default login' ausfuehren)."
            return RouteDecision(
                target="vertex_adc",
                model=None,
                base_url=None,
                project=GCP_PROJECT,
                location=GCP_LOCATION,
                simrig_mode=mode,
                workload=workload,
                reason="Cloud-Routing ueber Vertex AI (Application Default Credentials).",
                warning=warn,
            )
        if key_ok:
            return RouteDecision(
                target="gemini_api_env",
                model=None,
                base_url=None,
                project=None,
                location=None,
                simrig_mode=mode,
                workload=workload,
                reason="Cloud-Routing ueber Gemini API (Umgebungsvariable GEMINI_API_KEY).",
            )
        return RouteDecision(
            target="vertex_adc",
            model=None,
            base_url=None,
            project=GCP_PROJECT,
            location=GCP_LOCATION,
            simrig_mode=mode,
            workload=workload,
            reason="Cloud angefordert, Vertex ADC als Standardziel gewaehlt.",
            warning="Weder gcloud ADC noch GEMINI_API_KEY gefunden.",
        )

    simracer_probe = (
        {"online": False, "installed_models": []}
        if mode == "LIVE_RACE"
        else probe_ollama(SIMRACER_OLLAMA_BASE, timeout=timeout)
    )
    if mode != "LIVE_RACE" and simracer_probe["online"]:
        pref = SIMRACER_CODE_MODEL if workload == "code" else SIMRACER_CHAT_MODEL
        chosen, warn = _pick_ollama_model(simracer_probe["installed_models"], pref)
        return RouteDecision(
            target="simracer_ollama",
            model=chosen,
            base_url=SIMRACER_OLLAMA_BASE,
            project=None,
            location=None,
            simrig_mode=mode,
            workload=workload,
            reason=f"SimRacer Ollama (:11434) im Modus {mode} verfuegbar (RTX 5070 Ti 16 GB, Score={weight.weight_score}/{weight.weight_class}).",
            warning=warn,
            weight_score=weight.weight_score,
            weight_class=weight.weight_class,
        )

    laptop_probe = probe_ollama(LAPTOP_OLLAMA_BASE, timeout=timeout)
    if laptop_probe["online"]:
        installed_laptop = laptop_probe["installed_models"]
        pref = (
            LAPTOP_CODE_MODEL
            if (workload == "code" and LAPTOP_CODE_MODEL in installed_laptop)
            else LAPTOP_CHAT_MODEL
        )
        chosen, warn = _pick_ollama_model(installed_laptop, pref)
        why = (
            f"LIVE_RACE aktiv -> RTX 5070 Ti fuer VR reserviert, weiche auf Laptop Ollama aus (Score={weight.weight_score}/{weight.weight_class})."
            if mode == "LIVE_RACE"
            else f"SimRacer Ollama nicht erreichbar -> lokaler Laptop-Ollama Fallback aktiv (Score={weight.weight_score}/{weight.weight_class})."
        )
        return RouteDecision(
            target="laptop_ollama",
            model=chosen,
            base_url=LAPTOP_OLLAMA_BASE,
            project=None,
            location=None,
            simrig_mode=mode,
            workload=workload,
            reason=why,
            warning=warn,
            weight_score=weight.weight_score,
            weight_class=weight.weight_class,
        )

    if task_tier == "auto":
        cloud_decision = select_route(
            task_tier="cloud",
            workload=workload,
            simrig_mode=mode,
            prefer_vertex=prefer_vertex,
            timeout=timeout,
        )
        cloud_decision.reason = f"Lokale Ollama-Knoten nicht verfuegbar ({mode}) -> Eskalation: {cloud_decision.reason}"
        return cloud_decision

    return RouteDecision(
        target="offline",
        model=None,
        base_url=None,
        project=None,
        location=None,
        simrig_mode=mode,
        workload=workload,
        reason="Kein lokaler Ollama-Knoten erreichbar (task_tier='local').",
        warning="Starte Ollama oder fuehre setup-ollama-node.ps1 aus.",
    )


def build_antigravity_config(
    decision: RouteDecision, cloud_model: str | None = None
) -> Any:
    if decision.target == "offline":
        raise RuntimeError(decision.warning or decision.reason)

    try:
        from google.antigravity import LocalAgentConfig, LocalOpenAIAgentConfig
    except ImportError as exc:
        raise RuntimeError(
            "Paket 'google-antigravity' ist in diesem Python-Interpreter nicht verfuegbar "
            "(z. B. C:\\Users\\strik\\.local\\python-env\\Scripts\\python.exe verwenden)."
        ) from exc

    if decision.target in ("simracer_ollama", "laptop_ollama"):
        if not decision.model or not decision.base_url:
            raise ValueError(f"Unvollstaendige Ollama-Routing-Konfiguration: {decision}")
        return LocalOpenAIAgentConfig(
            model=decision.model,
            base_url=f"{decision.base_url.rstrip('/')}/v1",
        ).lightweight()

    if decision.target == "vertex_adc":
        kwargs: dict[str, Any] = {
            "vertex": True,
            "project": decision.project or GCP_PROJECT,
            "location": decision.location or GCP_LOCATION,
        }
        if cloud_model:
            kwargs["model"] = cloud_model
        return LocalAgentConfig(**kwargs)

    if decision.target == "gemini_api_env":
        if not has_gemini_api_key():
            raise RuntimeError("Umgebungsvariable GEMINI_API_KEY ist nicht gesetzt.")
        kwargs = {}
        if cloud_model:
            kwargs["model"] = cloud_model
        return LocalAgentConfig(**kwargs)

    raise ValueError(f"Unbekanntes Routing-Ziel: {decision.target}")


def run_diagnostic(
    task_tier: TaskTier = "auto",
    workload: WorkloadType = "general",
    prefer_vertex: bool = True,
    timeout: float = 1.5,
) -> dict[str, Any]:
    strikerpi = fetch_simrig_status(timeout=timeout)
    simracer = probe_ollama(SIMRACER_OLLAMA_BASE, timeout=timeout)
    laptop = probe_ollama(LAPTOP_OLLAMA_BASE, timeout=timeout)
    decision = select_route(
        task_tier=task_tier,
        workload=workload,
        simrig_mode=strikerpi["mode"],
        prefer_vertex=prefer_vertex,
        timeout=timeout,
    )
    return {
        "strikerpi_relay": strikerpi,
        "simracer_ollama": simracer,
        "laptop_ollama": laptop,
        "auth": {
            "vertex_adc_present": has_vertex_adc(),
            "gemini_api_key_set": has_gemini_api_key(),
            "gcp_project": GCP_PROJECT,
            "gcp_location": GCP_LOCATION,
        },
        "sdk": {
            "google_antigravity_installed": has_antigravity_sdk(),
        },
        "selected_route": asdict(decision),
    }


async def run_prompt(
    prompt: str, decision: RouteDecision, cloud_model: str | None = None
) -> str:
    from google.antigravity import Agent

    cfg = build_antigravity_config(decision, cloud_model=cloud_model)
    async with Agent(config=cfg) as agent:
        response = await agent.chat(prompt)
        return await response.text()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Hybrid Ollama + Google Antigravity SDK Router"
    )
    parser.add_argument(
        "--tier",
        choices=["auto", "local", "cloud"],
        default="auto",
        help="Routing-Strategie (Standard: auto).",
    )
    parser.add_argument(
        "--workload",
        choices=["general", "code"],
        default="general",
        help="Arbeitslast-Typ zur lokalen Modellwahl (Standard: general).",
    )
    parser.add_argument(
        "--cloud-model",
        default=None,
        help="Optionales explizites Gemini Cloud-Modell (ohne Angabe gilt SDK-Standard).",
    )
    parser.add_argument(
        "--no-vertex",
        action="store_true",
        help="Bei Cloud-Nutzung GEMINI_API_KEY statt Vertex ADC bevorzugen.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Nur Diagnose & Routing-Entscheidung ausgeben (keine bezahlte API-Anfrage).",
    )
    parser.add_argument(
        "--prompt",
        default=None,
        help="Prompt direkt ueber das gewaehlte Ziel ausfuehren.",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=1.5,
        help="HTTP-Probe Timeout in Sekunden (Standard: 1.5).",
    )

    args = parser.parse_args(argv)
    prefer_vertex = not args.no_vertex

    if args.check or not args.prompt:
        report = run_diagnostic(
            task_tier=args.tier,
            workload=args.workload,
            prefer_vertex=prefer_vertex,
            timeout=args.timeout,
        )
        print(json.dumps(report, indent=2, ensure_ascii=False))
        return 0

    decision = select_route(
        task_tier=args.tier,
        workload=args.workload,
        prefer_vertex=prefer_vertex,
        timeout=args.timeout,
    )
    try:
        answer = asyncio.run(
            run_prompt(args.prompt, decision, cloud_model=args.cloud_model)
        )
    except Exception as exc:
        print(f"[FEHLER] {exc}", file=sys.stderr)
        return 1

    print(answer)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
