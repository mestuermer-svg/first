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
| **A.4 Dark Agent (In-Container)** | ✅ Abgeschlossen | `runner.ps1`, `worker.ps1`, `status.json` einsatzbereit. |
| **A.5 Python 3.11.9 (Gast)** | ✅ Abgeschlossen | Installiert, MS-Store-Aliase umgangen, `python` & `pip` global. |
| **A.6 Content-Staging (16 RSS-Autos & 10 Strecken)** | ✅ Abgeschlossen | Schlankes Staging via Robocopy `/XF *.kn5 *.bank` (~140 MB) nach `C:\AssettoCorsa\content`. |
| **A.7 Setup-Validierung & Hot-Deploy Pipeline** | ✅ Abgeschlossen | 201 Setups valide; `DeployPitfile` synchronisiert Setups ins native SimRig. |
| **A.8 5-Agenten-Architektur & Dokumentation** | ✅ Abgeschlossen | General Agent, SimRacer Light, Rig Agent, Dark Agent, Sarah Coach; Topologie & Spezifikationen in `agents/`. |

### ✅ Bereits implementierte Host-Tools (SimRacer & Laptop)

* **`Invoke-DarkAgent.ps1` (Laptop):** Steuert den In-Container-Agenten via SSH Port 2222 (`Status`, `ValidateSetups`, `LaunchCM`, etc.).
* **`Invoke-RigAgent.ps1` (Laptop):** Steuert den SimRacer Host via SSH Port 22 (`ListContent`, `ProvisionContent`, `DeployPitfile`, `Status`, `Watchdog`).
* **`rig-hub.ps1` (SimRacer Host):** Schlankes Staging von Autos/Strecken aus `race.ini`, Sandbox-Pausierung (`docker pause`/`unpause`), Setup-Deployment und Telemetrie-Schnittstelle.

---

## 2. Nächste Schritte: Vor dem Sprung auf das IdeaPad (Omarchy)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                       REIHENFOLGE DER NÄCHSTEN SCHRITTE                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. [SimRacer] Fokus-Wächter Task Scheduler (B.2)   -> VR-Schutz aktiv       │
│ 2. [SimRacer] Telemetrie-Sender bereitstellen (C.1)-> Datenquelle f. Sarah  │
│ 3. [SimRacer] Tägliches Pitfile-Backup Task (B.3)  -> Setup-Sicherheit      │
│ 4. [Cyborg]   68,7 GB Alt-Image bereinigen (B.4)   -> NVMe C: entlasten     │
│ 5. [SimRacer] Veeam Bare-Metal Backup Stick (B.5)  -> Disaster Recovery     │
│ ─────────────────────────────────────────────────────────────────────────── │
│ 6. [IdeaPad]  Start mit Linux Omarchy & Sarah Voice-Coach (Block C)        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Schritt 1: Fokus-Wächter als Autostart-Task auf SimRacer (Task B.2)

* **Ziel:** Maximale VR-Frametimes (90 FPS stabil auf VIVE Focus Vision). Sobald `acs.exe` (Assetto Corsa) auf dem SimRacer startet, pausiert die Docker-Sandbox automatisch (`docker pause ac-win11-sandbox`). Sobald `acs.exe` schließt, taut die Sandbox wieder auf.
* **Umsetzung:**
  * Windows-Aufgabenplanung (Task Scheduler) auf dem SimRacer konfigurieren:
    * **Name:** `SimRacer-Focus-Watchdog`
    * **Trigger:** Bei Anmeldung des Benutzers `Mike` (oder Systemstart)
    * **Aktion:** `powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\ac-sandbox\shared\scripts\rig-hub.ps1 -Action Watchdog -IntervalSeconds 3`
    * **Bedingungen:** Ohne Leerlaufbedingung, kontinuierlich im Hintergrund.

---

### Schritt 2: AC Shared-Memory Telemetrie-Sender am SimRacer (Task C.1)

