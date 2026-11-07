$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$audioDir = Join-Path $root 'audio'
New-Item -ItemType Directory -Path $audioDir -Force | Out-Null
$outDir = Split-Path -Parent $root
$pptxPath = Join-Path $outDir 'README-Lernmaterial-Erklaervideo.pptx'
$videoPath = Join-Path $outDir 'README-Lernmaterial-Erklaervideo.mp4'
if (Test-Path $pptxPath) { throw "Output exists: $pptxPath" }
if (Test-Path $videoPath) { throw "Output exists: $videoPath" }

$notes = @(
'Willkommen. In zwei Minuten zeige ich, wie unser Lernmaterial organisiert ist und wo Sie die passende Anleitung finden. Der Ausgangspunkt ist der Ordner Lernmaterial. Die README erklärt den Workspace und verlinkt zu den Spezialdokumenten.',
'Der Workspace bündelt drei eigenständige Repositories. Git-Labor enthält Agenten, Skills und zentrale Dokumentation. Assetto-Corsa-Content enthält die Sandbox, Setups und Sim-Racing-Dateien. Local-Cyborg sammelt lokale Laptop-Tools und Lernmaterial. Vor Änderungen prüfen Sie, in welchem Repository die Datei liegt.',
'Die Dokumente sind nach Aufgaben sortiert. Für Git und VS Code starten Sie bei den Einsteigeranleitungen. Für KI-Agenten, Gemini und MCP nehmen Sie den Architekturüberblick oder die Agent-Anleitung. Für die Sandbox gibt es eine Betriebsanleitung und ein separates Handbuch zu Light und den sieben Paketen. Hardware und Wiederherstellung liegen im letzten Abschnitt.',
'Die README ist das Inhaltsverzeichnis. Abschnitt eins erklärt die Workspace-Struktur. Abschnitt zwei beschreibt Git, Synchronisierung und Codespaces. Abschnitt drei listet die Dokumente thematisch auf. Am schnellsten: README öffnen, Strg+F und ein Stichwort wie Sandbox, MCP, Commit oder Backup eingeben. Dann dem Link zum passenden Detaildokument folgen.',
'Für den Sandbox-Einstieg: SANDBOX ANLEITUNG erklärt Betrieb und Zugriff. Das Architektur-Dokument erklärt Steam und KI-Agenten. Das Light-Handbuch liegt im Repository Assetto-Corsa-Content unter ac-sandbox und beschreibt die sieben Sync-Pakete. planing.md dokumentiert Rollen und Betriebsmodi. Merksatz: README zum Finden, Spezialdokument für die konkrete Aufgabe.'
)
$voice = New-Object -ComObject SAPI.SpVoice
$voiceList = $voice.GetVoices()
$german = $null
for ($i=0; $i -lt $voiceList.Count; $i++) { if ($voiceList.Item($i).GetDescription() -like '*German*') { $german = $voiceList.Item($i); break } }
if (-not $german) { throw 'Keine deutsche SAPI-Stimme gefunden.' }
$voice.Voice = $german
$voice.Rate = -1
$voice.Volume = 94
$durations = @()
for ($i=0; $i -lt $notes.Count; $i++) {
  $wav = Join-Path $audioDir ("narration-{0}.wav" -f ($i+1))
  $stream = New-Object -ComObject SAPI.SpFileStream
  $stream.Open($wav, 3, $false)
  $voice.AudioOutputStream = $stream
  [void]$voice.Speak($notes[$i], 0)
  $stream.Close()
  $fs = [System.IO.File]::OpenRead($wav)
  try { $br = New-Object System.IO.BinaryReader($fs); $fs.Position = 28; $byteRate = $br.ReadInt32(); $fs.Position = 40; $dataSize = $br.ReadInt32(); $durations += [Math]::Max(6, ($dataSize / $byteRate) + 1.5) } finally { $fs.Dispose() }
}

