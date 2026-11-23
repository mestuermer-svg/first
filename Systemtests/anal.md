# Technische Systemanalyse und Implementierungsleitfaden: Antigravity-Orchestrierung und Multi-Agenten-Architektur

Die Integration autonom agierender Künstlicher Intelligenz in lokale Entwicklungsumgebungen und echtzeitkritische Ausführungsknoten erfordert eine rigorose Balance zwischen operativer Handlungsfähigkeit und deterministischer Systemsicherheit. Die vorliegenden technischen Dokumentationen und Systemaudits beleuchten das Gesamtsystem der One Strike Cyborg Multi-Agenten-Architektur. Das System spannt ein heterogenes Netzwerk über mehrere physische Rechnerknoten auf, um anspruchsvolle Entwicklungs- und Simulationsaufgaben – insbesondere im Hochleistungs-Sim-Racing – parallelisiert und fehlertolerant abzuarbeiten. Dieser Bericht bündelt die analysierten Schwachstellen, implementierten Stabilisierungsmaßnahmen sowie die konzeptionellen Hebel der nächsten Entwicklungsstufe in einem kohärenten Architekturrahmen für die anstehende Diskussion und technische Umsetzung.

---

## 1\. Architektonische Leitmaxime und Vier-Ebenen-Steuerungsmodell

Der Entwurf einer ausfallsicheren Agenteninfrastruktur basiert auf dem Grundsatz, dass autonome Agenten weitreichende Problemlösungskompetenzen innerhalb streng definierter Mandate besitzen müssen, ohne jemals unkontrollierten Zugriff auf die Integrität des Host-Betriebssystems zu erhalten. Um dieses Spannungsfeld aufzulösen, formalisiert die Architektur eine hierarchische Steuerung, die von einfachen Ad-hoc-Befehlen bis hin zu autonomen Spezialisten reicht:

* **Ebene 1: Chat-Prompts (Einweganweisungen)** Sie dienen als flüchtige Einweganweisungen für isolierte, kurzlebige Einzelaufgaben, wie das Sortieren einer JSON-Datei oder die Analyse eines einzelnen Python-Blocks. Sie operieren mit minimalem Kontext und besitzen keinerlei Berechtigung, systemweite Änderungen zu veranlassen.
* **Ebene 2: Instructions (Globale Markdown-Regelwerke mit** **apply\_to** **)** Diese persistenten Markdown-Dokumente formulieren globale Leitplanken und Projektkonventionen. Über integrierte `apply_to`\-Muster werden sie dynamisch nur dann in das Arbeitsgedächtnis eines Agenten geladen, wenn dieser an einer übereinstimmenden Datei arbeitet. Wird beispielsweise ein API-Endpunkt editiert, werden gezielt die API-Regeln injiziert. Dies spart substanziell Token und schützt vor kognitiver Ablenkung.
* **Ebene 3: Skills (Modulare On-Demand-Werkzeugkoffer)** Als modular aufgebaute Werkzeugkoffer stellen Skills standardisierte, mehrstufige Arbeitsabläufe und Skripte bereit. Sie verbleiben im Dateisystem und werden von den Agenten erst on-demand referenziert – beispielsweise zur Strukturierung eines Datenbank-Deployments –, womit der permanente Speicherverbrauch minimiert wird.
* **Ebene 4: Custom Agents (** **.agent.md** **als Systemgrenze und DNA)** Als Fundament der Rechteverwaltung definiert die jeweilige `.agent.md`\-Datei die digitale Identität eines Agenten. Neben Persona und Aufgabenbereich werden hier unverletzliche Systemgrenzen, zulässige Arbeitsverzeichnisse und strikt verbotene Programmierschnittstellen (APIs) festgeschrieben.

---

## 2\. Topologie der Hardwareknoten und funktionale Agentenspezialisierung

Zur Verhinderung von kaskadierenden Systemausfällen setzt das System auf eine physische Entkopplung der Rechenlasten über vier getrennte Hardwareknoten. Diese Aufteilung verhindert, dass rechenintensive Entwicklungsaufgaben oder fehlerhafte Code-Ausführungen die Latenzzeiten zeitkritischer Prozesse negativ beeinflussen.

### Physische Knotenverteilung

