<#
.SYNOPSIS
    Send-SimAgentTask.ps1 - Sendet Aufgaben aus Git-Labor an die SimRacer-Agenten-Terminals.
.DESCRIPTION
    Schreibt strukturierte Task-JSONs in die Inbox des Ziel-Agenten auf dem SimRacer (192.168.178.68).
    Unterstützt synchrones Warten auf die Rückmeldung (outbox/result_<id>.json) sowie Statusabfragen.
.EXAMPLE
    .\Send-SimAgentTask.ps1 -QueryStatus
.EXAMPLE
    .\Send-SimAgentTask.ps1 -TargetAgent dark -Action ValidateSetups -Wait
.EXAMPLE
    .\Send-SimAgentTask.ps1 -TargetAgent light -Action ApplyPreset -Params @{ preset = "vr_focusvision" } -Wait
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("general", "light", "rig", "dark", "sarah", "rick")]
    [string]$TargetAgent = "dark",

    [Parameter(Position = 1)]
    [string]$Action = "ValidateSetups",

    [Parameter()]
    [string]$Prompt = "",

    [Parameter()]
    [hashtable]$Params = @{},

    [Parameter()]
    [switch]$Wait,

    [Parameter()]
    [int]$TimeoutSeconds = 60,

    [Parameter()]
    [string]$SimRacerHost = "192.168.178.68",

    [Parameter()]
    [string]$StrikerPiHost = "strikerpi",

    [Parameter()]
    [switch]$QueryStatus
)

$AgentsRoot = "\\$SimRacerHost\ac-sandbox\shared\agents"

