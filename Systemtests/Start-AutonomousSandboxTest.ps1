<#
.SYNOPSIS
    Start-AutonomousSandboxTest.ps1 - Autonomer End-to-End-Testablauf fuer Docker-Sandbox, @light, @rig & @dark.
.DESCRIPTION
    Fuehrt ohne manuelle Zwischenschritte folgenden Testablauf ueber die Agenten-Queues aus:
      1. Pre-Flight: SMB-Share, Pitwall-Policy (AUTO & nicht pausiert) & Agenten-Erreichbarkeit pruefen.
      2. Docker-Sandbox starten & Container-Status verifizieren (@light / @rig).
      3. @dark (ac-win11-sandbox) Start & Handshake verifizieren (@dark Status).
      4. Noch nicht in der Sandbox installiertes Auto vom Hostsystem SimRacer ermitteln,
         ueber @light (ProvideAcContent) uebertragen und in @dark (SyncCoreAssets + ListContent) verifizieren.
      5. Strecke auswaehlen, Session in race.ini setzen (@dark SetSession) und Trainingssession starten (@dark LaunchSession).
      6. Abschluss-Status (@dark Status) und strukturierten Testbericht in Systemtests\ ablegen.
.EXAMPLE
    .\Start-AutonomousSandboxTest.ps1
.EXAMPLE
    .\Start-AutonomousSandboxTest.ps1 -Car ks_porsche_911_gt3_r_2016 -Track monza -TimeoutSeconds 180
.EXAMPLE
    .\Start-AutonomousSandboxTest.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$SimRacerHost = "192.168.178.68",

    [Parameter()]
    [string]$Car = "",

    [Parameter()]
    [string]$Track = "monza",

    [Parameter()]
    [int]$TimeoutSeconds = 180,

    [Parameter()]
    [string]$WorkspaceContext = "git-labor-ssh",

    [Parameter()]
    [string]$IssuedBy = "General_Cyborg",

    [Parameter()]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$AgentsRoot   = "\\$SimRacerHost\ac-sandbox\shared\agents"
$PolicyFile   = Join-Path $AgentsRoot "general-SIM\pitwall_control_policy.json"
$RunStamp     = Get-Date -Format "yyyyMMdd_HHmmss"
$ReportPath   = Join-Path $PSScriptRoot "Testbericht_Autonome_Sandbox_$RunStamp.md"
$Phases       = [System.Collections.Generic.List[object]]::new()
$TestSw       = [System.Diagnostics.Stopwatch]::StartNew()

function Add-PhaseResult {
    param(
        [string]$Phase,
        [string]$Agent,
        [string]$TaskId,
        [string]$Status,
        [double]$DurationSec,
        [string]$Details
    )
    $Phases.Add([pscustomobject]@{
        Phase       = $Phase
        Agent       = $Agent
        TaskId      = $TaskId
        Status      = $Status
        DurationSec = [math]::Round($DurationSec, 2)
        Details     = $Details
    })
}

