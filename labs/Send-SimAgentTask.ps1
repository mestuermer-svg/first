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
    [ValidateSet("git-labor-ssh", "assetto-corsa-content")]
    [string]$WorkspaceContext = "git-labor-ssh",

    [Parameter()]
    [ValidateSet("General_Cyborg", "General_Sim", "Light")]
    [string]$IssuedBy = "General_Cyborg",

    [Parameter()]
    [int]$LockWaitSeconds = 30,

    [Parameter()]
    [int]$LockTtlSeconds = 120,

    [Parameter()]
    [switch]$QueryStatus,

    [Parameter()]
    [switch]$QueryLeitstand
)

$AgentsRoot = "\\$SimRacerHost\ac-sandbox\shared\agents"
$PolicyFile = Join-Path $AgentsRoot "general-SIM\pitwall_control_policy.json"
$MutexLockFile = Join-Path $AgentsRoot "general-SIM\execution_mutex.lock"
$MutexMetaFile = Join-Path $AgentsRoot "general-SIM\execution_mutex.json"

function Get-PitwallPolicyState {
    if (-not (Test-Path $PolicyFile)) {
        return $null
    }
    try {
        return (Get-Content -Path $PolicyFile -Raw -Encoding UTF8 | ConvertFrom-Json)
    } catch {
        return $null
    }
}

function Get-ExecutionMutexStatus {
    $lockExists = Test-Path $MutexLockFile
    $meta = $null
    if (Test-Path $MutexMetaFile) {
        try { $meta = Get-Content -Path $MutexMetaFile -Raw -Encoding UTF8 | ConvertFrom-Json } catch {}
    }
    $expired = $false
    if ($meta -and $meta.expires_at) {
        try {
            $exp = [datetime]::Parse($meta.expires_at).ToUniversalTime()
            if ([datetime]::UtcNow -gt $exp) { $expired = $true }
        } catch {}
    }
    return [pscustomobject]@{
        locked = $lockExists -and (-not $expired)
        lock_file_present = $lockExists
        expired = $expired
        meta = $meta
    }
}

function Get-ForeignInboxConflict {
    param([string]$CurrentContext)
    $dirs = @(
        (Join-Path $AgentsRoot "general-SIM\inbox"),
        (Join-Path $AgentsRoot "light\inbox"),
        (Join-Path $AgentsRoot "rig\inbox"),
        (Join-Path $AgentsRoot "dark\inbox"),
        "\\$SimRacerHost\ac-sandbox\shared\telemetry\inbox"
    )
    foreach ($d in $dirs) {
        if (-not (Test-Path $d)) { continue }
        $files = Get-ChildItem -Path $d -Filter "*.json" -File -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            try {
                $obj = Get-Content -Path $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($obj.execution_context -and $obj.execution_context -ne $CurrentContext) {
                    return "Inbox $($f.Name) aktiv fuer Kontext '$($obj.execution_context)'"
                }
            } catch {}
        }
    }
    return $null
}

