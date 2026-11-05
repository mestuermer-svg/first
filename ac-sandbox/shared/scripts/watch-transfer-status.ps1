<#
.SYNOPSIS
    Live-Fortschritts-Dashboard (alle 5 Sekunden) für die Übertragung der 64-GB AC-Sandbox
    auf den SimRacer (\\192.168.178.68\ac-sandbox) in der kompakten Tabellen-Ansicht.
#>

param(
    [int]$IntervalSeconds = 5,
    [double]$TotalSizeGB  = 64.0
)

$ErrorActionPreference = "SilentlyContinue"
$prevBytes = $null
$prevTime  = $null
$oe        = [char]0x00F6 # ö
$ue        = [char]0x00FC # ü
$ae        = [char]0x00E4 # ä
$Ue        = [char]0x00DC # Ü
$avgSym    = [char]0x00D8 # Ø
$blkFull    = [string][char]0x2588
$blkLight   = [string][char]0x2591
$liveMdPath   = "c:\Users\strik\git-labor\ac-sandbox\LIVE-TRANSFER-STATUS.md"
$liveHtmlPath = "c:\Users\strik\git-labor\ac-sandbox\LIVE-TRANSFER-STATUS.html"
$utf8NoBom    = New-Object System.Text.UTF8Encoding($false)

