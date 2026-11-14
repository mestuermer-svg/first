<#
.SYNOPSIS
    Deploy-ToStrikerPi.ps1 - Deployed JS+TS Webseiten aus git-labor/labs/04_js_ts_web auf den StrikerPi Caddy-Webserver.
.DESCRIPTION
    1. Kopiert alle Dateien aus labs/04_js_ts_web/ nach /srv/git-labor/web/labs/04_js_ts_web/ (und index.html als Portal-Startseite nach /srv/git-labor/web/index.html).
    2. Beauftragt @rick per Inbox-Task mit dem TypeScript-Build (`build_ts_labs`) und Caddy-Reload (`caddy_reload`).
#>
[CmdletBinding()]
param(
    [string]$StrikerPiHost = "strikerpi"
)

$ErrorActionPreference = "Stop"
$LabDir = $PSScriptRoot
$SendTask = Join-Path (Split-Path -Parent $LabDir) "Send-SimAgentTask.ps1"

Write-Host "[1/4] Bereite Zielverzeichnis auf $StrikerPiHost vor..." -ForegroundColor Cyan
ssh -o BatchMode=yes -o ConnectTimeout=5 $StrikerPiHost "mkdir -p /srv/git-labor/web/labs/04_js_ts_web/ts-linux-lab/src"

Write-Host "[2/4] Uebertrage Portal-Startseite und JS/TS-Lab-Dateien..." -ForegroundColor Cyan
scp -q (Join-Path $LabDir "index.html") "${StrikerPiHost}:/srv/git-labor/web/index.html"
scp -q (Join-Path $LabDir "rechner.html") "${StrikerPiHost}:/srv/git-labor/web/labs/04_js_ts_web/rechner.html"
scp -q (Join-Path $LabDir "ts-linux-lab\package.json") "${StrikerPiHost}:/srv/git-labor/web/labs/04_js_ts_web/ts-linux-lab/package.json"
scp -q (Join-Path $LabDir "ts-linux-lab\tsconfig.json") "${StrikerPiHost}:/srv/git-labor/web/labs/04_js_ts_web/ts-linux-lab/tsconfig.json"
scp -q (Join-Path $LabDir "ts-linux-lab\index.html") "${StrikerPiHost}:/srv/git-labor/web/labs/04_js_ts_web/ts-linux-lab/index.html"
scp -q (Join-Path $LabDir "ts-linux-lab\styles.css") "${StrikerPiHost}:/srv/git-labor/web/labs/04_js_ts_web/ts-linux-lab/styles.css"
scp -q (Join-Path $LabDir "ts-linux-lab\src\main.ts") "${StrikerPiHost}:/srv/git-labor/web/labs/04_js_ts_web/ts-linux-lab/src/main.ts"

Write-Host "[3/4] Beauftrage @rick mit TypeScript-Kompilierung (tsc)..." -ForegroundColor Cyan
& $SendTask -TargetAgent rick -Action build_ts_labs -Wait -TimeoutSeconds 30

Write-Host "[4/4] Beauftrage @rick mit Caddy-Validierung & Reload..." -ForegroundColor Cyan
& $SendTask -TargetAgent rick -Action caddy_reload -Wait -TimeoutSeconds 30

Write-Host "`n[+] Deployment abgeschlossen! Live erreichbar unter:" -ForegroundColor Green
Write-Host "    Portal:        http://192.168.178.86/" -ForegroundColor White
Write-Host "    TS-Linux-Lab:  http://192.168.178.86/labs/04_js_ts_web/ts-linux-lab/" -ForegroundColor White
Write-Host "    Rechner (JS):  http://192.168.178.86/labs/04_js_ts_web/rechner.html" -ForegroundColor White
Write-Host "    Linux-API:     http://192.168.178.86/api/linux/status" -ForegroundColor White
