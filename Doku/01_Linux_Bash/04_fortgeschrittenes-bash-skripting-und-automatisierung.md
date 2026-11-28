> **Thema:** Fortgeschrittenes Bash-Skripting, Kontrollstrukturen, Arrays, getopts & Automatisierungsprojekte
> **Autor:** Michael Stürmer
> **Datum:** 08.11.2026

# 04 – Fortgeschrittenes Bash-Skripting & Automatisierungs-Pipelines

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (01 Linux & Bash)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 01 Linux & Bash](./README.md) · **Vorheriges:** [⬅️ 03 • Arch Linux, Omarchy, Remote-SSH & Nginx](./03_arch-linux-omarchy-und-remote-ssh.md) · **Nächstes:** [05 • Docker Grundlagen & Sandbox Micro-VMs (sbx) ➡️](./05_docker-und-sbx-micro-vms.md)

**Alle Module in `01_Linux_Bash/`:**
- [01 • Bash CLI, Text-Tools, Streams & Expansions](./01_bash-grundlagen-und-skripting.md) · `check-env.sh`
- [02 • Inodes, LVM, Prozesse, Boot-Prozess & systemd](./02_linux-systemadministration-und-interna.md)
- [03 • Arch Linux, Omarchy, Remote-SSH & Nginx](./03_arch-linux-omarchy-und-remote-ssh.md)
- 👉 **[04 • Advanced Bash: Arrays, getopts & Backups](./04_fortgeschrittenes-bash-skripting-und-automatisierung.md)** *(aktuell)*
- [05 • Docker Grundlagen & Sandbox Micro-VMs (sbx)](./05_docker-und-sbx-micro-vms.md)

