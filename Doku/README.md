> **Thema:** Zentrales Handbuch & Inhaltsverzeichnis der Wissensdatenbank (`Doku/`) im Test- und Lern-Workspace `git-labor`
> **Autor:** Michael Stürmer
> **Datum:** 26.11.2026

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
<div class="doku-arch-row"><a href="./02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md" style="color:inherit;text-decoration:none;flex:1;" title="02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">• MCP-Server, Ollama (:11434) &amp; Ports (Archiv: Proxy)</a><a class="doku-arch-badge" href="../.vscode/mcp.json" title="Direktlink: .vscode/mcp.json">mcp.json</a></div>
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
* **[03_arch-linux-omarchy-und-remote-ssh.md](./01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md)** – Rolling-Release-Wartung mit `pacman`, systemd-Dienste (`systemctl`, `journalctl`), Omarchy (Hyprland inkl. `idle_inhibit`), SSH-Keys (`ed25519`), `~/.ssh/config`, VS Code Remote-SSH, Nginx sowie **Caddy (`:80`) & gehärtete Node.js-API (`gitlabor-api.service` / [`strikerpi-services/`](../labs/01_linux_bash/strikerpi-services/))**.
* **[04_fortgeschrittenes-bash-skripting-und-automatisierung.md](./01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md)** – Advanced Bash: Arithmetik (`$((...))` & `bc`), Kontrollstrukturen (`if [[ ... ]]`, Regex `=~`), Schleifen, Arrays (`declare -A`), Funktionen (`local`), `getopts`, API-Fetch mit `curl`/`jq`, Backup-Rotation (`tar.gz`), Verzeichnis-Monitor und Dialoge (`whiptail`).
* **[05_docker-und-sbx-micro-vms.md](./01_Linux_Bash/05_docker-und-sbx-micro-vms.md)** – Klassisches Docker vs. Docker Sandboxes CLI (`sbx`), isolierte Linux-Micro-VMs ohne Docker Desktop, Secret-Proxy und Read-Only-Mounts (`:ro`).

</details>

<details>
<summary><b>2. Rubrik: VS Code Environment, Git, MCP & LLM (<code>02_VSCode_Env/</code>)</b></summary>

* **[Übersicht der Rubrik 02](./02_VSCode_Env/README.md)**
* **[01_vscode-architektur-lsp-und-remote.md](./02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md)** – Projekt Monaco, Electron, Prozesstrennung (Renderer vs. Extension Host), Language Server Protocol (LSP) und Dev Containers.
* **[02_git-github-und-multi-root-workspaces.md](./02_VSCode_Env/02_git-github-und-multi-root-workspaces.md)** – Der 4-Stufen-Workflow in Git (`Strg+Shift+G`), `.git`-Interna, `.gitignore` gegen das 100-MB-Limit, `.code-workspace` vs. Codespaces.
* **[03_mcp-server-localhost-proxy-und-ports.md](./02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md)** – Konsolidierte MCP-Server (`4` global + `2` Workspace), Dual-Node **Ollama (`:11434`)**, legitimer Antigravity Hub (`agy.exe` `:8317`), StrikerPi Pitwall (`:8080`), NVIDIA App MCP (`13508`), `geminiDocs` &amp; Archiv der entfernten Proxy-Altlasten.
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
* **[02_modernes-javascript-und-typescript.md](./04_JS_TS_Web/02_modernes-javascript-und-typescript.md)** – Browser vs. Node.js, ES6+ Syntax, `async/await` mit `fetch`, statische Typsicherheit in TypeScript (`interface`, Union Types), `tsconfig.json` sowie das **StrikerPi Live-Lab ([`ts-linux-lab/`](../labs/04_js_ts_web/ts-linux-lab/))** mit Deployment via [`Deploy-ToStrikerPi.ps1`](../labs/04_js_ts_web/Deploy-ToStrikerPi.ps1).
* **[03_gemini-sdk-typescript-und-web-apps.md](./04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md)** – Das aktuelle `@google/genai` SDK in TypeScript/Node.js, JSON-Schemata (`Type.OBJECT`) und sichere Trennung von Frontend und Backend-API-Keys.