| Hardware-Knoten                       | Spezifikation / Rolle               | Zugeordnete Agenten                | Aufgabenprofil und Schutzmechanismus                                                                                 |
| ------------------------------------- | ----------------------------------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| **Host-Laptop** *(VanstrikeCyborg)*   | Entwicklungs-Workstation, RTX 5060  | **General Agent (`@general`)**     | Globaler Systemarchitekt (`General Cyborg` & `General Sim`), Koordination der Workspaces, Ausführung im GitHub-Repo. |
| **Sim-Racer Workstation** (`.68`)     | Hochleistungsrechner, RTX 5070 Ti   | **`@light`**, **`@rig`**, **`@dark`** | Zeitkritische Ausführungsumgebung für Assetto Corsa (`acs.exe`), Docker-Orchestrierung (`@light`), VR/GPU (`@rig`) und Win11-Sandbox (`@dark`). |
| **Archibald / IdeaPad 5** (`.98`)     | Dedizierter Pitwall-Peripherieknoten | **`@sarah`**                       | Echtzeit-Telemetrieanalyse, Touch-Pitwall-Kiosk (`:8080`), Boxenmauer-Support, Setup-Optimierung und Videoschnitt.   |
| **StrikerPi** (`.86` / `.125`)        | Raspberry Pi Edgehub (24/7-Betrieb) | **`@rick`**                        | Kontinuierliche Hintergrundüberwachung, Telemetrie-Relay (`:8080`), Mosquitto MQTT (`:1883`) und Bare-Git-Server.    |

### Funktionale Rollenabgrenzung

Die Agentenrollen sind strikt auf ihre jeweilige Betriebsumgebung optimiert:

* **General Agent**: Residiert im Command Center auf dem Host-Laptop. Er besitzt als einziger Agent globale Autorität und überblickt den gesamten Projektstatus, delegiert jedoch operative Subtasks an die Peripherie.
* **Light Agent**: Operiert nativ auf der Sim-Racer-Workstation und verwaltet eigenständig die Docker-Infrastruktur sowie standardisierte Systemprozesse.
* **Rick Agent**: Fungiert als Hardware- und VR-Spezialist auf dem Sim-Racer. Er ist digital vollständig an seine Peripherie gebunden, wodurch Fehlfunktionen oder Halluzinationen zu keinem Zeitpunkt das Host-System gefährden können. Eine redundante Instanz von Rick läuft auf dem StrikerPi zur Ausführung dauerhafter Edge-Funktionen.
* **Dark Agent**: Dient als dedizierter Test- und Validierungsagent. Er ist vollständig in einer Windows 11 Sandbox bzw. einem isolierten Docker-Container eingesperrt, um potenziell instabile Skripte gefahrlos auszuführen.
* **Sarah Agent**: Verarbeitet an der Boxenmauer Telemetriedatenströme und bereitet Sektordeltazeiten auf.

---

## 3\. Granulare Ausführungssteuerung durch Antigravity und Gemini-Integrationen

Ein wiederkehrendes Grundproblem autonomer Agenten besteht im Wissens-Cutoff sowie dem Risiko unkontrollierter Befehlsausführungen auf Betriebssystemebene. Die Architektur löst dieses Problem durch eine dedizierte Werkzeugkette, die auf offiziellen Gemini-Schnittstellen und dem Antigravity-Tool aufsetzt.

&gt; Das Antigravity-Tool schlägt in Kombination mit den offiziellen Gemini Agent Skills eine kontrollierte Brücke zum Host-System: Über die Kommandozeile (CLI) lässt sich granular und absolut deterministisch steuern, welche Werkzeuge ein Agent aufrufen darf und ob für spezifische Systemdateien reine Lese- oder explizite Schreibberechtigungen gelten.

Die Bereitstellung externer Informationen und Werkzeugberechtigungen stützt sich auf vier Kanäle:

1. **Gemini Docs MCP Server**: Bindet kuratierte, maschinenlesbare Model-Context-Protocol-Endpunkte ein, um strukturierte Referenzdaten bereitzustellen.
2. **Maschinenlesbare** **llms.txt** **\-Dateien**: Stellen sicher, dass Agenten autoritative und tagesaktuelle Fakten ohne unkontrolliertes Websurfen beziehen.
3. **Offizielle Gemini Agent Skills**: Stellen validierte Funktionsaufrufe für Standardoperationen bereit.
4. **Antigravity CLI-Governance**: Gewährt Agenten präzise das für den spezifischen Task erforderliche Ausführungsminimum („Least-Privilege-Prinzip“). Eigenmächtige Modifikationen systemrelevanter Pfade werden auf CLI-Ebene unterbunden.

