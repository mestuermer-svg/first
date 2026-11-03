# Automatischer Start-Service für den VS Code Workspace "git-labor"
# Startet:
# 1. Antigravity Proxy (CLIProxyAPI auf Port 8317)
# 2. Docker Desktop Engine (falls noch nicht aktiv)
# 3. Windows 11 Assetto-Corsa Sandbox-Container (dockurr/windows auf Port 8006)

param(
    [switch]$NoDocker
)

$ErrorActionPreference = "Continue"
$SandboxDir = $PSScriptRoot
$SharedDir  = Join-Path $SandboxDir "shared"

# Gemeinsame Austausch-Ordner für den Agenten und das Gast-Windows anlegen
foreach ($sub in @("apps_python", "cfg_content_manager", "scripts", "telemetry")) {
    $p = Join-Path $SharedDir $sub
    if (-not (Test-Path $p)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
}

# -----------------------------------------------------------------------------
# 1. Antigravity CLIProxyAPI (Port 8317)
# -----------------------------------------------------------------------------
Write-Host "[1/3] Prüfe Antigravity CLIProxyAPI (Port 8317)..." -ForegroundColor Cyan

function Test-ProxyApi {
    try {
        $resp = Invoke-RestMethod -Uri "http://127.0.0.1:8317/v1/models" -TimeoutSec 2 -ErrorAction Stop
        return ($null -ne $resp)
    } catch {
        return $false
    }
}

$proxyOk = Test-ProxyApi
if ($proxyOk) {
    Write-Host "      CLIProxyAPI läuft und antwortet auf 127.0.0.1:8317." -ForegroundColor Green
} else {
    Write-Host "      CLIProxyAPI läuft noch nicht (Start wird durch die VS Code Extension 'Antigravity for Copilot' gesteuert)." -ForegroundColor Yellow
}

# -----------------------------------------------------------------------------
# 2. Docker Desktop & Engine
# -----------------------------------------------------------------------------
if ($NoDocker) {
    Write-Host "[2/3] Docker-Start übersprungen (-NoDocker gesetzt)." -ForegroundColor Yellow
    Write-Host "[3/3] Sandbox-Container übersprungen." -ForegroundColor Yellow
    return
}

Write-Host "[2/3] Prüfe Docker Engine..." -ForegroundColor Cyan
$dockerReady = $false
docker info *> $null
if ($LASTEXITCODE -eq 0) {
    $dockerReady = $true
    Write-Host "      Docker Engine läuft bereits." -ForegroundColor Green
} else {
    $dockerDesktopExe = "C:\Users\strik\AppData\Local\Programs\DockerDesktop\Docker Desktop.exe"
    if (-not (Test-Path $dockerDesktopExe)) {
        $dockerDesktopExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    }

    if (Test-Path $dockerDesktopExe) {
        Write-Host "      Starte Docker Desktop und warte auf Engine..." -ForegroundColor Yellow
        Start-Process -FilePath $dockerDesktopExe
        for ($i = 0; $i -lt 45; $i++) {
            Start-Sleep -Seconds 2
            docker info *> $null
            if ($LASTEXITCODE -eq 0) {
                $dockerReady = $true
                Write-Host "      Docker Engine ist bereit!" -ForegroundColor Green
                break
            }
        }
        if (-not $dockerReady) {
            Write-Host "      WARNUNG: Docker Engine reagiert nach 90s noch nicht." -ForegroundColor Red
        }
    } else {
        Write-Host "      WARNUNG: Docker Desktop wurde nicht gefunden." -ForegroundColor Red
    }
}

# -----------------------------------------------------------------------------
# 3. Windows 11 Sandbox-Container (ac-win11-sandbox)
# -----------------------------------------------------------------------------
Write-Host "[3/3] Prüfe Windows 11 Sandbox-Container (ac-win11-sandbox)..." -ForegroundColor Cyan
if ($dockerReady) {
    $running = docker ps --filter "name=ac-win11-sandbox" --filter "status=running" -q
    if (-not $running) {
        Write-Host "      Starte Container ac-win11-sandbox..." -ForegroundColor Yellow
        Push-Location $SandboxDir
        docker compose up -d
        Pop-Location
    } else {
        Write-Host "      Container ac-win11-sandbox läuft bereits." -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Green
    Write-Host " Sandbox & Antigravity aktiv!" -ForegroundColor Green
    Write-Host " -> Antigravity Proxy:                         http://127.0.0.1:8317" -ForegroundColor Cyan
    Write-Host " -> Web-Ansicht (auch für Chrome DevTools MCP): http://127.0.0.1:8006" -ForegroundColor Cyan
    Write-Host " -> RDP-Zugang (Windows Remotedesktop):         127.0.0.1:3389" -ForegroundColor Cyan
    Write-Host " -> Gemeinsamer Ordner (Host <-> Win11):        $SharedDir" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Green
}