</details>

<details>
<summary><b>5. Rubrik: Agents – Erstellen, Ausrüsten, Trainieren & Orchestrieren (<code>05_Agents/</code>)</b></summary>

* **[Übersicht der Rubrik 05](./05_Agents/README.md)**
* **[01_agent-stilfibel-und-didaktik-ruler.md](./05_Agents/01_agent-stilfibel-und-didaktik-ruler.md)** – Die verbindlichen Regeln aus `Agent-guidline.md` und `agent_ruler.md`: Schreibstil, `<details>`-Einklapp-Pflicht, 7-Stufen-Aufbau und Chips.
* **[02_agenten-erstellen-instructions-rules-und-prompts.md](./05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md)** – Unterschied Prompt vs. Instruction vs. Rule vs. Custom Agent (`*.agent.md`), Speicherorte (`AGENTS.md`, `.github/instructions/`, `.github/agents/`) und `applyTo`.
* **[03_agenten-ausruesten-skills-und-mcp-tools.md](./05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md)** – Agenten gegen veraltetes Wissen ausrüsten (`Agent_setup.md` & `SKILL.md`): `geminiDocs` MCP, `llms.txt`, offizielle Gemini-Skills (`skills.sh` / Context7) und eigene `SKILL.md`-Pakete.
* **[04_agenten-trainieren-primen-und-orchestrieren.md](./05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md)** – Priming-Methodik, 3-Stufen-Memory (`/memories/`), Evaluierung (`analyze-prompt`) und die Architektur um den **General Agenten** auf `VanstrikeCyborg`.
* **[05_workspace-schnittstelle-simracer-und-agenten-terminals.md](./05_Agents/05_workspace-schnittstelle-simracer-und-agenten-terminals.md)** – Task-Queue (`inbox/` $\rightarrow$ `outbox/`), Freigabe-Gate (`@rig`/`@light` ↔ `@general`) inkl. Policy `AUTO`/`MANUAL` & MQTT-Anbindung, SSH-Launcher (`Agent-Terminals.ps1` / `-ClientMode`), `@rick` auf StrikerPi (`simrig.git`), [`AGENT_KOMMUNIKATION_HISTORIE.md`](../../assetto-corsa-content/ac-sandbox/shared/agents/general-SIM/logs/AGENT_KOMMUNIKATION_HISTORIE.md) und Bridge-Skripte.
* **[05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md](./05_Agents/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md)** – 5-Knoten-Topologie (Laptop, SimRacer, Sandbox, Archibald, StrikerPi), Multi-Root-Workspace, Port-Matrix, **7-Rollen-Verbund** (`@cyborg`, `@general-sim [LIVE auf StrikerPi]` + Legacy `@general`), Dual-GPU Ollama und Handshake mit Pre-Flight-Check.
* **[SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md](./05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md)** – Letztstand 26.11.2026 (Cyborg Ollama `0.40.18`-Reparatur, Pro-GPU-Kontextprofile für RTX 5070 Ti &amp; 5060, Fallback-Routing `ollama_router.py`, zentrale **KI-Schaltweiche**, Pitwall-Tab `🧠 GPU-Modelle`, 7-Rollen-Registry **LIVE auf StrikerPi** &amp; Archibald-Lüfter-Entwurf).
* **[Rollen-, Terminal- und Pitwall-Umsetzung](../../assetto-corsa-content/docs/03_agenten_system/rollen-terminals-pitwall-umsetzung.md)** – Kanonische Rollen-IDs (`agent_registry.json`), General-Cyborg/General-Sim-Trennung (**LIVE** auf StrikerPi) und Legacy-Übergang.
* **[PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md](./05_Agents/PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md)** – Komplette Pitwall- (`v2.2.0`) &amp; Architektur-v5-Referenz (inkl. GPU-Modelle, KI-Schaltweiche &amp; REST/WS-API) für NotebookLM.
* **[SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md](./05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md)** – Stand 25.11.2026 (Architektur v5, Werkzeugkoffer, `light_verifier.py` QA, Pitwall v2.1 &amp; 64K-Ollama-Umstellung).
* **[SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md](./05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md)** – Stand 24.11.2026 (`C: -> D:`-Archivierung, 76-Ext-Parity, `qwen3.5:9b`/`4b`, RTX-5070-Ti-Lastbeweis, Workspace-Agenten-Filter, XOR-Mutex, Parallel-Limits &amp; **9-Fälle-Nacharbeiten-Register**).
* **[SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md](./05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md)** – ToS-Bereinigung (`:8317`-Proxy-Rückbau), 2-Knoten-Ollama-GPU-Setup, Change-Freeze, Pitwall `v1.5.0` &amp; Testfahrt-Auswertung (`testdrive_20261123_070115`).
* **[SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md](./05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md)** – Änderungsprotokoll (MQTT, Gatekeeper, Relay-Logik, Caddy `:80` + `gitlabor-api.service` `:8085` + TS-Labs & Pitwall-Display) mit verifiziertem Ist-Stand.
* **Direktlinks (Agent-Dateien, Skills & Regeln):**
  * **Custom Agents:** [`General Cyborg` (Global)](../../.copilot/agents/general.agent.md) · [`General Sim` (AC-Legacy)](../../assetto-corsa-content/.github/agents/general.agent.md) · [`general_sim_terminal.py` (Pi `LIVE`)](../../strikerpi-hub/general-sim/general_sim_terminal.py) · [`rig.agent.md`](../.github/agents/rig.agent.md) · [`light.agent.md`](../.github/agents/light.agent.md) · [`dark.agent.md`](../.github/agents/dark.agent.md) · [`sarah.agent.md`](../.github/agents/sarah.agent.md) · [`rick.agent.md`](../.github/agents/rick.agent.md)
  * **Launcher & StrikerPi:** [`Agent-Terminals.ps1`](../labs/Agent-Terminals.ps1) · [`agent_registry.json`](../../strikerpi-hub/telemetry-relay/agent_registry.json) · [`strikerpi-hub/README.md`](../../strikerpi-hub/README.md)
  * **Regeln & Instructions:** [`AGENTS.md`](../AGENTS.md) · [`gemini-api.instructions.md`](../.github/instructions/gemini-api.instructions.md) · [`vscode-experte.instructions.md`](../../.copilot/instructions/vscode-experte.instructions.md)
  * **Skills (`SKILL.md`):** [`live-transfer-status-monitor` (Workspace)](../.agents/skills/live-transfer-status-monitor/SKILL.md) · [`live-transfer-status-monitor` (Gemini)](../.gemini/skills/live-transfer-status-monitor/SKILL.md) · [`managing-python-dependencies`](../../.copilot/skills/managing-python-dependencies/SKILL.md)
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
details.doku-minimap .minimap-body { padding: 4px 12px 6px 12px; }
</style>
<details class="doku-minimap">
<summary><span>🗺️ Doku-Minimap (5 Rubriken &amp; Labs)</span><span class="minimap-toggle" title="Klicken zum Vergrößern / Einklappen"></span></summary>
<div class="minimap-preview-strip"><span><i class="dot r1"></i>Linux</span><span><i class="dot r2"></i>VSCode</span><span><i class="dot r3"></i>Python</span><span><i class="dot r4"></i>JS/TS</span><span><i class="dot r5"></i>Agents</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root"><span>🏛️ <a href="README.md">VanstrikeCyborg — git-labor Doku-Index</a></span> · <a href="../README.md">Repo-README</a> · <a href="../AGENTS.md">AGENTS.md</a> · <a href="../notebook-agent-environments/README.md">Notebooks</a> · <a href="05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md">Letztstand 26.11.</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🐧 <a href="01_Linux_Bash/README.md">01_Linux_Bash (Linux, Shell & Container)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 • Bash CLI, Text-Tools, Streams & Expansions</a> <a class="doku-arch-badge" href="../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="01_Linux_Bash/02_linux-systemadministration-und-interna.md">02 • Inodes, LVM, Prozesse, Boot-Prozess & systemd</a></li>
<li>├─ <a href="01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">03 • Arch Linux, Omarchy, Remote-SSH & Nginx</a></li>
<li>├─ <a href="01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">04 • Advanced Bash: Arrays, getopts & Backups</a></li>
<li>└─ <a href="01_Linux_Bash/05_docker-und-sbx-micro-vms.md">05 • Docker Grundlagen & Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP & Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) & Remote</a></li>
<li>├─ <a href="02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow & Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Ollama (:11434) & Ports (Archiv: Proxy)</a> <a class="doku-arch-badge" href="../.vscode/mcp.json">mcp.json</a></li>
<li>├─ <a href="02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio & API-Keys</a></li>
<li>└─ <a href="02_VSCode_Env/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">05 • 5-Knoten-Verbund, Parity & Parallel-Limits</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="03_Python_Coding/README.md">03_Python_Coding (Python, uv & GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance & Notebooks</a> <a class="doku-arch-badge" href="../notebook-agent-environments/agent_demo.ipynb">.ipynb</a></li>
<li>├─ <a href="03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">02 • Google GenAI SDK (google-genai) & Interactions API</a></li>
<li>└─ <a href="03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md">03 • Automatisierung, Datenanalyse & pytest</a> <a class="doku-arch-badge" href="../labs/03_python/sensor_demo.py">sensor_demo.py</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">🌐 <a href="04_JS_TS_Web/README.md">04_JS_TS_Web (HTML/CSS, JS/TS & Web-SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">01 • HTML5, CSS3 & DOM-Manipulation Grundlagen</a> <a class="doku-arch-badge" href="../labs/04_js_ts_web/rechner.html">rechner.html</a></li>
<li>├─ <a href="04_JS_TS_Web/02_modernes-javascript-und-typescript.md">02 • Modernes JavaScript (ES6+) & TypeScript</a></li>
<li>└─ <a href="04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">03 • Google GenAI SDK (@google/genai) für Web-Apps</a></li>
</ul>
</div>
<div class="doku-arch-card r5">
<div class="doku-arch-card-title">🤖 <a href="05_Agents/README.md">05_Agents (KI-Agenten, Skills & Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">01 • Agent-Stilfibel, Didaktik-Ruler & 7-Stufen-Aufbau</a></li>
<li>├─ <a href="05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">02 • Agenten erstellen: Instructions, Rules & Prompts</a> <a class="doku-arch-badge" href="../.github/instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>├─ <a href="05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills & MCP-Tools</a> <a class="doku-arch-badge" href="../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>├─ <a href="05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Priming, Memory & Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../.github/agents/light.agent.md">@light</a></li>
<li>├─ <a href="05_Agents/05_workspace-schnittstelle-simracer-und-agenten-terminals.md">05 • Schnittstelle, Terminals & XOR-Mutex</a> <a class="doku-arch-badge" href="../labs/03_python/sim_agent_bridge.py">Bridge</a></li>
<li>├─ <a href="05_Agents/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">06 • Multi-Workspace Netzwerk & 7-Rollen-Verbund</a></li>
<li>├─ <a href="05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md">Letztstand 26.11. (Dual-GPU Ollama &amp; Pitwall GPU-Modelle)</a></li>
<li>├─ <a href="05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md">Stand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)</a></li>
<li>├─ <a href="05_Agents/HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md">Praxis-Referenz 25.11. (Hisense 4K-TV & ClearType)</a></li>
<li>├─ <a href="05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md">Stand 24.11. (Parity, Qwen 3.5 & Nacharbeiten)</a></li>
<li>├─ <a href="05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md">Stand 23.11. (ToS-Bereinigung, Ollama & Pitwall v1.5)</a></li>
<li>├─ <a href="05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md">Änderungsprotokoll 11.11. (MQTT, Gatekeeper & Caddy)</a></li>
<li>├─ <a href="05_Agents/PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md">Pitwall & Systemreferenz (NotebookLM-Quelle)</a></li>
<li>└─ <a href="05_Agents/PITWALL_BOXENCREW_TEAMCHEF_KONZEPT_NOTEBOOKLM.md">Boxencrew & Teamchef Konzept (NotebookLM)</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
