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
    [ValidateSet("AUTO", "MANUAL", "")]
    [string]$SetApprovalMode = "",

    [Parameter()]
    [switch]$QueryStatus
)

$AgentsRoot = "\\$SimRacerHost\ac-sandbox\shared\agents"
$PolicyFile = Join-Path $AgentsRoot "general-SIM\pitwall_control_policy.json"

# Verbindlicher Change-Freeze & Cross-Agent-Schreibschutz
$ChangeFreezeRegex = "(?i)(\.agent\.md|AGENTS\.md|\.instructions\.md|SKILL\.md|approval_policy\.json|pitwall_control_policy\.json|settings\.json|mcp\.json|tasks\.json|\.code-workspace|start_general_terminal\.ps1|start_light_terminal\.ps1|start_rig_terminal\.ps1|start_dark_terminal\.ps1|start_sarah_terminal\.ps1|worker\.ps1|runner\.ps1|rick_worker\.py)"
$combinedPayloadCheck = "$Action $Prompt $($Params | ConvertTo-Json -Compress -ErrorAction SilentlyContinue)"
if ($combinedPayloadCheck -match $ChangeFreezeRegex) {
    Write-Error "[CHANGE-FREEZE BLOCK] Sicherheitsverstoß: Kein Agent darf eigene oder fremde Agenten-Profile (.agent.md), Skills (SKILL.md), System-Configs oder Worker-Skripte ohne manuelle Nutzer-Freigabe ändern!"
    return
}

if ($SetApprovalMode -ne "") {
    $mode = $SetApprovalMode.ToUpper()
    if (Test-Path $PolicyFile) {
        try {
            $pol = Get-Content -Path $PolicyFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $pol | Add-Member -NotePropertyName "mode" -NotePropertyValue $mode -Force
            $pol | Add-Member -NotePropertyName "updated_at" -NotePropertyValue (Get-Date -Format "o") -Force
            $pol | Add-Member -NotePropertyName "updated_by" -NotePropertyValue "Send-SimAgentTask" -Force
            [System.IO.File]::WriteAllText($PolicyFile, ($pol | ConvertTo-Json -Depth 10), ([System.Text.UTF8Encoding]::new($false)))
            Write-Host "`n[+] Freigabemodus in pitwall_control_policy.json erfolgreich auf '$mode' gesetzt!`n" -ForegroundColor Green
        } catch {
            Write-Warning "Fehler beim Aktualisieren von $PolicyFile : $_"
        }
    } else {
        Write-Warning "Kann pitwall_control_policy.json nicht erreichen ($PolicyFile). approval_policy.json bleibt per Change-Freeze unangetastet!"
    }
    return
}

# Status-Abfrage aller Agenten
if ($QueryStatus) {
    $curPolicy = "MANUAL (Standard)"
    if (Test-Path $PolicyFile) {
        try {
            $polObj = Get-Content -Path $PolicyFile -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($polObj.mode) { $curPolicy = $polObj.mode.ToUpper() }
        } catch {}
    }
    Write-Host "`n=== SimRacer & Verbund Agenten-Terminals Status ===" -ForegroundColor Cyan
    $pColor = if ($curPolicy -eq "AUTO") { "Green" } else { "Yellow" }
    Write-Host "  General Sim Freigabe-Gate: [$curPolicy] (Umschalten mit -SetApprovalMode AUTO/MANUAL)" -ForegroundColor $pColor
    Write-Host ""
    $agents = @("general", "light", "rig", "dark", "sarah")
    foreach ($ag in $agents) {
        $agDir = if ($ag -eq "general") { "general-SIM" } else { $ag }
        $inbox = if ($ag -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\inbox" } else { Join-Path $AgentsRoot "$agDir\inbox" }
        $outbox = if ($ag -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\outbox" } else { Join-Path $AgentsRoot "$agDir\outbox" }
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
$TargetDir = if ($TargetAgent -eq "general") { "general-SIM" } else { $TargetAgent }
$TargetInbox = if ($TargetAgent -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\inbox" } else { Join-Path $AgentsRoot "$TargetDir\inbox" }
$TargetOutbox = if ($TargetAgent -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\outbox" } else { Join-Path $AgentsRoot "$TargetDir\outbox" }
$TargetLogs = if ($TargetAgent -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\logs" } else { Join-Path $AgentsRoot "$TargetDir\logs" }

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

function Get-TaskContextSubset {
    param([string]$Target, [string]$Act, [string]$Prm)
    $txt = "$Act $Prm".ToLowerInvariant()
    $subsets = [System.Collections.Generic.List[string]]::new()
    if ($txt -match "(race\.ini|video\.ini|csp|preset|setup|\.ini)") { $subsets.Add("Assetto_Corsa_Config"); $subsets.Add("ini_parsing") }
    if ($txt -match "(vr|steamvr|focus|vive|ffb|fanatec|gpu|vram|5070)") { $subsets.Add("Hardware_VR_Telemetry") }
    if ($txt -match "(docker|sandbox|container|novnc|8006|2222)") { $subsets.Add("Docker_Sandbox_Guest") }
    if ($txt -match "(replay|video|cut|mp4|stint|lap|sector|telemetr)") { $subsets.Add("Telemetry_Coaching_Media") }
    if ($txt -match "(mqtt|relay|mosquitto|8080|1883|git)") { $subsets.Add("Edge_Relay_MQTT") }
    if ($subsets.Count -eq 0) {
        switch ($Target) {
            "dark"  { $subsets.Add("Docker_Sandbox_Guest"); $subsets.Add("ini_parsing") }
            "light" { $subsets.Add("Assetto_Corsa_Config"); $subsets.Add("Docker_Sandbox_Guest") }
            "rig"   { $subsets.Add("Hardware_VR_Telemetry") }
            "sarah" { $subsets.Add("Telemetry_Coaching_Media") }
            "rick"  { $subsets.Add("Edge_Relay_MQTT") }
            default { $subsets.Add("Workspace_Orchestration") }
        }
    }
    return ,($subsets | Select-Object -Unique)
}

$ctxSubset = Get-TaskContextSubset -Target $TargetAgent -Act $Action -Prm $Prompt
$memScope  = if ($TargetAgent -eq "dark") { "memories/sandbox" } else { "memories/host/$TargetAgent" }

$taskData = [ordered]@{
    task_id        = $taskId
    target         = $TargetAgent
    target_agent   = $TargetAgent
    sender         = "git-labor-powershell"
    source         = "git-labor-powershell"
    priority       = 2
    origin         = "ssh_cyborg"
    hop_count      = 0
    action         = if ($Prompt -ne "") { "ProcessPrompt" } else { $Action }
    prompt         = $Prompt
    context_subset = $ctxSubset
    memory_scope   = $memScope
    parameters     = $Params
    created_at     = (Get-Date).ToUniversalTime().ToString("o")
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