function Enter-ExecutionMutex {
    param(
        [string]$Context,
        [string]$Issuer,
        [string]$Target,
        [int]$WaitSec,
        [int]$TtlSec
    )
    $lockDir = Split-Path -Path $MutexLockFile -Parent
    if (-not (Test-Path $lockDir)) {
        New-Item -ItemType Directory -Path $lockDir -Force | Out-Null
    }
    $lockId = [guid]::NewGuid().ToString("N")
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    while ($true) {
        $conflict = Get-ForeignInboxConflict -CurrentContext $Context
        if (-not $conflict) {
            $status = Get-ExecutionMutexStatus
            if ($status.lock_file_present -and $status.expired) {
                Write-Warning "[MUTEX RECOVERY] Abgelaufenes XOR-Lock wird bereinigt (TTL ueberschritten)."
                Remove-Item -Path $MutexLockFile,$MutexMetaFile -Force -ErrorAction SilentlyContinue
            }
            try {
                $fs = [System.IO.File]::Open($MutexLockFile, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
                $metaObj = [ordered]@{
                    lock_id        = $lockId
                    holder_context = $Context
                    issued_by      = $Issuer
                    target_agent   = $Target
                    pid            = $PID
                    acquired_at    = [datetime]::UtcNow.ToString("o")
                    expires_at     = [datetime]::UtcNow.AddSeconds($TtlSec).ToString("o")
                }
                $bytes = ([System.Text.UTF8Encoding]::new($false)).GetBytes(($metaObj | ConvertTo-Json -Depth 4))
                $fs.Write($bytes, 0, $bytes.Length)
                $fs.Close()
                [System.IO.File]::WriteAllBytes($MutexMetaFile, $bytes)
                return $lockId
            } catch [System.IO.IOException] {
                # Lock existiert bereits -> warten
            }
        }

        if ($sw.Elapsed.TotalSeconds -ge $WaitSec) {
            $cur = Get-ExecutionMutexStatus
            $holder = if ($conflict) { $conflict } elseif ($cur.meta) { "Kontext '$($cur.meta.holder_context)' ($($cur.meta.issued_by)) bis $($cur.meta.expires_at)" } else { "anderer aktiver Task" }
            Write-Host "`n[XOR-MUTEX BLOCK] Parallele Ausfuehrung verhindert: $holder`n" -ForegroundColor Red
            exit 4
        }
        Start-Sleep -Seconds 1
    }
}

function Exit-ExecutionMutex {
    param([string]$LockId)
    if (-not $LockId) { return }
    try {
        if (Test-Path $MutexMetaFile) {
            $meta = Get-Content -Path $MutexMetaFile -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($meta.lock_id -and $meta.lock_id -ne $LockId) { return }
        }
        Remove-Item -Path $MutexMetaFile,$MutexLockFile -Force -ErrorAction SilentlyContinue
    } catch {}
}

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
    $polObj = Get-PitwallPolicyState
    $curPolicy = if ($polObj -and $polObj.mode) { $polObj.mode.ToUpper() } else { "MANUAL (Standard)" }
    $globalPaused = ($polObj -and $polObj.agents_paused -eq $true)
    $mutexState = Get-ExecutionMutexStatus

    Write-Host "`n=== SimRacer & Verbund Agenten-Terminals Status ===" -ForegroundColor Cyan
    $pColor = if ($curPolicy -eq "AUTO" -or $curPolicy -eq "DELEGATED") { "Green" } else { "Yellow" }
    Write-Host "  General Sim Freigabe-Gate: [$curPolicy] (Umschalten mit -SetApprovalMode AUTO/MANUAL)" -ForegroundColor $pColor
    $gateText = if ($globalPaused) { "PAUSIERT (Alle Ausfuehrungen ueber Pitwall gesperrt)" } else { "FREIGEGEBEN (Queues arbeiten FIFO)" }
    Write-Host "  Pitwall Global-Gate:       [$gateText]" -ForegroundColor $(if ($globalPaused) { "Red" } else { "Green" })
    if ($mutexState.locked -and $mutexState.meta) {
        Write-Host "  XOR-Mutex Verriegelung:    [GESPERRT durch $($mutexState.meta.holder_context) / $($mutexState.meta.issued_by) -> @$($mutexState.meta.target_agent)]" -ForegroundColor Yellow
    } else {
        Write-Host "  XOR-Mutex Verriegelung:    [FREI]" -ForegroundColor Green
    }
    Write-Host ""
    $agents = @("general", "light", "rig", "dark", "sarah")
    foreach ($ag in $agents) {
        $agDir = if ($ag -eq "general") { "general-SIM" } else { $ag }
        $inbox = if ($ag -eq "sarah") { "\\$SimRacerHost\ac-sandbox\shared\telemetry\inbox" } else { Join-Path $AgentsRoot "$agDir\inbox" }
        $connected = Test-Path $inbox
        $queueCount = 0
        if ($connected) {
            $queueCount = (Get-ChildItem -Path $inbox -Filter "*.json" -File -ErrorAction SilentlyContinue | Measure-Object).Count
        }
        $pitState = if ($polObj -and $polObj.agent_states -and $polObj.agent_states.$ag) { $polObj.agent_states.$ag } else { "active" }
        $statusStr = if (-not $connected) { "[OFFLINE]" } elseif ($queueCount -gt 0) { "[BUSY: $queueCount | $pitState]" } else { "[IDLE | $pitState]" }
        $color = if (-not $connected) { "DarkGray" } elseif ($pitState -ne "active") { "Red" } elseif ($queueCount -gt 0) { "Yellow" } else { "Green" }
        Write-Host ("  {0,-9} -> {1,-22} (Inbox: {2})" -f $ag.ToUpper(), $statusStr, $inbox) -ForegroundColor $color
    }
    $rickState = if ($polObj -and $polObj.agent_states -and $polObj.agent_states.rick) { $polObj.agent_states.rick } else { "active" }
    $rickCheck = ssh -o BatchMode=yes -o ConnectTimeout=3 $StrikerPiHost "systemctl is-active rick-agent.service 2>/dev/null; ls -1 /opt/rick-agent/inbox/*.json 2>/dev/null | wc -l" 2>$null
    if ($rickCheck) {
        $rLines = @($rickCheck -split "`r?`n")
        $rState = if ($rLines[0] -eq "active") { "ONLINE" } else { $rLines[0] }
        $rQueue = if ($rLines.Count -gt 1) { [int]$rLines[1] } else { 0 }
        Write-Host ("  {0,-9} -> [{1}: Q={2} | {3}]  (SSH: {4}:/opt/rick-agent/inbox)" -f "RICK", $rState, $rQueue, $rickState, $StrikerPiHost) -ForegroundColor $(if ($rickState -ne "active") { "Red" } else { "Green" })
    } else {
        Write-Host ("  {0,-9} -> [OFFLINE | {1}]      (SSH: {2}:/opt/rick-agent/inbox)" -f "RICK", $rickState, $StrikerPiHost) -ForegroundColor DarkGray
    }
    Write-Host ""
    return
}

