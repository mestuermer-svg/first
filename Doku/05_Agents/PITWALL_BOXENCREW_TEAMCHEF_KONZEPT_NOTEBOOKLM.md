# Konzept-Entwurf: Pitwall Mechaniker-Boxencrew & Teamchef-Strategie (v0.1 – Stand 25.11.2026)

> **Status dieses Dokuments:** Frühes Strategie- und Architekturkonzept (**Entwurf v0.1**, noch keine Produktiv-Konfigurationen geändert). Optimiert als flache Markdown-Quelle für **Gemini NotebookLM** (ohne einklappbares HTML/CSS).
> **Aufbauend auf:** [PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md](./PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md) (Pitwall `v2.1.0` & Agentensteuerung `Architektur v5`, Stand 25.11.2026).

---

## 1. Zielbild & Strategische Leitidee

Mit der Ausbaustufe **„Boxencrew & Teamchef“** überträgt die Pitwall die reale Arbeitsweise eines Motorsport-Kommandostands auf die vorhandene **5-Knoten-Infrastruktur** und **Architektur v5**:

1. **Klare Trennung zwischen Strategie und Schraubarbeit:**
   * Der **Teamchef** denkt in Sessions, Stints, Performance, Setup-Zielen und Risikoabwägung (Strategie & Priorisierung).
   * Die **Mechaniker-Boxencrew** setzt konkrete technische Maßnahmen kontrolliert am Rig, in der Win11-Sandbox, am Streaming oder in der Telemetrie um.
2. **Qualität & Sicherheit vor Geschwindigkeit:**
   * Auch wenn sich die Crew wie ein Boxenteam verhält, bleiben **Chefmechaniker `@light`** als alleiniger Host-Orchestrator, die **2-Stufen-QA (`light_verifier.py`)**, das **Leitstand-Protokoll (`leitstand_protocol.py`)**, der **Change-Freeze** sowie die **`0 %` GPU-Schutzregel im `LIVE_RACE`** vollständig erhalten.
3. **Wachstum über Werkzeugkoffer statt Agenten-Chaos:**
   * Neue Mechaniker-Fähigkeiten entstehen bevorzugt als klar definierte Werkzeuge (`toolbox.json` / `TOOLBOX.md`) und über dokumentierte Ausbauvorschläge (`report_capability_gap`), nicht durch unkontrollierte Ad-hoc-Skripte.

---

## 2. Steuerungslogik in der Pitwall: `MANUAL` vs. `DELEGATED` vs. `AUTO`

In der Pitwall-Oberfläche (`🛡️ Agenten` → `🤝 Freigabe-Matrix`) steuert der globale Freigabe-Modus **ausschließlich das Genehmigungs-Gate** (also *wer* einen Auftrag vorab freigeben muss). **Wichtig für das Systemverständnis:** Keiner dieser Modi schaltet die Befehlskette (`General SIM` → `@light` → Worker), die 2-Stufen-QA, das `📋 Leitstand-Protokoll` oder den Change-Freeze ab.

### 2.1 Technische Wirkung laut Implementierung (`pitwall_control_policy.json`, `start_light_terminal.ps1`, `sim_agent_bridge.py`)

Die Auswertung in `Test-LightDelegatedApproval` und in der Bridge folgt einer festen Prioritätsregel:

