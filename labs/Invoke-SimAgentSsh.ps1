<#
.SYNOPSIS
    Invoke-SimAgentSsh.ps1 - Direkte SSH-Steuerung und Prompt-Uebergabe aus git-labor an alle Agenten (inkl. General Sim).
.DESCRIPTION
    Erlaubt General Cyborg im Workspace git-labor, jeden Agenten im Verbund (general, light, rig, dark, sarah, rick)
    direkt per SSH zu prompten, zu steuern, Live-Status abzurufen und jede Aktion per SSH-Audit mitzuloggen.
.EXAMPLE
    .\Invoke-SimAgentSsh.ps1 -Agent general -Prompt "status"
    .\Invoke-SimAgentSsh.ps1 -Agent rig -Action Status
    .\Invoke-SimAgentSsh.ps1 -Agent dark -Action LaunchCM
    .\Invoke-SimAgentSsh.ps1 -Agent sarah -Prompt "status"
    .\Invoke-SimAgentSsh.ps1 -Agent rick -Action status
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("general", "light", "rig", "dark", "sarah", "rick")]
    [string]$Agent,

    [Parameter(Position = 1)]
    [string]$Prompt = "",

    [Parameter()]
    [string]$Action = "",

    [Parameter()]
    [string]$Target = "",

    [Parameter()]
    [string]$Command = "",

    [Parameter()]
    [int]$TimeoutSeconds = 30
)

$ErrorActionPreference = "Stop"
$GitLaborRoot = Split-Path -Parent $PSScriptRoot
$AcSandboxShared = Join-Path (Split-Path -Parent $GitLaborRoot) "assetto-corsa-content\ac-sandbox\shared"
$AuditHelper = Join-Path $AcSandboxShared "scripts\ssh_audit_helper.ps1"
if (Test-Path $AuditHelper) { . $AuditHelper }

$CallerId = "GeneralCyborg@$env:COMPUTERNAME"
$TaskId = "ssh_" + (Get-Date -Format "yyyyMMdd_HHmmss_fff")
$EffectiveAction = if ($Action) { $Action } elseif ($Prompt) { "ProcessPrompt" } else { "Status" }

if (Get-Command Write-AgentSshAudit -ErrorAction SilentlyContinue) {
    [void](Write-AgentSshAudit -AgentName $Agent -Action "SSH_Invoke:$EffectiveAction" -Status "Dispatched" -Details ("Prompt='$Prompt' Target='$Target' Command='$Command'") -Caller $CallerId -TaskId $TaskId)
}

function Invoke-SshCmd {
    param([string]$SshAlias, [string]$RemoteCmd)
    Write-Host ">>> [General Cyborg -> SSH:$SshAlias -> @$Agent] ($TaskId)" -ForegroundColor Cyan
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $out = & ssh.exe -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=6 $SshAlias $RemoteCmd 2>&1 | Out-String
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prevEap
    if (Get-Command Write-AgentSshAudit -ErrorAction SilentlyContinue) {
        $st = if ($code -eq 0) { "Success" } else { "Failed(Exit=$code)" }
        [void](Write-AgentSshAudit -AgentName $Agent -Action "SSH_Result:$EffectiveAction" -Status $st -Details $out -Caller $CallerId -TaskId $TaskId)
    }
    Write-Output $out
    if ($code -ne 0) { exit $code }
}

function New-EncodedPsCommand {
    param([string]$ScriptText)
    $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ScriptText))
    return "powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $enc"
}