if ($QueryLeitstand) {
    $protoFile = Join-Path $AgentsRoot "general-SIM\logs\leitstand_protocol.jsonl"
    $gapsFile = Join-Path $AgentsRoot "general-SIM\logs\capability_gaps_summary.json"
    Write-Host "`n=== General SIM Leitstand-Protokoll & Missing-Tools-Digest ===" -ForegroundColor Cyan
    if (Test-Path $protoFile) {
        $rows = @(Get-Content -Path $protoFile -Encoding UTF8 -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne "" } | Select-Object -Last 15)
        [array]::Reverse($rows)
        foreach ($r in $rows) {
            try {
                $obj = $r | ConvertFrom-Json
                $col = switch ($obj.final_status) {
                    "VerifiedSuccess"    { "Green" }
                    "Executed"           { "Cyan" }
                    "MissingCapability"  { "Yellow" }
                    "Unsupported"        { "Yellow" }
                    default              { "Red" }
                }
                Write-Host ("  [{0}] {1,-26} | {2,-18} | {3,-20} | {4}" -f ([string]$obj.timestamp).Substring(0, [Math]::Min(19, ([string]$obj.timestamp).Length)), $obj.task_id, $obj.final_status, $obj.error_code, $obj.summary) -ForegroundColor $col
            } catch {}
        }
    } else {
        Write-Host "  (Noch keine Eintraege in $protoFile)" -ForegroundColor DarkGray
    }
    if (Test-Path $gapsFile) {
        try {
            $g = Get-Content -Path $gapsFile -Raw -Encoding UTF8 | ConvertFrom-Json
            Write-Host "`n  Fehlende Werkzeuge: $($g.unique_missing_tools) | Fehlende Kompetenzen: $($g.unique_missing_competencies) | Gap-Events: $($g.total_gap_events)" -ForegroundColor Yellow
            foreach ($mt in @($g.missing_tools)) {
                Write-Host ("    - @{0}: {1} ({2}x)" -f $mt.agent, $mt.tool, $mt.count) -ForegroundColor Yellow
            }
        } catch {}
    }
    Write-Host ""
    return
}

$TargetAgent = $TargetAgent.ToLower()

# --- 1. HIERARCHIE-GATE ---
if ($IssuedBy -eq "Light" -and $TargetAgent -in @("general", "light")) {
    Write-Host "`n[HIERARCHIE-BLOCK] '$IssuedBy' darf nur untergeordnete Worker (dark, rig, sarah, rick) ansteuern, nicht '@$TargetAgent'.`n" -ForegroundColor Red
    exit 3
}

