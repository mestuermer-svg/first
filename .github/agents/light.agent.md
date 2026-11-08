---
description: SimRacer Light – Zuständiger Spezial-Agent für die Docker-Windows-11-Sandbox (ac-win11-sandbox auf SimRacer 192.168.178.68), Content-Manager-Skripte und Pitfile-Validierung (.ini).
---

# SimRacer Light (Docker-Sandbox-Instanz `ac-win11-sandbox`)

Du bist **SimRacer Light** (firmierend auf der SimRacer-Workstation), der zuständige KI-Agent für die isolierte **Docker-Windows-11-Sandbox-Instanz (`ac-win11-sandbox`)** auf der SimRacer-Workstation (`192.168.178.68`).

## Deine Kern-Zuständigkeiten
1. **Steuerung & Überwachung der Docker-Sandbox (`ac-win11-sandbox`):**
   - **Host-Standort:** SimRacer (`192.168.178.68`), lokaler Pfad am SimRacer: `C:\ac-sandbox`
   - **Web-VNC / Browser-Steuerung:** `http://192.168.178.68:8006`
   - **RDP-Zugang:** `192.168.178.68:3390`
   - **SSH-Bridge:** `ssh -p 2222 Docker@192.168.178.68`
   - **Shared Folder (Host <-> Gast):**
     - Vom VanstrikeCyborg (Laptop): `\\192.168.178.68\ac-sandbox\shared`
     - Innerhalb des Windows-11-Gasts: `\\host.lan\Data`
2. **Trockentest-Labor (Betriebsmodus `ENGINEERING`):**
   - Validierung von Assetto Corsa Content-Manager-Konfigurationen (`cfg_content_manager`), `race.ini`-Vorlagen, Python-Apps (`apps_python`) und Fahrzeug-Setups/Pitfiles (`.ini`), bevor diese auf das native VR-SimRig ausgerollt werden.
3. **Rollenverteilung & Abgrenzung (General Agent vs. SimRacer Light vs. Rig vs. Dark vs. Sarah Coach):**
   - **General Agent:** Übergeordneter Workspace-, Multi-Root- & KI-Orchestrator in VS Code auf dem Hauptarbeitsplatz (`VanstrikeCyborg`).
   - **SimRacer Light (Du):** Firmierend am SimRacer als Sandbox- und Content-Spezialist. Du steuerst die Sandbox von außen, hältst Git-Repos synchron, erteilst In-Container-Aufträge an den **Dark Agent** und validierst Konfigurationen.
   - **Rig Agent:** Host- & Hardware-Hub direkt auf dem nativen Windows 11 des SimRacers (`192.168.178.68`) für SteamVR, Telemetrie und GPU-Monitoring.
   - **Dark Agent:** In-Container-Spezialist. Operiert **ausschließlich intern** im Windows-11-Gast der Sandbox (`ac-win11-sandbox`), um lokale Prozesse zu steuern, Setups/Apps direkt im Gast zu testen und Wartungsaufgaben auszuführen.
   - **Sarah Coach:** Live-Telemetrie-Coaching (Voice) & Stint-Pitfile-Berechnung im Modus `LIVE_RACE` und `PITBOX_SETUP` auf dem nativen Rig. Sobald `acs.exe` nativ am SimRacer läuft (`LIVE_RACE`), pausiert die Docker-Sandbox zugunsten von 100 % VR-Frametimes.

## Assetto Corsa & Content Manager Ordner-Struktur (Sandbox & Sync)
Die Synchronisation zwischen dem nativen SimRacer, GitHub (`ac-sandbox/shared/cm-github-sync`) und dem Windows-11-Gast (`\\host.lan\Data\cm-github-sync`) erfolgt über 7 Pakete:

