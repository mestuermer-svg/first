> **Thema:** Gemini Ökosystem, Google AI Studio, API-Keys & Hardware-Stabilität (MSI Cyborg 15)
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

<details>
<summary><b>Lernziele</b></summary>

* Den fundamentalen Unterschied zwischen dem **Endanwender-Abo (Google AI Pro)** und der **Entwickler-Plattform (Google AI Studio & Gemini API)** verstehen.
* Den Sicherheitswechsel von klassischen **Standard API Keys** zu dienstkontogebundenen **Authorization (Auth) Keys** sowie deren sichere Einbindung über Umgebungsvariablen (`GEMINI_API_KEY`) beherrschen.
* Die **Hardware-Ressourcen des MSI Cyborg 15** (16 GB DDR5, Core 7 240H, RTX 5060) optimal für VS Code, KI-Agenten und lokale Tools einteilen.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Zwei getrennte Welten: Google AI Pro Abo vs. Gemini API</summary>

```mermaid
flowchart LR
    subgraph Consumer ["Endanwender-Welt (gemini.google.com)"]
        PRO["<b>Google AI Pro / Google One Abo</b><br/>• Feste Monatsgebühr<br/>• Web-Chat & Workspace-Integration<br/>• Dynamische Compute Caps (5h-Fenster)<br/>• KEIN API-Guthaben für eigenen Code"]
    end

    subgraph Developer ["Entwickler-Welt (aistudio.google.com)"]
        API["<b>Google AI Studio & Gemini API</b><br/>• Free Tier oder Pay-as-you-go (Cloud Billing)<br/>• System Instructions & JSON-Schema-Modus<br/>• API-Keys für Python, TypeScript & Agenten"]
    end
```

* **Compute Caps im AI Pro Abo:** Im Web-Chat steuert Google das Kontingent über rollierende Zeitfenster:
  * **Gemini Pro:** Hohes Prioritätskontingent für komplexes Coding und große Kontexte (automatischer Fallback auf Flash ohne harten Abbruch).
  * **Gemini Flash:** Nahezu unbegrenzter Schnellkanal für Routineaufgaben.
  * **Deep Think / Deep Research:** Tägliches Spezialbudget für tiefe Logik- und Rechercheläufe.
* **Google AI Studio (`aistudio.google.com`):** Der Entwickler-Playground zum Testen von System-Prompts, Temperatur (`0.0` für deterministischen Code/JSON), Structured Outputs und direktem Code-Export (*Get Code*).

</details>

<details>
<summary>1.2 API-Key-Architektur: Standard Keys vs. Authorization Keys</summary>

Ab Mai 2026 stellt die Gemini API aus Sicherheitsgründen von unbeschränkten Standard-Keys auf **Authorization (Auth) Keys** um:

| Eigenschaft | Standard API Key | Authorization (Auth) Key (Aktueller Standard) |
| :--- | :--- | :--- |
| **Identität & Bindung** | Nur mit einem Google Cloud Projekt für Billing/Quota verknüpft. | Direkt an ein **Google Cloud Service Account** gebunden (feingranulare IAM-Rechte). |
| **API-Einschränkung** | Unbeschränkte Standard-Keys werden von der Gemini API abgelehnt! | Standardmäßig strikt auf die *Generative Language API* beschränkt + automatischer Schutz bei geleakten Keys. |
| **Abrechnungsprüfung** | Ein erfolgreicher Modell-Abruf (`/v1/models`) prüft nur die Leseberechtigung – für echte Text-/Codegenerierung muss im verknüpften AI-Studio-Projekt Kontingent (Free Tier oder aktives Cloud Billing, sonst HTTP `402`) verfügbar sein. |

</details>

<details>
<summary>1.3 Sichere Konfiguration von <code>GEMINI_API_KEY</code></summary>

API-Schlüssel dürfen **niemals** im Klartext in Markdown-Dokumente oder Git-Commits geschrieben werden. Das offizielle `google-genai` SDK erkennt automatisch die Umgebungsvariablen `GEMINI_API_KEY` oder `GOOGLE_API_KEY`:

* **Unter Windows (PowerShell – dauerhaft für deinen Benutzer setzen):**
  ```powershell
  [Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "DEIN_ECHTER_API_KEY", "User")
  ```
* **Unter Linux / macOS (in `~/.bashrc` oder `~/.zshrc`):**
  ```bash
  export GEMINI_API_KEY="DEIN_ECHTER_API_KEY"
  source ~/.bashrc
  ```

</details>

<details>
<summary>1.4 Hardware-Analyse & RAM-Management auf dem MSI Cyborg 15 (<code>VanstrikeCyborg</code>)</summary>