1. **Höchste Priorität — Sicherheits- & Agenten-Sperren (stechen immer die Matrix):**
   * **Change-Freeze (`change_freeze_locked: true`):** Änderungen an `*.agent.md`, `AGENTS.md`, `SKILL.md`, `approval_policy.json`, `pitwall_control_policy.json`, `settings.json`, `mcp.json` und `tasks.json` sind in *allen* Modi hart gesperrt.
   * **Einzel-Agenten-Status (`agent_states`):** Steht ein Agent oben in `🤖 Agenten & Status` auf `paused` oder `disabled`, wird jeder Auftrag an ihn sofort blockiert (`[PITWALL-GATE BLOCK]`) – auch bei globalem `AUTO`.
   * **`LIVE_RACE` / GPU-Guardrail:** Bei `gpu_background_allowed: false` oder aktiven Prozessen (`acs.exe`, `acs_x86.exe`, `vrserver.exe`) bricht die lokale Ollama-Runtime (`agent_ollama_tool_runtime.py`) sofort mit `Blocked` ab (`0 %` GPU-Zusatzlast).
   * **Kategorie auf `LOCKED`:** Eine in der Matrix auf `LOCKED` gesetzte Kategorie bleibt selbst im `AUTO`-Modus blockiert (`KATEGORIE GESPERRT`).

2. **Die drei globalen Modi im direkten Vergleich:**

| Modus | Wie entscheidet das Gate? | Hierarchie (`General` → `@light` → Worker) | 2-Stufen-QA & `📋 Leitstand-Protokoll` | Typischer Einsatzzweck (Boxencrew) |
| :--- | :--- | :--- | :--- | :--- |
| **`MANUAL`** (`🙋 MANUAL`) | Erfordert immer eine explizite Vorabfreigabe durch Leitstand/Nutzer (`📥 Anträge & Audit`). Ohne `General_Cyborg`/`General_Sim`/`Light` blockt auch `sim_agent_bridge.py` Worker-Direktziele. | **Aktiv** (strikter Leitstand-Durchlauf) | **Immer aktiv** (alles wird geprüft & protokolliert) | Neue Boxencrew-Werkzeuge erproben, tiefgreifende System-/Windows-/Treiber-Eingriffe, Fehlersuche unter manueller Aufsicht. |
| **`DELEGATED`** (`🤝 DELEGATED`) | `@light` darf Aufträge nur in Kategorien mit Richtlinie **`LIGHT_AUTO`** selbst freigeben (`ApprovedBy = LightAgent_Delegated`) – solange das Zeitmandat (`Unbegrenzt`, `+60m`, `+180m`) läuft. Kategorien auf **`ASK_USER`** fragen weiterhin in `📥 Anträge & Audit`. | **Aktiv** (delegierte Entscheidungsbefugnis nach Kategorie) | **Immer aktiv** (inkl. Vorher/Nachher-Nachweis) | **Empfohlener Standard für Boxencrew-Betrieb:** Routine-Checks/Sandbox-Tests (`LIGHT_AUTO`) laufen eigenständig, heikle Host-Eingriffe (`rig_actions` auf `ASK_USER`) warten auf OK. |
| **`AUTO`** (`⚡ AUTO`) | Alle Kategorien, die **nicht** `LOCKED` sind (also auch Kategorien mit Einstellung `ASK_USER`), erhalten sofort automatische Policy-Freigabe (`ApprovedBy = GeneralAgent_AutoPolicy`). *Hinweis:* Im Live-Zustand vom 25.11. steht `mode: "AUTO"` bei `ASK_USER` auf allen 5 Kategorien und allen 6 Agenten auf `active`. | **Weiterhin aktiv** (`@light` bleibt Orchestrator & QA-Gate) | **Immer aktiv** (auch Auto-Läufe und Prompts erscheinen im Protokoll) | Schneller Serien- oder Testbetrieb im Leerlauf (`Garage / Idle`), bei dem bekannte Aufträge und Prompts ohne Einzelklick-Bestätigung durchlaufen sollen. |

### 2.2 Zwei häufige Missverständnisse aufgelöst

* **Missverständnis 1 – „Hebelt `AUTO` die Hierarchie aus?“:**
  **Nein.** `AUTO` hebt lediglich die *manuelle Klick-Hürde* in der Freigabe-Matrix (`ASK_USER`) auf. Die Architektur-v5-Kette (`General SIM` → `@light` → `@rig`/`@dark`), die 2-Stufen-QA (`light_verifier.py`), das `📋 Leitstand-Protokoll`, der `execution_mutex.lock`, `LOCKED`-Kategorien und der Change-Freeze bleiben zu 100 % wirksam.