function Invoke-SimAgentDirectTask {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("light", "rig", "dark")]
        [string]$TargetAgent,

        [Parameter(Mandatory)]
        [string]$Action,

        [string]$Prompt = "",
        [hashtable]$ExtraFields = @{},
        [int]$WaitSec = 120
    )

    $inboxDir  = Join-Path $AgentsRoot "$TargetAgent\inbox"
    $outboxDir = Join-Path $AgentsRoot "$TargetAgent\outbox"
    if (-not (Test-Path $inboxDir))  { New-Item -ItemType Directory -Path $inboxDir -Force | Out-Null }
    if (-not (Test-Path $outboxDir)) { New-Item -ItemType Directory -Path $outboxDir -Force | Out-Null }

    $ts   = Get-Date -Format "yyyyMMdd_HHmmss"
    $rand = [System.IO.Path]::GetRandomFileName().Replace(".", "").Substring(0, 4)
    $taskId = "autotest_${ts}_${rand}"

    $payload = [ordered]@{
        task_id           = $taskId
        target            = $TargetAgent
        target_agent      = $TargetAgent
        sender            = "git-labor-autotest"
        source            = "git-labor-autotest"
        issued_by         = $IssuedBy
        approved_by       = $IssuedBy
        execution_context = $WorkspaceContext
        priority          = 1
        origin            = "autonomous_test_runner"
        action            = $Action
        prompt            = $Prompt
        handshake         = $true
        created_at        = (Get-Date).ToUniversalTime().ToString("o")
    }
    foreach ($k in $ExtraFields.Keys) {
        $payload[$k] = $ExtraFields[$k]
    }

    if ($DryRun) {
        Write-Host "[DRY-RUN] @$TargetAgent <- $Action ($taskId)" -ForegroundColor DarkCyan
        return [pscustomobject]@{
            task_id          = $taskId
            status           = "DryRun"
            exit_code        = 0
            duration_seconds = 0
            output           = ($payload | ConvertTo-Json -Depth 5 -Compress)
        }
    }

    $taskFile = Join-Path $inboxDir "$taskId.json"
    [System.IO.File]::WriteAllText($taskFile, ($payload | ConvertTo-Json -Depth 6), ([System.Text.UTF8Encoding]::new($false)))
    Write-Host "[->] @$TargetAgent | Action=$Action | Task=$taskId" -ForegroundColor Cyan

    $resultFile = Join-Path $outboxDir "result_$taskId.json"
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt $WaitSec) {
        if (Test-Path $resultFile) {
            Start-Sleep -Milliseconds 250
            try {
                $raw = Get-Content -Path $resultFile -Raw -Encoding UTF8 -ErrorAction Stop
                if ($raw -and $raw.Trim().Length -gt 2) {
                    $obj = $raw | ConvertFrom-Json -ErrorAction Stop
                    if ($obj -and $obj.status) {
                        Write-Host "[<-] @$TargetAgent | Status=$($obj.status) | $([math]::Round($sw.Elapsed.TotalSeconds, 1))s" -ForegroundColor Green
                        return $obj
                    }
                }
            } catch {}
        }
        Start-Sleep -Seconds 1
    }

    throw "Timeout nach ${WaitSec}s beim Warten auf $resultFile"
}

