# Version 1.0 - Initiale Inbetriebnahme

---

# Version 1.1 – Diagnose & Behebung der 160-GB-Partitionserweiterung in der Docker-Sandbox (`ac-win11-sandbox`)
**Datum:** 06.11.2026  
**Systeme im Verbund:** `VanstrikeCyborg` (VS Code Multi-Root-Workspace) $\leftrightarrow$ `SimRacer` (`192.168.178.68`) $\leftrightarrow$ `ac-win11-sandbox` (`WIN-54U68T9T2FA`, Light Agent)

## 1. Fehlerbild (anhand der 4 Diagnose-Screenshots)
1. **Windows 11 `System > Info`:** Zeigte bereits korrekt **160 GB Speicher**, **12,0 GB RAM** und **AMD Ryzen 9 3900X** an.
2. **Windows Explorer (`Dieser PC`) & Eigenschaften von `C:`:** Zeigten für `Windows (C:)` weiterhin einen roten Balken mit **`4,46 GB frei von 62,9 GB`** (`58,4 GB belegt`).
3. **Netzlaufwerk `Data (\\host.lan) (Z:)`:** Wurde im Explorer mit einem **roten `X`** als getrennt markiert.
4. **Steam Client im Container:** Meldete beim Download von **Assetto Corsa (13,2 GB)** in Rot: **`NICHT GENÜGEND FREIER SPEICHERPLATZ`**.
5. **Lokale `docker-compose.yml`:** Stand im lokalen Repo `assetto-corsa-content/ac-sandbox/docker-compose.yml` noch auf den alten Laptop-Werten (`DISK_SIZE: "64G"`, `RAM_SIZE: "4G"`, `CPU_CORES: "4"`, `KVM: "N"`).

## 2. Technische Ursache (Root Cause)
* Auf der virtuellen 160-GB-QEMU-Festplatte (`Disk 0`) lag direkt hinter der primären Systempartition `Partition 3 (C:, 62,9 GB)` bei Offset `63 GB` eine **799 MB große versteckte Windows-Wiederherstellungspartition (`Partition 4`)**.
* Da `diskpart extend` und `Resize-Partition` eine Partition nur in **direkt angrenzenden** unzugeordneten Speicherplatz vergrößern können, blockierte `Partition 4` die Nutzung der neuen ~97 GB am Ende der Festplatte.

## 3. Durchgeführte Korrekturen
1. **Lokale `docker-compose.yml` synchronisiert:**
   * `c:\Users\strik\assetto-corsa-content\ac-sandbox\docker-compose.yml` vollständig an `docker-compose.simracer.yml` angeglichen (`DISK_SIZE: "160G"`, `RAM_SIZE: "12G"`, `CPU_CORES: "8"`, `KVM: "Y"`, Ports `8006`, `3390`, `2222` & Volume-Mounts).
2. **Blockierende Recovery-Partition (`Partition 4`) entfernt & `C:` auf 159,75 GB erweitert:**
   * Über die SSH-Bridge (`ssh -p 2222 Docker@192.168.178.68`) im Gast `WIN-54U68T9T2FA`:
     * `reagentc /disable` ausgeführt.
     * Per `diskpart` (`select disk 0` $\rightarrow$ `select partition 4` $\rightarrow$ `delete partition override` $\rightarrow$ `select volume C` $\rightarrow$ `extend`) die Blockade gelöst.
   * **Ergebnis:** `Windows (C:)` hat jetzt **159,75 GB Gesamtkapazität** und **100,51 GB freien Speicherplatz** (blauer Balken im Explorer).
3. **Netzlaufwerk `Z:` (`\\host.lan\Data`) in der Benutzersitzung neu verbunden:**
   * `net use Z: \\host.lan\Data /persistent:yes` ausgeführt – das rote `X` ist behoben (`125 GB frei von 930 GB`).
