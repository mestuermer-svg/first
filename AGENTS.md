# Projektregeln & KI-Richtlinien fÃ¼r `git-labor` (`AGENTS.md`)

Dieses Repository dient als zentraler **Test- und Lern-Workspace** auf dem Hauptarbeitsplatz (`VanstrikeCyborg`) mit 5 klar definierten Fachrubriken:
1. **`Doku/01_Linux_Bash/`** & **`labs/01_linux_bash/`** â€“ Linux, Bash, Arch/Omarchy, SSH & Docker Sandboxes (`sbx`)
2. **`Doku/02_VSCode_Env/`** & **`labs/02_vscode_env/`** â€“ VS Code Architektur, Git/GitHub, MCP-Server, Ports (`8317`) & Gemini Ã–kosystem
3. **`Doku/03_Python_Coding/`**, **`labs/03_python/`** & **`notebook-agent-environments/`** â€“ Python (`uv`, `.venv`, Notebooks, Pylance, `pytest`, `google-genai`)
4. **`Doku/04_JS_TS_Web/`** & **`labs/04_js_ts_web/`** â€“ HTML5, CSS3, DOM, modernes JavaScript, TypeScript & `@google/genai`
5. **`Doku/05_Agents/`** & **`.github/` / `.agents/`** â€“ KI-Agenten erstellen, mit Skills & MCP ausrÃ¼sten, primen/trainieren & orchestrieren

---

## 1. Verbindliche Dokumentations- & Didaktik-Regeln (`agent_ruler.md` & `Agent-guidline.md`)
- **Sprache & Stil:** Deutsch, prÃ¤zise, direkt, technisch fundiert (mit Praxisbezug zu Software-Engineering & Automatisierungstechnik/SPS), frei von Floskeln.
- **Einklapp-Pflicht (`<details>`):** Alle HauptÃ¼berschriften und Unterkapitel in Lernskripten unter `Doku/` mÃ¼ssen mit `<details>` und `<summary>` umschlossen sein (**ohne** `open`-Attribut), sodass beim Ã–ffnen der Datei standardmÃ¤ÃŸig alles geschlossen ist.
- **7-Stufen-Aufbau fÃ¼r Lernskripte:**
  1. Nicht einklappbarer Metadaten-Kopf (`Thema`, `Autor: Michael StÃ¼rmer`, `Datum`)
  2. `<details><summary><b>Lernziele</b></summary>`
  3. `<details><summary><b>Kernkonzepte</b></summary>` (mit einklappbaren Unterkapiteln)
  4. `<details><summary><b>Ãœbungsaufgaben</b></summary>`
  5. `<details><summary><b>WeiterfÃ¼hrende Links & Quellen</b></summary>`
  6. `<details><summary><b>Chips & Kernaussagen</b></summary>`
  7. Standardisierter FuÃŸhinweis am Dateiende.

## 2. Gemini API & SDK Richtlinien (`Agent_setup.md`)
- Konsultiere vor dem Schreiben von Gemini-API-Code den **`geminiDocs` MCP-Server** (`gemini_search_docs` / `gemini_get_doc` unter `https://gemini-api-docs-mcp.dev`) oder den Index unter `https://aistudio.google.com/docs/llms.txt`.
- Verwende ausschlieÃŸlich das aktuelle **Google Gen AI SDK**:
  - **Python:** `google-genai` (`from google import genai`) â€“ niemals `google-generativeai`.
  - **TypeScript / JavaScript:** `@google/genai` (`import { GoogleGenAI } from "@google/genai"`) â€“ niemals `@google/generative-ai`.
- Bevorzuge die **Interactions API** (`client.interactions.create` bzw. `ai.interactions.create`) fÃ¼r neue Anwendungen.

