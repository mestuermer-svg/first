# Testfahrt-Auswertung: `testdrive_20261123_070115`

> **SimRacer-Pfad:** `\\192.168.178.68\ac-sandbox\shared\telemetry\testdrive_20261123_070115`  
> **Cyborg-Observer-Pfad:** `C:\Users\strik\git-labor\Systemtests\Testdrive_testdrive_20261123_070115`  
> **Samples:** SimRacer `1135` Ticks | Events `112` | Cyborg `411` Ticks

<details>
<summary><b>1. Identifizierte Engpässe &amp; Optimierungshinweise (Vorher/Nachher 07:28-Fix)</b></summary>

- **Effekt des VR-Fixes (ab 07:28:25 Uhr):** Während zuvor unter alter CSP `v0.2.11` 7 `acs.exe`-Abstürze (`0xc0000374` in `ntdll.dll`, 07:07–07:16) sowie ein ausgefallenes linkes Auge durch Single-Pass-Stereo + FSR + Extra FX + `BACKGROUND_PAUSE=1` auftraten, lief die Testrunde **`PID 108064` (07:31:03–07:34:46, 222,9 s, `rss_formula_hybrid_x_2026` @ `lasvegas23`)** komplett ohne Absturz: SteamVR `vrcompositor` zählte **15.169 Presents, `0` dropped frames, `0` reprojected frames** bei 90 Hz Ziel (App CPU `7,93 ms`, App GPU `9,68 ms`, Compositor CPU `0,58 ms` / GPU `0,08 ms`).
- **Startverzögerungen vor der stabilen Runde (`07:29:38`–`07:30:18`):** 7 kurze `acs.exe`-Prozesse (2–8,5 s, ~241 MB RAM, ohne EventLog-Crash `ID=1000`) bis zum stabilen Start von `PID 108064`; zuvor (`07:03`–`07:05`) 3 Kurzstarts von `vrserver` vor `VR_COMPOSITOR_READY`.
- **Warum „Display“ &amp; Schärfe noch Luft nach oben haben (`Driver FPS: 45` &amp; weiches Bild):**
  - VIVE Hub (`RRServer` `ConnectType: DP`, 0 ms Netzwerklatenz) zeigte während der Fahrt wiederholt `Reason: Low Driver Render FPS` (`Driver FPS: 45`, `CpuRenderTime: 8,6–10,3 ms`, `GpuRenderTime: 9,0–10,1 ms`) plus Windows **`HAGS: On`** und ~70 `AcquireSync WAIT_TIMEOUT` / `0x887a0001`-Meldungen im Compositor.
  - Durch das Deaktivieren von `FSR` + `FFXCAS_PASS=0` und `ANISOTROPIC=2` in `video.ini` fehlte Schärfe-/Filterqualität bei gleichzeitig noch **großer GPU-Reserve** (RTX 5070 Ti im Post-Fix-Fenster: `gpu_util` Ø `56,9 %` / Max `97 %`, VRAM Max `13.325 / 16.303 MB`, Temp Max `73,98 °C`, Power Max `284,4 W`).
  - **Konkrete Grafik-Tuning-Hebel:** (1) `ANISOTROPIC=8` oder `16` in `video.ini`, (2) reines **CAS-Sharpening** testen (`FFXCAS_PASS=1` *ohne* `FSR/ACTIVE=1` in `graphics_adjustments.ini`), (3) Windows **HAGS (`Hardware-Accelerated GPU Scheduling`)** testweise deaktivieren, da `HAGS: On` häufig `AcquireSync WAIT_TIMEOUT` + halbe Driver-FPS unter SteamVR/DP auslöst, (4) VIVE Hub `Quality` / Render-Scale prüfen.
