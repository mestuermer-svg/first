#!/usr/bin/env python3
"""
Analysiert SteamVR vrcompositor.txt auf Frame-Presents, Drops, Reprojection,
Application/Compositor Frametimes und Synchronisations-Timeouts (AcquireSync/ReleaseSync).

Verwendet ausschließlich die Python-Standardbibliothek (Python 3.12+).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path

DEFAULT_LOG_PATH = Path(
    r"\\192.168.178.68\C$\Program Files (x86)\Steam\logs\vrcompositor.txt"
)

RE_SUPPRESSED = re.compile(r"\[(\d+)\s+messages\s+suppressed\]")
RE_TOTAL_PRESENTS = re.compile(
    r"Total\.+\s*(\d+)\s+presents\.\s+(\d+)\s+dropped\.\s+(\d+)\s+reprojected"
)
RE_TIMED_OUT_PRESENTS = re.compile(
    r"Timed out\.\s*(\d+)\s+total\.+\s*(\d+)\s+presents\.\s+(\d+)\s+dropped\.\s+(\d+)\s+reprojected"
)
RE_COMPOSITOR_TIME = re.compile(
    r"Compositor Time\.+CPU:\s*([\d.]+)ms\s*/\s*GPU:\s*([\d.]+)ms"
)
RE_GAME_INFO = re.compile(
    r"Game Info\.+FPS Average Target\s+(\d+)\s+ApplicationTime\s+CPU:\s*([\d.]+)ms\s*/\s*GPU:\s*([\d.]+)ms"
)
RE_TIMESTAMP = re.compile(r"^([A-Za-z]{3}\s+[A-Za-z]{3}\s+\d+\s+\d{4}\s+\d{2}:\d{2}:\d{2}\.\d{3})")


@dataclass
class SessionSummary:
    timestamp: str | None = None
    total_presents: int = 0
    dropped_frames: int = 0
    reprojected_frames: int = 0
    timed_out_events: int = 0
    timed_out_presents: int = 0
    compositor_cpu_ms: float | None = None
    compositor_gpu_ms: float | None = None
    fps_target: int | None = None
    app_cpu_ms: float | None = None
    app_gpu_ms: float | None = None


@dataclass
class CompositorReport:
    log_path: str
    date_filter: str | None
    target_hz: float
    frame_budget_ms: float
    lines_scanned: int
    acquire_sync_timeouts: int
    release_sync_failures: int
    wait_for_acquire_timeouts: int
    sessions: list[SessionSummary] = field(default_factory=list)
    latest_session: SessionSummary | None = None
    bottleneck_assessment: str = ""


def _count_occurrences(line: str) -> int:
    suppressed_match = RE_SUPPRESSED.search(line)
    if suppressed_match:
        return int(suppressed_match.group(1))
    return 1


def analyze_vr_log(
    log_path: Path, date_filter: str | None, target_hz: float
) -> CompositorReport:
    if not log_path.is_file():
        raise FileNotFoundError(f"Logdatei nicht gefunden: {log_path}")

    lines_scanned = 0
    acquire_sync_timeouts = 0
    release_sync_failures = 0
    wait_for_acquire_timeouts = 0
    sessions: list[SessionSummary] = []
    current = SessionSummary()
    in_summary_block = False

    with log_path.open("r", encoding="utf-8", errors="replace") as fh:
        for raw_line in fh:
            line = raw_line.strip()
            if not line:
                continue
            if date_filter and date_filter not in line:
                continue
            lines_scanned += 1

            ts_match = RE_TIMESTAMP.match(line)
            ts_str = ts_match.group(1) if ts_match else None

            if "AcquireSync FAILED with WAIT_TIMEOUT" in line:
                acquire_sync_timeouts += _count_occurrences(line)
            elif "ReleaseSync FAILED with unknown hr 0x887a0001" in line:
                release_sync_failures += _count_occurrences(line)
            elif "WaitForAcquire timed out (FAILED)" in line:
                wait_for_acquire_timeouts += _count_occurrences(line)

            m_total = RE_TOTAL_PRESENTS.search(line)
            if m_total:
                if in_summary_block and current.total_presents > 0:
                    sessions.append(current)
                current = SessionSummary(
                    timestamp=ts_str,
                    total_presents=int(m_total.group(1)),
                    dropped_frames=int(m_total.group(2)),
                    reprojected_frames=int(m_total.group(3)),
                )
                in_summary_block = True
                continue

            if not in_summary_block:
                continue

            m_to = RE_TIMED_OUT_PRESENTS.search(line)
            if m_to:
                current.timed_out_events = int(m_to.group(1))
                current.timed_out_presents = int(m_to.group(2))
                continue

            m_comp = RE_COMPOSITOR_TIME.search(line)
            if m_comp:
                current.compositor_cpu_ms = float(m_comp.group(1))
                current.compositor_gpu_ms = float(m_comp.group(2))
                continue

            m_game = RE_GAME_INFO.search(line)
            if m_game:
                current.fps_target = int(m_game.group(1))
                current.app_cpu_ms = float(m_game.group(2))
                current.app_gpu_ms = float(m_game.group(3))
                sessions.append(current)
                current = SessionSummary()
                in_summary_block = False

    if in_summary_block and current.total_presents > 0:
        sessions.append(current)

    effective_hz = (
        float(sessions[-1].fps_target)
        if sessions and sessions[-1].fps_target
        else target_hz
    )
    budget_ms = round(1000.0 / effective_hz, 3)

    assessment = _assess_bottleneck(
        sessions[-1] if sessions else None,
        budget_ms,
        acquire_sync_timeouts,
    )

    return CompositorReport(
        log_path=str(log_path),
        date_filter=date_filter,
        target_hz=effective_hz,
        frame_budget_ms=budget_ms,
        lines_scanned=lines_scanned,
        acquire_sync_timeouts=acquire_sync_timeouts,
        release_sync_failures=release_sync_failures,
        wait_for_acquire_timeouts=wait_for_acquire_timeouts,
        sessions=sessions,
        latest_session=sessions[-1] if sessions else None,
        bottleneck_assessment=assessment,
    )


def _assess_bottleneck(
    latest: SessionSummary | None,
    budget_ms: float,
    acquire_sync_timeouts: int,
) -> str:
    if latest is None:
        return "Keine abgeschlossene Session-Statistik im gefilterten Logzeitraum gefunden."

    parts: list[str] = []
    if latest.app_cpu_ms is not None and latest.app_gpu_ms is not None:
        if latest.app_cpu_ms > budget_ms and latest.app_cpu_ms >= latest.app_gpu_ms:
            diff = latest.app_cpu_ms - budget_ms
            parts.append(
                f"CPU-bound/knapp über Budget: App-CPU {latest.app_cpu_ms:.3f} ms "
                f"(+{diff:.3f} ms über {budget_ms:.2f} ms Budget), App-GPU {latest.app_gpu_ms:.3f} ms."
            )
        elif latest.app_gpu_ms > budget_ms:
            diff = latest.app_gpu_ms - budget_ms
            parts.append(
                f"GPU-bound: App-GPU {latest.app_gpu_ms:.3f} ms "
                f"(+{diff:.3f} ms über {budget_ms:.2f} ms Budget), App-CPU {latest.app_cpu_ms:.3f} ms."
            )
        else:
            parts.append(
                f"Im Framebudget ({budget_ms:.2f} ms): CPU {latest.app_cpu_ms:.3f} ms, GPU {latest.app_gpu_ms:.3f} ms."
            )

    if acquire_sync_timeouts > 0:
        parts.append(
            f"Sync-Druck erkannt ({acquire_sync_timeouts}x AcquireSync WAIT_TIMEOUT): "
            "Compositor wartet periodisch auf DX11-Texturfreigabe (typisch bei KI-/Traffic-Spitzen oder Hintergrundlast)."
        )
    return " ".join(parts)


def _print_report(report: CompositorReport) -> None:
    print(f"SteamVR Compositor-Analyse: {report.log_path}")
    print(f"  Datumsfilter : {report.date_filter or '(alle Zeilen)'}")
    print(f"  Gescannt     : {report.lines_scanned:,} Zeilen")
    print(f"  Target-Budget: {report.frame_budget_ms:.3f} ms ({report.target_hz:.0f} Hz)")
    print(
        f"  Sync-Fehler  : AcquireSync TIMEOUT={report.acquire_sync_timeouts:,} | "
        f"ReleaseSync 0x887a0001={report.release_sync_failures:,} | "
        f"WaitForAcquire TIMEOUT={report.wait_for_acquire_timeouts:,}"
    )

    print(f"\nGefundene Sessions ({len(report.sessions)}):")
    for idx, sess in enumerate(report.sessions, start=1):
        print(
            f"  [{idx}] {sess.timestamp or 'unbekannt'}: "
            f"Presents={sess.total_presents:,}, Dropped={sess.dropped_frames}, "
            f"Reprojected={sess.reprojected_frames}, TimedOutPresents={sess.timed_out_presents}"
        )
        if sess.app_cpu_ms is not None and sess.app_gpu_ms is not None:
            print(
                f"      App CPU={sess.app_cpu_ms:.3f} ms | App GPU={sess.app_gpu_ms:.3f} ms | "
                f"Comp CPU={sess.compositor_cpu_ms or 0:.3f} ms | Comp GPU={sess.compositor_gpu_ms or 0:.3f} ms"
            )

    print(f"\nDiagnose: {report.bottleneck_assessment}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Wertet SteamVR vrcompositor.txt auf Frametimes, Drops und Sync-Timeouts aus."
    )
    parser.add_argument(
        "--log",
        type=Path,
        default=DEFAULT_LOG_PATH,
        help=f"Pfad zu vrcompositor.txt (Standard: {DEFAULT_LOG_PATH})",
    )
    parser.add_argument(
        "--date",
        type=str,
        default=None,
        help='Optionaler Datumsfilter als Teilstring, z. B. "Nov 28 2026"',
    )
    parser.add_argument(
        "--target-hz",
        type=float,
        default=90.0,
        help="Fallback-Bildwiederholrate falls nicht im Log angegeben (Standard: 90.0)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Bericht als JSON auf stdout ausgeben",
    )
    args = parser.parse_args(argv)

    try:
        report = analyze_vr_log(args.log, args.date, args.target_hz)
    except (FileNotFoundError, OSError) as exc:
        if args.json:
            print(json.dumps({"ok": False, "error": str(exc)}, indent=2))
        else:
            print(f"FEHLER: {exc}", file=sys.stderr)
        return 1

    if args.json:
        print(json.dumps(asdict(report), indent=2, ensure_ascii=False))
    else:
        _print_report(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
