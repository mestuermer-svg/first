# Detailkonzept: Sarah Coach (Soll-Vorgaben), Pitfile-Optimizer (.ini) & Agent-Fokus-Steuerung

> **Thema:** Technische Spezifikation für Echtzeit-Renncoaching, automatisierte Setup-/Pitfile-Berechnung und Fokus-Management zwischen lokalen KI-Agents im 4-PC-Verbund
> **Autor:** Michael Stürmer
> **Datum:** 04.11.2026

<details>
<summary><h2>1. Zielsetzung: Natives VR-Racing trifft KI-Renningenieurin</h2></summary>

Dieses Dokument definiert die operative Steuerung für das Assetto-Corsa-Setup:
1. **100 % Nativer Fahrbetrieb am SimRacer:** Gefahren wird direkt unter Windows 11 auf dem **SimRacer** mit dem **Fanatec ClubSport V2.5 Lenkrad** und der **HTC VIVE Focus Vision VR-Brille (120 Hz)**.
2. **Docker-Sandbox (`ac-win11-sandbox`) als Pitfile- & Skript-Labor (Zuständig: Light Agent):** In der Docker-Umgebung wird **nicht** gefahren; dort ist **Light Agent** zuständig und nutzt die Instanz als sichere Testbank zum Validieren von Content-Manager-Skripten, `race.ini`-Vorlagen und neuen Setup-Parsern.
3. **Sarah Coach Verstärkung (auf IdeaPad 5 mit Linux Omarchy):** Sarah arbeitet mit harten, numerischen **Soll-Vorgaben (`sarah_targets.json`)** und übernimmt zwei getrennte Aufgaben:
   * **Aufgabe A (Fahrer-Coaching):** Live-Sprachansagen (TTS) auf definierten Entlastungszonen (Geraden) bei Abweichungen von Bremspunkt, Trailbraking oder Traktion.
   * **Aufgabe B (Pitfile-Engineering):** Automatische Berechnung und Bereitstellung einer optimierten `.ini`-Setup-Datei (`Sarah_Opt_Stint.ini`) für den nächsten Boxenstopp.

</details>

<details>
<summary><h2>2. Fokus-Steuerung zwischen den lokalen KI-Agents (3 Betriebsmodi)</h2></summary>

Um zu verhindern, dass Hintergrund-Agents während einer VR-Session Rechenzeit auf dem SimRacer verbrauchen oder gleichzeitig an denselben `.ini`-Dateien schreiben, regelt ein zentraler Status-Topic auf dem **Raspberry Pi 4 (Arch Linux)** (`simrig/mode`) den Fokus aller lokalen Agents:

<details>
<summary><h3>2.1 Übersicht der 3 Fokus-Zustände</h3></summary>

| Betriebsmodus | Auslöser (Trigger) | Aktiver Agent im Fokus | Pausierte / Gesperrte Prozesse |
| :--- | :--- | :--- | :--- |
| **`ENGINEERING`** | `acs.exe` läuft **nicht** am SimRacer | **Light Agent (Docker-Sandbox `ac-win11-sandbox`)** & CM-Agent (VanstrikeCyborg + SimRacer `192.168.178.68`) | Live-Voice-Ausgabe von Sarah Coach ist stummgeschaltet. |
| **`LIVE_RACE`** | `acs.exe` läuft **und** Fahrzeug ist auf der Strecke (`IsInPit == 0`) | **Sarah Coach – Live Telemetry & Voice** (auf IdeaPad 5 unter Linux Omarchy) | Docker-Sandbox (`ac-win11-sandbox` / Light Agent) & lokale LLMs am SimRacer werden **pausiert** (100 % VR-Schutz!). Schreibsperre auf aktive Setup-Dateien. |
| **`PITBOX_SETUP`** | `acs.exe` läuft **und** Fahrzeug steht in der Box (`IsInPit == 1`) | **Sarah Coach – Pitfile-Optimizer** + **RPi 4 Setup-Sync** | Sprach-Callouts für Kurven sind pausiert; Sarah generiert `Sarah_Opt_Stint.ini` und gibt ein kurzes Setup-Briefing. |

</details>