4. **Autostart-Skript (`ac-sandbox/shared/scripts/bootstrap-guest.ps1`) gehärtet:**
   * Prüft beim Start automatisch, ob `C:` kleiner als 150 GB ist, löscht bei Bedarf `Partition 4`, erweitert `C:`, verbindet `Z:` und aktualisiert `guest-status.json` (398 Setup-INIs, 256 AC-Configs, 91 CM-Presets, 5 Python-Apps synchron).

---

# Version 1.2 – Multi-Agenten-Architektur: Dark Agent (In-Container) & Rig Agent (SimRacer Host-Hub)
**Datum:** 06.11.2026  
**Systeme:** `VanstrikeCyborg` (Light Agent) $\leftrightarrow$ `SimRacer` (Rig Agent) $\leftrightarrow$ `ac-win11-sandbox` (Dark Agent) $\leftrightarrow$ `Sarah Coach`

## 1. Ausgangslage & Ziel
* Bereitstellung spezialisierter Agenten für den isolierten Windows-11-Gast der Docker-Sandbox (**Dark Agent**) und den physischen Host am SimRacer (**Rig Agent**).
* Ziel: Nahtloses Überwachen von SteamVR, GPU (RTX 5070 Ti) und `acs.exe` sowie automatisches Verlinken (`mklink /J`) von in `race.ini` verwendeten Autos und Strecken in die Sandbox, ohne 500 GB zu duplizieren.

## 2. Umgesetzte Komponenten
1. **Dark Agent (In-Container-Spezialist `agents/dark/`):**
   * `.github/agents/dark.agent.md` in beiden Repositories angelegt.
   * `runner.ps1`: Lokaler Ausführer für Status, Setup-Validierung, App-Tests, Content Manager Start/Stopp und Gast-Wartung.
   * `worker.ps1`: Task-Queue-Dienst (`inbox/` $\rightarrow$ `outbox/` $\rightarrow$ `logs/`).
   * `Invoke-DarkAgent.ps1`: Host-Brücke vom Laptop über SSH (Port 2222).
2. **Rig Agent (SimRacer Nativer Host & Hub `scripts/rig-hub.ps1`):**
   * `.github/agents/rig.agent.md` in beiden Repositories angelegt.
   * `rig-hub.ps1`: Überwachung von SteamVR (`vrserver`, `vrmonitor`), `acs.exe`, Fanatec-Peripherie und RTX 5070 Ti (GPU/VRAM via `nvidia-smi`).
   * **Auto-Provisioning (`AutoProvisionFromRaceIni`):** Liest die aktive `race.ini` (`MODEL=`, `TRACK=`) aus und legt automatisch Verzeichnis-Junctions (`mklink /J`) in `C:\ac-sandbox\shared\content\cars` und `tracks` an, falls noch nicht vorhanden.
   * `Invoke-RigAgent.ps1`: Host-Brücke vom Laptop über SSH (Port 22).
3. **Sandbox Bootstrap & Statusbericht:**
   * `bootstrap-guest.ps1` bindet bereitgestellte Autos und Strecken aus `\\host.lan\Data\content` automatisch in `C:\AssettoCorsa\content\cars` und `tracks` ein und erfasst sie in `guest-status.json`.
4. **Dokumentation:**
   * Handbuch `LIGHT-AGENT-UND-AC-STRUKTUR.md` und Architekturkonzept `multi-pc-architektur-ki-agents-simracing.md` aktualisiert.

---

# Version 1.3 – Boot-Verhalten, QEMU/KVM-Lebenszyklus & In-Guest Python 3.11 Härtung
**Datum:** 06.11.2026  
**Systeme:** `VanstrikeCyborg` (Light Agent) $\leftrightarrow$ `SimRacer` (Rig Agent) $\leftrightarrow$ `ac-win11-sandbox` (Dark Agent)

