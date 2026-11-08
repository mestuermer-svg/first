> **Thema:** Zentrales Handbuch & Inhaltsverzeichnis der Wissensdatenbank (`Doku/`) im Test- und Lern-Workspace `git-labor`
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

# Wissensdatenbank & Lern-Handbuch (`git-labor/Doku`)

Willkommen in der neu strukturierten Dokumentation des **`git-labor` Test- und Lern-Workspaces**. Nach der sauberen Ausgliederung der Assetto-Corsa-Spezifika in ihren eigenen Workspace sind hier alle allgemeinen Entwicklungs-, System- und KI-Themen in **5 klar getrennten Fachrubriken** gebündelt und nach den Vorgaben aus `agent_ruler.md` und `Agent-guidline.md` (mit standardmäßig geschlossenen `<details>`-Kapiteln) aufbereitet.

<details>
<summary><b>Architektur der 5 Lern- & Test-Rubriken</b></summary>

<div class="doku-arch-flow">
<div class="doku-arch-root-wrap">
<div class="doku-arch-root">
<div class="doku-arch-root-title">git-labor Wissensdatenbank (Doku/) &amp; Praxis-Übungslabor (labs/)</div>
<div class="doku-arch-root-links">
<a href="./README.md" title="Zentrales Handbuch (Doku/README.md)">📚 Doku-Zentrale</a>
<a href="../README.md" title="Haupt-README des Repositories">🏠 Workspace-Root</a>
<a href="../labs/01_linux_bash/check-env.sh" title="Bash Lab: check-env.sh">🐧 Lab 01 (.sh)</a>
<a href="../labs/03_python/sensor_demo.py" title="Python Lab: sensor_demo.py">🐍 Lab 03 (.py)</a>
<a href="../labs/04_js_ts_web/rechner.html" title="Web Lab: rechner.html">🌐 Lab 04 (.html)</a>
</div>
</div>
<div class="doku-arch-stem"></div>
</div>
<div class="doku-arch-bus"></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<a class="doku-arch-card-head" href="./01_Linux_Bash/README.md" title="Rubrik 01_Linux_Bash öffnen"><span>01_Linux_Bash</span><span class="doku-arch-badge">Linux, Bash & Container</span></a>
<div class="doku-arch-rows">
<div class="doku-arch-row"><a href="./01_Linux_Bash/01_bash-grundlagen-und-skripting.md" style="color:inherit;text-decoration:none;flex:1;" title="01_Linux_Bash/01_bash-grundlagen-und-skripting.md">• 01 • Bash CLI, Streams & Expansions</a><a class="doku-arch-badge" href="../labs/01_linux_bash/check-env.sh" title="Direktlink: 01_linux_bash/check-env.sh">Lab .sh</a></div>
<div class="doku-arch-row"><a href="./01_Linux_Bash/02_linux-systemadministration-und-interna.md" style="color:inherit;text-decoration:none;flex:1;" title="01_Linux_Bash/02_linux-systemadministration-und-interna.md">• 02 • Inodes, LVM, Boot, systemd & Net</a><a class="doku-arch-badge" href="./01_Linux_Bash/02_linux-systemadministration-und-interna.md" title="Direktlink: 01_Linux_Bash/02_linux-systemadministration-und-interna.md">LVM/sys</a></div>
<div class="doku-arch-row"><a href="./01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md" style="color:inherit;text-decoration:none;flex:1;" title="01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">• 03 • Arch, Omarchy, SSH & Nginx</a><a class="doku-arch-badge" href="./01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md" title="Direktlink: 01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">Nginx</a></div>
<div class="doku-arch-row"><a href="./01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md" style="color:inherit;text-decoration:none;flex:1;" title="01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">• 04 • Advanced Bash: Arrays & Backups</a><a class="doku-arch-badge" href="./01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md" title="Direktlink: 01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">getopts</a></div>
<div class="doku-arch-row"><a href="./01_Linux_Bash/05_docker-und-sbx-micro-vms.md" style="color:inherit;text-decoration:none;flex:1;" title="01_Linux_Bash/05_docker-und-sbx-micro-vms.md">• 05 • Docker & sbx Micro-VMs</a><a class="doku-arch-badge" href="./01_Linux_Bash/05_docker-und-sbx-micro-vms.md" title="Direktlink: 01_Linux_Bash/05_docker-und-sbx-micro-vms.md">sbx</a></div>
</div>
</div>
<div class="doku-arch-card r2">
<a class="doku-arch-card-head" href="./02_VSCode_Env/README.md" title="Rubrik 02_VSCode_Env öffnen"><span>02_VSCode_Env</span><span class="doku-arch-badge">VS Code, Git, MCP & Gemini</span></a>
<div class="doku-arch-rows">
<div class="doku-arch-row"><a href="./02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md" style="color:inherit;text-decoration:none;flex:1;" title="02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">• VS Code Multi-Prozess & LSP</a><a class="doku-arch-badge" href="./02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md" title="Direktlink: 02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">LSP</a></div>
<div class="doku-arch-row"><a href="./02_VSCode_Env/02_git-github-und-multi-root-workspaces.md" style="color:inherit;text-decoration:none;flex:1;" title="02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">• Git 4-Stufen-Workflow & Multi-Root</a><a class="doku-arch-badge" href="../git-labor.code-workspace" title="Direktlink: git-labor.code-workspace">Workspace</a></div>
<div class="doku-arch-row"><a href="./02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md" style="color:inherit;text-decoration:none;flex:1;" title="02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">• MCP-Server & Localhost-Proxy (:8317)</a><a class="doku-arch-badge" href="../.vscode/mcp.json" title="Direktlink: .vscode/mcp.json">mcp.json</a></div>
<div class="doku-arch-row"><a href="./02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md" style="color:inherit;text-decoration:none;flex:1;" title="02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">• Gemini Ökosystem, API-Keys & Hardware</a><a class="doku-arch-badge" href="./02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md" title="Direktlink: 02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">AI Studio</a></div>
</div>
</div>
<div class="doku-arch-card r3">
<a class="doku-arch-card-head" href="./03_Python_Coding/README.md" title="Rubrik 03_Python_Coding öffnen"><span>03_Python_Coding</span><span class="doku-arch-badge">Python, uv, Notebooks & SDK</span></a>
<div class="doku-arch-rows">
<div class="doku-arch-row"><a href="./03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md" style="color:inherit;text-decoration:none;flex:1;" title="03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">• Moderne Umgebungen (uv & .venv)</a><a class="doku-arch-badge" href="./03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md" title="Direktlink: 03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">uv/.venv</a></div>
<div class="doku-arch-row"><a href="./03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md" style="color:inherit;text-decoration:none;flex:1;" title="03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">• Jupyter Notebooks (Python 3.14)</a><a class="doku-arch-badge" href="../notebook-agent-environments/agent_demo.ipynb" title="Direktlink: notebook-agent-environments/agent_demo.ipynb">.ipynb</a></div>
<div class="doku-arch-row"><a href="./03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md" style="color:inherit;text-decoration:none;flex:1;" title="03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">• Google GenAI SDK (google-genai)</a><a class="doku-arch-badge" href="./03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md" title="Direktlink: 03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">GenAI</a></div>
<div class="doku-arch-row"><a href="./03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md" style="color:inherit;text-decoration:none;flex:1;" title="03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md">• Type Hints (Pylance) & pytest</a><a class="doku-arch-badge" href="../labs/03_python/sensor_demo.py" title="Direktlink: 03_python/sensor_demo.py">Lab .py</a></div>
</div>
</div>
<div class="doku-arch-card r4">
<a class="doku-arch-card-head" href="./04_JS_TS_Web/README.md" title="Rubrik 04_JS_TS_Web öffnen"><span>04_JS_TS_Web</span><span class="doku-arch-badge">HTML5, CSS3, DOM & TypeScript</span></a>
<div class="doku-arch-rows">
<div class="doku-arch-row"><a href="./04_JS_TS_Web/01_html-css-und-dom-grundlagen.md" style="color:inherit;text-decoration:none;flex:1;" title="04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">• HTML5, CSS3 & Browser-DOM</a><a class="doku-arch-badge" href="./04_JS_TS_Web/01_html-css-und-dom-grundlagen.md" title="Direktlink: 04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">DOM</a></div>
<div class="doku-arch-row"><a href="./04_JS_TS_Web/01_html-css-und-dom-grundlagen.md" style="color:inherit;text-decoration:none;flex:1;" title="04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">• Praxis-App rechner.html</a><a class="doku-arch-badge" href="../labs/04_js_ts_web/rechner.html" title="Direktlink: 04_js_ts_web/rechner.html">App .html</a></div>
<div class="doku-arch-row"><a href="./04_JS_TS_Web/02_modernes-javascript-und-typescript.md" style="color:inherit;text-decoration:none;flex:1;" title="04_JS_TS_Web/02_modernes-javascript-und-typescript.md">• Modernes JS (ES6+) & TypeScript</a><a class="doku-arch-badge" href="./04_JS_TS_Web/02_modernes-javascript-und-typescript.md" title="Direktlink: 04_JS_TS_Web/02_modernes-javascript-und-typescript.md">ES6+/TS</a></div>
<div class="doku-arch-row"><a href="./04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md" style="color:inherit;text-decoration:none;flex:1;" title="04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">• Node.js & @google/genai SDK</a><a class="doku-arch-badge" href="./04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md" title="Direktlink: 04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">TS SDK</a></div>
</div>
</div>
<div class="doku-arch-card r5">
<a class="doku-arch-card-head" href="./05_Agents/README.md" title="Rubrik 05_Agents öffnen"><span>05_Agents</span><span class="doku-arch-badge">KI-Agenten, Skills & MCP</span></a>
<div class="doku-arch-rows">
<div class="doku-arch-row"><a href="./05_Agents/01_agent-stilfibel-und-didaktik-ruler.md" style="color:inherit;text-decoration:none;flex:1;" title="05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">• Stilfibel & Didaktik-Ruler</a><a class="doku-arch-badge" href="./05_Agents/01_agent-stilfibel-und-didaktik-ruler.md" title="Direktlink: 05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">Ruler</a></div>
<div class="doku-arch-row"><a href="./05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md" style="color:inherit;text-decoration:none;flex:1;" title="05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">• Erstellen: Instructions & *.agent.md</a><a class="doku-arch-badge" href="../AGENTS.md" title="Direktlink: AGENTS.md">AGENTS.md</a></div>
<div class="doku-arch-row"><a href="./05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md" style="color:inherit;text-decoration:none;flex:1;" title="05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">• Ausrüsten: Skills, geminiDocs MCP, llms.txt</a><a class="doku-arch-badge" href="../.agents/skills/live-transfer-status-monitor/SKILL.md" title="Direktlink: .agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></div>
<div class="doku-arch-row"><a href="./05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md" style="color:inherit;text-decoration:none;flex:1;" title="05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">• Trainieren: Priming, Memory & General Agent</a><a class="doku-arch-badge" href="./05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md" title="Direktlink: 05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">Orchestrator</a></div>
</div>
</div>
</div>
</div>