<details>
<summary><h3>2.2 Automatischer Fokus-Wächter für den SimRacer (<code>watch-sim-focus.ps1</code>)</h3></summary>

Auf dem **SimRacer** prüft ein leichtgewichtiges PowerShell-Skript alle 3 Sekunden, ob die echte Rennsimulation (`acs.exe`) gestartet wurde, und schützt sofort die VR-Frametimes:

```powershell
# Wenn acs.exe startet -> Docker-Sandbox pausieren für 100% VR-Leistung
if (Get-Process -Name "acs" -ErrorAction SilentlyContinue) {
    docker pause ac-win11-sandbox 2>$null
} else {
    docker unpause ac-win11-sandbox 2>$null
}
```

</details>

</details>

<details>
<summary><h2>3. Sarah Coach Verstärkung: Harte Soll-Vorgaben & Regel-Matrix</h2></summary>

Damit **Sarah Coach** nicht vage halluziniert, sondern wie ein echter Renningenieur am Kommandostand präzise Werte vorgibt, erhält sie eine strukturierte Sollwert-Matrix (`sarah_targets.json`) pro Fahrzeugklasse (z. B. GT3) und Strecke:

<details>
<summary><h3>3.1 Telemetrie-Sollwerte & Schwellwerte (Was Sarah überwacht)</h3></summary>

| Messgröße (AC Shared Memory) | Soll-Fenster (GT3 Referenz) | Toleranz / Schwellwert | Aktion: Fahrer-Coaching (Voice) | Aktion: Pitfile-Anpassung (`.ini`) |
| :--- | :---: | :---: | :--- | :--- |
| **Heißdruck Reifen (`WheelsPressure`)** | **26.5 PSI** (oder modellspezifisch) | $\pm 0.3\text{ PSI}$ (nach $\ge 3$ Runden) | Info bei $> \pm 0.8\text{ PSI}$: *„Vorne links 1 PSI zu hoch, Reifen überfährt.“* | Pro $0.9\text{ PSI}$ Abweichung den Kaltdruck `PRESSURE_LF/RF/LR/RR` gegenläufig um **1 Klick / PSI** korrigieren. |
| **Reifentemperatur (`TyreCoreTemp`)** | **75 °C – 90 °C** | $< 70\text{ °C}$ (kalt) / $> 98\text{ °C}$ (heiß) | Bei $> 98\text{ °C}$: *„Hinterachse überhitzt am Ausgang, sanfter ans Gas.“* | Spur (`TOE`) oder Sturz (`CAMBER`) entschärfen, Traktionskontrolle (`TC`) +1 Klick. |
| **Sturz-Spread (`Temp Inner - Outer`)** | **5 °C – 10 °C** (Innen wärmer als Außen) | $> 14\text{ °C}$ Spread / $< 3\text{ °C}$ Spread | — (Reines Setup-Thema) | Spread $> 14\text{ °C}$: Weniger negativer Sturz (`CAMBER`). Spread $< 3\text{ °C}$: Mehr negativer Sturz für Kurvengrip. |
| **Bremspunkt-Konstanz (`NormalizedCarPosition`)** | Strecken-Referenzpunkt pro Kurve | Streuung $\sigma > 5.0\text{ m}$ | *„Bremspunkt Kurve 1 streut um 7 Meter. Fixpunkt bei 100m-Schild halten.“* | Falls Räder beim Anbremsen blockieren: `FRONT_BIAS` um `0.5 %` bis `1.0 %` anpassen. |
| **Traktionsverlust Kurvenausgang (`WheelSlip` HA)** | $< 0.12$ | $> 0.20$ in $\ge 3$ aufeinanderfolgenden Runden | *„Zu viel Schlupf Hinterachse Ausgang La Source, Lenkung früher öffnen.“* | Heckflügel `WING_2` +1 Klick oder Stabilisator hinten (`ARB_REAR`) 1 Klick weicher. |
| **Kraftstoffverbrauch (`Fuel` pro Runde)** | $\varnothing\text{ Verbrauch} \times \text{Restrunden} + 1.2\text{ Rd.}$ | $< 0.8\text{ Runden}$ Reserve | *„Sprit knapp: 1.5 Liter fehlen bis Ziel, Lift and Coast vor Kurve 5.“* | Berechnet exakten Wert `[FUEL] VALUE=` für das nächste Boxenstopp-Pitfile. |

