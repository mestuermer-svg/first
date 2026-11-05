<#
.SYNOPSIS
    Stufe-2 Sekunden-Backup für SimRacer:
    Sichert Pitfiles (.ini), Content Manager & CSP, Fanatec-Profile & SteamVR-Settings
    nach D:\Backups\SimRacer_Configs\<Zeitstempel>.

.DESCRIPTION
    Kann sowohl direkt auf dem SimRacer als auch remote vom VanstrikeCyborg (Laptop)
    ausgeführt werden. Erkennt automatisch, ob es lokal auf dem SimRacer läuft oder
    über die Netzwerkfreigabe (\\192.168.178.68 / \\SimRacer) zugreift.
#>

param(
    [string]$SimRacerHost = "192.168.178.68",
    [string]$SimRacerUser = "Mike",
    [int]$KeepSnapshots   = 30
)

$ErrorActionPreference = "Continue"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

# Automatische Erkennung: Laufen wir direkt auf dem SimRacer oder remote vom VanstrikeCyborg?
if ($env:COMPUTERNAME -ieq "SimRacer" -or (Test-Path "C:\Users\$SimRacerUser\Documents\Assetto Corsa\cfg")) {
    $RootC = "C:"
    $RootD = "D:"
    $Mode  = "Lokal auf SimRacer"
} else {
    $RootC = "\\$SimRacerHost\C"
    $RootD = "\\$SimRacerHost\D"
    $Mode  = "Remote via LAN ($SimRacerHost)"
}

$BackupBase = "$RootD\Backups\SimRacer_Configs"
$BackupRoot = "$BackupBase\$Timestamp"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " SimRacer Stufe-2 Backup ($Mode)" -ForegroundColor Cyan
Write-Host " Ziel: $BackupRoot" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path "$BackupRoot\AC_cfg" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupRoot\ContentManager" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupRoot\Fanatec" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupRoot\SteamVR" | Out-Null

# 1. Assetto Corsa cfg & alle Pitfiles (.ini) sichern (ohne schwere Replays!)
$AcCfgSource = "$RootC\Users\$SimRacerUser\Documents\Assetto Corsa\cfg"
if (Test-Path $AcCfgSource) {
    robocopy $AcCfgSource "$BackupRoot\AC_cfg" /E /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null
    Write-Host "  [OK] Assetto Corsa cfg & Pitfiles (.ini) gesichert." -ForegroundColor Green
} else {
    Write-Host "  [WARN] Nicht gefunden: $AcCfgSource" -ForegroundColor Yellow
}

# 2. Content Manager & Custom Shaders Patch Settings (ohne temporären Cache)
$CmSource = "$RootC\Users\$SimRacerUser\AppData\Local\AcTools Content Manager"
if (Test-Path $CmSource) {
    robocopy $CmSource "$BackupRoot\ContentManager" /E /XD "Cache" "Temporary" "Logs" "cef" "GPUCache" /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null
    Write-Host "  [OK] Content Manager & CSP Profile gesichert." -ForegroundColor Green
} else {
    Write-Host "  [WARN] Nicht gefunden: $CmSource" -ForegroundColor Yellow
}

# 3. Fanatec / FanaLab Profile
$FanatecSource = "$RootC\Users\$SimRacerUser\AppData\Local\Fanatec"
if (Test-Path $FanatecSource) {
    robocopy $FanatecSource "$BackupRoot\Fanatec" /E /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null
    Write-Host "  [OK] Fanatec Wheel-Profile gesichert." -ForegroundColor Green
} else {
    Write-Host "  [WARN] Nicht gefunden: $FanatecSource" -ForegroundColor Yellow
}

# 4. SteamVR / HTC VIVE Focus Vision Settings
$SteamVrSettings = "$RootC\Program Files (x86)\Steam\config\steamvr.vrsettings"
if (Test-Path $SteamVrSettings) {
    Copy-Item -Path $SteamVrSettings -Destination "$BackupRoot\SteamVR\steamvr.vrsettings" -Force
    Write-Host "  [OK] SteamVR / VIVE Focus Vision Settings gesichert." -ForegroundColor Green
}

# 5. Alte Stände aufräumen (Behalte die letzten $KeepSnapshots Snapshots auf D:)
if (Test-Path $BackupBase) {
    Get-ChildItem $BackupBase -Directory |
        Where-Object { $_.Name -match "^\d{4}-\d{2}-\d{2}" } |
        Sort-Object CreationTime -Descending |
        Select-Object -Skip $KeepSnapshots |
        Remove-Item -Recurse -Force
}

Write-Host "=================================================================" -ForegroundColor Green
Write-Host " [Backup] Fertig! Snapshot abgelegt unter: $BackupRoot" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
