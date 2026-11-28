# Systembericht & Audio-Zusammenfassung (27.11.2026) – Multi-Agenten-Verbund, Pitwall-Updates & Dual-GPU-Steuerung

> **Zweck dieses Dokuments:** Kompakte, flache Wissensquelle für **Gemini NotebookLM (Audio Overview / Podcast-Zusammenfassung)** über alle am **27.11.2026** durchgeführten Analysen, Fehlerbehebungen und Systemerweiterungen im SimRacing- und Agenten-Verbund (`VanstrikeCyborg`, `SimRacer`, `ac-win11-sandbox`, `Archibald` und `StrikerPi`).

---

## 1. Ausgangslage & Analyse des Dark-Sandbox-Vorfalls

Bei der Überprüfung der Protokolle vom Vorabend (`27.11.2026`, `00:38 – 00:45 CET`) wurde bestätigt, dass zum Zeitpunkt des Fehlversuchs sämtliche Pitwall-Freigaben aktiv waren (`Pause=AUS`, `Modus=DELEGATED`, `Mandat` gültig, `LIGHT_AUTO` für alle Kategorien, `GPU_Background=ERLAUBT`). Das lokale Qwen-Sprachmodell war nicht überlastet, da sowohl die Triage in `@light` als auch die Ausführung in `@dark` rein über PowerShell-Logik liefen.

Die tatsächlichen technischen Ursachen lagen in vier Punkten:
1. **SMB-Cache im Container (`worker.ps1`):** Der Sandbox-Worker prüfte die Pause-Policy noch über den Windows-11/Docker-SMB-Share (`\\host.lan\Data`) statt live über die Pitwall-API. Dadurch blieb ein Auftrag (`delegated_20261127_003824.json`) liegen und lief in `@light` nach 25 Sekunden in einen Timeout.
2. **Abgebrochene CM-/Replay-Kette (`runner.ps1` & `start_dark_terminal.ps1`):** Sobald ein Prompt „Content Manager“ oder „CM“ enthielt, startete das Skript nur den Content Manager und brach ab, statt anschließend die Assets zu synchronisieren und das Replay zu starten.
3. **Inkonsistente `race.ini` & blinder `acs.exe`-Start:** Beim Streckenwechsel auf `acu_cota_2021` blieb `CONFIG_TRACK=silverstone_f1_2022` stehen. Zudem las `runner.ps1` beim Scheitern von `acs.exe` keine Assetto-Corsa-Fehlerlogs aus.
4. **Zeitversatz im Container:** Die Systemuhr der Windows-11-Sandbox hinkte der Host-Zeit um eine Stunde hinterher.

**Umgesetzte Korrekturen:**
- `worker.ps1` fragt nun primär live `http://192.168.178.86:8080/api/approvals/state` ab und synchronisiert Zeitzone (`W. Europe Standard Time`) sowie Systemzeit zuverlässig über den StrikerPi-HTTP-`GET /health` `Date`-Header (nach Abschaffung von `net time \\host.lan`).
- `runner.ps1` und `start_dark_terminal.ps1` verarbeiten kombinierte CM-, Installations-, Grafik- und Replay-Prompts durchgängig (`SyncCoreAssets` -> Grafik/CM -> `LaunchSession`), bereinigen `CONFIG_TRACK` und `[RACE]`/`[REPLAY]` passend zum gewählten Replay und protokollieren bei Startfehlern automatisch die letzten Fehlerzeilen aus `Documents\Assetto Corsa\logs\log.txt`.
- Der Handshake-Timeout von `@light` auf `@dark` wurde stufenweise auf `150 Sekunden` erhöht (`90 Sekunden` für `@rig`).

---

## 2. Klare Trennung: SimRacer-Host vs. Docker-Sandbox & Light/Rig-Koordination

Bisher wurden Aufgaben mit Schlüsselwörtern wie `cm`, `content manager` oder `rennstart` automatisch in die Docker-Sandbox (`@dark`) umgeleitet, sodass der Eindruck entstand, der gesamte SimRacer-Host sei eine Sandbox.

- **Neues Standardverhalten:** Der **SimRacer (`192.168.178.68`)** ist das native Host-System und keine Sandbox. `@light` erledigt Aufgaben standardmäßig gemeinsam mit `@rig` direkt auf dem Host. Nur wenn ein Auftrag ausdrücklich `@dark`, `Dark Agent`, `in der Sandbox`, `im Container` oder `im Gast` nennt, wird er an `@dark` in die Docker-Sandbox weitergeleitet. Diese Regel ist sowohl in `start_light_terminal.ps1` als auch in den beiden `light.agent.md`-Definitionen verankert.
- **Wechselseitiges Abschlussprotokoll (`Update-HostCoordinationProtocol`):** In `start_light_terminal.ps1` und `start_rig_terminal.ps1` schreibt jeder abgeschlossene Host-Task nun in den gemeinsamen Zustand `host_coordination_state.json` sowie ins Protokoll `host_coordination_protocol.jsonl`. Beide Agenten bestätigen sich gegenseitig abgeschlossene Aufgaben (`ack_by_light` / `ack_by_rig`).

