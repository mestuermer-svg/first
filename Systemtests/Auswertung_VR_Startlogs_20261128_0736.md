# Auswertung VR- & Assetto-Corsa-Startlogs (`2026-11-28 06:46–07:36 CET`)

- **Host:** SimRacer (`192.168.178.68`)
- **Ausgewertete Quellen:** `Documents\Assetto Corsa\logs\{log.txt, custom_shaders_patch.log, launcher.log, launcher_debug.log}`, `AcTools Content Manager\Logs\Main Log_261128_{064749,070042}.log`, SteamVR (`vrserver.txt`, `vrcompositor.txt`), VIVE Hub (`rrServer*.txt`, `ViveTrackerServer_20261128.txt`), Windows EventLog (`Application` & `System`)

---

## 1. Zeitachse der Ereignisse (`06:46–07:36 CET`)

| Uhrzeit | Komponente | Ereignis / Befund |
| :--- | :--- | :--- |
| `06:46:44–06:46:47` | SteamVR / VIVE | `vrmonitor` (`PID 23968`), `vrserver` (`28764`), `vrcompositor` (`27176`) und `ViveTrackerServer` verbunden. |
| `06:47:02–06:47:21` | `AssettoCorsa.exe` (Original-Launcher) | Lädt `337` Autos und stürzt ab: `launcher_debug.log` meldet `[FATAL:memory.cc(19)] Out of memory. size=7245824`; Windows EventLog zeigt `Application Hang` (`ID 1002`, `06:47:20`) + `Application Error` (`ID 1000`, `libcef.DLL`, Code `0x4000001f`, `06:47:21`). |
| `06:47:49–06:47:53` | Content Manager | Startet (`Main Log_261128_064749.log`); meldet `[SteamStarter:314] Wrong location, SteamStarter won't work` sowie 2× `AcError: File 'ui_car.json' is missing` / `Brand's badge is missing`. |
| `06:48:13–06:48:17` | `acs.exe` Startversuch 1 | Gestartet via CM `AppIdStarter` → nach ~4 s abgestürzt: `Application Error` (`ID 1000`, `acs.exe`, `ntdll.dll v10.0.26100.10068`, Code **`0xc0000374` Heap Corruption**, Offset `0x0000000000112fc5`, PID `0x9610`). |
| `06:48:24–06:55:26` | `acs.exe` Startversuche 2 & 3 | Weitere Starts über `AppIdStarter` (`06:55:26` bis `06:58:32`, `rss_gtm_bayer_i6_evo @ fn_nurburgring`, `Cancelled=True`). |
| `06:59:40–06:59:44` | CSP-Update / Repair | CM erkennt `Versions in data_manifest.ini and installed.log are out of sync. Reinstalling from scratch.` und installiert CSP **`v0.2.11 (3465)`** neu; CM-Neustart `07:00:42`. |
| `07:01:12–07:10:03` | `acs.exe` Session | Laufzeit ~9 Min (`rss_gtm_bayer_i6_evo @ fn_nurburgring`, `Cancelled=True`). |
| `07:11:00–07:11:04` | `acs.exe` Startversuch (nach CSP-Reinstall) | Trotz frischem CSP-Reinstall erneut Absturz nach ~4 s in `ntdll.dll` (`0xc0000374`, Offset `0x0000000000112fc5`, PID `0xCAD4`). |
| `07:11:11–07:29:23` | `acs.exe` Stabile 18-Min-Session | Läuft 18 Min stabil (`TIME TO INIT: 13040.1 ms`), endet mit `Openvr shutdown` + `CLEAN EXIT`. Replay gespeichert unter `replay\temp\AC_281126-072918_O_rss_gtm_bayer_i6_evo_fn_nurburgring_nordschleife_sprint_arena.acreplay`. |
| `07:15:13` | Windows System EventLog | **Warnung `Tcpip` (`ID 4231`):** Erschöpfung kurzlebiger TCP-Ports (*ephemeral ports exhausted*). |
| `07:21–07:29` | SteamVR `vrcompositor` | `48.410 Presents`, `0 dropped`, `0 reprojected`, aber **5.966× `AcquireSync FAILED with WAIT_TIMEOUT`** (`136` Zeilen + `5.830` suppressed), `136+` `ReleaseSync FAILED (0x887a0001)`, **71× `WaitForAcquire timed out`** (`CPU: 11,374 ms / GPU: 10,711 ms`). |
| `07:35:47–07:35:53` | SteamVR & VIVE Hub | Sauberer Shutdown: `[vrserver] Graceful exit`, `rrServer` DisplayPort & USB sauber getrennt. |

