@echo off
cd /d C:\Users\Docker\Desktop\Shared
diskpart /s extend.txt > disk_extend.log 2>&1
powershell -Command "Get-Volume C | Out-File -FilePath disk_vol.txt"
