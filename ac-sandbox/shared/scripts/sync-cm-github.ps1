<#
.SYNOPSIS
    Synchronisiert Content Manager & Assetto Corsa Konfigurations-, Setup- und Skript-Ordner
    vom SimRacer (oder lokal) in das GitHub-Repository (ac-sandbox/shared/cm-github-sync)
    und laedt sie ordnerweise (einzeln pro Paket) zu GitHub hoch.

.DESCRIPTION
    Verhindert GitHub-Abbrueche ("File > 100 MB" / Spieldateien-Sperre), indem:
    1. Nur die 7 relevanten Engineering-, Setup-, Preset- und Skript-Ordner synchronisiert werden.
    2. Schwere 3D-Modelle (*.kn5), Texturen (*.dds), Soundbanks (*.bank), CEF-Browser-DLLs (Plugins/)
       und Patch-Archive (> 45 MB) strikt per Robocopy (/MAX:45000000) & .gitignore ausgeschlossen werden.
    3. Jeder der 7 Ordner in einem eigenen, sauberen Git-Commit + git push einzeln zu GitHub
       uebertragen wird (rechneruebergreifend nutzbar auf VanstrikeCyborg, SimRacer & Docker-Sandbox).
#>

param(
    [string]$SimRacerHost = "192.168.178.68",
    [string]$SimRacerUser = "Mike",
    [switch]$PushToGitHub,
    [switch]$RestoreToLocal
)

$ErrorActionPreference = "Continue"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$SyncRoot = Join-Path $RepoRoot "ac-sandbox\shared\cm-github-sync"

