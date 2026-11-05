---
name: live-transfer-status-monitor
description: |
  Zeigt bei Datei-, Backup- oder Netzwerkübertragungen (z. B. robocopy, xcopy, rsync, SMB/LAN-Transfers, große Datei-Kopiervorgänge) automatisch ein kombiniertes Live-Fortschritts-Dashboard (strukturierte Tabellenansicht + 5-Sekunden-Auto-Refresh im Terminal sowie Markdown-Status-Tabelle im Chat) an.
  IMMER verwenden, wenn Daten, Backups, Disk-Images oder Ordner übertragen oder synchronisiert werden.
---

# Live Transfer Status Monitor (Tabellenansicht + 5s Auto-Refresh)

> [!IMPORTANT]
> **PFLICHT-REGEL BEI ÜBERTRAGUNGEN:**
> Sobald eine Datei-, Ordner-, Backup- oder Netzwerkübertragung gestartet oder überwacht wird, **MUSS** immer automatisch diese kombinierte Status-Anzeige bereitgestellt werden:
> 1. **Im Chat:** Strukturierte Markdown-Tabelle (`Parameter | Aktueller Wert`).
> 2. **Im Terminal (`async`):** Live-Dashboard mit **5-Sekunden-Auto-Refresh** (`Clear-Host`), das dieselbe Tabellenstruktur laufend aktualisiert.

---

## 1. Strukturierte Tabellenansicht (Chat-Vorlage)

Bei jeder Übertragung ist im Chat folgender Statusblock auszugeben:

| Parameter | Aktueller Wert |
|---|---|
| **Prozess-Status** | 🟢 **AKTIV** (`<Prozessname>`, PID `<PID>`, `<Modus/Flags>`) |
| **Fortschritt** | `[█████████░░░░░░░░░░░░░] <Prozent> %` |
| **Übertragene Datenmenge** | **<Ist-GB> GB** von **<Gesamt-GB> GB** *(noch ca. <Rest-GB> GB offen)* |
| **Übertragungsrate (Ø)** | **<Ø MB/s> MB/s Ø** *(aktuell: <Aktuell MB/s> MB/s \| ~<Mbit/s> Mbit/s WLAN/LAN)* |
| **Bisherige Laufzeit** | **<Minuten> Min. <Sekunden> Sek.** |
| **Geschätzte Restzeit** | **ca. <Restminuten> Minuten** *(~<Std.> Std. <Min.> Min.)* |
| **Bereits fertig kopiert** | ✅ `<Liste bereits übertragener Dateien/Ordner>` |

---

## 2. Live-Terminal-Monitor & Grafisches 5s-Auto-Refresh-Panel

- **Vorhandenes Skript im Workspace:** `c:\Users\strik\assetto-corsa-content\ac-sandbox\shared\scripts\watch-transfer-status.ps1`
- **Automatisch generierte Live-Ansichten (aktualisieren sich alle 5 Sekunden von selbst):**
  - **Grafisches VS-Code-Browser-Dashboard:** `c:\Users\strik\assetto-corsa-content\ac-sandbox\LIVE-TRANSFER-STATUS.html` (via `open_browser_page` direkt als Tab in VS Code öffnen – aktualisiert sich alle 5 Sek. per `<meta http-equiv="refresh" content="5">`).
  - **Live-Markdown-Datei:** `c:\Users\strik\assetto-corsa-content\ac-sandbox\LIVE-TRANSFER-STATUS.md`
- **Aufruf (immer im `async`-Modus starten + Browser-Tab öffnen):**
  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "c:\Users\strik\assetto-corsa-content\ac-sandbox\shared\scripts\watch-transfer-status.ps1" -IntervalSeconds 5 -TotalSizeGB <GesamtgroesseInGB>
  ```
