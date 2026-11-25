# Technische Systemquelle: Pitwall-Steuerungskonsole (v2.1.0) & Multi-Agenten-Architektur (v5) – Stand 25.11.2026

> **Verwendungszweck dieses Dokuments:** Flache, eigenständige Markdown-Systemreferenz für **Gemini NotebookLM** (ohne einklappbares HTML/CSS). Sie beschreibt den verifizierten Produktivstand vom **25.11.2026** über alle 5 Systemknoten hinweg: Hardware-Topologie, Agenten-Hierarchie (`Architektur v5`), Werkzeugkoffer (`toolbox.json`), lokale Ollama-Tool-Runtime (`qwen3.5:9b`), 2-Stufen-Qualitätssicherung (`light_verifier.py`), Leitstand-Protokoll & Ausbauvorschläge (`leitstand_protocol.py`), **Pitwall v2.1.0 Webkonsole** inkl. 3-stufigem Drill-Down, verifizierte E2E-/GPU-Testläufe (inkl. Hisense 4K-TV-Optimierung) sowie alle REST- und WebSocket-Schnittstellen.
> **Live-Endpunkt Pitwall:** `http://192.168.178.86:8080/` (auf `StrikerPi`, Dienst `telemetry-relay.service`, Quellspiegel: `c:\Users\strik\strikerpi-hub\telemetry-relay\telemetry_relay.py`).

---

## 1. Systemüberblick & 5-Knoten-Topologie

Das Gesamtsystem verbindet zwei Entwickler-/Leitstand-PCs, eine virtualisierte Windows-11-Sandbox, ein Linux-Touch-Kiosk-Tablet und einen Raspberry Pi 4 als zentralen Telemetrie- und UI-Hub.

| Knoten | IP / Ports | Hardware & OS | Rolle, Agenten & Dienste | Besonderheiten / Limits |
| :--- | :--- | :--- | :--- | :--- |
| **VanstrikeCyborg** | `192.168.178.172` | Host-Laptop: Intel Core 7 240H, NVIDIA RTX 5060 Laptop (8 GB), 16 GB RAM, Windows | Leitstand **`General Cyborg`** (global) & **`General SIM`** (`assetto-corsa-content`); lokales Ollama (`qwen3.5:4b`, `gemma4:e4b`); Bridge `Send-SimAgentTask.ps1` | Teilt `Cyborg-GitLabor-RO` und `Cyborg-AC-Content-RO` **Read-Only** an `SimRacer`. Alle Repo-Schreibrechte liegen beim Leitstand. |
| **SimRacer** | `192.168.178.68` | AMD Ryzen 9 3900X, 31,92 GB RAM, NVIDIA **RTX 5070 Ti** (16303 MiB VRAM, Treiber `621.40`), `C:` NVMe + `D:\OllamaModels` USB; HTC VIVE Focus Vision (DP), Fanatec Wheelbase, **Hisense 4K-TV** (`DISPLAY\HECB340`) | **`@light`** (alleiniger Host-Orchestrator & QA-Prüfer), **`@rig`** (Hardware/Display/NVIDIA/VR-Facharbeiter); Ollama `:11434` (`qwen3.5:9b`, `gemma4:12b`, `qwen2.5-coder:14b`) | `bcdedit numproc=12` aktiv (6c/12t bis Admin-Bereinigung); `OLLAMA_KEEP_ALIVE=30m`, `OLLAMA_NUM_PARALLEL=1`; **0 %** GPU-Hintergrundlast bei `LIVE_RACE` oder laufender Sim/VR. |
| **ac-win11-sandbox** | `192.168.178.68:2222` (SSH), `:8006` (noVNC), `:3390` (RDP) | Docker/KVM Windows-11-Guest auf `SimRacer` (`CPU_CORES: 6`, `RAM_SIZE: 10G`; `.wslconfig`: 6 Kerne / 14 GB) | **`@dark`** (Sandboxed Guest-Worker unter `@light`, `worker.ps1` / `runner.ps1`) | Read-Only-Mounts `:ro` für `Original_AC_Content`, `Original_AC_Settings`, `Original_AC_Replays`, `Original_AC_Downloads`. |
| **Archibald** | `192.168.178.98` | Lenovo IdeaPad 5, Arch Linux / Omarchy (Hyprland) Touch-Kiosk | Chromium Fullscreen Pitwall-Kiosk (`StrikerPi:8080`); **`@sarah`** (`RaceEngineerCoach`); Dienste `sarah-agent.service`, `sarah-pitwall-telemetry.service` (UDP `:9996`), `voxtype.service` | `@sarah` sendet Live-Coaching per Sprache an die SimRacer VR Radio Bridge (`:8092`). |
| **StrikerPi** | `192.168.178.86` | Raspberry Pi 4 (`aarch64`), Linux | Pitwall-Host **`telemetry-relay.service`** (`telemetry_relay.py`, Port `:8080`); `mosquitto.service` (`:1883` / WS `:9001`); `rick-agent.service` (**`@rick`**); `caddy.service`; Bare-Git `/srv/git/simrig.git` | Empfangsport UDP `:50005` mit Weiterleitung an Archibald `:9996`; API-Cache 8s (`/api/leitstand/protocol`) bzw. 15s (`/api/leitstand/toolboxes`). |

---

## 2. Agenten-Steuerung Architektur v5: Hierarchie, Rollen & Ehrlichkeitsvertrag