- **Massiver CPU-Verbrauch durch Defender (`MsMpEng`):** **`526,64` CPU-Sekunden** und max. **`462,5 MB` RAM** über die Session (`Get-MpPreference` zeigt aktuell nur 1 `ExclusionPath`). Ordner-Ausnahmen für Steam/Assetto Corsa (`assettocorsa`), `Documents\Assetto Corsa` und `VIVE Hub` senken Startzeiten und Mikroruckler deutlich.
- **Warum StrikerPi `0` `LIVE_RACE`-Ticks meldete (`Local\acpmf_static`):** Obwohl `ac_telemetry_sender.py` durchgehend mit Ø `48,45 Hz` (`101.144` Pakete) sendete und StrikerPi stabil antwortete, loggte CSP `Failed to map shared memory file: Local\acpmf_static`. Ursache: Der dauerhaft laufende Background-Reader `ac_telemetry_sender.py` (`PID 13528`) hielt bzw. öffnete Shared-Memory-Handles (`acpmf_static`), bevor/während AC sie anlegte; damit blieben `rpm`/`speed` bei 0 und StrikerPi blieb im Modus `PITBOX_SETUP`.
- **StrikerPi LAN-Verbindung (`end0` = `192.168.178.125`):** Live-Check zeigt das LAN-Interface `end0` verbunden (`192.168.178.125`, `metric 1024`) parallel zu `wlan0` (`192.168.178.86`, `metric 1024`); `ac_telemetry_sender.py`, Archibald und Router zeigen aktuell noch auf `.86`.
- **Replay-Ablage für `@light` → `@dark`:** AC legte das neue Testfahrt-Replay (`5,43 MB`, `14.041` Frames) im Unterordner `C:\Users\Mike\Documents\Assetto Corsa\replay\temp\AC_231126-073444_O_rss_formula_hybrid_x_2026_lasvegas23_.acreplay` ab (`manage-simracer-session.ps1` sollte künftig neben `replay\` optional auch `replay\temp\` einbeziehen).

</details>

<details>
<summary><b>2. Startprozedur &amp; Phasen-Stoppuhr (ab Recorder-Start / Steam)</b></summary>

| Zeit (s) | Ab Steam (s) | Phase | Details |
| ---: | ---: | :--- | :--- |
| 0 | — | `BASELINE` | SimRacer TestDrive-Recorder gestartet (PID 73580). Warte auf Steam/VR/CM/AC... |
| 153.33 | — | `VR_INIT` | VR-Initialisierung gestartet (vrserver, PID 75236) |
| 311.61 | — | `VR_COMPOSITOR_READY` | SteamVR Compositor aktiv (PID 92484) |
| 342.05 | — | `CM_STARTED` | Content Manager gestartet (PID 96404) |
| 375.81 | — | `AC_RUNNING` | Assetto Corsa Engine gestartet (acs, PID 96500) |
| 384.98 | — | `AC_EXITED` | Assetto Corsa Session beendet |

</details>

<details>
<summary><b>3. CPU / RAM / GPU / VRAM je Phase (SimRacer RTX 5070 Ti)</b></summary>

| Phase | Ticks | CPU Avg/Max % | RAM Max MB (%) | GPU Avg/Max % | VRAM Max MB | Temp Max °C | Power Max W |
| :--- | ---: | :--- | :--- | :--- | ---: | ---: | ---: |
| `BASELINE` | 110 | 25.49 / 47.1 | 16047.8 (49.0 %) | 1.43 / 16.0 | 5225.0 | 50.02 | 55.84 |
| `VR_INIT` | 111 | 24.48 / 46.5 | 16170.1 (49.0 %) | 0.02 / 1.0 | 5129.0 | 53.02 | 42.83 |
| `VR_COMPOSITOR_READY` | 55 | 43.08 / 97.6 | 17552.1 (53.0 %) | 24.36 / 39.0 | 8098.0 | 58.87 | 122.52 |
| `AC_RUNNING` | 8 | 56.92 / 68.3 | 17493.4 (53.0 %) | 24.88 / 27.0 | 8097.0 | 52.93 | 107.61 |
| `AC_EXITED` | 851 | 45.47 / 100.0 | 22409.9 (68.0 %) | 28.06 / 97.0 | 13346.0 | 73.98 | 284.43 |

</details>

<details>
<summary><b>4. Prozess-Starts &amp; Hintergrund-Verbraucher</b></summary>

- Gestartete Key-Prozesse: `59` | Beendete Key-Prozesse: `46`

| Prozess | Samples | Kumulierte CPU (s) | Max RAM (MB) |
| :--- | ---: | ---: | ---: |
| `acs` | 432 | 1018.8 | 2107.2 |
| `MsMpEng` | 1135 | 526.64 | 462.5 |
| `Content Manager` | 800 | 247.37 | 885.8 |
| `vrwebhelper` | 8222 | 215.97 | 187.7 |
| `vrcompositor` | 914 | 204.56 | 131.3 |
| `vrserver` | 919 | 132.4 | 186.7 |
| `vrmonitor` | 915 | 125.81 | 152.9 |
| `vrdashboard` | 911 | 99.99 | 78.0 |
| `pythonw` | 2270 | 51.16 | 9.8 |
| `steam` | 1135 | 44.95 | 548.2 |
| `steamwebhelper` | 8338 | 39.07 | 518.6 |
| `ViveTrackerServer` | 1135 | 19.68 | 32.6 |
| `ViveHubServer` | 1135 | 8.99 | 45.8 |
| `ViveAgentService` | 3405 | 0.53 | 4.8 |
| `steamservice` | 1135 | 0.4 | 17.8 |
| `platform_runtime_VR4U2P2_service` | 1135 | 0.19 | 3.0 |
| `vmmemCmZygote` | 1135 | 0.0 | 0.0 |

</details>

<details>
<summary><b>5. Multi-Node-Netzwerk (Ping RTT) &amp; StrikerPi-Telemetrie</b></summary>

| Ziel | Samples | Avg ms | P95 ms | Max ms |
| :--- | ---: | ---: | ---: | ---: |
| `simracer` (192.168.178.68) | 410 | 3.04 | 5.55 | 166.0 |
| `strikerpi` (192.168.178.86) | 410 | 4.05 | 7.0 | 168.0 |
| `archibald` (192.168.178.98) | 409 | 4.88 | 7.0 | 166.0 |

- **Telemetrie im `LIVE_RACE`:** Ticks=`0`, Hz Avg=`None`, Min=`None`, Max=`None`, 0-Hz-Aussetzer=`0`
- **Ausgangs-`race.ini`:** `{"MODEL": "ks_ferrari_488_gt3", "SKIN": "00_gsi_rss_26", "TRACK": "vhe_interlagos", "CONFIG_TRACK": "", "CARS": "1"}`

</details>