## 1. Diagnose & Analyse: Scheinbarer Boot-Hänger der Sandbox
1. **Symptom:**  
   Nach einem Neustart (`docker restart`, `docker compose up -d` oder manuellem Start) wirkt die Sandbox für 60 bis 90 Sekunden so, als würde der Bootloader hängen. Weder SSH (Port 2222) noch Netzwerkbefehle antworten in dieser Zeit.
2. **Technische Ursache (Root Cause):**  
   * Die Windows-11-Instanz läuft in `dockurr/windows` virtualisiert unter **QEMU mit KVM-Beschleunigung** (`qemu-system-x86_64 -enable-kvm`).
   * Während des Kaltstarts durchläuft Windows 11 die UEFI-Boot-Phase (`BdsDxe: loading/starting Boot0005 "Windows Boot Manager"`), lädt den Windows-Kernel, initialisiert Treiber und fordert erst ganz am Ende der Startsequenz eine DHCP-IP an.
   * `dnsmasq` im Container weist die IP `172.30.0.2` erst zu, wenn der DHCPREQUEST-Handshake stattfindet (`DHCPACK 172.30.0.2 windows`).
   * **Erkenntnis:** Dieser Zeitraum (60–90 s) ist bei einer vollwertigen virtualisierten Windows-11-Enterprise-Instanz **völlig normal**. Verfrühte manuelle Resets oder Unterbrechungen in dieser Phase führen zu Dateisystem-Checks und verzögern den Boot zusätzlich.
3. **Diagnose- und Kontroll-Methoden:**
   * **Live-Screendump über QEMU-Monitor:** Über `/shared/take_screen.py` kann jederzeit ohne VNC ein Screendump der VM über den Unix-Domain-Socket `/run/shm/monitor.sock` als PNG (`screen_now.png`) exportiert werden.
   * **DHCP-Status:** `docker exec ac-win11-sandbox tail -f /var/log/dnsmasq.log` zeigt sekundengenau an, wann Windows 11 seine Netzwerkverbindung aktiviert.
   * **Sauberes Reset-Kommando:** Wenn ein Neustart zwingend erforderlich ist, immer über Docker Compose (`docker compose -f C:/ac-sandbox/docker-compose.simracer.yml down` und `up -d`), um hängende Prozesse sauber zu terminieren.

## 2. Installation & Konfiguration von Python 3.11 im Gast
1. **Paketinstallation:**
   * Python 3.11.9 (64-Bit) wurde erfolgreich im Windows-11-Gast unter `C:\Program Files\Python311` installiert.
2. **Bypass der Microsoft Store AppExecutionAliases:**
   * Da Windows 11 unkonfigurierte Aufrufe von `python` in den Microsoft Store umleitet, wurden direkte symbolische Verknüpfungen gesetzt:
     * `C:\Windows\python.exe` $\rightarrow$ `C:\Program Files\Python311\python.exe`
     * `C:\Windows\pip.exe` $\rightarrow$ `C:\Program Files\Python311\Scripts\pip.exe`
   * **Ergebnis:** `python --version` meldet global `Python 3.11.9` und `pip --version` meldet `pip 24.0`. Damit können Telemetrie-Skripte, Pitfile-Generatoren und In-Guest-Tests direkt von `Dark Agent` ausgeführt werden.

## 3. Dark Agent Härtung (Syntax & Ausführungsrichtlinie)
1. **Syntax-Korrektur in `runner.ps1`:**
   * Tippfehler `[ValidateSetSet(...)]` auf `[ValidateSet(...)]` korrigiert.
2. **PowerShell-Ausführungsrichtlinie:**
   * Befehlsaufrufe im Gast laufen mit `-ExecutionPolicy Bypass` bzw. `-Scope LocalMachine -ExecutionPolicy RemoteSigned`.
3. **Live-Validierung:**
   * Dark Agent Status erfolgreich abgerufen: Hostname `WIN-54U68T9T2FA`, freier Speicher auf C: `93,37 GB` von `159,75 GB`, freier RAM `9.303 MB`, Netzlaufwerk `\\host.lan\Data` aktiv.

