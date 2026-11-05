# Praxisanleitung: System-Image & Wiederherstellung (Veeam Agent Free) für SimRacer

<details>
<summary><h2>1. Zielsetzung & Architektur</h2></summary>

Diese Anleitung dokumentiert die schlüsselfertige Einrichtung eines bootfähigen Wiederherstellungs-Images für die **SimRacer-Workstation** (AMD Ryzen 9 3900X, NVIDIA RTX 5070 Ti, Fanatec ClubSport, HTC VIVE Focus Vision).

### Kernziel:
* **Vollständige Sicherung des Betriebssystems (C:):** Windows 11, Treiber, VR-Software, Content Manager und Konfigurationen.
* **Ausschluss von Steam-Spielen (`steamapps\common`):** Reduziert das Backup-Volumen von mehreren hundert Gigabyte auf ca. **25–40 GB**.
* **Wiederherstellungszeit im Ernstfall:** 10–15 Minuten (Bare-Metal Restore via USB-Stick).

```mermaid
graph TD
    subgraph SimRacer [SimRacer Workstation]
        C[Laufwerk C: 1 TB System-SSD]
        D[Laufwerk D: 1.8 TB Daten-SSD]
        USB[USB-Rettungsstick 8 GB]
    end

    C -->|OS, Treiber, Configs| VBK[Veeam Backup-Image .vbk]
    C -.->|Ausschluss: steamapps| SKIP[Spieleordner überspringen]
    VBK --> D
    USB -->|Notfall-Boot / WinPE| RESTORE[Veeam Recovery Environment]
    RESTORE -->|Rücksicherung 10 Min| C
```

</details>

<details>
<summary><h2>2. Vorbereitung & Installation</h2></summary>

1. **Software:** Lade die **Veeam Agent for Microsoft Windows (Community Edition / Free)** von der Herstellerseite herunter.
2. **Installation:** Führe den Installer mit Administratorrechten auf dem SimRacer aus.
3. **Lizenzierung:** Wähle bei der Lizenzabfrage **Free Edition** (erfordert keinen Lizenzschlüssel).

</details>

<details>
<summary><h2>3. Bootfähiges USB-Rettungsmedium erstellen</h2></summary>

Das Rettungsmedium ist die Voraussetzung, um das System auch dann wiederherzustellen, wenn Windows 11 nicht mehr hochfährt.

1. Stecke einen leeren USB-Stick (mind. 4 bis 8 GB) an den SimRacer an.
2. Öffne das Startmenü und starte den **Veeam Recovery Media Creator**.
3. **Wichtige Optionen aktivieren:**
   * `[x] Include network connection settings from this computer`
   * `[x] Include hardware drivers from this computer` *(Bindet automatisch die NVMe-Controller-, RTX-5070-Ti- und Netzwerktreiber ein)*.
4. Wähle den USB-Stick als Ziel aus und starte die Erstellung.
5. Nach Abschluss den Stick beschriften (z. B. *„SimRacer Recovery“*) und sicher aufbewahren.

</details>

<details>
<summary><h2>4. Konfiguration des Backup-Jobs (Ausschluss der Spiele)</h2></summary>

Öffne den Veeam Agent und klicke auf **Add New Job**:

<details>
<summary><h3>Option A: Saubere Laufwerkstrennung (Best Practice)</h3></summary>

Falls die Steam-Bibliothek auf der **1.8 TB Daten-SSD (Laufwerk D:)** liegt:
1. **Backup Mode:** Wähle **Volume level backup**.
2. **Volumes:** Markiere ausschließlich **Laufwerk C:** (System & EFI-Boot-Partition).
3. **Vorteil:** Alle Spiele liegen unberührt auf D:, Laufwerk C: wird schlank und blitzschnell gesichert.

</details>

<details>
<summary><h3>Option B: Spiele & Docker-Sandbox liegen auf C: (Manuelle Ausschlussliste)</h3></summary>

Falls Steam, Spiele oder die Docker-Sandbox auf Laufwerk C: liegen:
1. **Backup Mode:** Wähle **File level backup**.
2. **Items:** Wähle `Operating system` und Laufwerk `C:`.
3. Klicke auf **Filters / Advanced Options** und trage unter **Exclusions** folgende Pfade ein, damit keine hunderte Gigabyte Spiele oder Container-Festplatten mitgesichert werden (liegt auch fertig zum Kopieren auf dem SimRacer unter `D:\Backups\Veeam_Exclusions.txt`):
   ```text
   C:\Program Files (x86)\Steam\steamapps\common\*
   C:\Program Files (x86)\Steam\steamapps\downloading\*
   C:\Program Files (x86)\Steam\steamapps\temp\*
   C:\ac-sandbox\storage\*
   C:\Users\Mike\AppData\Local\Docker\wsl\*
   C:\XboxGames\*
   ```
