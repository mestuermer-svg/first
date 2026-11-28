> **Thema:** Rubrik 05 – KI-Agenten (Erstellen, Ausrüsten, Trainieren/Primen & Orchestrieren)
> **Autor:** Michael Stürmer
> **Datum:** 28.11.2026

# 05 – KI-Agenten: Erstellen, Ausrüsten, Trainieren & Orchestrieren

Diese Rubrik ist das **Herzstück für den Bau und die Führung deiner KI-Agenten** im `git-labor`: Sie vereint die verbindlichen Didaktik- und Stilregeln (`agent_ruler.md` & `Agent-guidline.md`), das Erstellen eigener Custom Agents (`*.agent.md`) und Instructions (`*.instructions.md`), das Ausrüsten mit **Skills (`SKILL.md`)** und **MCP-Servern (`Agent_setup.md`)** sowie das strukturierte **Primen, Trainieren und Orchestrieren** einer mehrstufigen Agenten-Hierarchie.

<details>
<summary><b>Übersicht der Module in dieser Rubrik</b></summary>

| Modul | Datei | Inhalt & Fokus |
| :--- | :--- | :--- |
| **Modul 5.1** | [01_agent-stilfibel-und-didaktik-ruler.md](./01_agent-stilfibel-und-didaktik-ruler.md) | Die verbindlichen Regeln aus `agent_ruler.md` & `Agent-guidline.md`: Tonalität, `<details>`-Einklapp-Pflicht, 7-stufiger Lernskript-Aufbau und Chips. |
| **Modul 5.2** | [02_agenten-erstellen-instructions-rules-und-prompts.md](./02_agenten-erstellen-instructions-rules-und-prompts.md) | Wie man Agenten von Grund auf erstellt: Unterschied Prompt vs. Instruction vs. Custom Agent (`*.agent.md`), Model Harnesses, dynamische Reasoning-Stufen (Thinking), Pylance/TypeScript LSP-Anbindung, Speicherorte (`AGENTS.md`, `.github/`) & YAML-Frontmatter. |
| **Modul 5.3** | [03_agenten-ausruesten-skills-und-mcp-tools.md](./03_agenten-ausruesten-skills-und-mcp-tools.md) | Agenten mit Fähigkeiten ausrüsten (`Agent_setup.md` & `SKILL.md`): Offizielle Gemini Skills (`skills.sh`), eigene `SKILL.md`-Pakete, `geminiDocs` MCP & `llms.txt`. |
| **Modul 5.4** | [04_agenten-trainieren-primen-und-orchestrieren.md](./04_agenten-trainieren-primen-und-orchestrieren.md) | Agenten-Training (Priming, Evaluierung, Memory-System), Remote Extension Host &amp; Headless-Agenten (Arch/Pi 4), Privacy-First Observability &amp; KI-Traffic-Analyse (On-Premise Matomo) sowie getrennte General-Rollen (`@cyborg` Laptop vs. `@general-sim` StrikerPi `LIVE`). |
| **Modul 5.5** | [05_workspace-schnittstelle-simracer-und-agenten-terminals.md](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md) | Workspace-Schnittstelle zwischen Git-Labor, SimRacer &amp; StrikerPi: kanonische Agent-IDs (`0.1`), Task-Queue (`inbox/` -> `outbox/`), Legacy-Freigabe-Gate (`@rig`/`@light` ↔ `@general`), SSH-Launcher (`Agent-Terminals.ps1` / `-ClientMode`), Agent `@rick` (`simrig.git`), Policy `pitwall_control_policy.json`, XOR-Mutex &amp; `sim_agent_bridge.py`. |
| **Modul 5.6** | [05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md](./05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md) | 5-Knoten-Topologie (Laptop, SimRacer, Sandbox, Archibald, StrikerPi), Multi-Root-Workspace, Port-Matrix, 7-Rollen-Verbund &amp; Dual-GPU-Ollama-Stand, Handshake mit Pre-Flight-Check und SSH-Terminalprofile. |
| **Modul 5.12 (Letztstand 28.11.)** | [SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-28.md](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-28.md) | **Labs 06 (`.kn5`) &amp; 07 (VR)**, GP-2025-`.kn5`-Reparatur (`runner.ps1`), VR-Startlog-Auswertung (`AcquireSync`/`0xc0000374`), Workspace-Cleanup (`10+10` Tasks, direkter `-ClientMode`, `79` Altlasten entfernt, `26` Backups archiviert, `D3` aktiv). |
| **Modul 5.11 (Stand 27.11.)** | [SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-27.md](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-27.md) | Dark-Sandbox-Fixes, **Host-vs.-Sandbox-Trennung (`@light`+`@rig` = Host)**, Light/Rig-Koordinationsprotokoll, Pitwall SQLite/Tool-Swap/Touch-Terminals/Sandbox-Schutz, `systemd`-Timer, **Auto-Dual-GPU-Routing** &amp; **Nachmittags-Härtung** (Timeouts, `:2222`-SSH/WebSocket, Token-Budgets, `@light`-Executors, `@dark`-Clock/Grafik/Replay/`SkipIfPresent`). |
| **NotebookLM Audio-Bericht (27.11.)** | [NOTEBOOKLM_AUDIO_BERICHT_2026-11-27.md](./NOTEBOOKLM_AUDIO_BERICHT_2026-11-27.md) | Flacher Sitzungsbericht vom 27.11.2026 für Gemini NotebookLM Audio Overview (alle Fehlerbehebungen, Architektur- &amp; UI-Updates). |
| **Modul 5.10 (Stand 26.11.)** | [SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md) | Dual-GPU Ollama (`SimRacer 5070 Ti` &rarr; `Cyborg 5060` Fallback), **KI-Schaltweiche (`ollama` / `auto` / `gemini`)**, Pitwall `🧠 GPU-Modelle`, kanonische 7-Rollen-Registry (`LIVE` auf StrikerPi), NetBird-Mesh, VS Code Agents Window/MCP-Tool-Budget &amp; **StrikerPi SQLite Leitstand-DB (Werkzeug-Bibliothek)**. |
| **Umsetzungsstand (7-Rollen-Trennung)** | [Rollen-, Terminal- und Pitwall-Umsetzung](../../../assetto-corsa-content/docs/03_agenten_system/rollen-terminals-pitwall-umsetzung.md) | Kanonische Rollen-IDs (`agent_registry.json`), General-Cyborg/General-Sim-Trennung, Pitwall-Status (`LIVE` auf StrikerPi), UTF-8-JSON-Prompt-Transport, Legacy-Übergang, **SQLite-Leitstand-DB &amp; 5 Bibliotheksregeln**. |
| **Modul 5.9 (Stand 25.11. — Architektur v5)** | [SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md) | `@light` als alleiniger Host-Orchestrator &amp; 2-Stufen-QA (`light_verifier.py`), Agenten-Werkzeugkoffer (`toolbox.json` + `TOOLBOX.md`), lokale Ollama-Tool-Runtime (`qwen3.5:9b`), `leitstand_protocol.py` (inkl. `MissingCapability` + Ausbauvorschlägen), Hisense-TV-Ist-Stand &amp; Pitwall v2.1 Drill-Down. |
| **Praxis-Referenz (25.11. — Hisense 4K-TV)** | [HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md](./HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md) | Durch `@light` &rarr; `@rig` (`qwen3.5:9b`) angewendete Windows-ClearType-Optimierung (`task_20261125_052359_3ndb`, `VerifiedSuccess`) inkl. Vorher/Nachher-Tabelle, Registry-Backup &amp; NVCP-Checkliste für VS Code, Docker Desktop und WhatsApp. |
| **Modul 5.8 (Stand 24.11. &amp; Nacharbeiten)** | [SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md) | SimRacer-Bereinigung (`+110,71 GB`), 76-Extensions-Parity, Read-Only-Shares, `qwen3.5:9b`/`4b` + RTX-5070-Ti-Lastbeweis (`80 %` Peak), Workspace-Agenten-Isolation, XOR-Mutex, Parallel-Limits (`numproc 12`-Befund) &amp; **9-Fälle-Nacharbeiten-Register**. |
| **Modul 5.7 (Stand 23.11.)** | [SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md) | ToS-Bereinigung, 2-Knoten-Ollama-GPU-Architektur, Change-Freeze & Cross-Agent-Schreibschutz, `context_subset`, `weight_score`, Terminal-Header-Fix und Pitwall `v1.5.0` mit Einzel-Agenten-Steuerung. |
| **Pitwall & NotebookLM-Quelle** | [PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md](./PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md) | Vollständige System-, Architektur-v5-, Dual-GPU-/Schaltweichen- &amp; Pitwall-REST/WS-Referenz (Stand 26.11.2026 **LIVE auf StrikerPi**) – flaches Markdown für Gemini NotebookLM. |
| **Boxencrew & Teamchef (Konzept / NotebookLM)** | [PITWALL_BOXENCREW_TEAMCHEF_KONZEPT_NOTEBOOKLM.md](./PITWALL_BOXENCREW_TEAMCHEF_KONZEPT_NOTEBOOKLM.md) | Strategie- und Rollenkonzept (Entwurf v0.1) für Teamchef, Mechaniker-Boxencrew, 4-Phasen-Roadmap sowie `MANUAL`/`DELEGATED`/`AUTO`-Steuerung für Gemini NotebookLM. |
| **Änderungsprotokoll (11.11.)** | [SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md) | Systemumstellung vom 11./12.11.2026 (MQTT, Gatekeeper `AUTO`/`MANUAL`, Relay-Logik, Caddy `:80` + `gitlabor-api.service` `:8085` + TS-Labs & Pitwall-Display) mit verifiziertem Ist-Stand. |