---

## 4\. Asynchroner Handshake-Bus: Analyse der Systemdefizite vom 10\. November und deren Stabilisierung

Um blockierende Timeouts bei langwierigen Rechenoperationen zu vermeiden, kommunizieren alle Agenten über ein dateibasiertes, asynchrones Warteschlangensystem (`Inbox`/`Outbox`) mittels JSON-Dateien. Dieses theoretisch robuste Paradigma zeigte in den End-to-End-Lasttests vom 10\. November schwerwiegende Schwachstellen, die durch gezielte Systemanpassungen behoben wurden.

### Diagnose der identifizierten Systemlücken

Die End-to-End-Prüfungen legten fünf kritische Defizite offen:

1. **Lücke 1 (Dark-Agent Race Condition)**: Der Dark Agent führte innerhalb der Sandbox einfache Validierungsaufgaben in unter zwei Sekunden aus und löschte die ursprüngliche Task-Datei umgehend. Da der übergeordnete General Agent das Verzeichnis in einem festen Polling-Intervall von zwei Sekunden abfragte, wurden abgeschlossene Tasks vollständig übersehen. Die Vorgänge verschwanden spurlos aus den Protokollen.
2. **Fehlendes Freigabeflag bei Rick**: Bei der Aufgabenübergabe von Rick an Light fehlte ein systemweites Freigabeflag, wodurch das Rig bei jedem Durchlauf für 15 Sekunden vollständig blockiert wurde.
3. **Pufferüberlauf der Telemetrie**: Fehlerhafte Abfrageintervalle führten zu einem unkontrollierten Anwachsen der Aufgabenwarteschlange von Sarah.
4. **SMB-Netzwerklatenzen**: Der standardmäßige Windows-SMB-Cache erzeugte bei der dateibasierten Kommunikation mit der virtuellen Maschine extreme Verzögerungen von bis zu 30 Sekunden für einfache Dateizugriffe.
5. **Null-Byte-Lesekollisionen**: Bei zeitgleichen Lese- und Schreibzugriffen zweier Agenten auf dieselbe JSON-Taskdatei traten Dateizugriffskonflikte auf, die zu unvollständigen Null-Byte-Payloads führten.

### Durchgeführte Stabilisierungsmaßnahmen

Das Entwicklerteam implementierte ein Bündel an Gegenmaßnahmen:

* **Eliminierung des SMB-Flaschenhalses**: Über einen gezielten Eingriff in die Windows-Registry wurde der SMB-Cache-Wert aggressiv auf `0` gesetzt, wodurch Dateisystem-Latenzen über Netzwerkgrenzen hinweg eliminiert wurden.
* **Atomare Dateioperationen**: Die JSON-Lese- und Schreibroutinen wurden auf atomare Zugriffe umgestellt und mit bis zu 10 automatischen Retry-Zyklen abgesichert.
* **Direktverbindung im Automodus**: Die blockierten Freigabeprozesse zwischen Rick, Light und dem General Agent wurden durch eine direkte Statusverknüpfung im Automodus über die Pitwall aufgelöst.
* **Implementierung des Intent Parsers**: Ein neuer Intent Parser reduziert die Latenz des synchronen Handshakes netzwerkweit auf verlässliche 2,1 Sekunden.
* **Sprachliche Standardisierung**: Als verbindliche Norm wurde die deutsche Sprache für sämtliche Agentenantworten fest im System verankert.

---

## 5\. Resiliente Mandatsverwaltung über eine Operational State Machine

Ein zentrales architektonisches Spannungsfeld besteht zwischen dem asynchronen GitLab-Entwicklungs-Workspace auf dem Laptop und dem hochgradig echtzeitkritischen Assetto-Corsa-Workspace auf dem Sim-Racer. Jede Latenz oder CPU-Unterbrechung auf dem Sim-Racer kann im Grenzbereich zum Einfrieren der Lenkrad-Telemetrie führen.

### Schwachstelle statischer Mandatswechsel

