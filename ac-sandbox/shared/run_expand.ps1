Write-Host "--- DISK EXTENSION START ---" -ForegroundColor Cyan
$dpFile = "$env:TEMP\extend_c.txt"
@("rescan", "select volume C", "extend") | Set-Content -Path $dpFile -Encoding Ascii
diskpart /s $dpFile

Start-Sleep -Seconds 2

Get-Disk | ForEach-Object { Update-Disk -Number $_.Number }
$vol = Get-Volume -DriveLetter C
$totalGB = [math]::Round($vol.Size / 1GB, 2)
$freeGB = [math]::Round($vol.SizeRemaining / 1GB, 2)

$out = "C_TOTAL_GB=$totalGB`nC_FREE_GB=$freeGB"
Write-Host $out -ForegroundColor Green
Set-Content -Path "\\host.lan\Data\disk_result.txt" -Value $out -Force
Write-Host "--- DISK EXTENSION DONE ---" -ForegroundColor Green
