# Technische Systemquelle: StrikerPi & Archibald Pitwall-Steuerungskonsole (v1.5.0 – Stand 23.11.2026)

> **Systemknoten:** `StrikerPi` (`192.168.178.86:8080`, Backend `telemetry_relay.py`), `Archibald` (`192.168.178.98`, IdeaPad 5 Linux Omarchy Touch-Kiosk), `SimRacer` (`192.168.178.68`, RTX 5070 Ti + Win11 Sandbox `ac-win11-sandbox`), `VanstrikeCyborg` (Host-Laptop RTX 5060, Leitstand `General Sim` & `General Cyborg`).  
> **Zweck:** Zentrale Echtzeit-Telemetrie-Anzeige (50 Hz), Video-/noVNC-Lobby-Streaming, Docker-Sandbox-Steuerung sowie vollständige Multi-Agenten-, Mandats- und GPU-Kontrollkonsole mit Hardware-Schreibschutz (Change-Freeze).

---

## 1. Systemarchitektur & Kommunikationswege der Pitwall

Die Pitwall verbindet die zeitkritische Assetto-Corsa-Rennsimulation (`acs.exe` / SteamVR) mit dem asynchronen 6-Agenten-Verbund (`@general`, `@light`, `@rig`, `@dark`, `@sarah`, `@rick`):

1. **50 Hz Echtzeit-Telemetrie (`UDP :50005` $\rightarrow$ `StrikerPi :8080` $\rightarrow$ `Archibald :9996` & WebSocket):**
   - Auf dem SimRacer liest `ac_telemetry_sender.py` die Assetto-Corsa-Telemetrie aus und sendet 50 JSON-Pakete pro Sekunde per UDP an `192.168.178.86:50005`.
   - `telemetry_relay.py` auf StrikerPi verteilt den Stream verzögerungsfrei an drei Ziele:
     - **WebSocket (`/ws/telemetry` auf `:8080`):** Treibt das Live-Dashboard im Chromium-Fullscreen-Kiosk auf Archibald mit 25 FPS UI-Refresh an.
     - **UDP-Forwarding (`192.168.178.98:9996`):** Versorgt den lokalen Daemon `sarah-pitwall-telemetry.service` auf Archibald für Stint-Analysen und Voice-Coaching.
     - **Mosquitto MQTT (`127.0.0.1:1883` / WS `:9001`):** Publiziert `simrig/telemetry` (10 Hz), `simrig/mode` (`ENGINEERING`, `PITBOX_SETUP`, `LIVE_RACE`) sowie `simrig/agent_control` und `agents/<target>/inbox`.
2. **Bidirektionale Agenten- & Policy-Brücke (`SMB :445` + `SSH :22` + `MQTT :1883`):**
   - Die Pitwall liest und schreibt über atomare `.tmp`-Operationen die Laufzeit-Steuerdatei `C:\ac-sandbox\shared\agents\general-SIM\pitwall_control_policy.json` auf dem SimRacer.
   - Die statische Grundsicherheitsdatei `approval_policy.json` sowie alle `.agent.md`-, `SKILL.md`- und System-Konfigurationsdateien unterliegen dem unverletzlichen **Change-Freeze** und können von keinem Agenten selbstständig oder gegenseitig verändert werden.

---

## 2. Aufbau der Benutzeroberfläche (Topbar & 2 Hauptansichten)

Die Pitwall wird unter **`http://192.168.178.86:8080/`** bedient und ist speziell für die Touch-Bedienung an der Boxenmauer (IdeaPad 5 `Archibald`) ausgelegt.

### 2.1 Globale Kopfzeile (Topbar)
In der oberen Steuerleiste befinden sich die permanent erreichbaren Systemschalter:
- **Status-Pills (links):**
  - `STRIKERPI // PITWALL LIVE`
  - **WebSocket-Indikator (`wsPill`):** Zeigt `🟢 Live auf Strecke` (sobald `rpm > 500` und `speed > 3 km/h`), `🟡 Box / Standby (WS OK)` oder `Replay`.
  - **Aktiver Systemmodus (`Mode`):** `ENGINEERING`, `LIVE_RACE` oder `PITBOX_SETUP`.
