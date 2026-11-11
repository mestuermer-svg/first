$procs = Get-Process -Name powershell -ErrorAction SilentlyContinue
Write-Host "Aktive PowerShell Prozesse auf SimRacer: $($procs.Count)" -ForegroundColor Cyan
foreach ($p in $procs) {
    Write-Host "  PID: $($p.Id) | Session: $($p.SessionId) | CPU: $($p.CPU) | RAM: $([math]::Round($p.WorkingSet64 / 1MB, 1)) MB | Title: '$($p.MainWindowTitle)'" -ForegroundColor White
}