if (-not (Test-Path $SyncRoot)) {
    New-Item -ItemType Directory -Path $SyncRoot -Force | Out-Null
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Content Manager & Assetto Corsa -> GitHub Ordner-Sync" -ForegroundColor Cyan
Write-Host " Ziel im Repository: $SyncRoot" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$IsOnSimRacer = ($env:COMPUTERNAME -ieq "SimRacer")

$FolderPackages = @(
    @{
        Id          = "01_Documents_AC_Setups"
        Description = "Assetto Corsa Fahrzeug-Setups und Pitfiles (.ini)"
    },
    @{
        Id          = "02_Documents_AC_Cfg"
        Description = "Assetto Corsa Benutzer-Konfiguration (race.ini, controls.ini, video.ini, CSP)"
    },
    @{
        Id          = "03_CM_AppData_Presets_Data"
        Description = "Content Manager User-Presets, Steuerungs-/CSP-Profile und Daten"
    },
    @{
        Id          = "04_Steam_AC_Cfg"
        Description = "Steam Assetto Corsa Basis- und System-Cfg (cfg, system/cfg, server/cfg)"
    },
    @{
        Id          = "05_Steam_AC_Apps_Python"
        Description = "Steam Assetto Corsa Python-Apps (apps/python)"
    },
    @{
        Id          = "06_Steam_AC_Extension_Lua_Config"
        Description = "Custom Shaders Patch (CSP) Lua-Skripte und Configs (ohne 3D-Modelle .kn5)"
    },
    @{
        Id          = "07_Content_Manager_Binary"
        Description = "Content Manager Programmdatei (Content Manager.exe)"
    }
)

if ($RestoreToLocal) {
    Write-Host "[RESTORE] Stelle Content-Manager- und AC-Ordner aus dem Git-Repository auf diesem PC wieder her..." -ForegroundColor Cyan
    $DocAC = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Assetto Corsa"
    $AppCM = Join-Path $env:LOCALAPPDATA "AcTools Content Manager"
    robocopy "$SyncRoot\01_Documents_AC_Setups" "$DocAC\setups" /E /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    robocopy "$SyncRoot\02_Documents_AC_Cfg" "$DocAC\cfg" /E /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    robocopy "$SyncRoot\03_CM_AppData_Presets_Data" $AppCM /E /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    Write-Host "      [OK] Setups, AC-Cfg und Content Manager AppData-Profile wiederhergestellt!" -ForegroundColor Green
    return
}

$RemoteStageScript = @'
$ErrorActionPreference = "Continue"
$StageRoot = "C:\ac-sandbox\shared\cm-github-sync"
if (-not (Test-Path $StageRoot)) { New-Item -ItemType Directory -Path $StageRoot -Force | Out-Null }

robocopy "C:\Users\Mike\Documents\Assetto Corsa\setups" "$StageRoot\01_Documents_AC_Setups" /MIR /MAX:45000000 /XF *.kn5 *.bank *.dds *.zip /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
robocopy "C:\Users\Mike\Documents\Assetto Corsa\cfg" "$StageRoot\02_Documents_AC_Cfg" /MIR /MAX:45000000 /XD replays screens logs cache /XF *.kn5 *.bank *.dds *.zip *.log *.dmp /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
robocopy "C:\Users\Mike\AppData\Local\AcTools Content Manager" "$StageRoot\03_CM_AppData_Presets_Data" /MIR /MAX:45000000 /XD Plugins Temporary Static Logs Cache GPUCache cef CrashDumps /XF *.dll *.exe *.zip *.7z *.rar *.log *.dmp *.pak /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
robocopy "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\cfg" "$StageRoot\04_Steam_AC_Cfg\cfg" /MIR /MAX:45000000 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
robocopy "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\system\cfg" "$StageRoot\04_Steam_AC_Cfg\system_cfg" /MIR /MAX:45000000 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
robocopy "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\server\cfg" "$StageRoot\04_Steam_AC_Cfg\server_cfg" /MIR /MAX:45000000 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
robocopy "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\apps\python" "$StageRoot\05_Steam_AC_Apps_Python" /MIR /MAX:45000000 /XD __pycache__ .git /XF *.pyc *.zip /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
robocopy "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\extension\lua" "$StageRoot\06_Steam_AC_Extension_Lua_Config\lua" /MIR /MAX:45000000 /XF *.kn5 *.bank *.dds *.zip /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
robocopy "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\extension\config" "$StageRoot\06_Steam_AC_Extension_Lua_Config\config" /MIR /MAX:25000000 /XF *.kn5 *.bank *.dds *.zip *.png *.jpg /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
New-Item -ItemType Directory -Path "$StageRoot\07_Content_Manager_Binary" -Force | Out-Null
Copy-Item "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\Content Manager.exe" "$StageRoot\07_Content_Manager_Binary\Content Manager.exe" -Force
'@

if (-not $IsOnSimRacer) {
    Write-Host "[1/3] Bereite gefilterte Content-Manager-Pakete auf SimRacer ($SimRacerHost) vor..." -ForegroundColor Yellow
    $b64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($RemoteStageScript))
    ssh -o ConnectTimeout=5 "$SimRacerUser@$SimRacerHost" "powershell -NoProfile -EncodedCommand $b64"
    
    Write-Host "[2/3] Uebertrage die 7 Ordner-Pakete vom SimRacer (\\$SimRacerHost\ac-sandbox\shared\cm-github-sync) zum lokalen Repository..." -ForegroundColor Yellow
    foreach ($pkg in $FolderPackages) {
        $src = "\\$SimRacerHost\ac-sandbox\shared\cm-github-sync\$($pkg.Id)"
        $dst = Join-Path $SyncRoot $pkg.Id
        if (Test-Path $src) {
            robocopy $src $dst /MIR /MAX:45000000 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
            $files = Get-ChildItem $dst -Recurse -File -ErrorAction SilentlyContinue
            $mb = [math]::Round((($files | Measure-Object Length -Sum).Sum) / 1MB, 2)
            Write-Host ("      [OK] {0,-35} ({1,4} Dateien | {2,6} MB)" -f $pkg.Id, $files.Count, $mb) -ForegroundColor Green
        }
    }
} else {
    Invoke-Expression $RemoteStageScript
}

if ($PushToGitHub) {
    Write-Host "[3/3] Lade Ordner-Pakete einzeln (ordnerweise) zu GitHub hoch..." -ForegroundColor Cyan
    Push-Location $RepoRoot
    foreach ($pkg in $FolderPackages) {
        $relPath = "ac-sandbox/shared/cm-github-sync/$($pkg.Id)"
        git add $relPath
        $status = git status --porcelain $relPath
        if ($status) {
            Write-Host "      -> Commit & Push: $($pkg.Id) ($($pkg.Description))..." -ForegroundColor Yellow
            git commit -m "sync(cm): $($pkg.Id) - $($pkg.Description)" | Out-Null
            git push origin main
            if ($LASTEXITCODE -eq 0) {
                Write-Host "      [GITHUB OK] $($pkg.Id) erfolgreich hochgeladen!" -ForegroundColor Green
            } else {
                Write-Host "      [FEHLER] Push fuer $($pkg.Id) fehlgeschlagen!" -ForegroundColor Red
                break
            }
        } else {
            Write-Host "      [BEREITS AKTUELL] $($pkg.Id) (keine Aenderungen)" -ForegroundColor DarkGray
        }
    }
    Pop-Location
}