---

## 2. Identifizierte Ursachen & Nebenfehler

1. **32-Bit-Speicherlimit (`AssettoCorsa.exe`):** Bei 337 installierten Fahrzeugen sprengt `libcef.DLL` den 32-Bit-Adressraum (`Out of memory`). Abhilfe: Ausschließlich Content Manager (mit `AppIdStarter`) nutzen.
2. **Sporadischer `0xc0000374`-Heap-Crash beim `acs.exe`-Start:** Tritt ~4 s nach Prozessstart in `ntdll.dll` auf (auch nach CSP-Reinstall) und erfordert danach einen erneuten Start. Ursache liegt nicht in fehlendem CSP-Manifest allein (da um `07:11:00` direkt nach Neuinstallation wiederholt), daher müssen Start-Skripte zwingend auf lebenden Prozess > 6 s und EventLog/AC-Log prüfen.
3. **SteamVR-Compositor-Synchronisationsdruck:** Durchschnittliche Renderzeiten (`CPU 11,374 ms / GPU 10,711 ms`) liegen knapp über dem 90-Hz-Framebudget (`11,11 ms`), begleitet von `5.966× AcquireSync WAIT_TIMEOUT` / `0x887a0001`.
4. **TCP-Port-Knappheit (`Tcpip ID 4231`):** Während der Session waren kurzfristig alle dynamischen Ephemeral-TCP-Ports belegt (Hinweis auf häufige Kurz-Requests/Polling ohne Connection-Pooling).
5. **Kleinere AC-/VIVE-Meldungen:** `apps/python/Kissmyrank/Kissmyrank.py not found`, 2× fehlende `ui_car.json` / Marken-Badge in CM, 3× `FMOD_ERR_INVALID_HANDLE`, `TrackIR LoadLibrary failed` (ohne TrackIR normal) sowie VIVE-Tracker-Startfehler (`vive_null_headset\default.vrsettings not found`, `dongle connected: 0`) ohne Auswirkung auf den DisplayPort-Stream.

---

## 3. Verbindliche Handlungsregeln für `@light` & `@dark`

- **`@light`:**
  - Auf SimRacer niemals den 32-Bit-Original-Launcher `AssettoCorsa.exe` anstoßen (337 Autos → CEF-OOM); Content Manager (`AppIdStarter`) verwenden.
  - Bei jedem AC-Start auf `0xc0000374` (`ntdll.dll`) innerhalb der ersten 5–10 s achten; niemals blind `Success` melden.
  - Bei Port-/Netzwerk-Diagnosen `Tcpip ID 4231` (Ephemeral-Port-Erschöpfung) mitprüfen und bei Sandbox-Übergaben an `@dark` `.kn5`-Vollständigkeit + `ReadLogs` verifizieren.
  - Neues Host-Replay in `replay\temp\`: `AC_281126-072918_O_rss_gtm_bayer_i6_evo_fn_nurburgring_nordschleife_sprint_arena.acreplay`.
- **`@dark`:**
  - `0xc0000374` (`ntdll.dll`), `libcef.DLL` OOM, CSP `data_manifest.ini` Desync, fehlende `.kn5`/`ui_car.json` und `Kissmyrank.py` als bekannte Fehlerbilder über `ReadLogs` erkennen und bei `LaunchSession` hart via `Test-SandboxAcsPostStart` abfangen.