function Rgb([int]$r,[int]$g,[int]$b) { return ($r + ($g -shl 8) + ($b -shl 16)) }
$ink = Rgb 24 36 49; $muted = Rgb 82 98 115; $blue = Rgb 23 107 135; $pale = Rgb 234 243 246; $paper = Rgb 248 250 251; $gold = Rgb 194 123 37; $line = Rgb 203 216 223
function Add-Text($slide,[string]$text,[single]$left,[single]$top,[single]$width,[single]$height,[single]$size,[int]$color,[bool]$bold=$false,[string]$font='Segoe UI') {
  $s = $slide.Shapes.AddTextbox(1,$left,$top,$width,$height)
  $s.Fill.Visible = 0; $s.Line.Visible = 0
  $s.TextFrame.MarginLeft = 0; $s.TextFrame.MarginRight = 0; $s.TextFrame.MarginTop = 0; $s.TextFrame.MarginBottom = 0
  $s.TextFrame.WordWrap = -1; $s.TextFrame.TextRange.Text = $text
  $f = $s.TextFrame.TextRange.Font; $f.Name = $font; $f.Size = $size; $f.Color.RGB = $color; $f.Bold = $(if($bold){-1}else{0})
  return $s
}
function Add-Rect($slide,[single]$left,[single]$top,[single]$width,[single]$height,[int]$color) {
  $s = $slide.Shapes.AddShape(1,$left,$top,$width,$height); $s.Fill.ForeColor.RGB=$color; $s.Line.Visible=0; return $s
}
function Add-Base($presentation,[int]$index,[string]$eyebrow,[string]$title) {
  $s=$presentation.Slides.Add($index,12); $s.FollowMasterBackground=0; $s.Background.Fill.ForeColor.RGB=$paper
  Add-Text $s $eyebrow.ToUpper() 78 48 800 22 12 $blue $true | Out-Null
  Add-Text $s $title 78 88 810 58 32 $ink $true | Out-Null
  Add-Rect $s 78 158 54 3 $gold | Out-Null
  return $s
}

$pp = New-Object -ComObject PowerPoint.Application
$pp.Visible = -1
$pres = $pp.Presentations.Add()
$pres.PageSetup.SlideSize = 16
$pres.PageSetup.SlideWidth = 960; $pres.PageSetup.SlideHeight = 540

# Slide 1
$s=$pres.Slides.Add(1,12); $s.FollowMasterBackground=0; $s.Background.Fill.ForeColor.RGB=$paper
Add-Text $s 'ORIENTIERUNG · 2 MINUTEN' 78 118 800 24 13 $blue $true | Out-Null
Add-Text $s 'Lernmaterial, Workspace & Architektur' 78 168 800 116 42 $ink $true | Out-Null
Add-Rect $s 78 300 72 4 $gold | Out-Null
Add-Text $s 'Wo ist was – und wo beginne ich mit der Suche?' 78 330 770 62 24 $muted $false | Out-Null
Add-Text $s 'C:\Users\strik\git-labor\#$_Lernmaterial_to_sort\README.md' 78 417 800 24 14 $blue $false 'Consolas' | Out-Null

# Slide 2
$s=Add-Base $pres 2 '01 · Ablage' 'Drei Repositories im Workspace'
$cols=@(
  @('Git-Labor','Agenten, Skills, MCP-Konfiguration und zentrale Dokumentation.','C:\Users\strik\git-labor'),
  @('Assetto-Corsa-Content','Sandbox, Content Manager, Setups und Telemetrie.','C:\Users\strik\assetto-corsa-content'),
  @('Local-Cyborg','Lokale Laptop-Tools, Gemini, OpenCode und Lernmaterial.','C:\local_Cyborg')
)
$x=78
foreach($c in $cols){Add-Rect $s $x 192 245 3 $blue | Out-Null; Add-Text $s $c[0] $x 210 245 34 20 $ink $true | Out-Null; Add-Text $s $c[1] $x 252 245 100 17 $muted $false | Out-Null; Add-Text $s $c[2] $x 364 245 42 12 $blue $false 'Consolas' | Out-Null; $x+=275}
Add-Text $s 'Master-Workspace' 78 435 215 28 17 $ink $true | Out-Null
Add-Text $s 'git-labor.code-workspace  →  Repository wählen  →  Source Control' 292 435 600 30 17 $muted $false 'Segoe UI' | Out-Null

