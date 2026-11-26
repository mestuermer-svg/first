<#
.SYNOPSIS
    Switch-LlmBackend.ps1 - Zentrale Schaltweiche zwischen lokalem Ollama und Google Gemini für alle Agenten.
.DESCRIPTION
    Liest oder schaltet das aktive KI-Backend (ollama | auto | gemini) und das Gemini-Modell
    zentral über die StrikerPi Pitwall-API (/api/approvals/policy -> pitwall_control_policy.json)
    mit automatischem SMB-Fallback direkt auf den SimRacer-Share.
.EXAMPLE
    .\Switch-LlmBackend.ps1
.EXAMPLE
    .\Switch-LlmBackend.ps1 -Backend gemini -GeminiModel gemini-3.8-flash
.EXAMPLE
    .\Switch-LlmBackend.ps1 -Agent rig -Backend ollama
.EXAMPLE
    .\Switch-LlmBackend.ps1 -Agent rig -Backend inherit
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("status", "ollama", "auto", "gemini", "inherit")]
    [string]$Backend = "status",

    [Parameter()]
    [ValidateSet("global", "general", "light", "rig", "dark", "sarah", "rick")]
    [string]$Agent = "global",

    [Parameter()]
    [string]$GeminiModel = "",

    [Parameter()]
    [string]$StrikerPiUrl = "http://192.168.178.86:8080",

    [Parameter()]
    [string]$SimRacerHost = "192.168.178.68"
)

$ErrorActionPreference = "Stop"
$BaseUrl = $StrikerPiUrl.TrimEnd("/")
$PolicyFile = "\\$SimRacerHost\ac-sandbox\shared\agents\general-SIM\pitwall_control_policy.json"
$KnownAgents = @("general", "light", "rig", "dark", "sarah", "rick")

