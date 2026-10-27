# VS Code & GitHub: Einrichtung, Verbindung und Shell-Befehle

> **Autor:** Michael Stürmer
> **Datum:** 18. Oktober 2026

## Lernziele: VS Code & GitHub

* Die nahtlose Verbindung zwischen Visual Studio Code und GitHub einrichten.
* Ein lokales Repository von Grund auf erstellen und mit einem Remote-Repository auf GitHub verknüpfen.
* Den grundlegenden Git-Workflow (Status prüfen, Änderungen hinzufügen, Committen, Hochladen) sicher über die integrierte Shell steuern.

### Kernkonzepte & Anleitung: VS Code & GitHub

#### 1. Vorbereitung und Grundlagen

Bevor VS Code und GitHub miteinander sprechen können, müssen zwei Grundlagen erfüllt sein:

* **Git muss installiert sein:** Da du bereits mit Arch Linux arbeitest, kennst du das Prinzip. Auf deinem Rechner (oder Raspberry Pi) installierst du Git über die Konsole (z. B. `sudo pacman -S git` unter Arch).
* **GitHub Account:** Du benötigst ein aktives Konto auf GitHub.com. Git ist das lokale Werkzeug auf deinem Rechner, GitHub ist die Cloud-Plattform, auf der dein Code gesichert und geteilt wird.

#### 2. VS Code mit GitHub verbinden

Visual Studio Code bringt eine native GitHub-Integration mit. Die Einrichtung ist unkompliziert:

1. Öffne VS Code.
2. Klicke in der linken Seitenleiste auf das **Quellcodeverwaltung-Symbol** (Source Control, Shortcut: `Ctrl+Shift+G`).
3. Wenn noch keine Verbindung besteht, bietet VS Code oft direkt einen Button "Publish to GitHub" an. Alternativ drückst du `Ctrl+Shift+P` (Command Palette) und suchst nach **"GitHub: Sign in"**.
4. Ein Browser-Fenster öffnet sich. Bestätige dort die Autorisierung.

*Erfolgskontrolle:* Wenn du unten links in der Statusleiste von VS Code auf das kleine Profil-Symbol klickst, sollte dein GitHub-Account nun als angemeldet angezeigt werden.

#### 3. Ein lokales Repository erstellen (über die Shell)

Ein Repository (Repo) ist dein Projektordner, dessen Dateihistorie von Git überwacht wird. Wir nutzen dafür das in VS Code integrierte Terminal (zu öffnen über das Menü *Terminal > New Terminal*).

Führe folgende Befehle nacheinander aus, um dein erstes Repo anzulegen:

```bash
# 1. Navigiere in deinen Projektordner (falls noch nicht geschehen)
cd mein-projektordner

# 2. Initialisiere das lokale Git-Repository
git init

# 3. Lege deinen Namen und deine E-Mail fest (wichtig für die Zuordnung der Änderungen)
git config user.name "Michael Stürmer"
git config user.email "deine.email@beispiel.com"
```

> **Thema:** Git Praxis: Push, Pull und Dateispeicherorte überprüfen
> **Autor:** Michael Stürmer
> **Datum:** 19. Oktober 2026

### Lernziele: Git Praxis

* Den kompletten Git-Zyklus (Ändern, Adden, Committen, Pushen) in einer sicheren Testumgebung simulieren und festigen.
* Die Mechanik von `git pull` verstehen, um dezentrale Änderungen (z. B. vom Raspberry Pi) synchron zu halten.
* Physische und logische Speicherorte von Git-Dateien auf dem lokalen Rechner und dem Remote-Server identifizieren.

### Kernkonzepte & Anleitung: Git Praxis

#### 1. Speicherorte: Wo liegen die Dateien physisch?

Ähnlich wie bei der SPS-Programmierung, wo du ein Offline-Projekt auf dem PG hast und den Online-Stand auf der CPU, arbeitet Git mit zwei getrennten Welten:

* **Lokal (Dein Rechner):** Deine sichtbaren Code-Dateien liegen ganz normal in deinem Projektordner. Die gesamte Versionshistorie (das "Gedächtnis" des Projekts) speichert Git in einem versteckten Ordner namens `.git` direkt in diesem Verzeichnis.
* **Remote (GitHub):** Auf den Servern von GitHub liegt ein exakter Klon deines `.git`-Ordners. GitHub bietet lediglich eine Weboberfläche, die diesen versteckten Ordner ausliest und lesbar im Browser darstellt.

#### 2. Vorbereitung einer sicheren Testumgebung

Um die Befehle gefahrlos zu testen, bauen wir einen Sandbox-Ordner auf. Öffne das VS Code Terminal und tippe:

```bash
# 1. Testordner erstellen und betreten
mkdir git-labor
cd git-labor

# 2. Lokales Git-Gedächtnis (.git Ordner) anlegen
git init

# 3. Erste Datei erstellen
echo "Version 1.0 - Initiale Inbetriebnahme" > prozess-log.md
```