# Status-Abfrage aller Agenten
if ($QueryStatus) {
    Write-Host "`n=== SimRacer & Verbund Agenten-Terminals Status ===" -ForegroundColor Cyan
    $agents = @("general", "light", "rig", "dark", "sarah")
    foreach ($ag in $agents) {
        $inbox = if ($ag -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\inbox" } else { Join-Path $AgentsRoot "$ag\inbox" }
        $outbox = if ($ag -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\outbox" } else { Join-Path $AgentsRoot "$ag\outbox" }
        $connected = Test-Path $inbox
        $queueCount = 0
        if ($connected) {
            $queueCount = (Get-ChildItem -Path $inbox -Filter "*.json" -File -ErrorAction SilentlyContinue | Measure-Object).Count
        }
        $statusStr = if (-not $connected) { "[OFFLINE]" } elseif ($queueCount -gt 0) { "[BUSY: $queueCount]" } else { "[IDLE]" }
        $color = if (-not $connected) { "DarkGray" } elseif ($queueCount -gt 0) { "Yellow" } else { "Green" }
        Write-Host ("  {0,-9} -> {1,-14} (Inbox: {2})" -f $ag.ToUpper(), $statusStr, $inbox) -ForegroundColor $color
    }
    $rickCheck = ssh -o BatchMode=yes -o ConnectTimeout=3 $StrikerPiHost "systemctl is-active rick-agent.service 2>/dev/null; ls -1 /opt/rick-agent/inbox/*.json 2>/dev/null | wc -l" 2>$null
    if ($rickCheck) {
        $rLines = @($rickCheck -split "`r?`n")
        $rState = if ($rLines[0] -eq "active") { "ONLINE" } else { $rLines[0] }
        $rQueue = if ($rLines.Count -gt 1) { [int]$rLines[1] } else { 0 }
        Write-Host ("  {0,-9} -> [{1}: Q={2}] (SSH: {3}:/opt/rick-agent/inbox)" -f "RICK", $rState, $rQueue, $StrikerPiHost) -ForegroundColor Green
    } else {
        Write-Host ("  {0,-9} -> [OFFLINE]      (SSH: {1}:/opt/rick-agent/inbox)" -f "RICK", $StrikerPiHost) -ForegroundColor DarkGray
    }
    Write-Host ""
    return
}

$TargetAgent = $TargetAgent.ToLower()

if ($TargetAgent -eq "rick") {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $randSuffix = [System.IO.Path]::GetRandomFileName().Replace(".", "").Substring(0, 4)
    $taskId = "task_${timestamp}_${randSuffix}"
    $taskData = [ordered]@{
        task_id    = $taskId
        sender     = "git-labor-powershell"
        target     = "rick"
        action     = if ($Prompt -ne "") { "note" } else { $Action }
        prompt     = $Prompt
        parameters = $Params
        created_at = (Get-Date).ToUniversalTime().ToString("o")
    }
    $tmpJson = Join-Path $env:TEMP "$taskId.json"
    $taskData | ConvertTo-Json -Depth 5 | Set-Content -Path $tmpJson -Encoding UTF8
    scp -q $tmpJson "${StrikerPiHost}:/opt/rick-agent/inbox/${taskId}.json"
    Remove-Item $tmpJson -Force -ErrorAction SilentlyContinue
    Write-Host "`n[+] Task übermittelt: $taskId an Agent '@rick' via SSH ($StrikerPiHost)" -ForegroundColor Green
    if (-not $Wait) { return }
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
        $res = ssh -o BatchMode=yes $StrikerPiHost "cat /opt/rick-agent/outbox/result_${taskId}.json 2>/dev/null" 2>$null
        if ($res) {
            Write-Host "`n$res`n" -ForegroundColor Cyan
            return
        }
        Start-Sleep -Seconds 1
    }
    Write-Warning "[-] Timeout nach ${TimeoutSeconds}s fuer Rick Task $taskId."
    return
}
$TargetInbox = if ($TargetAgent -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\inbox" } else { Join-Path $AgentsRoot "$TargetAgent\inbox" }
$TargetOutbox = if ($TargetAgent -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\outbox" } else { Join-Path $AgentsRoot "$TargetAgent\outbox" }
$TargetLogs = if ($TargetAgent -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\logs" } else { Join-Path $AgentsRoot "$TargetAgent\logs" }

if (-not (Test-Path $TargetInbox)) {
    try {
        New-Item -ItemType Directory -Path $TargetInbox -Force | Out-Null
    } catch {
        Write-Error "Kann Ziel-Inbox nicht erreichen: $TargetInbox ($($_.Exception.Message))"
        return
    }
}
if (-not (Test-Path $TargetOutbox)) {
    New-Item -ItemType Directory -Path $TargetOutbox -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$randSuffix = [System.IO.Path]::GetRandomFileName().Replace(".", "").Substring(0, 4)
$taskId = "task_${timestamp}_${randSuffix}"

$taskData = [ordered]@{
    task_id      = $taskId
    target_agent = $TargetAgent
    source       = "git-labor-powershell"
    action       = if ($Prompt -ne "") { "ProcessPrompt" } else { $Action }
    prompt       = $Prompt
    parameters   = $Params
    created_at   = (Get-Date).ToUniversalTime().ToString("o")
}

$taskFile = Join-Path $TargetInbox "$taskId.json"
$taskData | ConvertTo-Json -Depth 5 | Set-Content -Path $taskFile -Encoding UTF8

Write-Host "`n[+] Task übermittelt: $taskId an Agent '@$TargetAgent' ($Action)" -ForegroundColor Green
Write-Host "    Datei: $taskFile" -ForegroundColor Gray

if (-not $Wait) {
    Write-Host "[i] Asynchron abgeschickt. Status und Rückmeldung können per -QueryStatus oder in outbox/ eingesehen werden.`n" -ForegroundColor DarkCyan
    return
}

Write-Host "[*] Warte auf Rückmeldung in outbox (Timeout: ${TimeoutSeconds}s)..." -ForegroundColor Yellow
$resultFile = Join-Path $TargetOutbox "result_$taskId.json"
$logFile = Join-Path $TargetLogs "task_$taskId.log"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$resultFound = $false

while ($stopwatch.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
    if (Test-Path $resultFile) {
        $resultFound = $true
        break
    }
    Start-Sleep -Seconds 1
}

if (-not $resultFound) {
    Write-Warning "[-] Timeout: Nach ${TimeoutSeconds}s liegt noch kein Ergebnis in $resultFile vor."
    return
}

Start-Sleep -Milliseconds 200 # Sicherstellen, dass Datei fertig geschrieben ist
try {
    $resultJson = Get-Content -Path $resultFile -Raw -Encoding UTF8 | ConvertFrom-Json
    Write-Host "`n========================= RÜCKMELDUNG ERHALTEN =========================" -ForegroundColor Cyan
    Write-Host "Task-ID:      $($resultJson.task_id)" -ForegroundColor White
    Write-Host "Agent:        $($resultJson.agent)" -ForegroundColor White
    Write-Host "Status:       $($resultJson.status)" -ForegroundColor (if ($resultJson.status -eq "Success") { "Green" } else { "Red" })
    Write-Host "Exit-Code:    $($resultJson.exit_code)" -ForegroundColor White
    Write-Host "Dauer:        $($resultJson.duration_seconds) s" -ForegroundColor Gray
    Write-Host "------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Ausgabe:`n$($resultJson.output)" -ForegroundColor White
    if (Test-Path $logFile) {
        Write-Host "Log-Datei:    $logFile" -ForegroundColor DarkGray
    }
    Write-Host "========================================================================`n" -ForegroundColor Cyan
} catch {
    Write-Warning "Ergebnisdatei vorhanden, konnte aber nicht als JSON geparst werden: $resultFile"
}