| Komponente | Spezifikation (`VanstrikeCyborg`) | Bewertung für KI- & Dev-Workflows |
| :--- | :--- | :--- |
| **CPU** | Intel Core 7 240H (10 Kerne / 16 Threads, bis 5.20 GHz) | **Sehr hohe Reserve:** Ideal für parallele Sprachserver, Compiler und Hintergrund-Proxys. |
| **GPU** | NVIDIA GeForce RTX 5060 Laptop (8 GB GDDR7 VRAM) | **Exzellent:** Schneller GDDR7-Speicher für lokale Beschleunigung und CUDA-Experimente. |
| **SSD** | 1 TB NVMe SSD (Sandisk SN5000S) | **Sehr schnell:** Darauf achten, dass stets **> 100 GB frei** bleiben (keine verwaisten VM-Images lagern). |
| **RAM** | **16 GB DDR5-5600 Dual-Channel** | **Kritischer Pfad (Haupt-Engpass bei schweren VMs):** Windows 11 (~5.5 GB) + VS Code & Language Server (~2.5 GB) lassen ~8 GB frei. |

**Best Practices für maximale Stabilität auf dem Laptop:**
1. **Kein schweres Dauer-Docker-Desktop im Hintergrund**, wenn es nicht aktiv für ein Container-Projekt gebraucht wird (spart 2.5–4 GB RAM durch Wegfall von `vmmemWSL`).
2. **Nutzung von `sbx` oder nativen Binaries** (`github-mcp-server.exe`) für Agenten-Tools.
3. **Ausblick Hardware-Upgrade:** Durch Tausch der 2× 8 GB SO-DIMMs auf **32 GB DDR5-5600 (2× 16 GB)** verschwindet auch bei parallelen lokalen Containern jedes Pagefile-Swapping.

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Fehlercode HTTP 402:** Dein Skript kann erfolgreich alle 50 Gemini-Modelle auflisten, bricht aber beim ersten Generierungs-Request mit `HTTP 402` ab. Woran liegt das und wo prüfst du den Status?
2. **Key-Sicherheit:** Warum funktioniert `export GEMINI_API_KEY="..."` aus einer Linux-Anleitung nicht dauerhaft für ein Windows-PowerShell-Terminal in VS Code, und wie trägst du die Variable unter Windows richtig ein?
3. **RAM-Budget:** Berechne den RAM-Bedarf auf deinem 16-GB-Laptop, wenn Windows 11 (5.5 GB), VS Code mit Pylance (2.5 GB), Browser (2 GB) und zusätzlich eine 6-GB-VM zusammen mit WSL2 (3 GB) laufen würden. Was passiert technisch ab 16 GB?

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [Google AI Studio – API Keys verwalten](https://aistudio.google.com/apikey)
* [Gemini API Dokumentation: API Keys & Auth Keys](https://aistudio.google.com/docs/api-keys)
* [Gemini API Rate Limits & Billing Tiers](https://aistudio.google.com/docs/rate-limits)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **AI Pro Abo $\neq$ API-Billing:** Das Web-Abo gilt für `gemini.google.com`; eigener Code in VS Code nutzt API-Keys aus dem Google AI Studio (`aistudio.google.com`).
* **Auth Keys sind der neue Sicherheitsstandard:** Neue Gemini-Keys sind an Service Accounts gebunden und auf die Generative Language API beschränkt.
* **Umgebungsvariable statt Hardcoding:** Das SDK liest `GEMINI_API_KEY` automatisch aus der Systemumgebung – Keys gehören niemals in Git!
* **16 GB RAM smart einteilen:** Durch den Verzicht auf unnötige Dauer-VMs auf dem `VanstrikeCyborg` läuft VS Code inklusive Pylance, MCP-Servern und Antigravity absolut verzögerungsfrei.

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
<li>├─ <a href="../01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 • Bash-Grundlagen, Skripting, Pipes &amp; Exit-Codes</a> <a class="doku-arch-badge" href="../../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="../01_Linux_Bash/02_arch-linux-omarchy-und-remote-ssh.md">02 • Arch Linux, Omarchy, systemd &amp; Remote-SSH</a></li>
<li>└─ <a href="../01_Linux_Bash/03_docker-und-sbx-micro-vms.md">03 • Docker Grundlagen &amp; Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="README.md">02_VSCode_Env (IDE, Git, MCP &amp; Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) &amp; Remote</a></li>
<li>├─ <a href="02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow &amp; Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Localhost-Proxy &amp; Port-Diagnose (8317)</a></li>
<li>└─ <a href="04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio &amp; API-Keys</a></li>
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
<div class="doku-arch-card-title">🤖 <a href="../05_Agents/README.md">05_Agents (KI-Agenten, Skills &amp; Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">01 • Agent-Stilfibel, Didaktik-Ruler &amp; 7-Stufen-Aufbau</a></li>
<li>├─ <a href="../05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">02 • Agenten erstellen: Instructions, Rules &amp; Prompts</a> <a class="doku-arch-badge" href="../../.github/instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>├─ <a href="../05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills (SKILL.md) &amp; MCP-Tools</a> <a class="doku-arch-badge" href="../../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>└─ <a href="../05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Agenten trainieren, primen &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../../.github/agents/light.agent.md">@light</a> <a class="doku-arch-badge" href="../../.github/agents/rig.agent.md">@rig</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