---

## 3. SQLite-Leitstand-Datenbank, Tool-Tausch & `systemd`-Timer

Die zentrale Datenbank `/opt/general-sim/data/leitstand.db` auf dem StrikerPi indexiert alle Werkzeuge, Logs und Capability-Gaps über die Rohdaten-Master.

- **Automatisierte `systemd`-Timer auf StrikerPi:** `leitstand-db-sync.timer` synchronisiert die Datenbank nun automatisch alle 60 Sekunden; `leitstand-db-backup.timer` erstellt täglich ein Online-Backup inkl. Integritätsprüfung.
- **Dynamischer Tool-Tausch:** Über den neuen API-Endpunkt `POST /api/leitstand/tools/swap` sowie den CLI-Befehl `db swap <agent> <aktiv> [inaktiv]` in `general_sim_terminal.py` kann `General Sim` Werkzeuge zwischen `active` und `standby` tauschen, prüft dabei strikt das lokale Tool-Budget (`8–12` bzw. `10–20` Tools) und synchronisiert `leitstand.db` direkt im Anschluss.
- **Integration in die Pitwall Log-Ansicht:** Im Tab `📜 Logs` zeigt eine neue Leiste (`#sqliteDbBar`) die Live-Statistiken der SQLite-DB, den aktuellen Light/Rig-Abgleich, einen `DB Sync`-Button, eine direkte `FTS5`-Volltextsuche sowie das `Tool-Tausch`-Formular.

---

## 4. Pitwall Touch-Optimierung für das IdeaPad (Terminals & Sandbox-Schutz)

- **Multi-Terminal-Grid & Einzelfokus-Vollbild:** Unter `💻 Terminals` lassen sich per **`🧩 Alle Terminals`** alle verfügbaren Agenten-Terminals gleichzeitig auf einer Seite darstellen. Jedes Terminal besitzt einen touch-optimierten **`⛶ Vollbild`**-Button (Mindesthöhe 42–44 px), der **ausschließlich diesen einen Agenten** im Vollbild anzeigt und per **`✕ Vollbild beenden`** (oder `ESC`) sauber wieder verlässt.
- **Versehentliches Abschalten der Sandbox verhindert:** In der Pitwall-Kopfzeile direkt neben dem Einstellungs-Button (`⚙️`) befindet sich keine aktive Abschalt-Schaltfläche mehr, sondern nur noch eine reine Status-Anzeige (`🐳 Docker`), die in den Sandbox-Tab navigiert.
- **Getrennte Container- & Docker-Steuerung mit Bestätigung:** Im Tab `🧪 Sandbox` sind **`⏹ Container stoppen`** (fährt nur den Windows-11-Container herunter) und **`🛑 Docker komplett beenden`** (beendet zusätzlich Docker Desktop und WSL2) klar getrennt und durch eine explizite Sicherheitsabfrage geschützt.

---

## 5. Automatisches Dual-GPU-Routing & Cyborg RTX 5060

- **RTX 5060 reaktiviert:** Der am Vortag beendete Dienst `Ollama-Server-Cyborg` auf `VanstrikeCyborg` wurde neu gestartet; Pitwall erkennt die RTX 5060 (`192.168.178.172:11434`) wieder als `online` mit `qwen3.5:4b` und `gemma4:e4b`.
- **Dynamische Lastverteilung (`ollama_router.py`):** Statt alle Agenten starr zuerst auf die `5070 Ti` zu schicken, nutzt `select_ollama_target()` nun eine rollenbasierte Präferenz mit automatischem gegenseitigem Fallback:
  - **SimRacer RTX 5070 Ti (16 GB):** `@rig`, `@light`, `@general-sim`
  - **VanstrikeCyborg RTX 5060 (8 GB):** `@sarah`, `@dark`, `@cyborg`, `@rick`
  - Ist die `5070 Ti` durch `LIVE_RACE` oder eine Policy gesperrt, weichen alle Agenten automatisch auf die `5060` aus; ist der Laptop im Standby/offline, übernehmen alle auf der `5070 Ti`. Der aktuelle Verteilungsplan wird laufend in `shared\agents\gpu_routing_plan.json` festgehalten.

---