</details>

<details>
<summary><b>1. Rubrik: Linux (Bash), Systemsteuerung & Container (<code>01_Linux_Bash/</code>)</b></summary>

* **[Übersicht der Rubrik 01](./01_Linux_Bash/README.md)**
* **[01_bash-grundlagen-und-skripting.md](./01_Linux_Bash/01_bash-grundlagen-und-skripting.md)** – Terminal vs. Shell vs. Kernel, Navigation, Textfilter (`grep`, `awk`, `cut`, `sort`), Streams (0, 1, 2, `2>&1`, `&>`), Here-Docs, Pipes, `tee`, Environment (`$PATH`), Aliases, ANSI-Prompts (`PS1`) und Shell Expansions.
* **[02_linux-systemadministration-und-interna.md](./01_Linux_Bash/02_linux-systemadministration-und-interna.md)** – Inodes, Hard-/Softlinks, `/etc/passwd` & `/etc/shadow`, Dateirechte & Spezial-Bits (SUID, SGID, Sticky-Bit `1777`), Prozesse, Signale, Job Control (`&`, `jobs`, `nohup`), Boot-Prozess (UEFI/GRUB/systemd Targets), LVM Online-Expansion, systemd-Timer, Netzwerkdiagnose (`ss`, `tcpdump`) & Firewalls (`firewalld`, SELinux).
* **[03_arch-linux-omarchy-und-remote-ssh.md](./01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md)** – Rolling-Release-Wartung mit `pacman`, systemd-Dienste (`systemctl`, `journalctl`), Omarchy (Hyprland), SSH-Keys (`ed25519`), `~/.ssh/config`, VS Code Remote-SSH und Nginx-Webserver-Deployment auf dem Raspberry Pi 4.
* **[04_fortgeschrittenes-bash-skripting-und-automatisierung.md](./04_fortgeschrittenes-bash-skripting-und-automatisierung.md)** – Advanced Bash: Arithmetik (`$((...))` & `bc`), Kontrollstrukturen (`if [[ ... ]]`, Regex `=~`), Schleifen, Arrays (`declare -A`), Funktionen (`local`), `getopts`, API-Fetch mit `curl`/`jq`, Backup-Rotation (`tar.gz`), Verzeichnis-Monitor und Dialoge (`whiptail`).
* **[05_docker-und-sbx-micro-vms.md](./01_Linux_Bash/05_docker-und-sbx-micro-vms.md)** – Klassisches Docker vs. Docker Sandboxes CLI (`sbx`), isolierte Linux-Micro-VMs ohne Docker Desktop, Secret-Proxy und Read-Only-Mounts (`:ro`).

