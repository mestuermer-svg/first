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

TaskTier = Literal["policy", "auto", "local", "cloud", "ollama", "gemini"]
WorkloadType = Literal["general", "code"]
WeightClass = Literal["low", "medium", "high"]

ALLOWED_GEMINI_MODELS = (
    "gemini-3.8-flash",
    "gemini-3.5-flash-lite",
    "gemini-2.5-flash",
    "gemini-2.5-pro",
    "gemini-4-argon",
    "gemini-4-neon",
)
DEFAULT_GEMINI_MODEL = os.getenv("HYBRID_GEMINI_MODEL", "gemini-3.8-flash")
STRIKERPI_API_BASE = os.getenv("STRIKERPI_API_BASE", "http://192.168.178.86:8080").rstrip("/")
SHARED_POLICY_PATH = Path(r"\\192.168.178.68\ac-sandbox\shared\agents\general-SIM\pitwall_control_policy.json")

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


def has_google_genai_sdk() -> bool:
    try:
        return importlib.util.find_spec("google") is not None and importlib.util.find_spec("google.genai") is not None
    except (ImportError, ValueError, AttributeError):
        return False


def fetch_llm_switch_policy(timeout: float = 1.5) -> dict[str, Any]:
    """Liest die zentrale Schaltweichen-Policy vom StrikerPi Pitwall-Hub oder direkt ueber SMB."""
    default_pol: dict[str, Any] = {
        "llm_backend": "ollama",
        "llm_gemini_model": DEFAULT_GEMINI_MODEL,
        "agent_llm_backends": {},
        "source": "default",
    }
    st = _http_get_json(f"{STRIKERPI_API_BASE}/api/llm/status", timeout=timeout)
    if st and st.get("llm_backend"):
        return {
            "llm_backend": str(st.get("llm_backend") or "ollama").lower(),
            "llm_gemini_model": str(st.get("llm_gemini_model") or DEFAULT_GEMINI_MODEL),
            "agent_llm_backends": dict(st.get("agent_llm_backends") or {}),
            "gemini_ready": bool(st.get("gemini_ready")),
            "source": "strikerpi_api",
        }
    if SHARED_POLICY_PATH.is_file():
        try:
            raw = json.loads(SHARED_POLICY_PATH.read_text(encoding="utf-8-sig"))
            if isinstance(raw, dict):
                return {
                    "llm_backend": str(raw.get("llm_backend") or "ollama").lower(),
                    "llm_gemini_model": str(raw.get("llm_gemini_model") or DEFAULT_GEMINI_MODEL),
                    "agent_llm_backends": dict(raw.get("agent_llm_backends") or {}),
                    "source": "smb_policy",
                }
        except Exception:
            pass
    return default_pol