# --- 2. PITWALL-FREIGABE-GATE ---
$policy = Get-PitwallPolicyState
if ($policy) {
    if ($policy.agents_paused -eq $true) {
        Write-Host "`n[PITWALL-GATE BLOCK] Globale Pitwall-Freigabe ist PAUSIERT (agents_paused=true). Task abgelehnt.`n" -ForegroundColor Red
        exit 3
    }
    if ($policy.agent_states -and $policy.agent_states.$TargetAgent) {
        $agPolicyState = "$($policy.agent_states.$TargetAgent)".ToLower()
        if ($agPolicyState -in @("paused", "disabled")) {
            Write-Host "`n[PITWALL-GATE BLOCK] Agent '@$TargetAgent' ist auf der Pitwall auf '$agPolicyState' gesetzt.`n" -ForegroundColor Red
            exit 3
        }
    }
    if ($policy.mode -and "$($policy.mode)".ToUpper() -eq "MANUAL" -and $TargetAgent -in @("dark", "rig", "sarah", "rick") -and $IssuedBy -notin @("General_Sim", "General_Cyborg", "Light")) {
        Write-Host "`n[PITWALL-GATE BLOCK] Modus MANUAL erfordert Freigabe durch General/Light.`n" -ForegroundColor Red
        exit 3
    }
}

