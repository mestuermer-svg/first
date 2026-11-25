# System- & Architektur-Update: Multi-Workspace & Agent-Infrastruktur

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (05 Agents)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 05 Agents](./README.md) · **Vorheriges:** [⬅️ Stand 23.11. (ToS-Bereinigung, Ollama & Pitwall v1.5)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md) · **Nächstes:** [Pitwall & Systemreferenz (NotebookLM-Quelle) ➡️](./PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md)

**Alle Module in `05_Agents/`:**
- [01 • Agent-Stilfibel, Didaktik-Ruler & 7-Stufen-Aufbau](./01_agent-stilfibel-und-didaktik-ruler.md)
- [02 • Agenten erstellen: Instructions, Rules & Prompts](./02_agenten-erstellen-instructions-rules-und-prompts.md) · `gemini.instructions`
- [03 • Agenten ausrüsten: Skills & MCP-Tools](./03_agenten-ausruesten-skills-und-mcp-tools.md) · `SKILL.md`
- [04 • Priming, Memory & Multi-Agent-Orchestrierung](./04_agenten-trainieren-primen-und-orchestrieren.md) · `@light`
- [05 • Schnittstelle, Terminals & XOR-Mutex](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md) · `Bridge`
- [06 • Multi-Workspace Netzwerk & 6-Rollen-Verbund](./05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md)
- [Letztstand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md)
- [Praxis-Referenz 25.11. (Hisense 4K-TV & ClearType)](./HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md)
- [Stand 24.11. (Parity, Qwen 3.5 & Nacharbeiten)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md)
- [Stand 23.11. (ToS-Bereinigung, Ollama & Pitwall v1.5)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md)
- 👉 **[Änderungsprotokoll 11.11. (MQTT, Gatekeeper & Caddy)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md)** *(aktuell)*
- [Pitwall & Systemreferenz (NotebookLM-Quelle)](./PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md)
- [Boxencrew & Teamchef Konzept (NotebookLM)](./PITWALL_BOXENCREW_TEAMCHEF_KONZEPT_NOTEBOOKLM.md)

