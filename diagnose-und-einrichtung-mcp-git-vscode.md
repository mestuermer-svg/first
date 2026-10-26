# Diagnose- & Einrichtungsbericht: GitHub MCP-Server, Docker, Git & VS Code

**Datum:** 26. Oktober 2026  
**Benutzer / GitHub-Account:** `mestuermer-svg` (`m.e.stuermer@gmail.com`)  
**Betroffene Repositories:**
1. [`mestuermer-svg/first`](https://github.com/mestuermer-svg/first) (Lokal: `C:\Users\strik\git-labor`)
2. [`mestuermer-svg/local_Cyborg`](https://github.com/mestuermer-svg/local_Cyborg) (Lokal: `C:\local_Cyborg`)

---

## 1. Fehlerdiagnose: Warum `github-mcp-server` nicht startete

### Ursprüngliche Fehlermeldung
```text
failed to connect to the docker API at npipe:////./pipe/dockerDesktopLinuxEngine;
check if the path is correct and if the daemon is running:
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
: connection closed: calling "initialize": client is closing: EOF
```

### Ursache
* In der globalen Konfigurationsdatei `C:\Users\strik\.gemini\config\mcp_config.json` war der `github-mcp-server` so eingestellt, dass er über einen **Docker-Container** (`docker run -i --rm ... ghcr.io/github/github-mcp-server`) gestartet wird.
* Auf dem System ist zwar **Docker Desktop (`v29.8.2` / `4.95.0`)** installiert (`C:\Users\strik\AppData\Local\Programs\DockerDesktop\`), aber der **Docker-Hintergrunddienst (Daemon)** lief nicht.
* Wenn Docker Desktop geschlossen ist, existiert die Windows Named Pipe `\\.\pipe\dockerDesktopLinuxEngine` nicht – der Start des MCP-Servers bricht sofort ab.

### Warum das native Go-Binary (`Option 2`) für VMs & VS-Code-Sandboxen besser ist
| Kriterium | Option 1: Docker (`ghcr.io/...`) | **Option 2: Natives Binary (`github-mcp-server.exe`)** | Option 3: `npx` (`@modelcontextprotocol/server-github`) |
| :--- | :--- | :--- | :--- |
| **Funktionsumfang** | Aktuell & vollständig (`v2.0.3`) | **Aktuell & vollständig (`v2.0.3`)** | Veraltet (Deprecated), weniger Tools |
| **RAM-Bedarf** | Hoch (2–4 GB für WSL2/Docker-VM) | **Minimal (~20–30 MB)** | Mittel (~80–150 MB) |
| **Startzeit** | 1–3 Sekunden | **< 50 Millisekunden** | 1–4 Sekunden |
| **VM- & Sandbox-Eignung** | Schlecht (Nested Virtualization & Named Pipes nötig) | **Exzellent (einzelne statische `.exe`-Datei über `stdio`)** | Mittel |

### Durchgeführte Lösung beim MCP-Server
1. Das offizielle Windows-Binary (`v2.0.3`, x64) von GitHub Releases heruntergeladen und entpackt nach:
   `C:\Users\strik\.local\bin\github-mcp-server.exe`
2. Die Datei `C:\Users\strik\.gemini\config\mcp_config.json` von Docker auf das direkte Binary umgestellt:
   ```json
   "github-mcp-server": {
     "command": "C:\\Users\\strik\\.local\\bin\\github-mcp-server.exe",
     "args": [
       "stdio"
     ],
     "env": {
       "GITHUB_PERSONAL_ACCESS_TOKEN": "<IHR_GITHUB_PAT>"
     }
   }
   ```
3. **So starten Sie den `github-mcp-server` nach einer Änderung neu (lokal auf dem PC, nicht auf GitHub.com):**
   * **In der Antigravity Desktop-App:** Links in der Haupt-Seitenleiste auf **Customizations** (bzw. *Skills & Customizations*) klicken → **MCP Servers** auswählen → neben `github-mcp-server` auf **Restart** (↻) klicken.
   * **In der Antigravity IDE (Editor-Ansicht):** Oben rechts im Chat-Bereich auf das **Drei-Punkte-Menü (`...`)** klicken → **MCP Servers** → neben `github-mcp-server` auf **Restart** klicken.
   * **Im klassischen VS Code:** `Strg + Umschalt + P` drücken → `MCP: List Servers` eingeben → `github-mcp-server` auswählen → **Restart Server**.

---

## 2. Was in Git & VS Code falsch eingestellt war (und behoben wurde)

### A. Globale Git-Konfiguration (`C:\Users\strik\.gitconfig`)
* **Gefundener Fehler:** In der `.gitconfig` waren beim Benutzernamen versehentlich Zeilenumbrüche (`\n`) gespeichert:
  ```ini
  name = \nmestuermer-svg\n
  ```
  Das kann beim Erstellen von Commits zu Fehlern oder defekten Autoren-Einträgen führen.
* **Gefundene Schwachstelle:** In der System-Konfiguration war noch `init.defaultbranch = master` hinterlegt (GitHub nutzt heute `main`), und `push.autoSetupRemote` fehlte.
* **Durchgeführte Korrektur in `C:\Users\strik\.gitconfig`:**
  ```ini
  [core]
      editor = \"C:\\Users\\strik\\AppData\\Local\\Programs\\Microsoft VS Code\\bin\\code\" --wait
  [user]
      email = m.e.stuermer@gmail.com
      name = mestuermer-svg
  [init]
      defaultBranch = main
  [push]
      autoSetupRemote = true
  ```

### B. Geprüfte VS-Code-Einstellungen (`C:\Users\strik\AppData\Roaming\Code\User\settings.json`)
Diese Einstellungen waren bereits sinnvoll gesetzt und wurden beibehalten:
* `"git.enableSmartCommit": true` – Nimmt beim Klick auf *Commit* automatisch alle geänderten Dateien mit, falls vorher nichts manuell mit `+` ausgewählt wurde.
* `"git.autofetch": true` – Prüft regelmäßig im Hintergrund, ob Änderungen auf GitHub vorliegen.
* `"git.confirmSync": false` – Synchronisiert direkt ohne unnötige Bestätigungsdialoge.
* `credential.helper = manager` – Speichert die GitHub-Anmeldung sicher im Windows Credential Manager.

---

## 3. Warum die beiden GitHub-Repositories leer waren (und wie es gelöst wurde)

### Repository 1: `mestuermer-svg/first` (Lokal: `C:\Users\strik\git-labor`)
* **Ursache:** Die neuen Dateien (`lernmaterial-google-antigravity.md`, `verbindungsbericht-vscode-github-gemini.md`, `prozess-log.md` usw.) lagen zwar im **Staging-Bereich (Warenkorb)**, es fehlten aber noch der **Commit** (lokales Speichern im `.git`-Archiv) und der **Push** (Hochladen zu GitHub).
* **Lösung:** Alle Dateien inklusive dieser Dokumentation wurden ordentlich committet und auf `origin/main` (`https://github.com/mestuermer-svg/first.git`) gepusht.

### Repository 2: `mestuermer-svg/local_Cyborg` (Lokal: `C:\local_Cyborg`)
* **Ursache 1 (13 GB großes, beschädigtes `.git`-Archiv):** Im Ordner `C:\local_Cyborg` liegen große Programm-Installer und Treiber (`Apps und Treiber` mit **12,55 GB** und `Tool-Box` mit **239 MB**). Beim ersten Commit-Versuch wollte Git alle 13+ GB in das lokale `.git`-Archiv packen. Dabei ist die Pack-Datei `.git/objects/pack/pack-57754643c4e4bdeb932d437f81b4b3b9de4890eb.pack` abgebrochen und **korrupt** geworden (`fatal: packed object ... is corrupt`).
* **Ursache 2 (GitHub 100-MB-Dateilimit):** GitHub lehnt jeden Upload (`Push`) komplett ab, sobald eine einzelne Datei größer als **100 MB** ist (z. B. `SolarSystemScope-Setup-3-2-3.exe` mit 176 MB oder Treiber-Archive).
* **Lösung:**
  1. Das beschädigte, 13 GB große `.git`-Verzeichnis in `C:\local_Cyborg` wurde entfernt und sauber neu initialisiert (dadurch wurden **rund 13 GB Festplattenspeicher auf `C:` freigegeben**, ohne dass eine einzige Arbeitsdatei gelöscht wurde).
  2. Eine `.gitignore`-Datei in `C:\local_Cyborg\.gitignore` wurde angelegt, damit große Binär-/Treiber-Ordner (`Apps und Treiber/`, `Tool-Box/`, `*.exe`, `*.zip`) lokal erhalten bleiben, aber nicht in Git/GitHub hochgeladen werden.
  3. Alle Dokumentationen, Konfigurationen und Arbeitsdateien wurden committet und auf `https://github.com/mestuermer-svg/local_Cyborg.git` hochgeladen.

---

## 4. Grundlagen-Leitfaden: Wie Git, VS Code und GitHub zusammenarbeiten

Git arbeitet in **4 Stufen**. Die ersten drei Stufen finden komplett lokal auf Ihrem eigenen PC statt – erst die vierte Stufe überträgt Daten ins Internet auf den GitHub-Server:

```text
[ 1. Arbeitsordner ]  ──( + Stage )──>  [ 2. Warenkorb (Staging) ]  ──( Commit )──>  [ 3. Lokales Archiv (.git) ]  ──( Push / Sync )──>  [ 4. GitHub-Server ]
   (Ihre Dateien)                         (Auswahl für Commit)                        (Noch auf Ihrem PC!)                                (Im Internet / Cloud)
```

### Die 4 Stufen im Überblick

1. **Stufe 1 – Arbeitsverzeichnis (*Working Directory* auf Ihrem PC):**
   * Hier bearbeiten Sie Dateien in VS Code und speichern sie normal mit `Strg + S`.
   * `Strg + S` speichert nur auf Ihrer Festplatte, erstellt aber noch keine Git-Version.
2. **Stufe 2 – Bereitstellungsbereich (*Staging Area* / „Warenkorb“ auf Ihrem PC):**
   * Mit dem **`+`-Symbol** neben einer Datei in VS Code legen Sie fest, welche Änderungen in das nächste Versions-Paket gehören.
   * *Tipp:* Dank `git.enableSmartCommit: true` packt VS Code automatisch alle geänderten Dateien ein, wenn Sie direkt auf **Commit** klicken.
3. **Stufe 3 – Lokales Repository (*Commit* im versteckten `.git`-Ordner auf Ihrem PC):**
   * Sie geben oben eine kurze Nachricht ein (z. B. *„Dokumentation ergänzt“*) und klicken auf **Commit**.
   * Damit wird ein fester Schnappschuss mit Zeitstempel auf Ihrem PC gespeichert. Auf GitHub.com ist er zu diesem Zeitpunkt **noch nicht** sichtbar.
4. **Stufe 4 – Server-Ablage auf GitHub (*Remote Repository* via *Push / Pull / Sync*):**
   * **Push / Sync Changes:** Lädt Ihre lokalen Commits auf den GitHub-Server hoch.
   * **Pull:** Lädt Änderungen vom GitHub-Server auf Ihren PC herunter.

---

## 5. Täglicher Spickzettel für VS Code

1. **Quellcodeverwaltung öffnen:** Links in der Seitenleiste auf das Verzweigungssymbol klicken (oder `Strg + Umschalt + G` drücken).
2. **Nachricht eingeben:** Oben im Textfeld *Message* kurz eintragen, was geändert wurde.
3. **Commit & Push ausführen:**
   * Entweder auf **Commit** klicken und danach auf den blauen Button **Sync Changes**.
   * Oder rechts neben dem Button *Commit* auf den kleinen Pfeil klicken und direkt **Commit & Push** auswählen (erledigt Stufe 3 und Stufe 4 in einem Schritt).
4. **Wichtige Regel für große Dateien (`.gitignore`):**
   * Keine `.exe`-Installer, Treiber-Pakete oder Dateien über 50–100 MB committen. Solche Ordner oder Dateiendungen immer in die Datei `.gitignore` eintragen.