Mit **Architektur v5** wurde die direkte, unkontrollierte Befehlsausführung durch Sub-Agenten beendet und eine strikte Orchestrierungskette mit verpflichtender Qualitätsprüfung eingeführt.

### 2.1 Rollenverteilung & Befehlskette

```text
Leitstand (General SIM / General Cyborg auf VanstrikeCyborg)
   │  Send-SimAgentTask.ps1  ──►  sim_agent_bridge.py (Policy + XOR-Mutex + Change-Freeze)
   ▼
@light (Alleiniger Host-Orchestrator & QA-Prüfer auf SimRacer)
   ├──► @rig   (Facharbeiter für Hardware, Display/ClearType, NVIDIA, VR, SimRacer-Hub)
   ├──► @dark  (Facharbeiter in Docker/Win11-Sandbox ac-win11-sandbox)
   │
   ├──► 2-Stufen-QA (light_verifier.py: Stufe A Real-State + Stufe B Sauberer Pfad)
   └──► Rückmeldung an General SIM (leitstand_protocol.py + doc_handoffs/ + Pitwall :8080)

Begleitagenten (spezialisierte Dienste):
   • @sarah (Archibald): RaceEngineerCoach -> SimRacer VR Radio Bridge (:8092)
   • @rick  (StrikerPi): Relay-, MQTT- und Pi-Infrastruktur-Agent
```

1. **General SIM / General Cyborg (`VanstrikeCyborg`):** Formuliert Aufträge, verwaltet das Git-Repository (`git-labor`) und empfängt strukturierte Ergebnis- und Handoff-Pakete von `@light`.
2. **`@light` (`SimRacer`):** Einziger autorisierter Host-Orchestrator. Empfängt Aufträge vom Leitstand, prüft Freigaberichtlinien (`pitwall_control_policy.json`) und Change-Freeze, delegiert Facharbeiten an `@rig` oder `@dark`, erzwingt Beweise über `light_verifier.py` und meldet sowohl **Erfolge** als auch **Fehler/Fähigkeitslücken** vollständig an den Leitstand zurück.
3. **`@rig` (`SimRacer`) & `@dark` (`ac-win11-sandbox`):** Facharbeiter für Hardware/Windows/NVIDIA/VR bzw. isolierte AC-Sandbox-Tests. Empfangen Aufträge **ausschließlich über `@light`** – niemals über ungeprüfte Direkt-Shortcuts unter Umgehung der QA.

### 2.2 Ehrlichkeitsvertrag & Kanonische Status-/Fehlercodes

Vor dem Umbau (Root-Cause in `prompt_20261125_020111`) fehlte `@rig` ein Display-/NVIDIA-Handler; der PowerShell-Worker fiel pauschal auf `$execStatus = "Success"` zurück und verwarf `@light`s `Ignored`-Handoff per `[void]`. Architektur v5 verbietet jeden Schein-Erfolg:

* **Kanonische Endstatus (`final_status`):**
  * `Executed` — Vom Worker ehrlich als technisch ausgeführt gemeldet (noch vor finaler QA-Freigabe).
  * `VerifiedSuccess` — Beide QA-Stufen (`Stufe A Real-State` und `Stufe B Sauberer Pfad`) durch `@light` bestanden; Vorher/Nachher-Evidenz liegt vor.
  * `VerificationFailed` — Durch `light_verifier.py` abgelehnt (z. B. Dummy-Text-Antwort, fehlendes Tool im Koffer oder fehlender Vorher/Nachher-Nachweis).
  * `MissingCapability` — Dem Agenten fehlt ein Werkzeug im Koffer (`toolbox.json`) oder eine Fachkompetenz; meldet zwingend einen Ausbauvorschlag.
  * `Unsupported` — Prompt außerhalb des unterstützten Domänenumfangs.
  * `Blocked` — Durch Sicherheits-Guardrail gestoppt (z. B. `LIVE_RACE`, laufende `acs.exe`/`vrserver.exe`, Pitwall-Pause/Not-Aus oder Change-Freeze).
  * `Rejected` — Durch Freigabe-Matrix (`MANUAL` ohne Genehmigung) oder Leitstand-Prüfung abgewiesen.
  * `Failed` — Technischer Ausführungs- oder Timeout-Fehler.

* **Kanonische Fehlercodes (`error_code`):**
  * `NONE` — Fehlerfrei verifiziert.
  * `PROMPT_UNIDENTIFIED` — Auftrag konnte keinem Intent oder Werkzeug eindeutig zugeordnet werden.
  * `TOOL_MISSING` — Kein passendes registriertes Tool in `toolbox.json`.
  * `COMPETENCY_MISSING` — Domänen- oder SDK-Kompetenz fehlt beim Worker (z. B. spezifische Hardware-Kalibrierungs-API).
  * `VERIFICATION_FAILED` — Stage A oder Stage B in `light_verifier.py` nicht bestanden.
  * `EXECUTION_ERROR` — Laufzeitfehler, Guardrail-Blockade (`LIVE_RACE`), Timeout oder I/O-Fehler.

* **Nachweispflicht für Mutationen:** Jede zustandsändernde Aktion (`mutating`) muss **Ausgangswerte (Vorher)**, **konkrete Änderungen (Nachher)**, einen gültigen **`backup_file`-Pfad** und den **QA-Verifikationsnachweis** mitliefern.