* **Missverständnis 2 – „Braucht `@sarah` den `AUTO`-Modus für Telemetriedaten?“:**
  **Nein.** `@sarah`s passiver Telemetrie-Empfang (`sarah-pitwall-telemetry.service`, UDP `:9996` auf `Archibald`) ist eine fest zugewiesene Dienst-Fähigkeit und hängt **nicht** von `AUTO` vs. `DELEGATED` ab. Entscheidend ist lediglich, dass `@sarah` in `agent_states` auf `active` steht (und für Cyborg-GPU-Auswertung `sarah_cyborg_gpu_allowed: true` gilt). Der Freigabe-Modus bestimmt nur, ob **aktive Aufträge/Mutationen** über die Matrix einzeln abgenickt werden müssen.

### 2.3 Schaltbare Matrix-Kategorien (Ist-Bestand & Bedeutung für die Crew)

* `session_presets` (Standard-Vorgabe im Code: `LIGHT_AUTO`) — Session-, Wetter- und Trainings-Voreinstellungen.
* `sandbox_dark_tasks` (Standard: `LIGHT_AUTO`) — Setup-/Content-Tests durch `@dark` in `ac-win11-sandbox`.
* `sandbox_lifecycle` (Standard: `ASK_USER`) — Start, Stopp, Pause und Resume der Win11-Sandbox.
* `content_sync` (Standard: `ASK_USER`) — Synchronisation geprüfter Dateien/Setups (unter Beachtung der Read-Only-Grenzen).
* `rig_actions` (Standard: `ASK_USER`) — Hardware-, Display-, NVIDIA-, VR- und Rig-Eingriffe durch `@rig`.

---

## 3. Rollen- & Crew-Architektur (Soll-Modell auf 5 Knoten)

Das Boxencrew-Konzept mappt Motorsport-Rollen direkt auf bestehende Knoten und Agenten – ohne parallele Schattenstrukturen aufzubauen:

```text
Fahrer (Im Rig / VR / Touch-Kiosk / Voice)
   │
   ▼  Strategie- & Zielvorgabe ("Untersteuern in Turn 4", "VR-Check nach Stint")
TEAMCHEF (Strategie-Ebene: Leitstand General SIM + @sarah Kontext)
   │  Plant Reihenfolge, wägt Risiko ab, prüft LIVE_RACE vs. GARAGE
   ▼
CHEFMECHANIKER / WERKSTATTLEITER (@light auf SimRacer)
   │  Einziger Host-Orchestrator: Policy-Gate, Mutex, Delegation, 2-Stufen-QA
   ├──► Hardware-, VR- & Display-Mechaniker (@rig auf SimRacer)
   ├──► Sandbox- & Setup-Mechaniker        (@dark in ac-win11-sandbox)
   ├──► Telemetrie- & Funk-Ingenieurin     (@sarah auf Archibald, UDP :9996 -> :8092)
   └──► Boxengassen- & Relay-Techniker      (@rick auf StrikerPi :8080 / MQTT :1883)
```

### 3.1 Detailbeschreibung der Crew-Rollen

