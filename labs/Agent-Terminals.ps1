<#
.SYNOPSIS
    Agent-Terminals.ps1 - Zentraler SSH- & Lokal-Terminal-Launcher im Git-Labor (VanstrikeCyborg).
.DESCRIPTION
    Zeigt kanonische Agenten-IDs aus der StrikerPi-Registry und startet General Cyborg
    lokal, General Sim auf StrikerPi oder die Remote-Terminals der Worker-Agenten.
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
    [ValidateSet("menu", "general", "cyborg", "general-sim", "rig", "light", "dark", "sarah", "rick", "all")]
    [string]$Agent = "menu",

    [switch]$InCurrentWindow,
    [switch]$StatusOnly
)

$GitLaborRoot = Split-Path -Parent $PSScriptRoot
$AcSandboxRoot = Join-Path (Split-Path -Parent $GitLaborRoot) "assetto-corsa-content\ac-sandbox"
$SharedScriptsRoot = Join-Path $AcSandboxRoot "shared\scripts"
$RegistryPath = Join-Path (Split-Path -Parent $GitLaborRoot) "strikerpi-hub\telemetry-relay\agent_registry.json"

if (-not (Test-Path -LiteralPath $RegistryPath -PathType Leaf)) {
    throw "Kanonische Agenten-Registry nicht gefunden: $RegistryPath"
}

$AgentRegistry = Get-Content -LiteralPath $RegistryPath -Raw -Encoding UTF8 | ConvertFrom-Json
$AgentAliases = $AgentRegistry.aliases

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

$AgentCatalog = @()

function Get-AgentLaunchDefinition {
    param([string]$Id)

    switch ($Id) {
        "cyborg" {
            return @{ Mode = "LOKAL (Copilot CLI)"; Script = ""; LaunchArgs = @() }
        }
        "general-sim" {
            return @{ Mode = "SSH (StrikerPi)"; Script = ""; LaunchArgs = @("-t", "strikerpi", "bash -l /opt/general-sim/start_general_sim_terminal.sh") }
        }
        "rig" {
            return @{ Mode = "SSH -ClientMode"; Script = Join-Path $SharedScriptsRoot "connect_rig_terminal.ps1"; LaunchArgs = @("-t", "simracer", "powershell.exe -NoExit -ExecutionPolicy Bypass -File C:\ac-sandbox\shared\agents\rig\start_rig_terminal.ps1 -ClientMode") }
        }
        "light" {
            return @{ Mode = "SSH -ClientMode"; Script = Join-Path $SharedScriptsRoot "connect_light_terminal.ps1"; LaunchArgs = @("-t", "simracer", "powershell.exe -NoExit -ExecutionPolicy Bypass -File C:\ac-sandbox\shared\agents\light\start_light_terminal.ps1 -ClientMode") }
        }
        "dark" {
            return @{ Mode = "SSH -ClientMode"; Script = Join-Path $SharedScriptsRoot "connect_dark_terminal.ps1"; LaunchArgs = @("-t", "ac-sandbox", "powershell.exe -NoExit -ExecutionPolicy Bypass -File \\host.lan\Data\agents\dark\start_dark_terminal.ps1 -ClientMode") }
        }
        "sarah" {
            return @{ Mode = "SSH (Bash)"; Script = Join-Path $SharedScriptsRoot "connect_sarah_terminal.ps1"; LaunchArgs = @("-t", "archibald", "bash -l ~/ac-pitwall/start_sarah_terminal.sh") }
        }
        "rick" {
            return @{ Mode = "SSH (Bash)"; Script = Join-Path $SharedScriptsRoot "connect_rick_terminal.ps1"; LaunchArgs = @("-t", "strikerpi", "bash -l /opt/rick-agent/start_rick_terminal.sh") }
        }
        default {
            throw "Kein sicherer Launcher fuer Agent-ID '$Id' definiert."
        }
    }
}

for ($i = 0; $i -lt $AgentRegistry.agents.Count; $i++) {
    $definition = $AgentRegistry.agents[$i]
    $launch = Get-AgentLaunchDefinition -Id $definition.id
    $AgentCatalog += [PSCustomObject]@{
        Key = [string]($i + 1)
        Id = [string]$definition.id
        Name = "@$($definition.id)"
        DisplayName = [string]$definition.display_name
        HostName = [string]$definition.host_label
        HostIp = [string]$definition.host_ip
        Port = $definition.port
        Mode = $launch.Mode
        Script = $launch.Script
        LaunchArgs = $launch.LaunchArgs
        Description = [string]$definition.description
    }
}

function Test-GeneralSimDeployment {
    if (-not (Get-Command ssh.exe -ErrorAction SilentlyContinue)) { return "SSH CLIENT MISSING" }
    $online = Test-TcpPortFast -TargetHost "192.168.178.86" -Port 22 -TimeoutMs 450
    if (-not $online) { return "OFFLINE" }

    $null = & ssh.exe -o BatchMode=yes -o ConnectTimeout=2 strikerpi "test -f /opt/general-sim/start_general_sim_terminal.sh" 2>$null
    if ($LASTEXITCODE -eq 0) { return "READY" }
    return "NOT DEPLOYED"
}

