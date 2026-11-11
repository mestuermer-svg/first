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
*Dokumentation abgelegt unter `Doku/05_Agents/` zur Referenz für anstehende VR- und Telemetrietests.*