- **Haupt-Navigation (Tabs):**
  - **`🏁 Telemetrie`:** Schaltet auf das Renn-, Stream- und Sandbox-Dashboard.
  - **`🛡️ Agenten & Light`:** Schaltet auf die Multi-Agenten-Steuerung, GPU/Ollama-Überwachung und Freigabe-Matrix. Ein dynamisches Badge zeigt den Live-Status (`DELEGATED`, `AUTO`, `MANUAL`, `⏸ PAUSE` oder `X offen` bei wartenden Freigabe-Anträgen).
- **Schnellzugriffe & Panels (rechts):**
  - **`🎙️ Antigravity Sprachchat`:** Öffnet Google Antigravity Remote Control in einem dedizierten HTTPS-Browser-Tab (Secure Context für Mikrofon-Freigabe).
  - **Modus-Direktwahl:** Buttons `ENGINEERING` | `LIVE_RACE` | `PITBOX_SETUP` (schalten den globalen SimRig-Modus via REST `/api/mode` und MQTT `simrig/mode` um).
  - **`🐳 Sandbox starten` / `🛑 Docker & Sandbox stoppen`:** Startet oder beendet Docker Desktop, WSL2 und den Windows-11-Container `ac-win11-sandbox` auf dem SimRacer. *Schutzmechanismus:* Sobald auf dem SimRacer eine Live-Session (`acs.exe` oder SteamVR) läuft, verriegelt sich dieser Button automatisch auf **`🔒 Sandbox gesperrt (Live-Session)`**.
  - **`🧪 AC / CM / CSP`:** Öffnet das interaktive Sandbox-Steuerungspanel inklusive eingebettetem noVNC-Desktop (`:8006`).
  - **`📺 Lobby-Streams`:** Öffnet den Live-Videostream vom SimRacer (`:8090` MJPEG) oder der Sandbox (`:8006` noVNC).
  - **`⚙️ Touch & Display`:** Öffnet die ausklappbare Touch-Schublade für das IdeaPad.
  - **`⛶ Fullscreen`:** Schaltet den Browser in den randlosen Kiosk-Vollbildmodus.

### 2.2 Touch- & Display-Schublade (`⚙️ Touch & Display`)
Speziell für die Ergonomie am IdeaPad-Touchscreen bleiben alle Einstellungen im `localStorage` (`strikerpi_pitwall_prefs_v2`) gespeichert:
- **👆 IdeaPad Touch-Größe:** `Standard (100%)` | `Touch Komfort (44px Buttonhöhe)` | `Touch XL (50px Buttonhöhe für Handschuh-/Rennbetrieb)`.
- **📊 Anzeige:** `🔍 Große Rennwerte` (vergrößert km/h, Gang und Reifendrücke), `🌗 High-Contrast` (erhöhter Kontrast gegen Blendung), `🧹 Vmax / Delta Reset` (setzt Höchstgeschwindigkeit der Session zurück).
- **📺 Stream FPS / Qualität:** `8 FPS Eco` (960px) | `12 FPS Standard` (1280px) | `16 FPS Flüssig` (1280px, hohe Qualität).
- **Archibald-Systembefehle (via UDP `:9996`):**
  - **`🖥️ Sarah-Konsole (WS 2)`:** Wechselt Hyprland auf dem IdeaPad direkt zu Workspace 2 (`start_sarah_terminal.sh`).
  - **`🔧 Pitfile optimieren`:** Triggert `sarah_pitfile_optimizer.py` zur Berechnung von `Sarah_Opt_Stint.ini`.
  - **`🔄 Kiosk Reload`:** Lädt das Pitwall-Interface komplett neu.

---

## 3. Ansicht 1: `🏁 Telemetrie` (Renndaten, Lobby-Streams & Sandbox-Labor)

