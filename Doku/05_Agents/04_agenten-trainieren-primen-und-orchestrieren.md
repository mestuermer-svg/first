> **Thema:** KI-Agenten trainieren (Primen), evaluieren & in mehrstufigen Hierarchien orchestrieren
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (05 Agents)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 05 Agents](./README.md) · **Vorheriges:** [⬅️ 03 • Agenten ausrüsten: Skills & MCP-Tools](./03_agenten-ausruesten-skills-und-mcp-tools.md) · **Nächstes:** [05 • Schnittstelle, Terminals & XOR-Mutex ➡️](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md)

**Alle Module in `05_Agents/`:**
- [01 • Agent-Stilfibel, Didaktik-Ruler & 7-Stufen-Aufbau](./01_agent-stilfibel-und-didaktik-ruler.md)
- [02 • Agenten erstellen: Instructions, Rules & Prompts](./02_agenten-erstellen-instructions-rules-und-prompts.md) · `gemini.instructions`
- [03 • Agenten ausrüsten: Skills & MCP-Tools](./03_agenten-ausruesten-skills-und-mcp-tools.md) · `SKILL.md`
- 👉 **[04 • Priming, Memory & Multi-Agent-Orchestrierung](./04_agenten-trainieren-primen-und-orchestrieren.md)** *(aktuell)* · `@light`
- [05 • Schnittstelle, Terminals & XOR-Mutex](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md) · `Bridge`
- [06 • Multi-Workspace Netzwerk & 6-Rollen-Verbund](./05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md)
- [Letztstand 26.11. (Dual-GPU Ollama & Pitwall GPU-Modelle)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md)
- [Stand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md)
- [Praxis-Referenz 25.11. (Hisense 4K-TV & ClearType)](./HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md)
- [Stand 24.11. (Parity, Qwen 3.5 & Nacharbeiten)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md)
- [Stand 23.11. (ToS-Bereinigung, Ollama & Pitwall v1.5)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md)
- [Änderungsprotokoll 11.11. (MQTT, Gatekeeper & Caddy)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md)
- [Pitwall & Systemreferenz (NotebookLM-Quelle)](./PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md)
- [Boxencrew & Teamchef Konzept (NotebookLM)](./PITWALL_BOXENCREW_TEAMCHEF_KONZEPT_NOTEBOOKLM.md)