### 2.3 Verbindlicher Selbstschutz (Change-Freeze)

Kein Agent darf ohne ausdrückliche vorherige Nutzer-Freigabe (nach Diff-Vorschau) seine eigene oder fremde Agenten- und Systemkonfigurationen ändern, überschreiben oder löschen. Geschützt sind unter anderem:
`*.agent.md`, `AGENTS.md`, `*.instructions.md`, `SKILL.md`, `approval_policy.json`, `*.code-workspace`, `settings.json`, `mcp.json`, `tasks.json` und `pitwall_control_policy.json`.
Diese Sperre wird sowohl im Bridge-Skript (`sim_agent_bridge.py` per Regex) als auch in `agent_ollama_tool_runtime.py` hart erzwungen.

---

## 3. Agenten-Werkzeugkoffer (`toolbox.json`) & Lokale Ollama-Tool-Runtime

### 3.1 Werkzeugkoffer-System (`toolbox_manager.py`)

Das Inventar-Skript `\\192.168.178.68\ac-sandbox\shared\scripts\toolbox_manager.py` generiert und synchronisiert maschinenlesbare (`toolbox.json`) und menschenlesbare (`TOOLBOX.md`) Fähigkeitskoffer für alle **6 System-Agenten** sowie die Gesamtübersicht `AGENT_TOOLBOX_OVERVIEW.md` (insgesamt **28 generierte Dateien**).

| Agent | Speicherpfad unter `shared/memories/` | Anzahl Tools | Dokumentierte Kernwerkzeuge & Zuständigkeit |
| :--- | :--- | :---: | :--- |
| **`@light`** | `shared/memories/host/light/` | **7** | `verify_worker_result`, `delegate_to_rig`, `delegate_to_dark`, `manage_sim_session`, `manage_docker_sandbox`, `export_leitstand_protocol`, `report_capability_gap` |
| **`@rig`** | `shared/memories/host/rig/` | **8** | `inspect_display_and_nvidia`, `apply_display_sharpness_profile`, `analyze_vr_telemetry`, `apply_vr_stufe3_fixes`, `manage_rig_hub`, `inspect_wheel_ffb_safety`, `propose_or_apply_wheel_ffb_setting`, `report_capability_gap` |
| **`@dark`** | `shared/memories/sandbox/` | **6** | Sandbox-bezogene Werkzeuge im Windows-11-Guest (`ac-win11-sandbox`) unter Delegation von `@light` inkl. ehrlicher Fähigkeitslücken-Meldung (`CAPABILITY_GAP_JSON`) |
| **`@general`** | `shared/memories/host/general/` | **3** | Leitstand-Koordination, Bridge-Steuerung und Protokoll-/Dokumentations-Übernahme (`General SIM` / `General Cyborg`) |
| **`@sarah`** | `shared/memories/host/sarah/` | **3** | `RaceEngineerCoach`-Telemetrieauswertung & VR-Radio-Coaching auf `Archibald` (`:9996` / `:8092`) |
| **`@rick`** | `shared/memories/host/rick/` | **2** | Relay-, MQTT- (`:1883`) und Pitwall-Infrastrukturprüfung auf `StrikerPi` |

Für Hardware- und Display-Eingriffe nutzt `@rig` das dedizierte Tool-Modul `\\192.168.178.68\ac-sandbox\shared\scripts\rig_display_tuner.py` (Registry-Auslesung/-Backup und parametrisierte ClearType-/Gamma-Anwendung mit JSON-Nachweis).

### 3.1a VIVE Hub & VR-Settings Tool-Status (Audit 25.11.2026)