**Weitere Rubriken:** [🐧 01 Linux & Bash](../01_Linux_Bash/README.md) · [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🐍 03 Python](../03_Python_Coding/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

**Datum:** 11. November 2026  
**Zielgruppe:** General Cyborg (`VanstrikeCyborg`), General Sim (`SimRacer`), Sub-Agenten (`@rig`, `@light`, `@dark`, `@sarah`, `@rick`)  
**Autor:** Mike / VanstrikeCyborg & Antigravity  

---

<details>
<summary><b>1. Management Summary & Kernanpassungen</b></summary>

Seit dem Brainstorming wurde das Gesamtsystem von einer fehleranfälligen SMB-/Datei-Polling-Struktur auf ein robustes, echtzeitfähiges Multi-Workspace- und MQTT-Netzwerk umgestellt:
1. **Multi-Workspace-Rollen:**
   - `git-labor` (Laptop `VanstrikeCyborg`): Reiner Management- & Orchestrierungs-Workspace. Aufgaben werden ohne Workspace-Cross-Dependencies via direkte SSH-Profile ausgeführt.
   - `assetto-corsa-content` (Host `SimRacer`): Dedizierter Simulations- und Content-Workspace mit lokalen Konsolen und nativer Assetto Corsa Pipeline.
2. **Echtzeit-Eventing via MQTT (StrikerPi):**
   - StrikerPi (`192.168.178.86:1883`) fungiert als zentraler 24/7 Mosquitto Message Broker.
   - Datei-Handshakes (`*.request`, `*.in_progress`, `*.complete`) werden durch MQTT-Topics (`sim/tasks/...`, `sim/telemetry/...`) abgelöst bzw. ergänzt.
3. **Zwei-Stufen-Gatekeeper für General Sim:**
   - Umschaltbar zwischen `AUTO` (sofortige Freigabe für CI/CD und autonome Ketten) und `MANUAL` (strikte Bestätigung am Leitstand).
4. **Archibald Pitwall & Screensaver:**
   - Bereinigung des Telemetrie-Status (keine Falschanzeige mehr als "Live auf Strecke", wenn AC in Box oder Standby ist).
   - Dynamische Bildschirmschoner-Aktivierung auf dem omARCHy-System bei Leerlauf.

</details>

---

<details>
<summary><b>2. Detaillierte Komponenten-Änderungen</b></summary>

### A. Laptop `VanstrikeCyborg` (`git-labor`)
- **[`git-labor.code-workspace`](file:///c:/Users/strik/git-labor/git-labor.code-workspace):**
  - Entfernung von `folderOpen`-Autostart-Tasks (keine Abstürze oder hängenden Terminals mehr beim Workspace-Öffnen).
  - 6 neue SSH-Terminal-Profile im VS Code Dropdown: `@rig`, `@light`, `@dark`, `@sarah`, `@rick`, `@general`.
  - Task-Redirect: Alle Remote-Befehle laufen direkt über SSH anstelle lokaler Abhängigkeiten.
- **[`labs/Agent-Terminals.ps1`](file:///c:/Users/strik/git-labor/labs/Agent-Terminals.ps1):**
  - Autarkisiert: Funktioniert eigenständig ohne externe relative Pfadbindung.
  - `-StatusOnly`-Modus prüft alle 6 Agenten-Endpunkte blitzschnell über Port-Sockets.
- **[`labs/Send-SimAgentTask.ps1`](file:///c:/Users/strik/git-labor/labs/Send-SimAgentTask.ps1):**
  - Neuer Parameter `-SetApprovalMode <AUTO|MANUAL>` zur direkten Fernsteuerung der General-Sim-Freigabepolicy.
  - Integration von MQTT-Publikationstests.
- **[`labs/03_python/sim_agent_bridge.py`](file:///c:/Users/strik/git-labor/labs/03_python/sim_agent_bridge.py):**
  - Erweiterung um `get_approval_policy()` und `set_approval_policy()`.
  - Direkte MQTT-Publish- und Subscribe-Methoden via `paho-mqtt` an `192.168.178.86:1883`.

### B. SimRacer Host (`192.168.178.68`)
- **SSH-Konfiguration (`C:\Users\Mike\.ssh\config`):**
  - Eintrag für `Host strikerpi` (`HostName 192.168.178.86`, `User root`, `IdentityFile C:/Users/Mike/.ssh/id_ed25519`) hinterlegt.
  - Remote-SCP und SSH-Push zu Archibald und StrikerPi laufen jetzt schlüssellos und fehlerfrei.
- **General Sim Gatekeeper:**
  - Konfigurationsdatei `shared/agents/general-SIM/approval_policy.json` mit Statusflag `{"mode": "AUTO", "auto_approve": true}`.
  - `start_general_terminal.ps1` wertet die Policy dynamisch aus.

### C. StrikerPi (`192.168.178.86`) & Archibald (`192.168.178.98`)
- **Mosquitto MQTT Broker (`192.168.178.86:1883`):**
  - 24/7 aktiv im LAN für alle Agenten und Telemetrie-Feeds.
- **Telemetrie-Relay (`telemetry_relay.py` auf StrikerPi):**
  - Zustandslogik korrigiert: Status `2` (AC Live) wird nur noch gesetzt, wenn tatsächlich Drehzahl und Geschwindigkeit anliegen (`rpm > 0`, `speed > 3.0 km/h`).
  - Im Stillstand oder in der Box wird verlässlich `PITBOX_SETUP` / `Box / Standby` signalisiert.
- **Archibald omARCHy Pitwall:**
  - Sarah Pitwall Foot-Konsole und Chromium Dashboard laufen im Kiosk-Modus via `systemd --user`.
  - Screensaver-Logik: Sobald weder auf dem SimRacer noch in der Sandbox ein aktives Rennen läuft, wird `stay-awake` freigegeben bzw. der Bildschirmschoner gestartet.

</details>

---

<details>
<summary><b>3. Handlungsanweisungen für General Cyborg & General Sim</b></summary>

1. **General Cyborg (`VanstrikeCyborg`):**
   - Nutze für Statusabfragen bevorzugt `labs/Agent-Terminals.ps1 -StatusOnly` oder `sim_agent_bridge.py`.
   - Schicke Steuerbefehle an General Sim via `labs/Send-SimAgentTask.ps1 -Agent general -Action ...`.
   - Bei CI/CD-Pipelines: Setze die Policy auf `AUTO` (`-SetApprovalMode AUTO`).

2. **General Sim (`SimRacer`):**
   - Prüfe vor kritischen Aktionen die lokale `approval_policy.json`.
   - Empfange Aufgaben vorrangig über MQTT Topic `sim/tasks/general` oder die File-Inboxes.
   - Sende Ergebnisse zurück an `sim/status/general` oder via SSH direkt an StrikerPi/Archibald.

</details>

---

<details>
<summary><b>4. Strategische Weiterentwicklung & Roadmap: Web-Terminals via Caddy (StrikerPi)</b></summary>

### Zielarchitektur: Auslagerung der Terminal-Schnittstellen
Als nächster architektonischer Evolutionsschritt ist vorgesehen, die lokalen Konsolen und CLI-Terminals der Agenten schrittweise abzulösen und auf eine plattformunabhängige Web-Architektur zu migrieren:

1. **Hosting via Caddy Webserver auf dem StrikerPi:**
   - Der Webserver **Caddy** auf dem StrikerPi (`192.168.178.86`) wird als zentraler Host für schlanke, reaktive Web-Frontends (HTML5, CSS3, modernes JavaScript/TypeScript) eingesetzt.
   - **Lern- & Wissens-Server für `git-labor`:** StrikerPi dient zusätzlich als LAN-weiter Webserver-Host für die Lernskripte, interaktiven Doku-Seiten und Web-Labs aus `git-labor` (z. B. HTML/CSS/DOM-Demos, Python-Notebook-Exports, Visualisierungen). So können Lerninhalte und Doku von allen Clients im Heimnetzwerk ohne lokalen Build-Server abgerufen werden.
   - Sichere Bereitstellung im lokalen Netz ohne zusätzliche Laufzeit-Overheads.

2. **Webbasierte Agenten- & Terminal-UIs:**
   - Bereitstellung interaktiver Web-Terminals / Dashboards (z. B. xterm.js oder WebSocket-gestützte Streaming-Konsolen).
   - Anbindung der Web-Frontends an den lokalen **Mosquitto MQTT Broker** (über WebSockets auf Port `9001`) und an Backend-APIs.
   - Voller bidirektionaler Zugriff auf alle Sub-Agenten (`@rig`, `@light`, `@dark`, `@sarah`, `@rick`, `@general`).

3. **Multi-Device-Verfügbarkeit im LAN:**
   - Von StrikerPi aus können die Schnittstellen responsiv auf jedem Endgerät im Netzwerk bedient und angezeigt werden:
     - **Laptop `VanstrikeCyborg`:** Im Browser oder eingebetteten Webview als Leitstand.
     - **Archibald (IdeaPad):** Direkt im Chromium-Kioskmodus (neben oder als Umschaltung zur Pitwall).
     - **SimRacer / Tablets / Handys:** Schneller mobiler Zugriff auf Logs, Genehmigungs-Gates (`AUTO`/`MANUAL`) und Agenten-Status ohne offene SSH-Fenster.

</details>

---
<details>
<summary><b>5. Abgleich mit dem Ist-Stand (verifiziert am 11.11.2026)</b></summary>

Die Aussagen dieses Dokuments wurden gegen Workspace-Dateien, Skripte, die Policy-Datei auf dem SimRacer und die Dienste auf StrikerPi (nur lesend) geprüft:

| Aussage | Befund | Status |
| :--- | :--- | :--- |
| `folderOpen`-Autostart entfernt | `git-labor.code-workspace` enthält keinen `folderOpen`-Eintrag | ✅ bestätigt |
| 6 SSH-Terminalprofile | Vorhanden sind **5** SSH-Profile (`@rig`, `@light`, `@dark`, `@sarah`, `@rick`) plus `PowerShell (Git-Labor)`. `@general` läuft lokal (Task `Terminal: @general`), nicht als SSH-Profil. `@rig` und `@light` nutzen beide den SSH-Host `simracer`. | ⚠️ abweichend |
| `Agent-Terminals.ps1 -StatusOnly` mit Port-Sockets | Vorhanden (`Test-TcpPortFast`, Parameter `-StatusOnly`) | ✅ bestätigt |
| `Send-SimAgentTask.ps1 -SetApprovalMode <AUTO\|MANUAL>` | Vorhanden, schreibt `general-SIM\approval_policy.json`. Ein MQTT-Publikationstest ist im Skript **nicht** enthalten. | ⚠️ teilweise |
| `sim_agent_bridge.py`: `get_/set_approval_policy()` | Vorhanden | ✅ bestätigt |
| MQTT via `paho-mqtt`, Topics `sim/tasks/...` | Die Bridge nutzt **kein** `paho-mqtt`. `publish_mqtt_task()` ruft per SSH `mosquitto_pub` auf StrikerPi auf, Topic `agents/<agent>/inbox`. Echte Topics im Relay: `simrig/mode`, `simrig/telemetry`. | ⚠️ abweichend |
| `approval_policy.json` mit `{"mode": "AUTO", "auto_approve": true}` | Datei existiert, Felder: `mode`, `description`, `updated_at`. Ein Feld `auto_approve` gibt es nicht. Aktueller Wert: `AUTO` (Stand 11.11.2026 09:00). | ⚠️ Feldname abweichend |
| Relay-Zustandslogik (Status `2` nur bei Bewegung) | **Deployt auf StrikerPi:** `live_on_track` bei `(ac_status == 2 und rpm > 0)` oder `(speed > 3.0 und rpm > 500)`. Die Arbeitskopie `C:\Users\strik\strikerpi-hub\telemetry-relay\telemetry_relay.py` war zuerst im Rueckstand (bedingungsloses `live_on_track`). Sie wurde am 11.11.2026 vom Pi uebernommen, SHA-256 identisch (`1B2F9044…`). Sie wurde als Commit `7db7657` nach `simrig.git` (`origin/main`) gepusht. | ✅ angeglichen & committet |
| Mosquitto 24/7 (`1883`/`9001`) | `mosquitto`, `telemetry-relay`, `rick-agent` aktiv, Ports `1883`, `9001`, `8080` lauschen | ✅ bestätigt |
| Caddy auf StrikerPi (Roadmap) | **Umgesetzt am 12.11.2026:** `caddy.service` (`:80`, `/etc/caddy/conf.d/git-labor.caddy`, Webroot `/srv/git-labor/web`), `gitlabor-api.service` (`127.0.0.1:8085`, `node v26.13.0`), `tsc 7.0.2` und `/mqtt*` $\rightarrow$ `127.0.0.1:9001` aktiv und verifiziert. | ✅ umgesetzt &amp; verifiziert |

> [!NOTE]
> **Offene Punkte aus dem Abgleich:** (1) Relay-Kopie ist erledigt (Commit `7db7657` in `simrig.git`). (2) Topic-Schema für Task-Events festlegen. Zurzeit gilt `agents/<agent>/inbox`, im Konzept stand `sim/tasks/...`. (3) Entscheiden, ob ein `@general`-SSH-Profil nötig ist. (4) Caddy + Node.js-API + TypeScript-Lab-Hosting sind am 12.11.2026 produktiv geschaltet worden (siehe Abschnitt 7).

</details>

---

<details>
<summary><b>6. Betriebsnachweis aus den Systemtests (Snapshot 11.11.2026 07:18)</b></summary>

**Datenbasis:** `Systemtests/Systemchecks_Doku_Logs_2026-11-11` und `..._0718` sind inhaltlich identisch (93 Dateien, Hash-Vergleich ohne Abweichung). Struktur: `01_Dokumentation`, `02_Logs`, `03_Status_und_Outbox`, `04_Check_Skripte`.

| Bereich | Nachweis aus Logs & Status |
| :--- | :--- |
| **Dark-Gast** | `dark-status.json` (11.11. 00:37): CSP `0.2.11.0` aktiv, `host_lan_data_ok: true`, `C:` 75,17 von 159,75 GB frei, Content Manager läuft, `acs.exe` aus |
| **Dark-Aktionen (Log 11.11.)** | `SetSession` (`gp_2025_mcl39` / `monza`), `ValidateSetups` (**203 Setup-Dateien** syntaktisch valide), `LaunchCM`/`StopCM`, `ApplyPreset desktop_4k` (Video-, CSP-Preset und `video.ini` auf `MODE=DEFAULT`) |
| **Handshakes (10.11.)** | Testketten General→Light→Dark, Rig→Light, Dark→Light, Dark→Rig und General→Dark direkt: alle `Success` |
| **Freigabe-Gate** | Vier Rückfragen (`req_light_…222241`, `…222600`, `…003400`, `req_rig_…222744`) wurden mit `Approved` beantwortet. Seit 11.11. 09:00 steht die Policy auf `AUTO`. |
| **Pitwall-Probes** | Mehrere `Status`-Aufträge `StrikerPi Pitwall` → `@dark` am 11.11. zwischen 01:30 und 01:35, `pitwall_1794357228032` und `…316259` mit `Success` beantwortet |
| **Sarah** | `task_video_editor_onboarding` (06:54) und `task_2saeulen_video_strategie` (07:09) sind `Queued`. Im Snapshot liegt dazu **keine Rückmeldung** vor. |
| **Light-Prompt (11.11. 00:34)** | „Programm zum Öffnen der Agent-Logs installieren“ wurde freigegeben und mit `Success` quittiert. Das Light-Log zeigt nur die Intent-Prüfung, **keinen Installationsnachweis**. |

**Vergleich Snapshot ↔ Repo-Doku:** Alle 7 `assetto-corsa-content`-Dokus und `05_workspace-schnittstelle-…` sind byte-identisch. Abweichend: `README.md` von `assetto-corsa-content` (Repo 12.985 B, Snapshot 11.718 B, das Repo ist neuer). `05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md` fehlte im Repo und wurde aus dem Snapshot nach `Doku/05_Agents/` übernommen.

</details>

---

<details>
<summary><b>7. Nachtrag 12.11.2026: Caddy, Node.js-API, TypeScript-Labs &amp; Pitwall-Display</b></summary>

1. **Archibald (`192.168.178.98`) &amp; StrikerPi Pitwall Hub (`:8080`):**
   - Auf Archibald wurden der laufende Screensaver (`org.omarchy.screensaver`) beendet, `omarchy-toggle-idle stay-awake` sowie `omarchy-toggle screensaver-off on` aktiviert und `~/.config/hypr/hyprland.lua` um `idle_inhibit = "always"` ergänzt.
   - `telemetry_relay.py` (`:8080`) öffnet das Bildschirm-Panel standardmäßig beim Start (`lobbyOpen = true`, `manualForceWatch = true`), zeigt ohne aktive Fahrt/Sandbox direkt den **SimRacer-Desktop (`/api/stream/simracer.mjpeg`)** und schaltet automatisch auf **Sandbox noVNC (`:8006`)** bzw. **SimRacer Live-Fahrt** um.

2. **Caddy-Webserver (`:80`), Node.js-API (`:8085`) &amp; TypeScript-Toolchain über `@rick`:**
   - Auf StrikerPi wurden **`nodejs v26.13.0`**, **`npm 12.2.2`** und **`typescript (tsc) 7.0.2`** installiert.
   - `rick_worker.py` (inkl. UTF-8-BOM-Fix `utf-8-sig`) und `start_rick_terminal.sh` (gespiegelt unter [`labs/01_linux_bash/strikerpi-services/`](../../labs/01_linux_bash/strikerpi-services/)) wurden um `setup_caddy_gitlabor`, `caddy_validate`, `caddy_reload`, `caddy_status`, `build_ts_labs` und `restart_gitlabor_api` erweitert.
   - `/etc/caddy/Caddyfile` + `/etc/caddy/conf.d/git-labor.caddy`: Statischer Webroot `/srv/git-labor/web`, Reverse Proxy `/api/linux/*` $\rightarrow$ `127.0.0.1:8085`, `/mqtt*` $\rightarrow$ `127.0.0.1:9001`, JSON-Access-Log unter `/var/log/caddy/gitlabor-access.log`.
   - Gehärteter Systemd-Dienst `gitlabor-api.service` (`/srv/git-labor/apps/linux-monitor-api/gitlabor-api.mjs`, `NoNewPrivileges=true`, `PrivateTmp=true`, `ProtectHome=true`, `ProtectSystem=strict`) liefert `/api/linux/health`, `/status`, `/ports`, `/logs` und `POST /echo`.
   - Live-Deployment-Pipeline vom Laptop: [`labs/04_js_ts_web/Deploy-ToStrikerPi.ps1`](../../labs/04_js_ts_web/Deploy-ToStrikerPi.ps1) überträgt [`labs/04_js_ts_web/index.html`](../../labs/04_js_ts_web/index.html), `rechner.html` und [`ts-linux-lab/`](../../labs/04_js_ts_web/ts-linux-lab/) und triggert per `@rick` Remote-Kompilierung (`tsc -p .`) + `caddy_reload`.

</details>

---
*Dokumentation abgelegt unter `Doku/05_Agents/` zur Referenz für anstehende VR- und Telemetrietests.*

<!-- DOKU-MINIMAP-START -->
<style>
.doku-arch-flow { font-family: var(--vscode-editor-font-family, Consolas, monospace); background: linear-gradient(160deg, rgba(15, 23, 42, 0.96), rgba(17, 24, 39, 0.94)); border: 1px solid rgba(96, 165, 250, 0.35); border-radius: 12px; padding: 14px 16px; margin: 8px 0 0 0; color: #e2e8f0; }
.doku-arch-root { display: flex; flex-wrap: wrap; align-items: center; justify-content: center; gap: 10px; font-weight: 700; font-size: 0.98em; padding: 9px 14px; margin-bottom: 12px; background: linear-gradient(135deg, rgba(37, 99, 235, 0.28), rgba(30, 41, 59, 0.92)); border: 1px solid rgba(96, 165, 250, 0.48); border-radius: 10px; }
.doku-arch-root a { color: #93c5fd !important; text-decoration: none !important; }
.doku-arch-root a:hover { color: #dbeafe !important; text-decoration: underline !important; }
.doku-arch-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(268px, 1fr)); gap: 11px; }
.doku-arch-card { background: rgba(30, 41, 59, 0.72); border: 1px solid rgba(148, 163, 184, 0.24); border-top: 3px solid #3b82f6; border-left: 4px solid #3b82f6; border-radius: 10px; padding: 10px 12px; transition: transform 0.14s ease, border-color 0.14s ease, box-shadow 0.14s ease; }
.doku-arch-card:hover { border-color: #93c5fd; transform: translateY(-2px); box-shadow: 0 6px 18px rgba(0, 0, 0, 0.35); }
.doku-arch-card.r1 { border-left-color: #22c55e; border-top-color: #22c55e; }
.doku-arch-card.r2 { border-left-color: #3b82f6; border-top-color: #3b82f6; }
.doku-arch-card.r3 { border-left-color: #eab308; border-top-color: #eab308; }
.doku-arch-card.r4 { border-left-color: #ec4899; border-top-color: #ec4899; }
.doku-arch-card.r5 { border-left-color: #a855f7; border-top-color: #a855f7; }
.doku-arch-card-title { font-weight: 700; font-size: 0.93em; margin-bottom: 7px; padding-bottom: 5px; border-bottom: 1px dashed rgba(148, 163, 184, 0.26); }
.doku-arch-card-title a { color: #f8fafc !important; text-decoration: none !important; display: block; }
.doku-arch-card-title a:hover { color: #93c5fd !important; }
.doku-arch-lines { list-style: none; margin: 0; padding: 0; font-size: 0.84em; line-height: 1.5; }
.doku-arch-lines li { margin: 3px 0; padding: 2px 6px; border-radius: 5px; white-space: normal; }
.doku-arch-lines li:hover { background: rgba(59, 130, 246, 0.16); }
.doku-arch-lines a { color: #cbd5e1 !important; text-decoration: none !important; display: inline; }
.doku-arch-lines a:hover { color: #93c5fd !important; text-decoration: underline !important; }
.doku-arch-badge { display: inline-block; font-size: 0.74em; padding: 0 6px; margin-left: 5px; border-radius: 999px; background: rgba(59, 130, 246, 0.22); color: #bfdbfe !important; border: 1px solid rgba(96, 165, 250, 0.4); }
details.doku-minimap { position: fixed; bottom: 18px; right: 18px; z-index: 9999; width: 292px; max-height: 76px; overflow: hidden; background: rgba(15, 23, 42, 0.93); border: 1px solid rgba(96, 165, 250, 0.62); border-radius: 14px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.65); backdrop-filter: blur(10px); transition: width 0.18s ease, max-height 0.18s ease, border-color 0.18s ease; font-family: var(--vscode-font-family, sans-serif); }
details.doku-minimap:hover { border-color: #93c5fd; }
details.doku-minimap[open] { width: min(920px, 94vw); max-height: 84vh; overflow-y: auto; padding-bottom: 10px; border-radius: 14px; }
details.doku-minimap > summary { cursor: pointer; list-style: none; padding: 8px 13px; font-weight: 700; font-size: 0.84em; color: #f8fafc; background: linear-gradient(90deg, rgba(37, 99, 235, 0.45), rgba(30, 41, 59, 0.92)); border-bottom: 1px solid rgba(148, 163, 184, 0.24); display: flex; align-items: center; justify-content: space-between; user-select: none; }
details.doku-minimap > summary::-webkit-details-marker { display: none; }
details.doku-minimap > summary .minimap-toggle::after { content: "+"; font-size: 1.05em; opacity: 0.85; padding: 0 4px; }
details.doku-minimap[open] > summary .minimap-toggle::after { content: "−"; }
details.doku-minimap .minimap-preview-strip { display: flex; gap: 5px; padding: 6px 10px 8px 10px; font-size: 0.71em; color: #cbd5e1; justify-content: space-between; }
details.doku-minimap[open] .minimap-preview-strip { display: none; }
details.doku-minimap .minimap-preview-strip span { display: inline-flex; align-items: center; gap: 4px; background: rgba(30, 41, 59, 0.92); padding: 2px 7px; border-radius: 999px; border: 1px solid rgba(148, 163, 184, 0.26); }
details.doku-minimap .dot { width: 6px; height: 6px; border-radius: 50%; display: inline-block; }
details.doku-minimap .dot.r1 { background: #22c55e; }
details.doku-minimap .dot.r2 { background: #3b82f6; }
details.doku-minimap .dot.r3 { background: #eab308; }
details.doku-minimap .dot.r4 { background: #ec4899; }
details.doku-minimap .dot.r5 { background: #a855f7; }
details.doku-minimap .minimap-body { padding: 4px 12px 6px 12px; }
</style>
<details class="doku-minimap">
<summary><span>🗺️ Doku-Minimap (5 Rubriken &amp; Labs)</span><span class="minimap-toggle" title="Klicken zum Vergrößern / Einklappen"></span></summary>
<div class="minimap-preview-strip"><span><i class="dot r1"></i>Linux</span><span><i class="dot r2"></i>VSCode</span><span><i class="dot r3"></i>Python</span><span><i class="dot r4"></i>JS/TS</span><span><i class="dot r5"></i>Agents</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root"><span>🏛️ <a href="../README.md">VanstrikeCyborg — git-labor Doku-Index</a></span> · <a href="../../README.md">Repo-README</a> · <a href="../../AGENTS.md">AGENTS.md</a> · <a href="../../notebook-agent-environments/README.md">Notebooks</a> · <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md">Letztstand 25.11. (v5)</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🐧 <a href="../01_Linux_Bash/README.md">01_Linux_Bash (Linux, Shell & Container)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 • Bash CLI, Text-Tools, Streams & Expansions</a> <a class="doku-arch-badge" href="../../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="../01_Linux_Bash/02_linux-systemadministration-und-interna.md">02 • Inodes, LVM, Prozesse, Boot-Prozess & systemd</a></li>
<li>├─ <a href="../01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">03 • Arch Linux, Omarchy, Remote-SSH & Nginx</a></li>
<li>├─ <a href="../01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">04 • Advanced Bash: Arrays, getopts & Backups</a></li>
<li>└─ <a href="../01_Linux_Bash/05_docker-und-sbx-micro-vms.md">05 • Docker Grundlagen & Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="../02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP & Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) & Remote</a></li>
<li>├─ <a href="../02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow & Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="../02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Ollama (:11434) & Ports (Archiv: Proxy)</a> <a class="doku-arch-badge" href="../../.vscode/mcp.json">mcp.json</a></li>
<li>├─ <a href="../02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio & API-Keys</a></li>
<li>└─ <a href="../02_VSCode_Env/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">05 • 5-Knoten-Verbund, Parity & Parallel-Limits</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="../03_Python_Coding/README.md">03_Python_Coding (Python, uv & GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance & Notebooks</a> <a class="doku-arch-badge" href="../../notebook-agent-environments/agent_demo.ipynb">.ipynb</a></li>
<li>├─ <a href="../03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">02 • Google GenAI SDK (google-genai) & Interactions API</a></li>
<li>└─ <a href="../03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md">03 • Automatisierung, Datenanalyse & pytest</a> <a class="doku-arch-badge" href="../../labs/03_python/sensor_demo.py">sensor_demo.py</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">🌐 <a href="../04_JS_TS_Web/README.md">04_JS_TS_Web (HTML/CSS, JS/TS & Web-SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">01 • HTML5, CSS3 & DOM-Manipulation Grundlagen</a> <a class="doku-arch-badge" href="../../labs/04_js_ts_web/rechner.html">rechner.html</a></li>
<li>├─ <a href="../04_JS_TS_Web/02_modernes-javascript-und-typescript.md">02 • Modernes JavaScript (ES6+) & TypeScript</a></li>
<li>└─ <a href="../04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">03 • Google GenAI SDK (@google/genai) für Web-Apps</a></li>
</ul>
</div>
<div class="doku-arch-card r5">
<div class="doku-arch-card-title">🤖 <a href="../05_Agents/README.md">05_Agents (KI-Agenten, Skills & Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">01 • Agent-Stilfibel, Didaktik-Ruler & 7-Stufen-Aufbau</a></li>
<li>├─ <a href="../05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">02 • Agenten erstellen: Instructions, Rules & Prompts</a> <a class="doku-arch-badge" href="../../.github/instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>├─ <a href="../05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills & MCP-Tools</a> <a class="doku-arch-badge" href="../../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>├─ <a href="../05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Priming, Memory & Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../../.github/agents/light.agent.md">@light</a></li>
<li>├─ <a href="../05_Agents/05_workspace-schnittstelle-simracer-und-agenten-terminals.md">05 • Schnittstelle, Terminals & XOR-Mutex</a> <a class="doku-arch-badge" href="../../labs/03_python/sim_agent_bridge.py">Bridge</a></li>
<li>├─ <a href="../05_Agents/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">06 • Multi-Workspace Netzwerk & 6-Rollen-Verbund</a></li>
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md">Letztstand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)</a></li>
<li>├─ <a href="../05_Agents/HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md">Praxis-Referenz 25.11. (Hisense 4K-TV & ClearType)</a></li>
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md">Stand 24.11. (Parity, Qwen 3.5 & Nacharbeiten)</a></li>
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md">Stand 23.11. (ToS-Bereinigung, Ollama & Pitwall v1.5)</a></li>
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md">Änderungsprotokoll 11.11. (MQTT, Gatekeeper & Caddy)</a></li>
<li>├─ <a href="../05_Agents/PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md">Pitwall & Systemreferenz (NotebookLM-Quelle)</a></li>
<li>└─ <a href="../05_Agents/PITWALL_BOXENCREW_TEAMCHEF_KONZEPT_NOTEBOOKLM.md">Boxencrew & Teamchef Konzept (NotebookLM)</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
