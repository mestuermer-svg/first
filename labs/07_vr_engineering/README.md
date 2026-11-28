# Lab 07 – VR-Engineering, Frametime-Diagnose & Invarianten

Dieses Labor ergänzt [`Doku/07_VR_Engineering/`](../../Doku/07_VR_Engineering/README.md) um Diagnose- und Prüfwerkzeuge für das produktive VR-Setup auf **SimRacer (`192.168.178.68`)** (HTC VIVE Focus Vision per DisplayPort, `2448×2448` pro Auge @ `90 Hz`, RTX 5070 Ti, Ryzen 9 3900X).

## Enthaltene Dateien

| Datei | Zweck |
|---|---|
| [`analyze_vr_compositor.py`](./analyze_vr_compositor.py) | Liest SteamVR `vrcompositor.txt` aus, aggregiert `[N messages suppressed]`, Frametimes (`App CPU/GPU`, `Compositor CPU/GPU`) und diagnostiziert CPU-/GPU-/Sync-Engpässe |
| [`Check-VrInvariants.ps1`](./Check-VrInvariants.ps1) | Schreibgeschützte Prüfung der aktiven Assetto Corsa / CSP VR-Invarianten (`video.ini`, `vr_tweaks.ini`, `graphics_adjustments.ini`, `grass_fx.ini`) |

## Schnellstart (Read-Only gegen SimRacer-Host)

```powershell
$py = "C:\Users\strik\AppData\Roaming\uv\python\cpython-3.12-windows-x86_64-none\python.exe"

# 1. SteamVR Compositor-Log für ein bestimmtes Datum analysieren
& $py .\analyze_vr_compositor.py --date "Nov 28 2026"

# 2. JSON-Report für Agenten (@rig / @light) erzeugen
& $py .\analyze_vr_compositor.py --date "Nov 28 2026" --json

# 3. AC/CSP VR-Invarianten am Live-System prüfen (ohne Schreibzugriff)
.\Check-VrInvariants.ps1
```