switch ($Agent.ToLower()) {
    "general" {
        $genScript = "C:\Users\strik\assetto-corsa-content\ac-sandbox\shared\agents\general-SIM\start_general_terminal.ps1"
        $pText = if ($Prompt) { $Prompt } elseif ($Action) { $Action } else { "status" }
        $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pText))
        $psInner = "`$p=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$b64')); & '$genScript' -PromptOnce `$p -Caller '$CallerId'"
        Invoke-SshCmd -SshAlias "general-sim" -RemoteCmd (New-EncodedPsCommand $psInner)
    }
    "rig" {
        if (-not $Prompt -and $EffectiveAction -in @("Status", "Watchdog", "PauseSandbox", "ResumeSandbox", "ListContent", "ProvisionContent", "AutoProvisionFromRaceIni", "DeployPitfile", "GetTelemetry")) {
            $tB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Target))
            $psInner = "`$t=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$tB64')); `$p=@{Action='$EffectiveAction';Caller='$CallerId';TaskId='$TaskId'}; if(`$t){`$p['CarName']=`$t}; & 'C:\ac-sandbox\shared\scripts\rig-hub.ps1' @p"
            Invoke-SshCmd -SshAlias "simracer" -RemoteCmd (New-EncodedPsCommand $psInner)
        } else {
            $pText = if ($Prompt) { $Prompt } else { $EffectiveAction }
            $payload = ([ordered]@{
                task_id           = $TaskId
                sender            = $CallerId
                target            = "rig"
                action            = if ($Action -and $Action -ne "ProcessPrompt") { $Action } else { "ProcessPrompt" }
                prompt            = $pText
                approved_by       = "GeneralCyborg_SSH"
                requires_approval = $false
                reply_to          = "general"
                timestamp         = (Get-Date -Format "o")
            }) | ConvertTo-Json -Depth 4 -Compress
            $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($payload))
            $psInner = "`$j=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$b64')); `$in='C:\ac-sandbox\shared\agents\rig\inbox\$TaskId.json'; `$out='C:\ac-sandbox\shared\agents\rig\outbox\result_$TaskId.json'; Set-Content -Path `$in -Value `$j -Encoding UTF8; `$sw=[Diagnostics.Stopwatch]::StartNew(); while(`$sw.Elapsed.TotalSeconds -lt $TimeoutSeconds){ if(Test-Path `$out){ Start-Sleep -Milliseconds 150; Get-Content `$out -Raw -Encoding UTF8; exit 0 }; Start-Sleep -Milliseconds 400 }; Write-Output ('TIMEOUT:' + `$in); exit 1"
            Invoke-SshCmd -SshAlias "simracer" -RemoteCmd (New-EncodedPsCommand $psInner)
        }
    }
    "light" {
        $pText = if ($Prompt) { $Prompt } else { $EffectiveAction }
        $payload = ([ordered]@{
            task_id           = $TaskId
            sender            = $CallerId
            target            = "light"
            action            = if ($Action -and $Action -ne "ProcessPrompt") { $Action } else { "ProcessPrompt" }
            prompt            = $pText
            approved_by       = "GeneralCyborg_SSH"
            requires_approval = $false
            reply_to          = "general"
            timestamp         = (Get-Date -Format "o")
        }) | ConvertTo-Json -Depth 4 -Compress
        $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($payload))
        $psInner = "`$j=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$b64')); `$in='C:\ac-sandbox\shared\agents\light\inbox\$TaskId.json'; `$out='C:\ac-sandbox\shared\agents\light\outbox\result_$TaskId.json'; Set-Content -Path `$in -Value `$j -Encoding UTF8; `$sw=[Diagnostics.Stopwatch]::StartNew(); while(`$sw.Elapsed.TotalSeconds -lt $TimeoutSeconds){ if(Test-Path `$out){ Start-Sleep -Milliseconds 150; Get-Content `$out -Raw -Encoding UTF8; exit 0 }; Start-Sleep -Milliseconds 400 }; Write-Output ('TIMEOUT:' + `$in); exit 1"
        Invoke-SshCmd -SshAlias "simracer" -RemoteCmd (New-EncodedPsCommand $psInner)
    }
    "dark" {
        $pB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($(if ($Prompt) { $Prompt } else { "" })))
        $tB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Target))
        $cB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Command))
        $actName = if (-not $Prompt -and $EffectiveAction -in @("Status", "RunScript", "TestApp", "ValidateSetups", "LaunchCM", "StopCM", "CleanTemp", "ApplyPreset", "ListPresets", "SetSession", "LaunchSession", "StopSession", "DiagnoseAndHandoff", "SyncCoreAssets", "OpenExplorer", "SetTimezone")) { $EffectiveAction } else { "ProcessPrompt" }
        $psInner = "`$pr=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$pB64')); `$tg=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$tB64')); `$cm=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$cB64')); `$p=@{Action='$actName';Caller='$CallerId';TaskId='$TaskId'}; if(`$pr){`$p['Prompt']=`$pr}; if(`$tg){`$p['Target']=`$tg}; if(`$cm){`$p['Command']=`$cm}; & '\\host.lan\Data\agents\dark\runner.ps1' @p"
        Invoke-SshCmd -SshAlias "ac-sandbox" -RemoteCmd (New-EncodedPsCommand $psInner)
    }
    "sarah" {
        $pText = if ($Prompt) { $Prompt } elseif ($Action) { $Action } else { "status" }
        $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pText))
        $remoteSh = 'PROMPT_B64=''' + $b64 + ''' CALLER=''' + $CallerId + ''' TASK_ID=''' + $TaskId + ''' bash -lc ''P=$(printf "%s" "$PROMPT_B64" | base64 -d); if [ -x ~/ac-pitwall/sarah_ssh_exec.sh ]; then ~/ac-pitwall/sarah_ssh_exec.sh "$P" "$CALLER" "$TASK_ID"; else echo "SARAH_SSH_OK: $P"; systemctl --user is-active sarah-pitwall-telemetry.service 2>/dev/null || true; fi'''
        Invoke-SshCmd -SshAlias "archibald" -RemoteCmd $remoteSh
    }
    "rick" {
        $act = if ($Action) { $Action.ToLower() } elseif ($Prompt -match "^(status|health|ping|restart_relay|restart_mqtt|git_status)$") { $Prompt.ToLower() } else { "note" }
        $pText = if ($Prompt) { $Prompt } else { $act }
        $payload = ([ordered]@{
            task_id   = $TaskId
            sender    = $CallerId
            target    = "rick"
            action    = $act
            prompt    = $pText
            timestamp = (Get-Date -Format "o")
        }) | ConvertTo-Json -Depth 4 -Compress
        $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($payload))
        $remoteSh = "echo '$b64' | base64 -d > /opt/rick-agent/inbox/${TaskId}.json && for i in `$(seq 1 $TimeoutSeconds); do if [ -f /opt/rick-agent/outbox/result_${TaskId}.json ]; then cat /opt/rick-agent/outbox/result_${TaskId}.json; exit 0; fi; sleep 1; done; echo 'TIMEOUT:${TaskId}'; exit 1"
        Invoke-SshCmd -SshAlias "strikerpi" -RemoteCmd $remoteSh
    }
}