function Show-AgentMatrix {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  GIT-LABOR // AGENTEN-TERMINALS (kanonische Registry)" -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ("  {0,-3} {1,-15} {2,-34} {3,-18} {4,-14} {5}" -f "#", "Agent", "Ziel-Host", "Verbindung", "Status", "Aufgabe") -ForegroundColor DarkCyan
    Write-Host ("  " + ("-" * 110)) -ForegroundColor DarkGray

    foreach ($ag in $AgentCatalog) {
        if ($ag.Id -eq "cyborg") {
            $online = [bool](Get-Command copilot -ErrorAction SilentlyContinue)
            $stText = if ($online) { "LOKAL BEREIT" } else { "CLI FEHLT" }
            $color = if ($online) { "Cyan" } else { "DarkYellow" }
        } elseif ($ag.Id -eq "general-sim") {
            $stText = Test-GeneralSimDeployment
            $color = if ($stText -eq "READY") { "Green" } elseif ($stText -eq "OFFLINE") { "DarkYellow" } else { "Yellow" }
        } else {
            $online = Test-TcpPortFast -TargetHost $ag.HostIp -Port $ag.Port -TimeoutMs 450
            $stText = if ($online) { "ONLINE" } else { "OFFLINE" }
            $color = if ($online) { "Green" } else { "DarkYellow" }
        }
        $hostCol = "$($ag.HostName)"
        Write-Host ("  [{0}] {1,-15} {2,-34} {3,-18} {4,-14} {5}" -f $ag.Key, $ag.Name, $hostCol, $ag.Mode, $stText, $ag.Description) -ForegroundColor $color
    }
    Write-Host ("  " + ("-" * 110)) -ForegroundColor DarkGray
    Write-Host "  @general ist ein kompatibler Alias fuer @general-sim; General Cyborg wird separat als @cyborg gestartet." -ForegroundColor Gray
    Write-Host "  General Sim ist nur READY, wenn das Terminal-Skript auf StrikerPi tatsaechlich vorhanden ist." -ForegroundColor Gray
    Write-Host ""
}

function Start-AgentEntry {
    param($Entry, [switch]$CurrentWindow)

    if ($Entry.Id -eq "cyborg") {
        $copilotCommand = Get-Command copilot -ErrorAction SilentlyContinue
        if (-not $copilotCommand) {
            throw "Copilot CLI wurde nicht gefunden; General Cyborg kann nicht lokal gestartet werden."
        }
        if ($CurrentWindow) {
            Write-Host ">>> Starte General Cyborg lokal im Git-Labor..." -ForegroundColor Cyan
            & copilot --agent "General Cyborg"
        } else {
            $arguments = "-NoExit -NoProfile -File `"$($copilotCommand.Source)`" --agent `"General Cyborg`""
            Start-Process powershell.exe -WorkingDirectory $GitLaborRoot -ArgumentList $arguments
        }
        return
    }

    if ($Entry.Id -eq "general-sim") {
        $deployment = Test-GeneralSimDeployment
        if ($deployment -ne "READY") {
            Write-Warning "General Sim Terminal ist auf StrikerPi nicht verfuegbar ($deployment); es wird kein lokaler Ersatz gestartet."
            return
        }
        if ($CurrentWindow) {
            Write-Host ">>> Starte @general-sim auf StrikerPi..." -ForegroundColor Cyan
            $launchArgs = $Entry.LaunchArgs
            & ssh.exe @launchArgs
        } else {
            Write-Host ">>> Oeffne separates SSH-Terminal fuer @general-sim..." -ForegroundColor Green
            Start-Process ssh.exe -ArgumentList $Entry.LaunchArgs
        }
        return
    }

    if (Test-Path $Entry.Script) {
        if ($CurrentWindow) {
            Write-Host ">>> Starte $($Entry.Name) im aktuellen Terminal ($($Entry.Mode))..." -ForegroundColor Cyan
            & $Entry.Script
        } else {
            Write-Host ">>> Oeffne separates Terminal-Fenster fuer $($Entry.Name) ($($Entry.Mode))..." -ForegroundColor Green
            Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$($Entry.Script)`""
        }
    } elseif ($Entry.LaunchArgs.Count -gt 0) {
        if ($CurrentWindow) {
            Write-Host ">>> Starte $($Entry.Name) via SSH im aktuellen Terminal..." -ForegroundColor Cyan
            $launchArgs = $Entry.LaunchArgs
            & ssh.exe @launchArgs
        } else {
            Write-Host ">>> Oeffne separates SSH-Terminal fuer $($Entry.Name)..." -ForegroundColor Green
            Start-Process ssh.exe -ArgumentList $Entry.LaunchArgs
        }
    } else {
        Write-Warning "Weder lokales Skript noch SSH-Befehl fuer $($Entry.Name) definiert."
    }
}

$Agent = [string]$Agent
if ($Agent -ne "menu") {
    $aliasProperty = $AgentAliases.PSObject.Properties[$Agent]
    if ($aliasProperty) {
        $Agent = [string]$aliasProperty.Value
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
    Write-Host "[+] Alle verfuegbaren Agenten-Terminals wurden gestartet." -ForegroundColor Green
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
    Write-Host "  [1-7] Einzelnes Terminal im aktuellen Fenster oeffnen" -ForegroundColor White
    Write-Host "  [W1-W7] Einzelnes Terminal in neuem Fenster oeffnen" -ForegroundColor White
    Write-Host "  [A]   Alle verfuegbaren Terminals in separaten Fenstern starten" -ForegroundColor Yellow
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

    if ($choice -match "^w([1-7])$") {
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