# --- 3. STRIKTE XOR-MUTEX-VERRIEGELUNG ---
$activeLockId = Enter-ExecutionMutex -Context $WorkspaceContext -Issuer $IssuedBy -Target $TargetAgent -WaitSec $LockWaitSeconds -TtlSec $LockTtlSeconds
try {

if ($TargetAgent -eq "rick") {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $randSuffix = [System.IO.Path]::GetRandomFileName().Replace(".", "").Substring(0, 4)
    $taskId = "task_${timestamp}_${randSuffix}"
    $taskData = [ordered]@{
        task_id           = $taskId
        sender            = "git-labor-powershell"
        issued_by         = $IssuedBy
        approved_by       = $IssuedBy
        execution_context = $WorkspaceContext
        target            = "rick"
        action            = if ($Prompt -ne "") { "note" } else { $Action }
        prompt            = $Prompt
        parameters        = $Params
        created_at        = (Get-Date).ToUniversalTime().ToString("o")
    }
    $tmpJson = Join-Path $env:TEMP "$taskId.json"
    $taskData | ConvertTo-Json -Depth 5 | Set-Content -Path $tmpJson -Encoding UTF8
    scp -q $tmpJson "${StrikerPiHost}:/opt/rick-agent/inbox/${taskId}.json"
    Remove-Item $tmpJson -Force -ErrorAction SilentlyContinue
    Write-Host "`n[+] Task übermittelt: $taskId an Agent '@rick' via SSH ($StrikerPiHost) [Kontext: $WorkspaceContext | Issuer: $IssuedBy]" -ForegroundColor Green
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
    if ($txt -match "(race\.ini|video\.ini|csp|preset|setup|\.ini|grass|benchmark|optim)") {
        $subsets.Add("Assetto_Corsa_Config")
        $subsets.Add("ini_parsing")
        if ($Target -in @("rig", "dark")) { $subsets.Add("Optimization_Sandbox_Core") }
    }
    if ($txt -match "(vr|steamvr|focus|vive|ffb|fanatec|gpu|vram|5070)") { $subsets.Add("Hardware_VR_Telemetry") }
    if ($txt -match "(docker|sandbox|container|novnc|8006|2222)") { $subsets.Add("Docker_Sandbox_Guest") }
    if ($txt -match "(replay|video|cut|mp4|stint|lap|sector|telemetr|sarah|funk|radio)") { $subsets.Add("Telemetry_Coaching_Media") }
    if ($txt -match "(mqtt|relay|mosquitto|8080|1883|git)") { $subsets.Add("Edge_Relay_MQTT") }
    if ($subsets.Count -eq 0) {
        switch ($Target) {
            "dark"  { $subsets.Add("Docker_Sandbox_Guest"); $subsets.Add("Optimization_Sandbox_Core"); $subsets.Add("ini_parsing") }
            "light" { $subsets.Add("Assetto_Corsa_Config"); $subsets.Add("Docker_Sandbox_Guest") }
            "rig"   { $subsets.Add("Hardware_VR_Telemetry"); $subsets.Add("Optimization_Sandbox_Core") }
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
    task_id           = $taskId
    target            = $TargetAgent
    target_agent      = $TargetAgent
    sender            = "git-labor-powershell"
    source            = "git-labor-powershell"
    issued_by         = $IssuedBy
    approved_by       = $IssuedBy
    execution_context = $WorkspaceContext
    priority          = 2
    origin            = "ssh_cyborg"
    hop_count         = 0
    action            = if ($Prompt -ne "") { "ProcessPrompt" } else { $Action }
    prompt            = $Prompt
    context_subset    = $ctxSubset
    memory_scope      = $memScope
    parameters        = $Params
    created_at        = (Get-Date).ToUniversalTime().ToString("o")
}

$taskFile = Join-Path $TargetInbox "$taskId.json"
$taskData | ConvertTo-Json -Depth 5 | Set-Content -Path $taskFile -Encoding UTF8

Write-Host "`n[+] Task übermittelt: $taskId an Agent '@$TargetAgent' ($Action) [Kontext: $WorkspaceContext | Issuer: $IssuedBy]" -ForegroundColor Green
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

$resultJson = $null
for ($attempt = 1; $attempt -le 5; $attempt++) {
    Start-Sleep -Milliseconds 200 # SMB-Flush abwarten
    try {
        $rawRes = Get-Content -Path $resultFile -Raw -Encoding UTF8 -ErrorAction Stop
        if ($rawRes -and $rawRes.Trim().Length -gt 2) {
            $resultJson = $rawRes | ConvertFrom-Json -ErrorAction Stop
            if ($resultJson) { break }
        }
    } catch {
        $resultJson = $null
    }
}
if ($resultJson) {
    $stColor = switch ($resultJson.status) {
        "VerifiedSuccess"    { "Green" }
        "Success"            { "Green" }
        "Executed"           { "Cyan" }
        "MissingCapability"  { "Yellow" }
        "Unsupported"        { "Yellow" }
        "Ignored"            { "Yellow" }
        default              { "Red" }
    }
    Write-Host "`n========================= RÜCKMELDUNG ERHALTEN =========================" -ForegroundColor Cyan
    Write-Host "Task-ID:      $($resultJson.task_id)" -ForegroundColor White
    Write-Host "Agent:        $($resultJson.agent)" -ForegroundColor White
    Write-Host "Status:       $($resultJson.status)" -ForegroundColor $stColor
    if ($resultJson.error_code) { Write-Host "Fehlercode:   $($resultJson.error_code)" -ForegroundColor Yellow }
    if ($resultJson.executed_handler) { Write-Host "Handler:      $($resultJson.executed_handler)" -ForegroundColor Gray }
    if ($resultJson.tool_used) { Write-Host "Werkzeug:     $($resultJson.tool_used)" -ForegroundColor Gray }
    if ($resultJson.missing_tools -and @($resultJson.missing_tools).Count -gt 0) {
        Write-Host "Fehlende Tools: $((@($resultJson.missing_tools)) -join ', ')" -ForegroundColor Yellow
    }
    if ($resultJson.ollama_extension_proposal) {
        Write-Host "Ollama-Vorschlag: $($resultJson.ollama_extension_proposal | ConvertTo-Json -Compress)" -ForegroundColor DarkCyan
    }
    Write-Host "Exit-Code:    $($resultJson.exit_code)" -ForegroundColor White
    Write-Host "Dauer:        $($resultJson.duration_seconds) s" -ForegroundColor Gray
    Write-Host "------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Ausgabe:`n$($resultJson.output)" -ForegroundColor White
    if (Test-Path $logFile) {
        Write-Host "Log-Datei:    $logFile" -ForegroundColor DarkGray
    }
    Write-Host "========================================================================`n" -ForegroundColor Cyan
} else {
    Write-Warning "Ergebnisdatei vorhanden, konnte auch nach SMB-Retry nicht als JSON geparst werden: $resultFile"
}
} finally {
    Exit-ExecutionMutex -LockId $activeLockId
}
