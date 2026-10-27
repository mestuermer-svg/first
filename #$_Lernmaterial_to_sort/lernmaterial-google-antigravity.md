# Lernmaterial: Mit Google Antigravity in VS Code arbeiten

Stand: 23. Oktober 2026

## 1. Was ist Antigravity?

Google Antigravity ist ein KI-Programmieragent. Du beschreibst ein Ziel in normaler Sprache; der Agent kann den Projektcode untersuchen, einen Plan erstellen, Dateien ändern und Tests oder andere Befehle ausführen. Du bleibst verantwortlich für Anforderungen, Freigaben und die Kontrolle der Änderungen.

Antigravity ist mehr als eine Codevervollständigung: Bei größeren Aufgaben kann es mehrere Schritte planen. Lass es trotzdem zunächst erklären und Vorschläge machen, bevor du Änderungen freigibst.

## 2. Was ist auf diesem Rechner eingerichtet?

- Die offizielle Erweiterung **Google Antigravity** von Google ist in VS Code installiert (Version 1.9.0).
- Ob die Anmeldung in der Erweiterung bereits abgeschlossen ist, wurde nicht geprüft. Klicke in VS Code auf das Antigravity-Symbol in der Aktivitätsleiste und melde dich mit einem Google-Konto an.
- Antigravity verwendet seine eigene Google-Anmeldung. Der API-Schlüssel aus `geminiCode.apiKey` gehört zu einer anderen Gemini-Erweiterung und wird für Antigravity nicht benötigt.
- Der geöffnete Projektordner ist mit `mestuermer-svg/first` verbunden. Der lokale Branch `main` verfolgt `origin/main`.
- Lokale Notizen sind nicht automatisch Bestandteil von GitHub. Prüfe vor einem Commit oder Push immer `git status`.

Die offizielle VS-Code-Erweiterung setzt laut Google VS Code 1.90 oder neuer voraus. Beim ersten Start richtet sie den lokalen Antigravity-Backenddienst ein.

### Die Entwicklungsumgebung verstehen

| Teil | Aufgabe | Einfaches Bild |
| --- | --- | --- |
| VS Code | Editor: Hier öffnest du Dateien, schreibst Code und siehst Änderungen. | Werkbank und Werkzeugkasten |
| Antigravity | KI-Agent in VS Code: Erklärt Projektcode und kann nach deiner Freigabe Dateien ändern oder Befehle vorschlagen. | Lernpartner, der Vorschläge macht |
| Terminal / PowerShell | Führt Textbefehle aus, zum Beispiel Tests oder `git status`. | Bedienfeld für Werkzeuge |
| Git | Speichert die Entwicklung als nachvollziehbare lokale Änderungsschritte. | Verlauf mit Rücksprungpunkten |
| GitHub | Speichert und teilt ein Git-Repository online. | Gemeinsamer Online-Ort für den Verlauf |
| Browser | Führt eine Webseite aus und zeigt sie an. | Laufzeit und Anzeige für HTML, CSS und Browser-JavaScript |
| Docker | Startet Anwendungen und ihre Abhängigkeiten in Containern. Es ist weder Programmiersprache noch Antigravity-Sandbox. | Verpackte Laufzeitumgebung |

Diese Teile ergänzen einander, sind aber nicht dasselbe: VS Code bearbeitet Dateien, Antigravity unterstützt beim Denken und Ändern, Git protokolliert lokale Änderungen und GitHub kann sie teilen. Docker wird erst benötigt, wenn ein Projekt eine Container-Umgebung oder Dienste wie eine Datenbank braucht.

## 3. Erste Sitzung

1. Öffne in VS Code den Projektordner, an dem du arbeiten möchtest.
2. Klicke in der Aktivitätsleiste auf **Antigravity**.
3. Melde dich mit deinem Google-Konto an und schließe die angezeigte Einrichtung ab.
4. Prüfe, dass der Agent den richtigen Projektordner verwendet.
5. Beginne mit einer Frage, die nur eine Erklärung verlangt. So lernst du den Agenten kennen, ohne gleich Dateien ändern zu lassen.

**Einsteiger-Prompt:**

> Erkläre mir die Ordner und wichtigsten Dateien dieses Projekts. Ändere nichts. Nenne zuerst, was du geprüft hast, und erkläre neue Fachbegriffe einfach.

## 4. Von der Frage zur geprüften Änderung

Arbeite in kleinen, überprüfbaren Schritten:

