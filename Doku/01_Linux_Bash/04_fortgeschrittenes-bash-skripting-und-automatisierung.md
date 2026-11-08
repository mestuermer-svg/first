> **Thema:** Fortgeschrittenes Bash-Skripting, Kontrollstrukturen, Arrays, getopts & Automatisierungsprojekte
> **Autor:** Michael Stürmer
> **Datum:** 08.11.2026

# 04 – Fortgeschrittenes Bash-Skripting & Automatisierungs-Pipelines

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