</details>

<details>
<summary><h3>3.2 Kommunikations-Disziplin (Anti-Quassel-Regeln für VR)</h3></summary>

Wenn du mit der VIVE Focus Vision VR-Brille am Limit fährst, darf ein Sprach-Coach niemals in der Anbremszone oder am Scheitelpunkt sprechen:
1. **Strikte Sperrzonen (Silent Zones):** Sobald `Brake > 0.15` oder die Querbeschleunigung $|G_{lat}| > 1.2\,g$ beträgt, hält Sarah **absolut Funkstille** (Ausnahme: kritischer Schaden oder leerer Tank).
2. **Freigabezonen (Talk Windows):** Sprachausgaben erfolgen ausschließlich auf definierten Geraden (`NormalizedCarPosition`-Bereiche mit `Gas > 0.90` und $|G_{lat}| < 0.3\,g$).
3. **Maximal 1 Korrektur pro Sektor:** Maximal 12 Wörter pro Funkspruch im klaren Renningenieur-Stil (*„Sektor 2: 0.25 Sekunden verloren. Eingang Les Combes 8 km/h zu schnell, Untersteuern.“*).

</details>

<details>
<summary><h3>3.3 Beispiel-Konfiguration: <code>sarah_targets.json</code></h3></summary>

```json
{
  "profile_name": "GT3_Spa_Baseline",
  "car_id": "ks_mercedes_amg_gt3",
  "track_id": "spa",
  "tyre_targets": {
    "target_hot_psi_front": 26.5,
    "target_hot_psi_rear": 26.5,
    "psi_tolerance": 0.3,
    "optimal_core_temp_c": [75.0, 90.0],
    "optimal_inner_outer_spread_c": [5.0, 10.0]
  },
  "driving_targets": {
    "max_brake_point_stddev_meters": 5.0,
    "max_exit_wheelslip_rear": 0.18,
    "fuel_safety_margin_laps": 1.2
  },
  "talk_windows_spline": [
    { "name": "Kemmel Straight", "start": 0.17, "end": 0.28 },
    { "name": "Blanchimont Approach", "start": 0.78, "end": 0.86 }
  ]
}
```

</details>

</details>

<details>
<summary><h2>4. Der Pitfile-Workflow: Von der Telemetrie zur fertigen <code>.ini</code> im Content Manager</h2></summary>

<details>
<summary><h3>4.1 Aufbau eines Assetto-Corsa-Pitfiles (<code>.ini</code>)</h3></summary>

Assetto Corsa und der Content Manager speichern Fahrzeug-Setups als Klartext-INI-Dateien unter:
`C:\Users\strik\Documents\Assetto Corsa\cfg\setups\<car_name>\<track_name>\<setup_name>.ini`

Typische Struktur, die der **Pitfile-Optimizer** direkt liest und schreibt:
```ini
[PRESSURE_LF]
VALUE=20

[PRESSURE_RF]
VALUE=21

[PRESSURE_LR]
VALUE=19

[PRESSURE_RR]
VALUE=20

[FUEL]
VALUE=42

[WING_1]
VALUE=3

[WING_2]
VALUE=6

[FRONT_BIAS]
VALUE=57
```

</details>

<details>
<summary><h3>4.2 Ablauf zwischen Docker-Sandbox, Sarah Coach und dem echten SimRacer</h3></summary>

1. **Vor dem Rennen (Trockentest in der Docker-Sandbox):**
   * Ein neuer Setup-Generator oder ein Content-Manager-Skript wird zuerst in der `ac-win11-sandbox` an Test-INI-Dateien ausprobiert.
2. **Während des Stints (Live-Messung durch Sarah Coach):**
   * Du fährst nativ am SimRacer mit deiner Basis-Datei `Baseline_VR.ini`.
   * Sarah sammelt auf dem IdeaPad 5 über 4–5 gezeitete Runden die stabilisierten Heißdrücke, Kerntemperaturen und den Durchschnittsverbrauch.
