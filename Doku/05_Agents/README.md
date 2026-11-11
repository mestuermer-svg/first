> **Thema:** Rubrik 05 – KI-Agenten (Erstellen, Ausrüsten, Trainieren/Primen & Orchestrieren)
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

# 05 – KI-Agenten: Erstellen, Ausrüsten, Trainieren & Orchestrieren

Diese Rubrik ist das **Herzstück für den Bau und die Führung deiner KI-Agenten** im `git-labor`: Sie vereint die verbindlichen Didaktik- und Stilregeln (`agent_ruler.md` & `Agent-guidline.md`), das Erstellen eigener Custom Agents (`*.agent.md`) und Instructions (`*.instructions.md`), das Ausrüsten mit **Skills (`SKILL.md`)** und **MCP-Servern (`Agent_setup.md`)** sowie das strukturierte **Primen, Trainieren und Orchestrieren** einer mehrstufigen Agenten-Hierarchie.

<details>
<summary><b>Übersicht der Module in dieser Rubrik</b></summary>

| Modul | Datei | Inhalt & Fokus |
| :--- | :--- | :--- |
| **Modul 5.1** | [01_agent-stilfibel-und-didaktik-ruler.md](./01_agent-stilfibel-und-didaktik-ruler.md) | Die verbindlichen Regeln aus `agent_ruler.md` & `Agent-guidline.md`: Tonalität, `<details>`-Einklapp-Pflicht, 7-stufiger Lernskript-Aufbau und Chips. |
| **Modul 5.2** | [02_agenten-erstellen-instructions-rules-und-prompts.md](./02_agenten-erstellen-instructions-rules-und-prompts.md) | Wie man Agenten von Grund auf erstellt: Unterschied Prompt vs. Instruction vs. Custom Agent (`*.agent.md`), Model Harnesses, dynamische Reasoning-Stufen (Thinking), Pylance/TypeScript LSP-Anbindung, Speicherorte (`AGENTS.md`, `.github/`) & YAML-Frontmatter. |
| **Modul 5.3** | [03_agenten-ausruesten-skills-und-mcp-tools.md](./03_agenten-ausruesten-skills-und-mcp-tools.md) | Agenten mit Fähigkeiten ausrüsten (`Agent_setup.md` & `SKILL.md`): Offizielle Gemini Skills (`skills.sh`), eigene `SKILL.md`-Pakete, `geminiDocs` MCP & `llms.txt`. |
| **Modul 5.4** | [04_agenten-trainieren-primen-und-orchestrieren.md](./04_agenten-trainieren-primen-und-orchestrieren.md) | Agenten-Training (Priming, Evaluierung, Memory-System), Remote Extension Host & Headless-Agenten (Arch/Pi 4), Privacy-First Observability & KI-Traffic-Analyse (On-Premise Matomo) sowie die Systemarchitektur um den **General Agenten** auf `VanstrikeCyborg`. |
| **Modul 5.5** | [05_workspace-schnittstelle-simracer-und-agenten-terminals.md](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md) | Workspace-Schnittstelle zwischen Git-Labor, SimRacer &amp; StrikerPi: Task-Queue (`inbox/` -> `outbox/`), Freigabe-Gate (`@rig`/`@light` ↔ `@general`), SSH-Launcher (`Agent-Terminals.ps1` / `-ClientMode`), Agent `@rick` (`simrig.git`), Freigabe-Policy `AUTO`/`MANUAL` &amp; MQTT-Anbindung, `AGENT_KOMMUNIKATION_HISTORIE.md` &amp; `sim_agent_bridge.py`. |
| **Modul 5.6** | [05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md](./05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md) | 5-Knoten-Topologie (Laptop, SimRacer, Sandbox, Archibald, StrikerPi), Multi-Root-Workspace, Port-Matrix, 6-Rollen-Modell, Handshake mit Pre-Flight-Check und SSH-Terminalprofile. |
| **Änderungsprotokoll** | [SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md) | Systemumstellung vom 11.11.2026 (MQTT, Gatekeeper `AUTO`/`MANUAL`, Relay-Logik, Caddy-Roadmap) mit verifiziertem Ist-Stand und Betriebsnachweis aus den Systemtests. |

</details>

