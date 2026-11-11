# Roadmap & Nächste Schritte: SimRacer Host & VanstrikeCyborg

Dieses Dokument fasst den aktuellen Projektstatus zusammen und definiert die konkreten nächsten Arbeitsschritte auf der **SimRacer-Workstation (`192.168.178.68`)** und dem **VanstrikeCyborg-Laptop**, bevor die Inbetriebnahme von **Sarah Coach** auf dem **IdeaPad 5 (Linux Omarchy)** beginnt.

---

## 1. Status Quo: Wo stehen wir?

### ✅ Block A: Docker Windows-11-Sandbox (`ac-win11-sandbox` auf SimRacer) – 100 % abgeschlossen

| Komponente | Status | Details |
| :--- | :---: | :--- |
| **A.1 Virtuelle Festplatte (C:)** | ✅ Abgeschlossen | Auf 160 GB erweitert (159,75 GB erkannt, ~93,4 GB frei). |
| **A.2 OpenSSH-Server (Gast)** | ✅ Abgeschlossen | Port `2222`, Dienst `sshd` läuft, SSH-Keys konfiguriert. |
| **A.3 Assetto Corsa & Content Manager** | ✅ Abgeschlossen | 7 Pakete synchronisiert, Desktop-Verknüpfung vorhanden. |
| **A.4 Dark Agent (In-Container)** | ✅ Abgeschlossen | `runner.ps1`, `worker.ps1`, `guest-status.json` einsatzbereit. |
| **A.5 Python 3.11.9 (Gast)** | ✅ Abgeschlossen | Installiert, MS-Store-Aliase umgangen, `python` & `pip` global. |
| **A.6 Content-Staging (16 RSS-Autos & 10 Strecken)** | ✅ Abgeschlossen | Schlankes Staging via Robocopy `/XF *.kn5 *.bank` (~140 MB) nach `C:\AssettoCorsa\content`. |
| **A.7 Setup-Validierung & Hot-Deploy Pipeline** | ✅ Abgeschlossen | 201 Setups valide; `DeployPitfile` synchronisiert Setups ins native SimRig. |
| **A.8 5-Agenten-Architektur & Dokumentation** | ✅ Abgeschlossen | General Agent, SimRacer Light, Rig Agent, Dark Agent, Sarah Coach; Topologie & Spezifikationen in `agents/`. |
| **A.9 Dauerhafte Windows 11 HWID-Aktivierung** | ✅ Abgeschlossen | Permanent digital aktiviert (`slmgr.vbs /xpr`), in `bootstrap-guest.ps1` verankert. |
| **A.10 Handshake Task-Queue & Dispatcher** | ✅ Abgeschlossen | `Send-DarkAgentTask.ps1` (`inbox/` $\rightarrow$ `worker.ps1` $\rightarrow$ `outbox/` mit Result- & ExitCode-Prüfung). |
| **A.11 Managed Presets (Desktop 4K / VR)** | ✅ Abgeschlossen | Standardisierte Profile `desktop_4k` & `vr_focusvision` (`video.ini` DEFAULT vs. OPENVR). |
| **A.12 GUI-Start auf Desktop (Session 1)** | ✅ Abgeschlossen | Umgehung der Session-0-Isolation via QEMU Monitor Socket (`/run/shm/monitor.sock` / `open_cm.py`). |
| **A.13 SimRacer SMB-Freigaben & 35 Mod-Autos** | ✅ Abgeschlossen | `AssettoCorsa`, `ac-sandbox`, `C`, `D` freigegeben; 35 Premium-Mod-Autos gestaged. |
| **A.14 3-Ebenen-Befehlshierarchie** | ✅ Abgeschlossen | Ebene 1: General Agent / Nutzer $\rightarrow$ Ebene 2: SimRacer Light & Rig Agent $\rightarrow$ Ebene 3: Sandbox Dark. |

### ✅ Block B: SimRacer Host-Härtung, Schnittstellen & Backups – 100 % abgeschlossen