### 3.1 Die 6 Echtzeit-Telemetriekarten
1. **Fahrzeug & Strecke:** Aktuelles Fahrzeug-Modell und Track-Name (`car @ track`), aktuelle Rundennummer (`Lap`) und laufende Rundenzeit (`Cur mm:ss.SSS`).
2. **Speed / Gang / RPM:** Geschwindigkeit in `km/h`, eingelegter Gang (`R`, `N`, `G1`–`G8`), exakte Drehzahl (`RPM`), gemessene Session-Höchstgeschwindigkeit (`Vmax`) sowie ein dreifarbiger LED-Drehzahlbalken (Grün $\rightarrow$ Gelb $\rightarrow$ Rot).
3. **Pedale (Gas / Bremse):** Prozentuale Pedalstellung (`0% / 0%`) mit zwei getrennten Echtzeit-Füllbalken (Grün für Gas, Rot für Bremse).
4. **Reifendruck (FL / FR / RL / RR):** Live-Reifendrücke aller vier Räder in `PSI` auf eine Nachkommastelle sowie verbleibender Tankinhalt (`Fuel: X.X L`).
5. **Reifentemperatur (FL / FR / RL / RR):** Kerntemperaturen aller vier Reifen in `°C` mit automatischer Farbcodierung (**Blau** `< 72 °C` kalt, **Grün** `72–102 °C` optimales Grip-Fenster, **Rot** `> 102 °C` Überhitzung) sowie beste Rundenzeit (`Best`) und Live-Delta (`Δ +0.00s`).
6. **Aktive Sim-Lobby:** Zeigt den Live-Zustand des SimRacer-Hosts (`FAHRT AKTIV`, `Standby` oder `Offline`) und den aktiven Fenstertitel.

### 3.2 Panel `📺 Lobby-Streams` (Live-Bildübertragung & TV-Kamera-Regie)
- **Quellenwahl:** Umschaltbar zwischen **`🏎️ SimRacer Aktiv (Nativ / VR)`** (flüssiger 20–24 FPS Low-Latency MJPEG-Stream von Port `:8090` mit `960p`/`1024p`) und **`🧪 Sandbox Display (:8006)`** (auf `1280x720` optimiertes noVNC-Fenster des Windows-11-Gasts ohne CPU-Schatten/AA-Bremse).
- **Live-Kamera-Wahlschalter & Auto-Regie (für TV-Zuschauer an der Pitwall, ohne VR-Brille des Fahrers zu stören):**
  - **`📺 TV (F3)`:** Strecken-TV-Kameras mit automatischem Fahrzeug-Tracking.
  - **`🏎️ Cockpit (F1)`:** Onboard-/Cockpit-Perspektive.
  - **`🎬 Action (F6)`:** Motorhauben-, Heckflügel- und Rad-Actionkameras.
  - **`🔀 Mix (F2)`:** Dynamischer Assetto-Corsa-Kameramix.
  - **`🎥 Auto-Regie`:** Wechselt alle 18 Sekunden vollautomatisch zwischen TV-Streckenkamera (`F3`), Action-Kamera (`F6`) und Cockpit (`F1`).
- **`⛶ Video-Vollbild`:** Vergrößert ausschließlich das Live-Videobild auf den gesamten IdeaPad-Touchscreen.
- **Auto-Stream-Automatik:** Ist die Checkbox *„Auto-Stream sobald gefahren wird“* aktiv, schaltet sich das Videobild beim Verlassen der Boxengasse automatisch zu und stoppt im Standby (`0 %` CPU/GPU-Last im Leerlauf).