Bislang steuerte eine Konfigurationsdatei (`pitwall_control_policy.json`) die globalen Betriebsmodi:

* `Manual`: Vollständige Kontrolle beim Fahrer; KI-Aufgaben ruhen.
* `Delegated`: Geteilte Ausführung mit spezifischen Prüfpfaden.
* `Auto`: Vollautonome Abarbeitung von Entwicklungs- und Testaufgaben.

Wird bei Start der VR-Session (`acs.exe`) der Status in der Policy abrupt auf `Manual` gesetzt, entzieht das System formal das Mandat. Da das Umschreiben einer Variablen laufende I/O-Prozesse der asynchronen Agenten (wie Light oder Dark) jedoch nicht stoppt, werkeln diese in ihren Containern weiter. Schreibt der Dark Agent in diesem Moment an einem umfangreichen Setup-File oder führt eine Syntaxprüfung durch, führt das Kappen der Schnittstellen zu verwaisten Dateisperren, verstopften Inboxes und inkonsistenten Zuständen beim nächsten Neustart.

### Die Operational State Machine als Lösungsansatz

Anstelle eines abrupten Abbruchs („Graceful Exit“) implementiert das System ein Verfahren der geordneten Degradierung („Graceful Degradation“), das in fünf aufeinanderfolgenden Phasen abläuft:

1. **Ereignisgesteuerte Erkennung**: Der Hardware-Watchdog `rig_watchdog.ps1` registriert das Einschalten der VR-Brille.
2. **Injektion von Pause-Tasks**: Statt Docker-Container hart zu pausieren, erzeugt der Watchdog ein minimales JSON-Objekt mit höchster Priorität und platziert es direkt in den Inboxes von Light und Dark.
3. **Zustandssicherung**: Die Subagenten greifen diesen Task im nächsten Ausführungszyklus auf, unterbrechen laufende Validierungen, sichern den aktuellen Verarbeitungs-Pointer und schreiben den Exit-Code `Paused` oder `Ignored` in ihre Outbox.
4. **Hop-Count-Validierung**: Über eine integrierte Routing-Logik mit einem Hop-Count kleiner als `2` erkennt die übergeordnete Leitstand-Instanz (General Sim), dass es sich um eine interne Systemquittung handelt. Die ursprüngliche Aufgabe verbleibt geordnet in der Warteschlange.
5. **Freigabe der Hardware**: Erst nachdem sämtliche Subagenten den Pausierungs-Handshake erfolgreich bestätigt haben, schaltet die State Machine die Policy auf `Manual`. Dieser gesamte Vorgang vollzieht sich im Millisekundenbereich und garantiert konsistente Dateisysteme.

---

## 6\. Kontext-Scoping und kognitive Entlastung (Need-to-Know-Protokoll)

In lokalen Entwicklungsumgebungen stehen begrenzte Hardwareressourcen zur Verfügung (unter anderem eine RTX 5060 im Host-Laptop). Ein unkontrolliertes Aufblähen des Kontextfensters verlangsamt die Inferenzzeiten drastisch und erhöht das Risiko von Halluzinationen.

### Defizit der ganzheitlichen Wissensverteilung

Bisher nutzte das System ein zentrales Verzeichnis (`memories/repo` sowie `preferences.md`), um Erfahrungswerte ohne teures Modell-Finetuning persistent zu halten. Dabei wurde jedoch das gesamte Wissen pauschal an jeden Agenten verteilt. Wurde der Dark Agent in seiner Sandbox gestartet, injizierte sein Startskript (`worker.ps1`) sämtliche Hardware-Logs, VIVR-Fehlercodes und Telemetriemetriken der RTX 5070 Ti in den System-Prompt – selbst wenn die Aufgabe lediglich in der Syntaxprüfung eines simplen Python-Skripts bestand.

### Agent-Scoped Memories und dynamische Kontext-Subsets

Zur Beseitigung dieses Flaschenhalses wird ein striktes Need-to-Know-Prinzip auf zwei Ebenen etabliert:

* **Dateisystem-Kapselung (Agent Scoped Memories)**: Auf Betriebssystemebene erhält der Dark Agent ausschließlich Lesezugriff auf den Pfad `memories/sandbox/`. Systembereiche wie `memories/host/hardware/` existieren für ihn nicht. Hardware- und Telemetriedaten werden vollständig ausgeblendet.
* **Dynamisches JSON-Feld** **Context\_Subset**: Bei der Aufgabenübergabe über den Handshake-Parameter `Action: Route to Agent` wird nicht der gesamte Thread-Verlauf übergeben. Stattdessen spezifiziert der Leitstand im neuen Pflichtfeld `Context_Subset` exakt die relevanten Module.

```
{
  "task_id": "sim_cfg_parse_081",
  "action": "Route to Agent",
  "target_agent": "Dark",
  "context_subset": [
    "Assetto_Corsa_Config",
    "ini_parsing"
  ]
}

```

Muss beispielsweise eine `race.ini` geparst werden, lädt der Dark Agent ausschließlich die Konfigurations- und INI-Parsing-Spezifikationen. Seine Python-Test- oder Web-Scraping-Fähigkeiten werden ignoriert. Diese Reduktion senkt den Prompt-Umfang von typischerweise 4.000 Tokens auf schlanke 500 Tokens, minimiert die Latenz und entlastet die lokale GPU.

---

## 7\. Prädiktives Ressourcen-Dispatching: Deterministische Heuristik im hybriden LLM-Router

Zur Ausführung von Sprachmodellen greift die Architektur auf ein hybrides Verbundnetzwerk zu:

* Lokale Instanzen via Ollama auf dem Host-Laptop (z. B. Gemma für leichtgewichtige Abfragen).
* Leistungsfähigere lokale Modelle auf der Sim-Racer-Workstation (z. B. Qwen 2.5 Coder auf der RTX 5070 Ti).
* Cloud-Inferenz über Google Vertex AI für hochkomplexe Analysen.

### Limitationen des bestehenden Routers

Die Datei `hybrid_lm_router.py` steuert die Modellkaskadierung bislang vorwiegend reaktiv anhand harter Hardware-Trigger (z. B. Entladen der VRAM-Modelle auf der RTX 5070 Ti bei Start von Assetto Corsa) oder über statische Befehlsparameter (`workload=code`). Eine vorausschauende Bewertung der tatsächlichen Aufgabenkomplexität vor der Inferenz fehlte.

### Deterministisches Complexity &amp; Token Assessment

Ein semantischer LLM-Aufruf zur Komplexitätsprüfung scheidet aus, da er exakt die Latenzen erzeugen würde, die durch lokale Modelle vermieden werden sollen. Stattdessen analysiert eine vorgeschaltete, leichtgewichtige Heuristik die strukturellen Metadaten des JSON-Payloads mittels Regex und Zähloperatoren:

1. Anzahl der angehängten Dateien.
2. Summe der Zeilen in übergebenen Protokolldateien.
3. Verschachtelungstiefe des JSON-Objektbaums.

Aus diesen Parametern errechnet der Router in Bruchteilen einer Millisekunde einen deterministischen Kennwert (`weight_score`):

| Berechneter Weight-Score                      | Ressourcen-Status der Hardware                           | Ausgewählte Inferenz-Instanz                      | Verarbeitungslogik                                                                          |
| --------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| **Niedrig** *(z. B. Sarah Voice Coaching)*    | Beliebig; geringe Last                                   | **Lokales Laptop-Modell** *(Gemma via 127.0.0.1)* | Sofortige lokale Ausführung; schont GPU-Speicher der RTX 5070 Ti vollständig.               |
| **Mittel** *(z. B. Standard-Codeanalyse)*     | Normalbetrieb, 5070 Ti verfügbar                         | **Sim-Racer Modell** *(Qwen 2.5 Coder)*           | Lokale Beschleunigung auf dedizierter Workstation.                                          |
| **Hoch** *(z. B. Refactoring über 5 Dateien)* | Sim-Racer frei, Budget aktiv                             | **Vertex AI Cloud** oder 5070 Ti                  | Parallele Abarbeitung ohne Performance-Einbußen.                                            |
| **Hoch** *(z. B. Multi-Script-Refactoring)*   | Sim-Racer blockiert (`keep_alive=0`), Cloud-Budget aktiv | **Google Vertex AI Cloud**                        | Automatische, geräuschlose Eskalation in die Cloud zur Vermeidung lokaler Überhitzung.      |
| **Hoch**                                      | Sim-Racer blockiert, Cloud-Budget erschöpft              | **High-Weight Queue**                             | Einreihung in priorisierte Warteschlange; Abarbeitung erst nach Rennende und VRAM-Freigabe. |