| Komponente | Status | Details |
| :--- | :---: | :--- |
| **B.1 OpenSSH DefaultShell (PowerShell)** | ✅ Abgeschlossen | `HKLM\SOFTWARE\OpenSSH\DefaultShell` auf `powershell.exe` gesetzt. Beseitigt Cmdlet- und Pipeline-Fehler (`\|`, `Select-Object`, etc.). |
| **B.2 Fokus-Wächter Task (`SimRacer-Focus-Watchdog`)** | ✅ Abgeschlossen | Läuft dauerhaft (`State: Running`) via Task Scheduler. Pausiert `ac-win11-sandbox` automatisch bei Start von `acs.exe` (100 % VR 90 FPS). |
| **B.3 Tägliches Pitfile-Backup (`SimRacer-Pitfile-Backup`)** | ✅ Abgeschlossen | Registriert für täglich 23:00 Uhr via `setup-simracer-tasks.ps1`. Testlauf erfolgreich in `D:\Backups\SimRacer_Configs\` abgelegt. |
| **B.4 Laptop NVMe-Bereinigung** | ✅ Abgeschlossen | Altes 68,7-GB-Image `storage\data.img` auf VanstrikeCyborg gelöscht; freier Speicher auf `C:` auf **~171 GB** erhöht. |
| **B.5 Veeam Agent v13 & Recovery Media** | ✅ Abgeschlossen | Veeam Agent v13 installiert; USB-Stick (`E:`, 3,75 GB Generic Flash Disk) gemountet; Recovery Media Assistent auf Bildschirm gestartet; Exclusions in `D:\Backups\Veeam_Exclusions.txt`. |
| **B.6 Node.js LTS & Python 3.11 auf SimRacer** | ✅ Abgeschlossen | Node.js v26.13.0 LTS & npm 11.20.0 sowie Python 3.11.9 global auf dem Host installiert. |
| **B.7 AC Shared Memory Telemetrie-Sender (`C.1`)** | ✅ Abgeschlossen | `C:\ac-sandbox\shared\telemetry\ac_telemetry_sender.py` liest `acpmf_*` aus RAM und streamt 50 Hz UDP nach Port `9996`. |
| **B.8 Web-VNC Display (Port 8006)** | ✅ Abgeschlossen | Framebuffer schaltet auf Full HD 1920x1080; Webinterface stabil erreichbar. |

### ✅ Bereits implementierte Host-Tools (SimRacer & Laptop)

* **`Send-DarkAgentTask.ps1` (Laptop):** Primärer Handshake-Dispatcher für In-Container-Aufgaben mit asynchroner Queue und synchroner Rückmeldung.
* **`Invoke-DarkAgent.ps1` (Laptop):** Steuert den In-Container-Agenten via SSH Port 2222 (`Status`, `ValidateSetups`, `LaunchCM`, etc.).
* **`Invoke-RigAgent.ps1` (Laptop):** Steuert den SimRacer Host via SSH Port 22 (`ListContent`, `ProvisionContent`, `DeployPitfile`, `Status`, `Watchdog`).
* **`rig-hub.ps1` (SimRacer Host):** Schlankes Staging von Autos/Strecken aus `race.ini`, Sandbox-Pausierung (`docker pause`/`unpause`), Setup-Deployment und Telemetrie-Schnittstelle.

---

## 2. Abgeschlossene Meilensteine & Host-Konfiguration

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    STATUS DER BLÖCKE & NÄCHSTE SCHRITTE                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ ✅ Block A: Docker Windows-11 Sandbox auf SimRacer NVMe   -> 100 % fertig    │
│ ✅ Block B: Host-Härtung, Schnittstellen & Backups         -> 100 % fertig    │
│    ├── B.1 OpenSSH DefaultShell = powershell.exe (Keine Pipeline-Fehler)     │
│    ├── B.2 SimRacer-Focus-Watchdog Task (VR 90 FPS Schutz)                   │
│    ├── B.3 SimRacer-Pitfile-Backup Task (Täglich 23:00 Uhr)                  │
│    ├── B.4 NVMe-Bereinigung Cyborg (~171 GB frei)                            │
│    ├── B.5 Veeam Agent v13 & USB Recovery Media (Laufwerk E:)                │
│    ├── B.6 Node.js v26 LTS & Python 3.11 auf SimRacer Host                   │
│    ├── B.7 AC Shared Memory Telemetrie-Sender (50 Hz UDP Port 9996)          │
│    └── B.8 noVNC Web-Display Port 8006 (Full HD 1920x1080 aktiv)            │
│ ─────────────────────────────────────────────────────────────────────────── │
│ 🚀 NÄCHSTER SCHRITT: Block C - IdeaPad 5 (Linux Omarchy) & Sarah Coach      │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Schritt 1: Fokus-Wächter als Autostart-Task auf SimRacer (Task B.2) – ✅ Aktiv

* **Ziel:** Maximale VR-Frametimes (90 FPS stabil auf VIVE Focus Vision). Sobald `acs.exe` (Assetto Corsa) auf dem SimRacer startet, pausiert die Docker-Sandbox automatisch (`docker pause ac-win11-sandbox`). Sobald `acs.exe` schließt, taut die Sandbox wieder auf.
* **Umsetzung & Status:**
  * Geplante Aufgabe im Windows Task Scheduler registriert (`setup-simracer-tasks.ps1`):
    * **Name:** `SimRacer-Focus-Watchdog`
    * **Trigger:** Bei Anmeldung des Benutzers `Mike` (`AtLogOn`)
    * **Aktion:** `powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\ac-sandbox\shared\scripts\rig-hub.ps1 -Action Watchdog -WatchdogInterval 3`
    * **Status:** Läuft aktiv im Hintergrund (`State: Running`).

---

### Schritt 2: AC Shared-Memory Telemetrie-Sender am SimRacer (Task B.7 / C.1) – ✅ Bereit

* **Ziel:** Sarah Coach auf dem IdeaPad 5 benötigt Live-Telemetriedaten ohne FPS-Einbußen am Gaming-PC.
* **Architektur & Status:**
  * Skript: `C:\ac-sandbox\shared\telemetry\ac_telemetry_sender.py`.
  * Liest native Shared Memory Bereiche direkt aus dem Windows-RAM:
    * `acpmf_physics` (Reifendrücke, Kerntemperaturen, Bremsdruck, G-Kräfte, Radschlupf)
    * `acpmf_graphics` (Sitzungsstatus, Rundenzeiten, Streckenposition `normalizedCarPosition`, Sektor-Zeiten)
    * `acpmf_static` (Auto-Name, Strecken-Layout, max. Drehmoment/Drehzahl)
  * Sendet 50 Hz UDP/JSON-Pakete an `192.168.178.98:9996` (IdeaPad 5 / Archibald).
  * **Ressourcenverbrauch:** $< 0.2\text{ \%}$ CPU auf dem Ryzen 9 3900X.
  * **Verifikation:** Erfolgreich mit `test_telemetry.py` verifiziert.

---

### Schritt 3: Automatisches Pitfile-Backup auf SimRacer (Task B.3) – ✅ Aktiv

* **Ziel:** Jedes gespeicherte `.ini`-Fahrzeugsetup wird versioniert gesichert.
* **Umsetzung & Status:**
  * Geplanter Task `SimRacer-Pitfile-Backup` im Task Scheduler für täglich 23:00 Uhr registriert.
  * **Skript:** `C:\ac-sandbox\backup-simracer-configs.ps1`
  * **Zielverzeichnis:** `D:\Backups\SimRacer_Configs\YYYY-MM-DD_HH-mm\`
  * Sichert `AC_cfg` (Setups), `ContentManager`, `Fanatec` und `SteamVR`.

---

### Schritt 4: 68,7 GB Alt-Image auf dem Laptop bereinigen (Task B.4) – ✅ Erledigt

* **Ergebnis:** Alte 68,7-GB-Kopie `C:\Users\strik\assetto-corsa-content\ac-sandbox\storage\data.img` wurde nach Bestätigung gelöscht.
* **Freier Speicherplatz auf Laptop `C:`:** Gestiegen von 107 GB auf **~171 GB**.

---

### Schritt 5: Veeam Bare-Metal-Backup für SimRacer (Task B.5) – ✅ In Bearbeitung am Monitor

* **Umsetzung & Status:**
  * **Veeam Agent v13:** Auf SimRacer via `winget` installiert.
  * **Ausschlussliste:** `D:\Backups\Veeam_Exclusions.txt` spart `steamapps\common\*`, `ac-sandbox\storage\*` und `Docker\wsl\*` aus.
  * **USB-Stick:** Als Datenträger 2 (`Generic Flash Disk`, 3,75 GB, Laufwerk `E:`) erkannt.
  * **Recovery Media Assistent:** Auf SimRacer-Bildschirm geöffnet (`Veeam.Endpoint.RecoveryMedia.exe`).

---

### Schritt 6: OpenSSH DefaultShell & Node.js auf SimRacer – ✅ Behoben

* **OpenSSH DefaultShell:** In `HKLM\SOFTWARE\OpenSSH\DefaultShell` wurde `powershell.exe` als Standard festgelegt. Behebt Cmdlet-Fehler bei Pipelines (`|`, `Select-Object`).
* **Node.js LTS:** Node.js `v26.13.0` & npm `11.20.0` auf dem SimRacer installiert und im Machine-PATH verankert.

---

## 3. Block C – IdeaPad 5 (`Archibald` / Linux Omarchy Pitwall) – ✅ Grundbetrieb eingerichtet (11.11.2026)

1. **Basisbetrieb, WoWLAN & Remote-Sleep (✅ Abgeschlossen):**
   * Dauerhafter Basisbetrieb über `disable-sleep.conf` (`IdleAction=ignore`, `HandleLidSwitch=ignore`); für den Pitwall-Grafikbetrieb sind `idle.lock: 0`, `idle.screensaver: 0` (`~/.config/omarchy/shell.json`), `stay-awake` und `omarchy-sleep-lock.service` (`masked`) sowie der Pitwall-Autostart (`~/.config/hypr/autostart.lua`) eingerichtet, sodass SDDM-Autologin ohne Sperrbildschirm/Passwortabfrage durchläuft (optionaler separater User via `sudo ~/ac-pitwall/setup_pitwall_user.sh`).
   * Persistentes WoWLAN (`wlp0s20f3`, `50-wowlan.rules`, `nmcli wake-on-wlan=8`), passwortloses `sudo -n /usr/bin/systemctl suspend` (`/etc/sudoers.d/archibald-suspend`) sowie `wake_archibald.ps1` / `sleep_archibald.ps1` auf Laptop & SimRacer (`C:\ac-sandbox\`) hinterlegt und End-to-End verifiziert.
   * UFW-Firewall um LAN-Freigaben (`192.168.178.0/24`) für SSH (`22/tcp` vor `LIMIT IN`) und Telemetrie (`9996/udp`) ergänzt.
2. **Telemetrie-Empfänger & Pitfile-Optimizer (✅ Abgeschlossen):**
   * `sarah_telemetry_listener.py` (UDP `9996`), `sarah_pitfile_optimizer.py`, `sarah_targets.json` und `start_sarah_terminal.sh` unter `~/ac-pitwall/` bereitgestellt; Live-Empfang vom SimRacer (`192.168.178.68`) verifiziert.
3. **Sarah Voice Engine & CLIProxyAPI (✅ Abgeschlossen):**
   * `sarah_voice.py` (`edge-tts` + `mpv` über PipeWire, Profil `hybrid` mit `de-DE-SeraphinaMultilingualNeural` und automatischer Screensaver-Steuerung) einsatzbereit.
   * `CLIProxyAPI` (`127.0.0.1:8317`) mit Antigravity-OAuth (`m.e.stuermer@gmail.com`, 21 Modelle) und `pitwall.code-workspace` abgeglichen.
4. **StrikerPi Edge-Hub & Pitwall-Ausbau (✅ Abgeschlossen):**
   * `Mosquitto` MQTT-Broker (`1883` + WebSockets `9001`, Topics `simrig/mode`, `simrig/telemetry`), `uv`, zentrales Bare-Git-Repository `/srv/git/simrig.git` sowie `telemetry-relay.service` (`50005`/`9996` $\rightarrow$ `192.168.178.98:9996`, Live-Dashboard `:8080`) auf `StrikerPi` (`192.168.178.86`) eingerichtet.
   * `sarah-pitwall-telemetry.service` (User-Unit), Pitwall-Konsole (`foot --app-id=sarah-pitwall` auf Workspace 2) und Live-Dashboard (`http://192.168.178.86:8080/`) im **Hyprland-Fullscreen** (`--start-fullscreen` + `o.window("chrome-192.168.178.86__-Default", { workspace = "1", fullscreen = true })`) auf Archibald aktiviert.
   * **Lobby-Streams (On-Demand SimRacer-Perspektive):** Auf `SimRacer` (`192.168.178.68:8090`) läuft `sim_stream_server.py` (Task `SimRacer-Lobby-Stream`, `0 %` Idle-Last) und liefert bei aktivem Fahrbetrieb (`acs.exe` / VR / Live-Telemetrie) die aktive Sim-Perspektive per MJPEG über den `StrikerPi`-Proxy (`/api/streams`, `/api/stream/simracer.mjpeg`) in das Pitwall-Panel **📺 Lobby-Streams** (inkl. Sandbox-Ansicht `:8006`).
   * **Pitwall Sandbox & AC/CM/CSP Integration:** In der Pitwall-Topbar steuert **🐳 Sandbox starten / 🛑 Docker & Sandbox stoppen** den vollständigen Lifecycle von Docker Desktop, WSL2 und `ac-win11-sandbox` auf dem `SimRacer` (`/api/sandbox/start`, `/api/sandbox/stop`, `/api/sandbox/pause`, `/api/sandbox/resume`). Bei aktiver Host-Live-Session (`acs.exe`, `SteamVR` oder Live-Telemetrie) greift automatisch eine `409`-Sicherheitssperre. Im Panel **🧪 AC / CM / CSP** lassen sich Fahrzeuge, Strecken und CM/CSP-Presets setzen, Assetto Corsa + CSP (`dwrite.dll`), Content Manager, Setup-Validierungen (`ValidateSetups`) und `@dark`-Diagnosen direkt im eingebetteten `:8006`-Display starten und testen (`/api/sandbox/ac/action`).