function Get-HostMissingCar {
    param([string[]]$SandboxCars)

    # 1. Host-Autos ueber bekannten SMB/Local-Pfad oder @rig ListContent ermitteln
    $hostCars = @()
    $candidateHostPaths = @(
        "\\$SimRacerHost\D$\SteamLibrary\steamapps\common\assettocorsa\content\cars",
        "\\$SimRacerHost\C$\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\cars"
    )
    foreach ($p in $candidateHostPaths) {
        if (Test-Path $p) {
            $hostCars = @(Get-ChildItem -Path $p -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name | Sort-Object)
            if ($hostCars.Count -gt 0) { break }
        }
    }

    if ($hostCars.Count -eq 0) {
        # Fallback: @rig ListContent fragen
        $rigRes = Invoke-SimAgentDirectTask -TargetAgent "rig" -Action "ListContent" -WaitSec 45
        if ($rigRes.output) {
            $matches = [regex]::Matches([string]$rigRes.output, '(?m)^\s*Cars.*?:\s*(.+)$')
            if ($matches.Count -gt 0) {
                $hostCars = @($matches[0].Groups[1].Value -split ',\s*' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            }
        }
    }

    $sandboxSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($sc in $SandboxCars) { if ($sc) { [void]$sandboxSet.Add($sc.Trim()) } }

    foreach ($hc in $hostCars) {
        if (-not $sandboxSet.Contains($hc)) {
            return $hc
        }
    }
    return ""
}

try {
    Write-Host "`n=== Autonomer Sandbox- & Trainingssession-Testablauf ($RunStamp) ===" -ForegroundColor Cyan

    # --- PHASE 0: Pre-Flight & Policy-Gate ---
    $p0Sw = [System.Diagnostics.Stopwatch]::StartNew()
    if (-not (Test-Path $AgentsRoot)) {
        throw "SimRacer Agenten-Share nicht erreichbar: $AgentsRoot"
    }
    if (Test-Path $PolicyFile) {
        $pol = Get-Content -Path $PolicyFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not $DryRun) {
            if ($pol.agents_paused -eq $true) {
                throw "Pitwall Global-Gate ist PAUSIERT (agents_paused=true in $PolicyFile). Bitte auf Pitwall freigeben."
            }
            if ($pol.mode -and "$($pol.mode)".ToUpper() -ne "AUTO" -and "$($pol.mode)".ToUpper() -ne "DELEGATED") {
                Write-Warning "Pitwall-Modus ist '$($pol.mode)'. Fuer komplett autonome Ausfuehrung empfiehlt sich 'AUTO' (Send-SimAgentTask.ps1 -SetApprovalMode AUTO)."
            }
        }
        Add-PhaseResult -Phase "0. Pre-Flight & Policy" -Agent "pitwall" -TaskId "-" -Status "OK" -DurationSec $p0Sw.Elapsed.TotalSeconds -Details "Mode=$($pol.mode), Paused=$($pol.agents_paused)"
    } else {
        Add-PhaseResult -Phase "0. Pre-Flight & Policy" -Agent "pitwall" -TaskId "-" -Status "WARN" -DurationSec $p0Sw.Elapsed.TotalSeconds -Details "PolicyFile nicht gefunden"
    }

    # --- PHASE 1: Docker Sandbox starten & Container-Laufzeit pruefen ---
    $p1Sw = [System.Diagnostics.Stopwatch]::StartNew()
    $rigStatus = Invoke-SimAgentDirectTask -TargetAgent "rig" -Action "Status" -WaitSec 60
    $containerRunning = ($rigStatus.output -match "(?i)ac-win11-sandbox.*(running|Up|aktiv)") -or $DryRun

    if (-not $containerRunning) {
        Write-Host "[*] Docker-Sandbox scheint gestoppt -> beauftrage @light mit Start der Docker-Sandbox..." -ForegroundColor Yellow
        $startRes = Invoke-SimAgentDirectTask -TargetAgent "light" -Action "ProcessPrompt" `
            -Prompt "Starte die Docker Sandbox ac-win11-sandbox und pruefe den Status von @dark in der Sandbox." `
            -WaitSec ([Math]::Max($TimeoutSeconds, 180))
        if ($startRes.status -in @("Failed", "VerificationFailed", "Blocked", "Rejected")) {
            throw "Docker-Sandbox Start via @light fehlgeschlagen: $($startRes.output)"
        }
        Add-PhaseResult -Phase "1. Docker Sandbox Start" -Agent "light" -TaskId $startRes.task_id -Status $startRes.status -DurationSec $p1Sw.Elapsed.TotalSeconds -Details "Container gestartet & @dark Handshake"
    } else {
        Add-PhaseResult -Phase "1. Docker Sandbox Start" -Agent "rig" -TaskId $rigStatus.task_id -Status $rigStatus.status -DurationSec $p1Sw.Elapsed.TotalSeconds -Details "Container ac-win11-sandbox laeuft bereits"
    }

    # --- PHASE 2: @dark Start & Handshake verifizieren ---
    $p2Sw = [System.Diagnostics.Stopwatch]::StartNew()
    $darkStatus = Invoke-SimAgentDirectTask -TargetAgent "dark" -Action "Status" -WaitSec $TimeoutSeconds
    if ($darkStatus.status -in @("Failed", "VerificationFailed")) {
        throw "@dark Status-Check fehlgeschlagen: $($darkStatus.output)"
    }
    Add-PhaseResult -Phase "2. @dark Readiness" -Agent "dark" -TaskId $darkStatus.task_id -Status $darkStatus.status -DurationSec $p2Sw.Elapsed.TotalSeconds -Details "@dark antwortet in der Sandbox"

    # --- PHASE 3: Fehlendes Auto ermitteln, vom Host SimRacer uebertragen & installieren ---
    $p3Sw = [System.Diagnostics.Stopwatch]::StartNew()
    $darkListBefore = Invoke-SimAgentDirectTask -TargetAgent "dark" -Action "ListContent" -WaitSec 60
    $sandboxCars = @()
    $sandboxTracks = @()
    if ($darkListBefore.output -match "(?m)Gast Autos \(\d+\):\s*(.+)$") {
        $sandboxCars = @($Matches[1] -split ',\s*' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }
    if ($darkListBefore.output -match "(?m)Gast Strecken \(\d+\):\s*(.+)$") {
        $sandboxTracks = @($Matches[1] -split ',\s*' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }

    $selectedCar = $Car
    if (-not $selectedCar) {
        if ($DryRun) {
            $selectedCar = "<auto-discovered-host-car>"
        } else {
            $selectedCar = Get-HostMissingCar -SandboxCars $sandboxCars
            if (-not $selectedCar) {
                throw "Konnte kein Auto auf Host SimRacer finden, das nicht bereits in der Sandbox installiert ist. Bitte -Car explizit angeben."
            }
        }
    }
    Write-Host "[*] Ausgewaehltes Fahrzeug (neu fuer Sandbox): $selectedCar" -ForegroundColor Yellow

    $provCars = @($selectedCar)
    $provTracks = @()
    if (-not $DryRun -and ($sandboxTracks -notcontains $Track)) {
        Write-Host "[*] Strecke '$Track' fehlt in Sandbox -> wird mit uebertragen." -ForegroundColor Yellow
        $provTracks = @($Track)
    }

    $provRes = Invoke-SimAgentDirectTask -TargetAgent "light" -Action "ProvideAcContent" `
        -ExtraFields @{ cars = $provCars; tracks = $provTracks } `
        -WaitSec $TimeoutSeconds
    if ($provRes.status -in @("Failed", "VerificationFailed")) {
        throw "ProvideAcContent fuer '$selectedCar' fehlgeschlagen: $($provRes.output)"
    }

    $darkListAfter = Invoke-SimAgentDirectTask -TargetAgent "dark" -Action "ListContent" -ExtraFields @{ target_arg = $selectedCar } -WaitSec 60
    if (-not $DryRun -and ($darkListAfter.output -notmatch [regex]::Escape($selectedCar))) {
        throw "Verifikation fehlgeschlagen: '$selectedCar' erscheint nach Sync nicht in @dark ListContent!"
    }
    Add-PhaseResult -Phase "3. Auto Transfer & Install" -Agent "light->dark" -TaskId $provRes.task_id -Status $provRes.status -DurationSec $p3Sw.Elapsed.TotalSeconds -Details "Car=$selectedCar uebertragen & verifiziert"

    # --- PHASE 4: Strecke auswaehlen & Trainingssession starten ---
    $p4Sw = [System.Diagnostics.Stopwatch]::StartNew()
    $setSessRes = Invoke-SimAgentDirectTask -TargetAgent "dark" -Action "SetSession" `
        -ExtraFields @{ car = $selectedCar; track = $Track; target_arg = "car=$selectedCar;track=$Track" } `
        -WaitSec 90
    if ($setSessRes.status -in @("Failed", "VerificationFailed")) {
        throw "SetSession ($selectedCar @ $Track) fehlgeschlagen: $($setSessRes.output)"
    }

    $launchRes = Invoke-SimAgentDirectTask -TargetAgent "dark" -Action "LaunchSession" `
        -Prompt "Starte Trainingssession (Practice) mit $selectedCar auf $Track" `
        -ExtraFields @{ car = $selectedCar; track = $Track; target_arg = "practice" } `
        -WaitSec $TimeoutSeconds
    if ($launchRes.status -in @("Failed", "VerificationFailed")) {
        throw "LaunchSession fehlgeschlagen: $($launchRes.output)"
    }

    $postStatus = Invoke-SimAgentDirectTask -TargetAgent "dark" -Action "Status" -WaitSec 60
    Add-PhaseResult -Phase "4. Strecke & Trainingssession" -Agent "dark" -TaskId $launchRes.task_id -Status $launchRes.status -DurationSec $p4Sw.Elapsed.TotalSeconds -Details "Session: $selectedCar @ $Track (Practice)"

    Write-Host "`n[+] Testablauf erfolgreich abgeschlossen in $([math]::Round($TestSw.Elapsed.TotalSeconds, 1))s!" -ForegroundColor Green
}
catch {
    Add-PhaseResult -Phase "FEHLER" -Agent "-" -TaskId "-" -Status "Failed" -DurationSec $TestSw.Elapsed.TotalSeconds -Details $_.Exception.Message
    Write-Error $_.Exception.Message
}
finally {
    $md = [System.Collections.Generic.List[string]]::new()
    $md.Add("# Autonomer Sandbox-Testbericht (``$RunStamp``)")
    $md.Add("")
    $md.Add("- **SimRacer Host:** ``$SimRacerHost``")
    $md.Add("- **DryRun:** ``$DryRun``")
    $md.Add("- **Gesamtdauer:** $([math]::Round($TestSw.Elapsed.TotalSeconds, 2)) s")
    $md.Add("")
    $md.Add("| Phase | Agent | Task-ID | Status | Dauer (s) | Details |")
    $md.Add("| :--- | :--- | :--- | :--- | ---: | :--- |")
    foreach ($p in $Phases) {
        $det = ([string]$p.Details) -replace '\|', '/' -replace "`r?`n", ' '
        $md.Add("| $($p.Phase) | $($p.Agent) | ``$($p.TaskId)`` | **$($p.Status)** | $($p.DurationSec) | $det |")
    }
    $md | Set-Content -Path $ReportPath -Encoding UTF8
    Write-Host "[i] Bericht gespeichert: $ReportPath" -ForegroundColor Cyan
}