* **Szenario Sarah (Telemetrie)**: Ein Array mit drei Sektordeltazeiten für das Voice-Coaching weist einen minimalen Weight-Score auf. Der Router leitet den Task sofort an das lokale Laptop-Modell (`127.0.0.1`), womit die RTX 5070 Ti unberührt bleibt.
* **Szenario Refactoring**: Übergibt der General Agent ein Skript-Refactoring über fünf Dateien hinweg, schießt der Score in den roten Bereich. Ist die Sim-Racer-Workstation durch ein aktives Rennen blockiert (`keep_alive = 0`), eskaliert das System den Task geräuschlos an Vertex AI.
* **Budgetdeckelung und High-Weight Queue**: Um unkontrollierte Cloud-Kosten zu verhindern, ist die Heuristik an ein Session-Budget gekoppelt. Ist dieses erschöpft und die lokale Workstation gesperrt, parkt der Router den Task in einer priorisierten `High-Weight Queue`. Die Abarbeitung erfolgt erst nach Beendigung des Rennens, sobald der VRAM der 5070 Ti wieder freigegeben ist.

---

## 8\. Das zweistufige Sicherheitsfundament: Change Freeze und manuelles Terminal-Freigabegate

Die fortschreitende Autonomie von Agenten birgt das immanente Risiko, dass fehlerhafte Code-Generierungen oder Halluzinationen Kernkonfigurationen beschädigen. Zur Beherrschung dieses Risikos implementiert das Gesamtsystem eine strikte zweistufige Sicherheitsarchitektur.

### Der unverletzliche Change Freeze

Die wichtigste Schutzrichtlinie untersagt der KI jegliche eigenmächtige Modifikation an den Kernstrukturen des Systems:

* `.agent.md`\-Profile und Persona-Definitionen.
* Globale Instruktionen und System-Prompts.
* Zentrale Konfigurationsdateien wie `approval_policy.json` und `tasks.json`.

Agenten besitzen vollen Freiraum, Anwendungs- und Testcode zu schreiben oder Telemetriedateien auszuwerten. Sobald ein Schreibversuch auf eine geschützte Konfigurationsdatei detektiert wird, erzwingt das System einen sofortigen Stopp und generiert eine manuelle Diff-Vorschau.

### Das General-Freigabeprotokoll im Terminal

Für alle als kritisch eingestuften Payloads greift ein deterministisches Genehmigungsverfahren auf dem Host-Laptop:

1. **Payload-Isolation**: Ein Remote-Agent (beispielsweise Rig oder Light) erzeugt einen kritischen Code-Payload, parkt diesen isoliert im Verzeichnis `/approvals/` und pausiert die Ausführung.
2. **Signalisierung**: Eine Benachrichtigung wird direkt in die Terminal-Inbox des Entwicklers auf dem Host-Laptop (`VanstrikeCyborg`) sowie parallel in die Pitwall-Steuerungskonsole (`http://192.168.178.86:8080/`, Tab `🛡️ Agenten & Light`) übermittelt.
3. **Menschliche Prüfung und Steuerung**: Der Entwickler inspiziert den Code und steuert den weiteren Ablauf über drei standardisierte Terminal- bzw. Pitwall-Befehle:
  * `ok` / `approve`: Gibt den geprüften Auftrag frei und reiht ihn mit `approved_by` in die Ziel-Inbox ein.
  * `nein <Grund>` / `reject`: Lehnt den Auftrag ab, archiviert den Versuch im Audit-Log und sendet den Status `Rejected` an den anfragenden Agenten zurück.
  * `reply <Anweisung>` / `delegate`: Übergibt eine korrigierte Vorgabe oder delegiert eine geprüfte Aufgaben-Kategorie (`session_presets`, `sandbox_dark_tasks`) im Modus `DELEGATED` zeitlich begrenzt an `@light`, während der **Change-Freeze** (`.agent.md`, `AGENTS.md`, `SKILL.md`, `settings.json`, `mcp.json`, `approval_policy.json` sowie gegenseitige Agenten-Änderungen) technisch dauerhaft gesperrt bleibt.