> **Thema:** System-Letztstand 27.11.2026 – Vorfallsanalyse Dark-Sandbox, Host-vs.-Sandbox-Trennung, Light/Rig-Abstimmungsprotokoll, Pitwall SQLite/Tool-Swap/Touch-Terminals/Sandbox-Schutz, Auto-Dual-GPU-Routing &amp; Nachmittags-Härtung (14:30–14:49 CET)
> **Autor:** Michael Stürmer
> **Datum:** 27.11.2026

# 5.11 System-Letztstand (27.11.2026): Host-vs.-Sandbox-Trennung, Light/Rig-Koordination, Pitwall Touch/SQLite, Auto-Dual-GPU-Routing &amp; Stabilitäts-Härtung

Dieses Protokoll dokumentiert alle am **27.11.2026** durchgeführten Analysen, Fehlerbehebungen und Architektur-Erweiterungen über **VanstrikeCyborg**, **SimRacer**, **ac-win11-sandbox** und **StrikerPi**:
- Historische Analyse des Fehlversuchs in der Dark-Sandbox (`00:38–00:45 CET`) inkl. Behebung von SMB-Cache, `ProcessPrompt`, `CONFIG_TRACK`, AC-Log-Auswertung, Timeout (`150 s` / HTTP-Zeitsync) und Sandbox-Zeitsynchronisation.
- Klare Abgrenzung **SimRacer-Host (`@light` + `@rig`)** vs. **Docker-Sandbox (`@dark`)** in Skripten und `light.agent.md`.
- Wechselseitiges **Host-Koordinationsprotokoll** (`host_coordination_state.json` &amp; `host_coordination_protocol.jsonl`).
- **Pitwall Log-Ansicht**, **`db swap` / `/api/leitstand/tools/swap`**, **`systemd`-Timer** (`leitstand-db-sync.timer` &amp; `leitstand-db-backup.timer`), **Multi-Terminal-Grid mit Touch-Vollbild** und **sichere Sandbox-/Docker-Steuerung** mit Bestätigungsabfrage.
- **Automatisches Dual-GPU-Routing** (`RTX 5070 Ti` &harr; `RTX 5060`) mit `gpu_routing_plan.json` sowie Reaktivierung von `Ollama-Server-Cyborg`.
- **Nachmittags-Härtung (`14:30–14:49 CET`):** General-Sim-/StrikerPi-Timeouts, direkter `:2222`-SSH-Pfad und saubere WebSocket-Trennung, `max_output_tokens`, `@light`-Runtime-Executors (`manage_sim_session`, `delegate_to_dark`, `delegate_to_rig`) &amp; Token-Budgets sowie `@dark`-HTTP-`GET`-Zeitsync, Fullscreen-/Grafik-INI-Editor, Replay-First-Start und `-SkipIfPresent`-Asset-Sync.

<details>
<summary><b>Lernziele</b></summary>

Nach dem Durcharbeiten dieses Protokolls kannst du:
1. die technischen Ursachen des Dark-Sandbox-Vorfalls vom `27.11.2026` (`worker.ps1`-SMB-Cache, fehlender kombinierter CM-/Replay-Pfad, `CONFIG_TRACK`-Altlast, blinder `acs.exe`-Start, Timeout-Kette, Container-Uhrzeit) benennen und die umgesetzten Fixes nachvollziehen,
2. die verbindliche Trennung zwischen **SimRacer-Host** (`@light` + `@rig` als Standard) und **Docker-Sandbox** (`@dark` nur bei expliziter Angabe) anwenden,
3. das wechselseitige Abschluss- und Bestätigungsprotokoll (`Update-HostCoordinationProtocol`) zwischen `@light` und `@rig` erklären,
4. die neuen Pitwall-Funktionen (`#sqliteDbBar`, `/api/leitstand/tools/swap`, `db swap`, Multi-Terminal-Grid + Touch-Vollbild sowie die getrennte Container-/Docker-Abschaltung mit Sicherheitsabfrage) bedienen,
5. die automatische Dual-GPU-Aufteilung in `ollama_router.py` (`simracer` vs. `cyborg` + gegenseitiger Fallback + `gpu_routing_plan.json`) sowie die `systemd`-Timer auf StrikerPi einordnen,
6. die Maßnahmen der Nachmittags-Härtung (Token-Limits, Runtime-Tool-Executors, direkter `:2222`-SSH-/WebSocket-Pfad, HTTP-`GET`-Zeitsync, Replay-First-Start mit Fullscreen-Profil sowie nahtloser Gemini/Ollama-Mischbetrieb unter Change-Freeze) erklären und verifizieren.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary><b>1. Vorfallsanalyse Dark-Sandbox (27.11.2026, 00:38–00:45 CET) &amp; Behebungen</b></summary>

