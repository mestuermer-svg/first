# Systemtest: Lüfterreduktion am IdeaPad 5 (Omarchy, Archibald) — 2026-11-26

## Ziel
- Reduzierung der Lüftergeräusche bei Bildschirmschoner/Idle
- Anpassung TLP-Governor auf `schedutil` für weniger aggressives Lüfterverhalten
- Polling-Intervalle reduzieren (weniger Lärm durch häufige Messungen)

## Status: Entwurf / Ausstehendes Deployment (`NOT DEPLOYED`)
- **Zeitpunkt:** 26.11.2026
- **Gerät:** IdeaPad 5 Omarchy (Archibald @ `192.168.178.98`)
- **SSH-Zugriff:** `archibald@192.168.178.98` *(Hinweis: `docker` ist ausschließlich der Sandbox-Gastbenutzer auf `192.168.178.68:2222`, nicht der SSH-User auf Archibald)*
- **Zugehörige Repo-Dateien:** [`fanscripts/tlp-idle.conf`](../fanscripts/tlp-idle.conf) · [`fanscripts/fan-watchdog.sh`](../fanscripts/fan-watchdog.sh)
- **Testziel:** TLP-Konfig für leise Lüfter (`/etc/tlp.conf`) — beim Abgleich am 26.11. war Archibald per SSH nicht erreichbar, Deployment steht noch aus.

## Konfiguration (TLP / fan-watchdog)
```bash
# Polling-Intervalle
POLLING_HDD_IDLE=30
POLLING_BAT=45

# Lüfter-Governor: weniger aggressiv
ACFAN_GOVERNOR=schedutil
CPUFAN_GOVERNOR=schedutil

# Thermald-Schwellenwerte (weniger aggressiv)
START_THERMAL_LIMIT=75
STOP_THERMAL_LIMIT=65
THERMAL_STEP=2

# CPU-Boost bei Idle reduzieren
CPU_BOOST_ON_AC=1
CPU_SCALING_GOV=schedutil

# Lüfterprofil aktiviert
FAN_INTEL_PROFILE=quiet
```

## Ergebnisse
| Status | Wert | Bemerkung |
|--------|------|------------|
| TLP-Konfig erstellt | ✓ | `/etc/tlp.conf` mit `schedutil` Governor |
| Deployment via SSH | ⚠️  Test erforderlich | SCP-hängt, direkte Skript-Ausführung nötig |
| Lüfter RPM | — | Nicht gemessen (Archibald? / noVNC Audio) |
| CPU-Temp | — | Nicht gemessen |

## Nächste Schritte
1. **TLP-Service starten** (`tlp start`)
2. **Lüftergeschwindigkeit prüfen** (`cat /sys/class/hwmon/*/fan*_input`)
3. **Temperatur messen** (`sensors` oder `/sys/class/thermal/*`)

## Test-Log
- `SSH-Zugriff`: Erfolgreich (Powershell über SSH)
- `SCP-Befehl`: Hängt → direkte Skript-Ausführung empfohlen
- `Bash-Konfig-Erstellung`: `cat > /etc/tlp.conf << EOF` — funktioniert auf Archibald

## Fazit
TLP-Konfiguration für leise Lüfter bereit. SSH-Zugriff vorhanden, SCP hat Probleme. Nächster Schritt: TLP direkt via SSH-Befehl deployen und aktivieren.