### 3.3 Panel `🧪 AC / CM / CSP` (Interaktives Sandbox-Prüflabor)
Ermöglicht die komplette Fernsteuerung der Windows-11-Sandbox (`ac-win11-sandbox`) und des darin laufenden **`@dark` Agenten**, ohne den SimRacer-Monitor zu benutzen:
- **Docker-Lifecycle:** `▶ Docker & Sandbox starten`, `⏹ Docker & Sandbox stoppen`, `⏸ Sandbox pausieren`, `▶ Sandbox fortsetzen`.
- **AC + CSP Test-Session:** Dropdown-Auswahl für alle gestagten Fahrzeuge (`Shared Content`), Strecken und Presets (`desktop_4k`, `vr_focusvision`) mit Direktbuttons:
  - `🎨 Preset anwenden` (`ApplyPreset`)
  - `💾 Session setzen` (`SetSession` schreibt `race.ini` im Gast)
  - `🏁 AC + CSP starten` (`LaunchSession` im Practice-Modus)
  - `🔁 Replay-Test` (`LaunchSession` im Replay-Modus)
  - `⏹ AC beenden` (`StopSession`)
  - `🖥️ Content Manager` (`LaunchCM` auf Display `:8006`)
- **`@dark` Tests, Sync & Diagnose:** `✕ CM schließen`, `🧪 Setups prüfen` (`ValidateSetups` prüft alle `.ini`-Dateien auf Sektions-Integrität), `🔄 Assets syncen` (`SyncCoreAssets`), `🩺 @dark Diagnose` (`DiagnoseAndHandoff`) sowie ein Live-Logfenster (`📜 Sandbox / @dark Log`).

---

## 4. Ansicht 2: `🛡️ Agenten & Light` (Autonome KI-Steuerung & Sicherheits-Gates)

Diese Ansicht setzt die **Operational State Machine** um: Agenten können vollautonom im Hintergrund arbeiten, lassen sich aber global oder einzeln mit einem Fingertipp pausieren, deaktivieren oder zeitlich begrenzt delegieren.

### 4.1 Die 3 Master-Statuskarten (Obere Reihe)
1. **⏯️ Globaler Agenten-Status:**
   - Zeigt, ob der Verbund aktiv ist (`▶️ ALLE AGENTEN AKTIV` vs. `⏸️ ALLE AGENTEN PAUSIERT`) inklusive der Summe aller wartenden Aufgaben (`Queues: X`).
   - Der Button **`⏸️ Alle Agenten pausieren` / `▶️ Verbund fortsetzen`** setzt `agents_paused` in `pitwall_control_policy.json`. Im Pause-Modus behalten alle Agenten ihre Inboxes, starten aber keine neuen Aufgaben, bis die Pause aufgehoben wird.
2. **🎮 RTX 5070 Ti & Hintergrundarbeit (+ Cyborg-Laptop GPU-Freigabe für `@sarah`):**
   - Liest live über `nvidia-smi` und die Ollama-API (`:11434/api/ps`) auf dem SimRacer die **GPU-Temperatur (`°C`)**, **Auslastung (`%`)**, **VRAM-Belegung (`MiB`)** sowie die **aktuell im VRAM geladenen Sprachmodelle** (`gemma4:12b`, `qwen2.5-coder:14b`) aus.
   - Mit **`🚫 SimRacer GPU & Hintergrund sperren`** wird `gpu_background_allowed = false` gesetzt (blockiert sofort alle hintergründigen LLM-/Render-Jobs auf dem SimRacer). Während einer aktiven VR-/Rennsession schaltet die Karte automatisch auf **`🏎️ SIM-VORRANG (LIVE-FAHRT)`** und `rig-hub.ps1` entlädt den VRAM der 5070 Ti per `keep_alive: 0`.
   - **Schalter `💻 Cyborg-Laptop GPU fuer @sarah: ERLAUBT / 🔒 RESERVIERT (Nur Du am Laptop)` (`sarah_cyborg_gpu_allowed`):**
     - **ERLAUBT:** Da das IdeaPad (`Archibald`) keine eigene NVIDIA-GPU hat und die RTX 5070 Ti während einer VR-Fahrt zu 100 % für Assetto Corsa reserviert ist, lagert `@sarah` ihre KI-Aufgaben automatisch über LAN auf die **RTX 5060 (`gemma4:e4b`)** des `VanstrikeCyborg`-Laptops aus.
     - **RESERVIERT:** Wenn ein Gast im Simulator fährt und du selbst am `VanstrikeCyborg`-Laptop ungestört arbeiten willst, tippst du auf diesen Button – `@sarah` darf die Laptop-GPU dann nicht mehr beanspruchen.
