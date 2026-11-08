> **Thema:** Linux & Bash – Grundlagen, Dateisystem, Pipes und Shell-Skripting
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

<details>
<summary><b>Lernziele</b></summary>

* Den fundamentalen Unterschied zwischen **Terminal-Emulator, Shell (Bash/Zsh) und Betriebssystem-Kernel** sicher erklären.
* Das Linux-Dateisystem (`/`, `/home`, `/etc`, `/var`, `/proc`, `/sys`, `/dev`, `/tmp`) navigieren und mit Standard-Textwerkzeugen (`cat`, `less`, `head`, `tail`, `grep`, `wc`, `sort`, `uniq`, `cut`, `tr`, `sed`, `awk`) analysieren.
* Datenströme (**`stdin` [0], `stdout` [1], `stderr` [2]**), Umleitungen (`>`, `>>`, `2>&1`, `&>`, `/dev/null`, Here-Docs `<<EOF`), **Pipes (`|`)** und **`tee`** beherrschen.
* Die Shell-Umgebung (**Shell- vs. Umgebungsvariablen**, `$PATH`-Hierarchie, `export`, Aliases und farbige **`PS1`-Prompts** via ANSI) anpassen.
* **Shell Expansions** (Tilde-, Brace-, Parameter-, Command- und Arithmetic-Expansion sowie Globbing) fehlerfrei in Befehlen einsetzen.
* Eigene robuste Bash-Skripte mit Striktheitsflags (`set -euo pipefail`), Berechtigungen (`chmod +x`) und Umgebungskonfiguration erstellen.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Architektur: Terminal vs. Shell vs. Kernel</summary>

In der modernen Software- und Systementwicklung werden drei Begriffe oft fälschlich synonym verwendet:
* **Terminal (-Emulator):** Das Fenster bzw. die grafische Oberfläche (z. B. VS Code Integrated Terminal, Kitty, Alacritty, GNOME Terminal, Windows Terminal). Es nimmt Tastatureingaben entgegen und zeichnet Text und Farben auf den Bildschirm.
* **Shell:** Der interaktive Befehlsinterpreter (z. B. **GNU Bash**, Zsh, Fish). Die Shell liest Befehle, führt Syntaxanalysen durch, expandiert Pfade/Variablen und startet Programme.
* **Kernel (Linux):** Der Kern des Betriebssystems. Er verwaltet die Hardware (CPU, RAM, Festplatten, Netzwerkadapter) und stellt Systemaufrufe (System Calls) für Prozesse bereit.

```
┌────────────────────────────────────────────────────────┐
│  Benutzer / Entwickler                                  │
└───────────────────────────┬────────────────────────────┘
                            │ Tastatureingabe / UI
┌───────────────────────────▼────────────────────────────┐
│  Terminal (VS Code Terminal, Kitty, Windows Terminal)   │
└───────────────────────────┬────────────────────────────┘
                            │ Zeilenweises Einlesen
┌───────────────────────────▼────────────────────────────┐
│  Shell (GNU Bash / Zsh) — Interpreter & Expansions     │
└───────────────────────────┬────────────────────────────┘
                            │ Systemaufrufe (syscalls)
┌───────────────────────────▼────────────────────────────┐
│  Linux Kernel (Prozesse, Speicher, Hardwaretreiber)    │
└────────────────────────────────────────────────────────┘
```

</details>

<details>
<summary>1.2 Das Linux-Dateisystem im Vergleich zu Windows & SPS</summary>