- **Prüfung der Ausgangslage:** Alle Pitwall-Freigaben (`Pause=AUS`, `Modus=DELEGATED`, `Mandat=+60min`, alle 5 `LIGHT_AUTO`-Kategorien, `GPU_Background=ERLAUBT`) waren zum Vorfallszeitpunkt aktiv (`Pause=AN` folgte erst um `00:50:04 CET`). Das Qwen-Modul war nicht überlastet, da sowohl `@light` (Regex-Routing) als auch `@dark` (`LaunchSession`/`SyncCoreAssets`) rein über PowerShell-Logik liefen.
- **Behobene Ursachen:**
  1. **SMB-Cache in [`worker.ps1`](file://192.168.178.68/ac-sandbox/shared/agents/dark/worker.ps1):** `Test-DarkWorkerPaused` fragt nun primär `http://192.168.178.86:8080/api/approvals/state` ab (SMB-Datei nur noch als Fallback).
  2. **Kombinierte CM-/Install-/Replay-Prompts:** Sowohl [`runner.ps1`](file://192.168.178.68/ac-sandbox/shared/agents/dark/runner.ps1) als auch [`start_dark_terminal.ps1`](file://192.168.178.68/ac-sandbox/shared/agents/dark/start_dark_terminal.ps1) brechen bei `CM`/`Content Manager` nicht mehr vorzeitig ab, sondern führen bei Bedarf `SyncCoreAssets` &rarr; `LaunchCM` &rarr; `LaunchSession` (z. B. `replay`) nacheinander aus.
  3. **`CONFIG_TRACK`-Bereinigung (`SetSession`):** `runner.ps1` setzt `CONFIG_TRACK=$cfgVal` nun immer bei Streckenwechsel, auch wenn `config` leer ist (verhindert Altlasten wie `silverstone_f1_2022` auf `acu_cota_2021`).
  4. **AC-Fehlerlog-Auswertung:** Bei `acs.exe`-Startfehler liest `runner.ps1` automatisch die letzten Fehlerzeilen aus `Documents\Assetto Corsa\logs\log.txt`.
  5. **Handshake-Timeout &amp; Container-Zeitsync:** `@light` wartete zunächst `45 s` statt `25 s` und in der Nachmittags-Härtung schließlich `150 s` auf `@dark` (`90 s` auf `@rig`); `Sync-SandboxClockWithHost` setzt die Zeitzone explizit auf `W. Europe Standard Time` und synchronisiert die Systemzeit ohne das fehleranfällige `net time \\host.lan /set /y` direkt per StrikerPi HTTP `GET /health` (`Date`-Header) inkl. Scheduled-Task-Fallback.

</details>

<details>
<summary><b>2. Host-vs.-Sandbox-Trennung &amp; Light/Rig-Abstimmungsprotokoll</b></summary>

- **Host-Default in [`start_light_terminal.ps1`](file://192.168.178.68/ac-sandbox/shared/agents/light/start_light_terminal.ps1) &amp; `light.agent.md`:**
  - Der **SimRacer (`192.168.178.68`)** ist das native Host-System und keine Sandbox.
  - `cm`, `content manager`, `rennstart`, `vienna` und `winterzeit` wurden aus den automatischen `@dark`-Triggern entfernt. Aufgaben ohne expliziten Sandbox-Bezug (`in der sandbox`, `im container`, `im gast`, `@dark`) bleiben auf dem Host bei `@light` + `@rig`.
  - Beide Agent-Definitionen ([`git-labor/.github/agents/light.agent.md`](file:///c:/Users/strik/git-labor/.github/agents/light.agent.md) &amp; [`assetto-corsa-content/.github/agents/light.agent.md`](file:///c:/Users/strik/assetto-corsa-content/.github/agents/light.agent.md)) wurden nach Freigabe entsprechend ergänzt.
- **Wechselseitiges Abstimmungsprotokoll (`Update-HostCoordinationProtocol`):**
  - Implementiert in [`start_light_terminal.ps1`](file://192.168.178.68/ac-sandbox/shared/agents/light/start_light_terminal.ps1) und [`start_rig_terminal.ps1`](file://192.168.178.68/ac-sandbox/shared/agents/rig/start_rig_terminal.ps1).
  - Schreibt bei jedem Task-Abschluss in `shared\agents\host_coordination_state.json` und `shared\agents\general-SIM\logs\host_coordination_protocol.jsonl` inkl. gegenseitiger Abschlussbestätigung (`ack_by_light` / `ack_by_rig`).

</details>

<details>
<summary><b>3. Pitwall-Erweiterungen: SQLite-Log-Ansicht, Tool-Tausch, Touch-Terminals &amp; Sandbox-Schutz</b></summary>

Alle Erweiterungen wurden in [`telemetry_relay.py`](file:///c:/Users/strik/strikerpi-hub/telemetry-relay/telemetry_relay.py) umgesetzt und live auf `StrikerPi` (`192.168.178.86:8080`) deployed:
- **SQLite- &amp; Koordinationsleiste (`#sqliteDbBar`) im Log-Tab:** Zeigt Live-Zahlen aus `/opt/general-sim/data/leitstand.db`, Light/Rig-Sync-Stand (`/api/leitstand/coordination`), **`⚡ DB Sync`** (`POST /api/leitstand/db/sync`), **`🔍 FTS5`**-Suche (`GET /api/leitstand/db/search`) und **`🛠️ Tool-Tausch`** (`POST /api/leitstand/tools/swap` mit Budget-Prüfung + sofortigem `db sync`).
- **`General Sim` CLI ([`general_sim_terminal.py`](file:///c:/Users/strik/strikerpi-hub/general-sim/general_sim_terminal.py)):** Ergänzt um `db swap <agent> <activate_tool> [deactivate_tool]`.
- **`systemd`-Timer auf StrikerPi:** `leitstand-db-sync.timer` (alle `60 s`) und `leitstand-db-backup.timer` (täglich) aktiviert.
- **Touch-Terminals (`page-terminals`):** Neue Ansicht **`🧩 Alle Terminals`** (Multi-Agent-Grid) sowie pro Agent ein touch-optimierter **`⛶ Vollbild`**- / **`✕ Vollbild beenden`**-Modus (`min-height: 42–44px`, `ESC`-Unterstützung), der im Vollbild ausschließlich den gewählten Agenten anzeigt.
- **Sichere Sandbox-/Docker-Steuerung:** Status-Pill neben `⚙️` löst keine Abschaltung mehr aus; im Tab `🧪 Sandbox` sind **`⏹ Container stoppen`** (`/api/sandbox/stop_container`) und **`🛑 Docker komplett beenden`** (`/api/sandbox/stop`) sauber getrennt und jeweils mit Sicherheitsabfrage (`confirmSandboxLifecycle`) abgesichert.

</details>

<details>
<summary><b>4. Automatisches Dual-GPU-Routing &amp; Cyborg RTX 5060</b></summary>

- **`Ollama-Server-Cyborg`:** Nach Beendigung am Vortag neu gestartet; Pitwall `/api/ollama/gpus?refresh=1` meldete `cyborg` wieder `online: True` (`qwen3.5:4b` &amp; `gemma4:e4b`, je `32768`).
- **Automatische Lastverteilung in [`ollama_router.py`](file://192.168.178.68/ac-sandbox/shared/scripts/ollama_router.py):**
  - **SimRacer RTX 5070 Ti (`16 GB`):** Standardziel für `@rig`, `@light`, `@general-sim`.
  - **VanstrikeCyborg RTX 5060 (`8 GB`):** Standardziel für `@sarah`, `@dark`, `@cyborg`, `@rick`.
  - Fällt eine GPU aus (Standby, `LIVE_RACE` oder Policy-Sperre), schwenkt `select_ollama_target()` automatisch auf die jeweils andere GPU um; `build_auto_gpu_dispatch_plan()` schreibt den aktuellen Verteilungsplan nach `shared\agents\gpu_routing_plan.json`.

</details>

<details>
<summary><b>5. Nachmittags-Härtung (14:30–14:49 CET): Timeouts, Token-Limits, Tool-Executors &amp; Dark-Sandbox-Fixes</b></summary>

In einer anschließenden Autonom-Prüfung aller Logs (`general_sim`, `@light`, `@dark`, StrikerPi `journalctl`) wurden verbleibende Timeout-, Token-, Pfad-, Grafik-, Uhrzeit- und Replay-Probleme behoben und live auf **StrikerPi**, **SimRacer** und **ac-win11-sandbox** verifiziert:

- **General Sim &amp; StrikerPi ([`general_sim_terminal.py`](file:///c:/Users/strik/strikerpi-hub/general-sim/general_sim_terminal.py), [`telemetry_relay.py`](file:///c:/Users/strik/strikerpi-hub/telemetry-relay/telemetry_relay.py), [`start_general_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/general-SIM/start_general_terminal.ps1)):**
  - `request_json` nutzt `timeout: float = 45.0` statt fest `15 s`; `Wait-GeneralHandshake` wartet `45000 ms` (`30000 ms` beim Content-Sync an `@light`); `start_general_terminal.ps1` lässt Umlaute/Unicode-Zeichen zu (`-not [char]::IsControl(...)`).
  - `/api/voice/dispatch` prüft `8 × 350 ms` bei `timeout=25.0` (zuvor `12 × 450 ms` in `12.0 s`).
  - `_resolve_terminal_cmd("dark")` baut keinen hängenden Double-Hop (`Mike@SimRacer -> 127.0.0.1:2222`) mehr auf, sondern verbindet direkt von StrikerPi per `-p 2222 Docker@192.168.178.68`. Drei verwaiste `ssh.exe`-Prozesse (`PID 178032`, `102568`, `116176`) auf dem SimRacer wurden bereinigt.
  - `websocket_terminal` (`_pump_in`/`_pump_out`) fängt `WebSocketDisconnect`, `CancelledError`, `OSError` und `RuntimeError` sauber ab und räumt Task-Exceptions per `asyncio.gather(..., return_exceptions=True)` ab -> live bestätigt auf `/ws/terminal/general-sim` (`HTTP 101`, `rx_bytes=73`) und `/ws/terminal/dark` (`HTTP 101`, `rx_bytes=72`) bei `ZERO_JOURNAL_ERRORS` in `journalctl`.
  - `GeminiProxyRequest` und `api_llm_gemini_proxy` setzen `max_output_tokens` (Default `1024`, Bereich `64–8192`) inkl. `400`-Retry-Bereinigung -> live bestätigt mit `HTTP 200` (`max_output_tokens: 256`, `2.61 s`). `/opt/general-sim/leitstand_db.py sync` lief mit `status: ok` (`tools_synced: 29`, `logs_synced: 107`, `gaps_synced: 5`, `warnings: []`).
- **`@light`, Tool-Runtime &amp; Router ([`ollama_router.py`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/scripts/ollama_router.py), [`agent_ollama_tool_runtime.py`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/scripts/agent_ollama_tool_runtime.py), [`start_light_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/light/start_light_terminal.ps1)):**
  - `call_gemini_interaction` übergibt `max_output_tokens: int = 1024` einheitlich über SDK, REST und StrikerPi-Bridge.
  - `agent_ollama_tool_runtime.py` begrenzt `active_num_ctx` auf `8192` (`cyborg`) bzw. `16384` (`simracer`), setzt `num_predict=512`, kürzt `load_priming_excerpt` auf `800`/`1400` Zeichen, ergänzt durchgängig `token_usage` sowie einen `auto`-Fallback von Gemini auf Ollama und implementiert reale Subprocess-/Inbox-Executors für `manage_sim_session` (inkl. Read-Only-`Get` und in-memory Schema-Relaxation `required: []`), `delegate_to_dark` (mit `LIVE_RACE`-Schutz) und `delegate_to_rig`. Live getestet auf SimRacer: `manage_docker_sandbox` (`gemini-3.8-flash`: `1774` Tokens; `qwen3.5:9b`: `2080` Tokens, `Exit=0`) sowie `manage_sim_session` (`gp_2025_rb21 @ ks_silverstone`, `1831` Tokens, `Exit=0`).
  - `start_light_terminal.ps1` (neu gestartet als `PID 192116`): `agent_states` in `Get-PitwallControlPolicy` ergänzt; `PYTHONUTF8=1` und `-AllowMutating:$hasGeneralGo` in `Invoke-LightOllamaToolRuntime` gesetzt; `Invoke-ApprovedLightDispatch`-Regexes verankert; Sandbox-/Dark-Prompts vor der `@rig`-Grafik-/Preset-Weiche geschützt; `$testDarkReady` akzeptiert offenen `:2222`-Port + laufenden Container ohne unnötigen `150 s`-Boot-Wait; `@dark`-Delegation übergibt `handoff_context` bei `150 s` Timeout (`90 s` bei `@rig`); Umlaute im Terminal freigegeben.
- **`@dark` &amp; Windows-11-Sandbox ([`worker.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/worker.ps1), [`start_dark_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/start_dark_terminal.ps1), [`runner.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/runner.ps1)):**
  - `Sync-SandboxClockWithHost` entfernt das 1h-versetzte `net time \\host.lan` (und einen `405` bei HTTP `HEAD`) und synchronisiert per `GET http://192.168.178.86:8080/health` (`Date`-Header) nach `W. Europe Standard Time` -> live bestätigt (`Abweichung 0.8s`).
  - Tote `http://host.lan:11434`-Probes und `D:\ac-sandbox\shared\content` (`-> C:\ac-sandbox\shared\content`) entfernt; Cyborg (`192.168.178.172`/`.145`) steht vor SimRacer (`.68`) -> live bestätigt (`ollama_offline_ready: True`, `qwen3.5:4b` &amp; `gemma4:e4b`).
  - `Get-DarkPitwallState` liest primär die StrikerPi-API; Grafik-/Fullscreen-Prompts landen im `ProcessPrompt`-Pfad statt `LaunchCM`; ein mutierbarer `Set-IniSectionKey`-Editor + `Optimize-SandboxVideoAndCsp` (`1024x768 Fullscreen=1`, `AA/Shadows/FXAA/PP/Cubemap/Mirror/WorldDetail/ExtraFX/ScriptableFilter=0`) sowie `Bring-ProcessWindowToForeground` greifen in `video.ini`, `assetto_corsa.ini` und `extension\*.ini`; `LaunchSession` beendet vorherige `acs.exe`, löst Car/Track per `Resolve-ReplayCarAndTrack` vor `[RACE]`/`[REPLAY]` (`ACTIVE`, `FILENAME`, `NAME`) auf -> live bestätigt mit Silverstone-RB21-Replay (`acs.exe PID 10980`, `Content Manager PID 6532`).
  - `SyncCoreAssets` überspringt mit `-SkipIfPresent` (außer bei `-Target force`) bereits vorhandene Core-/Content-Ordner und verkürzt einen Wiederholungs-Sync auf **`6.34 s`** (`27` Autos, `11` Strecken, `0` Fehler); Gast-Worker neu gestartet (`PID 3340`).
- **Mischbetrieb &amp; Change-Freeze:** Gemischte Backend-Zuweisungen (`@light`/`@sarah` auf Gemini, `@general`/`@dark`/`@rig`/`@rick` auf Ollama) arbeiten über einheitliche JSON-Inbox/Outbox-Protokolle und `ollama_router.py` reibungslos zusammen. Alle Change-Freeze-Dateien (`approval_policy.json`, `pitwall_control_policy.json`, `wheel_write_release.json`, `AGENTS.md`, `*.agent.md`) blieben per SHA-256-Abgleich unverändert.

</details>

<details>
<summary><b>6. `@dark`-Priming-Upgrade (`2026.11.27-v2`), CM-Mod-Installer (`InstallModContent`) &amp; Tool-Runtime-Anbindung</b></summary>

Abschließend wurde geprüft, ob `@dark` für Content-Manager-Steuerung, Session-/Replay-Starts und Fahrzeug-/Strecken-Installation über Content Manager sauber geprimt und technisch verdrahtet ist:

- **Priming- &amp; Toolbox-Upgrade (`2026.11.27-v2`):** [`priming_profile.md`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/memories/sandbox/priming_profile.md), [`priming_profile.json`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/memories/sandbox/priming_profile.json), [`toolbox.json`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/memories/sandbox/toolbox.json) und [`TOOLBOX.md`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/memories/sandbox/TOOLBOX.md) auf den Stand `2026.11.27-v2` gehoben (oberste 800 Zeichen von `priming_profile.md` kompakt für Cyborg `4B` aufbereitet, Cyborg-RTX-5060-Präferenz, `GET /health` Clock-Sync, `1024x768 Fullscreen=1`, Few-Shot-Beispiel 4 für CM-Mod-Installation + Replay-/Practice-Start). Die Sandbox-Toolbox zählt **9 aktive Werkzeuge** (`get_sandbox_status`, `list_sandbox_and_host_content`, `validate_setups`, `launch_or_stop_cm`, `install_content_via_cm`, `manage_sandbox_session`, `apply_sandbox_preset`, `sync_core_assets`, `report_capability_gap`) und bleibt sauber im Cyborg-Budget (`&le; 12`).
- **Zweistufiger CM-/Mod-Installer in [`runner.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/runner.ps1) &amp; [`start_dark_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/start_dark_terminal.ps1):** Neue Aktionen `InstallModContent` (`Install-SandboxModContent`) und `ListContent` sowie `Ensure-SandboxCmReady` (`steam_appid.txt=244210`, CM-Preset-Ordner, Fensterfokus in `LaunchCM`). Tier 1 installiert aus `Original_AC_Content` (`:ro`), Tier 2 prüft `.zip`/`.7z`/`.rar`-Archive in `Original_AC_Downloads` &amp; `Original_AC_Downloads_Archiv` (`:ro`) auf AC-Struktur (`content/cars`, `content/tracks`, `ui_car.json`, `ui_track.json`, `data.acd`, `.kn5`), blockt Treiber-/Installer-Archive (`Fanatec_Driver`, BIOS, `.exe`) und startet/fokussiert Content Manager zur Live-Indizierung (optional `cmqueue:` für GUI-Übergabe).
- **Tool-Runtime-Executors in [`agent_ollama_tool_runtime.py`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/scripts/agent_ollama_tool_runtime.py):** Alle 8 operativen `@dark`-Werkzeuge angebunden (inkl. `--no-llm`-Heuristik und ehrlichem `Blocked`/`SANDBOX_STOPPED`, wenn `ac-win11-sandbox` auf SimRacer gestoppt ist).

</details>

<details>
<summary><b>7. Nachmittags-Log-Analyse &amp; Sofortpaket: Kommunikations-, Übergabe- &amp; QA-Härtung</b></summary>

Die Forensik der Nachmittags-Logs (`2026-11-27`) im Vergleich zum damaligen Agenten-Stand (`13:24–17:30 CET` vor dem Abend-Upgrade `2026.11.27-v2`, inkl. `pitwall_control_policy.json` und historischer Backups `*.bak_20261127_*`) zeigte sieben konkrete Übergabe- und Verifikationslücken in den Ausführungsskripten, die geschlossen wurden (alle Change-Freeze-Dateien blieben per SHA-256 unberührt):

1. **Atomarer `@dark`-Worker &amp; vollständiges QA-Outbox-Schema ([`worker.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/worker.ps1), [`start_dark_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/start_dark_terminal.ps1)):**
   - Atomarer Inbox-Claim (`Move-Item` auf `*.processing`) sowie Yielding von `start_dark_terminal.ps1` an einen aktiven `worker.ps1` verhindern Doppelverarbeitung derselben Aufgabe.
   - `Resolve-DarkToolMetadata` mappt alle 9 aktiven Sandbox-Werkzeuge (`2026.11.27-v2`) und schreibt `executed_handler`, `tool_used`, `risk_class`, `summary`, `before`, `after`, `changes`, `checked_tools`, `missing_tools` und `missing_competencies` atomar über `*.tmp` in `result_<taskId>.json`, sodass [`light_verifier.py`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/scripts/light_verifier.py) jede Rückmeldung deterministisch mit `VerifiedSuccess` prüft.
   - `handoff_context` wird Base64-kodiert (`-HandoffBase64`) übergeben, damit PowerShell 5.1 keine JSON-Anführungszeichen beim Prozessaufruf abschneidet, und `"auto"` im `target`-Feld wird nicht mehr fälschlich als Car/Track-Name weitergeleitet.
2. **Exit-Code-, Asset-Filter- &amp; Diagnose-Fixes in [`runner.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/runner.ps1):**
   - `Invoke-RunnerSubAction` ersetzt lose `& $PSCommandPath`-Aufrufe in `ProcessPrompt`, wertet PowerShell-Ausgabestreams korrekt aus und bricht nach `SyncCoreAssets` nicht mehr durch `$LASTEXITCODE -ne 0` (bei `$null`) vor dem Session-/Replay-Start ab.
   - `SyncCoreAssets` filtert reine Core-Ordnernamen (`sfx`, `fonts`, `gui`, `weather`, `driver`, `texture`) vor Schritt 2 heraus (kein fälschlicher Lookup unter `cars\`/`tracks\`) und unterstützt `-DestRootOverride` inkl. Host-Quellen-Fallback für isolierte Tests.
   - `Install-SandboxModContent` unterstützt `-ForceReinstall` (mit Schutz gegen das Löschen von `:ro`- oder Steam-Quellen), installiert bei Wildcard-Zielen (`gp_2025*`) mehrere passende Ordner und übernimmt in `ProcessPrompt` erkannte Pfade/Archive aus `-HandoffBase64`.
   - `DiagnoseAndHandoff` meldet `FULLSCREEN=1` nicht länger als Widerspruch (`ISSUE_04_DISPLAY_MODE`) zu `Optimize-SandboxVideoAndCsp` (`1024x768 Fullscreen=1`) und erzeugt nur dann einen Handshake-Auftrag für `@light`, wenn tatsächlich Core-Ordner fehlen.
3. **`@light` &amp; `@general` Orchestrierungs-Härtung ([`start_light_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/light/start_light_terminal.ps1), [`start_general_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/general-SIM/start_general_terminal.ps1)):**
   - `Build-LightDarkHandoffContext` reichert sowohl `ProcessPrompt`-Delegationen als auch direkte `@dark`-Aufträge (`Invoke-LightPrompt`) mit Host-Suchergebnissen (`cars`, `tracks`, `archives`, `replay`, `docs`) an und prüft direkte `@dark`-Ergebnisse über `Invoke-LightVerificationAndReport`; `ProvideAcCoreData` behält bei Content-Pfaden die Präfixe `cars/` bzw. `tracks/`.
   - `-SkipProtocolLog` verhindert doppelte Leitstand-Protokolleinträge vor der Auto-Verifikation in [`start_light_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/light/start_light_terminal.ps1).
   - `Initialize-CommHistory` ruft beim Start `Update-AgentCommHistory` auf, und `Invoke-GeneralLocalDiagnostic` schließt die stille `else`-Sackgasse in `@general`, indem lokale Log-, Leitstand-, Capability-Gap- und `host_coordination_state.json`-Daten ausgewertet werden.

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Pitwall Touch-Terminals testen:** Öffne `http://192.168.178.86:8080/` &rarr; `💻 Terminals` &rarr; `🧩 Alle Terminals` und prüfe den Einzelfokus über `⛶ Vollbild` / `✕ Vollbild beenden`.
2. **SQLite-Leiste &amp; Tool-Tausch prüfen:** Öffne `📜 Logs`, prüfe `#sqliteDbBar`, starte eine `FTS5`-Suche nach `qwen3.5` und teste `db swap` im `general-sim>`-Terminal.
3. **Dual-GPU-Verteilungsplan bei aktivem Verbund prüfen:** Nach `Pause=AUS` `ollama_router.py` / `build_auto_gpu_dispatch_plan` ausführen und in `gpu_routing_plan.json` prüfen, wie Host- und Sandbox-/Coaching-Agenten auf `5070 Ti` und `5060` verteilt werden.

</details>

<details>
<summary><b>Weiterführende Links &amp; Quellen</b></summary>

- **Vorgänger-Protokoll (26.11.2026):** [`SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md`](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md)
- **NotebookLM-Bericht (27.11.2026):** [`NOTEBOOKLM_AUDIO_BERICHT_2026-11-27.md`](./NOTEBOOKLM_AUDIO_BERICHT_2026-11-27.md)
- **Geänderte Agenten-Skripte:** [`worker.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/worker.ps1) · [`runner.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/runner.ps1) · [`start_dark_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/dark/start_dark_terminal.ps1) · [`start_light_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/light/start_light_terminal.ps1) · [`start_general_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/general-SIM/start_general_terminal.ps1) · [`start_rig_terminal.ps1`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/agents/rig/start_rig_terminal.ps1) · [`ollama_router.py`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/scripts/ollama_router.py) · [`agent_ollama_tool_runtime.py`](file:///c:/Users/strik/assetto-corsa-content/ac-sandbox/shared/scripts/agent_ollama_tool_runtime.py)
- **Pitwall &amp; Leitstand:** [`telemetry_relay.py`](file:///c:/Users/strik/strikerpi-hub/telemetry-relay/telemetry_relay.py) · [`general_sim_terminal.py`](file:///c:/Users/strik/strikerpi-hub/general-sim/general_sim_terminal.py) · [`light.agent.md`](file:///c:/Users/strik/git-labor/.github/agents/light.agent.md)

</details>

<details>
<summary><b>Chips &amp; Kernaussagen</b></summary>

- **Dark-Sandbox-Fixes:** `worker.ps1` &amp; `start_dark_terminal.ps1` lesen Pitwall-API primär; Zeitsync nutzt StrikerPi `GET /health` (`Date`-Header) nach `W. Europe Standard Time` (`Abweichung 0.8s`); `runner.ps1` setzt `Set-IniSectionKey` + `Optimize-SandboxVideoAndCsp` (`1024x768 Fullscreen=1`), beendet alte `acs.exe`, löst Car/Track replay-first auf (`gp_2025_rb21 @ ks_silverstone`) und synct inkrementell in `6.34 s`.
- **Host-vs.-Sandbox-Trennung:** SimRacer-Host (`@light` + `@rig`) ist Standard; `@dark` (Docker-Sandbox) nur auf explizite Anweisung (`handoff_context` inkl., `@light`-Wait `150 s`).
- **Light/Rig-Koordination &amp; Runtime:** `Update-HostCoordinationProtocol` synchronisiert `host_coordination_state.json`; `agent_ollama_tool_runtime.py` begrenzt `num_ctx` (`8192`/`16384`), setzt `num_predict=512` &amp; `max_output_tokens=1024`, führt `manage_sim_session`, `delegate_to_dark` und `delegate_to_rig` real aus und meldet `token_usage`.
- **Pitwall, StrikerPi &amp; WebSockets:** `#sqliteDbBar`, `/api/leitstand/tools/swap` + `db swap`, `systemd`-Timer, Multi-Terminal-Grid + Touch-Vollbild; `request_json` (`45 s`), `/api/voice/dispatch` (`25 s`), direktes `:2222`-SSH und saubere WebSocket-Trennung (`ZERO_JOURNAL_ERRORS`).
- **Auto-Dual-GPU, Mischbetrieb &amp; Change-Freeze:** `ollama_router.py` verteilt Host auf `5070 Ti` und Sandbox/Coaching auf `5060`; Gemini/Ollama-Mischbetrieb funktioniert über einheitliche Handshakes; alle Change-Freeze-Dateien sind per SHA-256 unverändert intakt.
- **`@dark` Priming &amp; CM-Mod-Installer (`2026.11.27-v2`):** 9 aktive Toolbox-Tools (`&le; 12` Cyborg-Budget) inkl. `install_content_via_cm` (`InstallModContent` für `:ro`-Content &amp; `.zip`/`.7z`/`.rar` mit Treiber-Filter), `list_sandbox_and_host_content`, `manage_sandbox_session` und `launch_or_stop_cm` (`steam_appid.txt=244210`), voll in `agent_ollama_tool_runtime.py` verdrahtet.
- **Sofortpaket Kommunikation &amp; QA:** Atomarer `.processing`-Claim + `Resolve-DarkToolMetadata` (alle 9 Tools + `changes`/`before`/`after`) für `light_verifier.py`, `-HandoffBase64` gegen PS-5.1-Quote-Loss, `Invoke-RunnerSubAction` statt `$LASTEXITCODE`-Bug, Core-Asset-Filter in `SyncCoreAssets`, `Build-LightDarkHandoffContext` inkl. direktem `@dark`-QA sowie `Invoke-GeneralLocalDiagnostic` in `@general`.

</details>

---
*Hinweis zur Organisation:* Die erstellte Dokumentation ist am Drehlaufwerk abgelegt und mit einer kurzen Zusammenfassung von den Chips auch in den Notebooks verlinkt.
