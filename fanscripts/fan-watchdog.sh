#!/bin/bash
# fan-watchdog — Warnmeldung nach 5 Minuten Inaktivität

START=$(date +%s)
WARN_INTERVAL=300   # 5 Min in Sekunden
SLEEP_INTERVAL=10   # alle 10s prüfen

while true; do
    if [ $(($(date +%s) - START)) -gt $WARN_INTERVAL ]; then
        echo "⚠️  Keine Agenten-Antwort seit 5 Minuten!"
        
        # Lüfter-RPM auslesen
        for h in /sys/class/hwmon/*/; do
            for f in "$h"fan*_input; do
                if [ -f "$f" ]; then
                    rpm=$(cat "$f" | tr -d '\n')
                    echo "   Lüfter: ${rpm:-0} RPM"
                fi
            done
        done 2>/dev/null || echo "   Lüfter-Daten nicht verfügbar (Archibald?)"
        
        # CPU-Temperatur
        for tz in /sys/class/thermal/thermal_zone*; do
            type=$(cat "$tz/type" 2>/dev/null)
            raw=$(cat "$tz/temp*_input" 2>/dev/null | tr -d '\n')
            [ -n "$raw" ] && temp=$((raw/1000)) && echo "   $type: ${temp:-0}°C" || true
        done 2>/dev/null
        
        START=$(($(date +%s) + WARN_INTERVAL)) # Reset-Countdown
    fi
    sleep $SLEEP_INTERVAL
done