## 4. Host-Stabilität & VS Code Task-Härtung
1. **VS Code Task `Auto-Start: Antigravity + Docker AC-Sandbox (Win11)`:**
   * In `.vscode/tasks.json` beider Repositories (`git-labor` und `assetto-corsa-content`) wurde der Shell-Aufruf von generischem `powershell.exe` auf den vollqualifizierten Pfad `${env:SystemRoot}\\System32\\WindowsPowerShell\\v1.0\\powershell.exe` umgestellt.
   * Verhindert `Exit Code 1` beim Öffnen des Workspaces, falls die System-Umgebungsvariable `PATH` temporär fragmentiert ist.
2. **Rig Agent Watchdog:**
   * `rig-hub.ps1 -Action AutoProvisionFromRaceIni` verlinkt das jeweils in `race.ini` aktive Fahrzeug (`rss_formula_hybrid_x_2026`) und die Strecke (`acu_cota_2021`) per NTFS-Junction nach `C:\ac-sandbox\shared\content\`.

---

# Version 1.4 – 5-Agenten-Architektur, Content-Manager-Bestandsaufnahme & Schlankes Staging (16 RSS-Autos, 10 Strecken) mit Samba-Fix
**Datum:** 06.11.2026  
**Systeme:** `VanstrikeCyborg` (General Agent) $\leftrightarrow$ `SimRacer` (SimRacer Light & Rig Agent) $\leftrightarrow$ `ac-win11-sandbox` (Dark Agent) $\leftrightarrow$ `IdeaPad 5 Pitwall` (Sarah Coach)

## 1. Rollendefinition & Workspace-Trennung
1. **Agenten-Matrix:**
   * **General Agent (Du):** Operiert auf Laptop `VanstrikeCyborg`. Hauptverantwortlich für VS Code Workspaces, Multi-Root-Setups, Profile, `settings.json`, Tasks und die Erstellung/Pflege aller Agenten & Skills. Pflicht zur Diff-Vorschau vor Konfigurationsänderungen.
   * **SimRacer Light (`@light`):** Firmierend am SimRacer (`192.168.178.68`), steuert die Docker-Windows-11-Sandbox von außen, synchronisiert Content-Manager-Skripte und Pitfile-Validierungen.
   * **Rig Agent (`@rig`):** SimRacer Nativ (Port 22), Hardware-Hub (RTX 5070 Ti, Ryzen 9 3900X, SteamVR, Fanatec FFB, Shared Memory), Watchdog (Auto-Pause Sandbox bei `LIVE_RACE`), Staging und Hot-Deploy.
   * **Dark Agent (`@dark`):** In-Guest-Spezialist rein im Windows-11-Gast der Docker-Sandbox (Port 2222, `runner.ps1`, `worker.ps1`).
   * **Sarah Coach:** Live-Voice Coaching & Stint-Pitfile-Optimierung auf IdeaPad 5 (Linux Omarchy).
2. **Workspace-Trennung:**
   * `assetto-corsa-content.code-workspace` sauber von `git-labor.code-workspace` getrennt mit eigenem Docker-Context `simracer` und isolierten Container-Settings.

## 2. Content Manager Bestandsaufnahme auf SimRacer
* **Nativ vorhanden:** 337 Autos, 61 Strecken.
* **Letztes aktives Rennen in `race.ini`:** Auto = `rss_formula_hybrid_x_2026`, Strecke = `acu_cota_2021`.
* **Quick Drive Presets:**
  * `rbr f1`: `rss_formula_hybrid_2024` auf `ks_red_bull_ring/layout_gp` (10 Runden GP).
  * `SHIRO RedBullRing`: `urd_jt5_shiro_2021` (Super GT Nissan) auf `ks_red_bull_ring`.
  * `Nissan GTR nord`: `ks_nissan_gtr_gt3` auf `ks_nordschleife/nordschleife`.
  * `Rally`: `ks_toyota_celica_st185` auf `trento-bondone`.
* **Häufigste Setups in Documents:**
  * Ferrari 296 GT3 (`rss_gtm_furiano_96_v6`): 32 Setups
  * Formula Hybrid X 2026 (`rss_formula_hybrid_x_2026`): 30 Setups
  * Formula Hybrid 2024 (`rss_formula_hybrid_2024`): 28 Setups
  * Red Bull RB21 (`gp_2025_rb21`) & Porsche 992 GT3 R (`rss_gtm_protech_p92_f6`): je 13 Setups

## 3. Diagnose & Lösung: Samba-NTFS-Junction Problem
1. **Problem:**  
   Verzeichnis-Junctions (`mklink /J`) auf dem Windows-Host verweisen auf lokale absolute NTFS-Pfade (`C:\Program Files (x86)\...`). Wenn der Docker-Windows-11-Container über Linux-Samba (`dockurr/windows`) auf die Host-Freigabe `\\host.lan\Data\content` zugreift, kann Samba diese NTFS-Reparse-Points nicht auflösen (`Test-Path` lieferte `False`).
2. **Lösung (Schlankes Staging via Robocopy):**  
   Umstellung in `rig-hub.ps1` auf gefiltertes Robocopy:
   ```powershell
   robocopy $srcCar $dstCar /E /XF *.kn5 *.bank /R:1 /W:1 /NFL /NDL /NJH /NJS
   robocopy $srcTrack $dstTrack /E /XF *.kn5 /R:1 /W:1 /NFL /NDL /NJH /NJS
   ```
   * **Vorteil:** Riesige 3D-Meshes (`*.kn5`) und Fmod-Soundbänke (`*.bank`) werden weggelassen. Es werden nur Physik-, Setup-, UI- und Skin-Dateien übertragen (~140 MB für 16 Autos und 10 Strecken statt ~35 GB).
   * **Ergebnis:** Samba kann alle Verzeichnisse direkt und ohne Fehler für die Sandbox bereitstellen.

## 4. Implementierung in der Sandbox durch Dark Agent
1. **Automatisierte Bereitstellung:**  
   Dark Agent hat im Windows-11-Gast (`WIN-54U68T9T2FA`) Verknüpfungen in `C:\AssettoCorsa\content\cars` und `C:\AssettoCorsa\content\tracks` angelegt:
   * **16 RSS-Autos:** `rss_formula_hybrid_2023`, `2024`, `v12-r`, `x_2026`, `rss_gtm_adonis_v8_evo`, `aero_v10_evo2`, `akuro_v6_evo2`, `bayer_i6_evo`, `bayer_v8`, `furiano_96_v6`, `hyperion_v8`, `lanzo_v10_evo2`, `lux_v8`, `macca_72_evo_v8`, `mercer_v8`, `protech_p92_f6`.
   * **10 Strecken:** `acu_cota_2021`, `ks_red_bull_ring`, `ks_nordschleife`, `ks_nurburgring`, `spa`, `monza`, `imola`, `ks_silverstone`, `ks_barcelona`, `trento-bondone`.
2. **Setup- & Content-Integritätsprüfung:**  
   * Alle 16 RSS-Fahrzeuge: `data = True`, `ui = True`, Skins vollständig vorhanden.
   * Alle **201 Setup-.ini-Dateien** im Gast durch `ValidateSetups` syntaktisch geprüft: **100 % valide**.
   * Speicherplatz auf C: im Gast: **93,37 GB frei** von 159,75 GB, RAM: **9.353 MB frei**.

## 5. Verifikation der Setup-Deploy-Pipeline auf das SimRig
* Befehl: `.\ac-sandbox\Invoke-RigAgent.ps1 -Action DeployPitfile`
* Getestet und verifiziert: In der Sandbox erstellte oder optimierte Setups werden direkt nach `C:\Users\Mike\Documents\Assetto Corsa\setups` auf dem Gaming-PC synchronisiert.