---

## 4. Schnellbefehle (Cheatsheet)

### Status aller Agenten prüfen

```powershell
# Vom Laptop aus:
.\Invoke-DarkAgent.ps1 -Action Status
.\Invoke-RigAgent.ps1 -Action Status
```

### Auto & Strecke für Sandbox synchronisieren

```powershell
# Automatisch aus der letzten race.ini des SimRacers:
.\Invoke-RigAgent.ps1 -Action AutoProvisionFromRaceIni
```

### Sandbox manuell pausieren / fortsetzen

```powershell
.\Invoke-RigAgent.ps1 -Action PauseSandbox
.\Invoke-RigAgent.ps1 -Action ResumeSandbox
```

<!-- DOKU-MINIMAP-START -->
<style>
.doku-arch-flow { font-family: var(--vscode-editor-font-family, Consolas, monospace); background: rgba(20, 24, 33, 0.92); border: 1px solid rgba(100, 140, 220, 0.35); border-radius: 10px; padding: 14px 16px; margin: 10px 0; color: #e2e8f0; }
.doku-arch-root { text-align: center; font-weight: 700; font-size: 1.04em; padding: 8px 12px; margin-bottom: 12px; background: linear-gradient(135deg, rgba(37, 99, 235, 0.28), rgba(15, 23, 42, 0.9)); border: 1px solid rgba(96, 165, 250, 0.5); border-radius: 8px; }
.doku-arch-root a { color: #93c5fd !important; text-decoration: none !important; }
.doku-arch-root a:hover { text-decoration: underline !important; }
.doku-arch-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(275px, 1fr)); gap: 10px; }
.doku-arch-card { background: rgba(30, 41, 59, 0.78); border: 1px solid rgba(148, 163, 184, 0.28); border-left: 4px solid #3b82f6; border-radius: 8px; padding: 9px 11px; transition: transform 0.12s ease, border-color 0.12s ease; }
.doku-arch-card:hover { border-color: #60a5fa; transform: translateY(-1px); }
.doku-arch-card.r1 { border-left-color: #22c55e; }
.doku-arch-card.r2 { border-left-color: #3b82f6; }
.doku-arch-card.r3 { border-left-color: #eab308; }
.doku-arch-card.r4 { border-left-color: #ec4899; }
.doku-arch-card.r5 { border-left-color: #a855f7; }
.doku-arch-card-title { font-weight: 700; font-size: 0.95em; margin-bottom: 6px; padding-bottom: 4px; border-bottom: 1px dashed rgba(148, 163, 184, 0.25); }
.doku-arch-card-title a { color: #f8fafc !important; text-decoration: none !important; display: block; }
.doku-arch-card-title a:hover { color: #60a5fa !important; }
.doku-arch-lines { list-style: none; margin: 0; padding: 0; font-size: 0.85em; line-height: 1.5; }
.doku-arch-lines li { margin: 3px 0; padding: 2px 5px; border-radius: 4px; white-space: normal; }
.doku-arch-lines li:hover { background: rgba(59, 130, 246, 0.18); }
.doku-arch-lines a { color: #cbd5e1 !important; text-decoration: none !important; display: inline; }
.doku-arch-lines a:hover { color: #93c5fd !important; text-decoration: underline !important; }
.doku-arch-badge { display: inline-block; font-size: 0.75em; padding: 0 5px; margin-left: 4px; border-radius: 4px; background: rgba(59, 130, 246, 0.22); color: #93c5fd !important; border: 1px solid rgba(96, 165, 250, 0.35); }
details.doku-minimap { position: fixed; bottom: 18px; right: 18px; z-index: 9999; width: 265px; max-height: 76px; overflow: hidden; background: rgba(15, 23, 42, 0.94); border: 1px solid rgba(96, 165, 250, 0.65); border-radius: 10px; box-shadow: 0 8px 26px rgba(0, 0, 0, 0.65); backdrop-filter: blur(8px); transition: width 0.18s ease, max-height 0.18s ease; font-family: var(--vscode-font-family, sans-serif); }
details.doku-minimap:hover { border-color: #60a5fa; }
details.doku-minimap[open] { width: min(880px, 94vw); max-height: 84vh; overflow-y: auto; padding-bottom: 10px; }
details.doku-minimap > summary { cursor: pointer; list-style: none; padding: 8px 12px; font-weight: 700; font-size: 0.84em; color: #f8fafc; background: linear-gradient(90deg, rgba(37, 99, 235, 0.45), rgba(30, 41, 59, 0.9)); border-bottom: 1px solid rgba(148, 163, 184, 0.25); display: flex; align-items: center; justify-content: space-between; user-select: none; }
details.doku-minimap > summary::-webkit-details-marker { display: none; }
details.doku-minimap .minimap-preview-strip { display: flex; gap: 4px; padding: 5px 10px 7px 10px; font-size: 0.72em; color: #94a3b8; justify-content: space-between; }
details.doku-minimap[open] .minimap-preview-strip { display: none; }
details.doku-minimap .minimap-preview-strip span { background: rgba(30, 41, 59, 0.9); padding: 2px 6px; border-radius: 4px; border: 1px solid rgba(148, 163, 184, 0.25); }
details.doku-minimap .minimap-body { padding: 8px 12px 4px 12px; }
</style>
<details class="doku-minimap">
<summary><span>🏎️ AC-Doku-Minimap (SimRacer &amp; Sandbox)</span><span title="Klicken zum Vergrößern / Einklappen">⛶</span></summary>
<div class="minimap-preview-strip"><span>01 SimRacer</span><span>02 Sandbox</span><span>03 Agenten</span><span>04 AC-Sync</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root">🏎️ <a href="../README.md">Assetto Corsa Content &amp; SimRacer Architektur (Doku-Index)</a>  |  <a href="../../README.md">Repo-README</a>  |  <a href="../../ac-sandbox/README.md">AC-Sandbox</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🖥️ <a href="multi-pc-architektur-ki-agents-simracing.md">01_simracer_architektur (Hardware &amp; 4-PC-Netz)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="multi-pc-architektur-ki-agents-simracing.md">01 • 4-Knoten-Architektur (SimRacer, Cyborg, Omarchy, Pi)</a></li>
<li>├─ <a href="hardware-analyse-system-stabilitaet-docker-ki.md">02 • Hardware- &amp; Stabilitätsanalyse (Docker, KI &amp; VR)</a></li>
<li>├─ <a href="simracer-system-backup-wiederherstellung-veeam.md">03 • System-Backup &amp; Recovery (Veeam + Sekunden-Backup)</a> <a class="doku-arch-badge" href="../../ac-sandbox/backup-simracer-configs.ps1">Backup.ps1</a></li>
<li>└─ <a href="naechste-schritte-simracer-und-cyborg.md">04 • Roadmap &amp; Nächste Schritte (SimRacer &amp; Cyborg)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🐳 <a href="../02_docker_sandbox/SANDBOX_ANLEITUNG.md">02_docker_sandbox (ac-win11-sandbox &amp; sbx)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../02_docker_sandbox/SANDBOX_ANLEITUNG.md">01 • Handbuch: Remote Windows-11-Sandbox (192.168.178.68)</a> <a class="doku-arch-badge" href="../../ac-sandbox/start-sandbox.ps1">Start.ps1</a></li>
<li>├─ <a href="../02_docker_sandbox/inside-the-simracing-sandbox-guide.md">02 • Inside the SimRacing Sandbox &amp; Dark-Agent-Betrieb</a></li>
<li>├─ <a href="../02_docker_sandbox/docker-windows-steam-ki-agent-architektur.md">03 • Prüflabor für Content Manager, Pitfiles (.ini) &amp; KI</a></li>
<li>├─ <a href="../02_docker_sandbox/sandbox-umzug-skalierung-simracer.md">04 • 64-GB Sandbox-Umzug &amp; Skalierung auf 160 GB</a></li>
<li>└─ <a href="../02_docker_sandbox/docker-sbx-anleitung.md">05 • Docker Sandboxes CLI (sbx)</a> · <a href="../02_docker_sandbox/docker.md">Coding Agent Sandbox</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🤖 <a href="../03_agenten_system/agenten-system-architektur-uebersicht.md">03_agenten_system (5-Rollen-Verbund &amp; REPL)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../03_agenten_system/agenten-system-architektur-uebersicht.md">01 • KI-Agenten-Systemarchitektur &amp; 5-Rollen-Handbuch</a></li>
<li>├─ <a href="../03_agenten_system/agenten-konsolen-repl-autostart-und-asset-handshake.md">02 • Agenten-Konsolen (REPL), Auto-Start &amp; Handshake</a> <a class="doku-arch-badge" href="../../ac-sandbox/shared/agents/README.md">Shared-Agents</a></li>
<li>├─ <a href="../../.github/agents/general.agent.md">Ebene 1: @general</a> · <a href="../../.github/agents/light.agent.md">Ebene 2: @light</a> · <a href="../../.github/agents/rig.agent.md">@rig</a></li>
<li>└─ <a href="../../.github/agents/dark.agent.md">Ebene 3 (Gast): @dark</a> · <a href="../../.github/agents/sarah.agent.md">Pitwall: @sarah (Coach)</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">⚙️ <a href="../../ac-sandbox/LIGHT-AGENT-UND-AC-STRUKTUR.md">04_ac_sandbox_sync (7-Pakete, Presets &amp; Skripte)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../../ac-sandbox/LIGHT-AGENT-UND-AC-STRUKTUR.md">01 • Light Agent Anweisungen &amp; 7-Pakete AC-Struktur</a> <a class="doku-arch-badge" href="../../ac-sandbox/shared/scripts/sync-cm-github.ps1">Sync.ps1</a></li>
<li>├─ <a href="../../ac-sandbox/README.md">02 • AC-Sandbox Ordnerstruktur &amp; Bootstrap-Ablauf</a> <a class="doku-arch-badge" href="../../ac-sandbox/shared/scripts/bootstrap-guest.ps1">Bootstrap.ps1</a></li>
<li>├─ <a href="../../ac-sandbox/shared/presets_managed/README.md">03 • Managed Settings-Profile (Desktop vs. VR / CSP)</a></li>
<li>└─ <a href="../../ac-sandbox/LIVE-TRANSFER-STATUS.md">04 • Live-Transfer-Status</a> · <a href="../../ac-sandbox/shared/cm-github-sync/03_CM_AppData_Presets_Data/Data/README.md">CM AppData &amp; Presets</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