| Crew-Rolle | Basis im System | Aufgaben & Verantwortung | Grenzen / Schutzregeln |
| :--- | :--- | :--- | :--- |
| **Teamchef (Strategie)** | Ausbau-Layer über `General SIM` (`VanstrikeCyborg`) gekoppelt mit Pitwall-Status & `@sarah`-Kontext | Übersetzt Fahrerwünsche in konkrete Aufgabenpakete; entscheidet *was* und *wann* (z. B. erst nach Stint-Ende); steuert Prioritäten und Freigabe-Strategie (`DELEGATED` vs. `MANUAL`). | Führt **keine** direkten Host- oder Registry-Änderungen aus; respektiert Change-Freeze. |
| **Chefmechaniker (`@light`)** | Bestehender Host-Orchestrator auf `SimRacer` | Zerlegt Teamchef-Aufträge in technische Arbeitspakete für `@rig` / `@dark`; erzwingt `pitwall_control_policy.json`, `execution_mutex.lock` und `light_verifier.py` (Stufe A + B); erstellt Handoffs. | Akzeptiert keine Schein-Erfolge; dokumentiert jede Lücke über `report_capability_gap`. |
| **Hardware-/VR-Mechaniker (`@rig`)** | Bestehender Facharbeiter auf `SimRacer` (`qwen3.5:9b`, `rig_display_tuner.py`) | Display/ClearType (Hisense 4K-TV), NVIDIA-Treibercheck, VR-Diagnose (`vr_tweaks.ini`), Rig-Hub, geplante Erweiterung für Force-Feedback-/Pedal-Tools (z. B. Fanatec-Kalibrierung). | Darf während `LIVE_RACE` (`acs.exe`/`vrserver.exe`) keine GPU-Last erzeugen (`Blocked`). Backup Pflicht. |
| **Setup-/Sandbox-Mechaniker (`@dark`)** | Bestehender Guest-Worker in `ac-win11-sandbox` (`:2222`) | Probiert AC-Fahrzeug-Setups (`.ini`), Track-/Session-Presets und Content isoliert gegen `:ro`-Mounts (`Original_AC_Content` / `Original_AC_Settings`) aus, bevor etwas ans Produktiv-Rig geht. | Keine direkten Host-Zugriffe außerhalb definierter Sandbox-Pfade. |
| **Telemetrie- & Funk-Ingenieurin (`@sarah`)** | Bestehender Service auf `Archibald` (`192.168.178.98`) | Wertet 50-Hz-Telemetrie (`:9996`) in Echtzeit aus (Reifentemperatur, Balance, Rundenzeiten, Stints) und funkt gezielt über SimRacer VR Radio Bridge (`:8092`). Liefert dem Teamchef die Datenbasis für Boxen-Aufträge. | Im Rennbetrieb rein beobachtend & beratend; löst ohne Freigabe keine Host-Mutationen aus. |
| **Boxengassen-Technik (`@rick`)** | Bestehender Agent auf `StrikerPi` (`192.168.178.86`) | Überwacht Pitwall-Relay (`:8080`), Mosquitto-MQTT (`:1883`), Stream-Verfügbarkeit und Kiosk-Gesundheit von `Archibald`. | Kein Zugriff auf `SimRacer`-Hardware oder AC-Setups. |

*Hinweis zu künftigen Crew-Spezialisierungen:* Zusätzliche Fächer (z. B. **Setup-Analyst** für `.ini`-Diffs nach dem Stint oder **FFB-/Pedal-Kalibrator**) sollten primär als neue, QA-geprüfte Werkzeuge in den Koffer von `@dark` bzw. `@rig` wandern und nur dann als eigener Worker ausgegliedert werden, wenn ein eigener Hardware-Knoten oder eine isolierte Laufzeitumgebung nötig ist.

---

## 4. Betriebsphasen & Kommunikationswege (`LIVE_RACE` vs. `GARAGE`)

Damit ein Boxenteam im SimRacing-Alltag hilfreich bleibt und niemals die Frame-Times in VR stört, gelten zwei klar getrennte Betriebsphasen:

### 4.1 Phase A: Auf der Strecke (`LIVE_RACE`)
* **Erlaubt:**
  * 50-Hz-Telemetrie an `StrikerPi` & `Archibald`, Funk-Coaching durch `@sarah`, Überwachung durch `@rick`.
  * **Vormerken (Queueing):** Erkennt `@sarah` ein Problem oder gibt der Fahrer per Voice (`voxtype` / `/api/voice/dispatch`) einen Wunsch durch (z. B. *„Für den nächsten Stopp mehr Reifendruck hinten prüfen und VR-Log ziehen“*), erstellt der Teamchef daraus ein vorgemerktes Ticket in der **Post-Stint-Warteschlange** (`PENDING_BOXENSTOPP`).