def set_llm_switch_policy(
    backend: str | None = None,
    gemini_model: str | None = None,
    agent: str | None = None,
    timeout: float = 10.0,
) -> dict[str, Any]:
    """Schaltet die zentrale LLM-Schaltweiche ueber den Pitwall-Hub um."""
    payload: dict[str, Any] = {}
    if backend:
        bk = backend.strip().lower()
        if agent:
            payload["agent_llm_backends"] = {agent.strip().lower().lstrip("@"): bk}
        else:
            payload["llm_backend"] = bk
    if gemini_model:
        payload["llm_gemini_model"] = gemini_model.strip()
    req = urllib.request.Request(
        f"{STRIKERPI_API_BASE}/api/approvals/policy",
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        headers={"Content-Type": "application/json; charset=utf-8"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def _resolve_tier_from_policy(task_tier: str, agent: str | None = None, timeout: float = 1.5) -> tuple[str, dict[str, Any]]:
    pol = fetch_llm_switch_policy(timeout=timeout)
    t = (task_tier or "policy").strip().lower()
    if t in ("ollama", "local"):
        return "local", pol
    if t in ("gemini", "cloud"):
        return "cloud", pol
    if t == "auto":
        return "auto", pol
    # policy mode:
    eff = pol.get("llm_backend", "ollama")
    if agent:
        ag_key = agent.strip().lower().lstrip("@")
        ag_ov = str((pol.get("agent_llm_backends") or {}).get(ag_key) or "inherit").lower()
        if ag_ov in ("ollama", "auto", "gemini"):
            eff = ag_ov
    if eff == "gemini":
        return "cloud", pol
    if eff == "auto":
        return "auto", pol
    return "local", pol


def select_route(
    task_tier: TaskTier = "policy",
    workload: WorkloadType = "general",
    simrig_mode: str | None = None,
    prefer_vertex: bool = True,
    timeout: float = 1.5,
    prompt: str = "",
    files_count: int = 0,
    cloud_budget_exhausted: bool = False,
    agent: str | None = None,
) -> RouteDecision:
    eff_tier, pol = _resolve_tier_from_policy(task_tier, agent=agent, timeout=timeout)
    pol_model = str(pol.get("llm_gemini_model") or DEFAULT_GEMINI_MODEL)
    mode = (simrig_mode or fetch_simrig_mode(timeout=timeout)).strip().upper()
    adc_ok = has_vertex_adc()
    key_ok = has_gemini_api_key()
    weight = assess_payload_weight(prompt=prompt, files_count=files_count)

    # Praediktives Ressourcen-Dispatching bei High-Weight Tasks im Auto-Modus:
    if eff_tier == "auto" and weight.weight_class == "high" and mode == "LIVE_RACE":
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
            agent=agent,
        )
        cloud_dec.reason = f"High-Weight Task (Score={weight.weight_score}, Dateien={weight.attached_files}) waehrend LIVE_RACE -> Eskalation an Cloud ({cloud_dec.target}) zum Schutz der Laptop-GPU."
        cloud_dec.weight_score = weight.weight_score
        cloud_dec.weight_class = weight.weight_class
        return cloud_dec

    # Low-Weight Telemetrie/Coaching-Tasks (z. B. Sarah Sektordeltas) direkt auf Laptop-Ollama halten, um 5070 Ti zu schonen
    if eff_tier == "auto" and weight.weight_class == "low" and prompt and len(prompt) < 180 and workload == "general":
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

    if eff_tier == "cloud":
        if key_ok and (not prefer_vertex or not adc_ok):
            return RouteDecision(
                target="gemini_api_env",
                model=pol_model,
                base_url=None,
                project=None,
                location=None,
                simrig_mode=mode,
                workload=workload,
                reason=f"Cloud-Routing ueber Google Gemini Interactions API ({pol_model}, GEMINI_API_KEY).",
            )
        if prefer_vertex and (adc_ok or not key_ok):
            warn = None if adc_ok else "Keine gcloud ADC gefunden ('gcloud auth application-default login' ausfuehren)."
            return RouteDecision(
                target="vertex_adc",
                model=pol_model,
                base_url=None,
                project=GCP_PROJECT,
                location=GCP_LOCATION,
                simrig_mode=mode,
                workload=workload,
                reason=f"Cloud-Routing ueber Vertex AI / ADC ({pol_model}).",
                warning=warn,
            )
        if key_ok:
            return RouteDecision(
                target="gemini_api_env",
                model=pol_model,
                base_url=None,
                project=None,
                location=None,
                simrig_mode=mode,
                workload=workload,
                reason=f"Cloud-Routing ueber Gemini API ({pol_model}, Umgebungsvariable GEMINI_API_KEY).",
            )
        return RouteDecision(
            target="vertex_adc",
            model=pol_model,
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

    if eff_tier == "auto":
        cloud_decision = select_route(
            task_tier="cloud",
            workload=workload,
            simrig_mode=mode,
            prefer_vertex=prefer_vertex,
            timeout=timeout,
            agent=agent,
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
    task_tier: TaskTier = "policy",
    workload: WorkloadType = "general",
    prefer_vertex: bool = False,
    timeout: float = 1.5,
    agent: str | None = None,
) -> dict[str, Any]:
    strikerpi = fetch_simrig_status(timeout=timeout)
    simracer = probe_ollama(SIMRACER_OLLAMA_BASE, timeout=timeout)
    laptop = probe_ollama(LAPTOP_OLLAMA_BASE, timeout=timeout)
    switch_pol = fetch_llm_switch_policy(timeout=timeout)
    decision = select_route(
        task_tier=task_tier,
        workload=workload,
        simrig_mode=strikerpi["mode"],
        prefer_vertex=prefer_vertex,
        timeout=timeout,
        agent=agent,
    )
    return {
        "strikerpi_relay": strikerpi,
        "llm_switch_policy": switch_pol,
        "simracer_ollama": simracer,
        "laptop_ollama": laptop,
        "auth": {
            "vertex_adc_present": has_vertex_adc(),
            "gemini_api_key_set": has_gemini_api_key(),
            "gcp_project": GCP_PROJECT,
            "gcp_location": GCP_LOCATION,
        },
        "sdk": {
            "google_genai_installed": has_google_genai_sdk(),
            "google_antigravity_installed": has_antigravity_sdk(),
        },
        "selected_route": asdict(decision),
    }


def _run_ollama_chat_sync(base_url: str, model: str, prompt: str, timeout: float = 120.0) -> str:
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "stream": False,
        "think": False,
    }
    req = urllib.request.Request(
        f"{base_url.rstrip('/')}/api/chat",
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        headers={"Content-Type": "application/json; charset=utf-8"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    return str(((data.get("message") or {}).get("content")) or "").strip()


async def run_prompt(
    prompt: str, decision: RouteDecision, cloud_model: str | None = None
) -> str:
    if decision.target == "offline":
        raise RuntimeError(decision.warning or decision.reason)
    if decision.target == "high_weight_queue":
        return decision.reason

    if decision.target in ("simracer_ollama", "laptop_ollama"):
        if not decision.model or not decision.base_url:
            raise ValueError(f"Unvollstaendige Ollama-Routing-Konfiguration: {decision}")
        return _run_ollama_chat_sync(decision.base_url, decision.model, prompt)

    target_model = (cloud_model or decision.model or DEFAULT_GEMINI_MODEL).strip()
    if has_google_genai_sdk():
        from google import genai

        if decision.target == "vertex_adc" and not has_gemini_api_key():
            client = genai.Client(
                vertexai=True,
                project=decision.project or GCP_PROJECT,
                location=decision.location or GCP_LOCATION,
            )
        else:
            api_key = os.getenv("GEMINI_API_KEY", "").strip()
            if not api_key:
                raise RuntimeError("Umgebungsvariable GEMINI_API_KEY ist nicht gesetzt.")
            client = genai.Client(api_key=api_key)

        resp = client.interactions.create(
            model=target_model,
            input=prompt,
            store=False,
        )
        txt = str(getattr(resp, "output_text", "") or "").strip()
        if txt:
            return txt
        parts: list[str] = []
        for step in (getattr(resp, "steps", None) or []):
            for item in (getattr(step, "content", None) or []):
                t = getattr(item, "text", None)
                if isinstance(t, str) and t:
                    parts.append(t)
        return "\n".join(parts).strip()

    from google.antigravity import Agent

    cfg = build_antigravity_config(decision, cloud_model=target_model)
    async with Agent(config=cfg) as agent:
        response = await agent.chat(prompt)
        return await response.text()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Hybrid Ollama + Google Gemini (Interactions API) Router & Schaltweiche"
    )
    parser.add_argument(
        "--tier",
        choices=["policy", "auto", "local", "cloud", "ollama", "gemini"],
        default="policy",
        help="Routing-Strategie (Standard: policy -> folgt Pitwall-Schaltweiche).",
    )
    parser.add_argument(
        "--agent",
        default=None,
        help="Optionaler Agent-Name zur Pruefung eines Pro-Agent-Overrides (z. B. rig, dark, sarah).",
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
        help="Optionales explizites Gemini Cloud-Modell (Standard: Pitwall-Modell oder gemini-3.8-flash).",
    )
    parser.add_argument(
        "--set-backend",
        choices=["ollama", "auto", "gemini", "inherit"],
        default=None,
        help="Schaltet die zentrale Pitwall-Schaltweiche um (global oder mit --agent fuer einen Agenten).",
    )
    parser.add_argument(
        "--set-gemini-model",
        choices=list(ALLOWED_GEMINI_MODELS),
        default=None,
        help="Setzt das zentrale Gemini-Modell in der Pitwall-Schaltweiche.",
    )
    parser.add_argument(
        "--prefer-vertex",
        action="store_true",
        help="Bei Cloud-Nutzung Vertex ADC statt GEMINI_API_KEY bevorzugen.",
    )
    parser.add_argument(
        "--no-vertex",
        action="store_true",
        help="Rueckwaertskompatibles Flag: GEMINI_API_KEY bevorzugen.",
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
    prefer_vertex = bool(args.prefer_vertex) and not bool(args.no_vertex)

    if args.set_backend or args.set_gemini_model:
        try:
            res = set_llm_switch_policy(
                backend=args.set_backend,
                gemini_model=args.set_gemini_model,
                agent=args.agent,
                timeout=max(5.0, args.timeout),
            )
            pol = res.get("policy") or {}
            print(json.dumps({
                "ok": True,
                "llm_backend": pol.get("llm_backend"),
                "llm_gemini_model": pol.get("llm_gemini_model"),
                "agent_llm_backends": pol.get("agent_llm_backends"),
            }, indent=2, ensure_ascii=False))
            return 0
        except Exception as exc:
            print(f"[FEHLER Schaltweiche] {exc}", file=sys.stderr)
            return 1

    if args.check or not args.prompt:
        report = run_diagnostic(
            task_tier=args.tier,
            workload=args.workload,
            prefer_vertex=prefer_vertex,
            timeout=args.timeout,
            agent=args.agent,
        )
        print(json.dumps(report, indent=2, ensure_ascii=False))
        return 0

    decision = select_route(
        task_tier=args.tier,
        workload=args.workload,
        prefer_vertex=prefer_vertex,
        timeout=args.timeout,
        prompt=args.prompt,
        agent=args.agent,
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