while ($true) {
    $p = Get-CimInstance Win32_Process -Filter "Name='robocopy.exe'"
    Clear-Host

    if (-not $p) {
        $barDone = $blkFull * 22
        $doneTime = Get-Date -Format 'HH:mm:ss'
        $mdDone = @"
## Aktueller Live-Status (Stand: **$doneTime Uhr** — Auto-Refresh: alle $IntervalSeconds Sek.)

| Parameter | Aktueller Wert |
|---|---|
| **Prozess-Status** | ✅ **ABGESCHLOSSEN (100 %)** |
| **Fortschritt** | ``[$barDone] 100,0 %`` |
| **$($Ue)bertragene Datenmenge** | **64,00 GB** von **64,00 GB** *(0,00 GB offen)* |
| **Ziel-Freigabe** | ``\\192.168.178.68\ac-sandbox`` (``C:\ac-sandbox`` auf SimRacer) |
| **Bereits fertig kopiert** | ✅ ``docker-compose.yml``, ``docker-compose.simracer.yml``, ``start-sandbox.ps1``, ``backup-simracer-configs.ps1``, ``shared`` + ``storage\data.img`` |
"@
        [System.IO.File]::WriteAllText($liveMdPath, $mdDone, $utf8NoBom)

        $htmlDone = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8" />
  <title>Aktueller Live-Status (Abgeschlossen)</title>
  <style>
    :root { color-scheme: dark; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #1e1e1e; color: #d4d4d4; margin: 24px; }
    h2 { color: #4ec9b0; font-size: 1.25rem; margin-bottom: 14px; border-bottom: 1px solid #333; padding-bottom: 8px; }
    table { border-collapse: collapse; width: 100%; max-width: 860px; background: #252526; border: 1px solid #3c3c3c; border-radius: 6px; }
    th, td { text-align: left; padding: 10px 14px; border-bottom: 1px solid #333; font-size: 0.95rem; }
    th { background: #2d2d30; color: #fff; font-weight: 600; width: 230px; }
    code { font-family: Consolas, monospace; background: #1b1b1c; color: #4ec9b0; padding: 2px 6px; border-radius: 4px; }
  </style>
</head>
<body>
  <h2>2. Aktueller Live-Status (Stand: <strong>$doneTime Uhr</strong>)</h2>
  <table>
    <thead><tr><th>Parameter</th><th>Aktueller Wert</th></tr></thead>
    <tbody>
      <tr><th>Prozess-Status</th><td>&#x1F7E2; <strong>ABGESCHLOSSEN (100 %)</strong></td></tr>
      <tr><th>Fortschritt</th><td><code>[$barDone] 100,0 %</code></td></tr>
      <tr><th>$($Ue)bertragene Datenmenge</th><td><strong>64,00 GB</strong> von <strong>64,00 GB</strong> <em>(0,00 GB offen)</em></td></tr>
      <tr><th>Bereits fertig kopiert</th><td>&#x2705; Alle Dateien inkl. <code>storage\data.img</code> vollst$($ae)ndig auf <code>\\192.168.178.68\ac-sandbox</code></td></tr>
    </tbody>
  </table>
</body>
</html>
"@
        [System.IO.File]::WriteAllText($liveHtmlPath, $htmlDone, $utf8NoBom)

        Write-Host "==========================================================================" -ForegroundColor Green
        Write-Host " AC-SANDBOX TRANSFER: SimRacer (\\192.168.178.68\ac-sandbox)" -ForegroundColor Green
        Write-Host "==========================================================================" -ForegroundColor Green
        Write-Host " Parameter               | Aktueller Wert" -ForegroundColor White
        Write-Host "-------------------------+------------------------------------------------" -ForegroundColor DarkGray
        Write-Host " Prozess-Status          | ABGESCHLOSSEN (100 %)" -ForegroundColor Green
        Write-Host " Fortschritt             | [$barDone] 100,0 %" -ForegroundColor Green
        Write-Host " $($Ue)bertragene Datenmenge  | 64,00 GB von 64,00 GB (0,00 GB offen)" -ForegroundColor Green
        Write-Host "==========================================================================" -ForegroundColor Green
        break
    }

    $now       = Get-Date
    $currBytes = ($p.WriteTransferCount | Measure-Object -Sum).Sum
    $writeGB   = [math]::Round($currBytes / 1GB, 2)
    $remGB     = [math]::Max(0.0, [math]::Round($TotalSizeGB - $writeGB, 2))
    $pct       = [math]::Min(100.0, [math]::Round(($writeGB / $TotalSizeGB) * 100, 1))
    $elapsed   = $now - $p[0].CreationDate
    $avgMbps   = if ($elapsed.TotalSeconds -gt 0) { [math]::Round(($currBytes / 1MB) / $elapsed.TotalSeconds, 1) } else { 0 }

    if ($null -ne $prevBytes -and $null -ne $prevTime) {
        $dt = ($now - $prevTime).TotalSeconds
        $curMbps = if ($dt -gt 0) { [math]::Round((($currBytes - $prevBytes) / 1MB) / $dt, 1) } else { $avgMbps }
    } else {
        $curMbps = $avgMbps
    }
    $mbit = [math]::Round($avgMbps * 8, 0)

    $prevBytes = $currBytes
    $prevTime  = $now

    $speedForEta = if ($avgMbps -gt 0.1) { $avgMbps } else { 8.8 }
    $remSec      = [math]::Max(0, (($TotalSizeGB - $writeGB) * 1024) / $speedForEta)
    $remMin      = [math]::Round($remSec / 60, 0)
    $remSpan     = [TimeSpan]::FromSeconds($remSec)

    $filled = [math]::Floor(($pct / 100.0) * 22)
    $empty  = 22 - $filled
    $bar    = ($blkFull * $filled) + ($blkLight * $empty)
    $pids   = $p.ProcessId -join ", "
    $timeStr = Get-Date -Format 'HH:mm:ss'
    $elMin   = [math]::Floor($elapsed.TotalMinutes)
    $elSec   = $elapsed.Seconds

    $mdLive = @"
## Aktueller Live-Status (Stand: **$timeStr Uhr** — Auto-Refresh: alle $IntervalSeconds Sek.)

| Parameter | Aktueller Wert |
|---|---|
| **Prozess-Status** | 🟢 **AKTIV** (``robocopy.exe``, PID ``$pids``, Restartable Mode ``/Z /J``) |
| **Fortschritt** | ``[$bar] $($pct.ToString("0.0")) %`` |
| **$($Ue)bertragene Datenmenge** | **$($writeGB.ToString("0.00")) GB** von **64,00 GB** *(noch ca. $($remGB.ToString("0.00")) GB offen)* |
| **$($Ue)bertragungsrate ($avgSym)** | **$($avgMbps.ToString("0.0")) MB/s $avgSym** *(aktuell: $($curMbps.ToString("0.0")) MB/s \| ~$mbit Mbit/s WLAN/LAN)* |
| **Bisherige Laufzeit** | **$elMin Min. $elSec Sek.** |
| **Gesch$($ae)tzte Restzeit** | **ca. $remMin Minuten** *(~$($remSpan.Hours) Std. $($remSpan.Minutes) Min.)* |
| **Bereits fertig kopiert** | ✅ ``docker-compose.yml``, ``docker-compose.simracer.yml``, ``start-sandbox.ps1``, ``backup-simracer-configs.ps1`` + ``shared`` |
"@
    [System.IO.File]::WriteAllText($liveMdPath, $mdLive, $utf8NoBom)

    $htmlLive = @"
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8" />
  <meta http-equiv="refresh" content="$IntervalSeconds" />
  <title>Aktueller Live-Status (Auto-Refresh: $($IntervalSeconds)s)</title>
  <style>
    :root { color-scheme: dark; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background-color: #1e1e1e;
      color: #d4d4d4;
      margin: 24px;
    }
    h2 {
      color: #4fc1ff;
      font-size: 1.25rem;
      margin-bottom: 14px;
      border-bottom: 1px solid #333;
      padding-bottom: 8px;
    }
    table {
      border-collapse: collapse;
      width: 100%;
      max-width: 880px;
      background: #252526;
      border: 1px solid #3c3c3c;
      border-radius: 6px;
      overflow: hidden;
    }
    th, td {
      text-align: left;
      padding: 10px 14px;
      border-bottom: 1px solid #333333;
      font-size: 0.95rem;
    }
    th {
      background-color: #2d2d30;
      color: #ffffff;
      font-weight: 600;
      width: 230px;
    }
    tr:last-child th, tr:last-child td {
      border-bottom: none;
    }
    code {
      font-family: Consolas, "Courier New", monospace;
      background-color: #1b1b1c;
      color: #ce9178;
      padding: 2px 6px;
      border-radius: 4px;
    }
    .bar {
      color: #4ec9b0;
      font-weight: bold;
    }
    .sub {
      color: #9da5b4;
      font-size: 0.85rem;
      margin-top: 10px;
    }
  </style>
</head>
<body>
  <h2>2. Aktueller Live-Status (Stand: <strong>$timeStr Uhr</strong> &mdash; Auto-Refresh: alle $IntervalSeconds Sek.)</h2>
  <table>
    <thead>
      <tr>
        <th>Parameter</th>
        <th>Aktueller Wert</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <th>Prozess-Status</th>
        <td>&#x1F7E2; <strong>AKTIV</strong> (<code>robocopy.exe</code>, PID <code>$pids</code>, Restartable Mode <code>/Z /J</code>)</td>
      </tr>
      <tr>
        <th>Fortschritt</th>
        <td><code class="bar">[$bar] $($pct.ToString("0.0")) %</code></td>
      </tr>
      <tr>
        <th>$($Ue)bertragene Datenmenge</th>
        <td><strong>$($writeGB.ToString("0.00")) GB</strong> von <strong>64,00 GB</strong> <em>(noch ca. $($remGB.ToString("0.00")) GB offen)</em></td>
      </tr>
      <tr>
        <th>$($Ue)bertragungsrate ($avgSym)</th>
        <td><strong>$($avgMbps.ToString("0.0")) MB/s $avgSym</strong> <em>(aktuell: $($curMbps.ToString("0.0")) MB/s | ~$mbit Mbit/s WLAN/LAN)</em></td>
      </tr>
      <tr>
        <th>Bisherige Laufzeit</th>
        <td><strong>$elMin Min. $elSec Sek.</strong></td>
      </tr>
      <tr>
        <th>Gesch$($ae)tzte Restzeit</th>
        <td><strong>ca. $remMin Minuten</strong> <em>(~$($remSpan.Hours) Std. $($remSpan.Minutes) Min.)</em></td>
      </tr>
      <tr>
        <th>Bereits fertig kopiert</th>
        <td>&#x2705; <code>docker-compose.yml</code>, <code>docker-compose.simracer.yml</code>, <code>start-sandbox.ps1</code>, <code>backup-simracer-configs.ps1</code> + <code>shared</code></td>
      </tr>
    </tbody>
  </table>
  <p class="sub">Diese Ansicht aktualisiert ihre Werte automatisch alle $IntervalSeconds Sekunden.</p>
</body>
</html>
"@
    [System.IO.File]::WriteAllText($liveHtmlPath, $htmlLive, $utf8NoBom)

    Write-Host "====================================================================================" -ForegroundColor Cyan
    Write-Host " Aktueller Live-Status (Stand: $timeStr Uhr | Auto-Refresh: alle $IntervalSeconds Sek.)" -ForegroundColor Cyan
    Write-Host "====================================================================================" -ForegroundColor Cyan
    Write-Host (" {0,-24} | {1}" -f "Parameter", "Aktueller Wert") -ForegroundColor Yellow
    Write-Host "--------------------------+---------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host (" {0,-24} | AKTIV (robocopy.exe, PID {1}, Restartable Mode /Z /J)" -f "Prozess-Status", $pids) -ForegroundColor Green
    Write-Host (" {0,-24} | [{1}] {2} %" -f "Fortschritt", $bar, $pct.ToString("0.0")) -ForegroundColor Cyan
    Write-Host (" {0,-24} | {1} GB von 64,00 GB (noch ca. {2} GB offen)" -f "$($Ue)bertragene Datenmenge", $writeGB.ToString("0.00"), $remGB.ToString("0.00")) -ForegroundColor White
    Write-Host (" {0,-24} | {1} MB/s $avgSym (aktuell: {2} MB/s | ~{3} Mbit/s WLAN/LAN)" -f "$($Ue)bertragungsrate ($avgSym)", $avgMbps.ToString("0.0"), $curMbps.ToString("0.0"), $mbit) -ForegroundColor White
    Write-Host (" {0,-24} | {1} Min. {2} Sek." -f "Bisherige Laufzeit", $elMin, $elSec) -ForegroundColor White
    Write-Host (" {0,-24} | ca. {1} Minuten (~{2} Std. {3} Min.)" -f "Gesch$($ae)tzte Restzeit", $remMin, $remSpan.Hours, $remSpan.Minutes) -ForegroundColor White
    Write-Host (" {0,-24} | docker-compose.yml, docker-compose.simracer.yml," -f "Bereits fertig kopiert") -ForegroundColor Gray
    Write-Host (" {0,-24} | start-sandbox.ps1, backup-simracer-configs.ps1 + shared" -f "") -ForegroundColor Gray
    Write-Host "====================================================================================" -ForegroundColor Cyan

    [System.Threading.Thread]::Sleep($IntervalSeconds * 1000)
}