3. **Beim Einkehren in die Box (`PITBOX_SETUP`):**
   * Das Python-Skript `sarah_pitfile_optimizer.py` liest `Baseline_VR.ini`, wendet die Korrekturformeln gegen `sarah_targets.json` an und schreibt automatisch `Sarah_Opt_Stint2.ini` in deinen Setup-Ordner.
   * Im VR-Headset wählst du im Setup-Menü mit einem Klick `Sarah_Opt_Stint2` aus und fährst mit perfekt korrigierten Drücken und exakt berechnetem Sprit wieder auf die Strecke.

</details>

</details>

<details>
<summary><h2>5. Umsetzungs-Logbuch (Erledigte Aufgaben) & Master-Checkliste (Next Steps)</h2></summary>

<details>
<summary><h3>5.1 Erledigte Meilensteine (Stand: 05.11.2026)</h3></summary>

#### Phase 1: SimRacer Basis-Infrastruktur, Netzwerk & Backups (`192.168.178.68`)
- [x] **OpenSSH-Server (`sshd`) auf SimRacer aktiviert:** Dienst auf `Automatic` gesetzt, Firewall-Port `22` freigegeben und passwortlosen SSH-Key-Login (`id_ed25519`, `administrators_authorized_keys`) für `Mike@192.168.178.68` eingerichtet.
- [x] **SSH-Konfiguration auf VanstrikeCyborg (`~/.ssh/config`):** Host-Aliases `simracer` (`Mike@192.168.178.68:22`) und `ac-sandbox` (`Docker@192.168.178.68:2222`) hinterlegt.
- [x] **Erstes automatisches Pitfile- & Config-Backup auf `D:` durchgeführt:** Snapshot `D:\Backups\SimRacer_Configs\2026-11-04_17-37` (inkl. Assetto Corsa `cfg`/Setups, Content Manager/CSP-Profilen und Fanatec-Profilen) erstellt sowie `D:\Backups\Veeam_Exclusions.txt` abgelegt.
- [x] **Fokus-Wächter vorbereitet:** `C:\ac-sandbox\watch-sim-focus.ps1` erstellt und auf den SimRacer übertragen (pausiert `ac-win11-sandbox` automatisch, sobald `acs.exe` für ein VR-Rennen startet).

#### Phase 2: 64-GB Sandbox-Migration, Docker Desktop & `D:`-Festplatten-Verknüpfung
- [x] **64 GB Windows-11-Image (`data.img`) + Shared-Tools übertragen:** Vollständige Übertragung (100 % / 64,00 GB) vom VanstrikeCyborg nach `C:\ac-sandbox` auf der internen 1-TB-NVMe des SimRacers abgeschlossen.
- [x] **Docker Desktop (`v4.98.0`) auf SimRacer installiert & angemeldet:** Docker Engine `29.9.2` und Docker Compose `v5.6.1` installiert, Google-Login durchgeführt und `dockurr/windows:latest` geladen.
- [x] **KVM-Hardwarebeschleunigung (`kvm_amd`) aktiviert:** Nested Virtualization für den AMD Ryzen 9 3900X in `C:\Users\Mike\.wslconfig` (`nestedVirtualization=true`, `kernelCommandLine=kvm_amd.nested=1`) und im WSL2-Kernel (`/dev/kvm`, `KVM: "Y"`) freigeschaltet.
- [x] **Verknüpfung der `D:`-Festplatte (Host & Container) hergestellt:**
  - **Host-Level (NTFS-Junction):** `D:\ac-sandbox` $\rightarrow$ `C:\ac-sandbox` sowie Desktop-Verknüpfung `AC-Sandbox (C_ac-sandbox).lnk` eingerichtet.
  - **Container-Bind-Mounts (`docker-compose.yml`):**
    - `D:/Backups:/shared/D_Backups` (`\\host.lan\Data\D_Backups`)
    - `D:/SteamLibrary:/shared/D_SteamLibrary` (`\\host.lan\Data\D_SteamLibrary`)
    - `C:/Users/Mike/Documents/Assetto Corsa/cfg:/shared/Native_AC_cfg` (`\\host.lan\Data\Native_AC_cfg`)