</details>

<details>
<summary><b>2. Rubrik: VS Code Environment, Git, MCP & LLM (<code>02_VSCode_Env/</code>)</b></summary>

* **[Übersicht der Rubrik 02](./02_VSCode_Env/README.md)**
* **[01_vscode-architektur-lsp-und-remote.md](./02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md)** – Projekt Monaco, Electron, Prozesstrennung (Renderer vs. Extension Host), Language Server Protocol (LSP) und Dev Containers.
* **[02_git-github-und-multi-root-workspaces.md](./02_VSCode_Env/02_git-github-und-multi-root-workspaces.md)** – Der 4-Stufen-Workflow in Git (`Strg+Shift+G`), `.git`-Interna, `.gitignore` gegen das 100-MB-Limit, `.code-workspace` vs. Codespaces.
* **[03_mcp-server-localhost-proxy-und-ports.md](./02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md)** – Hybride Localhost-Bridge, Port-Trennung (`8317` CLIProxyAPI vs. `8000` Antigravity Web-UI), natives `github-mcp-server.exe`, NVIDIA App MCP (`13508`) und `geminiDocs`.
* **[04_gemini-oekosystem-ai-studio-und-api-keys.md](./02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md)** – Google AI Pro Abo vs. Gemini API, Google AI Studio Playground, Authorization API Keys, Umgebungsvariablen und RAM-Management auf dem MSI Cyborg 15 (16 GB DDR5).

