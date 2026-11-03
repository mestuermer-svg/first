<#
.SYNOPSIS
    Erweitert innerhalb der Windows-11-Docker-Sandbox (Gast-System) die Partition C:
    automatisch auf die volle neue Festplattengröße (nach Erhöhung von DISK_SIZE in docker-compose.yml).

.DESCRIPTION
    Wenn in der docker-compose.yml auf dem SimRacer z. B. DISK_SIZE: "160G" (statt "64G") gesetzt wird,
    vergrößert QEMU/dockurr beim Container-Start die virtuelle Festplatte (data.img).
    Dieses Skript wird INNERHALB der Windows-11-Sandbox als Administrator ausgeführt und erweitert
    die NTFS-Systempartition C: ohne Datenverlust und ohne Neustart auf das neue Maximum.
#>

$ErrorActionPreference = "Stop"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Windows 11 Gast-Partition C: auf neue DISK_SIZE erweitern" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Prüfen, ob Administratorrechte vorliegen
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Starte Skript mit Administratorrechten neu..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$volBefore = Get-Volume -DriveLetter C
$beforeGB  = [math]::Round($volBefore.Size / 1GB, 2)
Write-Host "[1/3] Aktuelle Größe von Laufwerk C: $beforeGB GB" -ForegroundColor Cyan

Write-Host "[2/3] Aktualisiere Datenträger-Layout (Update-Disk)..." -ForegroundColor Cyan
Get-Disk | ForEach-Object { Update-Disk -Number $_.Number }

$sizeInfo = Get-PartitionSupportedSize -DriveLetter C
$maxGB    = [math]::Round($sizeInfo.SizeMax / 1GB, 2)
Write-Host "      Maximal verfügbare Partitionsgröße: $maxGB GB" -ForegroundColor Green

if (($sizeInfo.SizeMax - $volBefore.Size) -lt 100MB) {
    Write-Host "[3/3] Laufwerk C: nutzt bereits die maximale Größe ($beforeGB GB). Keine Änderung nötig." -ForegroundColor Green
} else {
    Write-Host "[3/3] Erweitere Partition C: von $beforeGB GB auf $maxGB GB..." -ForegroundColor Yellow
    Resize-Partition -DriveLetter C -Size $sizeInfo.SizeMax
    $volAfter = Get-Volume -DriveLetter C
    $afterGB  = [math]::Round($volAfter.Size / 1GB, 2)
    $freeGB   = [math]::Round($volAfter.SizeRemaining / 1GB, 2)
    Write-Host "      ERFOLG! Neue Größe von C: $afterGB GB ($freeGB GB frei)." -ForegroundColor Green
}

Write-Host "=================================================================" -ForegroundColor Green