1. **Ziel beschreiben:** Was soll sich für die spätere Nutzerin oder den Nutzer ändern?
2. **Grenzen nennen:** Welche Dateien darf der Agent bearbeiten? Was soll unverändert bleiben?
3. **Erst planen lassen:** Bitte um einen kurzen Plan und offene Fragen, noch ohne Änderungen.
4. **Änderung einzeln freigeben:** Lass nur einen kleinen Teil umsetzen.
5. **Lernen:** Bitte um eine Erklärung, warum die Änderung nötig ist und wie der Code funktioniert.
6. **Prüfen:** Lass passende Tests ausführen und lies den Diff in VS Code.
7. **Entscheiden:** Übernimm die Änderung nur, wenn du sie nachvollziehen kannst und die Prüfung passt.

**Prompt-Vorlage:**

> Ich lerne Programmieren mit diesem Projekt. Mein Ziel ist: [Ziel]. Erkläre zuerst in einfachen Worten, welche Dateien betroffen wären, und schlage einen kleinen Plan vor. Ändere noch nichts. Wenn ich zustimme, bearbeite nur [Datei oder Ordner]. Erkläre jeden wichtigen Schritt und zeige, wie ich die Änderung testen kann. Führe keine Änderungen außerhalb des Projektordners aus.

## 5. Übungen

### Programmiersprachen und wo sie laufen

Eine Programmiersprache beschreibt Anweisungen für einen Computer. Die passende Sprache hängt davon ab, welche Art von Anwendung du baust und welche Laufzeit sie ausführt.

| Technologie | Was sie macht | Häufiger Einsatz und Ausführung |
| --- | --- | --- |
| HTML | Beschreibt Inhalt und Struktur einer Webseite; es ist eine Auszeichnungssprache, keine Programmiersprache. | Browser liest `.html`-Dateien. |
| CSS | Beschreibt Aussehen und Layout; es ist ein Stylesheet, keine Programmiersprache. | Browser wendet `.css`-Regeln auf HTML an. |
| JavaScript | Programmiert Verhalten, zum Beispiel Klicks, Berechnungen und Änderungen an der Seite. | Läuft im Browser oder mit Node.js auf einem Server beziehungsweise lokal. |
| TypeScript | JavaScript mit zusätzlichen Typprüfungen; wird meist vor der Ausführung in JavaScript umgewandelt. | Web-Frontends und Node.js-Projekte. |
| Python | Allgemeine Sprache, oft für Automatisierung, Datenanalyse, KI und Webserver. | Python-Laufzeit auf dem Rechner oder Server. |
| Java / C# | Häufig für größere Backend-, Unternehmens- und Desktop-Systeme; Java auch für Android, C# auch für Spiele mit Unity. | Java Virtual Machine beziehungsweise .NET-Laufzeit. |
| SQL | Sprache zum Abfragen und Ändern strukturierter Daten in Datenbanken. | Wird von einem Datenbankserver verarbeitet. |
| YAML | Konfigurationsformat, zum Beispiel in `compose.yaml`; keine Programmiersprache. | Wird von Werkzeugen wie Docker Compose gelesen. |
| Dockerfile | Bauanleitung für ein Docker-Image; keine Programmiersprache. | Docker baut daraus ein Image und startet daraus Container. |

Bei jeder Codeänderung helfen diese Fragen: Welche Datei ist das? Welche Sprache oder welches Format steht darin? Welches Programm führt es aus? Welche Eingaben kommen hinein und welche Ausgabe entsteht?

**Prompt zum Lernen einer bestehenden Datei:**

> Erkläre die Datei [Dateiname] für eine lernende Person. Nenne zuerst die Sprache oder das Format und wo es ausgeführt wird. Gehe dann den Ablauf vom Eingang bis zur Ausgabe durch. Erkläre neue Begriffe mit kurzen Beispielen und zeige, wie ich das Verhalten testen kann. Ändere nichts.

### Übung A: Code lesen

> Erkläre die Funktion [Funktionsname] Schritt für Schritt. Zeige, welche Eingaben sie erwartet und was sie zurückgibt. Ändere den Code nicht.

### Übung B: Einen Test verstehen

> Suche einen passenden Test für [Funktion]. Erkläre, was der Test prüft. Schlage einen zusätzlichen Testfall vor, aber ändere noch keine Datei.

### Übung C: Kleine Verbesserung planen

> Schlage eine kleine Verbesserung an [Datei oder Funktion] vor. Nenne Nutzen, mögliche Nebenwirkungen und einen Test. Warte auf meine Freigabe, bevor du etwas änderst.

### Übung D: Änderung überprüfen