## 6. Nachmittags-Härtung (14:30–14:49 CET): Timeouts, Token-Limits, Tool-Executors & Dark-Sandbox-Fixes

In der anschließenden Log- und Systemhärtung am Nachmittag wurden verbleibende Timeouts, Token-Spitzen, fehlende Tool-Executors und Sandbox-Sonderfälle behoben und live bestätigt:

- **StrikerPi & General Sim (`telemetry_relay.py`, `general_sim_terminal.py`, `start_general_terminal.ps1`):**
  - `request_json` nutzt `45 s` Standard-Timeout (statt `15 s`), `Wait-GeneralHandshake` wartet `45 s` (`30 s` für Content-Sync), `/api/voice/dispatch` nutzt `8 × 350 ms` bei `25 s` SSH-Timeout.
  - Das integrierte `@dark`-Web-Terminal verbindet nicht mehr über einen hängenden SimRacer-Double-Hop (`127.0.0.1:2222`), sondern direkt von StrikerPi per SSH auf Port `2222` (`Docker@192.168.178.68`). Drei hängende `ssh.exe`-Prozesse auf SimRacer wurden beendet.
  - WebSocket-Trennungen in `/ws/terminal/{agent}` werden sauber abgefangen (`HTTP 101` und `ZERO_JOURNAL_ERRORS` im `journalctl` verifiziert).
  - `/api/llm/gemini` und `ollama_router.py` setzen `max_output_tokens=1024` (64–8192) als Ausgabebremse (`HTTP 200` in `2.61 s` verifiziert).
- **`@light` & Tool-Runtime (`agent_ollama_tool_runtime.py`, `start_light_terminal.ps1`):**
  - `agent_ollama_tool_runtime.py` begrenzt `num_ctx` auf `8192` (`cyborg`) bzw. `16384` (`simracer`), setzt `num_predict=512`, kürzt `load_priming_excerpt`, ergänzt `token_usage` sowie `auto`-Fallback von Gemini auf Ollama und implementiert reale Executors für `manage_sim_session` (inkl. sicherem Read-Only-`Get`), `delegate_to_dark` und `delegate_to_rig`. Live verifiziert auf SimRacer mit `gemini-3.8-flash` und `qwen3.5:9b` (`Exit=0`).
  - `start_light_terminal.ps1` (`PID 192116`) liest `agent_states`, setzt `PYTHONUTF8=1` und `--allow-mutating`, verankert Regexes sauber, schützt Sandbox-Grafikaufgaben vor Fehldelegation an `@rig`, erkennt einen laufenden `:2222`-Container ohne unnötigen `150 s`-Boot-Wait und übergibt `handoff_context` an `@dark` (`150 s` Timeout).
- **`@dark` & Windows-11-Sandbox (`worker.ps1`, `start_dark_terminal.ps1`, `runner.ps1`):**
  - Zeitsynchronisation per StrikerPi `GET /health` (`Date`-Header) nach `W. Europe Standard Time` (`Abweichung 0.8s`), Cyborg-First-Ollama-Suche ohne `host.lan:11434`, Korrektur von `D:\ac-sandbox\shared\content` nach `C:\ac-sandbox\shared\content`, präziser INI-Editor (`Set-IniSectionKey`) und Fullscreen-Grafikprofil (`1024x768`, alle schweren Effekte/PP/ExtraFX/ScriptableFilter deaktiviert).
  - `LaunchSession` beendet alte `acs.exe`-Prozesse vor Neustart, löst Car/Track aus dem Replay-Namen (`gp_2025_rb21 @ ks_silverstone`) auf und startet das Silverstone-RB21-Replay sauber (`acs.exe PID 10980`). `SyncCoreAssets` nutzt `-SkipIfPresent` und verkürzt den Vollsync auf `6.34 s`.

---

## 7. Mischbetrieb (Gemini & Ollama) & Change-Freeze-Integrität

- **Nahtloser Mischbetrieb:** `@light` und `@sarah` laufen auf Google Gemini (`gemini-3.8-flash`), während `@general`, `@dark`, `@rig` und `@rick` lokal über Ollama arbeiten. Die Zusammenarbeit bleibt stabil, weil Aufträge und Ergebnisse dateibasiert als standardisierte JSON-Pakete (`inbox`/`outbox`) sowie über einheitliche Tool-Schemas in `ollama_router.py` und `telemetry_relay.py` ausgetauscht werden.
- **Change-Freeze bestätigt:** Alle geschützten Konfigurations- und Policy-Dateien (`approval_policy.json`, `pitwall_control_policy.json`, `wheel_write_release.json`, `AGENTS.md`, `*.agent.md`) wurden per SHA-256 geprüft und blieben unverändert. Das zeitlich befristete 30-Minuten-Mandat in `pitwall_control_policy.json` lief planmäßig um `13:54:42 CET` ab und wird erst bei der nächsten manuellen Testfreigabe über die Pitwall erneuert.