**Weitere Rubriken:** [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🐍 03 Python](../03_Python_Coding/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md) · [🤖 05 Agents](../05_Agents/README.md) · [🏎️ 06 AC KN5 Modding](../06_AC_KN5_Modding/README.md) · [🥽 07 VR Engineering](../07_VR_Engineering/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

<details>
<summary><b>Lernziele</b></summary>

* Arithmetische Ganzzahl- (`$((...))`) und Gleitkomma-Berechnungen (`bc`) in Shell-Skripten durchführen.
* Alle **Kontrollstrukturen** (`if/elif/else`, `case`) mit vollständigen Dateitests (`-f`, `-d`, `-s`, `-e`), Stringvergleichen (`-z`, `-n`, Regex `=~`) und Zahlenvergleichen (`-eq`, `-lt`, etc.) einsetzen.
* **Schleifen** (`for`, C-Style-`for`, `while`, `until`) und das sichere zeilenweise Einlesen von Dateien (`while IFS= read -r`) beherrschen.
* Indizierte und assoziative **Bash-Arrays (`declare -a`, `declare -A`)** deklarieren, iterieren und manipulieren.
* Funktionen mit sicherem Scoping (**`local`**), Parameterübergabe und Rückgabewerten schreiben.
* Robuste CLI-Argumente über **`getopts`** parsen.
* Praxisprojekte aus dem Lehrkompendium realisieren: **API-Daten mit `curl` & `jq` abrufen**, **automatisierte Backup-Rotation (`tar.gz`)**, **Verzeichnis-Monitore** und **CLI-Dialoge (`whiptail`)**.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Arithmetik in Bash: Ganzzahlen ($((...))) & Gleitkommazahlen (bc)</summary>

Die Standard-Bash unterstützt nativ nur Ganzzahl-Arithmetik. Für Kommazahlen wird das Werkzeug **`bc` (Basic Calculator)** angebunden:

```bash
# 1. Native Ganzzahl-Berechnungen ($(( ... )))
A=20
B=6
SUMME=$(( A + B ))              # 26
PRODUKT=$(( A * B ))            # 120
DIVISION=$(( A / B ))           # 3 (Ganzzahlig abgerundet!)
MODULO=$(( A % B ))             # 2 (Rest der Division)
POTENZ=$(( 2 ** 8 ))            # 256

# Inkrementieren / Dekrementieren
(( A++ ))                       # A ist jetzt 21
(( B += 4 ))                    # B ist jetzt 10

# 2. Gleitkommazahlen mit 'bc' berechnen (scale definiert Nachkommastellen)
ERGEBNIS=$(echo "scale=3; 20 / 6" | bc)
echo "Exakte Division: $ERGEBNIS"   # 3.333

# Fließkomma-Vergleich in Bash:
IST_GROESSER=$(echo "3.33 > 2.5" | bc)  # Gibt 1 (wahr) oder 0 (falsch) zurück
```

</details>

<details>
<summary>1.2 Bedingungen & Kontrollstrukturen: if, [[ ... ]] und case</summary>

In moderner Bash wird fast immer die erweiterte Test-Syntax **`[[ ... ]]`** (statt altem `[ ... ]`) genutzt, da sie Worttrennung verhindert und Regex-Matching unterstützt:

```bash
# 1. Dateitests
DATEI="/etc/nginx/nginx.conf"
if [[ -f "$DATEI" ]]; then
    echo "Reguläre Datei existiert."
elif [[ -d "$DATEI" ]]; then
    echo "Es ist ein Verzeichnis."
elif [[ -L "$DATEI" ]]; then
    echo "Es ist ein symbolischer Link."
fi

# Weitere Tests:
# -e $PFAD : Existiert überhaupt (Datei oder Ordner)
# -s $DATEI: Datei existiert UND ihre Größe ist > 0 Bytes
# -r / -w / -x $PFAD : Lesbar / Schreibbar / Ausführbar

# 2. String-Tests & Reguläre Ausdrücke (=~)
BENUTZER_INPUT="admin@example.com"

if [[ -z "$BENUTZER_INPUT" ]]; then
    echo "Fehler: Eingabe ist leer!"
elif [[ -n "$BENUTZER_INPUT" ]]; then
    echo "Eingabe vorhanden."
fi

# Regex-Prüfung (z. B. E-Mail oder Versionsnummer):
if [[ "$BENUTZER_INPUT" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Gültige E-Mail-Adresse."
fi

# 3. Numerische Vergleiche:
# -eq (gleich) | -ne (ungleich) | -lt (kleiner) | -le (kleiner gleich) | -gt (größer) | -ge (größer gleich)
STATUS=200
if [[ "$STATUS" -eq 200 ]]; then
    echo "HTTP Status OK"
fi

# 4. Mehrfachauswahl mit case
AKTION="restart"
case "$AKTION" in
    start)
        echo "Dienst wird gestartet..."
        ;;
    stop)
        echo "Dienst wird gestoppt..."
        ;;
    restart|reload)
        echo "Dienst wird neu geladen..."
        ;;
    *)
        echo "Ungültiger Befehl: $AKTION"
        exit 1
        ;;
esac
```

</details>

<details>
<summary>1.3 Schleifen: for, while, until & zeilenweises Einlesen</summary>

```bash
# 1. For-Schleife über eine Liste oder Glob
for server in rpi4 omarchy simracer; do
    echo "Pinge Server: $server"
done

# 2. C-Style For-Schleife (Zählschleife)
for ((i = 1; i <= 5; i++)); do
    echo "Durchlauf $i von 5"
done

# 3. While-Schleife mit Bedingung
COUNTER=5
while [[ "$COUNTER" -gt 0 ]]; do
    echo "Countdown: $COUNTER"
    (( COUNTER-- ))
done

# 4. Dateien sicher zeilenweise einlesen (IFS= verhindert Whitespace-Stripping, -r verhindert Backslash-Interpretation)
while IFS= read -r zeile || [[ -n "$zeile" ]]; do
    echo "Zeile aus Log: $zeile"
done < /var/log/pacman.log
```

</details>

<details>
<summary>1.4 Bash-Arrays: Indizierte und assoziative Arrays (Dictionaries)</summary>

```bash
# 1. Indizierte Arrays (Listen)
diensten=("nginx" "sshd" "docker" "mosquitto")

# Zugriff auf erstes Element (0-basiert):
echo "Erster Dienst: ${diensten[0]}"

# Alle Elemente ausgeben:
echo "Alle Dienste: ${diensten[@]}"

# Anzahl der Elemente (#):
echo "Anzahl Dienste: ${#diensten[@]}"

# Element anhängen (+=):
diensten+=("postgresql")

# Über alle Elemente iterieren:
for dienst in "${diensten[@]}"; do
    echo " -> Prüfe Service: $dienst"
done

# 2. Assoziative Arrays (Key-Value Dictionaries, erfordert declare -A)
declare -A app_config
app_config["app_name"]="git-labor"
app_config["port"]="8317"
app_config["env"]="production"

# Zugriff über Schlüssel:
echo "Port: ${app_config["port"]}"

# Alle Schlüssel iterieren (!):
for schluessel in "${!app_config[@]}"; do
    echo "Key: $schluessel = Value: ${app_config[$schluessel]}"
done
```

</details>

<details>
<summary>1.5 Funktionen, Parameter & lokaler Gültigkeitsbereich (local)</summary>

```bash
# Funktion deklarieren
log_nachricht() {
    # 'local' verhindert, dass Variablen die globale Shell überschreiben:
    local level="$1"
    local text="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    echo "[$timestamp] [$level] $text"
}

# Funktion aufrufen
log_nachricht "INFO" "Skript erfolgreich initialisiert"
log_nachricht "WARN" "Hohe Festplattenauslastung festgestellt"

# Rückgabewerte:
# 'return 0' signalisiert Erfolg (0-255 für Exit-Codes)
# Komplexe Daten werden über stdout ausgegeben und per $(...) aufgefangen:
ermittle_ip() {
    local host="$1"
    local ip
    ip=$(dig +short "$host" | head -n 1)
    echo "$ip"
}

ZIEL_IP=$(ermittle_ip "google.com")
echo "Gefundene IP: $ZIEL_IP"
```

</details>

<details>
<summary>1.6 CLI-Argumente parsen mit getopts</summary>

Für Werkzeuge mit flexiblen Flags (z. B. `./script.sh -h -v -f datei.txt`):

```bash
#!/usr/bin/env bash
set -euo pipefail

VERBOSE=false
DATEI=""

usage() {
    echo "Verwendung: $0 [-h] [-v] -f <datei>"
    exit 1
}

# Doppelpunkt nach einem Buchstaben bedeutet: Diese Option erwartet ein Argument!
while getopts "hvf:" opt; do
    case "$opt" in
        h)
            usage
            ;;
        v)
            VERBOSE=true
            ;;
        f)
            DATEI="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "$DATEI" ]]; then
    echo "[FEHLER] Bitte geben Sie eine Datei mit -f an."
    usage
fi

if [[ "$VERBOSE" == true ]]; then
    echo "[DEBUG] Verarbeite Datei im Verbose-Modus: $DATEI"
fi
```

</details>

<details>
<summary>1.7 Praxis-Projekt 1: API-Daten abrufen mit curl & JSON parsen (jq)</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

API_URL="https://api.github.com/repos/torvalds/linux"
CACHE_FILE="/tmp/github_repo.json"

echo "[INFO] Rufe GitHub API ab: $API_URL"
HTTP_STATUS=$(curl -s -w "%{http_code}" -o "$CACHE_FILE" "$API_URL")

if [[ "$HTTP_STATUS" -ne 200 ]]; then
    echo "[FEHLER] API-Aufruf fehlgeschlagen mit HTTP $HTTP_STATUS"
    exit 1
fi

# JSON mit 'jq' analysieren
if command -v jq &> /dev/null; then
    REPO_NAME=$(jq -r '.name' "$CACHE_FILE")
    STARS=$(jq -r '.stargazers_count' "$CACHE_FILE")
    FORKS=$(jq -r '.forks_count' "$CACHE_FILE")

    echo "Repository: $REPO_NAME"
    echo "Sterne:     $STARS"
    echo "Forks:      $FORKS"
else
    echo "[WARN] jq ist nicht installiert. Rohes JSON liegt in $CACHE_FILE"
fi
```

</details>

<details>
<summary>1.8 Praxis-Projekt 2: Robustes Backup-Skript mit Rotation & Kompression</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

QUELL_VERZEICHNIS="$HOME/git-labor"
ZIEL_ORDNER="$HOME/backups/git-labor"
MAX_TAGE=7

mkdir -p "$ZIEL_ORDNER"

ZEITSTEMPEL=$(date +"%Y%m%d_%H%M%S")
ARCHIV_NAME="git_labor_backup_${ZEITSTEMPEL}.tar.gz"
ZIEL_DATEI="${ZIEL_ORDNER}/${ARCHIV_NAME}"

echo "[INFO] Starte komprimiertes Backup von $QUELL_VERZEICHNIS nach $ZIEL_DATEI..."

# Archiv mit tar und gzip erstellen (--exclude ignoriert temporäre Build-Caches)
tar --exclude='.venv' --exclude='node_modules' --exclude='.git' \
    -czf "$ZIEL_DATEI" -C "$(dirname "$QUELL_VERZEICHNIS")" "$(basename "$QUELL_VERZEICHNIS")"

GROESSE=$(du -h "$ZIEL_DATEI" | cut -f1)
echo "[OK] Backup erfolgreich erstellt: $ARCHIV_NAME ($GROESSE)"

# Alte Backups rotieren (alle Archive löschen, die älter als MAX_TAGE sind)
echo "[INFO] Bereinige Backups älter als $MAX_TAGE Tage..."
find "$ZIEL_ORDNER" -name "git_labor_backup_*.tar.gz" -type f -mtime +"$MAX_TAGE" -exec rm -v {} \;

echo "[FERTIG] Backup-Workflow abgeschlossen."
```

</details>

<details>
<summary>1.9 Praxis-Projekt 3: Verzeichnis-Größen-Monitor mit Array-Schwellwertprüfung</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

# Zu überwachende Pfade in einem Array
PFADE=("/var/log" "/tmp" "$HOME/git-labor")
MAX_MB=500

echo "=== Verzeichnis-Größen-Monitor ==="

for pfad in "${PFADE[@]}"; do
    if [[ ! -d "$pfad" ]]; then
        echo "[SKIP] Pfad nicht gefunden: $pfad"
        continue
    fi

    # Größe in Megabytes ermitteln (du -sm)
    GROESSE_MB=$(du -sm "$pfad" 2> /dev/null | cut -f1)

    if [[ "$GROESSE_MB" -ge "$MAX_MB" ]]; then
        echo "[WARNUNG] $pfad belegt $GROESSE_MB MB (Schwellwert: $MAX_MB MB überschritten!)"
    else
        echo "[OK]      $pfad belegt $GROESSE_MB MB"
    fi
done
```

</details>

<details>
<summary>1.10 Praxis-Projekt 4: Interaktive CLI-Dialoge mit whiptail / dialog</summary>

Für professionelle Konsolen-Installationsassistenten (wie im Debian-/Arch-Installer):

```bash
#!/usr/bin/env bash

# Prüfen, ob whiptail vorhanden ist
if ! command -v whiptail &> /dev/null; then
    echo "whiptail nicht installiert. Nutzen Sie die Standard-Textabfrage."
    exit 0
fi

# Ja/Nein-Dialog
if whiptail --title "System-Backup" --yesno "Möchten Sie jetzt ein vollständiges Backup starten?" 10 60; then
    # Menü-Auswahl
    AUSWAHL=$(whiptail --title "Backup-Ziel" --menu "Wählen Sie das Ziel:" 15 60 4 \
        "1" "Lokaler USB-Stick (/mnt/usb)" \
        "2" "Netzwerk-Freigabe (SMB / NAS)" \
        "3" "Cloud / Remote-SSH Server" 3>&1 1>&2 2>&3)

    whiptail --msgbox "Gewähltes Backup-Ziel: Option $AUSWAHL" 8 45
else
    echo "Vorgang durch Benutzer abgebrochen."
fi
```

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Arithmetik & `bc`:** Schreibe ein Skript, das zwei Festplattenbelegungen in Bytes entgegennimmt und das prozentuale Verhältnis auf 2 Nachkommastellen genau berechnet.
2. **Regex-Validierung:** Implementiere eine Funktion `ist_gueltige_ip()`, die mit dem Bash-Operator `=~` prüft, ob ein übergebener String eine syntaktisch korrekte IPv4-Adresse (`0-255.0-255.0-255.0-255`) ist.
3. **Array-Deduplizierung:** Erstelle ein indiziertes Array mit 10 Elementen (einige doppelt) und filtere alle doppelten Werte heraus, sodass am Ende jedes Element nur einmal im Array vorkommt.
4. **CLI-Argumente mit getopts:** Schreibe ein Skript `transfer.sh`, das `-s <quelle>`, `-d <ziel>` und optional `-c` (für Kompression) annimmt und die Werte validiert ausgibt.
5. **Automatisierte Backup-Rotation:** Erweitere das Backup-Skript aus Abschnitt 1.8 so, dass es vor der Archivierung prüft, ob mindestens 1 GB freier Festplattenspeicher vorhanden ist (`df`).

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [Jannis Seemann – Advanced Bash Scripting Guide](https://github.com/jannisseemann)
* [Bash Hackers Wiki – Parameter Expansion & Arrays](https://wiki.bash-hackers.org/)
* [Greg's Wiki (BashFAQ) – Das fundierteste Bash-Referenzwerk](https://mywiki.wooledge.org/BashFAQ)
* [jq Manual – Command-line JSON processor](https://stedolan.github.io/jq/manual/)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **Robuste Tests mit `[[ ... ]]`:** Nutze immer doppelte eckige Klammern für Stringvergleiche, Leerheitsprüfungen (`-z`) und reguläre Ausdrücke (`=~`).
* **Sicheres Scoping mit `local`:** Deklariere Variablen in Funktionen stets als `local`, um unbemerkte Überschreibungen im Hauptskript auszuschließen.
* **Array-Power:** Indizierte Arrays (`arr=("a" "b")`) für Sequenzen und assoziative Arrays (`declare -A map`) für Key-Value-Konfigurationen nutzen.
* **Saubere Argumente mit `getopts`:** Ersetze fehleranfälliges `$1`, `$2`-Parsing durch den Standard-Parser `getopts`.
* **Automatisierung mit Absicherung:** Kombiniere `set -euo pipefail` mit `tar`, `find -mtime` und `curl` für wartungsfreie Produktionsskripte.

</details>

---
*Hinweis zur Organisation:* Die erstellte Dokumentation ist am Drehlaufwerk abgelegt und mit einer kurzen Zusammenfassung von den Chips auch in den Notebooks verlinkt.

<!-- DOKU-MINIMAP-START -->
<style>
.doku-arch-flow { font-family: var(--vscode-editor-font-family, Consolas, monospace); background: linear-gradient(160deg, rgba(15, 23, 42, 0.96), rgba(17, 24, 39, 0.94)); border: 1px solid rgba(96, 165, 250, 0.35); border-radius: 12px; padding: 14px 16px; margin: 8px 0 0 0; color: #e2e8f0; }
.doku-arch-root { display: flex; flex-wrap: wrap; align-items: center; justify-content: center; gap: 10px; font-weight: 700; font-size: 0.98em; padding: 9px 14px; margin-bottom: 12px; background: linear-gradient(135deg, rgba(37, 99, 235, 0.28), rgba(30, 41, 59, 0.92)); border: 1px solid rgba(96, 165, 250, 0.48); border-radius: 10px; }
.doku-arch-root a { color: #93c5fd !important; text-decoration: none !important; }
.doku-arch-root a:hover { color: #dbeafe !important; text-decoration: underline !important; }
.doku-arch-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(268px, 1fr)); gap: 11px; }
.doku-arch-card { background: rgba(30, 41, 59, 0.72); border: 1px solid rgba(148, 163, 184, 0.24); border-top: 3px solid #3b82f6; border-left: 4px solid #3b82f6; border-radius: 10px; padding: 10px 12px; transition: transform 0.14s ease, border-color 0.14s ease, box-shadow 0.14s ease; }
.doku-arch-card:hover { border-color: #93c5fd; transform: translateY(-2px); box-shadow: 0 6px 18px rgba(0, 0, 0, 0.35); }
.doku-arch-card.r1 { border-left-color: #22c55e; border-top-color: #22c55e; }
.doku-arch-card.r2 { border-left-color: #3b82f6; border-top-color: #3b82f6; }
.doku-arch-card.r3 { border-left-color: #eab308; border-top-color: #eab308; }
.doku-arch-card.r4 { border-left-color: #ec4899; border-top-color: #ec4899; }
.doku-arch-card.r5 { border-left-color: #a855f7; border-top-color: #a855f7; }
.doku-arch-card.r6 { border-left-color: #f97316; border-top-color: #f97316; }
.doku-arch-card.r7 { border-left-color: #06b6d4; border-top-color: #06b6d4; }
.doku-arch-card-title { font-weight: 700; font-size: 0.93em; margin-bottom: 7px; padding-bottom: 5px; border-bottom: 1px dashed rgba(148, 163, 184, 0.26); }
.doku-arch-card-title a { color: #f8fafc !important; text-decoration: none !important; display: block; }
.doku-arch-card-title a:hover { color: #93c5fd !important; }
.doku-arch-lines { list-style: none; margin: 0; padding: 0; font-size: 0.84em; line-height: 1.5; }
.doku-arch-lines li { margin: 3px 0; padding: 2px 6px; border-radius: 5px; white-space: normal; }
.doku-arch-lines li:hover { background: rgba(59, 130, 246, 0.16); }
.doku-arch-lines a { color: #cbd5e1 !important; text-decoration: none !important; display: inline; }
.doku-arch-lines a:hover { color: #93c5fd !important; text-decoration: underline !important; }
.doku-arch-badge { display: inline-block; font-size: 0.74em; padding: 0 6px; margin-left: 5px; border-radius: 999px; background: rgba(59, 130, 246, 0.22); color: #bfdbfe !important; border: 1px solid rgba(96, 165, 250, 0.4); }
details.doku-minimap { position: fixed; bottom: 18px; right: 18px; z-index: 9999; width: 292px; max-height: 76px; overflow: hidden; background: rgba(15, 23, 42, 0.93); border: 1px solid rgba(96, 165, 250, 0.62); border-radius: 14px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.65); backdrop-filter: blur(10px); transition: width 0.18s ease, max-height 0.18s ease, border-color 0.18s ease; font-family: var(--vscode-font-family, sans-serif); }
details.doku-minimap:hover { border-color: #93c5fd; }
details.doku-minimap[open] { width: min(920px, 94vw); max-height: 84vh; overflow-y: auto; padding-bottom: 10px; border-radius: 14px; }
details.doku-minimap > summary { cursor: pointer; list-style: none; padding: 8px 13px; font-weight: 700; font-size: 0.84em; color: #f8fafc; background: linear-gradient(90deg, rgba(37, 99, 235, 0.45), rgba(30, 41, 59, 0.92)); border-bottom: 1px solid rgba(148, 163, 184, 0.24); display: flex; align-items: center; justify-content: space-between; user-select: none; }
details.doku-minimap > summary::-webkit-details-marker { display: none; }
details.doku-minimap > summary .minimap-toggle::after { content: "+"; font-size: 1.05em; opacity: 0.85; padding: 0 4px; }
details.doku-minimap[open] > summary .minimap-toggle::after { content: "−"; }
details.doku-minimap .minimap-preview-strip { display: flex; gap: 5px; padding: 6px 10px 8px 10px; font-size: 0.71em; color: #cbd5e1; justify-content: space-between; }
details.doku-minimap[open] .minimap-preview-strip { display: none; }
details.doku-minimap .minimap-preview-strip span { display: inline-flex; align-items: center; gap: 4px; background: rgba(30, 41, 59, 0.92); padding: 2px 7px; border-radius: 999px; border: 1px solid rgba(148, 163, 184, 0.26); }
details.doku-minimap .dot { width: 6px; height: 6px; border-radius: 50%; display: inline-block; }
details.doku-minimap .dot.r1 { background: #22c55e; }
details.doku-minimap .dot.r2 { background: #3b82f6; }
details.doku-minimap .dot.r3 { background: #eab308; }
details.doku-minimap .dot.r4 { background: #ec4899; }
details.doku-minimap .dot.r5 { background: #a855f7; }
details.doku-minimap .dot.r6 { background: #f97316; }
details.doku-minimap .dot.r7 { background: #06b6d4; }
details.doku-minimap .minimap-body { padding: 4px 12px 6px 12px; }
</style>
<details class="doku-minimap">
<summary><span>🗺️ Doku-Minimap (7 Rubriken &amp; Labs)</span><span class="minimap-toggle" title="Klicken zum Vergrößern / Einklappen"></span></summary>
<div class="minimap-preview-strip"><span><i class="dot r1"></i>Linux</span><span><i class="dot r2"></i>VSCode</span><span><i class="dot r3"></i>Python</span><span><i class="dot r4"></i>JS/TS</span><span><i class="dot r5"></i>Agents</span><span><i class="dot r6"></i>KN5</span><span><i class="dot r7"></i>VR</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root"><span>🏛️ <a href="../README.md">VanstrikeCyborg — git-labor Doku-Index</a></span> · <a href="../../README.md">Repo-README</a> · <a href="../../AGENTS.md">AGENTS.md</a> · <a href="../../notebook-agent-environments/README.md">Notebooks</a> · <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-28.md">Letztstand 28.11.</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🐧 <a href="../01_Linux_Bash/README.md">01_Linux_Bash (Linux, Shell &amp; Container)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 • Bash CLI, Text-Tools, Streams &amp; Expansions</a> <a class="doku-arch-badge" href="../../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="../01_Linux_Bash/02_linux-systemadministration-und-interna.md">02 • Inodes, LVM, Prozesse, Boot-Prozess &amp; systemd</a></li>
<li>├─ <a href="../01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">03 • Arch Linux, Omarchy, Remote-SSH &amp; Nginx</a></li>
<li>├─ <a href="../01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">04 • Advanced Bash: Arrays, getopts &amp; Backups</a></li>
<li>└─ <a href="../01_Linux_Bash/05_docker-und-sbx-micro-vms.md">05 • Docker Grundlagen &amp; Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="../02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP &amp; Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) &amp; Remote</a></li>
<li>├─ <a href="../02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow &amp; Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="../02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Ollama (:11434) &amp; Ports (Archiv: Proxy)</a> <a class="doku-arch-badge" href="../../.vscode/mcp.json">mcp.json</a></li>
<li>├─ <a href="../02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio &amp; API-Keys</a></li>
<li>└─ <a href="../02_VSCode_Env/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">05 • 5-Knoten-Verbund, Parity &amp; Parallel-Limits</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="../03_Python_Coding/README.md">03_Python_Coding (Python, uv &amp; GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance &amp; Notebooks</a> <a class="doku-arch-badge" href="../../notebook-agent-environments/agent_demo.ipynb">.ipynb</a></li>
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
<li>├─ <a href="../05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills &amp; MCP-Tools</a> <a class="doku-arch-badge" href="../../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>├─ <a href="../05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Priming, Memory &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../../.github/agents/light.agent.md">@light</a></li>
<li>├─ <a href="../05_Agents/05_workspace-schnittstelle-simracer-und-agenten-terminals.md">05 • Schnittstelle, Terminals &amp; XOR-Mutex</a> <a class="doku-arch-badge" href="../../labs/03_python/sim_agent_bridge.py">Bridge</a></li>
<li>├─ <a href="../05_Agents/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">06 • Multi-Workspace Netzwerk &amp; 7-Rollen-Verbund</a></li>
<li>└─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-28.md">Letztstand 28.11. (Labs 06/07, Cleanup &amp; KN5-Fix)</a></li>
</ul>
</div>
<div class="doku-arch-card r6">
<div class="doku-arch-card-title">🏎️ <a href="../06_AC_KN5_Modding/README.md">06_AC_KN5_Modding (.kn5 &amp; Toolchain)</a></div>
<ul class="doku-arch-lines">
<li>└─ <a href="../06_AC_KN5_Modding/01_kn5-format-entwicklungsumgebung-und-setup.md">01 • .kn5-Format, ext_config &amp; Sandbox-Gate</a> <a class="doku-arch-badge" href="../../labs/06_ac_kn5_modding/inspect_kn5.py">inspect_kn5.py</a></li>
</ul>
</div>
<div class="doku-arch-card r7">
<div class="doku-arch-card-title">🥽 <a href="../07_VR_Engineering/README.md">07_VR_Engineering (90 Hz VR &amp; @rig)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../07_VR_Engineering/01_vr-architektur-frametimes-und-diagnose.md">01 • VR-Architektur, Frametimes &amp; Compositor</a> <a class="doku-arch-badge" href="../../labs/07_vr_engineering/analyze_vr_compositor.py">analyze_vr_compositor.py</a></li>
<li>└─ <a href="../../labs/07_vr_engineering/README.md">Lab 07 • VR-Invarianten &amp; Read-Only Check</a> <a class="doku-arch-badge" href="../../labs/07_vr_engineering/Check-VrInvariants.ps1">Check-VrInvariants.ps1</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
