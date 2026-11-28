<#
.SYNOPSIS
    Prüft Assetto Corsa & CSP VR-Invarianten schreibgeschützt (Read-Only) gegen die SimRacer-Konfiguration.
.EXAMPLE
    .\Check-VrInvariants.ps1
    .\Check-VrInvariants.ps1 -CfgRoot "\\192.168.178.68\C$\Users\Mike\Documents\Assetto Corsa\cfg" -Json
#>
[CmdletBinding()]
param(
    [string]$CfgRoot = "\\192.168.178.68\C$\Users\Mike\Documents\Assetto Corsa\cfg",
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-IniMap {
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    $section = "_ROOT"
    $map[$section] = @{}
    foreach ($rawLine in Get-Content -LiteralPath $Path -Encoding UTF8) {
        $line = $rawLine.Trim()
        if (-not $line -or $line.StartsWith(";") -or $line.StartsWith("#")) {
            continue
        }
        if ($line -match '^\[(.+)\]$') {
            $section = $matches[1].Trim()
            if (-not $map.ContainsKey($section)) {
                $map[$section] = @{}
            }
            continue
        }
        if ($line -match '^([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            $map[$section][$key] = $val
        }
    }
    return $map
}

function Get-IniVal {
    param($IniMap, [string]$Section, [string]$Key)
    if ($null -eq $IniMap) { return $null }
    if ($IniMap.ContainsKey($Section) -and $IniMap[$Section].ContainsKey($Key)) {
        return $IniMap[$Section][$Key]
    }
    return $null
}

if (-not (Test-Path -LiteralPath $CfgRoot)) {
    Write-Error "CfgRoot nicht erreichbar: $CfgRoot"
    exit 1
}

$videoIni = Read-IniMap (Join-Path $CfgRoot "video.ini")
$vrTweaksIni = Read-IniMap (Join-Path $CfgRoot "extension\vr_tweaks.ini")
$gfxAdjIni = Read-IniMap (Join-Path $CfgRoot "extension\graphics_adjustments.ini")
$grassFxIni = Read-IniMap (Join-Path $CfgRoot "extension\grass_fx.ini")

$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param(
        [string]$File,
        [string]$Section,
        [string]$Key,
        [string]$Actual,
        [string]$Expected,
        [string]$Status,
        [string]$Note
    )
    $checks.Add([pscustomobject]@{
        File     = $File
        Section  = $Section
        Key      = $Key
        Actual   = if ($null -eq $Actual) { "<missing>" } else { $Actual }
        Expected = $Expected
        Status   = $Status
        Note     = $Note
    })
}

# 1. video.ini Checks
$camMode = Get-IniVal $videoIni "CAMERA" "MODE"
Add-Check "video.ini" "CAMERA" "MODE" $camMode "OPENVR" ($(if ($camMode -eq "OPENVR") { "OK" } else { "WARN" })) "OpenVR-Ausgabe für HTC VIVE Focus Vision"

$ppFilter = Get-IniVal $videoIni "POST_PROCESS" "FILTER"
Add-Check "video.ini" "POST_PROCESS" "FILTER" $ppFilter "pureVR" ($(if ($ppFilter -eq "pureVR") { "OK" } else { "WARN" })) "VR-kalibrierter Pure-Filter"

$dof = Get-IniVal $videoIni "POST_PROCESS" "DOF"
Add-Check "video.ini" "POST_PROCESS" "DOF" $dof "0" ($(if ($dof -eq "0") { "OK" } else { "WARN" })) "Tiefenunschärfe in VR aus Kosten-/Komfortgründen aus"

$motionBlur = Get-IniVal $videoIni "EFFECTS" "MOTION_BLUR"
Add-Check "video.ini" "EFFECTS" "MOTION_BLUR" $motionBlur "0" ($(if ($motionBlur -eq "0") { "OK" } else { "WARN" })) "Bewegungsunschärfe in VR deaktiviert"

$smokeMirror = Get-IniVal $videoIni "EFFECTS" "RENDER_SMOKE_IN_MIRROR"
Add-Check "video.ini" "EFFECTS" "RENDER_SMOKE_IN_MIRROR" $smokeMirror "0" ($(if ($smokeMirror -eq "0") { "OK" } else { "WARN" })) "Spart doppeltes Partikel-Rendering im Rückspiegel"

$mirrorHq = Get-IniVal $videoIni "MIRROR" "HQ"
Add-Check "video.ini" "MIRROR" "HQ" $mirrorHq "0" ($(if ($mirrorHq -eq "0") { "OK" } else { "WARN" })) "Standard-Spiegelauflösung hält Frametimes im 90-Hz-Budget"

$shadowSize = Get-IniVal $videoIni "VIDEO" "SHADOW_MAP_SIZE"
$shadowOk = ($null -ne $shadowSize) -and ([int]$shadowSize -le 1024)
Add-Check "video.ini" "VIDEO" "SHADOW_MAP_SIZE" $shadowSize "<= 1024" ($(if ($shadowOk) { "OK" } else { "WARN" })) "Begrenzt GPU-Schattenlast (aktuell 512 auf SimRacer)"