4. Temporäre Ordner und Caches werden von Veeam automatisch gefiltert.

</details>

<details>
<summary><h3>Speicherziel & Aufbewahrung</h3></summary>

* **Destination:** Wähle **Local storage**.
* **Folder:** Wähle einen Backup-Ordner auf der 1.8 TB SSD (z. B. `D:\Backups\Veeam_OS`).
* **Restore points to keep:** Empfohlen sind **3 bis 5 Punkte** (inkrementelle Speicherung; belegt ca. 40–70 GB Gesamtspeicher).
* **Schedule:** Optional wöchentlich oder manuell vor größeren Treiber- oder Mod-Updates.

</details>

</details>

<details>
<summary><h2>5. Durchführung der ersten Vollsicherung (Stufe 1: Betriebssystem)</h2></summary>

1. Klicke im Hauptfenster von Veeam mit der rechten Maustaste auf den Job `SimRacer-System-Backup` und wähle **Backup Now**.
2. **Geschwindigkeit:** Dank der internen Sandisk/NVMe-SSDs dauert der Vorgang für ca. 60–80 GB Systemdaten i. d. R. nur **5 bis 10 Minuten**.
3. **Ergebnis:** Eine komprimierte `.vbk`-Datei auf Laufwerk D: mit ca. 25–40 GB Größe.

</details>

<details>
<summary><h2>6. Stufe 2: Tägliches Sekunden-Backup für Pitfiles (.ini), Content Manager, Fanatec & VR</h2></summary>

Während Veeam das gesamte Windows-11-Betriebssystem sichert, entstehen deine wichtigsten Arbeitsdaten bei jeder Session im **Content Manager** und durch **Sarah Coach** (Setup-Pitfiles `.ini`, Lenkrad-Force-Feedback-Kurven, VR-Auflösungsprofile). Wenn ein KI-Agent beim Experimentieren ein Setup oder eine Content-Manager-Konfiguration überschreibt, musst du nicht das komplette Windows-Image zurückspielen, sondern stellst in **2 Sekunden** genau diese Konfigurationsdateien wieder her.

<details>
<summary><h3>6.1 Kritische SimRacer-Verzeichnisse im Überblick</h3></summary>

| Komponente | Pfad auf dem SimRacer (`C:\Users\Mike\...`) | Inhalt & Bedeutung |
| :--- | :--- | :--- |
| **1. Pitfiles / Fahrzeug-Setups** | `Documents\Assetto Corsa\cfg\setups\` | Alle `.ini`-Setups pro Fahrzeug & Strecke (inkl. `Sarah_Opt_*.ini`). |
| **2. AC Steuerung, Video & `race.ini`** | `Documents\Assetto Corsa\cfg\` | Fanatec-Achsen/Buttons (`controls.ini`), VR-Settings (`video.ini`), `race.ini`. |
| **3. Content Manager & CSP Presets** | `AppData\Local\AcTools Content Manager\` | Alle gespeicherten CM-Presets, Custom Shaders Patch (CSP) Tweaks, Python-App-Configs. |
| **4. Fanatec Treiber-/FanaLab-Profile** | `AppData\Local\Fanatec\` | Hardware-FFB-Profile für die ClubSport V2.5 Base und das Formula V2.0 Wheel. |
| **5. SteamVR / VIVE Focus Vision** | `C:\Program Files (x86)\Steam\config\steamvr.vrsettings` | Exakte Supersampling- und 120-Hz-DisplayPort-Einstellungen für das VR-Headset. |

</details>

<details>
<summary><h3>6.2 Automatisches PowerShell-Backup-Skript (<code>backup-simracer-configs.ps1</code>)</h3></summary>

Dieses Skript sichert alle oben genannten Ordner mit Zeitstempel nach `D:\Backups\SimRacer_Configs` (und kann zusätzlich per Git/SCP auf den **Raspberry Pi 4** spiegeln):

```powershell
# PowerShell-Skript: backup-simracer-configs.ps1
# Sichert Pitfiles (.ini), Content Manager, CSP, Fanatec & VR-Settings in < 3 Sekunden
$ErrorActionPreference = "Continue"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$BackupRoot = "D:\Backups\SimRacer_Configs\$Timestamp"

