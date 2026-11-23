#!/usr/bin/env python3
"""
Multi-Node-Testfahrt-Observer & Engpass-Auswerter auf VanstrikeCyborg.

Modi:
  --watch            Ueberwacht parallel StrikerPi (:8080/health), Netzwerk-RTTs
                     (.68 SimRacer, .86 StrikerPi, .98 Archibald) und SimRacer-SMB-Logs.
  --analyze [ID]     Wertet SimRacer- + Cyborg-Logs nach der Testfahrt komplett aus und
                     erstellt AUSWERTUNG_<SessionId>.md unter git-labor/Systemtests/.
  --stop             Schreibt STOP_OBSERVER (und optional --stop-simracer STOP_RECORDER).
"""

from __future__ import annotations

import argparse
import concurrent.futures
import json
import math
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Any

SIMRACER_TELEMETRY_SMB = Path(r"\\192.168.178.68\ac-sandbox\shared\telemetry")
ACTIVE_SESSION_FILE = SIMRACER_TELEMETRY_SMB / "ACTIVE_SESSION.json"
SYSTEMTESTS_DIR = Path(r"C:\Users\strik\git-labor\Systemtests")
STRIKERPI_HEALTH_URL = "http://192.168.178.86:8080/health"

PING_TARGETS = {
    "simracer": "192.168.178.68",
    "strikerpi": "192.168.178.86",
    "archibald": "192.168.178.98",
}

_PING_RE = re.compile(r"(?:Zeit|time)\s*([=<])\s*([\d.,]+)\s*ms", re.IGNORECASE)


def now_iso() -> str:
    return datetime.now().astimezone().isoformat(timespec="milliseconds")


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    rows: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8-sig", errors="replace") as fh:
        for line in fh:
            s = line.strip()
            if not s:
                continue
            try:
                obj = json.loads(s)
                if isinstance(obj, dict):
                    rows.append(obj)
            except ValueError:
                continue
    return rows


def read_last_jsonl_entry(path: Path) -> tuple[dict[str, Any] | None, int]:
    if not path.exists():
        return None, 0
    try:
        size = path.stat().st_size
        if size == 0:
            return None, 0
        with path.open("rb") as fh:
            chunk_size = min(size, 16384)
            fh.seek(-chunk_size, os.SEEK_END)
            tail = fh.read(chunk_size).decode("utf-8", errors="replace")
        lines = [ln.strip() for ln in tail.splitlines() if ln.strip()]
        for ln in reversed(lines):
            try:
                obj = json.loads(ln)
                if isinstance(obj, dict):
                    return obj, size
            except ValueError:
                continue
        return None, size
    except OSError:
        return None, 0


def count_lines_fast(path: Path) -> int:
    if not path.exists():
        return 0
    try:
        with path.open("rb") as fh:
            return sum(1 for _ in fh)
    except OSError:
        return 0


def probe_strikerpi_health(timeout: float = 1.5) -> dict[str, Any]:
    t0 = time.perf_counter()
    req = urllib.request.Request(STRIKERPI_HEALTH_URL, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            rtt_ms = round((time.perf_counter() - t0) * 1000.0, 2)
            data = json.loads(resp.read().decode("utf-8", errors="replace"))
            return {"online": True, "rtt_ms": rtt_ms, "data": data if isinstance(data, dict) else {}}
    except (urllib.error.URLError, TimeoutError, ValueError, OSError) as exc:
        return {"online": False, "rtt_ms": None, "error": str(exc), "data": {}}


def ping_once(ip: str, timeout_ms: int = 900) -> float | None:
    creation_flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
    try:
        proc = subprocess.run(
            ["ping", "-n", "1", "-w", str(timeout_ms), ip],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=max(2.0, timeout_ms / 1000.0 + 1.0),
            creationflags=creation_flags,
        )
        out = proc.stdout or ""
        m = _PING_RE.search(out)
        if m:
            op = m.group(1)
            val = float(m.group(2).replace(",", "."))
            if op == "<" and val <= 1.0:
                return 0.5
            return round(val, 2)
        return None
    except (subprocess.SubprocessError, ValueError, OSError):
        return None


def probe_all_pings() -> dict[str, float | None]:
    results: dict[str, float | None] = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(PING_TARGETS)) as pool:
        futs = {name: pool.submit(ping_once, ip) for name, ip in PING_TARGETS.items()}
        for name, fut in futs.items():
            try:
                results[name] = fut.result(timeout=2.5)
            except Exception:
                results[name] = None
    return results