- [x] **Port-Entkopplung & Container-Start (`ac-win11-sandbox`):**
  - RDP-Port der Sandbox auf **`3390`** (`0.0.0.0:3390->3389/tcp+udp`) verlegt, damit der native Windows-Remotedesktop des SimRacers (`3389`) konfliktfrei bleibt.
  - Container mit **8 CPU-Kernen**, **12 GB RAM** und **160 GB Disk-Image** gestartet; Web-VNC (`http://192.168.178.68:8006`), RDP (`192.168.178.68:3390`) und SSH-Bridge (`192.168.178.68:2222`) sind live erreichbar.

#### Phase 3: Remote-Autostart-Härtung (Session 1 / KVM) & VS Code Containers-Integration (05.11.2026)
- [x] **Session-0-Isolations-Fix für Docker Desktop via SSH (`StartDockerDesktopInteractive`):** Da ein direkter `Start-Process`-Aufruf über SSH in der nicht-interaktiven Windows-Dienstsitzung (**Session 0**) landet, startet `ac-sandbox/start-sandbox.ps1` nun zuerst den Dienst `com.docker.service` und triggert `Docker Desktop.exe` über den Windows Taskplaner (`Register-ScheduledTask` mit `-LogonType Interactive`) direkt auf dem Benutzer-Desktop (**Session 1**) von `Mike` am SimRacer.
- [x] **Automatisches Laden des KVM-Kernelmoduls (`kvm_amd`) nach WSL2-Kaltstart:** Vor `docker compose up -d` führt `start-sandbox.ps1` automatisch `wsl -d docker-desktop -u root -e modprobe kvm_amd` sowie `chmod 666 /dev/kvm` aus, damit `/dev/kvm` nach jedem Neustart von Docker Desktop sofort bereitsteht.
- [x] **Remote Docker Context (`simracer`) für VS Code Containers-Erweiterung eingerichtet:** Auf dem VanstrikeCyborg wurde der Docker-Kontext `simracer` (`ssh://Mike@192.168.178.68`) erstellt, als Standard aktiviert und in `start-sandbox.ps1` hinterlegt. Dadurch zeigt die **VS Code Containers-Erweiterung** auf dem Laptop den Container `ac-win11-sandbox` vom SimRacer direkt an und erlaubt Start/Stop/Logs ohne lokales Docker Desktop.
- [x] **Startskript synchronisiert:** Die aktualisierte `start-sandbox.ps1` ist sowohl lokal (`C:\Users\strik\git-labor\ac-sandbox\start-sandbox.ps1`) als auch auf dem SimRacer (`\\192.168.178.68\ac-sandbox\start-sandbox.ps1`) synchron.
- [x] **Content Manager & Assetto Corsa ordnerweise auf GitHub synchronisiert (`sync-cm-github.ps1`):**
  - Da GitHub komplette Steam-Spielordner wegen großer Binärdateien (`> 100 MB`, z. B. `.kn5` 3D-Modelle, `.dds` 16K-Texturen, `.bank` Audio, `libcef.dll` 158 MB) ablehnt, trennt `ac-sandbox/shared/scripts/sync-cm-github.ps1` automatisch alle relevanten Daten in **7 GitHub-kompatible Ordner-Pakete** (`3.590 Dateien`, insgesamt `39,83 MB`) unter `ac-sandbox/shared/cm-github-sync/`:
    1. `01_Documents_AC_Setups` (`424 Dateien` | `0,43 MB` – alle `.ini`-Pitfiles & Fahrzeug-Setups)
    2. `02_Documents_AC_Cfg` (`256 Dateien` | `1,83 MB` – `race.ini`, `controls.ini`, `video.ini`, CSP-User-Configs)
    3. `03_CM_AppData_Presets_Data` (`1.996 Dateien` | `16,65 MB` – Content Manager Presets, Profile & User-Daten ohne Browser-Cache)
    4. `04_Steam_AC_Cfg` (`142 Dateien` | `1,18 MB` – Steam `cfg`, `system/cfg`, `server/cfg`)
    5. `05_Steam_AC_Apps_Python` (`61 Dateien` | `2,04 MB` – Python-Apps aus `steamapps/common/assettocorsa/apps/python`)
    6. `06_Steam_AC_Extension_Lua_Config` (`710 Dateien` | `6,80 MB` – Custom Shaders Patch Lua-Skripte & Configs ohne `.kn5`)
    7. `07_Content_Manager_Binary` (`1 Datei` | `10,90 MB` – `Content Manager.exe`)
  - Alle 7 Pakete wurden in einzelnen Commits erfolgreich nach GitHub (`origin/main`) hochgeladen und stehen rechnerübergreifend auf **VanstrikeCyborg**, **SimRacer** und in der **Docker-Sandbox** zur Verfügung.