* **Vorhanden im `@rig`-Koffer:** `analyze_vr_telemetry` (`rig_ollama_vr_analyzer.py`, `read_only` für AC/CSP-INIs, `steamvr.vrsettings`, `vrcompositor.txt`, `HwSchMode`, `bcdedit numproc`) sowie `apply_vr_stufe3_fixes` (`rig_apply_vr_fixes.py`, `mutating`, statisches Einmal-Fix ohne Parameter `{}` inkl. Black-Eye-Invariante `SINGLE_PASS_STEREO_REAL=0` & `USE_VRS=0`).
* **Dokumentierte Tool-Lücken:**
  1. **VIVE Hub / VIVE Business Streaming:** Auf `SimRacer` zwar installiert (`C:\Program Files\VIVE Hub\`, Treiber `htc_business_streaming` für VIVE Focus Vision, `RRServer\config\serverSetting.setting`, `QualityPreset.json`, `C:\ProgramData\HTC\ViveSoftware\ViveHUB\ViveHubServerConfig.ini`, `HKCU:\Software\HTC\VBS`), aber **noch kein Lese-/Schreibtool** in `toolbox.json` vorhanden.
  2. **Parametrisierbare VR-Settings:** Keine gezielten Einzelparameter-Tools (z. B. 90/120 Hz Umschaltung, App-Resolution-Scale oder `openvr.ini`/`vr_tweaks.ini` Fein-Tuning); `Invoke-RigCspVrOptimization` in `start_rig_terminal.ps1` ist nicht als Toolbox-Tool registriert.

### 3.1b 4-Stufen Lenkrad- & Force-Feedback-Verletzungsschutz (`rig_wheel_safety_guard.py`)

Alle Änderungen an Lenkrad-, FFB- (`controls.ini`, `ff_post_process.ini`, `extension\ffb_tweaks.ini`, `system\cfg\assetto_corsa.ini`) und Fanatec-Parametern unterliegen auf `@rig`, in `agent_ollama_tool_runtime.py` und in `rig-hub.ps1` (`DeployPitfile`-Sperre) einer harten, deterministischen **4-Stufen-Sperre** (`0 %` GPU-Last, Fail-Closed):

1. **Stufe 1 — Live-Simulator- & Boxengassen-Interlock:** Läuft `acs.exe`/`acs_x86.exe`, liest der Guard `acpmf_physics` und `acpmf_graphics` (`3` Prüfpunkte). Änderungen sind **streng verboten**, sobald das Fahrzeug fährt (`|speedKmh| > 0.5`), außerhalb der Boxengasse steht (`isInPit == 0` und `isInPitLane == 0`), Gas anliegt (`gas > 0.02`), Drehmoment am Lenkrad wirkt (`|finalFF| > 0.15`), Replay aktiv ist oder Shared Memory nicht lesbar ist (`LIVE_DRIVING_BLOCKED`, `NOT_IN_PITLANE_BLOCKED`, `MOVING_IN_PITLANE_BLOCKED`). Erlaubt ist nur verifizierter Stillstand in der Boxengasse (`0 km/h`, `PITLANE_STATIONARY_VERIFIED`) oder Offline-Standby.
2. **Stufe 2 — Anti-Kickback- & Verletzungsschutz-Vorabprüfung (`INJURY_RISK_BLOCKED`):** Prüft Zielwerte vorab gegen heftige Lenkrad-Ausschläge und Oszillationen: `ff_gain` `[0.10 .. 1.00]` (max `+0.15`/Schritt), `wheel_max_nm` `[2.0 .. 8.0] Nm` (max `+1.5 Nm`/Schritt), effektives Moment `<= 6.5 Nm` (max `+20 %`/Schritt), `min_ff <= 0.12`, `center_boost_gain <= 15`, kein `GYRO2=0` bei FFB `>= 65 %`, `steer_lock` `[360 .. 1080]°`, `ff_gamma` `[0.60 .. 1.50]`, `.lut`-Monotonie & Steigung `<= 3.0`, `range_compression` `[0.50 .. 4.50]`, `filter_ff <= 0.50` sowie Effekt-Limits `<= 0.50`.
3. **Stufe 3 — Pflicht-Kräfte-Briefing:** Erzeugt vorab die exakte Vorher/Nachher-Übersicht in `Nm` und `%` inkl. Griff-Sicherheitshinweis (und optionaler VR-Radio-Warnung `:8092`).
4. **Stufe 4 — Ausdrückliche Fahrer-Freigabe per Einmal-Token (`WFB-...`):** Ohne an den exakten Parameter-Hash gebundenes Fahrer-Token + Bestätigung wird **nicht** geschrieben (`DRIVER_CONFIRMATION_REQUIRED`) – selbst bei Pitwall-Modus `AUTO`/`DELEGATED`. Unmittelbar vor dem Schreiben wird der Boxengassen-Stillstand erneut geprüft; `light_verifier.py` verlangt bei Stage A neben Live-Grenzwert-Check sowohl `backup_file` als auch `driver_receipt_file`.

### 3.2 Lokale Ollama Tool-Runtime (`agent_ollama_tool_runtime.py`)

Die Tool-Ausführung der Worker auf `SimRacer` läuft **rein lokal** (0 Cloud-Aufrufe) über `\\192.168.178.68\ac-sandbox\shared\scripts\agent_ollama_tool_runtime.py` gegen die lokale Ollama-Instanz (`127.0.0.1:11434`):

* **Modell & Inferenz-Parameter:** Standardmodell `qwen3.5:9b`, `think: False` (direkte Tool-Calls ohne langwierige Denk-Latenz), `keep_alive: "30m"`.
* **Timeouts:** `240s` für Kaltstart (erstes Laden der ~6–9 GB Modellgewichte in den VRAM der RTX 5070 Ti) und `90s` für warme Folgeläufe.
* **Harte GPU-Guardrail:** Vor jedem LLM- oder GPU-Aufruf prüft die Runtime auf aktive Sim-/VR-Prozesse (`acs.exe`, `acs_x86.exe`, `vrserver.exe`) sowie das Policy-Flag `gpu_background_allowed=false` (im Pitwall-Modus `LIVE_RACE`). Ist eine dieser Bedingungen aktiv, bricht die Runtime sofort mit `Blocked` / `EXECUTION_ERROR` ab – dadurch bleibt die GPU-Zusatzlast im Rennbetrieb bei garantiert **0 %**.
* **Pflicht zur Lückenmeldung (`report_capability_gap`):** Kann das Modell einen Auftrag nicht mit den registrierten Werkzeugen des eigenen Koffers erfüllen, darf es keine Ausrede erfinden, sondern muss `report_capability_gap` aufrufen. Dieses Tool liefert ein standardisiertes JSON-Paket mit:
  * `missing_tools` (konkrete fehlende Tool-Bezeichner),
  * `missing_competencies` (fehlende Hardware-, Treiber- oder SDK-Fähigkeiten),
  * `ollama_extension_proposal` (Ausbauvorschlag für ein neues Ollama-Tool inkl. Parameter-Schema, Anpassungen am Priming-Profil und Risikoklassifizierung).

---

## 4. Qualitätssicherung (`light_verifier.py`), Leitstand-Protokoll & Bridge

### 4.1 2-Stufen-QA durch `@light` (`light_verifier.py`)

`@light` prüft jedes Worker-Ergebnis automatisiert über `\\192.168.178.68\ac-sandbox\shared\scripts\light_verifier.py`, bevor ein Status als `VerifiedSuccess` an den Leitstand geht:

1. **Stufe A — Real-State-Prüfung:** Validiert tatsächliche Systemzustände unabhängig vom Behauptungstext des Workers:
   * Windows Registry (`HKCU\Control Panel\Desktop`, `Avalon.Graphics\DISPLAY1`),
   * GPU-/Treiber-Abfrage (`nvidia-smi`),
   * tatsächliche Existenz und Lesbarkeit der angegebenen `backup_file`,
   * Konfigurations-Inhaltsschutz (`vr_tweaks.ini` mit Sicherstellung `SINGLE_PASS_STEREO_REAL != 1` und `USE_VRS != 1`, `race.ini`),
   * Lenkrad-/FFB-Verletzungsschutz (`rig_wheel_safety_guard.py`: Prüfung von `controls.ini`/`ffb_tweaks.ini`, Anti-Kickback-Grenzen, `backup_file` sowie Fahrer-Briefing-Quittung `driver_receipt_file`),
   * Sandbox-Statusdatei (`dark-status.json`).
2. **Stufe B — Sauberer-Pfad & Anti-Dummy-Prüfung:**
   * Erkennt und verwirft pauschal zurückgegebene Schein-Erfolge wie `"Auftrag mit General-Freigabe ausgefuehrt:"` oder `"empfangen und registriert."` sofort als `VerificationFailed` (`VERIFICATION_FAILED`).
   * Verlangt, dass das verwendete Werkzeug aktiv in der `toolbox.json` des ausführenden Agenten registriert ist.
   * Erzwingt bei `mutating`-Werkzeugen überprüfbare Vorher/Nachher-Vergleichswerte sowie einen Backup-Nachweis.
3. **Protokollierung & Encoding:** Mit `--record-leitstand` persistiert `light_verifier.py` das Prüfergebnis direkt in das zentrale Ledger. In `start_light_terminal.ps1` sind `PYTHONUTF8=1` und ein direkter `doc_handoffs`-Fallback verankert.

### 4.2 Leitstand-Ledger, Missing-Tools-Report & DocHandoff (`leitstand_protocol.py`)

`\\192.168.178.68\ac-sandbox\shared\scripts\leitstand_protocol.py` (Python 3.11 Standardbibliothek) führt das zentrale Melde- und Diagnosearchiv für `General SIM` unter `\\192.168.178.68\ac-sandbox\shared\agents\general-SIM\`:

* **`logs\leitstand_protocol.jsonl`** & **`logs\LEITSTAND_PROTOKOLL.md`:** Append-only Ereignis-Ledger (maschinen- und menschenlesbar) über jeden ausgeführten, blockierten oder abgelehnten Auftrag.
* **`logs\capability_gaps.jsonl`**, **`logs\capability_gaps_summary.json`** & **`logs\MISSING_TOOLS_REPORT.md`:** Aggregiertes Register aller erkannten Tool-/Kompetenzlücken inkl. der `ollama_extension_proposal`-Entwürfe.
* **`doc_handoffs\handoff_<task_id>.json`** & **`.md`:** Nach erfolgreichem QA-Lauf (oder relevanter Diagnose) legt `@light` ein strukturiertes Dokumentationspaket in dieser Inbox ab. So bleibt das `Read-Only`-Limit von `SimRacer` gegenüber `Cyborg-GitLabor-RO` gewahrt: `General SIM` auf `VanstrikeCyborg` liest das Handoff-Paket und überführt es sauber in `Doku/`.

### 4.3 Bridge, XOR-Mutex, Policy Gate & Priming Forge (`VanstrikeCyborg`)

* **PowerShell-CLI (`c:\Users\strik\git-labor\labs\Send-SimAgentTask.ps1`):** Steuert Aufgabenübermittlung an `SimRacer` inkl. Parametern `-WorkspaceContext`, `-IssuedBy`, `-QueryStatus` und `-QueryLeitstand` (zeigt kompakte Live-Übersicht der Protokoll-Einträge und fehlenden Tools mit Status-Farbcodierung). *Hinweis für Remote-SSH an Windows PowerShell 5.1:* Komplexe Befehle stets Base64-kodiert als UTF-16LE `-EncodedCommand` übergeben (ohne `&&`).
* **Python-Bridge (`c:\Users\strik\git-labor\labs\03_python\sim_agent_bridge.py`):**
  * Erzwingt die Hierarchie `General -> Light -> Worker`.
  * Prüft `pitwall_control_policy.json` und Change-Freeze-Regex vor jedem Dispatch.
  * Schützt parallele Mutationen durch den atomaren XOR-Mutex **`execution_mutex.lock`** (TTL: `120s`).
  * Stellt programmatische Abfragen bereit: `get_leitstand_protocol()`, `get_missing_tools_report()`, `get_agent_toolboxes()`.
* **Priming Forge (`c:\Users\strik\git-labor\labs\03_python\agent_priming_forge.py`):** Hält aktualisierte `scope_note`-Profile für `rig`, `light` und `general` synchron.

---

## 5. Pitwall v2.1.0 Webkonsole (`StrikerPi :8080`)

Die Pitwall auf `http://192.168.178.86:8080/` ist als scroll-freie **6-Seiten-Touch-Konsole (`100dvh`)** für den Touch-Monitor auf `Archibald` und den Desktop-Browser im Leitstand konzipiert.

### 5.1 Gesamtstruktur: Topbar, 6 Hauptseiten & Overlays

* **6 Hauptseiten der Touch-Konsole:**
  1. **Telemetrie:** 50-Hz-Echtzeitdaten über `WS /ws/telemetry` (UDP-Eingang `StrikerPi :50005` mit Weiterleitung an `Archibald :9996`).
  2. **Streams / Video:** Live-Lobby-Kamerabilder (`simracer.jpg` / `simracer.mjpeg`) inkl. Kamera-Umschaltung (`POST /api/stream/camera`) und noVNC-Einbindung (`:8006`).
  3. **Sandbox / AC Content:** Lebenszyklus-Steuerung von `ac-win11-sandbox` (`start`, `stop`, `pause`, `resume`) sowie AC-Content-/Session-Aktionen (`POST /api/sandbox/ac/action`).
  4. **Agentensteuerung (`🛡️ Agenten`, `#page-control`):** Zentraler Leitstand für Status, Policy, Freigaben, Werkzeugkoffer und Protokoll-Diagnose (4 Sub-Tabs, siehe §5.2).
  5. **SSH-Terminals:** Integrierte WebSocket-Terminals je Agent über `WS /ws/terminal/{agent}`.
  6. **Agenten-Logs:** Historische Aufgaben- und Hardware-Logs über `GET /api/logs/history` und `GET /api/logs/task/{agent}/{task_id}`.
* **Touch-/Display-Menü & Sprachchat-Overlay:** Touch-optimiertes Drawer-Menü für Betriebsmodi (`POST /api/mode`), Archibald-Kiosk-Steuerung (`POST /api/pitwall/archibald`) und einklappbares Voice-Overlay (`POST /api/voice/dispatch` bzw. `voxtype.service` -> `@sarah`).

### 5.2 Bereich `🛡️ Agenten` (`#page-control`) – Die 4 Sub-Tabs

1. **`🤖 Agenten & Status` (`subTab-agents`):**
   * **3 Master-Karten:**
     * `⏯️ Global-Status` (Systembetriebsmodus / globale Freigabe),
     * `🎮 RTX 5070 Ti & Ollama` (Anzeige/Steuerung der GPU-Hintergrundfreigabe während `LIVE_RACE`),
     * `🚨 Not-Aus & Mandat` (sofortiger Stopp aller autonomen Agentenläufe / Mandatslaufzeit).
   * **6 Einzel-Agenten-Zeilen:** Status-Schalter (`▶️ Aktiv`, `⏸️ Pause`, `⛔ Deaktiviert`) sowie Direktbuttons `💻` (Terminal) und `📜` (Log) je Agent (`light`, `rig`, `dark`, `general`, `sarah`, `rick`).
2. **`🤝 Freigabe-Matrix` (`subTab-matrix`):**
   * **Globale Betriebsmodi:** `MANUAL` (einzelne Vorabfreigabe nötig), `DELEGATED` (Delegation über `@light` nach Matrix), `AUTO` (zeitlich/kategorisch freigegebene Routineausführung).
   * **Zeitmandate:** `Unbegrenzt`, `+60 Min`, `+180 Min`.
   * **5 schaltbare Genehmigungskategorien:** `session_presets`, `sandbox_dark_tasks`, `sandbox_lifecycle`, `content_sync`, `rig_actions`.
   * **Unveränderliche Change-Freeze-Zeile** sowie Konfigurations-Link zur Antigravity-Instanz.
3. **`📥 Anträge & Audit` (`subTab-audit`):**
   * **Antrags-Karten** für wartende Agenten-Anfragen mit direkten Touch-Aktionen: `✅ Freigeben`, `🤝 + an Light`, `❌ Ablehnen`.
   * **`audit`-Verlauf:** Chronologische Liste der letzten **30 Policy- und Mode-Umschaltungen**.
4. **`📋 Leitstand-Protokoll` (`subTab-protocol`, Live-Zähler `#ctrlGapCountBadge`):**
   * Implementiert ein **3-stufiges Drill-Down-Konzept** für sofortige Übersicht ohne Touch-Überladung (`ESC` schließt jeweils exakt eine Ebene rückwärts):

| Drill-Down-Ebene | UI-Container / Breadcrumb | Inhalte & Bedienelemente |
| :--- | :--- | :--- |
| **Ebene 0: Systemübersicht & Werkzeugkoffer** | Sub-Tab `subTab-protocol` | • **4 klickbare KPI-Karten (Filter):** `Protokoll-Aufträge`, `VerifiedSuccess`, `Tool / Kompetenz fehlt`, `Fehler / Verifikation`<br>• **Ansichts-Umschalter:** `📋 Leitstand-Protokoll` vs. `🧰 Werkzeugkoffer` (lädt alle 6 `toolbox.json`-Inventare)<br>• **Filterleiste:** `agent`, `status`, `error_code`, Volltextsuche `q`, Button `🔄 Aktualisieren`<br>• **Scrollbare Eintragsliste** aller Protokoll- und Gap-Läufe |
| **Ebene 1: Unterfenster Auftrags- & Fehlerdiagnose** | `#protoDrillBackdrop` / `#protoLevel1`<br>Breadcrumb: `← Übersicht` | • **Meta & Kette:** Ausführende Kette (`General_Sim → @light → @rig`), `hardware_node`, Freigabe-ID, Original-Prompt & Summary<br>• **2-Stufen Light-QA-Karten:** Getrennte Statusanzeige für `Stufe A Real-State` und `Stufe B Sauberer Pfad`<br>• **Vorher/Nachher-Diff-Grid:** Gegenüberstellung der gemessenen Ausgangs- und Zielwerte + Backup-Pfad<br>• **3 Drill-Down-Karten zu Ebene 2** |
| **Ebene 2: Detail-Unterfenster** | `#protoLevel2`<br>Breadcrumb: `← Übersicht › ← Auftrag › Detail` | Öffnet fokussiert je eine Detailansicht:<br>1. `🔧 Ollama-Ausbauvorschlag` (Schema, Parameter, Priming- & Risikoklassifizierungs-Vorschlag bei fehlenden Tools)<br>2. `🧰 Agenten-Werkzeugkoffer` (komplettes Tool-Inventar des beteiligten Agenten)<br>3. `📜 Roh-Evidenz & Log` (vollständige Evidenzdaten + Button `💻 Terminal öffnen`) |

---

## 6. Verifizierte E2E-Referenzläufe & Live-GPU-Praxis (Stand 25.11.2026)

Alle Kernszenarien wurden nach Deployment von Pitwall v2.1.0 und den aktualisierten Worker-Skripten end-to-end über `qwen3.5:9b` auf `SimRacer` verifiziert und im Leitstand-Protokoll registriert (`/api/leitstand/protocol?refresh=1` meldete nach Abschluss `{"total":4,"verified_success":2,"gaps":1,"errors":1}`):

### 6.1 Referenz-Matrix der 4 Test- & Produktivläufe

| Task-ID | Auslöser & Kette | Verwendetes Tool / Pfad | Laufzeit / Modellverhalten | `final_status` & `error_code` | Nachgewiesenes Ergebnis |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`e2e_hisense_inspect_20261125`** | E2E-Inspektion über `@light` → `@rig` | `inspect_display_and_nvidia` (`rig_display_tuner.py`) | **181,11s** (Kaltstart `qwen3.5:9b` in RTX 5070 Ti VRAM) | **`VerifiedSuccess`** (`NONE`) | Erkannte `DISPLAY\HECB340` `HISENSE` (Serial `1735156332`), `3840x2160 @ 60Hz`, RTX 5070 Ti Treiber `621.40`. |
| **`task_20261125_052359_3ndb`** | Live-GPU-Auftrag: `General_Sim` → `@light` (PID 45340) → `@rig` (PID 7468) | `apply_display_sharpness_profile` (`rig_display_tuner.py`) | Warmes Modell `qwen3.5:9b` + 2-Stufen-QA + DocHandoff | **`VerifiedSuccess`** (`NONE`) | Echte Registry-Optimierung auf Hisense 4K-TV (Details siehe §6.2); DocHandoff `handoff_task_20261125_052359_3ndb.json`. |
| **`e2e_missing_tool_20261125`** | E2E-Fähigkeitslücke (Fanatec-SDK-Kalibrierung) | `report_capability_gap` via Ollama-Runtime | **15,52s** (warmes `qwen3.5:9b`) | **`MissingCapability`** (`COMPETENCY_MISSING`) | Meldete fehlend: `fanatec_sdk_calibration`, `firmware_flasher`; erstellte Ausbauvorschlag `fanatec_loadcell_calibrator`. |
| **`e2e_fake_success_reject_20261125`** | Negativtest: Injizierte Dummy-Antwort `Success` | `light_verifier.py` (Stufe A & B) | **0,14s** | **`VerificationFailed`** (`VERIFICATION_FAILED`) | Schein-Erfolg ohne echte Evidenz sauber erkannt, blockiert und im Protokoll als Verifikationsfehler markiert. |

### 6.2 Live-GPU-Referenzfall: Hisense 4K-TV ClearType-Optimierung (`task_20261125_052359_3ndb`)

Im produktiven Durchlauf optimierte `@rig` (gesteuert durch `@light` und `qwen3.5:9b`) die Windows-Schrift- und Kantendarstellung für den **Hisense 4K-TV (`DISPLAY\HECB340`, `3840x2160 @ 60Hz`)** und wies jede Registry-Änderung mit Vorher/Nachher-Werten nach:

* **Registry-Backup:** `C:\ac-sandbox\shared\agents\rig\backups\display_backup_20261125_052402.json`
* **Verifizierte Vorher/Nachher-Werte:**
  * `HKCU\Control Panel\Desktop\FontSmoothingGamma`: `0` → **`1200`**
  * `HKCU\SOFTWARE\Microsoft\Avalon.Graphics\DISPLAY1\ClearTypeLevel`: `null` → **`100`**
  * `HKCU\SOFTWARE\Microsoft\Avalon.Graphics\DISPLAY1\PixelStructure`: `null` → **`1`**
* **QA & Handoff:** `light_verifier.py` bestätigte die Registry-Werte sowie die Existenz der Backup-Datei (Stufe A) und den sauberen Toolbox-Pfad (Stufe B) -> `VerifiedSuccess` (`NONE`); Paket in `general-SIM\doc_handoffs\handoff_task_20261125_052359_3ndb.json` abgelegt und durch `General SIM` in `HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md` überführt.
* **Verbleibende manuelle Hardware-/Treiber-Checkliste (TV- & NVCP-Menü):**
  * **NVIDIA Control Panel (NVCP):** Ausgabe-Farbformat **`RGB`** und dynamischer Ausgabebereich **`Voll (0–255)`** (für scharfe IDE-/Chat-/Code-Schrift in VS Code, Docker Desktop und WhatsApp).
  * **Hisense-TV-Menü:** Bildmodus **`PC / Spiel`**, TV-Schärfe auf **`0`** (verhindert Überschärfungs-Halos um Text), **HDMI-Format auf `Erweitert` (Enhanced)**.

---

## 7. Vollständige REST- & WebSocket-API-Referenz (`StrikerPi :8080`)

Alle Endpunkte laufen über FastAPI/Uvicorn in `/opt/telemetry-relay/telemetry_relay.py` auf `http://192.168.178.86:8080`.

| Methode & Pfad | Parameter / Cache | Beschreibung |
| :--- | :--- | :--- |
| `GET /` | — | Liefert die Pitwall v2.1.0 Web-UI (Single-Page Touch-Konsole inkl. `subBtn-protocol` & `protoDrillBackdrop`). |
| `GET /static/*` | — | Statische Web-Assets der Pitwall-Oberfläche. |
| `WS /ws/telemetry` | 50 Hz Push | Echtzeit-Telemetrie-Stream aus AC / `ac_telemetry_sender` an die Pitwall-UI. |
| `WS /ws/terminal/{agent}` | Path: `agent` | Interaktive WebSocket-SSH-Terminal-Session für einen spezifischen Agenten. |
| `GET /health` / `GET /api/status` | — | System-Gesundheitsstatus des Relays und der angebundenen Knoten. |
| `GET /api/mode` & `POST /api/mode` | — | Abfrage und Umschaltung des Pitwall-Betriebsmodus (z. B. `LIVE_RACE` vs. Konfigurations-/Idle-Modus). |
| `GET /api/streams` | — | Übersicht verfügbarer Video- und noVNC-Streams. |
| `GET /api/stream/simracer.jpg` | — | Aktueller Einzelbild-Snapshot vom `SimRacer`. |
| `GET /api/stream/simracer.mjpeg` | — | Kontinuierlicher MJPEG-Videostream vom `SimRacer`. |
| `POST /api/stream/camera` | — | Umschaltung der aktiven Kameraquelle im Video-Streaming-Modul. |
| `GET /api/sandbox/status` | — | Statusabfrage der Docker/Win11-Sandbox `ac-win11-sandbox` auf `SimRacer`. |
| `POST /api/sandbox/start` | — | Startet `ac-win11-sandbox`. |
| `POST /api/sandbox/stop` | — | Stoppt `ac-win11-sandbox`. |
| `POST /api/sandbox/pause` | — | Pausiert `ac-win11-sandbox`. |
| `POST /api/sandbox/resume` | — | Setzt `ac-win11-sandbox` fort. |
| `POST /api/sandbox/ac/action` | — | Führt vordefinierte Assetto-Corsa-/Content-Aktionen in der Sandbox aus. |
| `GET /api/approvals/state` | — | Liefert aktuellen Policy-Zustand, Agenten-Status, Zeitmandat, ausstehende Anträge und die letzten 30 Audit-Einträge. |
| `POST /api/approvals/policy` | — | Aktualisiert Freigabe-Matrix (`MANUAL`/`DELEGATED`/`AUTO`), Zeitmandat, Kategorien, Einzel-Agenten-Status oder GPU-Freigabe. |
| `POST /api/approvals/decide` | — | Entscheidet über einen ausstehenden Antrag (`✅ Freigeben`, `🤝 + an Light`, `❌ Ablehnen`). |
| `GET /api/leitstand/protocol` | Query: `agent`, `status`, `error_code`, `q`, `limit`, `refresh`; **8s TTL-Cache** | Liefert aggregierte KPI-Zähler (`total`, `verified_success`, `gaps`, `errors`), gefilterte Protokoll-Einträge und `capability_gaps` für Ebene 0 & 1. |
| `GET /api/leitstand/protocol/{task_id}` | Path: `task_id` | Liefert das vollständige Diagnose- und Detailobjekt (QA Stufe A/B, Diff, Ausbauvorschlag, Evidenz) für Ebene 1 & 2. |
| `GET /api/leitstand/toolboxes` | **15s TTL-Cache** | Liefert alle 6 geladenen `toolbox.json`-Werkzeugkoffer aus `shared/memories/` für die Werkzeugkoffer-Ansicht und Ebene 2. |
| `GET /api/logs/history` | — | Historische Agenten-Logs mit Hardware-Knoten-Zuordnung. |
| `GET /api/logs/task/{agent}/{task_id}` | Path: `agent`, `task_id` | Detail-Log eines spezifischen Tasks eines Agenten (Ebene 2 `Roh-Evidenz & Log`). |
| `POST /api/voice/dispatch` | — | Endpunkt des einklappbaren Sprachchat-Overlays für Sprachkommandos. |
| `POST /api/pitwall/archibald` | — | Kiosk-, Display- und Steuerbefehle an `Archibald` (`192.168.178.98`). |