3. **🚨 Not-Aus & Mandats-Status:**
   - Zeigt den aktiven Freigabemodus (`MANUAL`, `DELEGATED`, `AUTO`), die Restlaufzeit eines zeitlich begrenzten Light-Mandats (`Unbegrenzt` oder `Noch X Min`) sowie die Queue-Verteilung (`@light | @dark | @rig`).
   - **Roter Button `🚨 Not-Aus: Pause + Light-Rechte entziehen`:** Setzt das System sofort auf `mode = MANUAL`, `agents_paused = true`, `gpu_background_allowed = false`, löscht alle Zeitmandate und stellt sämtliche Kategorien auf `ASK_USER` zurück.

### 4.2 `🤖 Einzel-Agenten-Steuerung (Autonom / Pause / Deaktivieren)`
Über diese 6 Zeilen wird jeder Agent im 5-Knoten-Netzwerk individuell gesteuert (`policy.agent_states`):
- **`🏛️ @general` (Leitstand Laptop `VanstrikeCyborg`)** – Workspace-Orchestrator, Freigabe-Gate & Cross-Agent-Routing.
- **`🐳 @light` (SimRacer Docker/Session)** – Container-Lifecycle, `race.ini`, Presets & Content-Staging.
- **`🏎️ @rig` (SimRacer Hardware/VR)** – RTX 5070 Ti, SteamVR, `acs.exe` & VR-Watchdog.
- **`🧪 @dark` (Win11 Sandbox Gast)** – Isolierte Setup-Validierung, CM-Tests & Replay-Analyse.
- **`🎧 @sarah` (Archibald Pitwall Coach)** – Live-Telemetrie, Sektordeltas, Setup-Optimierung & Videoschnitt.
- **`📡 @rick` (StrikerPi 24/7 Edge Hub)** – Mosquitto MQTT `:1883`, Relay `:8080` & Bare-Git-Server.

**Pro Agent stehen 3 Betriebsarten zur Auswahl:**
- **`▶️ Aktiv` (`active`):** Agent arbeitet seine Inbox autonom gemäß Freigabe-Matrix ab.
- **`⏸️ Pause` (`paused`):** Agent-Prozess läuft weiter, zieht aber keine Tasks aus der Inbox (bestehende Aufträge warten verlustfrei in der Queue; im Terminal erscheint gelb/rot `PAUSIERT (Pitwall)`).
- **`⛔ Deaktiviert` (`disabled`):** Agent ist komplett abgekoppelt; Tasks werden nicht abgearbeitet (`DEAKTIVIERT (Pitwall)`).

### 4.3 `🤝 Gemeinsame Freigabe-Matrix (Du & @light)`
Steuert die Aufgabenteilung zwischen Mensch und KI:
- **Globale Modi:**
  - **`🙋 MANUAL (Nur Du)`:** Jede Aktion erfordert eine explizite Bestätigung (`ok` im Terminal oder Klick auf `✅ Freigeben` an der Pitwall).
  - **`🤝 DELEGATED (Du + Light)`:** `@light` darf genau die Kategorien eigenständig freigeben und ausführen, die in der Matrix auf `🤝 Light` (`LIGHT_AUTO`) stehen.
  - **`⚡ AUTO (Dauerfreigabe)`:** Alle regulären Projekt- und Sim-Aufgaben werden automatisch genehmigt.