#### Phase 4: Gast-Konfiguration & Live-Inbetriebnahme der Windows-11-Sandbox (05.11.2026)
- [x] **Gast-Partition `C:` auf 160 GB erweitert:** Recovery-Partition (Partition 4) per `diskpart override` entfernt, Partition C: auf **159,86 GB** erweitert und Windows Explorer neu gestartet. Gast zeigt nun **125 GB frei von 159 GB**.
- [x] **OpenSSH-Server (`sshd`) im Windows-11-Gast installiert & betriebsbereit:** OpenSSH MSI unattended installiert, Host-Keys per `ssh-keygen -A` erzeugt, Dienst `sshd` auf `Automatic` gesetzt und gestartet (Status `Running`, Port 22 lauscht auf `0.0.0.0` / `[::]`).
- [x] **SSH-Key-Authentifizierung im Gast eingerichtet:** Ed25519-Public-Key für `strik@VanstrikeCyborg` in `administrators_authorized_keys` und `C:\Users\Docker\.ssh\authorized_keys` hinterlegt und Berechtigungen fixiert.
- [x] **Content Manager & Assetto Corsa Verzeichnisse im Gast bereitgestellt:**
  - `Content Manager.exe` auf dem Desktop und unter `C:\AssettoCorsa\` platziert.
  - Alle 7 Ordner-Pakete (`Documents\Assetto Corsa\setups`, `cfg`, `AppData\Local\AcTools Content Manager` Presets & Data, Steam `cfg`, `system/cfg`, `server/cfg`, Python-Apps) per Robocopy ins Gastsystem synchronisiert.
- [x] **Netzwerk-Mounts & Autostart-Bootstrap verifiziert:** Zugriff auf `\\host.lan\Data\D_Backups`, `\\host.lan\Data\D_SteamLibrary` und `\\host.lan\Data\Native_AC_cfg` erfolgreich geprüft; `ac-sandbox-bootstrap.bat` im Autostart-Ordner hinterlegt; Status-Report `guest-status.json` erzeugt.

</details>

<details>
<summary><h3>5.2 Master-Checkliste: Nächste Arbeitsschritte (Next Steps)</h3></summary>

#### Block A: Feinschliff & Automatisierung in der Windows-11-Sandbox (`ac-win11-sandbox`)
- [x] **A.1 Gast-Partition `C:` auf 160 GB erweitern:** Erfolgreich durchgeführt (159,86 GB gesamt, 125 GB frei).
- [x] **A.2 OpenSSH-Server im Windows-11-Gast aktivieren:** Erfolgreich installiert, Host-Keys generiert und Dienst gestartet (Status `Running`).
- [x] **A.3 Content Manager & AC-Strukturen im Gast einrichten:** Vollständig synchronisiert, Content Manager auf Desktop und Zugriff auf alle Host-Volumes (`D_Backups`, `D_SteamLibrary`, `Native_AC_cfg`) bestätigt.
- [ ] **A.4 Python 3.11 & Skript-Runner im Gast ergänzen:** Python 3.11 (via `winget` oder lokales Installationspaket) installieren für direkte Ausführung von Pitfile-Generatoren und Telemetrie-Validatoren im Gast.

#### Block B: SimRacer Host-Automatisierung & Systemsicherung (Veeam)
- [ ] **B.1 Fokus-Wächter (`watch-sim-focus.ps1`) als Autostart-Task registrieren:** Geplante Aufgabe (`SimRacer-Focus-Watchdog`) für Benutzer `Mike` anlegen, damit `ac-win11-sandbox` beim Start von `acs.exe` vollautomatisch pausiert (`LIVE_RACE`) und nach Rennende wieder fortgesetzt wird (`ENGINEERING`).
- [ ] **B.2 Tägliches Pitfile-Backup (`backup-simracer-configs.ps1`) automatisieren:** Task-Scheduler-Job auf dem SimRacer einrichten, der täglich (oder bei Systemstart) einen Snapshot nach `D:\Backups\SimRacer_Configs` schreibt.
- [ ] **B.3 Lokale Sandbox-Rohdaten am VanstrikeCyborg archivieren/freigeben:** Nach erfolgreichem Dauerbetrieb auf dem SimRacer die alte 64-GB-Datei `C:\Users\strik\git-labor\ac-sandbox\storage\data.img` auf dem Laptop bereinigen (spart 64 GB NVMe-Speicher auf dem Cyborg) bzw. ein Cold-Backup nach `D:\Backups\ac-sandbox` auf dem SimRacer legen.
- [ ] **B.4 Veeam Agent Free Bare-Metal-Backup erstellen:** Bootfähigen USB-Rettungsstick erstellen und erstes System-Image von `C:` (mit den vorbereiteten Pfaden aus `D:\Backups\Veeam_Exclusions.txt`) nach `D:\Backups\Veeam_OS` sichern.

#### Block C: Telemetrie-Brücke, Raspberry Pi 4 & Sarah Coach (IdeaPad 5 Omarchy)
- [ ] **C.1 AC Shared-Memory Telemetrie-Sender am SimRacer einrichten:** Leichtgewichtiges Python-Skript (`ac_telemetry_sender.py`) auf dem SimRacer bereitstellen, das `acpmf_physics`, `acpmf_graphics` und `acpmf_static` ausliest und per UDP/MQTT ins LAN streamt.
- [ ] **C.2 Raspberry Pi 4 (Arch Linux) als Edge-Broker konfigurieren:** Mosquitto MQTT-Broker (`simrig/mode`, `simrig/telemetry`) und zentrales Git-/Setup-Sync-Repository in Betrieb nehmen.
- [ ] **C.3 Sarah Coach & Pitfile-Optimizer implementieren:**
  - Referenzdatei `sarah_targets.json` (Soll-Fenster für Reifendruck, Kerntemperatur, Sturz-Spread, Bremspunkte und Talk-Windows) anlegen.
  - Python-Modul `sarah_pitfile_optimizer.py` erstellen, das nach einem Stint aus `Baseline_VR.ini` + Telemetrie automatisch `Sarah_Opt_Stint.ini` berechnet und in `C:\Users\Mike\Documents\Assetto Corsa\cfg\setups\` ablegt.
- [ ] **C.4 Trockentest & End-to-End-Validierung:** Einen kompletten Zyklus (`ENGINEERING` $\rightarrow$ `LIVE_RACE` $\rightarrow$ `PITBOX_SETUP`) inklusive automatischer Pausierung der Docker-Sandbox und Generierung eines `.ini`-Pitfiles testen.

</details>

</details>

<details>
<summary><h2>6. Weiterführende Dokumente & Verknüpfungen</h2></summary>

* [4-Knoten-Architektur & Einsatzkonzept (SimRacer, Cyborg, IdeaPad Omarchy, RPi 4)](./multi-pc-architektur-ki-agents-simracing.md)
* [Architektur & VS Code Multi-PC-Anleitung (Localhost, Remote-SSH & Workspaces)](./uebersicht-vscode-agent-localhost-gemini-antigravity.md)
* [Praxisanleitung: System-Image (Veeam) & Pitfile-Schnellbackup für SimRacer](./simracer-system-backup-wiederherstellung-veeam.md)
* [Docker Windows-11 Sandbox: Prüflabor für Content Manager & KI-Agenten](./docker-windows-steam-ki-agent-architektur.md)

</details>

---
*Hinweis zur Organisation:* Die erstellte Dokumentation ist am Drehlaufwerk abgelegt und mit einer kurzen Zusammenfassung von den Chips auch in den Notebooks verlinkt.