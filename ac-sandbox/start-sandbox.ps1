# Automatischer Start-Service für den VS Code Workspace "git-labor"
# Startet:
# 1. Antigravity Proxy (CLIProxyAPI auf Port 8317)
# 2. Docker Desktop Engine (falls noch nicht aktiv)
# 3. Windows 11 Assetto-Corsa Sandbox-Container (dockurr/windows auf Port 8006)

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

Write-Host "[1/3] Prüfe Antigravity CLIProxyAPI (Port 8317)..." -ForegroundColor Cyan
$proxyListening = Get-NetTCPConnection -LocalPort 8317 -State Listen -ErrorAction SilentlyContinue
if (-not $proxyListening) {
    $proxyExe = "C:\Users\strik\CLIProxyAPI\cli-proxy-api.exe"
    $proxyCfg = "C:\Users\strik\CLIProxyAPI\config.yaml"
    if (Test-Path $proxyExe) {
        Write-Host "      Starte CLIProxyAPI im Hintergrund..." -ForegroundColor Yellow
        Start-Process -FilePath $proxyExe -ArgumentList "--config `"$proxyCfg`"" -WorkingDirectory "C:\Users\strik\CLIProxyAPI" -WindowStyle Hidden
    }
} else {
    Write-Host "      CLIProxyAPI läuft bereits auf 127.0.0.1:8317." -ForegroundColor Green
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
    } else {
        Write-Host "      WARNUNG: Docker Desktop wurde nicht gefunden." -ForegroundColor Red
    }
}

Write-Host "[3/3] Starte Windows 11 Sandbox-Container (ac-win11-sandbox)..." -ForegroundColor Cyan
if ($dockerReady) {
    Push-Location $SandboxDir
    docker compose up -d
    Pop-Location
    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Green
    Write-Host " Sandbox aktiv!" -ForegroundColor Green
    Write-Host " -> Web-Ansicht (auch für Chrome DevTools MCP): http://127.0.0.1:8006" -ForegroundColor Cyan
    Write-Host " -> RDP-Zugang (Windows Remotedesktop):         127.0.0.1:3389" -ForegroundColor Cyan
    Write-Host " -> Gemeinsamer Ordner (Host <-> Win11):        $SharedDir" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Green
}