def unc_to_session_dir(ptr: dict[str, Any]) -> Path:
    sid = str(ptr.get("session_id") or "").strip()
    if sid:
        return SIMRACER_TELEMETRY_SMB / sid
    raw_dir = str(ptr.get("session_dir") or "")
    leaf = Path(raw_dir).name
    return SIMRACER_TELEMETRY_SMB / leaf


def wait_for_active_session(session_id_override: str | None, wait_sec: int = 30) -> dict[str, Any]:
    if session_id_override:
        return {
            "session_id": session_id_override,
            "session_dir": str(SIMRACER_TELEMETRY_SMB / session_id_override),
            "status": "recording",
        }
    deadline = time.monotonic() + wait_sec
    while time.monotonic() < deadline:
        if ACTIVE_SESSION_FILE.exists():
            try:
                ptr = load_json(ACTIVE_SESSION_FILE)
                if isinstance(ptr, dict) and ptr.get("session_id") and ptr.get("status") == "recording":
                    return ptr
            except (ValueError, OSError):
                pass
        time.sleep(1.0)
    sid = f"cyborg_only_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    return {"session_id": sid, "session_dir": "", "status": "standalone"}


def run_watch(session_id_override: str | None, interval: float, max_minutes: int) -> int:
    ptr = wait_for_active_session(session_id_override, wait_sec=20)
    session_id = str(ptr["session_id"])
    sim_dir = unc_to_session_dir(ptr) if ptr.get("session_id") else None

    local_dir = SYSTEMTESTS_DIR / f"Testdrive_{session_id}"
    local_dir.mkdir(parents=True, exist_ok=True)
    obs_log = local_dir / "cyborg_observer.jsonl"
    pid_file = local_dir / "cyborg_observer.pid"
    stop_flag = local_dir / "STOP_OBSERVER"

    if stop_flag.exists():
        stop_flag.unlink(missing_ok=True)

    pid_file.write_text(str(os.getpid()), encoding="utf-8")

    meta = {
        "session_id": session_id,
        "observer_pid": os.getpid(),
        "started_at": now_iso(),
        "simracer_smb_dir": str(sim_dir) if sim_dir else None,
        "local_dir": str(local_dir),
        "interval_sec": interval,
    }
    (local_dir / "observer_meta.json").write_text(
        json.dumps(meta, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    prev_packets: int | None = None
    prev_packet_ts: float | None = None
    prev_mode: str | None = None
    start_mono = time.monotonic()
    deadline_mono = start_mono + max_minutes * 60.0
    tick = 0

    while time.monotonic() < deadline_mono:
        if stop_flag.exists():
            break

        tick += 1
        t_mono = time.monotonic()
        elapsed_s = round(t_mono - start_mono, 2)

        sp = probe_strikerpi_health()
        sp_data = sp.get("data", {})
        cur_mode = str(sp_data.get("mode") or "OFFLINE") if sp.get("online") else "OFFLINE"
        cur_packets = sp_data.get("packets_processed")
        hz: float | None = None
        if isinstance(cur_packets, int) and prev_packets is not None and prev_packet_ts is not None:
            dt = t_mono - prev_packet_ts
            if dt > 0.2:
                hz = round(max(0, cur_packets - prev_packets) / dt, 2)
        if isinstance(cur_packets, int):
            prev_packets = cur_packets
            prev_packet_ts = t_mono

        last_seen_age_s: float | None = None
        if sp.get("online") and isinstance(sp_data.get("last_seen"), (int, float)):
            last_seen_age_s = round(time.time() - float(sp_data["last_seen"]), 2)

        mode_changed = prev_mode is not None and cur_mode != prev_mode
        prev_mode = cur_mode

        pings = probe_all_pings()

        sim_metrics_last: dict[str, Any] | None = None
        sim_metrics_bytes = 0
        sim_events_count = 0
        sim_status = "unknown"

        if ACTIVE_SESSION_FILE.exists():
            try:
                ap = load_json(ACTIVE_SESSION_FILE)
                if ap.get("session_id") == session_id:
                    sim_status = str(ap.get("status") or "unknown")
            except (ValueError, OSError):
                pass

        if sim_dir and sim_dir.exists():
            sim_metrics_last, sim_metrics_bytes = read_last_jsonl_entry(sim_dir / "metrics.jsonl")
            sim_events_count = count_lines_fast(sim_dir / "events.jsonl")

        sim_summary = None
        if sim_metrics_last:
            sim_summary = {
                "tick": sim_metrics_last.get("tick"),
                "phase": sim_metrics_last.get("phase"),
                "cpu_pct": sim_metrics_last.get("cpu_pct"),
                "ram_used_mb": sim_metrics_last.get("ram_used_mb"),
                "ram_pct": sim_metrics_last.get("ram_pct"),
                "gpu_util": sim_metrics_last.get("gpu_util"),
                "vram_used_mb": sim_metrics_last.get("vram_used_mb"),
                "gpu_temp_c": sim_metrics_last.get("gpu_temp_c"),
                "gpu_power_w": sim_metrics_last.get("gpu_power_w"),
            }

        row = {
            "ts": now_iso(),
            "tick": tick,
            "elapsed_s": elapsed_s,
            "strikerpi": {
                "online": bool(sp.get("online")),
                "http_rtt_ms": sp.get("rtt_ms"),
                "mode": cur_mode,
                "mode_changed": mode_changed,
                "packets_processed": cur_packets,
                "telemetry_hz": hz,
                "active_clients": sp_data.get("active_clients"),
                "mqtt_connected": sp_data.get("mqtt_connected"),
                "last_seen_age_s": last_seen_age_s,
            },
            "ping_ms": pings,
            "simracer": {
                "status": sim_status,
                "metrics_bytes": sim_metrics_bytes,
                "events_count": sim_events_count,
                "latest": sim_summary,
            },
        }
        with obs_log.open("a", encoding="utf-8") as fh:
            fh.write(json.dumps(row, ensure_ascii=False) + "\n")

        if sim_status == "completed":
            break

        sleep_left = interval - (time.monotonic() - t_mono)
        if sleep_left > 0.1:
            time.sleep(sleep_left)

    meta["ended_at"] = now_iso()
    meta["ticks"] = tick
    (local_dir / "observer_meta.json").write_text(
        json.dumps(meta, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return 0


def percentile(values: list[float], pct: float) -> float | None:
    if not values:
        return None
    s = sorted(values)
    idx = (len(s) - 1) * pct / 100.0
    lo = math.floor(idx)
    hi = math.ceil(idx)
    if lo == hi:
        return round(s[int(idx)], 2)
    return round(s[lo] * (hi - idx) + s[hi] * (idx - lo), 2)


def summarize_num(values: list[float | int | None]) -> dict[str, Any]:
    clean = [float(v) for v in values if isinstance(v, (int, float))]
    if not clean:
        return {"n": 0, "avg": None, "p95": None, "max": None, "min": None}
    return {
        "n": len(clean),
        "avg": round(sum(clean) / len(clean), 2),
        "p95": percentile(clean, 95),
        "max": round(max(clean), 2),
        "min": round(min(clean), 2),
    }


def resolve_session_paths(target: str | None) -> tuple[str, Path, Path]:
    sid: str | None = target
    if not sid and ACTIVE_SESSION_FILE.exists():
        try:
            ptr = load_json(ACTIVE_SESSION_FILE)
            sid = str(ptr.get("session_id") or "")
        except (ValueError, OSError):
            sid = None
    if not sid and SYSTEMTESTS_DIR.exists():
        dirs = sorted(SYSTEMTESTS_DIR.glob("Testdrive_*"), key=lambda p: p.stat().st_mtime, reverse=True)
        if dirs:
            sid = dirs[0].name.replace("Testdrive_", "", 1)
    if not sid:
        raise FileNotFoundError("Keine Testdrive-Session gefunden.")
    if sid.startswith("Testdrive_"):
        sid = sid.replace("Testdrive_", "", 1)
    return sid, SIMRACER_TELEMETRY_SMB / sid, SYSTEMTESTS_DIR / f"Testdrive_{sid}"


def analyze_session(target: str | None) -> Path:
    sid, sim_dir, local_dir = resolve_session_paths(target)
    local_dir.mkdir(parents=True, exist_ok=True)

    baseline = load_json(sim_dir / "baseline.json") if (sim_dir / "baseline.json").exists() else {}
    events = load_jsonl(sim_dir / "events.jsonl")
    metrics = load_jsonl(sim_dir / "metrics.jsonl")
    ev_warnings = (
        load_jsonl(sim_dir / "eventlog_warnings.json")
        if (sim_dir / "eventlog_warnings.json").exists() and (sim_dir / "eventlog_warnings.json").read_text(encoding="utf-8-sig").lstrip().startswith("{")
        else (load_json(sim_dir / "eventlog_warnings.json") if (sim_dir / "eventlog_warnings.json").exists() else [])
    )
    obs_rows = load_jsonl(local_dir / "cyborg_observer.jsonl")

    phase_events = [ev for ev in events if ev.get("type") == "PHASE"]
    proc_starts = [ev for ev in events if ev.get("type") == "PROC_START"]
    proc_exits = [ev for ev in events if ev.get("type") == "PROC_EXIT"]

    # Phasen-Statistik ueber metrics.jsonl
    by_phase: dict[str, list[dict[str, Any]]] = {}
    for row in metrics:
        ph = str(row.get("phase") or "UNKNOWN")
        by_phase.setdefault(ph, []).append(row)

    # Hintergrund-Prozesse mit relevanter Last identifizieren
    proc_stats: dict[str, dict[str, Any]] = {}
    for row in metrics:
        for kp in row.get("key_procs") or []:
            nm = str(kp.get("name") or "")
            if not nm:
                continue
            st = proc_stats.setdefault(nm, {"samples": 0, "max_ram_mb": 0.0, "total_cpu_s": 0.0})
            st["samples"] += 1
            st["max_ram_mb"] = max(st["max_ram_mb"], float(kp.get("ram_mb") or 0.0))
            st["total_cpu_s"] += float(kp.get("cpu_s") or 0.0)

    # StrikerPi & Ping Stats
    ping_stats = {
        k: summarize_num([r.get("ping_ms", {}).get(k) for r in obs_rows])
        for k in PING_TARGETS
    }
    hz_all = summarize_num([r.get("strikerpi", {}).get("telemetry_hz") for r in obs_rows if r.get("strikerpi", {}).get("mode") == "LIVE_RACE"])
    live_ticks = [r for r in obs_rows if r.get("strikerpi", {}).get("mode") == "LIVE_RACE"]
    live_drops = [r for r in live_ticks if r.get("strikerpi", {}).get("telemetry_hz") == 0]

    # Engpaesse automatisch markieren
    findings: list[str] = []
    phase_map = {p.get("phase"): p for p in phase_events}
    if "VR_INIT" in phase_map and "VR_COMPOSITOR_READY" in phase_map:
        dt_vr = round(float(phase_map["VR_COMPOSITOR_READY"]["elapsed_s"]) - float(phase_map["VR_INIT"]["elapsed_s"]), 1)
        if dt_vr > 25:
            findings.append(f"**Langsamer VR-Start ({dt_vr} s):** Zwischen `VR_INIT` und `VR_COMPOSITOR_READY` vergingen {dt_vr} s (SteamVR/VIVE-Logs unter `captured_logs/` prüfen).")
    if "AC_RUNNING" in by_phase:
        ac_cpu = summarize_num([r.get("cpu_pct") for r in by_phase["AC_RUNNING"]])
        ac_ram = summarize_num([r.get("ram_pct") for r in by_phase["AC_RUNNING"]])
        ac_vram = summarize_num([r.get("vram_used_mb") for r in by_phase["AC_RUNNING"]])
        ac_temp = summarize_num([r.get("gpu_temp_c") for r in by_phase["AC_RUNNING"]])
        if ac_cpu["p95"] and ac_cpu["p95"] >= 85:
            findings.append(f"**Hohe CPU-Last während `AC_RUNNING`:** P95={ac_cpu['p95']} % / Max={ac_cpu['max']} %.")
        if ac_ram["max"] and ac_ram["max"] >= 85:
            findings.append(f"**Hohe RAM-Belegung während `AC_RUNNING`:** Max={ac_ram['max']} %.")
        if ac_vram["max"] and ac_vram["max"] >= 14500:
            findings.append(f"**VRAM-Spitze nahe 16-GB-Grenze:** Max={ac_vram['max']} MB auf RTX 5070 Ti.")
        if ac_temp["max"] and ac_temp["max"] >= 82:
            findings.append(f"**Hohe GPU-Temperatur:** Max={ac_temp['max']} °C.")
    for noisy in ("MsMpEng", "TiWorker", "TrustedInstaller", "Docker Desktop", "vmmemWSL", "vmmem"):
        if noisy in proc_stats and proc_stats[noisy]["total_cpu_s"] >= 15.0:
            findings.append(f"**Hintergrund-CPU durch `{noisy}`:** {round(proc_stats[noisy]['total_cpu_s'], 1)} CPU-Sekunden und max. {round(proc_stats[noisy]['max_ram_mb'], 1)} MB RAM verbraucht.")
    for node, pst in ping_stats.items():
        if pst["p95"] and pst["p95"] >= 15.0:
            findings.append(f"**Netz-Latenzspitze zu `{node}`:** P95={pst['p95']} ms (Max={pst['max']} ms).")
    if live_drops:
        findings.append(f"**Telemetrie-Aussetzer im `LIVE_RACE`:** {len(live_drops)} von {len(live_ticks)} Ticks meldeten 0 Hz.")
    if isinstance(ev_warnings, list) and ev_warnings:
        findings.append(f"**Windows-EventLog:** {len(ev_warnings)} Warnungen/Fehler seit Session-Start unter `eventlog_warnings.json`.")
    if not findings:
        findings.append("Keine offensichtlichen CPU-, RAM-, VRAM-, Telemetrie- oder Latenz-Engpässe erkannt.")

    lines: list[str] = [
        f"# Testfahrt-Auswertung: `{sid}`",
        "",
        f"> **SimRacer-Pfad:** `{sim_dir}`  ",
        f"> **Cyborg-Observer-Pfad:** `{local_dir}`  ",
        f"> **Samples:** SimRacer `{len(metrics)}` Ticks | Events `{len(events)}` | Cyborg `{len(obs_rows)}` Ticks",
        "",
        "<details>",
        "<summary><b>1. Identifizierte Engpässe &amp; Optimierungshinweise</b></summary>",
        "",
    ]
    for item in findings:
        lines.append(f"- {item}")
    lines += ["", "</details>", "", "<details>", "<summary><b>2. Startprozedur &amp; Phasen-Stoppuhr (ab Recorder-Start / Steam)</b></summary>", ""]
    lines.append("| Zeit (s) | Ab Steam (s) | Phase | Details |")
    lines.append("| ---: | ---: | :--- | :--- |")
    for ev in phase_events:
        ss = ev.get("elapsed_since_steam_s")
        ss_str = f"{ss}" if ss is not None else "—"
        lines.append(f"| {ev.get('elapsed_s')} | {ss_str} | `{ev.get('phase')}` | {ev.get('detail')} |")
    if live_ticks:
        first_live = live_ticks[0]
        lines.append(f"\n- **Erster `LIVE_RACE`-Zeitpunkt auf StrikerPi:** `{first_live.get('ts')}` (`t = {first_live.get('elapsed_s')} s` am Observer).")

    lines += ["", "</details>", "", "<details>", "<summary><b>3. CPU / RAM / GPU / VRAM je Phase (SimRacer RTX 5070 Ti)</b></summary>", ""]
    lines.append("| Phase | Ticks | CPU Avg/Max % | RAM Max MB (%) | GPU Avg/Max % | VRAM Max MB | Temp Max °C | Power Max W |")
    lines.append("| :--- | ---: | :--- | :--- | :--- | ---: | ---: | ---: |")
    for ph, rows in by_phase.items():
        cpu_s = summarize_num([r.get("cpu_pct") for r in rows])
        ram_mb = summarize_num([r.get("ram_used_mb") for r in rows])
        ram_pct = summarize_num([r.get("ram_pct") for r in rows])
        gpu_s = summarize_num([r.get("gpu_util") for r in rows])
        vram_s = summarize_num([r.get("vram_used_mb") for r in rows])
        tmp_s = summarize_num([r.get("gpu_temp_c") for r in rows])
        pwr_s = summarize_num([r.get("gpu_power_w") for r in rows])
        lines.append(
            f"| `{ph}` | {len(rows)} | {cpu_s['avg']} / {cpu_s['max']} | {ram_mb['max']} ({ram_pct['max']} %) | {gpu_s['avg']} / {gpu_s['max']} | {vram_s['max']} | {tmp_s['max']} | {pwr_s['max']} |"
        )

    lines += ["", "</details>", "", "<details>", "<summary><b>4. Prozess-Starts &amp; Hintergrund-Verbraucher</b></summary>", ""]
    lines.append(f"- Gestartete Key-Prozesse: `{len(proc_starts)}` | Beendete Key-Prozesse: `{len(proc_exits)}`")
    lines.append("")
    lines.append("| Prozess | Samples | Kumulierte CPU (s) | Max RAM (MB) |")
    lines.append("| :--- | ---: | ---: | ---: |")
    for nm, st in sorted(proc_stats.items(), key=lambda kv: (-kv[1]["total_cpu_s"], -kv[1]["max_ram_mb"])):
        lines.append(f"| `{nm}` | {st['samples']} | {round(st['total_cpu_s'], 2)} | {round(st['max_ram_mb'], 1)} |")

    lines += ["", "</details>", "", "<details>", "<summary><b>5. Multi-Node-Netzwerk (Ping RTT) &amp; StrikerPi-Telemetrie</b></summary>", ""]
    lines.append("| Ziel | Samples | Avg ms | P95 ms | Max ms |")
    lines.append("| :--- | ---: | ---: | ---: | ---: |")
    for node, pst in ping_stats.items():
        lines.append(f"| `{node}` ({PING_TARGETS[node]}) | {pst['n']} | {pst['avg']} | {pst['p95']} | {pst['max']} |")
    lines.append("")
    lines.append(
        f"- **Telemetrie im `LIVE_RACE`:** Ticks=`{len(live_ticks)}`, Hz Avg=`{hz_all['avg']}`, Min=`{hz_all['min']}`, Max=`{hz_all['max']}`, 0-Hz-Aussetzer=`{len(live_drops)}`"
    )
    if baseline.get("race_ini"):
        lines.append(f"- **Ausgangs-`race.ini`:** `{json.dumps(baseline['race_ini'], ensure_ascii=False)}`")
    lines += ["", "</details>", ""]

    report_path = local_dir / f"AUSWERTUNG_{sid}.md"
    report_path.write_text("\n".join(lines), encoding="utf-8")
    return report_path


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="SimRig Testfahrt-Observer & Auswerter")
    mode_grp = parser.add_mutually_exclusive_group()
    mode_grp.add_argument("--watch", action="store_true", help="Live-Observer starten (Standard).")
    mode_grp.add_argument("--analyze", nargs="?", const="", default=None, help="Session auswerten (optional Session-ID).")
    mode_grp.add_argument("--stop", action="store_true", help="STOP_OBSERVER setzen.")
    parser.add_argument("--stop-simracer", action="store_true", help="Mit --stop auch STOP_RECORDER auf SimRacer setzen.")
    parser.add_argument("--session-id", default=None, help="Explizite Session-ID.")
    parser.add_argument("--interval", type=float, default=5.0, help="Poll-Intervall in Sekunden (Standard: 5.0).")
    parser.add_argument("--max-minutes", type=int, default=240, help="Maximale Laufzeit in Minuten.")

    args = parser.parse_args(argv)

    if args.stop:
        sid, sim_dir, local_dir = resolve_session_paths(args.session_id)
        local_dir.mkdir(parents=True, exist_ok=True)
        (local_dir / "STOP_OBSERVER").write_text(now_iso(), encoding="utf-8")
        print(f"STOP_OBSERVER written: {local_dir / 'STOP_OBSERVER'}")
        if args.stop_simracer and sim_dir.exists():
            (sim_dir / "STOP_RECORDER").write_text(now_iso(), encoding="utf-8")
            print(f"STOP_RECORDER written: {sim_dir / 'STOP_RECORDER'}")
        return 0

    if args.analyze is not None:
        target = args.analyze or args.session_id
        report = analyze_session(target)
        print(f"REPORT_WRITTEN: {report}")
        return 0

    return run_watch(args.session_id, interval=args.interval, max_minutes=args.max_minutes)


if __name__ == "__main__":
    raise SystemExit(main())