<details>
<summary><b>Direktlinks: Agent-Dateien, Skills, Regeln &amp; Terminal-Historie</b></summary>

| Kategorie | Datei | Zweck &amp; Geltungsbereich |
| :--- | :--- | :--- |
| **Custom Agent (Global – `General Cyborg`)** | [`general.agent.md` (User)](../../../.copilot/agents/general.agent.md) | Läuft auf `VanstrikeCyborg` (global): MSI Cyborg 15 Hardware/BIOS/MSI Center, NVIDIA App MCP (`:13508`), VIVE VR, VS Code Workspaces &amp; Profile. |
| **Custom Agent (Ebene 1 – `General Sim`)** | [`general.agent.md` (Workspace)](../../.github/agents/general.agent.md) | Läuft auf `VanstrikeCyborg` (Workspace-Leitstand): steuert SimRacer (`192.168.178.68`), Assetto Corsa, Docker-Sandbox &amp; Freigabe-Hub (`ok`/`nein`/`reply`). |
| **Custom Agent (Ebene 2)** | [`rig.agent.md`](../../.github/agents/rig.agent.md) | Läuft nativ auf SimRacer (`192.168.178.68`): Hardware-Hub (Ryzen 9, RTX 5070 Ti), SteamVR, `acs.exe`, Rückversicherungspflicht mit `@general`. |
| **Custom Agent (Ebene 2)** | [`light.agent.md`](../../.github/agents/light.agent.md) | Läuft nativ auf SimRacer (`192.168.178.68`): Docker Engine, Session- &amp; Content-Orchestrator, Rückversicherungspflicht mit `@general`. |
| **Custom Agent (Ebene 3)** | [`dark.agent.md`](../../.github/agents/dark.agent.md) | Läuft isoliert im Docker-Container `ac-win11-sandbox` auf SimRacer: Setups, CM &amp; In-Guest-Tests. |
| **Custom Agent (Pitwall)** | [`sarah.agent.md`](../../.github/agents/sarah.agent.md) | Läuft auf IdeaPad 5 (`omARCHy`): Live-Telemetrie-Coaching &amp; Videoschnitt. |
| **Custom Agent (24/7 Edge Hub)** | [`rick.agent.md`](../../.github/agents/rick.agent.md) | Läuft 24/7 auf `StrikerPi` (`192.168.178.86`): Telemetrie-Relay (`:8080`), MQTT (`:1883`), Bare-Git (`/srv/git/simrig.git`) &amp; LAN-Watchdog. |
| **SSH-Terminal-Launcher** | [`Agent-Terminals.ps1`](../../labs/Agent-Terminals.ps1) | Zentrales Menü im `git-labor` für alle 6 Agenten-Terminals (Host-Lokal vs. SSH `-ClientMode`). |
| **Projekt-Regeln** | [`AGENTS.md`](../../AGENTS.md) | Verbindliche Projekt- und Didaktik-Richtlinien für Copilot &amp; Antigravity. |
| **API-Regeln (`applyTo`)** | [`gemini-api.instructions.md`](../../.github/instructions/gemini-api.instructions.md) | Regeln für `google-genai` / `@google/genai`, Interactions API &amp; `geminiDocs` MCP. |
| **Globale Regeln** | [`vscode-experte.instructions.md`](../../../.copilot/instructions/vscode-experte.instructions.md) | Profil- &amp; Workspace-Regeln für den General Agent. |
| **Skill (`SKILL.md`)** | [`live-transfer-status-monitor` (Workspace)](../../.agents/skills/live-transfer-status-monitor/SKILL.md) | Live-Dashboard-Pflicht bei Datei-, Backup- &amp; LAN-Transfers (Spiegel: [`.gemini/skills`](../../.gemini/skills/live-transfer-status-monitor/SKILL.md)). |
| **Benutzer-Skills** | [`managing-python-dependencies`](../../../.copilot/skills/managing-python-dependencies/SKILL.md) · [`notebook-guidance`](../../../.copilot/skills/notebook-guidance/SKILL.md) · [`accidental-data-loss-prevention`](../../../.copilot/skills/accidental-data-loss-prevention/SKILL.md) | Globale Copilot-Skills unter `C:\Users\strik\.copilot\skills\`. |
| **Kommunikations-Historie** | [`AGENT_KOMMUNIKATION_HISTORIE.md`](../../../assetto-corsa-content/ac-sandbox/shared/agents/general/logs/AGENT_KOMMUNIKATION_HISTORIE.md) | Vollständige Markdown-Historie aller Agenten-Übergaben, Antworten &amp; Freigaben. |
| **Testbericht (10.11.2026)** | [`agenten-kommunikation-und-sandbox-testbericht.md`](../../../assetto-corsa-content/docs/03_agenten_system/agenten-kommunikation-und-sandbox-testbericht.md) | Verifizierter E2E-Testbericht zu `@general`, `@light`, `@rig`, `@dark`, `@sarah`, Sandbox-Start &amp; OSC-8-Log-Links. |
| **Terminal-Konsolen &amp; Tasks** | [`start_general_terminal.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/agents/general/start_general_terminal.ps1) · [`start_rig_terminal.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/agents/rig/start_rig_terminal.ps1) · [`start_light_terminal.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/agents/light/start_light_terminal.ps1) · [`start_dark_terminal.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/agents/dark/start_dark_terminal.ps1) · [`tasks.json`](../../../assetto-corsa-content/.vscode/tasks.json) | PowerShell-REPL-Konsolen mit OSC-8 Logfile-Links und optimierter VS-Code-Task-Konfiguration. |

</details>

---
*Hinweis zur Organisation:* Die erstellte Dokumentation ist am Drehlaufwerk abgelegt und mit einer kurzen Zusammenfassung von den Chips auch in den Notebooks verlinkt.

<!-- DOKU-MINIMAP-START -->
<style>
.doku-arch-flow { font-family: var(--vscode-editor-font-family, Consolas, monospace); background: rgba(20, 24, 33, 0.92); border: 1px solid rgba(100, 140, 220, 0.35); border-radius: 10px; padding: 14px 16px; margin: 10px 0; color: #e2e8f0; }
.doku-arch-root { text-align: center; font-weight: 700; font-size: 1.04em; padding: 8px 12px; margin-bottom: 12px; background: linear-gradient(135deg, rgba(37, 99, 235, 0.28), rgba(15, 23, 42, 0.9)); border: 1px solid rgba(96, 165, 250, 0.5); border-radius: 8px; }
.doku-arch-root a { color: #93c5fd !important; text-decoration: none !important; }
.doku-arch-root a:hover { text-decoration: underline !important; }
.doku-arch-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(275px, 1fr)); gap: 10px; }
.doku-arch-card { background: rgba(30, 41, 59, 0.78); border: 1px solid rgba(148, 163, 184, 0.28); border-left: 4px solid #3b82f6; border-radius: 8px; padding: 9px 11px; transition: transform 0.12s ease, border-color 0.12s ease; }
.doku-arch-card:hover { border-color: #60a5fa; transform: translateY(-1px); }
.doku-arch-card.r1 { border-left-color: #22c55e; }
.doku-arch-card.r2 { border-left-color: #3b82f6; }
.doku-arch-card.r3 { border-left-color: #eab308; }
.doku-arch-card.r4 { border-left-color: #ec4899; }
.doku-arch-card.r5 { border-left-color: #a855f7; }
.doku-arch-card-title { font-weight: 700; font-size: 0.95em; margin-bottom: 6px; padding-bottom: 4px; border-bottom: 1px dashed rgba(148, 163, 184, 0.25); }
.doku-arch-card-title a { color: #f8fafc !important; text-decoration: none !important; display: block; }
.doku-arch-card-title a:hover { color: #60a5fa !important; }
.doku-arch-lines { list-style: none; margin: 0; padding: 0; font-size: 0.85em; line-height: 1.5; }
.doku-arch-lines li { margin: 3px 0; padding: 2px 5px; border-radius: 4px; white-space: normal; }
.doku-arch-lines li:hover { background: rgba(59, 130, 246, 0.18); }
.doku-arch-lines a { color: #cbd5e1 !important; text-decoration: none !important; display: inline; }
.doku-arch-lines a:hover { color: #93c5fd !important; text-decoration: underline !important; }
.doku-arch-badge { display: inline-block; font-size: 0.75em; padding: 0 5px; margin-left: 4px; border-radius: 4px; background: rgba(59, 130, 246, 0.22); color: #93c5fd !important; border: 1px solid rgba(96, 165, 250, 0.35); }
details.doku-minimap { position: fixed; bottom: 18px; right: 18px; z-index: 9999; width: 250px; max-height: 76px; overflow: hidden; background: rgba(15, 23, 42, 0.94); border: 1px solid rgba(96, 165, 250, 0.65); border-radius: 10px; box-shadow: 0 8px 26px rgba(0, 0, 0, 0.65); backdrop-filter: blur(8px); transition: width 0.18s ease, max-height 0.18s ease; font-family: var(--vscode-font-family, sans-serif); }
details.doku-minimap:hover { border-color: #60a5fa; }
details.doku-minimap[open] { width: min(860px, 94vw); max-height: 84vh; overflow-y: auto; padding-bottom: 10px; }
details.doku-minimap > summary { cursor: pointer; list-style: none; padding: 8px 12px; font-weight: 700; font-size: 0.84em; color: #f8fafc; background: linear-gradient(90deg, rgba(37, 99, 235, 0.45), rgba(30, 41, 59, 0.9)); border-bottom: 1px solid rgba(148, 163, 184, 0.25); display: flex; align-items: center; justify-content: space-between; user-select: none; }
details.doku-minimap > summary::-webkit-details-marker { display: none; }
details.doku-minimap .minimap-preview-strip { display: flex; gap: 4px; padding: 5px 10px 7px 10px; font-size: 0.72em; color: #94a3b8; justify-content: space-between; }
details.doku-minimap[open] .minimap-preview-strip { display: none; }
details.doku-minimap .minimap-preview-strip span { background: rgba(30, 41, 59, 0.9); padding: 2px 6px; border-radius: 4px; border: 1px solid rgba(148, 163, 184, 0.25); }
details.doku-minimap .minimap-body { padding: 8px 12px 4px 12px; }
</style>
<details class="doku-minimap">
<summary><span>🗺️ Doku-Minimap (5 Rubriken &amp; Labs)</span><span title="Klicken zum Vergrößern / Einklappen">⛶</span></summary>
<div class="minimap-preview-strip"><span>01 Linux</span><span>02 VSCode</span><span>03 Python</span><span>04 JS/TS</span><span>05 Agents</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root">🏛️ <a href="../README.md">VanstrikeCyborg — git-labor Lern- &amp; Test-Architektur (Doku-Index)</a>  |  <a href="../../README.md">Repo-README</a>  |  <a href="../../AGENTS.md">AGENTS.md</a>  |  <a href="../../notebook-agent-environments/README.md">Notebooks</a></div>
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
<li>├─ <a href="../02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Localhost-Proxy &amp; Port-Diagnose (8317)</a></li>
<li>└─ <a href="../02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio &amp; API-Keys</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="../03_Python_Coding/README.md">03_Python_Coding (Python, uv &amp; GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance &amp; Notebooks</a></li>
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
<div class="doku-arch-card-title">🤖 <a href="README.md">05_Agents (KI-Agenten, Skills &amp; Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="01_agent-stilfibel-und-didaktik-ruler.md">01 • Agent-Stilfibel, Didaktik-Ruler &amp; 7-Stufen-Aufbau</a></li>
<li>├─ <a href="02_agenten-erstellen-instructions-rules-und-prompts.md">02 • Agenten erstellen: Instructions, Rules &amp; Prompts</a> <a class="doku-arch-badge" href="../../.github/instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>├─ <a href="03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills (SKILL.md) &amp; MCP-Tools</a> <a class="doku-arch-badge" href="../../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>├─ <a href="04_agenten-trainieren-primen-und-orchestrieren.md">04 • Agenten trainieren, primen &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../../.github/agents/light.agent.md">@light</a> <a class="doku-arch-badge" href="../../.github/agents/rig.agent.md">@rig</a></li>
<li>└─ <a href="05_workspace-schnittstelle-simracer-und-agenten-terminals.md">05 • Workspace-Schnittstelle: SimRacer &amp; Agenten-Terminals</a> <a class="doku-arch-badge" href="../../labs/03_python/sim_agent_bridge.py">Bridge</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
