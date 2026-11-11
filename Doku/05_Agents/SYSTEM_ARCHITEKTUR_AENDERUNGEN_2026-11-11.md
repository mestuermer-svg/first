# System- & Architektur-Update: Multi-Workspace & Agent-Infrastruktur

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
  - Konfigurationsdatei `shared/agents/general/approval_policy.json` mit Statusflag `{"mode": "AUTO", "auto_approve": true}`.
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
| `Send-SimAgentTask.ps1 -SetApprovalMode <AUTO\|MANUAL>` | Vorhanden, schreibt `general\approval_policy.json`. Ein MQTT-Publikationstest ist im Skript **nicht** enthalten. | ⚠️ teilweise |
| `sim_agent_bridge.py`: `get_/set_approval_policy()` | Vorhanden | ✅ bestätigt |
| MQTT via `paho-mqtt`, Topics `sim/tasks/...` | Die Bridge nutzt **kein** `paho-mqtt`. `publish_mqtt_task()` ruft per SSH `mosquitto_pub` auf StrikerPi auf, Topic `agents/<agent>/inbox`. Echte Topics im Relay: `simrig/mode`, `simrig/telemetry`. | ⚠️ abweichend |
| `approval_policy.json` mit `{"mode": "AUTO", "auto_approve": true}` | Datei existiert, Felder: `mode`, `description`, `updated_at`. Ein Feld `auto_approve` gibt es nicht. Aktueller Wert: `AUTO` (Stand 11.11.2026 09:00). | ⚠️ Feldname abweichend |
| Relay-Zustandslogik (Status `2` nur bei Bewegung) | **Deployt auf StrikerPi:** `live_on_track` bei `(ac_status == 2 und rpm > 0)` oder `(speed > 3.0 und rpm > 500)`. Die Arbeitskopie `C:\Users\strik\strikerpi-hub\telemetry-relay\telemetry_relay.py` war zuerst im Rueckstand (bedingungsloses `live_on_track`). Sie wurde am 11.11.2026 vom Pi uebernommen, SHA-256 identisch (`1B2F9044…`). Sie wurde als Commit `7db7657` nach `simrig.git` (`origin/main`) gepusht. | ✅ angeglichen & committet |
| Mosquitto 24/7 (`1883`/`9001`) | `mosquitto`, `telemetry-relay`, `rick-agent` aktiv, Ports `1883`, `9001`, `8080` lauschen | ✅ bestätigt |
| Caddy auf StrikerPi (Roadmap) | Binary `/usr/bin/caddy` vorhanden. Dienststatus, Webroot und Routing wurden nicht geprüft. | 🔜 offen |

> [!NOTE]
> **Offene Punkte aus dem Abgleich:** (1) Relay-Kopie ist erledigt (Commit `7db7657` in `simrig.git`). (2) Topic-Schema für Task-Events festlegen. Zurzeit gilt `agents/<agent>/inbox`, im Konzept stand `sim/tasks/...`. (3) Entscheiden, ob ein `@general`-SSH-Profil nötig ist.

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
*Dokumentation abgelegt unter `Doku/05_Agents/` zur Referenz für anstehende VR- und Telemetrietests.*