- **Zeitliches Mandat:** Über `♾️ Unbegrenzt`, `⏱️ +60 Min` oder `⏱️ +180 Min` lässt sich die Delegationsvollmacht für `@light` zeitlich befristen (danach fällt das System automatisch auf manuelle Rückfrage zurück).
- **Die 5 einzeln schaltbaren Aufgaben-Kategorien (`🤝 Light` | `🙋 Du` | `🔒 Sperre`):**
  1. `🏎️ Session & Presets` (`session_presets`: `race.ini`, Fahrzeug/Strecke, Desktop/VR-Presets)
  2. `🧪 Sandbox-Tests (@dark)` (`sandbox_dark_tasks`: Setup-Prüfung, Content Manager Start/Stop, Diagnose)
  3. `🐳 Docker & Sandbox-Lifecycle` (`sandbox_lifecycle`: Start/Stop/Pause Container)
  4. `🔄 Content- & Paket-Sync` (`content_sync`: 7 Pakete `cm-github-sync` & Core-Assets)
  5. `🎮 Rig- & Hardware-Aktionen` (`rig_actions`: Weiterleitungen an `@rig`, SteamVR & FFB-Konfig)
- **Unveränderliche Sicherheitszeile:** `🔒 Change-Freeze (Agenten & System-Configs)` ist dauerhaft auf **`🔒 Immer gesperrt`** verriegelt (`*.agent.md`, `AGENTS.md`, `SKILL.md`, `settings.json`, `mcp.json`, `approval_policy.json` und Worker-Skripte sind gegen Selbst- und Fremdänderung durch Agenten geschützt).

### 4.4 `📥 Offene Freigabe-Anträge` & `📜 Freigabe- & Schalt-Protokoll`
- Wenn ein Agent im Modus `MANUAL` oder in einer `ASK_USER`-Kategorie eine Aktion ausführen möchte, erscheint der Antrag sofort als gelbe Karte unter **Offene Freigabe-Anträge** mit drei Touch-Buttons:
  - **`✅ Freigeben`:** Einmalige Ausführung genehmigen.
  - **`🤝 Freigeben + an Light`:** Auftrag genehmigen und diese Kategorie künftig dauerhaft an `@light` (`LIGHT_AUTO`) delegieren.
  - **`❌ Ablehnen`:** Auftrag abweisen (`Status: Rejected`).
- Darunter protokolliert das **Freigabe- & Schalt-Protokoll (`audit`)** lückenlos die letzten 30 Änderungen mit Zeitstempel, Akteur (`Pitwall_User` / `GeneralTerminal`) und geändertem Parameter.

---

## 5. Zusammenspiel mit den 5 Agenten-Terminals & dem Hybrid-LLM-Router

1. **Synchronisierte Terminal-Kopfzeilen:**
   Alle fünf PowerShell-Konsolen (`start_general_terminal.ps1`, `start_light_terminal.ps1`, `start_rig_terminal.ps1`, `start_dark_terminal.ps1`, `start_sarah_terminal.ps1`) zeigen unter ihrem mehrzeiligen ASCII-Header in Echtzeit die Zeile **`Pitwall-Gate: Modus=... | Verbund=... | GPU-BG=...`** an.
2. **Terminal-Kurzbefehle (identisch zur Pitwall-UI):**
   Im `General Sim`-Terminal auf dem Laptop können dieselben Schaltungen auch per Tastatur ausgelöst werden:
   - `pause` / `resume`: Pausiert den gesamten Agenten-Verbund oder setzt ihn fort.
   - `auto` / `delegated` / `manual`: Schaltet den globalen Freigabemodus in `pitwall_control_policy.json` um.
   - `ok` / `nein <Grund>` / `reply <Text>`: Beantwortet offene Freigabe-Anträge synchron zur Pitwall.
   - `md` / `log`: Öffnet die Markdown-Kommunikationshistorie (`AGENT_KOMMUNIKATION_HISTORIE.md`) bzw. die Tages-Logfiles direkt in VS Code.
