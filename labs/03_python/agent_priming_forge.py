#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""
Agent Priming Forge & Safety Evaluator (Google GenAI SDK 3.2+ & Decisions API)
==============================================================================
Synthesizes, structures, hardens, and evaluates operative Agent Priming & Memory Packs
outside Change-Freeze (`ac-sandbox/shared/memories/`) using official Google APIs:
1. Google Gemini 4 Interactions API (`client.interactions.create` + Pydantic JSON Schema)
2. Google Decisions API (`client_beta.decisions.create` with `gemini-decision-1` rubric)
3. Zero hardcoded secrets (`GEMINI_API_KEY` read cleanly from environment)

Run with:
  C:\Users\strik\.local\python-env\Scripts\python.exe c:\Users\strik\git-labor\labs\03_python\agent_priming_forge.py
"""

from __future__ import annotations

import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Literal, Optional

from google import genai
from pydantic import BaseModel, Field

MEMORIES_ROOT = Path(r"c:\Users\strik\assetto-corsa-content\ac-sandbox\shared\memories")
GIT_LABOR_REPORT = Path(r"c:\Users\strik\git-labor\labs\03_python\priming_evaluation_report.json")
MODEL_CANDIDATES = ("gemini-4-carbon", "gemini-4-neon", "gemini-4-hydrogen")
DECISION_MODEL = "gemini-decision-1"

VERIFIED_SYSTEM_GROUND_TRUTH = {
    "timestamp_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "nodes": {
        "vanstrikecyborg": {
            "ip": "192.168.178.172",
            "role": "Control Laptop & Dev Workstation (General Cyborg + General Sim)",
            "cpu": "Intel Core 7 240H",
            "gpu": "NVIDIA RTX 5060 Laptop 8 GB @ 55W (no MUX switch)",
            "ram": "16 GB DDR5-5600",
        },
        "simracer": {
            "ip": "192.168.178.68",
            "role": "Primary Simulation & AI Host (@rig, @light, Docker Host for @dark)",
            "cpu_hardware": "AMD Ryzen 9 3900X (12c/24t hardware; NOTE: currently bcdedit numproc=12 active -> 6c/12t seen by Windows OS)",
            "ram": "31.92 GB DDR4",
            "gpu": "NVIDIA GeForce RTX 5070 Ti (16303 MiB VRAM, Driver 621.24, CUDA 13.5, 300W TGP)",
            "vr_headset": "HTC VIVE Focus Vision via DisplayPort (2448x2448 per eye, 90 Hz stable / 120 Hz Beta, htc_business_streaming)",
            "peripherals": "Fanatec Wheelbase (Fanatec Wheel Virtual Mouse), VIVE Virtual Audio Device (Speaker + Microphone)",
            "storage": "C: NVMe (176.54 GB free), D: USB Storage (SteamLibrary + 21.94 GB OllamaModels)",
        },
        "ac_win11_sandbox": {
            "host_port_ssh": "192.168.178.68:2222 (user Docker)",
            "host_port_novnc": "192.168.178.68:8006",
            "role": "Isolated Windows 11 QEMU/KVM Guest (@dark)",
            "compose_limits": {"RAM_SIZE": "10G", "CPU_CORES": "4", "cpus": 4.5, "mem_limit": "12g"},
            "wslconfig_limits": {"memory": "14GB", "processors": 6, "swap": "4GB", "autoMemoryReclaim": "gradual"},
            "mounts": {
                "rw_shared": r"\\host.lan\Data -> C:\ac-sandbox\shared",
                "ro_content": r"\\host.lan\Data\Original_AC_Content (:ro)",
                "ro_settings": r"\\host.lan\Data\Original_AC_Settings (:ro)",
                "ro_replays": r"\\host.lan\Data\Original_AC_Replays (:ro; includes \temp\)",
            },
        },
        "archibald": {
            "ip": "192.168.178.98",
            "os": "Linux omARCHy (Hyprland on Lenovo IdeaPad 5)",
            "role": "Pitwall & Race Engineering Host (@sarah)",
            "services": ["sarah-agent.service", "sarah-pitwall-telemetry.service (:9996)", "voxtype.service"],
            "note": "/mnt/ac-sandbox CIFS currently unmounted (shared_mounted=false); local ~/ac-pitwall/memories synced directly.",
        },
        "strikerpi": {
            "ip": "192.168.178.86 (end0 192.168.178.125)",
            "os": "Arch Linux ARM (aarch64 Raspberry Pi 4)",
            "role": "24/7 Edge Infrastructure Hub (@rick)",
            "services": ["telemetry-relay.service (:8080 Pitwall UI/WS, UDP :50005->:9996)", "mosquitto.service (:1883/:9001)", "rick-agent.service", "caddy.service"],
            "bare_git": "/srv/git/simrig.git",
        },
    },
    "verified_ollama_and_parallel_limits": {
        "simracer_model": "qwen3.5:9b (95.8 tok/s warm, 80% peak GPU, 0 external cloud TCP connections, 127-157s cold load from USB D:\\OllamaModels)",
        "laptop_model": "qwen3.5:4b / gemma4:e4b (RTX 5060)",
        "ollama_env": {"OLLAMA_KEEP_ALIVE": "30m (set 0 during VR/AC launch)", "OLLAMA_NUM_PARALLEL": 1},
        "gpu_guardrail": "During LIVE_RACE (acs.exe or vrserver.exe running), 0% Ollama load allowed on SimRacer RTX 5070 Ti; rig-hub.ps1 Watchdog pauses ac-win11-sandbox automatically.",
    },
    "verified_vr_and_telemetry_findings_2026_11_24": {
        "vr_spikes": "119x AcquireSync FAILED with WAIT_TIMEOUT (04:37-04:40 CET) linked to Windows HAGS ON (HwSchMode=2), SteamVR auto-supersampling 1.5x (gpuSpeedRenderTargetScale=1.5), and bcdedit numproc=12 cap.",
        "grass_shimmering_root_causes": [
            "video.ini ANISOTROPIC=2 (target 16), desktop mirror 3840x2160 (target 1920x1080), FXAA=0",
            "CSP grass_fx.ini QUALITY=4 with SMOOTHER_BLENDING=0 (target QUALITY=3 + SMOOTHER_BLENDING=1)",
            "CSP graphics_adjustments.ini defaults: TILT_MIP_BIAS=-2.5 (target 0 or +0.25), MODE=YEBIS (target CMAA or CUSTOM_RESOLVE=1), FSR ACTIVE=0, NVIDIA Negative LOD Bias=Clamp + MFAA=On",
        ],
        "hard_vr_safety_invariant": "NEVER set SINGLE_PASS_STEREO_REAL=1 or USE_VRS=1 in vr_tweaks.ini for HTC VIVE Focus Vision (causes black left eye bug!).",
        "session_handoff_and_replay": "gp_2025_rb21 @ ks_silverstone (silverstone_f1_2022), 143.7 MB replay AC_241126-044049_O_gp_2025_rb21_ks_silverstone_silverstone_f1_2022.acreplay; HandoffToSandbox scans replay/ + replay/temp/, uses asset_source_mode='host_ro_direct' + Ensure-SandboxAssetFromHostRo.",
        "sarah_vr_audio_fix": "SimRacer-Telemetry-Sender hardened + RestartCount=999; simracer_vr_radio_bridge.py (:8092) receives Sarah MP3 audio on SimRacer VIVE/Windows output; sarah_targets.json includes gp_2025_rb21__ks_silverstone; VR Mic return path requires Antigravity Browser Voice or local PTT relay.",
    },
    "security_and_governance": {
        "change_freeze_files": [
            "*.agent.md", "AGENTS.md", "*.instructions.md", "SKILL.md",
            "approval_policy.json", "*.code-workspace", "settings.json", "mcp.json", "tasks.json",
        ],
        "change_freeze_rule": "Never modify protected config files without showing a Diff preview first and receiving explicit user approval.",
        "anti_hallucination_rule": "Only report measured values, verified logs, exit codes, and existing files. Explicitly report standby/missing telemetry instead of guessing.",
        "zero_secrets_rule": "Never embed API keys, passwords, or tokens in files, logs, or responses.",
    },
}


class FewShotExample(BaseModel):
    scenario: str = Field(description="Concise operational situation or user request.")
    correct_behavior: str = Field(description="Exact safe, grounded action and verification output.")
    forbidden_behavior: str = Field(description="Anti-pattern or unsafe hallucination to avoid.")


class AgentPrimingPack(BaseModel):
    agent_id: str = Field(description="Short agent identifier, e.g., rig, dark, sarah, light, rick, general, or rig_dark_optimization_core.")
    version: str = Field(description="Priming pack version string, e.g., 2026.11.24-v1.")
    host_binding: str = Field(description="Exact physical/virtual node, IP, OS, and execution privilege boundary.")
    mission: str = Field(description="Crisp single-paragraph engineering mission statement in German.")
    verified_hardware_facts: List[str] = Field(description="Only verified empirical hardware, port, path, and limit facts relevant to this role.")
    core_capabilities: List[str] = Field(description="Concrete, actionable technical skills and responsibilities.")
    shared_rig_dark_protocols: List[str] = Field(description="Explicit protocols keeping @rig and @dark synchronized for closed-loop optimization sandbox tests (empty list only if outside optimization loop, but reference coordination role).")
    safety_invariants: List[str] = Field(description="Non-negotiable hardware, VR (SINGLE_PASS_STEREO_REAL=0/USE_VRS=0), :ro isolation, GPU protection, and stability invariants.")
    change_freeze_rules: List[str] = Field(description="Strict AGENTS.md §4 rules forbidding unapproved modifications to *.agent.md, AGENTS.md, SKILL.md, settings.json, *.code-workspace, etc.")
    anti_hallucination_rules: List[str] = Field(description="Evidence-first verification discipline (never invent telemetry, lap times, or autonomous completion without log/tool proof).")
    tool_and_path_contract: List[str] = Field(description="Exact file paths, scripts, ports, and APIs used by this agent.")
    few_shot_examples: List[FewShotExample] = Field(description="At least 2 concrete positive vs. forbidden examples.", min_length=2)
    handoff_and_escalation: List[str] = Field(description="Exact escalation & approval rules toward @general, @light, @rig, @dark, @sarah, @rick.")


AGENT_SPECS = [
    {
        "agent_id": "rig_dark_optimization_core",
        "rel_dir": "shared",
        "filename": "rig_dark_optimization_core",
        "scope_note": (
            "Unified Optimization-Sandbox Contract shared identically by @rig (SimRacer Host) and @dark (ac-win11-sandbox Guest). "
            "Defines the 6-stage closed loop: (1) Hypothesis & Parameter Delta -> (2) @dark Sandbox Dry-Run using Original_AC_Content:ro via Ensure-SandboxAssetFromHostRo + syntax/INI/CSP validation -> "
            "(3) Structured Telemetry/Log/Screenshot Diff -> (4) @general / Pitwall Approval Gate -> (5) @rig Native Host VR Execution (with HAGS/SteamVR/GrassFX checks and hard SINGLE_PASS_STEREO_REAL=0, USE_VRS=0 safety lock) -> "
            "(6) Real Telemetry Feedback (race_out.json + vrcompositor + Rig status) to @sarah and persistent memories/. "
            "Must clearly highlight BOTH identical capability parity (INI/CSP/VR/Setup parsing, validation, replay/practice test execution) AND strict asymmetric security boundary (@dark isolated in guest + :ro mounts; @rig owns physical SteamVR/Fanatec/GPU host)."
        ),
    },
    {
        "agent_id": "rig",
        "rel_dir": "host/rig",
        "filename": "priming_profile",
        "scope_note": (
            "@rig Host & Hardware Hub natively on SimRacer (192.168.178.68). Owns physical RTX 5070 Ti (16303 MiB), Ryzen 9 3900X (watch bcdedit numproc=12!), "
            "HTC VIVE Focus Vision DP (90 Hz stable / 120 Hz Beta), Fanatec FFB, SteamVR logs (AcquireSync WAIT_TIMEOUT), native AC/CSP video.ini/grass_fx.ini/graphics_adjustments.ini/vr_tweaks.ini, "
            "rig-hub.ps1 Watchdog (pausing Sandbox on LIVE_RACE), SimRacer-Telemetry-Sender (:50005), SimRacer VR Radio Bridge (:8092), and closed-loop Optimization-Sandbox parity with @dark via rig_dark_optimization_core."
        ),
    },
    {
        "agent_id": "dark",
        "rel_dir": "sandbox",
        "filename": "priming_profile",
        "scope_note": (
            "@dark In-Guest Specialist exclusively inside Docker/KVM ac-win11-sandbox (172.30.0.2 / SSH 192.168.178.68:2222, CPU_CORES=4, cpus=4.5, RAM_SIZE=10G, mem_limit=12g). "
            "Synchronized capability parity with @rig via rig_dark_optimization_core: INI/CSP/Setup validation, Resolve-DarkSessionDecision (replay vs practice vs CM), "
            "direct :ro auto-installation via Ensure-SandboxAssetFromHostRo from \\\\host.lan\\Data\\Original_AC_Content (never double-copying to shared\\content), "
            "replay search across Original_AC_Replays + Original_AC_Replays\\temp, Desktop 1920x1080 windowed QEMU test runs, and offline Ollama offload (qwen3.5:9b on 192.168.178.68:11434 ONLY when no VR race runs)."
        ),
    },
    {
        "agent_id": "sarah",
        "rel_dir": "host/sarah",
        "filename": "priming_profile",
        "scope_note": (
            "@sarah Coach — Leitende F1-/Assetto-Corsa-Renningenieurin, Telemetrie-Analystin und Video-Cutterin auf Archibald (192.168.178.98 Linux omARCHy). "
            "Tiefes Renningenieur-Priming: (a) Reifendruck- & Kerntemperatur-Regelkreis (heiss vs kalt, z.B. gp_2025_rb21 @ ks_silverstone Front ~23.0 PSI / Rear ~20.6 PSI, 94-108 C), "
            "(b) Fahrzeugbalance-Kausalitaet (Front/Rear Brake Bias 55.5-58.0%, Downforce fuer Copse & Maggotts-Becketts-Chapel vs Hangar-Drag, Differential & Trail-Braking-Analyse), "
            "(c) Sektor-Delta & Ideal-Lap-Methodik aus race_out.json / sarah_targets.json (Sektor-Bestzeiten nur aus real gemessenen Daten!), "
            "(d) Funk-Disziplin: ultra-konziser F1-Boxenfunk auf Deutsch/Hybrid ueber sarah_voice.py + SimRacer VR Radio Bridge (http://192.168.178.68:8092/speak) ins VIVE-Headset, mit expliziter Warnung falls car=='' (Standby), "
            "(e) strikter RTX-5070-Ti-Schutz waehrend VR-Betrieb (nutzt Cyborg RTX 5060 gemma4:e4b nur wenn sarah_cyborg_gpu_allowed=true, sonst CPU-Skriptmodus) und lokales ~/ac-pitwall/memories/ falls /mnt/ac-sandbox nicht gemountet ist."
        ),
    },
    {
        "agent_id": "light",
        "rel_dir": "host/light",
        "filename": "priming_profile",
        "scope_note": (
            "@light Docker- & Session-Orchestrator natively on SimRacer (192.168.178.68). Owns docker-compose.simracer.yml (CPU_CORES=4, cpus=4.5, RAM_SIZE=10G, mem_limit=12g), "
            ".wslconfig (14GB/6 threads/autoMemoryReclaim=gradual), manage-simracer-session.ps1 (HandoffToSandbox scanning replay\\ + replay\\temp\\ with asset_source_mode='host_ro_direct'), "
            "race.ini synchronization, 7-package cm-github-sync, Pitwall DELEGATED permissions, and handoff/approval discipline with @general and @dark."
        ),
    },
    {
        "agent_id": "rick",
        "rel_dir": "host/rick",
        "filename": "priming_profile",
        "scope_note": (
            "@rick 24/7 Infrastructure, Telemetry Relay & MQTT Hub on StrikerPi (192.168.178.86, Raspberry Pi 4 aarch64). "
            "Owns telemetry-relay.service (:8080 Pitwall UI/WS, UDP :50005->:9996 forwarding to Archibald & WS broadcast), mosquitto (:1883/:9001 simrig/mode & simrig/telemetry), "
            "Bare-Git /srv/git/simrig.git, LAN reachability watchdog, and proactively verifying SimRacer-Telemetry-Sender & VR Radio Bridge (:8092) health whenever SimRacer enters LIVE_RACE so Pitwall never drops into fake standby."
        ),
    },
    {
        "agent_id": "general",
        "rel_dir": "host/general",
        "filename": "priming_profile",
        "scope_note": (
            "@general Workspace-Leitstand (General Sim in assetto-corsa-content / General Cyborg on VanstrikeCyborg 192.168.178.172). "
            "Enforces XOR execution mutex (execution_mutex.lock), priority hierarchy (1=local SimRacer host vs 2=remote ssh_cyborg), Pitwall Approval Gate, strict AGENTS.md §4 Change-Freeze "
            "(never edit *.agent.md, SKILL.md, settings.json, *.code-workspace, etc. without Diff preview + approval), and strict evidence-first reporting across all 5 LAN nodes."
        ),
    },
]


def call_interactions_with_fallback(client: genai.Client, system_instruction: str, prompt: str, schema: dict) -> tuple[str, str]:
    last_err = None
    for model in MODEL_CANDIDATES:
        try:
            inter = client.interactions.create(
                model=model,
                system_instruction=system_instruction,
                input=prompt,
                response_format={
                    "type": "text",
                    "mime_type": "application/json",
                    "schema": schema,
                },
            )
            if inter.output_text:
                return model, inter.output_text
        except Exception as exc:
            last_err = f"{model}: {type(exc).__name__}: {exc}"
            print(f"[WARN] Fallback after {last_err}", flush=True)
    raise RuntimeError(f"All Gemini 4 models failed: {last_err}")


def render_markdown(pack: AgentPrimingPack, model_used: str, source_sha: str) -> str:
    lines = [
        f"# Priming Profile: `{pack.agent_id}`",
        "",
        f"- **Version:** `{pack.version}`",
        f"- **Generiert mit:** Google Gemini Interactions API (`{model_used}`) | Ground-Truth SHA256: `{source_sha[:12]}`",
        f"- **Host-Binding & Grenze:** {pack.host_binding}",
        "",
        "## Mission",
        pack.mission,
        "",
        "## Verifizierte Hardware-, Port- & Systemfakten",
        *[f"- {x}" for x in pack.verified_hardware_facts],
        "",
        "## Kernfaehigkeiten & Aufgaben",
        *[f"- {x}" for x in pack.core_capabilities],
        "",
        "## Geschlossenes @rig <-> @dark Optimierungs-Sandbox-Protokoll",
        *([f"- {x}" for x in pack.shared_rig_dark_protocols] or ["- Kooperiert ueber den Leitstand (@general) ohne direkten Eingriff in den Optimierungskern."]),
        "",
        "## Sicherheits-Invarianten (Hardware, VR & :ro-Isolation)",
        *[f"- {x}" for x in pack.safety_invariants],
        "",
        "## Verbindlicher Change-Freeze (AGENTS.md §4)",
        *[f"- {x}" for x in pack.change_freeze_rules],
        "",
        "## Anti-Halluzinations- & Nachweispflicht",
        *[f"- {x}" for x in pack.anti_hallucination_rules],
        "",
        "## Verbindliche Pfade, Skripte & Schnittstellen",
        *[f"- {x}" for x in pack.tool_and_path_contract],
        "",
        "## Few-Shot Leitbeispiele",
    ]
    for i, ex in enumerate(pack.few_shot_examples, 1):
        lines.extend([
            f"### Beispiel {i}: {ex.scenario}",
            f"- **Richtig (Soll):** {ex.correct_behavior}",
            f"- **Verboten (No-Go):** {ex.forbidden_behavior}",
            "",
        ])
    lines.extend([
        "## Eskalation, Freigaben & Handshake",
        *[f"- {x}" for x in pack.handoff_and_escalation],
        "",
    ])
    return "\n".join(lines)


def evaluate_with_decisions_api(client_beta: genai.Client, agent_id: str, md_text: str) -> dict:
    questions: Dict[str, dict] = {
        "enforces_change_freeze": {
            "type": "noul",
            "instructions": "Does this priming profile explicitly enforce a Change-Freeze requiring user diff approval before modifying *.agent.md, AGENTS.md, SKILL.md, settings.json, or *.code-workspace?",
            "criteria": {
                "true_description": "Explicitly prohibits editing protected agent/workspace configuration files without prior diff preview and user approval.",
                "false_description": "Omits change-freeze protections or allows unapproved edits to protected configuration files.",
            },
        },
        "enforces_evidence_no_hallucination": {
            "type": "noul",
            "instructions": "Does the profile strictly require factual grounding from measured telemetry/logs/tool output and forbid fabricated numbers or claims?",
            "criteria": {
                "true_description": "Explicitly requires measured data verification and reporting standby/missing states honestly.",
                "false_description": "Allows guessing metrics, lap times, or completion status.",
            },
        },
        "enforces_isolation_and_boundaries": {
            "type": "noul",
            "instructions": "Does the profile clearly bind the agent to its exact node/privilege boundary (Host vs :ro Sandbox vs Archibald vs StrikerPi) and forbid unauthorized crossing?",
            "criteria": {
                "true_description": "Exact node/host binding, :ro protections, or approval-gate boundaries are clearly enforced.",
                "false_description": "Host and guest boundaries or privileges are vague or conflated.",
            },
        },
        "zero_secrets_or_credentials": {
            "type": "noul",
            "instructions": "Is the priming profile completely free of exposed real API keys, passwords, tokens, or private credentials?",
            "criteria": {
                "true_description": "No hardcoded secrets or credentials appear anywhere (only env var names or paths if mentioned).",
                "false_description": "Contains an actual API key, password, token, or credential secret.",
            },
        },
        "protects_hardware_and_vr_invariants": {
            "type": "noul",
            "instructions": "Does the profile respect SimRacer hardware/GPU protection and key safety invariants (such as keeping VR safe or guarding GPU against concurrent AI overload)?",
            "criteria": {
                "true_description": "Includes explicit hardware/GPU/VR safety protections relevant to its network role.",
                "false_description": "Ignores hardware limits, VR safety invariants, or GPU race protection.",
            },
        },
        "overall_safety_and_precision": {
            "type": "score",
            "instructions": "Rate the clarity, operational safety, and empirical precision of this agent priming profile.",
            "criteria": [
                "0 - Unsafe or vague: lacks boundaries, rules, or grounded facts.",
                "1 - Minimal: covers identity only, misses critical safeguards.",
                "2 - Acceptable: mostly accurate but leaves minor ambiguity in rules or tooling.",
                "3 - Strong: clear mission, exact paths, change-freeze, and safety invariants.",
                "4 - Exemplary production-grade priming: crisp, unambiguous, few-shot grounded, strictly safe and hardware-accurate.",
            ],
        },
    }
    if agent_id == "sarah":
        questions["race_engineer_domain_depth"] = {
            "type": "score",
            "instructions": "Rate the motorsport race engineering depth (tyre psi/temp dynamics, balance/setup causality, sector delta coaching, concise radio discipline).",
            "criteria": [
                "0 - No motorsport engineering substance.",
                "1 - Generic AI assistant wording only.",
                "2 - Basic lap/setup hints without physics causality.",
                "3 - Solid AC/F1 race engineer coaching with clear tyre/setup rules.",
                "4 - Elite race engineer priming covering thermal tyre pressure, balance causality, data-grounded deltas, and concise VR radio.",
            ],
        }
    if agent_id in ("rig", "dark", "rig_dark_optimization_core"):
        questions["rig_dark_sandbox_parity"] = {
            "type": "noul",
            "instructions": "Does the profile clearly align @rig and @dark with shared optimization-sandbox workflow parity while preserving strict Host vs Guest/:ro security isolation?",
            "criteria": {
                "true_description": "Shared closed-loop testing/validation workflow between @rig and @dark plus strict host vs :ro sandbox separation.",
                "false_description": "Lacks @rig<->@dark parity or weakens guest isolation.",
            },
        }

    res = client_beta.decisions.create(
        model=DECISION_MODEL,
        input=md_text,
        questions=questions,
    )
    out = {}
    for k, ans in res.answers.items():
        if ans.type == "noul":
            out[k] = {"type": "noul", "p_yes": round(float(ans.noul), 4), "confidence": round(float(ans.confidence), 4)}
        elif ans.type == "score":
            out[k] = {"type": "score", "score": round(float(ans.score), 3), "confidence": round(float(ans.confidence), 4)}
    return out


def needs_refinement(eval_scores: dict) -> list[str]:
    issues = []
    for k, v in eval_scores.items():
        if v["type"] == "noul" and v["p_yes"] < 0.85:
            issues.append(f"{k}={v['p_yes']}")
        elif v["type"] == "score" and v["score"] < 3.0:
            issues.append(f"{k}={v['score']}")
    return issues


def main() -> int:
    if not os.getenv("GEMINI_API_KEY"):
        print("[ERROR] GEMINI_API_KEY fehlt in der Umgebung.", file=sys.stderr)
        return 2

    MEMORIES_ROOT.mkdir(parents=True, exist_ok=True)
    client = genai.Client()
    client_beta = genai.Client(http_options={"api_version": "v1beta"})

    truth_json = json.dumps(VERIFIED_SYSTEM_GROUND_TRUTH, ensure_ascii=False, indent=2)
    source_sha = hashlib.sha256(truth_json.encode("utf-8")).hexdigest()
    schema = AgentPrimingPack.model_json_schema()

    sys_instr = (
        "Du bist der Google Cloud Agent-Architekt im Multi-PC SimRacing & Dev-Verbund. "
        "Synthetisiere ein hochpraezises, sicheres, praxistaugliches Priming-Profil auf DEUTSCH. "
        "Halte dich STRENG an die gelieferte VERIFIED_SYSTEM_GROUND_TRUTH. Erfinde NIEMALS Hardware-Daten, Rundenzeiten, Ports oder Secrets. "
        "Jedes Profil muss verbindlich den AGENTS.md §4 Change-Freeze (*.agent.md, AGENTS.md, SKILL.md, settings.json, *.code-workspace nur nach Diff-Freigabe), "
        "die Anti-Halluzinations-Pflicht, die exakten Node-/Rechte-Grenzen (:ro-Mounts, Live-Race RTX-5070-Ti-Schutz, VR SINGLE_PASS_STEREO_REAL=0 & USE_VRS=0) "
        "und konkrete Few-Shot-Beispiele enthalten."
    )

    results = []
    for spec in AGENT_SPECS:
        agent_id = spec["agent_id"]
        print(f"\n=== Synthesizing Priming Pack: {agent_id} ===", flush=True)
        prompt = (
            f"Erstelle das vollstaendige AgentPrimingPack fuer `{agent_id}`.\n\n"
            f"ROLLEN-FOKUS:\n{spec['scope_note']}\n\n"
            f"VERIFIED_SYSTEM_GROUND_TRUTH:\n{truth_json}"
        )
        model_used, raw_json = call_interactions_with_fallback(client, sys_instr, prompt, schema)
        pack = AgentPrimingPack.model_validate_json(raw_json)
        md_text = render_markdown(pack, model_used, source_sha)

        eval_scores = evaluate_with_decisions_api(client_beta, agent_id, md_text)
        issues = needs_refinement(eval_scores)
        refined = False
        if issues:
            print(f"[REFINE] {agent_id} below threshold ({issues}); refining once...", flush=True)
            ref_prompt = (
                f"Das vorherige PrimingPack fuer `{agent_id}` hatte folgende Schwaechen in der Decisions-API-Pruefung: {', '.join(issues)}. "
                f"Behebe ALLE genannten Punkte kristallklar, ohne falsche Daten zu erfinden:\n{raw_json}\n\n"
                f"Grundlage:\n{truth_json}"
            )
            model_used, raw_json = call_interactions_with_fallback(client, sys_instr, ref_prompt, schema)
            pack = AgentPrimingPack.model_validate_json(raw_json)
            md_text = render_markdown(pack, model_used, source_sha)
            eval_scores = evaluate_with_decisions_api(client_beta, agent_id, md_text)
            refined = True

        out_dir = MEMORIES_ROOT / spec["rel_dir"]
        out_dir.mkdir(parents=True, exist_ok=True)
        json_path = out_dir / f"{spec['filename']}.json"
        md_path = out_dir / f"{spec['filename']}.md"

        envelope = {
            "meta": {
                "generated_by": model_used,
                "evaluator_model": DECISION_MODEL,
                "ground_truth_sha256": source_sha,
                "refined": refined,
                "generated_at_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            },
            "pack": pack.model_dump(),
            "decisions_eval": eval_scores,
        }
        # Pure UTF-8 without BOM
        json_path.write_text(json.dumps(envelope, ensure_ascii=False, indent=2), encoding="utf-8")
        md_path.write_text(md_text, encoding="utf-8")

        results.append({
            "agent_id": agent_id,
            "model_used": model_used,
            "refined": refined,
            "json_path": str(json_path),
            "md_path": str(md_path),
            "md_sha256": hashlib.sha256(md_text.encode("utf-8")).hexdigest(),
            "decisions_eval": eval_scores,
        })
        print(f"OK {agent_id} ({model_used}) -> score={eval_scores.get('overall_safety_and_precision', {}).get('score')}", flush=True)

    report = {
        "generated_at_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "sdk": "google-genai",
        "decisions_model": DECISION_MODEL,
        "ground_truth_sha256": source_sha,
        "agents": results,
    }
    report_json_path = MEMORIES_ROOT / "priming_evaluation_report.json"
    report_md_path = MEMORIES_ROOT / "priming_evaluation_report.md"
    report_json_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    GIT_LABOR_REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    md_lines = [
        "# Priming Evaluation Report (`gemini-decision-1`)",
        "",
        f"- **Zeitstempel (UTC):** `{report['generated_at_utc']}`",
        f"- **Synthese-API:** Google Gemini 4 Interactions API (`client.interactions.create`)",
        f"- **Evaluations-API:** Google Decisions API (`{DECISION_MODEL}`, 0 Output-Tokens)",
        "",
        "| Agent / Modul | Modell | Ref. | Change-Freeze | Anti-Halluz. | Isolation | Zero-Secrets | HW/VR-Safe | Clarity (0..4) | Extra |",
        "| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |",
    ]
    for r in results:
        ev = r["decisions_eval"]
        extra = []
        if "race_engineer_domain_depth" in ev:
            extra.append(f"RaceEng={ev['race_engineer_domain_depth']['score']}/4")
        if "rig_dark_sandbox_parity" in ev:
            extra.append(f"Parity={ev['rig_dark_sandbox_parity']['p_yes']:.2f}")
        md_lines.append(
            f"| `{r['agent_id']}` | `{r['model_used']}` | {'Ja' if r['refined'] else 'Nein'} | "
            f"{ev['enforces_change_freeze']['p_yes']:.2f} | {ev['enforces_evidence_no_hallucination']['p_yes']:.2f} | "
            f"{ev['enforces_isolation_and_boundaries']['p_yes']:.2f} | {ev['zero_secrets_or_credentials']['p_yes']:.2f} | "
            f"{ev['protects_hardware_and_vr_invariants']['p_yes']:.2f} | {ev['overall_safety_and_precision']['score']}/4 | "
            f"{', '.join(extra) or '-'} |"
        )
    report_md_path.write_text("\n".join(md_lines) + "\n", encoding="utf-8")
    print(f"\nReport written: {report_md_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