* **Ziel:** Das IdeaPad (Sarah Coach) benötigt Live-Telemetriedaten ohne FPS-Einbußen am Gaming-PC.
* **Architektur:**
  * Ein ultrakompaktes Python-Skript am SimRacer liest die Windows Shared Memory Mappings aus:
    * `acpmf_physics` (Reifendrücke, Kerntemperaturen, Bremsdruck, G-Kräfte, Radschlupf)
    * `acpmf_graphics` (Sitzungsstatus, Rundenzeiten, Streckenposition `normalizedCarPosition`, Sektor-Zeiten)
    * `acpmf_static` (Auto-Name, Strecken-Layout, max. Drehmoment/Drehzahl)
  * Sendet komprimierte JSON/UDP-Pakete mit $50\text{ Hz}$ ins lokale Netz an das IdeaPad (Port `9996`) oder MQTT-Broker.
  * **Ressourcenverbrauch:** $< 0.5\text{ \%}$ CPU auf dem Ryzen 9 3900X.

---

### Schritt 3: Automatisches Pitfile-Backup auf SimRacer (Task B.3)

* **Ziel:** Jedes gespeicherte `.ini`-Fahrzeugsetup soll versioniert gesichert werden, damit kein mühevoll herausgefahrenes Setup verloren geht.
* **Umsetzung:**
  * Geplanter Task für `backup-simracer-configs.ps1` auf dem SimRacer:
    * **Ausführung:** Täglich um 23:00 Uhr und/oder bei Herunterfahren.
    * **Zielverzeichnis:** `D:\Backups\SimRacer_Configs\YYYY-MM-DD_HH-mm\`
    * **Inhalt:** `C:\Users\Mike\Documents\Assetto Corsa\cfg\setups\`

---

### Schritt 4: 68,7 GB Alt-Image auf dem Laptop bereinigen (Task B.4)

* **Ziel:** Freigabe von Speicherplatz auf der NVMe-SSD des VanstrikeCyborg-Laptops.
* **Hintergrund:**
  * Auf dem Laptop liegt unter `C:\Users\strik\assetto-corsa-content\ac-sandbox\storage\data.img` noch das alte 68,7-GB-Image aus der initialen Testphase auf dem Laptop.
  * Die aktive Sandbox läuft jetzt dauerhaft auf der schnellen NVMe des SimRacers (`C:\ac-sandbox\storage\data.img`).
  * Aktueller freier Speicher auf Laptop-Laufwerk `C:`: **122,8 GB**.
  * **Nach Bereinigung:** **~191,5 GB freier Speicher**.

---

### Schritt 5: Veeam Bare-Metal-Backup für SimRacer (Task B.5)

* **Ziel:** Komplette Ausfallsicherheit des SimRigs vor größeren Rennevents.
* **Maßnahmen:**
  1. Bootfähigen USB-Rettungsstick (Recovery Media) über Veeam Agent Free erstellen.
  2. Backup-Job konfigurieren: Sicherung von Laufwerk `C:` (OS, Treiber, VR-Software) nach `D:\Backups\Veeam_OS\`.
  3. Ausschlusslisten (`D:\Backups\Veeam_Exclusions.txt`) prüfen (große Steam-Spieledateien auf `D:` aussparen).

---

## 3. Ausblick: Was passiert danach auf dem IdeaPad 5 (Linux Omarchy)?

Sobald die SimRacer- und Laptop-Punkte erledigt sind, wird das IdeaPad 5 eingerichtet:

1. **MQTT & Telemetrie-Empfänger:** Empfängt UDP/MQTT-Telemetrie vom SimRacer.
2. **Sarah Voice Engine:** Piper-TTS oder lokale Sprachausgabe mit Anti-Quassel-Regeln (Stille in Anbremszonen, Funksprüche nur auf Geraden).
3. **Pitfile-Optimizer (`sarah_pitfile_optimizer.py`):** Berechnet automatisch optimierte Stint-Setups (`Sarah_Opt_Stint.ini`) basierend auf Reifendrücken und Telemetrie und schiebt sie zurück auf den SimRacer.
4. **Pitwall Dashboard:** Live-Timing und Reifentemperaturen auf dem IdeaPad-Bildschirm.

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