* **Hart gesperrt:**
  * Jede GPU-/Ollama-Ausführung (`qwen3.5:9b`) auf `SimRacer`, Registry-/Display-Änderungen oder Sandbox-Neustarts.

### 4.2 Phase B: In der Box / Leerlauf (`GARAGE / IDLE`)
* Sobald das Auto in der Box steht oder die Sim-Session beendet ist (`acs.exe` inaktiv, `gpu_background_allowed: true`), gibt der Teamchef die vorgemerkten Boxenstopp-Aufträge frei (je nach Modus per `DELEGATED` oder Klick in `📥 Anträge & Audit`).
* **Durchlaufkette:**
  1. Auftrag geht über `Send-SimAgentTask.ps1` / `sim_agent_bridge.py` (mit `execution_mutex.lock`) an `@light`.
  2. `@light` delegiert je nach Kategorie an `@dark` (Setup-Test in Sandbox) und/oder `@rig` (Rig-/VR-/Hardware-Maßnahme).
  3. Worker liefert Vorher-Werte, Änderungen, `backup_file` und Evidenz (oder ehrlich `MissingCapability` via `report_capability_gap`).
  4. `light_verifier.py` prüft Stufe A (Real-State) und Stufe B (Sauberer Pfad).
  5. `@light` schreibt den Bericht ins `📋 Leitstand-Protokoll` (`leitstand_protocol.py`) sowie das Handoff-Paket nach `general-SIM\doc_handoffs\`.
* **Selbstlernende Crew (`MISSING_TOOLS_REPORT.md`):** Fehlt für einen Fahrerwunsch ein Werkzeug (wie beim E2E-Test `e2e_missing_tool_20261125` für Fanatec-Loadcell-Kalibrierung), erscheint in der Pitwall unter Ebene 2 (`🔧 Ollama-Ausbauvorschlag`) direkt der Entwurf für das fehlende Tool inklusive Parameter-Schema und Risikoklassifizierung.

---

## 5. Grober 4-Phasen-Umsetzungsplan (Roadmap)

Diese Roadmap beschreibt die schrittweise Einführung, ohne bestehende Produktivabläufe zu gefährden:

| Phase | Schwerpunkt | Konkrete Arbeitsschritte | Messbares Zwischenergebnis („Done“) |
| :--- | :--- | :--- | :--- |
| **Phase 1: Rollen & Werkzeugkoffer** | Crew-Rollen schärfen & Toolboxes erweitern | • Aufgaben zwischen Teamchef (Strategie), `@light` (Chefmechaniker), `@rig`, `@dark`, `@sarah` und `@rick` verbindlich abgrenzen.<br>• Geplante Mechaniker-Werkzeuge in `toolbox_manager.py` modellieren (z. B. AC-Setup-Reader/-Vergleicher als `read_only`, Preset-Anwendung als `mutating` mit Pflicht-Backup).<br>• Change-Freeze und GPU-Guardrail als harte Invarianten festschreiben. | Aktualisierte Entwürfe für `toolbox.json` / `TOOLBOX.md` liegen vor; Read-Only- und Mutating-Tools sind sauber getrennt. |
| **Phase 2: Kommunikation & Policy-Matrix** | Datenflüsse & Freigabe-Regeln definieren | • Post-Stint-Queue (`PENDING_BOXENSTOPP`) zwischen Telemetrie/Voice (`@sarah`/Pitwall) und `@light`-Inbox entwerfen.<br>• Freigabe-Matrix (`pitwall_control_policy.json`) pro Kategorie auf den Boxencrew-Alltag abstimmen (z. B. Analyse-Tools `LIGHT_AUTO` für `DELEGATED`, Hardware-Eingriffe `ASK_USER`).<br>• Standard-Ticketformat für Fahrer-Voice -> Teamchef -> `@light` festlegen. | Eindeutige Schnittstellenbeschreibung für Voice/Telemetrie -> Teamchef -> `@light` und definierte Kategorie-Regeln für `MANUAL`/`DELEGATED`/`AUTO`. |
| **Phase 3: Integration in Architektur v5 & QA** | Verifikation & Pilotläufe mit `@light` | • Neue Stufe-A-Prüfungen in `light_verifier.py` für Mechaniker-Tools ergänzen (z. B. gültige `.ini`-Syntax, Backup-Nachweis, AC-Original-Integrität).<br>• Pilot-E2E-Testreihe fahren: (1) Setup-Analyse in `@dark`, (2) Hardware-/Display-Aktion in `@rig`, (3) Abbruch-Nachweis bei laufendem `LIVE_RACE`, (4) `MissingCapability`-Test bei fehlendem Mechaniker-Tool. | Alle 4 Pilotfälle im `📋 Leitstand-Protokoll` sauber als `VerifiedSuccess`, `Blocked` bzw. `MissingCapability` belegt. |
| **Phase 4: Pitwall-UI & Live-Telemetrie-Anbindung** | Bedienbarkeit auf `Archibald` (`StrikerPi :8080`) | • Eigene Boxencrew-Ansicht / Kachelreihe in `#page-control` (Teamchef-Strategie, vorgemerkte Stint-Aufträge, aktiver Mechaniker-Status).<br>• Verknüpfung von Telemetrie-Events (z. B. Stint-Ende, Boxeneinfahrt) als optionale Vorschlags-Trigger an den Teamchef (im `DELEGATED`-Modus erst nach Strategie-/Nutzer-Bestätigung aktiv).<br>• Direkte Verlinkung jeder Crew-Aktion in das bestehende 3-stufige `📋 Leitstand-Protokoll`. | Touch-taugliche Steuerung auf `Archibald` + lückenlose Rückverfolgbarkeit bis in die Roh-Evidenz (`#protoLevel2`). |