> Fasse den aktuellen Diff zusammen. Erkläre jede geänderte Datei und nenne, welche Tests gelaufen sind und welche noch fehlen. Ändere nichts weiter.

### Übung E: Ein kleines Programm erzeugen

Starte in einem neuen Gespräch und bitte Antigravity um eine einzelne Datei `rechner.html` mit HTML, CSS und JavaScript. So bleibt das Beispiel unabhängig von zusätzlichen Bibliotheken.

> Erzeuge eine einzelne Datei `rechner.html` mit einem kleinen Zahlenrechner. Zwei Eingabefelder nehmen Zahlen auf; ein Button addiert sie und zeigt das Ergebnis auf der Seite. Verwende nur HTML, CSS und JavaScript ohne externe Bibliotheken. Erkläre zuerst den Plan und warte auf meine Zustimmung. Erkläre danach: welche Teile HTML, CSS und JavaScript sind; dass der Browser die Datei ausführt; wie ein Klick das JavaScript startet; wie Texte aus Eingabefeldern zu Zahlen werden; und wie das Ergebnis auf der Seite erscheint. Beschreibe den Ablauf in einfachen Worten, bevor du Fachbegriffe verwendest. Nenne drei manuelle Tests, darunter eine leere Eingabe. Ändere keine anderen Dateien und führe keinen Git-Commit oder Push aus.

Öffne die Datei anschließend im Browser und teste normale Zahlen, negative Zahlen und leere Eingaben. Bitte Antigravity danach, einen gefundenen Fehler erst zu erklären und eine Korrektur vorzuschlagen, bevor es die Datei ändert.

## 6. Git und Sicherheit

- Vor einer größeren Aufgabe: Änderungen sichern oder einen Git-Commit erstellen, den du selbst geprüft hast.
- Nach der Arbeit: `git status` und den Diff prüfen. Ein Agent kann plausibel klingenden, aber falschen Code erzeugen.
- Stage und committe nur Dateien, die du geprüft hast. Ein Push veröffentlicht Commits auf GitHub; bitte den Agenten nicht pauschal um „alles committen und pushen“.
- Antigravity bietet Berechtigungen und eine Terminal-Sandbox. Für den Einstieg ist die Voreinstellung **Default** sinnvoll: Zugriff bleibt auf den Arbeitsbereich begrenzt; sensible Befehle außerhalb der Sandbox benötigen eine Bestätigung.
- Aktiviere keine uneingeschränkten Modi wie **Turbo** oder **Full machine**, solange du ihre Folgen nicht bewusst möchtest.
- Prüfe jeden Freigabedialog. Ein Befehl kann Dateien löschen, Daten übertragen oder Einstellungen ändern.
- Füge keine API-Schlüssel, Passwörter, privaten Schlüssel oder Inhalte aus `.env`-Dateien in Prompts ein.

## 7. Docker mit Antigravity

Docker und die Antigravity-Sandbox sind zwei verschiedene Dinge. Antigravity isoliert Agenten-Befehle mit Betriebssystemfunktionen; laut Google verwendet die Sandbox keine Docker-Images oder virtuelle Maschinen. Docker Desktop kann unabhängig davon Container für dein Projekt starten. Auf diesem Rechner sind Docker CLI und Docker-Server (Version 29.8.2) verfügbar.

In der Sandbox können Netzwerkzugriff und der Zugriff auf den Docker-Dienst eingeschränkt sein. Antigravity kann deshalb um Erlaubnis bitten, einen Docker-Befehl außerhalb der Sandbox auszuführen. Prüfe den angezeigten Befehl und bestätige ihn nur, wenn du weißt, was er bewirkt.

**Lernübung mit Docker Compose:**

> Prüfe zuerst, ob dieses Projekt eine `Dockerfile` oder `compose.yaml` enthält. Erkläre mir, welche Container gestartet würden, welche Ports veröffentlicht werden und ob Dateien oder Volumes eingebunden sind. Ändere nichts und führe noch keine Befehle aus. Wenn keine Docker-Konfiguration existiert, erkläre mir das und schlage eine kleine Lernübung vor, ohne Dateien anzulegen.

Wenn du später eine vorhandene Compose-Konfiguration verstanden hast, kannst du in einem separaten Schritt den Agenten bitten, den Build und Start vorzubereiten. Lass dir die Befehle vor der Ausführung zeigen. Prüfe danach Containerstatus und Logs und lass dir erklären, wie du die Anwendung stoppst. Vermeide `docker compose down -v`, bis du sicher bist, dass du die damit gelöschten Volume-Daten nicht brauchst.