</details>

<details>
<summary><b>Direktlinks: Agent-Dateien, Skills, Regeln &amp; Terminal-Historie</b></summary>

| Kategorie | Datei | Zweck &amp; Geltungsbereich |
| :--- | :--- | :--- |
| **Custom Agent (Global – `General Cyborg`)** | [`general.agent.md` (User)](../../../.copilot/agents/general.agent.md) | Läuft auf `VanstrikeCyborg` (global): MSI Cyborg 15 Hardware/BIOS/MSI Center, NVIDIA App MCP (`:13508`), VIVE VR, VS Code Workspaces &amp; Profile (einziger General-Agent im `git-labor`). |
| **Custom-Agent-Datei (`General Sim`, Legacy)** | [`general.agent.md` (AC-Workspace)](../../../assetto-corsa-content/.github/agents/general.agent.md) | Historische Workspace-Definition auf `VanstrikeCyborg`; kanonische Laufzeitrolle ist `general-sim` auf StrikerPi ([`general_sim_terminal.py`](../../../strikerpi-hub/general-sim/general_sim_terminal.py), [`leitstand_db.py`](../../../strikerpi-hub/general-sim/leitstand_db.py), [`BIBLIOTHEKS_ORGANISATION_LEITFADEN.md`](../../../strikerpi-hub/general-sim/BIBLIOTHEKS_ORGANISATION_LEITFADEN.md), seit `26.11.2026` **LIVE** unter `/opt/general-sim/`). |
| **Custom Agent (Ebene 2)** | [`rig.agent.md`](../../.github/agents/rig.agent.md) | Läuft nativ auf SimRacer (`192.168.178.68`), aus `git-labor` via **SSH &amp; Bridge**: Hardware-Hub (Ryzen 9, RTX 5070 Ti), SteamVR, `acs.exe`. |
| **Custom Agent (Ebene 2)** | [`light.agent.md`](../../.github/agents/light.agent.md) | Läuft nativ auf SimRacer (`192.168.178.68`), aus `git-labor` via **SSH &amp; Bridge**: Docker Engine, Session- &amp; Content-Orchestrator. |
| **Custom Agent (Ebene 3)** | [`dark.agent.md`](../../.github/agents/dark.agent.md) | Läuft isoliert im Docker-Container `ac-win11-sandbox` auf SimRacer, aus `git-labor` via **SSH (`:2222`) &amp; Bridge**. |
| **Custom Agent (Pitwall)** | [`sarah.agent.md`](../../.github/agents/sarah.agent.md) | Läuft auf IdeaPad 5 (`omARCHy`), aus `git-labor` via **SSH &amp; Bridge**: Live-Telemetrie-Coaching &amp; Videoschnitt. |
| **Custom Agent (24/7 Edge Hub)** | [`rick.agent.md`](../../.github/agents/rick.agent.md) | Läuft 24/7 auf `StrikerPi` (`192.168.178.86`), aus `git-labor` via **SSH/SCP &amp; Bridge**: Telemetrie-Relay (`:8080`), MQTT (`:1883`), Bare-Git (`/srv/git/simrig.git`). |
| **SSH-Terminal-Launcher** | [`Agent-Terminals.ps1`](../../labs/Agent-Terminals.ps1) | Zentrales Menü aus [`agent_registry.json`](../../../strikerpi-hub/telemetry-relay/agent_registry.json) für 7 kanonische Rollen; `@cyborg` lokal, `@general-sim` auf StrikerPi und Worker per SSH (`-ClientMode`). |
| **Projekt-Regeln** | [`AGENTS.md`](../../AGENTS.md) | Verbindliche Projekt- und Didaktik-Richtlinien für Copilot &amp; Antigravity. |
| **API-Regeln (`applyTo`)** | [`gemini-api.instructions.md`](../../.github/instructions/gemini-api.instructions.md) | Regeln für `google-genai` / `@google/genai`, Interactions API &amp; `geminiDocs` MCP. |
| **Globale Regeln** | [`vscode-experte.instructions.md`](../../../.copilot/instructions/vscode-experte.instructions.md) | Profil- &amp; Workspace-Regeln für den General Agent. |
| **Skill (`SKILL.md`)** | [`live-transfer-status-monitor` (Workspace)](../../.agents/skills/live-transfer-status-monitor/SKILL.md) | Live-Dashboard-Pflicht bei Datei-, Backup- &amp; LAN-Transfers (Spiegel: [`.gemini/skills`](../../.gemini/skills/live-transfer-status-monitor/SKILL.md)). |
| **Benutzer-Skills** | [`managing-python-dependencies`](../../../.copilot/skills/managing-python-dependencies/SKILL.md) · [`notebook-guidance`](../../../.copilot/skills/notebook-guidance/SKILL.md) · [`accidental-data-loss-prevention`](../../../.copilot/skills/accidental-data-loss-prevention/SKILL.md) | Globale Copilot-Skills unter `C:\Users\strik\.copilot\skills\`. |
| **Kommunikations-Historie** | [`AGENT_KOMMUNIKATION_HISTORIE.md`](../../../assetto-corsa-content/ac-sandbox/shared/agents/general-SIM/logs/AGENT_KOMMUNIKATION_HISTORIE.md) | Vollständige Markdown-Historie aller Agenten-Übergaben, Antworten &amp; Freigaben. |
| **Testbericht (10.11.2026)** | [`agenten-kommunikation-und-sandbox-testbericht.md`](../../../assetto-corsa-content/docs/03_agenten_system/agenten-kommunikation-und-sandbox-testbericht.md) | Verifizierter E2E-Testbericht zu `@general`, `@light`, `@rig`, `@dark`, `@sarah`, Sandbox-Start &amp; OSC-8-Log-Links. |
| **Terminal-Konsolen &amp; Tasks** | [`start_general_terminal.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/agents/general-SIM/start_general_terminal.ps1) · [`start_rig_terminal.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/agents/rig/start_rig_terminal.ps1) · [`start_light_terminal.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/agents/light/start_light_terminal.ps1) · [`start_dark_terminal.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/agents/dark/start_dark_terminal.ps1) · [`tasks.json`](../../../assetto-corsa-content/.vscode/tasks.json) | PowerShell-REPL-Konsolen mit OSC-8 Logfile-Links (`10` zentrale Agenten-Tasks im direktem `-ClientMode` in `git-labor.code-workspace` + `10` Infrastruktur-Tasks in `tasks.json`). |

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