---

## 6. Offene Strategie- & Designfragen (für NotebookLM-Brainstorming)

Für die gemeinsame Weiterentwicklung dieses Entwurfs in **Gemini NotebookLM** bleiben folgende Punkte bewusst offen zur Diskussion:

1. **Teamchef-Implementierung:** Soll der Teamchef als logische Rollen-Erweiterung auf `General SIM` (`VanstrikeCyborg`) + Strategie-Prompt von `@sarah` arbeiten, oder lohnt sich ein dedizierter Strategie-Agent direkt neben `@light`?
2. **Strenge im `DELEGATED`-Modus:** Welche konkreten Boxenstopp-Aktionen dürfen als `LIGHT_AUTO` automatisch durch `@light` freigegeben werden (z. B. rein lesende Telemetrie-/Setup-Analysen oder Sandbox-Tests in `@dark`) und welche müssen immer `ASK_USER` bleiben (z. B. Änderungen am produktiven Car-Setup oder Force-Feedback)?
3. **Automatische vs. manuelle Trigger bei Boxeneinfahrt:** Soll der Teamchef bei erkanntem Stint-Ende selbstständig einen *Vorschlag* auf der Pitwall einblenden („Boxencrew bereit: 2 vorgemerkte Aufgaben ausführen?“) oder in `AUTO` sofort die Queue abarbeiten lassen?
4. **Erstes Pilot-Mechaniker-Tool:** Welches konkrete Werkzeug bringt im ersten Schritt den größten praktischen Nutzen — der **Post-Stint AC-Setup-Inspektor (`@dark`)** oder ein **Fanatec/Rig-Hardware-Werkzeug (`@rig`)** aus `MISSING_TOOLS_REPORT.md`?
5. **Sprach-Workflow im Cockpit:** Wie werden kurze Fahrer-Ansagen über `voxtype.service` zuverlässig in strukturierte Boxencrew-Tickets umgewandelt, ohne während schneller Runden durch Rückfragen abzulenken?
