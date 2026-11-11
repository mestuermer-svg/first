Write-Host "=== CSP & CM & AC Environment Check ===" -ForegroundColor Cyan

# 1. Custom Shaders Patch Files
$dwrite = "C:\AssettoCorsa\dwrite.dll"
$extDir = "C:\AssettoCorsa\extension"
Write-Host "dwrite.dll (CSP Core Hook): $(Test-Path $dwrite)" -ForegroundColor $(if (Test-Path $dwrite) { "Green" } else { "Red" })
Write-Host "extension directory:        $(Test-Path $extDir)" -ForegroundColor $(if (Test-Path $extDir) { "Green" } else { "Red" })

if (Test-Path $dwrite) {
    $ver = (Get-Item $dwrite).VersionInfo.ProductVersion
    Write-Host "CSP Version in dwrite.dll:  $ver" -ForegroundColor Yellow
}

# 2. Content Manager
$cm = "C:\AssettoCorsa\Content Manager.exe"
Write-Host "Content Manager.exe:        $(Test-Path $cm)" -ForegroundColor $(if (Test-Path $cm) { "Green" } else { "Red" })
$cmProc = Get-Process -Name "Content Manager" -ErrorAction SilentlyContinue
Write-Host "Content Manager Process:    $(if ($cmProc) { "Running (PID $($cmProc.Id))" } else { "Stopped" })" -ForegroundColor Cyan

# 3. Assetto Corsa Configs
$docAC = "$env:USERPROFILE\Documents\Assetto Corsa"
$raceIni = "$docAC\cfg\race.ini"
$videoIni = "$docAC\cfg\video.ini"
$cspGeneral = "$docAC\cfg\extension\general.ini"

Write-Host "race.ini exists:            $(Test-Path $raceIni)" -ForegroundColor $(if (Test-Path $raceIni) { "Green" } else { "Red" })
Write-Host "video.ini exists:           $(Test-Path $videoIni)" -ForegroundColor $(if (Test-Path $videoIni) { "Green" } else { "Red" })
Write-Host "CSP general.ini:            $(Test-Path $cspGeneral)" -ForegroundColor $(if (Test-Path $cspGeneral) { "Green" } else { "Red" })

# 4. acs.exe process
$acsProc = Get-Process -Name "acs", "acs_x86" -ErrorAction SilentlyContinue
Write-Host "acs.exe Simulation Process: $(if ($acsProc) { "Running (PID $($acsProc.Id -join ', '))" } else { "Stopped" })" -ForegroundColor $(if ($acsProc) { "Green" } else { "DarkGray" })
