# Verbindungsbericht: VS Code, GitHub und Gemini

Stand: 23. Oktober 2026

## Ausgangszustand

### VS Code und GitHub

- Der geöffnete lokale Ordner war `C:\Users\strik\git-labor`; der Workspace-Kontext zeigte das GitHub-Projekt `mestuermer-svg/first`.
- Die GitHub-API war mit dem Konto `mestuermer-svg` erreichbar. Das bestätigte die GitHub-Kontoanmeldung, aber für sich allein noch keine Verknüpfung des lokalen Repositories.
- Im lokalen Repository gab es anfangs keinen Remote, keine Commits und den Branch `master`. `prozess-log.md` war unversioniert.
- Git war installiert, aber nicht im PowerShell-PATH. Das ausführbare Git wurde unter `C:\Program Files\Git\cmd\git.exe` gefunden.
- Die globale Git-Konfiguration gab `openssl` als HTTPS-SSL-Backend vor. Diese Git-for-Windows-Installation unterstützte hier `schannel`, nicht `openssl`.
- Das GitHub-Repository `mestuermer-svg/first` hatte den Branch `main` und enthielt `README.md` sowie `.vscode/extensions.json`.

### Gemini

- Installiert waren unter anderem Google Gemini Code Assist, Gemini CLI Companion, Gemini CLI Chat und eine Erweiterung namens Gemini Chat.
- In den VS-Code-Einstellungen waren `geminiCode.apiKey` befüllt und `geminiCode.useDirectAPI` aktiviert. Der Schlüsselwert wurde weder ausgegeben noch in diesen Bericht übernommen.
- Die Gemini CLI war installiert. Sie hatte zunächst keine eigene Authentifizierung in ihrer Umgebung.
- Die Erweiterung `galacticgit.gemini-chat` stellte laut lokal installiertem Erweiterungscode ein Chat-Webview bereit; in diesem Code war keine direkte Gemini-API-Verbindung erkennbar.

## Durchgeführte Änderungen

1. Das lokale Git-Repository erhielt den Remote `origin` mit der Adresse `https://github.com/mestuermer-svg/first.git`.
2. Nur für dieses Repository wurde `http.sslBackend` auf `schannel` gesetzt. Die globale Git-Konfiguration blieb unverändert.
3. Ein Fetch von GitHub war danach erfolgreich.
4. Der lokale Branch `main` wurde angelegt und so eingerichtet, dass er `origin/main` verfolgt.
5. Es wurde nichts nach GitHub gepusht. Die lokale, unversionierte `prozess-log.md` blieb erhalten.
6. Für den Gemini-CLI-Test wurde der in VS Code gespeicherte Schlüssel nur vorübergehend an den Testprozess übergeben; er wurde nicht dauerhaft als Windows-Umgebungsvariable gespeichert.

## Prüfergebnisse

- **GitHub:** Remote und Fetch funktionieren. Der lokale Status war `main...origin/main`; `prozess-log.md` blieb als unversionierte lokale Datei sichtbar.
- **Gemini API:** Nach dem Einfügen des neu erzeugten Schlüssels antwortete Googles lesende Modellabfrage erfolgreich und lieferte 50 Modelle. Der Schlüssel wurde dabei verborgen.
- **Gemini CLI:** Ein früherer Generierungstest mit dem damals gespeicherten Schlüssel erreichte Google, wurde aber mit HTTP 402 abgelehnt: Das Prepaid-Guthaben des zugehörigen AI-Studio-Projekts war aufgebraucht. Nach dem späteren Einfügen des neuen Schlüssels wurde nur die lesende Modellabfrage wiederholt. Eine Generierung mit diesem neuen Schlüssel wurde nicht erneut getestet; deren Abrechnungsstatus ist daher offen.
- **Gemini Code Assist-Anmeldung:** Ob die offizielle Google-Erweiterung zusätzlich über ein Google-Konto angemeldet ist, ließ sich mit den verfügbaren Statusprüfungen nicht feststellen.

## Hinweise

- Die frühere Eingabe `export GEMINI_API_KEY="YOUR_API_KEY"` setzte lediglich einen Platzhalter in einer Bash-Sitzung und machte keinen Schlüssel dauerhaft für PowerShell oder VS Code verfügbar.
- Für tatsächlich generierte Gemini-Antworten muss das AI-Studio-Projekt über verfügbares Kontingent beziehungsweise aktive Abrechnung verfügen. Die erfolgreiche Modellliste allein bestätigt keine verfügbare Generierung.
- Der Gemini-Schlüssel gehört nicht in ein versioniertes Markdown-Dokument. Dieses Protokoll enthält absichtlich keine Schlüsselwerte.
