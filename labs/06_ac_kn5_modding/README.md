# Lab 06 – Assetto Corsa `.kn5` Modding & Asset-Inspektion

Dieses Labor ergänzt die Dokumentation unter [`Doku/06_AC_KN5_Modding/`](../../Doku/06_AC_KN5_Modding/README.md) mit praxisfertigen Werkzeugen für die Analyse, Reparatur und non-destruktive Erweiterung von `.kn5`-Fahrzeugmodellen.

## Enthaltene Dateien

| Datei | Zweck |
|---|---|
| [`inspect_kn5.py`](./inspect_kn5.py) | Binärer `.kn5`-Inspektor (Header, Texturen, Materialien, Shader) und Ordner-Integritätsprüfer (`--check-car-dir`) |
| [`templates/ext_config_template.ini`](./templates/ext_config_template.ini) | Kommentarvorlage für non-destruktive CSP-Material- und Licht-Anpassungen (`extension/ext_config.ini`) |

## Schnellstart (Read-Only gegen SimRacer-Host)

Interpreter im Workspace: `uv` Python 3.12 (`python.exe`). Es werden keine Drittanbieter-Pakete benötigt.

```powershell
$py = "C:\Users\strik\AppData\Roaming\uv\python\cpython-3.12-windows-x86_64-none\python.exe"
$rb21Dir = "\\192.168.178.68\C$\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\cars\gp_2025_rb21"

# 1. Fahrzeugordner vollständig prüfen (collider, .kn5 Magic-Bytes, ui_car.json)
& $py .\inspect_kn5.py --check-car-dir $rb21Dir

# 2. Binärstruktur des Hauptmodells inspizieren (Texturen & Shader)
& $py .\inspect_kn5.py --file "$rb21Dir\gp_2025_rb21.kn5" --top 12

# 3. Maschinenlesbare JSON-Ausgabe für Automatisierung
& $py .\inspect_kn5.py --check-car-dir $rb21Dir --json
```