# 2. extension\vr_tweaks.ini Checks
if ($null -eq $vrTweaksIni) {
    Add-Check "extension\vr_tweaks.ini" "*" "*" $null "vorhanden" "FAIL" "CSP VR Tweaks Datei fehlt"
} else {
    $spsEnabled = Get-IniVal $vrTweaksIni "SINGLE_PASS_STEREO" "ENABLED"
    $vrsRate = Get-IniVal $vrTweaksIni "SINGLE_PASS_STEREO" "VRS_RATE"
    $spsStatus = if ($spsEnabled -eq "0") { "FAIL" } elseif ($null -ne $vrsRate -and [int]$vrsRate -ge 1) { "OK" } else { "WARN" }
    Add-Check "extension\vr_tweaks.ini" "SINGLE_PASS_STEREO" "VRS_RATE" $vrsRate ">= 1 (Standard/2)" $spsStatus "Single Pass Stereo + Variable Rate Shading aktiv"

    $vrHud = Get-IniVal $vrTweaksIni "VR_HUD" "ENABLED"
    Add-Check "extension\vr_tweaks.ini" "VR_HUD" "ENABLED" $vrHud "1" ($(if ($vrHud -eq "1") { "OK" } else { "WARN" })) "VR-HUD Lesbarkeit"
}

# 3. extension\graphics_adjustments.ini Checks
if ($null -eq $gfxAdjIni) {
    Add-Check "extension\graphics_adjustments.ini" "*" "*" $null "vorhanden" "FAIL" "CSP Graphics Adjustments fehlt"
} else {
    $sfEnabled = Get-IniVal $gfxAdjIni "SCRIPTABLE_FILTER" "ENABLED"
    $sfImpl = Get-IniVal $gfxAdjIni "SCRIPTABLE_FILTER" "IMPLEMENTATION"
    $sfOk = ($sfEnabled -eq "1") -and ($sfImpl -eq "pure")
    Add-Check "extension\graphics_adjustments.ini" "SCRIPTABLE_FILTER" "IMPLEMENTATION" "$sfImpl (ENABLED=$sfEnabled)" "pure (ENABLED=1)" ($(if ($sfOk) { "OK" } else { "WARN" })) "Pure Scriptable Filter aktiv"

    $visMirror = Get-IniVal $gfxAdjIni "VISIBLE_CARS" "MIRROR"
    Add-Check "extension\graphics_adjustments.ini" "VISIBLE_CARS" "MIRROR" $visMirror "gesetzt (z. B. 1,3,7,12)" ($(if ($visMirror) { "OK" } else { "WARN" })) "Begrenzt gerenderte Fahrzeuge im Rückspiegel"

    $ffxCas = Get-IniVal $gfxAdjIni "ANTIALIASING" "FFXCAS_PASS"
    Add-Check "extension\graphics_adjustments.ini" "ANTIALIASING" "FFXCAS_PASS" $ffxCas "1" ($(if ($ffxCas -eq "1") { "OK" } else { "WARN" })) "FidelityFX CAS Schärfe-Pass für VR-Linsen"
}

# 4. extension\grass_fx.ini Checks
if ($null -eq $grassFxIni) {
    Add-Check "extension\grass_fx.ini" "BASIC" "QUALITY" $null "<= 4" "WARN" "grass_fx.ini nicht gefunden"
} else {
    $grassQ = Get-IniVal $grassFxIni "BASIC" "QUALITY"
    $grassOk = ($null -ne $grassQ) -and ([int]$grassQ -le 4)
    Add-Check "extension\grass_fx.ini" "BASIC" "QUALITY" $grassQ "<= 4" ($(if ($grassOk) { "OK" } else { "WARN" })) "Gras-Detailgrad im VR-Budget halten"
}

$failCount = ($checks | Where-Object { $_.Status -eq "FAIL" } | Measure-Object).Count
$warnCount = ($checks | Where-Object { $_.Status -eq "WARN" } | Measure-Object).Count
$okCount   = ($checks | Where-Object { $_.Status -eq "OK" }   | Measure-Object).Count

if ($Json) {
    [pscustomobject]@{
        cfg_root = $CfgRoot
        summary  = @{ ok = $okCount; warn = $warnCount; fail = $failCount }
        checks   = $checks
    } | ConvertTo-Json -Depth 5
} else {
    Write-Output "VR-Invarianten-Check (Read-Only): $CfgRoot"
    $checks | Format-Table -Property File, Section, Key, Actual, Expected, Status -AutoSize | Out-String | Write-Output
    Write-Output "Ergebnis: OK=$okCount | WARN=$warnCount | FAIL=$failCount"
}

if ($failCount -gt 0) { exit 1 }
exit 0
