# Initialisierungs-Skript für die Windows 11 Sandbox (innerhalb des Containers ausführen)
# Installiert automatisch Steam, Python und 7-Zip via winget und verknüpft den Shared-Ordner.

Write-Host "Installiere Steam und Python in der Sandbox..." -ForegroundColor Cyan
winget install -e --id Valve.Steam --accept-package-agreements --accept-source-agreements
winget install -e --id Python.Python.3.11 --accept-package-agreements --accept-source-agreements

$acCfgDir = "$env:USERPROFILE\Documents\Assetto Corsa\cfg"
$cmDir    = "$env:LOCALAPPDATA\AcTools Content Manager"
New-Item -ItemType Directory -Path $acCfgDir -Force | Out-Null
New-Item -ItemType Directory -Path $cmDir -Force | Out-Null

Write-Host "Erstelle Verknüpfung zum Agent-Shared-Ordner (\\host.lan\Data)..." -ForegroundColor Green