Docker kann Dateien über Bind-Mounts verändern und Container können Netzwerkzugriff erhalten. Hänge keine Zugangsdaten, `.env`-Dateien oder privaten Schlüssel in Container ein. Verwende für den Anfang keine privilegierten Container und bestätige keine unbekannten Image-Downloads.

Im aktuellen Lernmaterial-Repository gibt es keine Dockerfile und keine Compose-Konfiguration; es ist daher noch keine Anwendung vorhanden, die direkt gestartet werden kann.

## 8. Gut formulierte Aufgaben

Eine gute Aufgabe benennt Ziel, Umfang und Prüfkriterium. Zum Beispiel:

> Ergänze für die Funktion `summe` einen Test für leere Eingaben. Ändere nur die Testdatei. Erkläre, welches Ergebnis erwartet wird, führe den passenden Test aus und zeige mir den Diff. Bitte nichts committen oder pushen.

Weniger hilfreich ist: „Mach das Projekt fertig.“ Das lässt Umfang, gewünschtes Verhalten und Freigaben offen.

## 9. KI mit Projektregeln und Skills anleiten

### Erst den Code zugänglich machen

1. Öffne in VS Code den **Projektordner**, in dem das Git-Repository liegt, nicht nur eine einzelne Datei.
2. Wähle in der KI-Erweiterung das passende Modell beziehungsweise den passenden Agenten und starte einen neuen Chat für dieses Projekt.
3. Bitte die KI zunächst, `README.md`, die Ordnerstruktur und passende Quellcode- und Testdateien zu lesen und dir den Aufbau zu erklären. Lass sie noch nichts ändern.
4. Bei Antigravity müssen die Projektordner im Antigravity-Projekt enthalten sein. Weitere Ordner nur hinzufügen, wenn sie für die Aufgabe wirklich gebraucht werden.
5. Der Zugriff bezieht sich auf die freigegebenen Arbeitsordner und Werkzeuge, nicht automatisch auf jedes Repository in deinem GitHub-Konto oder auf den gesamten Rechner. Terminalbefehle und externe Zugriffe können zusätzliche Freigaben benötigen.

Dateien kannst du im Prompt gezielt benennen, zum Beispiel „Lies `src/rechner.js` und `tests/rechner.test.js`“. Verwende in VS Code außerdem die Dateiauswahl beziehungsweise Dateiverweise im Chat, wenn der verwendete Agent das anbietet.

### Regeln, Skills und Prompts unterscheiden

| Art | Wofür sie gedacht ist | Beispiel |
| --- | --- | --- |
| Chat-Prompt | Ein einzelner Auftrag und sein Umfang | „Erkläre diese Funktion, ändere nichts.“ |
| Regel / Anweisung | Dauerhafte Projektvorgaben oder technische Grenzen | „Ändere keine Dateien außerhalb des Projektordners.“ |
| Skill | Wiederverwendbarer Ablauf für eine bestimmte Aufgabe | „Code lesen, Tests suchen, Änderung erklären und prüfen.“ |
| Projektdatei | Fakten, die aus dem Code selbst kommen | `README.md`, Architektur- oder Testdokumentation |

Halte Regeln kurz und verbindlich. Skills sollten einen konkreten Arbeitsablauf beschreiben und nur bei passenden Aufgaben geladen werden. Wiederhole keine langen Projektbeschreibungen in Prompts, Regeln und Skills zugleich.

### Dateiformate und Speicherorte

Der richtige Speicherort hängt vom verwendeten Agenten ab. Eine Datei im falschen Ordner wird möglicherweise ignoriert.

| Verwendung | Geeigneter Ort im Projekt |
| --- | --- |
| Gemeinsame Projektregeln für Antigravity und unterstützende VS-Code-Agenten | `AGENTS.md` im Repository-Hauptordner |
| Antigravity-spezifische Regeln | `GEMINI.md` oder `.agents/rules/*.md` |
| Antigravity- oder VS-Code-Agent-Skills | `.agents/skills/<skill-name>/SKILL.md` |
| GitHub Copilot-Projektanweisungen | `.github/copilot-instructions.md` |
| Copilot-Skills | `.github/skills/<skill-name>/SKILL.md` |
| Copilot-Anweisungen für bestimmte Dateien | `.github/instructions/*.instructions.md` mit passendem `applyTo`-Muster |

Antigravity behandelt `AGENTS.md` und `GEMINI.md` im Projekt als dauerhaft aktive Regeln. Dateien in `.agents/rules/` benötigen YAML-Kopfzeilen mit einem gültigen Auslöser. Beispiel für eine Regel, die nur für HTML- und JavaScript-Dateien gilt:

```markdown
---
trigger: glob
globs: "**/*.html, **/*.js"
description: "Lernregeln für HTML- und JavaScript-Dateien."
---

# Lernregeln für Webcode

- Erkläre zuerst, welche Datei der Browser ausführt und welche Aufgabe sie hat.
- Schlage Änderungen vor und warte auf meine Freigabe.
- Ändere nur Dateien, die zur Aufgabe gehören.
- Nenne einen passenden manuellen Test oder automatisierten Test.
```

Ein Skill ist ein Ordner mit einer `SKILL.md`. Der `name` im YAML-Kopf muss zum Ordnernamen passen; die `description` soll klar sagen, wann der Skill nützlich ist. Beispiel für `.agents/skills/code-erklaeren/SKILL.md`:

```markdown
---
name: code-erklaeren
description: Erklärt vorhandenen Quellcode Schritt für Schritt für Lernende. Verwenden, wenn Code gelesen oder verstanden werden soll.
---

# Code erklären

1. Lies die betroffene Datei und nenne Sprache, Zweck und Laufzeit.
2. Erkläre Eingaben, wichtige Schritte und Ausgabe in einfachen Worten.
3. Erkläre neue Fachbegriffe an einem kleinen Beispiel.
4. Nenne einen passenden Test. Ändere keine Datei, außer die Person bittet ausdrücklich darum.
```

Skills können je nach Agent automatisch passend zur Beschreibung geladen oder über die Skill-Auswahl im Chat gestartet werden. Bei Antigravity können Skills im App-Chat auch über ihren Slash-Namen aufgerufen werden, sofern sie dort angezeigt werden.

### Regeln im VS-Code-Chat anlegen und prüfen

- Für GitHub Copilot: Öffne die Befehlspalette mit `Ctrl+Shift+P`, wähle **Chat: Open Customizations**, prüfe zuerst den ausgewählten Agenten und lege Anweisungen oder Skills im **Workspace** an, wenn sie mit dem Projekt geteilt werden sollen.
- Für Antigravity: Lege gemeinsame Regeln als `AGENTS.md` im Projektstamm ab; Antigravity-spezifische Regeln und Skills kommen in die oben genannten `.agents/`-Ordner.
- Formuliere Regeln als überprüfbare Sätze. Schreibe zum Beispiel „Führe `npm test` nach Änderungen an JavaScript-Dateien aus“ statt „Teste immer ordentlich“.
- Halte persönliche Vorlieben von Projektregeln getrennt. Projektregeln gehören ins Repository, wenn alle Mitwirkenden sie verwenden sollen.
- Prüfe im Agent-Customizations-Editor, ob der richtige Agent die Dateien erkennt. Teste anschließend in einem neuen Chat eine kleine Aufgabe und kontrolliere die verwendeten Referenzen und den Diff.

**Start-Prompt zum Einrichten von Projektregeln:**

> Untersuche nur den geöffneten Projektordner: Lies die README, prüfe vorhandene Quellcode-, Test- und Konfigurationsdateien und fasse Sprache, Laufzeit, Start- und Testbefehle zusammen. Erstelle noch keine Dateien und ändere nichts. Schlage danach kurze Projektregeln und höchstens einen passenden Skill vor. Nenne für jede Regel, woran ich ihre Einhaltung prüfen kann. Erkläre außerdem, in welchem Dateiformat sie für den ausgewählten Agenten abgelegt werden müssen.

Übernimm vorgeschlagene Regeln oder Skills erst nach eigener Prüfung. Ein Skill kann neben Text auch Skripte enthalten; lies deren Zweck und Auswirkungen, bevor ein Agent sie ausführt. Niemals geheime Schlüssel, Passwörter oder private Dateien in Projektanweisungen aufnehmen.

## 10. Offizielle Dokumentation

- [Google Antigravity: Getting Started](https://antigravity.google/docs/getting-started/)
- [Antigravity in Visual Studio Code](https://antigravity.google/docs/ide/extensions/vscode/)
- [Funktionen und Arbeitsbereiche](https://antigravity.google/docs/features/)
- [Berechtigungen und Sicherheit](https://antigravity.google/docs/permissions/)
- [Antigravity-Terminal-Sandbox](https://antigravity.google/docs/sandbox/)
- [Antigravity-Regeln](https://antigravity.google/docs/rules/)
- [Antigravity-Skills](https://antigravity.google/docs/skills/)
- [VS-Code-Anweisungen](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [VS-Code-Agent-Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Modelle und Verfügbarkeit](https://antigravity.google/docs/models/)