**Weitere Rubriken:** [🐧 01 Linux & Bash](../01_Linux_Bash/README.md) · [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🐍 03 Python](../03_Python_Coding/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md) · [🏎️ 06 AC KN5 Modding](../06_AC_KN5_Modding/README.md) · [🥽 07 VR Engineering](../07_VR_Engineering/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

<details>
<summary><b>Lernziele</b></summary>

* Verstehen, was **„Training & Priming“** bei KI-Agenten in der Praxis bedeutet: Gezielte Kontext-Konditionierung über **Instructions**, **3-Stufen-Memory (`/memories/`)** und **Few-Shot-Beispiele** statt teurem Modell-Nachtraining.
* Die **hierarchische Multi-Agenten-Architektur** mit dem **General Agent** als oberster Instanz auf dem Laptop (`VanstrikeCyborg`) und spezialisierten Subagenten beherrschen.
* Eigene Agent-Customizations systematisch in der **Sandbox (`sbx`)** testen und mit den VS Code **Evaluations-Skills (`analyze-prompt`, `troubleshoot`)** überprüfen.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Was bedeutet „Agenten trainieren & primen“ im Engineering-Alltag?</summary>

Ein lokaler oder Cloud-KI-Agent wird im Projektalltag nicht durch das Ändern seiner neuronalen Gewichte (*Fine-Tuning*) trainiert, sondern durch **strukturiertes Priming und persistentes Gedächtnis** konditioniert:

```mermaid
flowchart LR
    subgraph Priming ["1. Statisches Priming (Vor jeder Sitzung)"]
        I["Instructions & AGENTS.md\n(Rolle, Grenzen, SDK-Pflicht)"]
        S["Skills (SKILL.md)\n(Geprüfte Arbeitsabläufe & Skripte)"]
    end

    subgraph Memory ["2. Dynamisches Lernen (Über Sitzungen hinweg)"]
        M1["User Memory (/memories/)\nDauerhafte Vorlieben & gelernte Muster"]
        M2["Repo Memory (/memories/repo/)\nProjekt-Fakten & Build-Befehle"]
        M3["Session Memory (/memories/session/)\nAktueller Aufgabenplan"]
    end

    subgraph Eval ["3. Feedback & Schärfung"]
        E["Diff-Prüfung, Tests & analyze-prompt\nKorrektur bei Fehlverhalten"]
    end

    Priming --> Agent["Geprimter Spezial-Agent"]
    Memory --> Agent
    Agent --> Eval
    Eval -->|"Gelernte Lektion speichern"| Memory
```

### Die 4 Stufen des Agenten-Trainings:
1. **Rollen-Priming (System-Identität):** Dem Agenten in seiner `*.agent.md` oder `*.instructions.md` exakt sagen, **wer** er ist, **wo** er läuft und **was er nicht tun darf** (z. B. *„Vorschau-Pflicht vor Änderungen an `settings.json` oder `.code-workspace`“*).
2. **Few-Shot-Konditionierung (Gute Beispiele zeigen):** Ein konkretes Positiv- und Negativbeispiel (z. B. ein fertiger `<details>`-Block oder ein korrekter `google-genai`-Aufruf) wirkt zehnmal stärker als lange Textverbote.
3. **Erfahrungsspeicher (Memory-System `/memories/`):** Wenn ein Problem gelöst wurde (z. B. ein Port-Konflikt oder ein Pflicht-Dashboard bei Dateiübertragungen), wird die Erkenntnis in `/memories/preferences.md` oder `/memories/repo/` verankert.
4. **Iterative Schärfung (Evaluation):** Wenn ein Agent eine Regel übersieht, wird die Formulierung in der Instruction/Skill geschärft und mit dem Skill `analyze-prompt` auf Eindeutigkeit geprüft.

</details>

<details>
<summary>1.2 Die Agenten-Hierarchie: <code>General Cyborg</code> &amp; <code>General Sim</code> auf <code>VanstrikeCyborg</code> vs. SimRacer-Agenten</summary>

Nach dem Prinzip einer modernen Anlagensteuerung (Leitstand $\rightarrow$ Bereichs-Controller $\rightarrow$ Feld-Aktor) ist der Haupt-Agent bewusst in zwei klar getrennte Rollen aufgeteilt: **`General Cyborg`** (global für Laptop & VS Code) und **`General Sim`** (Workspace-Leitstand für den SimRacer).

```mermaid
flowchart TB
    subgraph Ebene1 ["Ebene 1: Laptop VanstrikeCyborg (MSI Cyborg 15 B2RWFKG – Core 7 240H / RTX 5060 / 16 GB)"]
        USER["Entwickler (Michael Stürmer)"]
        GC["<b>General Cyborg</b> (Global)<br/><i>~/.copilot/agents/general.agent.md</i><br/>• Laptop-System, BIOS, MSI Center &amp; VIVE VR<br/>• NVIDIA App MCP (:13508) &amp; VS Code Profile<br/>• Workspaces, Tasks, MCP &amp; KI-Modelle"]
        GS["<b>General Sim</b> (AC-Workspace-Leitstand)<br/><i>assetto-corsa-content/.github/agents/general.agent.md</i><br/>• Steuert SimRacer (192.168.178.68) per LAN/SSH<br/>• Freigabe-Gate (@general Terminal)<br/>• Koordiniert AC, Sandbox &amp; Sync"]
        USER <--> GC
        USER <--> GS
    end

    subgraph Ebene2 ["Ebene 2: SimRacer Host (192.168.178.68 – Ryzen 9 / RTX 5070 Ti)"]
        RIG["<b>@rig</b> (Nativ SimRacer)<br/>SteamVR, acs.exe, GPU &amp; FFB"]
        LIGHT["<b>@light</b> (Nativ SimRacer)<br/>Docker Engine, race.ini &amp; Presets"]
    end

    subgraph Ebene3 ["Ebene 3: Docker-Sandbox &amp; Pitwall"]
        DARK["<b>@dark</b> (ac-win11-sandbox auf SimRacer)<br/>Isolierte In-Guest-Tests &amp; CM"]
        SARAH["<b>@sarah</b> (IdeaPad 5 omARCHy)<br/>Live-Coaching &amp; Videoschnitt"]
    end

    GS -->|"SSH / SMB / Freigabe-Gate"| RIG
    GS -->|"SSH / SMB / Freigabe-Gate"| LIGHT
    LIGHT -->|"Port 2222 / Queue"| DARK
    RIG -->|"UDP-Telemetrie"| SARAH
```

### Hardware-Zuordnung &amp; klare Differenzierung:
* **`General Cyborg`** (`C:\Users\strik\.copilot\agents\general.agent.md`, global): Läuft auf **`VanstrikeCyborg`**, nutzt dessen Ressourcen und besitzt das hinterlegte Systemwissen aus `C:\local_Cyborg\Gemini\VanstrikeCyborg\` (Core 7 240H, 16 GB DDR5-5600 / max. 96 GB, RTX 5060 Laptop 8 GB @ 55 W ohne MUX-Switch, 3-Monitor-Setup, `MSI Center`, `F3`-Recovery, `NVIDIA App` MCP `http://127.0.0.1:13508/mcp` und `VIVE Hub` / Fehlercode `337`). Im Workspace `git-labor` ist `General Cyborg` der einzige aktive General-Agent und steuert die Remote-Agenten (`@light`, `@rig`, `@dark`, `@sarah`, `@rick`) über **SSH & Bridge-Skripte**.
* **`General Sim`** (`assetto-corsa-content/.github/agents/general.agent.md`, AC-Workspace / Legacy): Läuft in der bisherigen Workspace-Fassung noch auf `VanstrikeCyborg` (`@general`-Terminal), steuert über LAN/SSH/SMB die **SimRacer-Workstation (`192.168.178.68`)** und bildet das Legacy-Freigabe-Gate (`ok`/`nein`/`reply`) für `@rig` und `@light`.
  * **Zielarchitektur (Stand 26.11.2026, `LIVE` auf StrikerPi):** In der kanonischen 7-Rollen-Registry (`strikerpi-hub/telemetry-relay/agent_registry.json`) sind **`General Cyborg` (`@cyborg`)** auf dem Laptop `VanstrikeCyborg` und **`General Sim` (`@general-sim`)** als eigenständige Leitstandsrolle auf **`StrikerPi` (`192.168.178.86`)** getrennt modelliert. `/opt/general-sim/start_general_sim_terminal.sh`, `agent_registry.*` und das aktualisierte `telemetry_relay.py` sind seit `26.11.2026` auf dem Pi deployed (`READY` / `available`); die bestehende `@general`-Route bleibt bis zum vollständigen Cutover als Legacy aktiv (Details: [Rollen-, Terminal- und Pitwall-Umsetzung](../../../assetto-corsa-content/docs/03_agenten_system/rollen-terminals-pitwall-umsetzung.md)).
* **SimRacer-Agenten (`@rig`, `@light`, `@dark`):** Laufen **nicht** auf dem Laptop, sondern direkt auf der **Hardware des `SimRacer` (`192.168.178.68`)** (`@rig` & `@light` nativ auf dem Host; `@dark` gekapselt in der Docker-VM `ac-win11-sandbox`). Aus `git-labor` werden sie per SSH/Bridge (`labs/Agent-Terminals.ps1`, `labs/Send-SimAgentTask.ps1`) angesprochen.
* **Pitwall (`@sarah`):** Läuft dediziert auf dem **IdeaPad 5 (`omARCHy` / `192.168.178.98`)**, um die SimRacer-CPU beim Videoschnitt zu entlasten.
* **Verbindliche Rückversicherung &amp; Freigabe-Gate:** Die SimRacer-Agenten ([`rig.agent.md`](../../.github/agents/rig.agent.md) und [`light.agent.md`](../../.github/agents/light.agent.md)) sichern sich vor jeder System-, Container- oder Weiterleitungs-Aktion beim `@general`-Leitstand (`General Sim`) ab (`ApprovalRequest` in `agents/general-SIM/inbox/`), sofern kein direkter General-Auftrag (`approved_by: GeneralAgent_Laptop`) vorliegt. Details siehe [Modul 5.5](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md).

</details>

<details>
<summary>1.3 Der 6-Schritte-Trainingszyklus für neue Aufgaben mit einem Agenten</summary>

Wenn du im `git-labor` ein neues Feature baust oder einen Agenten anlernst, gehe immer nach diesem geprüften Muster vor:

1. **Ziel & Kontext stecken:** Nenne die betroffenen Dateien oder die Rubrik (z. B. *„Arbeite nur im Ordner `labs/python/`“*).
2. **Erst planen lassen (Plan Mode / Rückfragen):** Lass den Agenten bei komplexen Aufgaben erst einen kurzen Plan oder ein Diff zeigen, bevor er Dateien ändert.
3. **Isoliert ausführen (bei Risiko in `sbx`):** Wenn der Agent im Full-Autonomy-Modus neue Pakete oder Systembefehle ausprobieren soll, starte ihn in der Sandbox (`sbx run --name agent-training gemini . "./Doku:ro"`).
4. **Automatisierte Verifikation verlangen:** Der Agent muss nach jeder Änderung selbstständig Linter/Pylance (`get_errors`) oder Tests (`pytest` / `tsc --noEmit`) ausführen.
5. **Diff kontrollieren (`Strg + Shift + G`):** Prüfe in der VS Code Source Control rot/grün, was der Agent tatsächlich verändert hat.
6. **Lerneffekt sichern:** Hat ein Workflow perfekt funktioniert, speichere ihn als wiederverwendbaren **Skill (`SKILL.md`)** oder **Prompt (`.prompt.md`)**.

</details>

<details>
<summary>1.4 Diagnose & Qualitätsprüfung für Agenten-Dateien</summary>

In deinem VS Code sind spezielle Diagnose-Werkzeuge für das Agenten-Training vorinstalliert:
* **Skill `agent-customization`:** Hilft beim Erstellen, Prüfen und Reparieren von `.instructions.md`, `.prompt.md`, `.agent.md`, `SKILL.md` und `AGENTS.md`.
* **Skill `analyze-prompt` & `fix-customization-evaluation-diagnostics`:** Prüft deine geöffneten Agenten- und Prompt-Dateien auf unklare Anweisungen, fehlende YAML-Felder oder Konflikte im *Problems*-Panel.
* **Skill `troubleshoot`:** Analysiert die JSONL-Debug-Logs einer Chat-Sitzung, falls du wissen möchtest, warum ein bestimmtes Tool, eine Instruction oder ein Subagent in einem Durchlauf genutzt oder übersprungen wurde.

</details>

<details>
<summary>1.5 Remote-Entwicklung & Headless-Agenten (Raspberry Pi 4 &amp; Arch Linux)</summary>

In professionellen Entwicklungsumgebungen läuft die Ausführung rechenintensiver Skripte oder von Webservern oft nicht auf dem lokalen Arbeitsplatz-Laptop, sondern auf dedizierten Remote-Hosts (z. B. Raspberry Pi 4 oder Omarchy Linux-Server):

```mermaid
flowchart LR
    subgraph Host ["Lokaler Arbeitsplatz (VanstrikeCyborg)"]
        UI["VS Code Editor & UI-Renderer"]
        PLANNER["General Agent (Planung & Prompt-Assembly)"]
    end

    subgraph RemoteNode ["Headless Remote-Host (Raspberry Pi 4 / Arch Linux)"]
        REH["VS Code Remote Extension Host"]
        AGENT_EXEC["Agent Execution Runner (Bash / Python Worker)"]
        SRV["Nginx Webserver & SQLite/Postgres"]
        REH --> AGENT_EXEC
        AGENT_EXEC --> SRV
    end

    UI <-->|"Verschlüsselter SSH-Tunnel (:22)"| REH
```

* **Entkopplung von Benutzeroberfläche und Ausführung:** Durch den *Remote Extension Host* bleibt die Benutzeroberfläche von VS Code auf `VanstrikeCyborg` butterweich bedienbar, während Compiler, Tests und Hintergrundprozesse auf dem Linux-Host laufen.
* **Agenten im Headless-Modus:** Ein Agent kann remote Befehle ausführen (`systemctl restart nginx`, Datenbankmigrationen starten), ohne dass lokale Pfadübersetzungen (Windows `C:\` vs. Linux `/`) nötig sind.

</details>

<details>
<summary>1.6 Privacy-First Agent Observability: KI-Traffic-Analyse &amp; Matomo</summary>

Wenn Agenten autonom mit Webdiensten, internen APIs und Dokumentationen interagieren, entsteht ein völlig neues Anforderungsprofil an das **Monitoring & Analytics**:

| Eigenschaft | Matomo On-Premise (Privacy-First) | Herkömmliche Cloud-Analytics |
| :--- | :--- | :--- |
| **Dateninhaberschaft** | **100 % eigene Kontrolle** auf eigenem Linux-/Pi-Server | Daten liegen auf externen US-Konzern-Servern |
| **Datenschutz / DSGVO** | Vollständig konform, optional komplett ohne Cookies | Oft komplexe Consent-Banner & Opt-In-Pflicht |
| **Datenpräzision** | **Ungefilterte Rohdaten (No Sampling)** | Verzerrte Hochrechnungen durch Data Sampling |
| **KI- & Bot-Traffic-Analyse** | **Gezielte Differenzierung von KI- vs. Human-Traffic** | Vermischt Menschen mit Bots oder blockiert KI blind |

### Warum KI-Traffic-Tracking unverzichtbar ist:
1. **Trennung von Mensch und Maschine:**
   Traditionelle Webanalyse zählt Seitenaufrufe unabhängig davon, ob ein Mensch im Browser liest oder ein autonomer Agent (`Copilot`, `ClaudeCode`, `GeminiAgent`, `curl`, `python-requests`) die Dokumentation parst. Matomo ermöglicht über User-Agent-Erkennung und Sitzungsanalyse eine saubere Trennung.
2. **Observability für Multi-Agenten-Systeme:**
   * Wie oft greift der Agent auf interne Wissensdatenbanken oder MCP-Endpunkte zu?
   * Welche Fehlercodes (`404`, `500`) treten bei automatisierten API-Aufrufen auf?
   * Wie entwickelt sich die Latenz und der synthetische Datenverkehr bei komplexen Aufgabenketten?
3. **Schutz vor Daten-Leakage:**
   Da das gesamte Tracking On-Premise auf dem eigenen Server betrieben wird, fließen sensible Unternehmens- und Projektdaten (wie Dateipfade oder Abfrage-Parameter) niemals an externe Analyse-Dienstleister ab.

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Priming vs. Fine-Tuning:** Erkläre in eigenen Worten, warum wir für unsere täglichen Workflows **Instructions (`*.instructions.md`), Skills (`SKILL.md`) und Memory (`/memories/`)** nutzen, statt ein Sprachmodell jedes Mal neu zu trainieren.
2. **Rolle des General Agenten:** Welche Aufgaben übernimmt der **General Agent** auf dem Laptop `VanstrikeCyborg` und warum gilt für ihn bei Änderungen an der globalen `settings.json` oder `.code-workspace` immer die **Vorschau-Pflicht**?
3. **Remote-Agenten-Architektur:** Welchen Vorteil hat der VS Code *Remote Extension Host*, wenn ein Agent auf einem Raspberry Pi 4 einen Nginx-Server konfiguriert und testet?
4. **Privacy-First Observability:** Warum ist ungesampeltes Tracking mit Matomo On-Premise für die Überwachung von KI-Agenten-Traffic herkömmlichen Cloud-Analytics-Systemen überlegen?
5. **Fehleranalyse bei Agenten:** Eine neu angelegte `.instructions.md`-Datei wird vom Agenten im Chat scheinbar ignoriert. Welche drei Punkte (Speicherort, YAML-Frontmatter `applyTo`, VS Code Reload/Diagnostics) prüfst du zuerst?

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [Modul 5.1: Verbindliche Stilfibel & Didaktik-Ruler](./01_agent-stilfibel-und-didaktik-ruler.md)
* [Modul 5.2: Agenten erstellen (Instructions, Rules & Custom Agents)](./02_agenten-erstellen-instructions-rules-und-prompts.md)
* [Modul 5.3: Agenten ausrüsten (Skills & MCP-Tools)](./03_agenten-ausruesten-skills-und-mcp-tools.md)
* [Modul 5.5: Workspace-Schnittstelle, Freigabe-Gate & Agenten-Terminals](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md)
* **Agent-Definitionen &amp; Regeln:** [`AGENTS.md`](../../AGENTS.md) · [`vscode-experte.instructions.md`](../../../.copilot/instructions/vscode-experte.instructions.md) · [`General Cyborg` (Global)](../../../.copilot/agents/general.agent.md) · [`General Sim` (AC-Workspace)](../../../assetto-corsa-content/.github/agents/general.agent.md) · [`rig.agent.md`](../../.github/agents/rig.agent.md) · [`light.agent.md`](../../.github/agents/light.agent.md) · [`dark.agent.md`](../../.github/agents/dark.agent.md) · [`sarah.agent.md`](../../.github/agents/sarah.agent.md) · [`rick.agent.md`](../../.github/agents/rick.agent.md)
* **Skills &amp; Historie:** [`live-transfer-status-monitor` (`SKILL.md`)](../../.agents/skills/live-transfer-status-monitor/SKILL.md) · [`AGENT_KOMMUNIKATION_HISTORIE.md`](../../../assetto-corsa-content/ac-sandbox/shared/agents/general-SIM/logs/AGENT_KOMMUNIKATION_HISTORIE.md)
* [Matomo Web Analytics – On-Premise & Privacy-First](https://matomo.org/)
* [VS Code Remote Development Architektur](https://code.visualstudio.com/docs/remote/remote-overview)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **Gutes Priming = Präzises Training:** Klare Rollen-Grenzen, Positiv-Beispiele und das 3-Stufen-Memory (`/memories/`) formen einen verlässlichen Experten-Agenten.
* **Klare Trennung `General Cyborg` vs. `General Sim`:** Beide laufen auf dem Laptop `VanstrikeCyborg` — `General Cyborg` betreut global das MSI-Laptop-System, VIVE VR, MCP & VS Code; `General Sim` steuert den `SimRacer` (`192.168.178.68`) & das Freigabe-Gate.
* **Hardware-Treue der Subagenten:** `@rig` und `@light` laufen nativ auf dem `SimRacer`, `@dark` gekapselt im Docker-Container auf dem `SimRacer`, `@sarah` auf dem `IdeaPad 5`.
* **Vorschau-Pflicht schützt Konfigurationen:** Vor Eingriffen in `.code-workspace` oder globale `settings.json` wird immer erst ein Diff gezeigt.
* **Sicher trainieren mit `sbx` + `:ro`:** Autonome Agenten-Tests laufen isoliert in der Micro-VM, während Referenz-Ordner wie `./Doku:ro` schreibgeschützt bleiben.
* **Remote Extension Host entkoppelt UI:** Komplexe Skripte und Server laufen auf dem Headless-Host (Raspberry Pi / Arch Linux), während der Entwickler auf dem Laptop verzögerungsfrei weiterarbeitet.
* **Privacy-First Observability:** On-Premise-Tracking mit Matomo liefert ungesampelte Rohdaten und unterscheidet zuverlässig zwischen menschlichen Nutzern und KI-Agenten-Traffic.

</details>

---
*Hinweis zur Organisation:* Die erstellte Dokumentation ist am Drehlaufwerk abgelegt und mit einer kurzen Zusammenfassung von den Chips auch in den Notebooks verlinkt.

<!-- DOKU-MINIMAP-START -->
<style>
.doku-arch-flow { font-family: var(--vscode-editor-font-family, Consolas, monospace); background: linear-gradient(160deg, rgba(15, 23, 42, 0.96), rgba(17, 24, 39, 0.94)); border: 1px solid rgba(96, 165, 250, 0.35); border-radius: 12px; padding: 14px 16px; margin: 8px 0 0 0; color: #e2e8f0; }
.doku-arch-root { display: flex; flex-wrap: wrap; align-items: center; justify-content: center; gap: 10px; font-weight: 700; font-size: 0.98em; padding: 9px 14px; margin-bottom: 12px; background: linear-gradient(135deg, rgba(37, 99, 235, 0.28), rgba(30, 41, 59, 0.92)); border: 1px solid rgba(96, 165, 250, 0.48); border-radius: 10px; }
.doku-arch-root a { color: #93c5fd !important; text-decoration: none !important; }
.doku-arch-root a:hover { color: #dbeafe !important; text-decoration: underline !important; }
.doku-arch-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(268px, 1fr)); gap: 11px; }
.doku-arch-card { background: rgba(30, 41, 59, 0.72); border: 1px solid rgba(148, 163, 184, 0.24); border-top: 3px solid #3b82f6; border-left: 4px solid #3b82f6; border-radius: 10px; padding: 10px 12px; transition: transform 0.14s ease, border-color 0.14s ease, box-shadow 0.14s ease; }
.doku-arch-card:hover { border-color: #93c5fd; transform: translateY(-2px); box-shadow: 0 6px 18px rgba(0, 0, 0, 0.35); }
.doku-arch-card.r1 { border-left-color: #22c55e; border-top-color: #22c55e; }
.doku-arch-card.r2 { border-left-color: #3b82f6; border-top-color: #3b82f6; }
.doku-arch-card.r3 { border-left-color: #eab308; border-top-color: #eab308; }
.doku-arch-card.r4 { border-left-color: #ec4899; border-top-color: #ec4899; }
.doku-arch-card.r5 { border-left-color: #a855f7; border-top-color: #a855f7; }
.doku-arch-card.r6 { border-left-color: #f97316; border-top-color: #f97316; }
.doku-arch-card.r7 { border-left-color: #06b6d4; border-top-color: #06b6d4; }
.doku-arch-card-title { font-weight: 700; font-size: 0.93em; margin-bottom: 7px; padding-bottom: 5px; border-bottom: 1px dashed rgba(148, 163, 184, 0.26); }
.doku-arch-card-title a { color: #f8fafc !important; text-decoration: none !important; display: block; }
.doku-arch-card-title a:hover { color: #93c5fd !important; }
.doku-arch-lines { list-style: none; margin: 0; padding: 0; font-size: 0.84em; line-height: 1.5; }
.doku-arch-lines li { margin: 3px 0; padding: 2px 6px; border-radius: 5px; white-space: normal; }
.doku-arch-lines li:hover { background: rgba(59, 130, 246, 0.16); }
.doku-arch-lines a { color: #cbd5e1 !important; text-decoration: none !important; display: inline; }
.doku-arch-lines a:hover { color: #93c5fd !important; text-decoration: underline !important; }
.doku-arch-badge { display: inline-block; font-size: 0.74em; padding: 0 6px; margin-left: 5px; border-radius: 999px; background: rgba(59, 130, 246, 0.22); color: #bfdbfe !important; border: 1px solid rgba(96, 165, 250, 0.4); }
details.doku-minimap { position: fixed; bottom: 18px; right: 18px; z-index: 9999; width: 292px; max-height: 76px; overflow: hidden; background: rgba(15, 23, 42, 0.93); border: 1px solid rgba(96, 165, 250, 0.62); border-radius: 14px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.65); backdrop-filter: blur(10px); transition: width 0.18s ease, max-height 0.18s ease, border-color 0.18s ease; font-family: var(--vscode-font-family, sans-serif); }
details.doku-minimap:hover { border-color: #93c5fd; }
details.doku-minimap[open] { width: min(920px, 94vw); max-height: 84vh; overflow-y: auto; padding-bottom: 10px; border-radius: 14px; }
details.doku-minimap > summary { cursor: pointer; list-style: none; padding: 8px 13px; font-weight: 700; font-size: 0.84em; color: #f8fafc; background: linear-gradient(90deg, rgba(37, 99, 235, 0.45), rgba(30, 41, 59, 0.92)); border-bottom: 1px solid rgba(148, 163, 184, 0.24); display: flex; align-items: center; justify-content: space-between; user-select: none; }
details.doku-minimap > summary::-webkit-details-marker { display: none; }
details.doku-minimap > summary .minimap-toggle::after { content: "+"; font-size: 1.05em; opacity: 0.85; padding: 0 4px; }
details.doku-minimap[open] > summary .minimap-toggle::after { content: "−"; }
details.doku-minimap .minimap-preview-strip { display: flex; gap: 5px; padding: 6px 10px 8px 10px; font-size: 0.71em; color: #cbd5e1; justify-content: space-between; }
details.doku-minimap[open] .minimap-preview-strip { display: none; }
details.doku-minimap .minimap-preview-strip span { display: inline-flex; align-items: center; gap: 4px; background: rgba(30, 41, 59, 0.92); padding: 2px 7px; border-radius: 999px; border: 1px solid rgba(148, 163, 184, 0.26); }
details.doku-minimap .dot { width: 6px; height: 6px; border-radius: 50%; display: inline-block; }
details.doku-minimap .dot.r1 { background: #22c55e; }
details.doku-minimap .dot.r2 { background: #3b82f6; }
details.doku-minimap .dot.r3 { background: #eab308; }
details.doku-minimap .dot.r4 { background: #ec4899; }
details.doku-minimap .dot.r5 { background: #a855f7; }
details.doku-minimap .dot.r6 { background: #f97316; }
details.doku-minimap .dot.r7 { background: #06b6d4; }
details.doku-minimap .minimap-body { padding: 4px 12px 6px 12px; }
</style>
<details class="doku-minimap">
<summary><span>🗺️ Doku-Minimap (7 Rubriken &amp; Labs)</span><span class="minimap-toggle" title="Klicken zum Vergrößern / Einklappen"></span></summary>
<div class="minimap-preview-strip"><span><i class="dot r1"></i>Linux</span><span><i class="dot r2"></i>VSCode</span><span><i class="dot r3"></i>Python</span><span><i class="dot r4"></i>JS/TS</span><span><i class="dot r5"></i>Agents</span><span><i class="dot r6"></i>KN5</span><span><i class="dot r7"></i>VR</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root"><span>🏛️ <a href="../README.md">VanstrikeCyborg — git-labor Doku-Index</a></span> · <a href="../../README.md">Repo-README</a> · <a href="../../AGENTS.md">AGENTS.md</a> · <a href="../../notebook-agent-environments/README.md">Notebooks</a> · <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-28.md">Letztstand 28.11.</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🐧 <a href="../01_Linux_Bash/README.md">01_Linux_Bash (Linux, Shell &amp; Container)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 • Bash CLI, Text-Tools, Streams &amp; Expansions</a> <a class="doku-arch-badge" href="../../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="../01_Linux_Bash/02_linux-systemadministration-und-interna.md">02 • Inodes, LVM, Prozesse, Boot-Prozess &amp; systemd</a></li>
<li>├─ <a href="../01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">03 • Arch Linux, Omarchy, Remote-SSH &amp; Nginx</a></li>
<li>├─ <a href="../01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">04 • Advanced Bash: Arrays, getopts &amp; Backups</a></li>
<li>└─ <a href="../01_Linux_Bash/05_docker-und-sbx-micro-vms.md">05 • Docker Grundlagen &amp; Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="../02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP &amp; Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) &amp; Remote</a></li>
<li>├─ <a href="../02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow &amp; Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="../02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Ollama (:11434) &amp; Ports (Archiv: Proxy)</a> <a class="doku-arch-badge" href="../../.vscode/mcp.json">mcp.json</a></li>
<li>├─ <a href="../02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio &amp; API-Keys</a></li>
<li>└─ <a href="../02_VSCode_Env/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">05 • 5-Knoten-Verbund, Parity &amp; Parallel-Limits</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="../03_Python_Coding/README.md">03_Python_Coding (Python, uv &amp; GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance &amp; Notebooks</a> <a class="doku-arch-badge" href="../../notebook-agent-environments/agent_demo.ipynb">.ipynb</a></li>
<li>├─ <a href="../03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">02 • Google GenAI SDK (google-genai) &amp; Interactions API</a></li>
<li>└─ <a href="../03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md">03 • Automatisierung, Datenanalyse &amp; pytest</a> <a class="doku-arch-badge" href="../../labs/03_python/sensor_demo.py">sensor_demo.py</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">🌐 <a href="../04_JS_TS_Web/README.md">04_JS_TS_Web (HTML/CSS, JS/TS &amp; Web-SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">01 • HTML5, CSS3 &amp; DOM-Manipulation Grundlagen</a> <a class="doku-arch-badge" href="../../labs/04_js_ts_web/rechner.html">rechner.html</a></li>
<li>├─ <a href="../04_JS_TS_Web/02_modernes-javascript-und-typescript.md">02 • Modernes JavaScript (ES6+) &amp; TypeScript</a></li>
<li>└─ <a href="../04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">03 • Google GenAI SDK (@google/genai) für Web-Apps</a></li>
</ul>
</div>
<div class="doku-arch-card r5">
<div class="doku-arch-card-title">🤖 <a href="../05_Agents/README.md">05_Agents (KI-Agenten, Skills &amp; Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">01 • Agent-Stilfibel, Didaktik-Ruler &amp; 7-Stufen-Aufbau</a></li>
<li>├─ <a href="../05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">02 • Agenten erstellen: Instructions, Rules &amp; Prompts</a> <a class="doku-arch-badge" href="../../.github/instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>├─ <a href="../05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills &amp; MCP-Tools</a> <a class="doku-arch-badge" href="../../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>├─ <a href="../05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Priming, Memory &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../../.github/agents/light.agent.md">@light</a></li>
<li>├─ <a href="../05_Agents/05_workspace-schnittstelle-simracer-und-agenten-terminals.md">05 • Schnittstelle, Terminals &amp; XOR-Mutex</a> <a class="doku-arch-badge" href="../../labs/03_python/sim_agent_bridge.py">Bridge</a></li>
<li>├─ <a href="../05_Agents/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">06 • Multi-Workspace Netzwerk &amp; 7-Rollen-Verbund</a></li>
<li>└─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-28.md">Letztstand 28.11. (Labs 06/07, Cleanup &amp; KN5-Fix)</a></li>
</ul>
</div>
<div class="doku-arch-card r6">
<div class="doku-arch-card-title">🏎️ <a href="../06_AC_KN5_Modding/README.md">06_AC_KN5_Modding (.kn5 &amp; Toolchain)</a></div>
<ul class="doku-arch-lines">
<li>└─ <a href="../06_AC_KN5_Modding/01_kn5-format-entwicklungsumgebung-und-setup.md">01 • .kn5-Format, ext_config &amp; Sandbox-Gate</a> <a class="doku-arch-badge" href="../../labs/06_ac_kn5_modding/inspect_kn5.py">inspect_kn5.py</a></li>
</ul>
</div>
<div class="doku-arch-card r7">
<div class="doku-arch-card-title">🥽 <a href="../07_VR_Engineering/README.md">07_VR_Engineering (90 Hz VR &amp; @rig)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../07_VR_Engineering/01_vr-architektur-frametimes-und-diagnose.md">01 • VR-Architektur, Frametimes &amp; Compositor</a> <a class="doku-arch-badge" href="../../labs/07_vr_engineering/analyze_vr_compositor.py">analyze_vr_compositor.py</a></li>
<li>└─ <a href="../../labs/07_vr_engineering/README.md">Lab 07 • VR-Invarianten &amp; Read-Only Check</a> <a class="doku-arch-badge" href="../../labs/07_vr_engineering/Check-VrInvariants.ps1">Check-VrInvariants.ps1</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