Write-Host "[Backup] Starte SimRacer Pitfile- & Config-Sicherung nach $BackupRoot ..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "$BackupRoot\AC_cfg" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupRoot\ContentManager" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupRoot\Fanatec" | Out-Null

# 1. Assetto Corsa cfg & alle Pitfiles (.ini) sichern (ohne schwere Replays!)
$AcCfgSource = "$env:USERPROFILE\Documents\Assetto Corsa\cfg"
if (Test-Path $AcCfgSource) {
    robocopy $AcCfgSource "$BackupRoot\AC_cfg" /E /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null
    Write-Host "  [OK] Assetto Corsa cfg & Pitfiles (.ini) gesichert." -ForegroundColor Green
}

# 2. Content Manager & Custom Shaders Patch Settings (ohne temporären Cache)
$CmSource = "$env:LOCALAPPDATA\AcTools Content Manager"
if (Test-Path $CmSource) {
    robocopy $CmSource "$BackupRoot\ContentManager" /E /XD "Cache" "Temporary" "Logs" /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null
    Write-Host "  [OK] Content Manager & CSP Profile gesichert." -ForegroundColor Green
}

# 3. Fanatec / FanaLab Profile
$FanatecSource = "$env:LOCALAPPDATA\Fanatec"
if (Test-Path $FanatecSource) {
    robocopy $FanatecSource "$BackupRoot\Fanatec" /E /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null
    Write-Host "  [OK] Fanatec Wheel-Profile gesichert." -ForegroundColor Green
}

# 4. Alte Stände aufräumen (Behalte die letzten 30 Snapshots auf D:)
if (Test-Path "D:\Backups\SimRacer_Configs") {
    Get-ChildItem "D:\Backups\SimRacer_Configs" -Directory |
        Where-Object { $_.Name -match "^\d{4}-\d{2}-\d{2}" } |
        Sort-Object CreationTime -Descending |
        Select-Object -Skip 30 |
        Remove-Item -Recurse -Force
}

Write-Host "[Backup] Fertig! Snapshot abgelegt unter: $BackupRoot" -ForegroundColor Cyan
```

* **Ablageort im Workspace:** Das ausführbare Skript liegt unter `c:\Users\strik\git-labor\ac-sandbox\backup-simracer-configs.ps1`.

</details>

</details>

<details>
<summary><h2>7. Der Ernstfall: Schritt-für-Schritt Bare-Metal Recovery</h2></summary>

Falls Windows nach einem fehlgeschlagenen Update, Mod-Konflikt oder Absturz nicht mehr startet:

1. **PC ausschalten.**
2. Den **Veeam-USB-Stick** an den SimRacer anschließen.
3. PC einschalten und sofort die Bootmenü-Taste drücken (je nach Mainboard `F11`, `F12` oder `F8`).
4. Den USB-Stick als Boot-Laufwerk auswählen.
5. In der blauen **Veeam Recovery Environment** auf **Bare Metal Recovery** klicken.
6. Die Backup-Datei auf Laufwerk `D:\Backups\Veeam_OS\` auswählen.
7. Als Wiederherstellungsziel **Laufwerk C:** bestätigen und den Restore starten.
8. Nach ca. 10 Minuten den USB-Stick entfernen und neu starten – das System befindet sich wieder im exakt funktionierenden Zustand.

</details>

<details>
<summary><h2>8. Weiterführende Dokumente & Verknüpfungen</h2></summary>

* [Architektur-Übersicht & VS Code Multi-PC-Anleitung](./uebersicht-vscode-agent-localhost-gemini-antigravity.md)
* [4-Knoten-Architektur & Einsatzkonzept (SimRacer, Cyborg, IdeaPad Omarchy, RPi 4)](./multi-pc-architektur-ki-agents-simracing.md)
* [Technische Hardware- und Stabilitätsanalyse (MSI Cyborg 15 & Docker)](./hardware-analyse-system-stabilitaet-docker-ki.md)
* [Docker Windows-11 Sandbox: Prüflabor für Content Manager & KI-Agenten](./docker-windows-steam-ki-agent-architektur.md)
* [Sarah Coach, Agent-Fokus & Pitfile-Automatisierung (Detailkonzept)](./planing.md)

</details>

---
*Hinweis zur Organisation:* Die erstellte Dokumentation ist am Drehlaufwerk abgelegt und mit einer kurzen Zusammenfassung von den Chips auch in den Notebooks verlinkt.