---

## 8. `@dark`-Priming (`2026.11.27-v2`), Content-Manager-Mod-Installer & Runtime-Wiring

Zur Abrundung wurde `@dark` vollständig auf Content Manager, Sessions/Replays und Content-/Mod-Installationen ausgerichtet:

- **Aktuelles Priming & 9-Tool-Toolbox (`2026.11.27-v2`):** `priming_profile.md` / `.json` sowie `toolbox.json` / `TOOLBOX.md` wurden aktualisiert (9 aktive Werkzeuge im Cyborg-Budget `<= 12`: neben Status, Setup-Check, Core-Sync, Preset und Gap-Reporter nun auch `launch_or_stop_cm`, `install_content_via_cm`, `list_sandbox_and_host_content` und `manage_sandbox_session`). Die statischen Workspace-Dateien `dark.agent.md` unterlagen weiterhin dem `AGENTS.md` §4 Change-Freeze.
- **Zweistufiger CM-Installer (`InstallModContent`):** `runner.ps1` und `start_dark_terminal.ps1` unterstützen das Installieren von Autos/Strecken sowohl direkt aus `Original_AC_Content` (`:ro`) als auch aus `.zip`/`.7z`/`.rar`-Mod-Archiven in `Original_AC_Downloads` & `Original_AC_Downloads_Archiv` (`:ro`) inkl. Treiber-/EXE-Schutzfilter (`Fanatec_Driver` o. ä. wird geblockt), AC-Strukturprüfung vor dem Entpacken, automatischer `steam_appid.txt=244210` und CM-Live-Indizierung.
- **Runtime & SQLite-Bibliothek:** `agent_ollama_tool_runtime.py` führt alle 8 operativen `@dark`-Werkzeuge direkt (im Gast) bzw. per Inbox-Handshake (auf SimRacer) aus und meldet bei gestopptem Docker-Container sauber `Blocked` / `SANDBOX_STOPPED`.

---

## 9. Nachmittags-Audit & Sofortpaket (Kommunikation, Übergabe & QA-Härtung)

Der direkte Abgleich der Nachmittags-Testlogs (`13:24–17:30 CET`) mit den damaligen Agenten-Ständen und dem abendlichen `@dark`-Ausbau hat die eigentlichen Ursachen früherer Fehlschläge offengelegt und komplett behoben — ohne eine einzige Change-Freeze-Datei anzutasten:

- **Keine Doppelverarbeitung & echtes `@dark`-QA-Schema (`worker.ps1`, `start_dark_terminal.ps1`):** Atomare `.processing`-Übernahme von Inbox-Aufträgen und konsequentes Yielding von `start_dark_terminal.ps1` an einen aktiven `worker.ps1` stoppen Race-Conditions. Über `Resolve-DarkToolMetadata` melden beide Skripte alle 9 Werkzeuge samt `executed_handler`, `tool_used`, `changes`, `before` und `after` atomar per `*.tmp`-Move an `light_verifier.py`.
- **Stabile Übergaben & Sub-Aktionen (`runner.ps1`):** Base64-kodierte Handoffs (`-HandoffBase64`) verhindern den PowerShell-5.1-Quote-Verlust im `handoff_context`; `Invoke-RunnerSubAction` beseitigt falsche `$LASTEXITCODE`-Abbrüche nach `SyncCoreAssets`; `SyncCoreAssets` filtert Core-Ordnernamen (`sfx`, `fonts`, `gui`, `weather`, `driver`, `texture`) vor der Fahrzeug-/Streckensuche heraus; `Install-SandboxModContent` unterstützt `-ForceReinstall` sowie Multi-Wildcard-Installation; und `DiagnoseAndHandoff` stuft `FULLSCREEN=1` nicht mehr irrtümlich als Konfigurationsfehler ein.
- **Lückenlose Orchestrierung (`start_light_terminal.ps1`, `start_general_terminal.ps1`):** `Build-LightDarkHandoffContext` versorgt auch direkte `@dark`-Aufträge mit vorab ermittelten Host-Content- und Replay-Hinweisen und schaltet `Invoke-LightVerificationAndReport` nach, während `-SkipProtocolLog` doppelte Leitstand-Einträge vermeidet. Auf Seiten von `@general` aktualisiert `Initialize-CommHistory` beim Start die Historie und `Invoke-GeneralLocalDiagnostic` ersetzt die bisher stille `else`-Verzweigung durch echte Log-, Leitstand- und Capability-Gap-Auswertung.