## 3. Arbeitsweise im Workspace
- **Vorschau-Pflicht:** Zeige vor Ã„nderungen an globalen Konfigurationsdateien (`settings.json` oder `*.code-workspace`) immer zuerst ein Diff / eine Vorschau.
- **Python-Umgebungen:** Verwende niemals globales `pip install`, sondern immer die lokale `.venv` oder `uv` (`uv add`, `uv run`).
- **Geheimnisschutz:** Schreibe niemals echte API-Keys oder PasswÃ¶rter in versionierte Dateien; nutze Umgebungsvariablen (`GEMINI_API_KEY`) oder `sbx secret`.

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
<summary><span>ðŸ—ºï¸ Doku-Minimap (5 Rubriken &amp; Labs)</span><span title="Klicken zum VergrÃ¶ÃŸern / Einklappen">â›¶</span></summary>
<div class="minimap-preview-strip"><span>01 Linux</span><span>02 VSCode</span><span>03 Python</span><span>04 JS/TS</span><span>05 Agents</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root">ðŸ›ï¸ <a href="Doku/README.md">VanstrikeCyborg â€” git-labor Lern- &amp; Test-Architektur (Doku-Index)</a> Â |Â  <a href="README.md">Repo-README</a> Â |Â  <a href="AGENTS.md">AGENTS.md</a> Â |Â  <a href="notebook-agent-environments/README.md">Notebooks</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">ðŸ§ <a href="Doku/01_Linux_Bash/README.md">01_Linux_Bash (Linux, Shell &amp; Container)</a></div>
<ul class="doku-arch-lines">
<li>â”œâ”€ <a href="Doku/01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 â€¢ Bash CLI, Text-Tools, Streams &amp; Expansions</a> <a class="doku-arch-badge" href="labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>â”œâ”€ <a href="Doku/01_Linux_Bash/02_linux-systemadministration-und-interna.md">02 â€¢ Inodes, LVM, Prozesse, Boot-Prozess &amp; systemd</a></li>
<li>â”œâ”€ <a href="Doku/01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">03 â€¢ Arch Linux, Omarchy, Remote-SSH &amp; Nginx</a></li>
<li>â”œâ”€ <a href="Doku/01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">04 â€¢ Advanced Bash: Arrays, getopts &amp; Backups</a></li>
<li>â””â”€ <a href="Doku/01_Linux_Bash/05_docker-und-sbx-micro-vms.md">05 â€¢ Docker Grundlagen &amp; Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">ðŸ§© <a href="Doku/02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP &amp; Gemini)</a></div>
<ul class="doku-arch-lines">
<li>â”œâ”€ <a href="Doku/02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 â€¢ VS Code Architektur, Sprachserver (LSP) &amp; Remote</a></li>
<li>â”œâ”€ <a href="Doku/02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 â€¢ Git, GitHub Workflow &amp; Multi-Root Workspaces</a> <a class="doku-arch-badge" href="git-labor.code-workspace">Workspace</a></li>
<li>â”œâ”€ <a href="Doku/02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 â€¢ MCP-Server, Localhost-Proxy &amp; Port-Diagnose (8317)</a></li>
<li>â””â”€ <a href="Doku/02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 â€¢ Gemini Ã–kosystem, Google AI Studio &amp; API-Keys</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">ðŸ <a href="Doku/03_Python_Coding/README.md">03_Python_Coding (Python, uv &amp; GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>â”œâ”€ <a href="Doku/03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 â€¢ Python Setup: uv, .venv, Pylance &amp; Notebooks</a></li>
<li>â”œâ”€ <a href="Doku/03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">02 â€¢ Google GenAI SDK (google-genai) &amp; Interactions API</a></li>
<li>â””â”€ <a href="Doku/03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md">03 â€¢ Automatisierung, Datenanalyse &amp; pytest</a> <a class="doku-arch-badge" href="labs/03_python/sensor_demo.py">sensor_demo.py</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">ðŸŒ <a href="Doku/04_JS_TS_Web/README.md">04_JS_TS_Web (HTML/CSS, JS/TS &amp; Web-SDK)</a></div>
<ul class="doku-arch-lines">
<li>â”œâ”€ <a href="Doku/04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">01 â€¢ HTML5, CSS3 &amp; DOM-Manipulation Grundlagen</a> <a class="doku-arch-badge" href="labs/04_js_ts_web/rechner.html">rechner.html</a></li>
<li>â”œâ”€ <a href="Doku/04_JS_TS_Web/02_modernes-javascript-und-typescript.md">02 â€¢ Modernes JavaScript (ES6+) &amp; TypeScript</a></li>
<li>â””â”€ <a href="Doku/04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">03 â€¢ Google GenAI SDK (@google/genai) fÃ¼r Web-Apps</a></li>
</ul>
</div>
<div class="doku-arch-card r5">
<div class="doku-arch-card-title">ðŸ¤– <a href="Doku/05_Agents/README.md">05_Agents (KI-Agenten, Skills &amp; Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>â”œâ”€ <a href="Doku/05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">01 â€¢ Agent-Stilfibel, Didaktik-Ruler &amp; 7-Stufen-Aufbau</a></li>
<li>â”œâ”€ <a href="Doku/05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">02 â€¢ Agenten erstellen: Instructions, Rules &amp; Prompts</a> <a class="doku-arch-badge" href=".github/instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>â”œâ”€ <a href="Doku/05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 â€¢ Agenten ausrÃ¼sten: Skills (SKILL.md) &amp; MCP-Tools</a> <a class="doku-arch-badge" href=".agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>â””â”€ <a href="Doku/05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 â€¢ Agenten trainieren, primen &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href=".github/agents/light.agent.md">@light</a> <a class="doku-arch-badge" href=".github/agents/rig.agent.md">@rig</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
