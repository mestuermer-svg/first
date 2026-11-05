# Automatischer Start-Service für den VS Code Workspace "git-labor"
# Zuständiger Agent in der Docker-Sandbox-Instanz: Light Agent
# Startet / verbindet:
# 1. Antigravity Proxy (CLIProxyAPI auf Port 8317)
# 2. Remote-Verbindung zur SimRacer Docker-Sandbox (192.168.178.68) ODER lokale Docker Engine
# 3. Windows 11 Assetto-Corsa Sandbox-Container (dockurr/windows auf Port 8006 - Light Agent)

param(
    [switch]$NoDocker,
    [switch]$LocalDocker,
    [string]$RemoteHost = "192.168.178.68"
)

$ErrorActionPreference = "Continue"
$SandboxDir = $PSScriptRoot
$SharedDir  = Join-Path $SandboxDir "shared"

# Falls das Skript direkt auf dem SimRacer ausgeführt wird oder -LocalDocker aktiv ist, lokal starten
if ($LocalDocker -or $env:COMPUTERNAME -match "SIMRACER") {
    $RemoteHost = ""
}

function Test-TcpPortFast {
    param([string]$TargetHost, [int]$Port, [int]$TimeoutMs = 1500)
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $tcp.BeginConnect($TargetHost, $Port, $null, $null)
        $connected = $async.AsyncWaitHandle.WaitOne($TimeoutMs, $false) -and $tcp.Connected
        return $connected
    } catch {
        return $false
    } finally {
        $tcp.Close()
    }
}

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
# 1b. Remote-Modus: Sandbox läuft auf dem SimRacer (Light Agent aktiv)
# -----------------------------------------------------------------------------
if (-not [string]::IsNullOrWhiteSpace($RemoteHost)) {
    Write-Host "[2/3] Remote-Modus aktiv: Prüfe Docker-Sandbox-Instanz (Light Agent) auf SimRacer ($RemoteHost)..." -ForegroundColor Cyan
    docker context inspect simracer *> $null
    if ($LASTEXITCODE -ne 0) {
        docker context create simracer --description "SimRacer Docker Engine ($RemoteHost)" --docker "host=ssh://Mike@$RemoteHost" *> $null
    }
    docker context use simracer *> $null

    $vncOk = Test-TcpPortFast -TargetHost $RemoteHost -Port 8006
    $rdpOk = Test-TcpPortFast -TargetHost $RemoteHost -Port 3390
    $sshOk = Test-TcpPortFast -TargetHost $RemoteHost -Port 2222
    $smbOk = Test-Path "\\$RemoteHost\ac-sandbox\shared"

    if (-not ($vncOk -or $rdpOk)) {
        Write-Host "      Remote-Sandbox auf '$RemoteHost' antwortet noch nicht – prüfe Docker Engine & Container via SSH..." -ForegroundColor Yellow
        try {
            $remoteStart = @'
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Start-Service com.docker.service -ErrorAction SilentlyContinue
    $ddExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $ddExe) {
        $action = New-ScheduledTaskAction -Execute $ddExe
        $principal = New-ScheduledTaskPrincipal -UserId "Mike" -LogonType Interactive -RunLevel Highest
        Register-ScheduledTask -TaskName "StartDockerDesktopInteractive" -Action $action -Principal $principal -Force | Out-Null
        Start-ScheduledTask -TaskName "StartDockerDesktopInteractive"
        for ($i = 0; $i -lt 45; $i++) {
            Start-Sleep -Seconds 2
            docker info *> $null
            if ($LASTEXITCODE -eq 0) { break }
        }
    }
}
docker info *> $null
if ($LASTEXITCODE -eq 0) {
    wsl -d docker-desktop -u root -e /sbin/modprobe kvm_amd *> $null
    wsl -d docker-desktop -u root -e /bin/chmod 666 /dev/kvm *> $null
    Set-Location "C:\ac-sandbox"
    docker compose up -d
}
'@
            $b64Start = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($remoteStart))
            ssh -o ConnectTimeout=5 "Mike@$RemoteHost" "powershell -NoProfile -EncodedCommand $b64Start" *> $null
            for ($w = 0; $w -lt 20; $w++) {
                Start-Sleep -Seconds 2
                $vncOk = Test-TcpPortFast -TargetHost $RemoteHost -Port 8006
                $rdpOk = Test-TcpPortFast -TargetHost $RemoteHost -Port 3390
                $sshOk = Test-TcpPortFast -TargetHost $RemoteHost -Port 2222
                if ($vncOk -or $rdpOk) { break }
            }
        } catch {
            # Fallback auf manuellen Hinweis
        }
    }

    if ($vncOk -or $rdpOk) {
        Write-Host "[3/3] Docker-Sandbox-Instanz (Light Agent) auf '$RemoteHost' ist IN BETRIEB!" -ForegroundColor Green
        Write-Host ""
        Write-Host "=================================================================" -ForegroundColor Green
        Write-Host " Docker-Sandbox (SimRacer) & Light Agent aktiv in Betrieb!" -ForegroundColor Green
        Write-Host " -> Zuständiger Sandbox-Agent:                  Light Agent" -ForegroundColor Magenta
        Write-Host " -> Antigravity Proxy (lokal):                  http://127.0.0.1:8317" -ForegroundColor Cyan
        Write-Host " -> Web-Ansicht (auch für Chrome DevTools MCP): http://${RemoteHost}:8006 (Online: $vncOk)" -ForegroundColor Cyan
        Write-Host " -> RDP-Zugang Sandbox (Windows Remotedesktop): ${RemoteHost}:3390 (Online: $rdpOk)" -ForegroundColor Cyan
        Write-Host " -> SSH-Zugang (OpenSSH Bridge):                ssh -p 2222 Docker@${RemoteHost} (Online: $sshOk)" -ForegroundColor Cyan
        Write-Host " -> Remote-Shared-Ordner (SMB):                 \\${RemoteHost}\ac-sandbox\shared (Verbunden: $smbOk)" -ForegroundColor Cyan
        Write-Host "=================================================================" -ForegroundColor Green
    } else {
        Write-Host "[3/3] WARNUNG: Remote-Sandbox auf '$RemoteHost' (Port 8006/3390) antwortet noch nicht." -ForegroundColor Yellow
        Write-Host "      Bitte prüfen Sie auf dem SimRacer in C:\ac-sandbox: 'docker compose up -d'" -ForegroundColor Yellow
    }
    return
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
    Write-Host " -> RDP-Zugang (Windows Remotedesktop):         127.0.0.1:3390" -ForegroundColor Cyan
    Write-Host " -> SSH-Zugang (OpenSSH Bridge):                127.0.0.1:2222" -ForegroundColor Cyan
    Write-Host " -> Gemeinsamer Ordner (Host <-> Win11):        $SharedDir" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Green
}
