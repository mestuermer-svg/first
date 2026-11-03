<#
.SYNOPSIS
    Überträgt die 64-GB Docker-Sandbox (ac-sandbox inkl. storage/data.img und shared)
    vom VanstrikeCyborg (Laptop) über das lokale Netzwerk (oder ein Ziellaufwerk) auf den SimRacer.

.DESCRIPTION
    1. Prüft und stoppt ggf. den laufenden Container 'ac-win11-sandbox', damit data.img konsistent ist.
    2. Nutzt 'robocopy /J /Z /MT:8' (Unbuffered I/O + Restartable Mode) für maximalen Durchsatz bei der 64-GB-Imagedatei.
    3. Kopiert automatisch die hochskalierte 'docker-compose.simracer.yml' als aktive 'docker-compose.yml' ins Zielverzeichnis.

.PARAMETER TargetPath
    Netzwerkpfad (SMB-Share) oder Laufwerkspfad zum Zielordner auf dem SimRacer.
    Standard: "\\SimRacer\ac-sandbox" (empfohlene Freigabe für D:\ac-sandbox auf der 1.8 TB NVMe-SSD).

.EXAMPLE
    .\migrate-sandbox-to-simracer.ps1 -TargetPath "\\SimRacer\ac-sandbox"
    .\migrate-sandbox-to-simracer.ps1 -TargetPath "\\192.168.178.50\ac-sandbox"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$TargetPath = "\\SimRacer\ac-sandbox",

    [switch]$ActivateSimRacerCompose = $true
)

$ErrorActionPreference = "Continue"

# Quellverzeichnis bestimmen (2 Ebenen über shared/scripts -> ac-sandbox)
$ScriptDir  = $PSScriptRoot
$SandboxDir = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
$DataImg    = Join-Path $SandboxDir "storage\data.img"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " AC-Sandbox Migration: VanstrikeCyborg -> SimRacer" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Quellordner : $SandboxDir"
Write-Host " Zielordner  : $TargetPath"
Write-Host ""

if (-not (Test-Path $SandboxDir)) {
    Write-Error "Quellordner $SandboxDir wurde nicht gefunden!"
    exit 1
}

if (Test-Path $DataImg) {
    $sizeGB = [math]::Round((Get-Item $DataImg).Length / 1GB, 2)
    Write-Host "[1/4] Gefundenes Sandbox-Image: data.img ($sizeGB GB)" -ForegroundColor Green
} else {
    Write-Host "[1/4] WARNUNG: storage\data.img wurde unter $SandboxDir nicht gefunden." -ForegroundColor Yellow
}

# 1. Laufenden Container stoppen, damit data.img nicht während des Schreibens kopiert wird
Write-Host "[2/4] Prüfe, ob Container 'ac-win11-sandbox' lokal noch läuft..." -ForegroundColor Cyan
docker info *> $null
if ($LASTEXITCODE -eq 0) {
    $running = docker ps --filter "name=ac-win11-sandbox" --filter "status=running" -q
    if ($running) {
        Write-Host "      Stoppe laufenden Container 'ac-win11-sandbox' sauber (max. 120s)..." -ForegroundColor Yellow
        Push-Location $SandboxDir
        docker compose stop
        Pop-Location
        Write-Host "      Container erfolgreich gestoppt." -ForegroundColor Green
    } else {
        Write-Host "      Container ist bereits gestoppt." -ForegroundColor Green
    }
} else {
    Write-Host "      Lokale Docker Engine ist nicht aktiv (Image-Datei ist nicht gesperrt)." -ForegroundColor Green
}

# 2. Zielpfad prüfen / anlegen
Write-Host "[3/4] Prüfe Erreichbarkeit des Zielpfads '$TargetPath'..." -ForegroundColor Cyan
if (-not (Test-Path $TargetPath)) {
    try {
        New-Item -ItemType Directory -Path $TargetPath -Force -ErrorAction Stop | Out-Null
        Write-Host "      Zielordner '$TargetPath' wurde erstellt." -ForegroundColor Green
    } catch {
        Write-Host "      FEHLER: Zielpfad '$TargetPath' ist nicht erreichbar!" -ForegroundColor Red
        Write-Host "      Tipp: Führen Sie auf dem SimRacer in einer Admin-PowerShell zuerst aus:" -ForegroundColor Yellow
        Write-Host '            New-Item -ItemType Directory -Path "C:\ac-sandbox" -Force' -ForegroundColor White
        Write-Host '            New-SmbShare -Name "ac-sandbox" -Path "C:\ac-sandbox" -FullAccess "Jeder"' -ForegroundColor White
        exit 1
    }
} else {
    Write-Host "      Zielpfad '$TargetPath' ist erreichbar." -ForegroundColor Green
}

# 3. High-Speed Robocopy Transfer (/J = Unbuffered I/O für große VM-Images, /Z = Restartable)
Write-Host "[4/4] Starte High-Speed-Transfer (robocopy /E /J /Z /MT:8)..." -ForegroundColor Cyan
$roboArgs = @(
    $SandboxDir,
    $TargetPath,
    "/E",
    "/J",
    "/Z",
    "/MT:8",
    "/R:3",
    "/W:5",
    "/NP",
    "/ETA"
)

& robocopy @roboArgs
$roboExit = $LASTEXITCODE

# Robocopy Exit-Codes 0 bis 7 bedeuten Erfolg
if ($roboExit -ge 8) {
    Write-Host "FEHLER: Robocopy meldete Fehlercode $roboExit." -ForegroundColor Red
    exit $roboExit
}

# 4. Auf Wunsch direkt die hochskalierte SimRacer-Compose-Datei im Ziel als docker-compose.yml aktivieren
if ($ActivateSimRacerCompose) {
    $simCompose = Join-Path $TargetPath "docker-compose.simracer.yml"
    $dstCompose = Join-Path $TargetPath "docker-compose.yml"
    if (Test-Path $simCompose) {
        Copy-Item -Path $simCompose -Destination $dstCompose -Force
        Write-Host "      SimRacer-Konfiguration (12G RAM, 8 CPU, 160G Disk, LAN-Ports) als Ziel-docker-compose.yml aktiviert!" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host " Transfer erfolgreich abgeschlossen!" -ForegroundColor Green
Write-Host " Nächste Schritte auf dem SimRacer (in C:\ac-sandbox):" -ForegroundColor Cyan
Write-Host "   1. cd C:\ac-sandbox" -ForegroundColor White
Write-Host "   2. docker compose up -d" -ForegroundColor White
Write-Host "   3. Im Windows-11-Gast einmalig Shared\scripts\expand-guest-disk.ps1" -ForegroundColor White
Write-Host "      ausführen, um Laufwerk C: auf die vollen 160 GB zu erweitern." -ForegroundColor White
Write-Host "=================================================================" -ForegroundColor Green