Während Windows mit Laufwerksbuchstaben (`C:\`, `D:\`) arbeitet, hängt Linux alle Datenträger und Systembereiche in einen einzigen Verzeichnisbaum unterhalb der **Wurzel (`/`, Root)** ein:

| Pfad | Bedeutung unter Linux | Analogie (Windows / Automatisierungstechnik) |
| :--- | :--- | :--- |
| `/` | **Root-Verzeichnis** (Wurzel des gesamten Baums) | Oberste Anlagenhierarchie |
| `/home/<user>` | Persönliches Benutzerverzeichnis (Kurzform: `~`) | `C:\Users\<Name>` |
| `/etc` | Systemweite **Konfigurationsdateien** (Klartext) | Windows-Registry / Gerätekonfiguration (GSD/XML) |
| `/var/log` | System- und Dienst-**Protokolldateien** (Logs) | Diagnosepuffer der SPS / Ereignisanzeige |
| `/srv` | Daten für bereitgestellte Server-Dienste (z. B. Git, Webserver) | Datenbausteine / Server-Freigaben |
| `/proc` & `/sys` | Virtuelles Abbild von Kernel, CPU und Prozessen in Echtzeit | Systemzustand / Prozessabbild der Eingänge |
| `/dev` | Gerätedateien (Festplatten, serielle Ports, TTYs) | Hardwaretreiber & COM-Ports |
| `/tmp` | Temporäre Dateien (wird bei vielen Systemen im RAM gehalten) | Temporärer Zwischenspeicher |

</details>

<details>
<summary>1.3 Datei- & Verzeichnismanagement in der Bash</summary>

```bash
# 1. Navigation & Orientierung
pwd                     # Aktuelles Arbeitsverzeichnis (Print Working Directory)
ls -la                  # Ausführliche Liste inkl. versteckter Dateien (.git, .env)
cd ~/git-labor          # Ins Verzeichnis wechseln (~ = /home/<user>)
cd -                    # Zum vorherigen Verzeichnis zurückspringen (wie 'Zurück' im Browser)
cd ..                   # Eine Ebene nach oben wechseln

# 2. Dateien & Ordner erzeugen, kopieren, verschieben
mkdir -p build/{debug,release}/logs   # Mehrstufige Ordnerstruktur in einem Schritt anlegen
touch config.json                     # Leere Datei erzeugen oder Zeitstempel aktualisieren
cp quelle.txt ziel.txt                # Datei kopieren
cp -r src/ dist/                      # Ganzen Ordner rekursiv kopieren
mv alt.txt neu.txt                    # Datei umbenennen oder verschieben
rm datei.txt                          # Datei löschen (Achtung: kein Papierkorb!)
rm -rf ordner/                        # Ordner rekursiv und ohne Rückfrage löschen (mit Bedacht nutzen!)
```

</details>

<details>
<summary>1.4 Textdateien analysieren & filtern (cat, less, head, tail, grep, wc, cut, sort, uniq)</summary>

Linux-Administration basiert auf Klartext-Dateien. Folgende Werkzeuge bilden das Rückgrat jeder Logfile- und Datenanalyse:

```bash
# Vollständige Ausgabe & seitenweises Lesen
cat server.log                        # Gesamte Datei auf die Konsole drucken
less /var/log/pacman.log              # Interaktiv blättern (Space = Vor, b = Zurück, / = Suchen, q = Beenden)

# Dateianfang & Datei-Ende
head -n 10 access.log                 # Erste 10 Zeilen
tail -n 20 access.log                 # Letzte 20 Zeilen
tail -f access.log                    # Live-Verfolgung neuer Zeilen (Online-Monitoring)

# Zählen von Zeilen, Wörtern und Bytes
wc -l access.log                      # Zeilenanzahl ermitteln

# Suchen mit Mustern (grep)
grep "ERROR" server.log               # Nach 'ERROR' suchen
grep -i "error" server.log            # Groß-/Kleinschreibung ignorieren
grep -v "DEBUG" server.log            # Zeilen ausschließen (Invert-Match)
grep -rn "API_KEY" src/               # Rekursiv in allen Dateien suchen mit Zeilennummer

# Extrahieren, Sortieren & Deduplizieren
cut -d':' -f1 /etc/passwd             # Erste Spalte (Benutzernamen) getrennt durch Doppelpunkt extrahieren
sort ip_list.txt                      # Alphabetisch sortieren
sort -n ping_times.txt                # Numerisch sortieren
sort ip_list.txt | uniq               # Doppelte Zeilen entfernen (Voraussetzung: vorher sortieren!)
sort ip_list.txt | uniq -c            # Häufigkeit jeder Zeile zählen
```

</details>

<details>
<summary>1.5 Datenströme (stdin, stdout, stderr), Umleitungen & Here-Docs</summary>

Jeder gestartete Linux-Prozess besitzt standardmäßig drei offene Dateideskriptoren:
1. **`stdin` (Deskriptor 0):** Standardeingabe (Tastatur oder Datenstrom aus einer Pipe)
2. **`stdout` (Deskriptor 1):** Standardausgabe (normale Text- und Programmausgaben)
3. **`stderr` (Deskriptor 2):** Standardfehlerausgabe (Fehlermeldungen und Diagnosehinweise)

```bash
# Standardausgabe umleiten (> überschreibt, >> hängt an)
echo "Start: $(date)" > deploy.log
echo "Worker bereit" >> deploy.log

# Nur Fehler (stderr) umleiten
./start-service.sh 2> fehler.log

# stdout und stderr trennen
./start-service.sh > ausgabe.log 2> fehler.log

# stderr in stdout zusammenführen (beides in eine Datei)
./start-service.sh > alles.log 2>&1
# Kurzform in moderner Bash:
./start-service.sh &> alles.log

# Stummschalten von Ausgaben (ins Linux-Schwarze-Loch)
./prüfe-status.sh > /dev/null 2>&1

# Eingabe umleiten (<)
sort < unsortiert.txt

# Here-Document (Mehrzeiligen Textblock direkt in eine Datei schreiben)
cat << 'EOF' > /tmp/app-config.env
PORT=8317
HOST=127.0.0.1
LOG_LEVEL=debug
MODE=production
EOF
```

</details>

<details>
<summary>1.6 Pipes (<code>|</code>), <code>tee</code> & Pipeline-Fehlerbehandlung</summary>

Die Pipe (**`|`**) leitet `stdout` des linken Befehls direkt als `stdin` an den rechten Befehl weiter:

```bash
# Kette: Log anzeigen -> nach 404 filtern -> IP extrahieren -> sortieren -> zählen -> top 5
cat access.log | grep " 404 " | cut -d' ' -f1 | sort | uniq -c | sort -nr | head -n 5

# Das Werkzeug 'tee': Ausgabe gleichzeitig am Bildschirm anzeigen UND in Datei speichern
./datenverarbeitung.sh | tee -a auswertung.log

# Pipeline-Sicherheit in Bash-Skripten:
# Standardmäßig liefert eine Pipe den Exit-Code des LETZTEN Befehls!
# Stürzt der erste Befehl ab, meldet die Shell fälschlicherweise Erfolg.
# Lösung: 'set -o pipefail' sorgt dafür, dass der Gesamtexitcode scheitert, wenn IRGENDEIN Glied scheitert:
set -o pipefail
failing_command | grep "test"    # Schlägt sauber mit dem Exit-Code von failing_command fehl
```

</details>

<details>
<summary>1.7 Shell Environment: Shell-Variablen, Umgebungsvariablen ($PATH) & Aliases</summary>

* **Shell-Variable:** Nur in der aktuellen Shell-Instanz sichtbar; wird **nicht** an Subprozesse vererbt.
* **Umgebungsvariable (Environment Variable):** Wird mit `export` deklariert und an alle Kindprozesse übergeben.
* **Die Suchpfad-Variable `$PATH`:** Ein durch Doppelpunkte getrennter Pfad, in dem die Shell nach ausführbaren Programmen sucht.

```bash
# 1. Shell-Variable vs. Export
NAME="Vanstrike"          # Nur in dieser Shell
export LOG_DIR="/var/log" # An alle Kindprozesse (z. B. Python-Skripte) vererbt

# 2. $PATH inspizieren & erweitern
echo $PATH
# Eigenen Ordner für Skripte an den Pfad anhängen:
export PATH="$HOME/.local/bin:$PATH"

# Welches Programm wird ausgeführt?
which python3             # Zeigt den absoluten Pfad des Programms
type -a python3           # Zeigt, ob es ein Alias, eine Funktion oder ein Binary ist

# 3. Aliases (Tastatur-Abkürzungen)
alias ll='ls -lah --color=auto'
alias gs='git status -sb'
alias ..='cd ..'
# Dauerhaft in ~/.bashrc eintragen und neu laden:
source ~/.bashrc
```

</details>

<details>
<summary>1.8 Farbige Terminal-Prompts gestalten (<code>PS1</code> mit ANSI-Codes)</summary>

Der primäre Eingabeprompt der Shell wird durch die Variable **`PS1`** gesteuert. Durch ANSI-Farbcodes kann der Prompt benutzerfreundlich eingefärbt werden:

```bash
# Wichtige Platzhalter in PS1:
# \u = Benutzername | \h = Hostname | \w = Vollständiger Pfad | \W = Nur aktueller Ordner | \$ = $ für User, # für Root

# Farb-Syntax: \[\e[<Farbcode>m\] ... \[\e[0m\] (Reset)
# 31m = Rot | 32m = Grün | 33m = Gelb | 34m = Blau | 36m = Cyan | 1m = Fett

# Beispiel für einen professionellen zweifarbigen Prompt:
# Grün für user@host, Blau für Pfad:
export PS1="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "

# Prompt mit Git-Branch-Anzeige (in ~/.bashrc integrierbar):
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\[\e[36m\]\u@\h\[\e[0m\]:\[\e[33m\]\w\[\e[35m\]\$(parse_git_branch)\[\e[0m\]\$ "
```

</details>

<details>
<summary>1.9 Shell Expansions (Tilde, Brace, Parameter, Command, Arithmetic & Globbing)</summary>

Bevor die Bash einen Befehl an den Kernel übergibt, durchläuft die Befehlszeile mehrere Expansions-Phasen in fester Reihenfolge:

```bash
# 1. Tilde Expansion (~)
echo ~                   # Ergibt /home/<user>
echo ~/projekte          # Ergibt /home/<user>/projekte

# 2. Brace Expansion ({...}) — Generiert Wortfolgen VOR der Dateisuche
echo {1..5}              # 1 2 3 4 5
echo {a..e}              # a b c d e
touch test_{01..03}.log  # Erzeugt test_01.log test_02.log test_03.log
mkdir -p src/{api,models,views,controllers}

# 3. Parameter Expansion (${...})
PROJEKT="git-labor"
echo ${PROJEKT}
echo ${PROJEKT_NAME:-"standard_wert"}   # Fallback-Wert, falls Variable leer/ungesetzt
echo ${#PROJEKT}                        # Länge des Strings in Zeichen (9)

# 4. Command Substitution ($(command)) — Ausgabe eines Befehls als Argument
HEUTE=$(date +%Y-%m-%d)
BACKUP_FILE="backup_$(uname -m)_$HEUTE.tar.gz"

# 5. Arithmetic Expansion ($((...))) — Mathematische Ganzzahlberechnungen
A=10
B=25
SUMME=$(( A + B * 2 ))                  # 60
REST=$(( 17 % 4 ))                      # 1

# 6. Pathname Expansion (Globbing) — Dateinamen auf der Festplatte abgleichen
ls *.md                  # Alle Dateien mit Endung .md
ls test_?.log            # Genau ein beliebiges Zeichen für ?
ls [0-9][0-9]_*.md       # Alle Dateien, die mit zwei Ziffern gefolgt von Unterstrich beginnen
ls *.[!t][!x][!t]        # Alle Dateien, die NICHT auf .txt enden
```

</details>

<details>
<summary>1.10 Dateirechte (<code>chmod</code>), Besitzer (<code>chown</code>) & Ausführbarkeit</summary>

Unter Linux entscheidet das **Execute-Bit (`x`)** in den Dateiattributen über die Ausführbarkeit:
* `r` (**Read** = 4): Lesen erlaubt
* `w` (**Write** = 2): Schreiben/Ändern erlaubt
* `x` (**Execute** = 1): Ausführen als Programm/Skript erlaubt

```bash
# Berechtigungen numerisch setzen:
# Erste Ziffer: Besitzer (User) | Zweite Ziffer: Gruppe (Group) | Dritte Ziffer: Andere (Others)
chmod 755 start-service.sh     # User: rwx (7), Gruppe: r-x (5), Andere: r-x (5)
chmod 644 config.yaml          # User: rw- (6), Gruppe: r-- (4), Andere: r-- (4)
chmod 600 id_ed25519           # Streng geheimer SSH-Key: nur User darf lesen/schreiben (rw-)

# Berechtigungen symbolisch anpassen:
chmod +x start-service.sh      # Execute-Bit für alle hinzufügen
chmod g-w config.yaml          # Schreibrecht für Gruppe entfernen

# Besitzer und Gruppe ändern (erfordert meist sudo):
sudo chown user:gruppe datei.txt
sudo chown -R alarm:alarm /srv/http/
```

</details>

<details>
<summary>1.11 Saubere Bash-Skripte schreiben (Fail-Fast-Template)</summary>

Ein professionelles Skript nutzt immer den **Shebang (`#!/usr/bin/env bash`)** und den Fail-Fast-Schutz:

```bash
#!/usr/bin/env bash
set -euo pipefail
# -e: Sofortiger Abbruch bei Befehlsfehler (Exit-Code != 0)
# -u: Sofortiger Abbruch bei Verwendung uninitialisierter Variablen
# -o pipefail: Pipeline-Fehler werden erkannt und nicht verschleiert

PROJEKT_NAME="git-labor"
BACKUP_DIR="$HOME/backups"

echo "[INFO] Starte Backup-Workflow für: $PROJEKT_NAME"

if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "[WARN] Backup-Ordner existiert nicht. Erstelle: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

for datei in *.md; do
    [[ -e "$datei" ]] || continue # Schutz bei leerem Verzeichnis
    echo " -> Verarbeite Dokument: $datei"
done

echo "[OK] Workflow erfolgreich abgeschlossen."
```

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Log-Filter & Text-Werkzeuge:** Schreibe eine Befehlszeile mit `cut`, `sort`, `uniq -c` und `grep`, die aus einer simulierten Webserver-Logzeile alle HTTP-Fehlercodes (`4xx` und `5xx`) isoliert und nach ihrer Häufigkeit absteigend auflistet.
2. **Datenstrom-Umleitung:** Führe einen Befehl aus, der gezielt eine Warnmeldung auf `stderr` erzeugt, und leite `stdout` in `erfolg.log` und `stderr` in `fehler.log` um. Teste anschließend die Kurzform `&> gesamt.log`.
3. **Shell Expansions:** Erstelle mit einem einzigen Befehl via Brace Expansion die Ordnerstruktur `backup/{2026..2027}/{01..12}` und prüfe mit `ls -R backup`, wie viele Unterordner entstanden sind.
4. **Farbiger Prompt:** Konfiguriere temporär in deiner Shell einen zweifarbigen `PS1`-Prompt (z. B. Cyan für deinen Benutzernamen und Gelb für den Ordnerpfad) und teste die Rücksetzung mit `\[\e[0m\]`.
5. **Fail-Fast-Skript:** Erweitere `check-env.sh` mit `set -euo pipefail` und prüfe, was passiert, wenn eine nicht existierende Umgebungsvariable `$UNBEKANNT` aufgerufen wird.

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [GNU Bash Reference Manual (Offizielle Dokumentation)](https://www.gnu.org/software/bash/manual/bash.html)
* [ArchWiki – Bash Grundlagen, Aliases & Prompt Configuration](https://wiki.archlinux.org/title/Bash)
* [ShellCheck – Online Linter & statische Analyse für Shell-Skripte](https://www.shellcheck.net/)
* [Jannis Seemann – Bash & Linux CLI Kompendium](https://github.com/jannisseemann)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **Schichten-Modell:** Das Terminal zeichnet Fenster und Text, die Shell (Bash) interpretiert Befehle & Expansions, der Linux-Kernel steuert Hardware und Speicher.
* **Dateibaum-Philosophie:** Unter Linux existieren keine Laufwerksbuchstaben; alles hängt im einheitlichen Baum unter `/` (`/etc` für Konfigurationen, `/var/log` für Logs, `/home` für Benutzer).
* **Datenströme (0, 1, 2):** Trenne Erfolgsmeldungen (`stdout` = 1) sauber von Fehlern (`stderr` = 2) oder führe sie mit `&> datei.log` bzw. `2>&1` zusammen.
* **Pipeline-Sicherheit:** Nutze `set -o pipefail`, damit Fehler innerhalb einer Pipe (`cmd1 | cmd2`) nicht durch den Exit-Code des letzten Befehls maskiert werden.
* **Expansions vor Befehlsausführung:** Brace Expansion (`{1..5}`), Command Substitution (`$(...)`) und Arithmetic Expansion (`$((...))`) werden von der Bash expandiert, bevor der Kernel den Befehl sieht.
* **Persistente Shell-Umgebung:** Variablen mit `export` deklarieren, Aliases und Prompts (`PS1`) in `~/.bashrc` hinterlegen und via `source ~/.bashrc` aktivieren.

</details>

---
*Hinweis zur Organisation:* Die erstellte Dokumentation ist am Drehlaufwerk abgelegt und mit einer kurzen Zusammenfassung von den Chips auch in den Notebooks verlinkt.

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
details.doku-minimap { position: fixed; bottom: 18px; right: 18px; z-index: 9999; width: 250px; max-height: 76px; overflow: hidden; background: rgba(15, 23, 42, 0.94); border: 1px solid rgba(96, 165, 250, 0.65); border-radius: 10px; box-shadow: 0 8px 26px rgba(0, 0, 0, 0.65); backdrop-filter: blur(8px); transition: width 0.18s ease, max-height 0.18s ease; font-family: var(--vscode-font-family, sans-serif); }
details.doku-minimap:hover { border-color: #60a5fa; }
details.doku-minimap[open] { width: min(860px, 94vw); max-height: 84vh; overflow-y: auto; padding-bottom: 10px; }
details.doku-minimap > summary { cursor: pointer; list-style: none; padding: 8px 12px; font-weight: 700; font-size: 0.84em; color: #f8fafc; background: linear-gradient(90deg, rgba(37, 99, 235, 0.45), rgba(30, 41, 59, 0.9)); border-bottom: 1px solid rgba(148, 163, 184, 0.25); display: flex; align-items: center; justify-content: space-between; user-select: none; }
details.doku-minimap > summary::-webkit-details-marker { display: none; }
details.doku-minimap .minimap-preview-strip { display: flex; gap: 4px; padding: 5px 10px 7px 10px; font-size: 0.72em; color: #94a3b8; justify-content: space-between; }
details.doku-minimap[open] .minimap-preview-strip { display: none; }
details.doku-minimap .minimap-preview-strip span { background: rgba(30, 41, 59, 0.9); padding: 2px 6px; border-radius: 4px; border: 1px solid rgba(148, 163, 184, 0.25); }
details.doku-minimap .minimap-body { padding: 8px 12px 4px 12px; }
</style>
<details class="doku-minimap">
<summary><span>🗺️ Doku-Minimap (5 Rubriken &amp; Labs)</span><span title="Klicken zum Vergrößern / Einklappen">⛶</span></summary>
<div class="minimap-preview-strip"><span>01 Linux</span><span>02 VSCode</span><span>03 Python</span><span>04 JS/TS</span><span>05 Agents</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root">🏛️ <a href="../README.md">VanstrikeCyborg — git-labor Lern- &amp; Test-Architektur (Doku-Index)</a>  |  <a href="../../README.md">Repo-README</a>  |  <a href="../../AGENTS.md">AGENTS.md</a>  |  <a href="../../notebook-agent-environments/README.md">Notebooks</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🐧 <a href="README.md">01_Linux_Bash (Linux, Shell &amp; Container)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="01_bash-grundlagen-und-skripting.md">01 • Bash-Grundlagen, Skripting, Pipes &amp; Exit-Codes</a> <a class="doku-arch-badge" href="../../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="02_arch-linux-omarchy-und-remote-ssh.md">02 • Arch Linux, Omarchy, systemd &amp; Remote-SSH</a></li>
<li>└─ <a href="03_docker-und-sbx-micro-vms.md">03 • Docker Grundlagen &amp; Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="../02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP &amp; Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) &amp; Remote</a></li>
<li>├─ <a href="../02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow &amp; Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="../02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Localhost-Proxy &amp; Port-Diagnose (8317)</a></li>
<li>└─ <a href="../02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio &amp; API-Keys</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="../03_Python_Coding/README.md">03_Python_Coding (Python, uv &amp; GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance &amp; Notebooks</a></li>
<li>├─ <a href="../03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">02 • Google GenAI SDK (google-genai) &amp; Interactions API</a></li>
<li>└─ <a href="../03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md">03 • Automatisierung, Datenanalyse &amp; pytest</a> <a class="doku-arch-badge" href="../../labs/03_python/sensor_demo.py">sensor_demo.py</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">🌐 <a href="../04_JS_TS_Web/README.md">04_JS_TS_Web (HTML/CSS, JS/TS &amp; Web-SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">01 • HTML5, CSS3 &amp; DOM-Manipulation Grundlagen</a> <a class="doku-arch-badge" href="../../labs/04_js_ts_web/rechner.html">rechner.html</a></li>
<li>├─ <a href="../04_JS_TS_Web/02_modernes-javascript-und-typescript.md">02 • Modernes JavaScript (ES6+) &amp; TypeScript</a></li>
<li>└─ <a href="../04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">03 • Google GenAI SDK (@google/genai) für Web-Apps</a></li>
</ul>
</div>
<div class="doku-arch-card r5">
<div class="doku-arch-card-title">🤖 <a href="../05_Agents/README.md">05_Agents (KI-Agenten, Skills &amp; Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">01 • Agent-Stilfibel, Didaktik-Ruler &amp; 7-Stufen-Aufbau</a></li>
<li>├─ <a href="../05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">02 • Agenten erstellen: Instructions, Rules &amp; Prompts</a> <a class="doku-arch-badge" href="../../.github/instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>├─ <a href="../05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills (SKILL.md) &amp; MCP-Tools</a> <a class="doku-arch-badge" href="../../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>└─ <a href="../05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Agenten trainieren, primen &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../../.github/agents/light.agent.md">@light</a> <a class="doku-arch-badge" href="../../.github/agents/rig.agent.md">@rig</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