</details>

<details>
<summary><b>3. Rubrik: Python Coding, Notebooks & GenAI (<code>03_Python_Coding/</code>)</b></summary>

* **[Übersicht der Rubrik 03](./03_Python_Coding/README.md)**
* **[01_python-setup-uv-venv-und-notebooks.md](./03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md)** – Warum man niemals global `pip install` nutzt, Paketmanagement mit `uv` (`pyproject.toml`, `uv.lock`), `.venv`-Aktivierung und Jupyter Notebooks (`notebook-agent-environments/`).
* **[02_gemini-api-python-sdk-und-interactions.md](./03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md)** – Das aktuelle `google-genai` SDK (statt `google-generativeai`), `client.interactions.create`, Structured Outputs mit Pydantic und Function Calling.
* **[03_python-automatisierung-datenanalyse-und-tests.md](./03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md)** – Statische Typannotationen für Pylance, plattformunabhängige Pfade mit `pathlib.Path`, Unit-Tests mit `pytest` und BigFrames-Grundlagen.

</details>

<details>
<summary><b>4. Rubrik: JS & TS, HTML & CSS (<code>04_JS_TS_Web/</code>)</b></summary>

* **[Übersicht der Rubrik 04](./04_JS_TS_Web/README.md)**
* **[01_html-css-und-dom-grundlagen.md](./04_JS_TS_Web/01_html-css-und-dom-grundlagen.md)** – Zusammenspiel von HTML5, CSS3 und Browser-DOM, Typumwandlung von Texteingaben (`Number()`) und das komplette Praxisprojekt `rechner.html`.
* **[02_modernes-javascript-und-typescript.md](./04_JS_TS_Web/02_modernes-javascript-und-typescript.md)** – Browser vs. Node.js, ES6+ Syntax, `async/await` mit `fetch`, statische Typsicherheit in TypeScript (`interface`, Union Types) und `tsconfig.json`.
* **[03_gemini-sdk-typescript-und-web-apps.md](./04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md)** – Das aktuelle `@google/genai` SDK in TypeScript/Node.js, JSON-Schemata (`Type.OBJECT`) und sichere Trennung von Frontend und Backend-API-Keys.

</details>

<details>
<summary><b>5. Rubrik: Agents – Erstellen, Ausrüsten, Trainieren & Orchestrieren (<code>05_Agents/</code>)</b></summary>

