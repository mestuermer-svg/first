#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Lern- & Testskript (Rubrik 01: Linux & Bash)
# Prüft die wichtigsten Werkzeuge und Umgebungsvariablen im git-labor
# ==============================================================================

echo "=== [Git-Labor] Linux / Bash Umgebungs-Check ==="
echo "Zeitpunkt : $(date)"
echo "Verzeichnis: $(pwd)"
echo "------------------------------------------------"

for tool in git python3 node uv sbx; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[OK]    $tool gefunden: $(command -v "$tool")"
    else
        echo "[INFO]  $tool ist in dieser Shell nicht im PATH"
    fi
done

if [ -n "${GEMINI_API_KEY:-}" ]; then
    echo "[OK]    GEMINI_API_KEY ist in der Umgebung gesetzt (Wert verborgen)."
else
    echo "[WARN]  GEMINI_API_KEY ist aktuell nicht gesetzt."
fi
