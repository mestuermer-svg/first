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

# 4. Create AC/CM directories & write status report
Write-Host "[4/4] Creating AC/CM directories & writing status report..." -ForegroundColor Cyan
$acCfgDir = "$env:USERPROFILE\Documents\Assetto Corsa\cfg\setups"
$cmDir    = "$env:LOCALAPPDATA\AcTools Content Manager"
New-Item -ItemType Directory -Path $acCfgDir -Force | Out-Null
New-Item -ItemType Directory -Path $cmDir -Force | Out-Null

$cDrive = Get-PSDrive -Name C
$sshdAfter = Get-Service -Name sshd -ErrorAction SilentlyContinue
$statusObj = [ordered]@{
    timestamp        = (Get-Date -Format "o")
    computer_name    = $env:COMPUTERNAME
    user_name        = $env:USERNAME
    c_drive_total_gb = [math]::Round(($cDrive.Used + $cDrive.Free) / 1GB, 2)
    c_drive_free_gb  = [math]::Round($cDrive.Free / 1GB, 2)
    sshd_status      = if ($sshdAfter) { $sshdAfter.Status.ToString() } else { "NotInstalled" }
    d_backups_ok     = (Test-Path "\\host.lan\Data\D_Backups")
    d_steamlib_ok    = (Test-Path "\\host.lan\Data\D_SteamLibrary")
    native_ac_cfg_ok = (Test-Path "\\host.lan\Data\Native_AC_cfg")
}
$jsonPath = "$env:TEMP\guest-status.json"
$statusObj | ConvertTo-Json -Depth 4 | Set-Content -Path $jsonPath -Encoding UTF8
Copy-Item -Path $jsonPath -Destination "\\host.lan\Data\guest-status.json" -Force
Write-Host "=== ALL DONE! C: Total = $($statusObj.c_drive_total_gb) GB, Free = $($statusObj.c_drive_free_gb) GB, sshd = $($statusObj.sshd_status) ===" -ForegroundColor Green
