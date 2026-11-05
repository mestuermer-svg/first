# 1. Expand C: partition to 160 GB using diskpart (non-blocking)
Write-Host "[1/4] Expanding partition C: to 160 GB via diskpart..." -ForegroundColor Cyan
$dpFile = "$env:TEMP\expand_c.txt"
@("rescan", "select volume C", "extend") | Set-Content -Path $dpFile -Encoding Ascii
diskpart /s $dpFile

# 2. Check / Install OpenSSH Server (sshd)
Write-Host "[2/4] Checking OpenSSH Server (sshd)..." -ForegroundColor Cyan
$sshd = Get-Service -Name sshd -ErrorAction SilentlyContinue
if (-not $sshd) {
    Write-Host "      Installing OpenSSH from local MSI..." -ForegroundColor Yellow
    Copy-Item "\\host.lan\Data\OpenSSH.msi" "$env:TEMP\OpenSSH.msi" -Force
    Start-Process msiexec.exe -ArgumentList "/i `"$env:TEMP\OpenSSH.msi`" /qn" -Wait
}
if (Get-Service -Name sshd -ErrorAction SilentlyContinue) {
    Set-Service -Name sshd -StartupType Automatic
    Start-Service -Name sshd
    Write-Host "      sshd service is RUNNING!" -ForegroundColor Green
}
if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName "OpenSSH Server (sshd)" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
}

# 3. Configure SSH Authorized Keys
Write-Host "[3/4] Configuring SSH Authorized Keys..." -ForegroundColor Cyan
$pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhN9mutI5MJ/+URm1erUnhx4aHC9v4wuYyIc1EycWfu strik@VanstrikeCyborg"
$sshProgData = "C:\ProgramData\ssh"
if (Test-Path $sshProgData) {
    $adminKeys = Join-Path $sshProgData "administrators_authorized_keys"
    Set-Content -Path $adminKeys -Value $pubKey -Encoding Ascii -Force
    icacls.exe $adminKeys /inheritance:r /grant "SYSTEM:(F)" /grant "*S-1-5-32-544:(F)" | Out-Null
}
$userSshDir = Join-Path $env:USERPROFILE ".ssh"
New-Item -ItemType Directory -Path $userSshDir -Force | Out-Null
Set-Content -Path (Join-Path $userSshDir "authorized_keys") -Value $pubKey -Encoding Ascii -Force

# 4. Create & Sync AC/CM directories from \\host.lan\Data\cm-github-sync & write status report
Write-Host "[4/4] Provisioning AC & Content Manager ENGINEERING workspace in Guest..." -ForegroundColor Cyan
$SyncRoot = "\\host.lan\Data\cm-github-sync"
$DocAC    = "$env:USERPROFILE\Documents\Assetto Corsa"
$AcSetups = "$DocAC\setups"
$AcCfg    = "$DocAC\cfg"
$CmAppDir = "$env:LOCALAPPDATA\AcTools Content Manager"
$AcRoot   = "C:\AssettoCorsa"

foreach ($d in @($AcSetups, $AcCfg, $CmAppDir, "$AcRoot\cfg", "$AcRoot\system\cfg", "$AcRoot\server\cfg", "$AcRoot\apps\python", "$AcRoot\extension")) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
}

if (Test-Path $SyncRoot) {
    robocopy "$SyncRoot\01_Documents_AC_Setups" $AcSetups /E /MT:16 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    robocopy "$SyncRoot\02_Documents_AC_Cfg" $AcCfg /E /MT:16 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    robocopy "$SyncRoot\03_CM_AppData_Presets_Data\Presets" "$CmAppDir\Presets" /E /MT:16 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    robocopy "$SyncRoot\03_CM_AppData_Presets_Data\Online Servers" "$CmAppDir\Online Servers" /E /MT:16 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    Get-ChildItem "$SyncRoot\03_CM_AppData_Presets_Data\*.data" -ErrorAction SilentlyContinue | Copy-Item -Destination $CmAppDir -Force
    robocopy "$SyncRoot\04_Steam_AC_Cfg\cfg" "$AcRoot\cfg" /E /MT:16 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    robocopy "$SyncRoot\04_Steam_AC_Cfg\system_cfg" "$AcRoot\system\cfg" /E /MT:16 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    robocopy "$SyncRoot\04_Steam_AC_Cfg\server_cfg" "$AcRoot\server\cfg" /E /MT:16 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    robocopy "$SyncRoot\05_Steam_AC_Apps_Python" "$AcRoot\apps\python" /E /MT:16 /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    if (Test-Path "$SyncRoot\07_Content_Manager_Binary\Content Manager.exe") {
        Copy-Item "$SyncRoot\07_Content_Manager_Binary\Content Manager.exe" "$AcRoot\Content Manager.exe" -Force
        Copy-Item "$SyncRoot\07_Content_Manager_Binary\Content Manager.exe" "$env:USERPROFILE\Desktop\Content Manager.exe" -Force
    }
}

# Register startup script so sshd & status are always active after container boot
$startupBat = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ac-sandbox-bootstrap.bat"
if (Test-Path "\\host.lan\Data\bootstrap.bat") {
    Copy-Item "\\host.lan\Data\bootstrap.bat" $startupBat -Force
}

$cDrive = Get-PSDrive -Name C
$sshdAfter = Get-Service -Name sshd -ErrorAction SilentlyContinue
$setupFiles = @(Get-ChildItem $AcSetups -Recurse -File -ErrorAction SilentlyContinue)
$cfgFiles   = @(Get-ChildItem $AcCfg -Recurse -File -ErrorAction SilentlyContinue)
$cmPresets  = @(Get-ChildItem "$CmAppDir\Presets" -Recurse -File -ErrorAction SilentlyContinue)
$pyApps     = @(Get-ChildItem "$AcRoot\apps\python" -Directory -ErrorAction SilentlyContinue)

$statusObj = [ordered]@{
    timestamp             = (Get-Date -Format "o")
    agent                 = "Light Agent"
    mode                  = "ENGINEERING"
    computer_name         = $env:COMPUTERNAME
    user_name             = $env:USERNAME
    os_version            = [System.Environment]::OSVersion.VersionString
    c_drive_total_gb      = [math]::Round(($cDrive.Used + $cDrive.Free) / 1GB, 2)
    c_drive_free_gb       = [math]::Round($cDrive.Free / 1GB, 2)
    c_drive_used_gb       = [math]::Round($cDrive.Used / 1GB, 2)
    sshd_status           = if ($sshdAfter) { $sshdAfter.Status.ToString() } else { "NotInstalled" }
    host_lan_data_ok      = (Test-Path "\\host.lan\Data")
    d_backups_ok          = (Test-Path "\\host.lan\Data\D_Backups")
    d_steamlib_ok         = (Test-Path "\\host.lan\Data\D_SteamLibrary")
    native_ac_cfg_ok      = (Test-Path "\\host.lan\Data\Native_AC_cfg")
    cm_github_sync_ok     = (Test-Path "\\host.lan\Data\cm-github-sync")
    ac_documents_cfg_ok   = (Test-Path $AcCfg)
    ac_documents_setups_ok= (Test-Path $AcSetups)
    cm_appdata_ok         = (Test-Path $CmAppDir)
    cm_exe_guest_ok       = (Test-Path "$AcRoot\Content Manager.exe")
    cm_exe_desktop_ok     = (Test-Path "$env:USERPROFILE\Desktop\Content Manager.exe")
    synced_counts         = [ordered]@{
        setup_ini_files   = $setupFiles.Count
        ac_cfg_files      = $cfgFiles.Count
        cm_preset_files   = $cmPresets.Count
        python_apps       = $pyApps.Count
    }
}
$jsonPath = "$env:TEMP\guest-status.json"
$statusObj | ConvertTo-Json -Depth 4 | Set-Content -Path $jsonPath -Encoding UTF8
Copy-Item -Path $jsonPath -Destination "\\host.lan\Data\guest-status.json" -Force
Write-Host "=== ALL DONE! C: Total = $($statusObj.c_drive_total_gb) GB, Free = $($statusObj.c_drive_free_gb) GB, sshd = $($statusObj.sshd_status) ===" -ForegroundColor Green