# Slide 3
$s=Add-Base $pres 3 '02 · Themen' 'Dokumente nach Aufgabe'
$topics=@(
  @('Git & VS Code','Synchronisieren, Workspaces und GitHub','git-source-control-anleitung-fuer-einsteiger.md','visual_studio_code_doku.md'),
  @('KI-Agenten & MCP','Agentenrollen, Gemini und lokale MCP-Architektur','Agent_setup.md','uebersicht-vscode-agent-localhost-gemini-antigravity.md'),
  @('Sandbox & Assetto Corsa','Betrieb, Zugriff und Aufgabenverteilung','SANDBOX_ANLEITUNG.md','docker-windows-steam-ki-agent-architektur.md'),
  @('Hardware & Backup','PC-Aufteilung, Stabilität und Wiederherstellung','multi-pc-architektur-ki-agents-simracing.md','simracer-system-backup-wiederherstellung-veeam.md')
)
$positions=@(@(78,194),@(502,194),@(78,344),@(502,344))
for($i=0;$i -lt 4;$i++){$x=$positions[$i][0];$y=$positions[$i][1];$t=$topics[$i];Add-Rect $s $x $y 335 3 $blue | Out-Null;Add-Text $s $t[0] $x ($y+12) 355 30 19 $ink $true | Out-Null;Add-Text $s $t[1] $x ($y+49) 355 48 15 $muted $false | Out-Null;Add-Text $s ($t[2]+'`n'+$t[3]) $x ($y+101) 355 50 12 $blue $false 'Consolas' | Out-Null}

# Slide 4
$s=Add-Base $pres 4 '03 · Einstieg' 'Die README ist der Wegweiser'
Add-Text $s '1' 106 206 44 44 27 $blue $true | Out-Null; Add-Text $s 'Workspace-Übersicht' 168 205 640 36 24 $ink $true | Out-Null; Add-Text $s 'Repositories und Speicherorte' 168 243 640 30 17 $muted $false | Out-Null
Add-Text $s '2' 106 294 44 44 27 $blue $true | Out-Null; Add-Text $s 'Arbeitsabläufe' 168 293 640 36 24 $ink $true | Out-Null; Add-Text $s 'Git, Synchronisierung und Codespaces' 168 331 640 30 17 $muted $false | Out-Null
Add-Text $s '3' 106 382 44 44 27 $blue $true | Out-Null; Add-Text $s 'Inhaltsverzeichnis' 168 381 640 36 24 $ink $true | Out-Null; Add-Text $s 'Themenbereiche und direkte Links zu den Anleitungen' 168 419 650 30 17 $muted $false | Out-Null
Add-Text $s 'Tipp: README öffnen → Strg+F → „Sandbox“, „MCP“, „Commit“ oder „Backup“' 106 476 760 30 17 $blue $true | Out-Null

# Slide 5
$s=Add-Base $pres 5 '04 · Beispiel Sandbox' 'Vom Überblick zur passenden Anleitung'
$steps=@(@('README','Abschnitt 3.3 öffnen'),@('Betrieb & Zugriff','SANDBOX_ANLEITUNG.md'),@('Light & 7 Pakete','ac-sandbox/LIGHT-AGENT-UND-AC-STRUKTUR.md'))
$x=78
foreach($st in $steps){Add-Rect $s $x 224 230 3 $blue | Out-Null;Add-Text $s $st[0] $x 245 240 34 20 $ink $true | Out-Null;Add-Text $s $st[1] $x 292 240 90 15 $muted $false | Out-Null;$x+=270}
Add-Text $s 'README zum Finden – Detaildokument für die konkrete Aufgabe.' 78 420 810 56 26 $ink $true | Out-Null

for($i=1;$i -le 5;$i++){
  $wav=Join-Path $audioDir ("narration-{0}.wav" -f $i)
  $audio=$pres.Slides.Item($i).Shapes.AddMediaObject2($wav,0,-1,946,526,8,8)
  $audio.AnimationSettings.PlaySettings.PlayOnEntry=-1
  $audio.AnimationSettings.PlaySettings.PauseAnimation=-1
  $audio.AnimationSettings.PlaySettings.HideWhileNotPlaying=-1
  $tr=$pres.Slides.Item($i).SlideShowTransition
  $tr.AdvanceOnClick=0; $tr.AdvanceOnTime=-1; $tr.AdvanceTime=$durations[$i-1]
}
$pres.SlideShowSettings.AdvanceMode=2
$pres.SaveAs($pptxPath,24)
$pres.CreateVideo($videoPath,$true,5,1080,30,85)
$deadline=(Get-Date).AddMinutes(12)
while($pres.CreateVideoStatus -eq 1 -or $pres.CreateVideoStatus -eq 2){if((Get-Date)-gt $deadline){throw 'Video export timeout'}; Start-Sleep -Seconds 2}
$status=$pres.CreateVideoStatus
if($status -ne 3){throw "Video export failed; status $status"}
$pres.Close(); $pp.Quit()
Get-Item -LiteralPath $pptxPath,$videoPath | Select-Object Name,Length