* **[Übersicht der Rubrik 05](./05_Agents/README.md)**
* **[01_agent-stilfibel-und-didaktik-ruler.md](./05_Agents/01_agent-stilfibel-und-didaktik-ruler.md)** – Die verbindlichen Regeln aus `Agent-guidline.md` und `agent_ruler.md`: Schreibstil, `<details>`-Einklapp-Pflicht, 7-Stufen-Aufbau und Chips.
* **[02_agenten-erstellen-instructions-rules-und-prompts.md](./05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md)** – Unterschied Prompt vs. Instruction vs. Rule vs. Custom Agent (`*.agent.md`), Speicherorte (`AGENTS.md`, `.github/instructions/`, `.github/agents/`) und `applyTo`.
* **[03_agenten-ausruesten-skills-und-mcp-tools.md](./05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md)** – Agenten gegen veraltetes Wissen ausrüsten (`Agent_setup.md` & `SKILL.md`): `geminiDocs` MCP, `llms.txt`, offizielle Gemini-Skills (`skills.sh` / Context7) und eigene `SKILL.md`-Pakete.
* **[04_agenten-trainieren-primen-und-orchestrieren.md](./05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md)** – Priming-Methodik, 3-Stufen-Memory (`/memories/`), Evaluierung (`analyze-prompt`) und die Architektur um den **General Agenten** auf `VanstrikeCyborg`.

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
<div class="doku-arch-root">🏛️ <a href="README.md">VanstrikeCyborg — git-labor Lern- &amp; Test-Architektur (Doku-Index)</a>  |  <a href="../README.md">Repo-README</a>  |  <a href="../AGENTS.md">AGENTS.md</a>  |  <a href="../notebook-agent-environments/README.md">Notebooks</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🐧 <a href="01_Linux_Bash/README.md">01_Linux_Bash (Linux, Shell &amp; Container)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 • Bash CLI, Text-Tools, Streams &amp; Expansions</a> <a class="doku-arch-badge" href="../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="01_Linux_Bash/02_linux-systemadministration-und-interna.md">02 • Inodes, LVM, Prozesse, Boot-Prozess &amp; systemd</a></li>
<li>├─ <a href="01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">03 • Arch Linux, Omarchy, Remote-SSH &amp; Nginx</a></li>
<li>├─ <a href="01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">04 • Advanced Bash: Arrays, getopts &amp; Backups</a></li>
<li>└─ <a href="01_Linux_Bash/05_docker-und-sbx-micro-vms.md">05 • Docker Grundlagen &amp; Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP &amp; Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) &amp; Remote</a></li>
<li>├─ <a href="02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow &amp; Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Localhost-Proxy &amp; Port-Diagnose (8317)</a></li>
<li>└─ <a href="02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio &amp; API-Keys</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="03_Python_Coding/README.md">03_Python_Coding (Python, uv &amp; GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance &amp; Notebooks</a></li>
<li>├─ <a href="03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">02 • Google GenAI SDK (google-genai) &amp; Interactions API</a></li>
<li>└─ <a href="03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md">03 • Automatisierung, Datenanalyse &amp; pytest</a> <a class="doku-arch-badge" href="../labs/03_python/sensor_demo.py">sensor_demo.py</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">🌐 <a href="04_JS_TS_Web/README.md">04_JS_TS_Web (HTML/CSS, JS/TS &amp; Web-SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">01 • HTML5, CSS3 &amp; DOM-Manipulation Grundlagen</a> <a class="doku-arch-badge" href="../labs/04_js_ts_web/rechner.html">rechner.html</a></li>
<li>├─ <a href="04_JS_TS_Web/02_modernes-javascript-und-typescript.md">02 • Modernes JavaScript (ES6+) &amp; TypeScript</a></li>
<li>└─ <a href="04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">03 • Google GenAI SDK (@google/genai) für Web-Apps</a></li>
</ul>
</div>
<div class="doku-arch-card r5">
<div class="doku-arch-card-title">🤖 <a href="05_Agents/README.md">05_Agents (KI-Agenten, Skills &amp; Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">01 • Agent-Stilfibel, Didaktik-Ruler &amp; 7-Stufen-Aufbau</a></li>
<li>├─ <a href="05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">02 • Agenten erstellen: Instructions, Rules &amp; Prompts</a> <a class="doku-arch-badge" href="../.github/instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>├─ <a href="05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills (SKILL.md) &amp; MCP-Tools</a> <a class="doku-arch-badge" href="../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>└─ <a href="05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Agenten trainieren, primen &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../.github/agents/light.agent.md">@light</a> <a class="doku-arch-badge" href="../.github/agents/rig.agent.md">@rig</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