3. **Anti-Halluzination & Prädiktives LLM-Routing (`hybrid_llm_router.py` & `sim_agent_bridge.py`):**
   - Jeder Auftrag erhält beim Versand automatisch ein aufgabenbezogenes **`context_subset`** (z. B. `Assetto_Corsa_Config`, `ini_parsing`, `Hardware_VR_Telemetry`, `Docker_Sandbox_Guest`, `Telemetry_Coaching_Media`, `Edge_Relay_MQTT`) sowie einen strikt getrennten **`memory_scope`** (`memories/sandbox` für `@dark` vs. `memories/host/<agent>`).
   - Der Router berechnet vorab in `< 1 ms` einen deterministischen **`weight_score`** (`low`, `medium`, `high`): Leichte Aufgaben (z. B. Sarah-Sektordeltas) laufen auf dem lokalen Laptop-Ollama (`gemma4:e4b`), mittlere Code-/Setup-Tasks auf dem SimRacer-Ollama (`qwen2.5-coder:14b` / `gemma4:12b` auf RTX 5070 Ti), und schwere Multi-File-Tasks während `LIVE_RACE` eskalieren an Vertex AI ADC (`gen-lang-client-0668043276`) oder parken in der `High-Weight Queue`.

---

## 6. REST- & WebSocket-API-Referenz der Pitwall (`:8080`)

| Endpunkt | Methode | Funktion |
| :--- | :--- | :--- |
| `/` | `GET` | Liefert die vollständige HTML5/CSS/JS Pitwall-Anwendung (Tabs `🏁 Telemetrie` & `🛡️ Agenten & Light`). |
| `/ws/telemetry` | `WS` | Echtzeit-WebSocket-Stream (25 Hz UI-Push der 50 Hz UDP-Telemetrie vom SimRacer). |
| `/health` bzw. `/api/status` | `GET` | System-Healthcheck (`mode`, `mqtt_connected`, `active_source`, `packets_received`, `car`, `track`). |
| `/api/mode` | `GET` / `POST` | Liest oder setzt den globalen SimRig-Modus (`ENGINEERING`, `LIVE_RACE`, `PITBOX_SETUP`) inkl. MQTT-Retain. |
| `/api/streams` | `GET` | Prüft Live-Fahrstatus (`driving_active`), SimRacer-Stream (`:8090`) und Sandbox-noVNC (`:8006`). |
| `/api/stream/simracer.mjpeg` | `GET` | MJPEG-Live-Proxy vom SimRacer-Screen/VR-Mirror (steuerbar über `fps`, `w`, `q`). |
| `/api/sandbox/status` | `GET` | Vollständiger Container-, CSP-, `race.ini`- und Preset-Status der Windows-11-Sandbox. |
| `/api/sandbox/{start,stop,pause,resume}` | `POST` | Steuert Docker Desktop & `ac-win11-sandbox` auf dem SimRacer (automatisch gesperrt bei `LIVE_RACE`). |
| `/api/sandbox/ac/action` | `POST` | Führt `@dark`-Aktionen im Gast aus (`apply_preset`, `set_session`, `launch_practice`, `launch_replay`, `validate_setups`, `sync_assets`, `diagnose`). |
| `/api/approvals/state` | `GET` | Liefert `pitwall_control_policy.json`, `agent_states`, wartende Freigaben, Queue-Längen, RTX-5070-Ti-Telemetrie & Ollama-Status. |
| `/api/approvals/policy` | `POST` | Aktualisiert `mode`, `agents_paused`, `gpu_background_allowed`, `mandate_minutes`, `categories`, `agent_states` oder löst `emergency_revoke` (Not-Aus) aus. |
| `/api/approvals/decide` | `POST` | Genehmigt (`approve`) oder verwirft (`reject`) einen Freigabe-Antrag und delegiert optional die Kategorie an `@light`. |
| `/api/pitwall/archibald` | `POST` | Sendet Hyprland-/Systembefehle per UDP `:9996` an Archibald (`workspace_1`, `workspace_2`, `wake_display`, `pitfile_opt`). |
