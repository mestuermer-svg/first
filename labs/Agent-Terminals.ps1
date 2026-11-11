<#
.SYNOPSIS
    Agent-Terminals.ps1 - Zentraler SSH- & Lokal-Terminal-Launcher im Git-Labor (VanstrikeCyborg).
.DESCRIPTION
    Zeigt den Erreichbarkeitsstatus aller 6 Agenten im SimRig-Verbund und startet
    entweder das lokale General-Agent-Terminal auf VanstrikeCyborg oder sichere
    SSH-Client-Terminals zu SimRacer (@rig, @light), Sandbox (@dark), Archibald (@sarah)
    und StrikerPi (@rick) — ohne die lokal auf den Hosts laufenden Terminals zu beenden.
.EXAMPLE
    .\Agent-Terminals.ps1
.EXAMPLE
    .\Agent-Terminals.ps1 -StatusOnly
.EXAMPLE
    .\Agent-Terminals.ps1 -Agent rick -InCurrentWindow
.EXAMPLE
    .\Agent-Terminals.ps1 -Agent all
#>

[CmdletBinding()]
param(
    [ValidateSet("menu", "general", "rig", "light", "dark", "sarah", "rick", "all")]
    [string]$Agent = "menu",

    [switch]$InCurrentWindow,
    [switch]$StatusOnly
)

$GitLaborRoot = Split-Path -Parent $PSScriptRoot
$AcSandboxRoot = Join-Path (Split-Path -Parent $GitLaborRoot) "assetto-corsa-content\ac-sandbox"
$SharedAgentsRoot = Join-Path $AcSandboxRoot "shared\agents"
$SharedScriptsRoot = Join-Path $AcSandboxRoot "shared\scripts"

function Test-TcpPortFast {
    param([string]$TargetHost, [int]$Port, [int]$TimeoutMs = 500)
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $tcp.BeginConnect($TargetHost, $Port, $null, $null)
        return ($async.AsyncWaitHandle.WaitOne($TimeoutMs, $false) -and $tcp.Connected)
    } catch {
        return $false
    } finally {
        $tcp.Close()
    }
}

$AgentCatalog = @(
    [ordered]@{
        Key         = "1"
        Id          = "general"
        Name        = "@general"
        HostName    = "VanstrikeCyborg (Lokal)"
        HostIp      = "127.0.0.1"
        Port        = 8317
        Mode        = "LOKAL (Master)"
        Script      = Join-Path $SharedAgentsRoot "general\start_general_terminal.ps1"
        Description = "Workspace-, Git-Labor- & Multi-Agent-Orchestrator"
    },
    [ordered]@{
        Key         = "2"
        Id          = "rig"
        Name        = "@rig"
        HostName    = "SimRacer Host"
        HostIp      = "192.168.178.68"
        Port        = 22
        Mode        = "SSH -ClientMode"
        Script      = Join-Path $SharedScriptsRoot "connect_rig_terminal.ps1"
        Description = "Hardware, SteamVR, Fanatec, AC & 50Hz-Telemetry"
    },
    [ordered]@{
        Key         = "3"
        Id          = "light"
        Name        = "@light"
        HostName    = "SimRacer Host"
        HostIp      = "192.168.178.68"
        Port        = 22
        Mode        = "SSH -ClientMode"
        Script      = Join-Path $SharedScriptsRoot "connect_light_terminal.ps1"
        Description = "Docker-Engine, Container & Sandbox-Lifecycle"
    },
    [ordered]@{
        Key         = "4"
        Id          = "dark"
        Name        = "@dark"
        HostName    = "ac-win11-sandbox"
        HostIp      = "192.168.178.68"
        Port        = 2222
        Mode        = "SSH -ClientMode"
        Script      = Join-Path $SharedScriptsRoot "connect_dark_terminal.ps1"
        Description = "In-Guest Windows 11, CM/CSP & Setup-Validierung"
    },
    [ordered]@{
        Key         = "5"
        Id          = "sarah"
        Name        = "@sarah"
        HostName    = "Archibald (Pitwall)"
        HostIp      = "192.168.178.98"
        Port        = 22
        Mode        = "SSH (Bash)"
        Script      = Join-Path $SharedScriptsRoot "connect_sarah_terminal.ps1"
        Description = "Pitwall Kiosk, Live-Coaching & Replay-Schnitt"
    },
    [ordered]@{
        Key         = "6"
        Id          = "rick"
        Name        = "@rick"
        HostName    = "StrikerPi (24/7 Hub)"
        HostIp      = "192.168.178.86"
        Port        = 22
        Mode        = "SSH (Bash)"
        Script      = Join-Path $SharedScriptsRoot "connect_rick_terminal.ps1"
        Description = "Telemetry-Relay (:8080), MQTT (:1883) & Bare-Git"
    }
)