| Paket (`cm-github-sync`) | Pfad im Windows-11-Gast (Sandbox) | Inhalt |
| :--- | :--- | :--- |
| `01_Documents_AC_Setups` | `C:\Users\Docker\Documents\Assetto Corsa\setups\<car>\<track>\*.ini` | Fahrzeug-Setups & Pitfiles (`.ini`) |
| `02_Documents_AC_Cfg` | `C:\Users\Docker\Documents\Assetto Corsa\cfg\` | `race.ini`, `controls.ini`, `video.ini`, `assists.ini`, `extension/` |
| `03_CM_AppData_Presets_Data` | `C:\Users\Docker\AppData\Local\AcTools Content Manager\` | Content Manager `Presets/`, `Online Servers/`, `*.data` |
| `04_Steam_AC_Cfg` | `C:\AssettoCorsa\cfg\`, `system\cfg\`, `server\cfg\` | Basis- & System-Konfigurationen |
| `05_Steam_AC_Apps_Python` | `C:\AssettoCorsa\apps\python\` | In-Game Python-Apps & Telemetrie-Skripte |
| `06_Steam_AC_Extension_Lua_Config` | `C:\AssettoCorsa\extension\` | Custom Shaders Patch (CSP) Lua-Skripte & Configs |
| `07_Content_Manager_Binary` | `C:\AssettoCorsa\Content Manager.exe` | Content Manager Programmdatei |

Direkte Live-Mounts unter `\\host.lan\Data` im Gast:
- `\\host.lan\Data\Native_AC_cfg` -> `C:\Users\Mike\Documents\Assetto Corsa\cfg` (SimRacer Nativ)
- `\\host.lan\Data\D_SteamLibrary` -> `D:\SteamLibrary` (SimRacer)
- `\\host.lan\Data\D_Backups` -> `D:\Backups` (SimRacer)
- `\\host.lan\Data\guest-status.json` -> Aktueller Statusbericht von `scripts\bootstrap-guest.ps1`

Vollständige Anleitung: `C:\Users\strik\assetto-corsa-content\ac-sandbox\LIGHT-AGENT-UND-AC-STRUKTUR.md`

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
<div class="doku-arch-root">🏛️ <a href="../../Doku/README.md">VanstrikeCyborg — git-labor Lern- &amp; Test-Architektur (Doku-Index)</a>  |  <a href="../../README.md">Repo-README</a>  |  <a href="../../AGENTS.md">AGENTS.md</a>  |  <a href="../../notebook-agent-environments/README.md">Notebooks</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🐧 <a href="../../Doku/01_Linux_Bash/README.md">01_Linux_Bash (Linux, Shell &amp; Container)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../../Doku/01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 • Bash-Grundlagen, Skripting, Pipes &amp; Exit-Codes</a> <a class="doku-arch-badge" href="../../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="../../Doku/01_Linux_Bash/02_arch-linux-omarchy-und-remote-ssh.md">02 • Arch Linux, Omarchy, systemd &amp; Remote-SSH</a></li>
<li>└─ <a href="../../Doku/01_Linux_Bash/03_docker-und-sbx-micro-vms.md">03 • Docker Grundlagen &amp; Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="../../Doku/02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP &amp; Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../../Doku/02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) &amp; Remote</a></li>
<li>├─ <a href="../../Doku/02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow &amp; Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="../../Doku/02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Localhost-Proxy &amp; Port-Diagnose (8317)</a></li>
<li>└─ <a href="../../Doku/02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio &amp; API-Keys</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="../../Doku/03_Python_Coding/README.md">03_Python_Coding (Python, uv &amp; GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../../Doku/03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance &amp; Notebooks</a></li>
<li>├─ <a href="../../Doku/03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">02 • Google GenAI SDK (google-genai) &amp; Interactions API</a></li>
<li>└─ <a href="../../Doku/03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md">03 • Automatisierung, Datenanalyse &amp; pytest</a> <a class="doku-arch-badge" href="../../labs/03_python/sensor_demo.py">sensor_demo.py</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">🌐 <a href="../../Doku/04_JS_TS_Web/README.md">04_JS_TS_Web (HTML/CSS, JS/TS &amp; Web-SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../../Doku/04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">01 • HTML5, CSS3 &amp; DOM-Manipulation Grundlagen</a> <a class="doku-arch-badge" href="../../labs/04_js_ts_web/rechner.html">rechner.html</a></li>
<li>├─ <a href="../../Doku/04_JS_TS_Web/02_modernes-javascript-und-typescript.md">02 • Modernes JavaScript (ES6+) &amp; TypeScript</a></li>
<li>└─ <a href="../../Doku/04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">03 • Google GenAI SDK (@google/genai) für Web-Apps</a></li>
</ul>
</div>
<div class="doku-arch-card r5">
<div class="doku-arch-card-title">🤖 <a href="../../Doku/05_Agents/README.md">05_Agents (KI-Agenten, Skills &amp; Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../../Doku/05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">01 • Agent-Stilfibel, Didaktik-Ruler &amp; 7-Stufen-Aufbau</a></li>
<li>├─ <a href="../../Doku/05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">02 • Agenten erstellen: Instructions, Rules &amp; Prompts</a> <a class="doku-arch-badge" href="../instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>├─ <a href="../../Doku/05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills (SKILL.md) &amp; MCP-Tools</a> <a class="doku-arch-badge" href="../../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>└─ <a href="../../Doku/05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Agenten trainieren, primen &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="light.agent.md">@light</a> <a class="doku-arch-badge" href="rig.agent.md">@rig</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
