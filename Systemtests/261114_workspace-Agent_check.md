# Audit-Bericht: Workspace-, Agenten-, Sandbox- & Dokumentations-Abgleich (`git-labor` & `assetto-corsa-content`)

Der Bericht basiert auf einem reinen Lese-Abgleich aller Workspace-Konfigurationen, Agent-Definitionen, Laufzeit-Skripte, Live-Logs und Dokumentationen über `git-labor`, `assetto-corsa-content`, `ac-cm-csp-sandbox`, `strikerpi-hub` und `.copilot`.

---

## 1. Status der Agents & der Kommunikation

### 1.1 Rollenverteilung im 5-Knoten-Verbund

| Agent | Vorgesehener Host / Knoten | Aktive Definition (`.agent.md`) | Laufzeit-Konsole / Worker | Kommunikationskanal |
| :--- | :--- | :--- | :--- | :--- |
| **`@general`** (`General Cyborg` / `General Sim`) | Laptop `VanstrikeCyborg` (`192.168.178.172`) | Global: `general.agent.md`<br>`git-labor/.github/agents/general.agent.md`<br>`assetto-corsa-content`: **nur in `agents.backup`** | `start_general_terminal.ps1` | SMB `\\192.168.178.68\ac-sandbox\shared\agents\*` + lokal `general-SIM\`, SSH/SCP an StrikerPi & Archibald |
| **`@light`** | SimRacer Host (`192.168.178.68`) | `git-labor/.github/agents/light.agent.md` | `start_light_terminal.ps1` | File-Inbox/Outbox, Docker CLI, `robocopy`, `manage-simracer-session.ps1` |
| **`@rig`** | SimRacer Host (`192.168.178.68`) | `git-labor/.github/agents/rig.agent.md` | `start_rig_terminal.ps1` + `rig-hub.ps1` | File-Inbox/Outbox, SteamVR/GPU, `sim_stream_server.py` (`:8090`) |
| **`@dark`** | Docker Win11 Guest (`ac-win11-sandbox`) | `git-labor/.github/agents/dark.agent.md` | `start_dark_terminal.ps1`, `worker.ps1`, `runner.ps1` | `\\host.lan\Data\agents\dark\{inbox,outbox}` (9p), SSH `:2222`, VNC `:8006`, RDP `:3390` |
| **`@sarah`** | Archibald IdeaPad 5 (`192.168.178.98`, Omarchy) / Sandbox-Fallback | `git-labor/.github/agents/sarah.agent.md` | Linux: `start_sarah_terminal.sh`<br>Win/Sandbox: `telemetry/start_sarah_terminal.ps1` | Linux: interaktive Bash-CLI (`sarah_*`), UDP `9996`, HTTP `:8080`<br>Win: `telemetry\{inbox,outbox}` |
| **`@rick`** | StrikerPi (`192.168.178.86`, Arch ARM) | `git-labor/.github/agents/rick.agent.md` | `strikerpi-hub/rick-agent/rick_worker.py` (`systemd`), `start_rick_terminal.sh` | SSH/SCP `/opt/rick-agent/{inbox,outbox}`, MQTT `:1883`, Relay `:8080` |

### 1.2 Befunde aus der Live-Kommunikation (`general-SIM/logs/agent_comm_20261112.log`)
Die reale Kommunikations-Historie belegt mehrere strukturelle Fehler in der Agent-Kette:
1. **Genehmigungs-Sturm (`@light -> @general`):** Zwischen `00:06:04` und `01:04:29` erzeugte jeder Dateipfad in einer Mehrzeilen-Eingabe eine eigene `ApprovalRequest`-Kaskade (`req_light_20261112_000604_049` bis `010429_025`, inkl. einzelner Zeile `'h'`), gekennzeichnet als `Rueckversicherung @light -> @light`.
2. **Pfad-Split (`general-SIM` vs. `general`):** Anfragen landeten in `general-SIM\approvals\`, Freigaben von `GeneralAgent_Laptop` wurden um `03:03:47` nach `\\192.168.178.68\ac-sandbox\shared\agents\general\outbox\` geschrieben.
3. **Schein-`Success` ohne Ausführung:**
   - `02:11:48`: `@dark` meldete für `starte CM` (`prompt_20261112_021138`) `Status: Success` mit `"Keine Code-Ausfuehrung"`, obwohl Content Manager nicht gestartet wurde.
   - `03:49:30`: `@light` meldete auf `Status` (`test_delegation_light_status`) `Status: Success` mit `"Unbekannte Aktion oder Prompt."`.
   - `03:53:01` / `03:57:41`: `@light` meldete bei Delegation an `@dark` bereits `Success`, während `@dark` erst Sekunden später (`02:53:07` / `02:57:48`) antwortete.
4. **Fehlschlag durch `worker.ps1`-Bug:** `02:37:25` scheiterte `test_status_20261112_033655` mit `Status: Failed | Nicht unterstütztes Format: .json`.

---

## 2. Standalone-Fähigkeit von `assetto-corsa-content`

**Ergebnis:** `assetto-corsa-content` ist **aktuell nicht standalone-fähig**. Wird das Repo allein (ohne `git-labor`) geöffnet, brechen Agent-Aktivierung, Tasks, Dispatcher und Doku-Verweise:

1. **Keine aktiven Custom Agents in `assetto-corsa-content/.github/`:**
   - Das Verzeichnis `agents` existiert nicht; alle 5 Dateien liegen deaktiviert in `agents.backup` (`dark`, `general`, `light`, `rig`, `sarah`).
   - `rick.agent.md` fehlt auch im Backup komplett.
   - Da der globale Agent `General Cyborg` (`general.agent.md`) SimRacer-/Sandbox-Aufgaben an den Workspace-Agenten `General Sim` delegiert, läuft diese Delegation im Standalone-Betrieb ins Leere.
2. **Defekter VS-Code-Task in `assetto-corsa-content/.vscode/tasks.json`:**
   - `"Agent Console: General Agent (Laptop VanstrikeCyborg)"` verweist auf `${workspaceFolder}\ac-sandbox\shared\agents\general\start_general_terminal.ps1`. Der tatsächliche Ordner heißt jedoch `general-SIM\`.
   - Ein Task für `@rick` (`connect_rick_terminal.ps1` ist vorhanden) fehlt in `tasks.json`.
3. **Fehlende Standalone-Brücke & Policy-Steuerung:**
   - Eine Entsprechung zu `git-labor/labs/Send-SimAgentTask.ps1` (Multi-Agent-Versand inkl. `@rick`, `-QueryStatus`, `-SetApprovalMode`) und `git-labor/labs/Agent-Terminals.ps1` existiert in `assetto-corsa-content` nicht.
   - `Send-DarkAgentTask.ps1` adressiert nur `@dark` und ruft via SSH `worker.ps1 -RunOnce` auf (aktuell durch den `.json`-Bug defekt).
4. **Cross-Workspace-Abhängigkeiten in Doku & Code:**
   - `assetto-corsa-content/docs/README.md` und `agenten-terminals-prompt-verarbeitung-und-rueckmeldungs-handbuch.md` verlinken direkt auf `../../git-labor/.github/agents/*.agent.md`.
   - `assetto-corsa-content.code-workspace` bindet `git-labor` als Ordner `2_Git-Labor` hart ein.

---

## 3. Was noch fehlt, bevor Agents & Sandbox-Agents `Success` melden dürfen

### 3.1 `assetto-corsa-content` & Sandbox (`ac-win11-sandbox`)

| Komponente / Datei | Ursache des Fehlers bzw. verfrühten `Success` | Erforderliche Korrektur |
| :--- | :--- | :--- |
| **`worker.ps1`** (Z. 102–104) | Im `elseif ($task.Extension -eq ".json")`-Block fehlt das `else { ... }`. Dadurch wird am Ende **jeder** `.json`-Auftrag mit `"Nicht unterstütztes Dateiformat: .json"` (`Status = "Failed"`, `exitCode = 1`) überschrieben. Außerdem fehlen `requester`/`reply_to` im Ergebnis-JSON. | `else { ... }`-Zweig sauber trennen; `sender`/`reply_to` in `result_*.json` übernehmen (wie in `start_dark_terminal.ps1`); `worker.ps1` und `start_dark_terminal.ps1` auf eine gemeinsame Parsing-/Logikbasis vereinheitlichen. |
| **`runner.ps1`** | **Schein-`Success` (Exit-Code `0`) bei Teil- oder Fehlschlägen:**<br>• `ValidateSetups`: gibt bei `$invalidCount -gt 0` nur `WARN` aus und endet mit `0`.<br>• `TestApp`: zählt nur `*.py`-Dateien statt Syntax-/Import-Checks (`python -m py_compile`), kein Fehler bei fehlendem Target.<br>• `LaunchCM` / `StopCM`: prüft im Fallback nicht, ob `Content Manager.exe` tatsächlich läuft bzw. beendet wurde.<br>• `LaunchSession`: prüft nicht, ob `acs.exe` nach Start wirklich läuft; hat zudem hartcodierte COTA-/RSS-Pfade (`rss_formula_hybrid_x_2026\acu_cota_2021` und festes `.acreplay`).<br>• `DiagnoseAndHandoff`: schreibt nur Handoff-JSON, prüft/wartet nicht auf Abschluss und setzt keinen Exit-Status.<br>• `SyncCoreAssets`: bricht bei fehlendem `\\host.lan\Data\content` per `return` (`exit 0`) statt `exit 1` ab. | Verbindliche Post-Conditions + `exit 1` bei Fehlschlag einführen (Prozess-Check nach `LaunchCM`/`LaunchSession`/`StopCM`, Exit `1` bei `$invalidCount -gt 0` oder fehlender Target-App/Content-Quelle); `LaunchSession` dynamisch über `race.ini` statt festem Fahrzeug/Track/Replay parametrisieren. |
| **`general-SIM` vs. `general/`** | Split-Brain: Die Konsole liegt in `general-SIM/` und liest `general-SIM\approval_policy.json`, während `light/start_light_terminal.ps1`, `rig/start_rig_terminal.ps1`, `Send-SimAgentTask.ps1`, `sim_agent_bridge.py` und `tasks.json` weiterhin `agents\general\` (`inbox`, `outbox`, `approval_policy.json`) adressieren. | Einheitlichen Ordnernamen (`general` oder `general-SIM`) festlegen und in allen Skripten, Bridges, Tasks und Dokus konsistent verwenden. |
| **`start_light_terminal.ps1`** | • `SetSession`/`SetCar`/`SetTrack` prüfen den Exit-Code von `manage-simracer-session.ps1` nicht.<br>• `ProvideAcCoreData`/`ProvideAcContent`: wenn `$missingItems.Count -gt 0`, bleibt `$status = "Success"`.<br>• Bei Delegation an `@dark` ohne Antwort innerhalb 25s wird trotzdem `Success` (`"Verarbeitung laeuft im Gast"`) gemeldet (bei Timeout oder ausbleibender Bestätigung sollte `Pending`/`Timeout` gemeldet werden).<br>• Hartcodierter Host-Pfad `C:\Program Files (x86)\Steam\...` statt flexibler SteamLibrary-Erkennung (`D:\SteamLibrary\...`). | Exit-Codes und `$missingItems` als Fehler/Partial werten; bei ausstehendem Dark-Handshake sauber `Pending`/`Timeout` statt `Success` zurückgeben; Steam-Pfad dynamisch über Registry/Konfig oder `D:\SteamLibrary` auflösen. |
| **`start_rig_terminal.ps1`** | `Invoke-ApprovedRigExecution` prüft beim Aufruf von `rig-hub.ps1` (`Status`, `PauseSandbox`, `ResumeSandbox`, `ListContent`) `$LASTEXITCODE` nicht und meldet pauschal `Success`. | `$LASTEXITCODE` / Fehlerausgabe von `rig-hub.ps1` auswerten und bei Fehlern `Failed` in `outbox` schreiben. |
| **`start_general_terminal.ps1`** | Beim Versand an `@rick` (Z. 865–881) wird sofort `Status = "Success"` gemeldet, ohne `scp`-Exitcode oder `/opt/rick-agent/outbox/result_<id>.json` abzuwarten. | `scp`-Exitcode prüfen und optional/bei Handshake auf `result_<id>.json` auf StrikerPi warten (mindestens `Submitted`/`Pending` statt `Success` melden). |
| **`start_sarah_terminal.ps1` & `.sh`** | • `.ps1` (Sandbox/Windows): `ConfigureTwoPillarVideoEngine` legt nur Ordner an; `AssignReplayAndVideoCutting` liefert fest `7` Replays; `promo`/`cut`-Prompts rufen weder `sarah_replay_cutter.py` noch FFmpeg auf und melden dennoch `Success`; Exitcode von `sarah_pitfile_optimizer.py` wird ignoriert.<br>• `.sh` (Archibald/Linux): reine interaktive Bash-REPL, **kein** Polling von Inbox/Outbox und keine MQTT-Anbindung – über Queue gesendete Tasks erreichen das native Linux-System nur, wenn die Windows-Konsole parallel läuft. | `.ps1` echte Aufrufe an `sarah_replay_cutter.py` (inkl. dynamischer Replay-Zählung und Exitcode-Prüfung) ausführen lassen; auf Archibald einen headless Worker (Inbox/Outbox bzw. MQTT/HTTP-Job-Endpunkt) ergänzen. |
| **Guest-Bootstrap & Content-Sync-Skripte** | • `bootstrap-guest.ps1` schreibt `guest-status.json` fälschlich mit `"agent": "Light Agent"`.<br>• `setup-guest-win11.ps1` ist laut Audit-Befund ein unvollständiger Stub.<br>• `sync-cm-github.ps1` & `stage-bought-cars.ps1` verweisen auf `C:\Program Files (x86)\Steam\...` statt `D:\SteamLibrary\...`. | `bootstrap-guest.ps1` auf `"Dark Agent"` korrigieren, Guest-Setup vervollständigen und Steam-Pfade zentral konfigurieren. |

---

### 3.2 `git-labor` & `strikerpi-hub`

| Komponente / Datei | Ursache des Fehlers bzw. verfrühten `Success` | Erforderliche Korrektur |
| :--- | :--- | :--- |
| **`git-labor/labs/Send-SimAgentTask.ps1`** | • `PolicyFile` zeigt auf `general\approval_policy.json` statt `general-SIM\approval_policy.json`.<br>• Sendet `target_agent` und `source` statt `target` und `sender` (so erscheint im Log `Extern`).<br>• Bei `@rick` wird `action = "note"` für Prompts gesendet und die Rückmeldung ungeprüft ausgegeben (kein Schema-Mapping `status: "ok"` vs. `"Success"`). | Pfad `general-SIM` angleichen; Payload-Felder (`sender`, `target`) an die Worker angleichen; Status-Auswertung vereinheitlichen. |
| **`git-labor/labs/03_python/sim_agent_bridge.py`** | • `policy_file` zeigt auf `general\approval_policy.json` statt `general-SIM\`.<br>• `send_agent_task` unterstützt `@rick` gar nicht (schreibt für `rick` lokal in `\\192.168.178.68\...\rick\inbox` statt per SSH/HTTP an StrikerPi).<br>• `publish_mqtt_task` publiziert auf `agents/<target>/inbox`, worauf **kein** Agent (weder Windows noch `rick_worker.py`) lauscht.<br>• `verify_repository()` prüft **10** Paketordner (`08_`–`10_`), während `sync-cm-github.ps1` nur 7 Pakete synchronisiert (dazu teils fehlender Abgleich mit realen Ordnerinhalten). | `@rick`-Support in `send_agent_task` ergänzen, `policy_file`-Pfad angleichen, MQTT-Subscriber in `rick_worker.py`/Windows-Workern ergänzen oder MQTT-Publish als ungenutzt kennzeichnen, Paketliste mit `ac-cm-csp-sandbox` abgleichen. |
| **`git-labor/labs/Agent-Terminals.ps1`** | Pfad für `@general` zeigt auf `shared\agents\general\start_general_terminal.ps1` (nicht existent; real `general-SIM\start_general_terminal.ps1`). | Pfad auf `general-SIM\start_general_terminal.ps1` korrigieren. |
| **`git-labor/.github/agents/*.agent.md`** | • `light`, `dark`, `rig`, `rick`, `sarah` fehlt das `name:`-Feld im YAML-Frontmatter.<br>• `light.agent.md` enthält UTF-8-Mojibake (`fÃ¼r`, `RÃ¼ckversicherungs`, `Ãœberwachung`).<br>• `sarah.agent.md` hat doppelte Zeilen (Z. 55–61). | YAML-Header vervollständigen, Encoding bereinigen, Duplikat entfernen und nach `assetto-corsa-content/.github/agents/` spiegeln bzw. sauber trennen. |
| **`strikerpi-hub/rick-agent/rick_worker.py`** | • Gibt bei **unbekannter `action`** immer `"status": "ok"` (`"Nachricht von ... empfangen"`) zurück – falscher Erfolg!<br>• Antwortschema (`status: "ok"`, `message`, `data`, ohne `exit_code`/`output`) ist inkompatibel mit dem `Success`/`Failed`/`Ignored` + `output`-Vertrag der übrigen Agenten.<br>• Prüft nicht `caddy.service` / `gitlabor-api.service`. | Unbekannte Actions mit `status: "ignored"` oder `"error"` beantworten; Schema um `output`/`exit_code` (oder Adapter in `Send-SimAgentTask.ps1`) erweitern. |
| **`strikerpi-hub/telemetry-relay/telemetry_relay.py`** | • `run_dark_runner` Fallback (Z. 479–505) schreibt `id` statt `task_id` in `inbox/{job_id}.json` und pollt `outbox/{job_id}.json` statt `outbox/result_{job_id}.json` (läuft somit immer in den Timeout).<br>• `_job_start_sandbox` nutzt `docker-compose.simracer.yml` (ohne die 5 `:ro` `Original_AC_*`-Mounts aus `docker-compose.yml`) und meldet bei erreichbarem VNC `:8006` bereits `ok=True`, auch wenn SSH `:2222` (für `@dark`) noch nicht bereit ist. | Task-JSON auf `task_id` + `outbox/result_{job_id}.json` umstellen; Compose-Datei/Mounts angleichen; Readiness-Check auf `:2222` + `worker.ps1`-Prüfung erweitern. |
| **`git-labor/labs/01_linux_bash/strikerpi-services/gitlabor-api.service`** | `ExecStart` zeigt auf `/srv/git-labor/apps/linux-monitor-api/server.mjs`, im Repo liegt jedoch `gitlabor-api.mjs` (bereits in `SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md` dokumentiert, aber im Service-File noch unkorrigiert). | Service-Unit an tatsächlichen Pfad/Dateinamen anpassen. |

---

## 4. Veraltete, falsche oder widersprüchliche Informationen in der Doku

### 4.1 `assetto-corsa-content`
- **Defekte Minimap-Links in praktisch allen Dokus & `.github/agents.backup/*.agent.md`:**
  - Links verweisen auf `README.md` (tatsächlich `README ACC.md`), `ac-sandbox/README.md` (tatsächlich `README Sandbox.md`) sowie auf `.github/agents/*.agent.md` (existiert nicht, nur `agents.backup`).
- **`README.md`:** Verweist direkt auf `../../git-labor/.github/agents/*.agent.md` (bricht Standalone) und verlinkt nicht existierende/umbenannte Dateien.
- **`multi-pc-architektur-ki-agents-simracing.md`:**
  - Widerspruch im selben Dokument: Abschnitt 1.2 beschreibt korrekt das 5-Knoten-Modell (`Light` auf SimRacer), Abschnitt 2.2 verortet `Light Agent` fälschlich auf `VanstrikeCyborg`.
  - Verlinkt auf fehlende Dateien (`uebersicht-vscode-agent-localhost-gemini-antigravity.md`, `planing.md`).
- **`docs/01_simracer_architektur/naechste-schritte-und-offene-aufgaben.md`:** Enthält veraltete Statusstände zu noch zu erstellenden Komponenten, die bereits existieren (oder umgekehrt).
- **`SANDBOX_ANLEITUNG.md`:**
  - Doppelte Überschrift `### 6.`.
  - Dokumentiert `Screen.cmpreset` (1920×1080) und fehlgeschlagenes SSH `:2222` nach Restart als aktuellen Zustand, während `README.md` weiterhin nur `Screen4k.cmpreset` dokumentiert.
  - Der `.json`-Bug in `worker.ps1` fehlt.
- **`agenten-system-architektur-uebersicht.md`:**
  - Beschreibt ein 5-Rollen-Netzwerk und lässt `@rick` (StrikerPi) komplett aus.
  - Verortet `General Sim` in `git-labor` und weist `start_sarah_terminal.ps1` fälschlich dem Linux-Host `omARCHy / archibald` zu.
- **`agenten-konsolen-repl-autostart-und-asset-handshake.md`:**
  - Nennt veraltet `4 Terminals`, alten Pfad `D:\ac-sandbox` und den bereits abgeschafften `folderOpen`-Autostart.
- **`agenten-terminals-prompt-verarbeitung-und-rueckmeldungs-handbuch.md`:**
  - Nennt `agents/general/` statt `general-SIM/`, behauptet pauschal `@sarah` polle `inbox/` und schreibe `result_*.json` (gilt nicht für `start_sarah_terminal.sh` auf Archibald) und verlinkt ins `git-labor`-Repo.
- **`agenten-kommunikation-und-sandbox-testbericht.md`:**
  - Bestätigt teilweise Probleme (z. B. fehlendes Inbox-Polling/Log in `start_sarah_terminal.ps1` zum Testzeitpunkt), deckt aber den `worker.ps1`-`.json`-Bug und die falschen `Success`-Meldungen in `runner.ps1` / `start_light_terminal.ps1` / `rick_worker.py` nicht ab.
- **`README.md`:**
  - Lässt `@general`, `@sarah` und `@rick` komplett aus, markiert Telemetry-/Mod-Agenten als „künftig“ und nennt einen falschen Light-Timeout (`15s`).

### 4.2 `git-labor`
- **`README.md`:**
  - Nennt die 5-Knoten-Topologie veraltet „4-Knoten“ und führt `05_workspace-schnittstelle-simracer-und-agenten-terminals.md` nicht im Verzeichnis auf.
- **`Doku/02_VSCode_Env/05_workspace-schnittstelle-simracer-und-agenten-terminals.md`:**
  - Dokumentiert `agents/general/` und `general/approval_policy.json` (tatsächlich `general-SIM/`), behauptet für `@sarah` durchgängiges `inbox/outbox`-Polling ohne Hinweis auf die fehlende Linux-Queue-Anbindung auf Archibald.
- **`SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md`:**
  - Abschnitte 2 und 3 enthalten veraltete Angaben (6 statt 5 SSH-Profile in `git-labor.code-workspace`, `paho-mqtt`, `sim/tasks/...`, `auto_approve`), die zwar in Abschnitt 5 teils relativiert werden; Abschnitt 5 selbst geht aber weiterhin fälschlich von `general\approval_policy.json` statt `general-SIM\` aus.
- **`git-labor/.github/agents/*.agent.md` (Minimaps & Links):**
  - `general.agent.md`, `light.agent.md`, `dark.agent.md`, `sarah.agent.md` enthalten die `assetto-corsa-content`-Minimap mit dort gebrochenen Relativpfaden (`../../docs/...`, `../../ac-sandbox/...`); `general.agent.md` bezeichnet `assetto-corsa-content` wörtlich als `(dieser Workspace)`.
  - `rig.agent.md` enthält die `git-labor`-Minimap mit falschen Dateinamen unter `01_Linux_Bash` (`02_arch-linux...` und `03_docker...` statt tatsächlich `03_arch-linux-omarchy-und-remote-ssh.md` und `05_docker-und-sbx-micro-vms.md`).

### 4.3 Sicherheits-/Konfigurations-Hinweis in beiden `.code-workspace`-Dateien
- Sowohl `git-labor.code-workspace` als auch `assetto-corsa-content.code-workspace` enthalten API-Keys im Klartext (`geminiApiKey.key`, `geminiCode.apiKey` – letzterer in `assetto-corsa-content.code-workspace` zusätzlich fälschlich in `geminicodeassist.agent.additionalTrustedCertificates`).
- Die MCP-Server sind unterschiedlich definiert: `.mcp.json` in `git-labor` konfiguriert 3 Server (`local-workspace-filesystem`, `google-ai-search-mcp`, `geminiDocs`), während `.vscode/mcp.json` in beiden Repos leer (`{"servers": {}}`) ist und nur `geminiDocs` in den `.code-workspace`-Dateien steht.

---

## 5. Priorisierte Checkliste (Nächste Schritte vor Produktiv-Betrieb)

1. **`worker.ps1` (Sandbox) fixen:** Fehlendes `else` ergänzen, damit `.json`-Tasks nicht pauschal als `"Nicht unterstütztes Dateiformat: .json"` fehlschlagen.
2. **`general-SIM` vs. `general` vereinheitlichen:** Einen gemeinsamen Ordnernamen für `inbox`, `outbox` und `approval_policy.json` in `start_general_terminal.ps1`, `start_light_terminal.ps1`, `start_rig_terminal.ps1`, `Send-SimAgentTask.ps1`, `sim_agent_bridge.py`, `Agent-Terminals.ps1` und `tasks.json` festlegen.
3. **Echte `Success`-Gates in `runner.ps1`, `start_light_terminal.ps1`, `start_sarah_terminal.ps1`, `rick_worker.py` und `telemetry_relay.py` einbauen:** Kein `exit 0` / `Success` ohne geprüften Prozess-, Exitcode- und Outbox-Nachweis; `run_dark_runner` in `telemetry_relay.py` auf `task_id` + `result_<id>.json` korrigieren.
4. **`assetto-corsa-content` standalone machen:** `agents.backup` nach `agents` reaktivieren (inkl. `rick.agent.md` und YAML-`name:`), `tasks.json` korrigieren und Cross-Repo-Links auf `git-labor` auflösen.
5. **Dokumentation & Minimaps bereinigen:** Gebrochene Links (`README ACC.md`, `README Sandbox.md`, `03_`/`05_` unter `01_Linux_Bash`, `general-SIM`) und veraltete Rollen-/Pfadangaben korrigieren sowie Klartext-API-Keys aus den `.code-workspace`-Dateien entfernen.