function Show-AgentMatrix {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  GIT-LABOR // ZENTRALER AGENTEN-TERMINAL-LAUNCHER (VanstrikeCyborg -> SSH)" -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ("  {0,-3} {1,-9} {2,-22} {3,-16} {4,-9} {5}" -f "#", "Agent", "Ziel-Host", "Verbindung", "Status", "Aufgabe") -ForegroundColor DarkCyan
    Write-Host ("  " + ("-" * 76)) -ForegroundColor DarkGray

    foreach ($ag in $AgentCatalog) {
        $online = Test-TcpPortFast -TargetHost $ag.HostIp -Port $ag.Port -TimeoutMs 450
        $stText = if ($online) { "ONLINE" } elseif ($ag.Id -eq "general") { "BEREIT" } else { "OFFLINE" }
        $color  = if ($online) { "Green" } elseif ($ag.Id -eq "general") { "Cyan" } else { "DarkYellow" }
        $hostCol = "$($ag.HostName)"
        Write-Host ("  [{0}] {1,-9} {2,-22} {3,-16} {4,-9} {5}" -f $ag.Key, $ag.Name, $hostCol, $ag.Mode, $stText, $ag.Description) -ForegroundColor $color
    }
    Write-Host ("  " + ("-" * 76)) -ForegroundColor DarkGray
    Write-Host "  Hinweis: Hostsysteme starten ihre Terminals lokal; SSH nutzt Client-Mode." -ForegroundColor Gray
    Write-Host ""
}

function Start-AgentEntry {
    param([hashtable]$Entry, [switch]$CurrentWindow)

    if (-not (Test-Path $Entry.Script)) {
        Write-Warning "Skript nicht gefunden: $($Entry.Script)"
        return
    }

    if ($CurrentWindow) {
        Write-Host ">>> Starte $($Entry.Name) im aktuellen Terminal ($($Entry.Mode))..." -ForegroundColor Cyan
        & $Entry.Script
    } else {
        Write-Host ">>> Oeffne separates Terminal-Fenster fuer $($Entry.Name) ($($Entry.Mode))..." -ForegroundColor Green
        Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$($Entry.Script)`""
    }
}

if ($StatusOnly) {
    Show-AgentMatrix
    return
}

if ($Agent -eq "all") {
    Show-AgentMatrix
    foreach ($ag in $AgentCatalog) {
        Start-AgentEntry -Entry $ag
        Start-Sleep -Milliseconds 250
    }
    Write-Host "[+] Alle 6 Agenten-Terminals gestartet." -ForegroundColor Green
    return
}

if ($Agent -ne "menu") {
    $match = $AgentCatalog | Where-Object { $_.Id -eq $Agent } | Select-Object -First 1
    if ($match) {
        Start-AgentEntry -Entry $match -CurrentWindow:$InCurrentWindow
    }
    return
}

while ($true) {
    Show-AgentMatrix
    Write-Host "  [1-6] Einzelnes Terminal im aktuellen Fenster oeffnen" -ForegroundColor White
    Write-Host "  [W1-W6] Einzelnes Terminal in neuem PowerShell-Fenster oeffnen" -ForegroundColor White
    Write-Host "  [A]   Alle 6 Terminals parallel in separaten Fenstern starten" -ForegroundColor Yellow
    Write-Host "  [R]   Status aktualisieren   |   [Q] Beenden" -ForegroundColor Gray
    Write-Host ""
    $choice = (Read-Host "Auswahl").Trim().ToLower()

    if ($choice -eq "q" -or $choice -eq "exit") { break }
    if ($choice -eq "r" -or $choice -eq "") { continue }
    if ($choice -eq "a" -or $choice -eq "all") {
        foreach ($ag in $AgentCatalog) {
            Start-AgentEntry -Entry $ag
            Start-Sleep -Milliseconds 250
        }
        continue
    }

    if ($choice -match "^w([1-6])$") {
        $k = $Matches[1]
        $entry = $AgentCatalog | Where-Object { $_.Key -eq $k } | Select-Object -First 1
        if ($entry) { Start-AgentEntry -Entry $entry }
        continue
    }

    $entry = $AgentCatalog | Where-Object { $_.Key -eq $choice -or $_.Id -eq $choice } | Select-Object -First 1
    if ($entry) {
        Start-AgentEntry -Entry $entry -CurrentWindow
    } else {
        Write-Warning "Ungueltige Auswahl: '$choice'"
        Start-Sleep -Seconds 1
    }
}
