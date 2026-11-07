$ErrorActionPreference = 'Stop'
$baseDir = 'C:\Users\strik\git-labor\#$_Lernmaterial_to_sort'
$buildDir = Join-Path $baseDir '.build-video'
$ffmpeg = Join-Path $buildDir 'ffmpeg-bin\ffmpeg-9.0.2-essentials_build\bin\ffmpeg.exe'
$ffprobe = Join-Path $buildDir 'ffmpeg-bin\ffmpeg-9.0.2-essentials_build\bin\ffprobe.exe'
$neuralDir = Join-Path $buildDir 'audio-neural'
New-Item -ItemType Directory -Path $neuralDir -Force | Out-Null

$voice = 'de-DE-SeraphinaMultilingualNeural'
$scripts = @(
    'Herzlich willkommen! In diesem kurzen Überblick zeige ich Ihnen, wie unser Lernmaterial aufgebaut ist – und wie Sie ohne langes Suchen sofort zur passenden Anleitung finden. Ihr zentraler Startpunkt ist die README-Datei im Ordner Lernmaterial: Sie erklärt den gesamten Workspace und führt Sie direkt zu den richtigen Fachdokumenten.',
    'Unser Workspace verbindet drei eigenständige Repositories unter einem Dach. Im Git-Labor liegen die KI-Agenten, die Skills und die zentrale Dokumentation. Assetto-Corsa-Content bündelt alles rund um die Docker-Sandbox, den Content Manager und die Sim-Racing-Konfiguration. Und Local-Cyborg enthält lokale Werkzeuge sowie ergänzendes Lernmaterial auf dem Laptop. Ein wichtiger Tipp vor jeder Änderung: Prüfen Sie kurz, in welchem der drei Repositories Ihre Datei liegt, damit der Commit später in der richtigen Git-Historie landet.',
    'Damit Sie sich schnell zurechtfinden, sind alle Dokumente nach konkreten Aufgaben sortiert. Wenn Sie mit Git, GitHub oder Visual Studio Code starten möchten, beginnen Sie am besten mit den Einsteigeranleitungen. Geht es um KI-Agenten, Gemini oder die lokale MCP-Architektur, helfen Ihnen das Agent-Setup und der Architekturüberblick weiter. Für die Assetto-Corsa-Sandbox gibt es eine eigene Betriebsanleitung sowie das Handbuch zum Light-Agenten. Und alles rund um die Multi-PC-Architektur und Veeam-Backups finden Sie gebündelt im Bereich Hardware und Backup.',
    'Die README-Datei funktioniert dabei wie Ihr interaktives Inhaltsverzeichnis. Im ersten Abschnitt sehen Sie auf einen Blick die Struktur des gesamten Workspaces. Der zweite Abschnitt führt Schritt für Schritt durch die täglichen Arbeitsabläufe mit Git, GitHub und den Codespaces. Und im dritten Abschnitt sind sämtliche Anleitungen übersichtlich nach Themen verlinkt. Am schnellsten geht es im Alltag so: Öffnen Sie einfach die README, drücken Sie Steuerung und F, und tippen Sie ein Stichwort wie Sandbox, MCP, Commit oder Backup ein – schon führt Sie der passende Link direkt ans Ziel.',
    'Schauen wir uns das zum Abschluss am Beispiel der Sandbox an: Sie starten in der README im Abschnitt drei Punkt drei. Für den täglichen Betrieb und den Zugriff öffnen Sie von dort aus direkt die Sandbox-Anleitung. Wenn Sie tiefer in die Aufgaben des Light-Agenten und die sieben Synchronisations-Pakete einsteigen möchten, wechseln Sie ins Handbuch direkt im Ordner ac-sandbox. Als einfache Faustregel gilt also: Die README nutzen Sie zum schnellen Finden – und das jeweilige Spezialdokument zum konkreten Umsetzen.'
)

$durations = @()
for ($i = 0; $i -lt $scripts.Count; $i++) {
    $idx = $i + 1
    $mp3 = Join-Path $neuralDir "raw-$idx.mp3"
    $wav = Join-Path $neuralDir "narration-$idx.wav"
    & uvx edge-tts --voice $voice --rate="-2%" --text $scripts[$i] --write-media $mp3
    & $ffmpeg -y -hide_banner -loglevel error -i $mp3 -af "adelay=350|350,apad=pad_dur=0.65,loudnorm=I=-16:TP=-1.5:LRA=11" -ar 48000 -ac 2 -c:a pcm_s16le $wav
    $durStr = (& $ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $wav).Trim()
    $dur = [double]::Parse($durStr, [System.Globalization.CultureInfo]::InvariantCulture)
    $durations += $dur
    Write-Host ("Folie {0}: {1:N2} s" -f $idx, $dur)
}

$concatVideo = Join-Path $neuralDir 'slides-neural.ffconcat'
$concatLines = @('ffconcat version 1.0')
for ($i = 0; $i -lt 5; $i++) {
    $idx = $i + 1
    $slidePath = ('C:/Users/strik/git-labor/#$_Lernmaterial_to_sort/.build-video/frames/slide-{0}.png' -f $idx)
    $durInvariant = $durations[$i].ToString('F6', [System.Globalization.CultureInfo]::InvariantCulture)
    $concatLines += "file '$slidePath'"
    $concatLines += "duration $durInvariant"
}
$concatLines += "file 'C:/Users/strik/git-labor/#`$_Lernmaterial_to_sort/.build-video/frames/slide-5.png'"
$concatLines += "duration 0.04"
[System.IO.File]::WriteAllLines($concatVideo, $concatLines, (New-Object System.Text.UTF8Encoding($false)))

$concatAudio = Join-Path $neuralDir 'audio-neural.ffconcat'
$audioLines = @('ffconcat version 1.0')
for ($i = 1; $i -le 5; $i++) {
    $wavPath = ('C:/Users/strik/git-labor/#$_Lernmaterial_to_sort/.build-video/audio-neural/narration-{0}.wav' -f $i)
    $audioLines += "file '$wavPath'"
}
[System.IO.File]::WriteAllLines($concatAudio, $audioLines, (New-Object System.Text.UTF8Encoding($false)))

$fullWav = Join-Path $neuralDir 'full-narration.wav'
& $ffmpeg -y -hide_banner -loglevel error -f concat -safe 0 -i $concatAudio -c copy $fullWav

$outVideo = Join-Path $baseDir 'README-Lernmaterial-Erklaervideo.mp4'
$backupVideo = Join-Path $buildDir 'README-Lernmaterial-Erklaervideo.katja-backup.mp4'
if ((Test-Path -LiteralPath $outVideo) -and -not (Test-Path -LiteralPath $backupVideo)) {
    Copy-Item -LiteralPath $outVideo -Destination $backupVideo -Force
}

& $ffmpeg -y -hide_banner -loglevel error -f concat -safe 0 -i $concatVideo -i $fullWav -vf "fps=30,format=yuv420p" -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 18 -preset medium -c:a aac -b:a 192k -ar 48000 -movflags +faststart -shortest $outVideo

Write-Host "`n--- Video-Prüfung ---"
& $ffprobe -v error -show_entries stream=codec_name,width,height,pix_fmt,sample_rate,channels -show_entries format=duration,size -of default=noprint_wrappers=1 $outVideo