function Show-LlmSwitchMatrix {
    param($StateObj, $LlmStatusObj)

    $pol = if ($StateObj -and $StateObj.policy) { $StateObj.policy } else { $StateObj }
    $globalMode = if ($pol.llm_backend) { ([string]$pol.llm_backend).ToLower() } else { "ollama" }
    $gModel = if ($pol.llm_gemini_model) { [string]$pol.llm_gemini_model } else { "gemini-3.8-flash" }
    $paused = [bool]($pol.agents_paused)
    $gpuAllowed = ($pol.gpu_background_allowed -ne $false)
    $gemReady = [bool]($LlmStatusObj -and $LlmStatusObj.gemini_ready)
    $gemKeyOk = [bool]($LlmStatusObj -and $LlmStatusObj.gemini_key_present)

    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  GIT-LABOR // ZENTRALE KI-SCHALTWEICHE (Lokales Ollama <-> Google Gemini)" -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
    $gCol = if ($globalMode -eq "gemini") { "Magenta" } elseif ($globalMode -eq "auto") { "Cyan" } else { "Green" }
    Write-Host ("  Globaler Modus : {0,-10} | Gemini-Modell : {1}" -f $globalMode.ToUpper(), $gModel) -ForegroundColor $gCol
    Write-Host ("  Gemini API     : {0,-10} | Verbund Pause : {1} | 5070 Ti BG: {2}" -f $(if ($gemReady) { "BEREIT" } elseif ($gemKeyOk) { "OFFLINE" } else { "KEIN KEY" }), $(if ($paused) { "JA" } else { "NEIN" }), $(if ($gpuAllowed) { "ERLAUBT" } else { "GESPERRT" })) -ForegroundColor Gray
    Write-Host ("  " + ("-" * 76)) -ForegroundColor DarkGray
    Write-Host ("  {0,-10} {1,-12} {2,-12} {3}" -f "Agent", "Override", "Effektiv", "Ziel-Endpunkt") -ForegroundColor DarkCyan
    Write-Host ("  " + ("-" * 76)) -ForegroundColor DarkGray

    foreach ($ag in $KnownAgents) {
        $ov = "inherit"
        if ($pol.agent_llm_backends -and $pol.agent_llm_backends.PSObject.Properties[$ag]) {
            $ov = ([string]$pol.agent_llm_backends.$ag).ToLower()
        }
        $eff = if ($ov -in @("ollama", "auto", "gemini")) { $ov } else { $globalMode }
        $targetDesc = switch ($eff) {
            "gemini" { "Google Gemini ($gModel) [0% GPU]" }
            "auto"   { "Ollama (5070 Ti -> Cyborg 5060) -> Fallback Gemini ($gModel)" }
            default  { "Lokal Ollama (SimRacer 5070 Ti -> Cyborg 5060)" }
        }
        $rowCol = if ($eff -eq "gemini") { "Magenta" } elseif ($eff -eq "auto") { "Cyan" } else { "Green" }
        Write-Host ("  @{0,-9} {1,-12} {2,-12} {3}" -f $ag, $ov, $eff.ToUpper(), $targetDesc) -ForegroundColor $rowCol
    }
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

$bk = $Backend.ToLower()
$ag = $Agent.ToLower()

if ($bk -ne "status" -or -not [string]::IsNullOrWhiteSpace($GeminiModel)) {
    if ($ag -eq "global" -and $bk -eq "inherit") {
        throw "'inherit' ist nur zusammen mit -Agent <general|light|rig|dark|sarah|rick> gueltig."
    }

    $body = @{}
    if ($bk -ne "status") {
        if ($ag -eq "global") {
            $body["llm_backend"] = $bk
        } else {
            $body["agent_llm_backends"] = @{ $ag = $bk }
        }
    }
    if (-not [string]::IsNullOrWhiteSpace($GeminiModel)) {
        $body["llm_gemini_model"] = $GeminiModel.Trim()
    }

    $updatedViaApi = $false
    try {
        $jsonBody = ($body | ConvertTo-Json -Depth 4 -Compress)
        $apiResp = Invoke-RestMethod -Uri "$BaseUrl/api/approvals/policy" -Method Post -ContentType "application/json; charset=utf-8" -Body ([Text.Encoding]::UTF8.GetBytes($jsonBody)) -TimeoutSec 12 -ErrorAction Stop
        $updatedViaApi = $true
        Write-Host "[+] Schaltweiche via Pitwall-API aktualisiert." -ForegroundColor Green
        Show-LlmSwitchMatrix -StateObj $apiResp -LlmStatusObj $apiResp.llm_status
        return
    } catch {
        Write-Warning "Pitwall-API nicht erreichbar ($($_.Exception.Message)); nutze direkten SMB-Fallback..."
    }

    if (-not $updatedViaApi) {
        if (-not (Test-Path $PolicyFile)) {
            throw "Weder Pitwall-API noch Policy-Datei erreichbar: $PolicyFile"
        }
        $pol = Get-Content -Path $PolicyFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($body.ContainsKey("llm_backend")) {
            $pol | Add-Member -MemberType NoteProperty -Name "llm_backend" -Value $body["llm_backend"] -Force
        }
        if ($body.ContainsKey("llm_gemini_model")) {
            $pol | Add-Member -MemberType NoteProperty -Name "llm_gemini_model" -Value $body["llm_gemini_model"] -Force
        }
        if ($body.ContainsKey("agent_llm_backends")) {
            $map = @{}
            if ($pol.agent_llm_backends) {
                foreach ($p in $pol.agent_llm_backends.PSObject.Properties) { $map[$p.Name] = [string]$p.Value }
            }
            foreach ($kv in $body["agent_llm_backends"].GetEnumerator()) { $map[$kv.Key] = $kv.Value }
            $pol | Add-Member -MemberType NoteProperty -Name "agent_llm_backends" -Value $map -Force
        }
        $pol | Add-Member -MemberType NoteProperty -Name "updated_at" -Value (Get-Date -Format "o") -Force
        $pol | Add-Member -MemberType NoteProperty -Name "updated_by" -Value "Switch-LlmBackend_CLI" -Force
        $tmp = "$PolicyFile.tmp"
        [System.IO.File]::WriteAllText($tmp, ($pol | ConvertTo-Json -Depth 10), ([System.Text.UTF8Encoding]::new($false)))
        Move-Item -Path $tmp -Destination $PolicyFile -Force
        Write-Host "[+] Schaltweiche via SMB-Fallback gespeichert: $PolicyFile" -ForegroundColor Green
    }
}

try {
    $st = Invoke-RestMethod -Uri "$BaseUrl/api/approvals/state?refresh=1" -TimeoutSec 6 -ErrorAction Stop
    Show-LlmSwitchMatrix -StateObj $st -LlmStatusObj $st.llm_status
} catch {
    if (Test-Path $PolicyFile) {
        $pol = Get-Content -Path $PolicyFile -Raw -Encoding UTF8 | ConvertFrom-Json
        Show-LlmSwitchMatrix -StateObj $pol -LlmStatusObj $null
    } else {
        throw "Weder Pitwall-API ($BaseUrl) noch SMB-Policy ($PolicyFile) erreichbar."
    }
}
