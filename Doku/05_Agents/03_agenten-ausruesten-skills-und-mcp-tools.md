> **Thema:** KI-Agenten ausrüsten – Skills (`SKILL.md`), Gemini Developer Resources (`Agent_setup.md`), MCP-Server & `llms.txt`
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

<details>
<summary><b>Lernziele</b></summary>

* Verstehen, wie man KI-Agenten gegen veraltetes Trainingswissen schützt, indem man sie über **`Agent_setup.md`** mit Live-Dokumentation (**`geminiDocs` MCP**, **`llms.txt`**) und **Skills** ausrüstet.
* Offizielle Gemini-Skills (`gemini-api-dev`, `gemini-live-api-dev`, `gemini-omni-flash-api`) über **`skills.sh`**, **Context7** oder das **Antigravity Gemini API Plugin** installieren.
* Eigene modulare **Agent-Skills (`SKILL.md`)** mit Unterdokumentation (`references/`) und Hilfsskripten (`scripts/`) fehlerfrei aufbauen.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Warum Agenten ausgerüstet werden müssen (Das Knowledge-Cutoff-Problem)</summary>

Sprachmodelle besitzen ein festes Trainingsdatum (*Knowledge Cutoff*). Ohne zusätzliche Ausrüstung schlagen sie oft veraltete Modelle (`gemini-1.5`), abgekündigte SDKs (`google-generativeai`) oder veraltete API-Muster vor.

Über **vier offizielle Kanäle** (aus `Agent_setup.md`) rüsten wir unsere Agenten im `git-labor` mit aktuellem Live-Wissen aus:

| Ressource | Was sie dem Agenten gibt | Wie im `git-labor` eingebunden? |
| :--- | :--- | :--- |
| **1. Gemini Docs MCP Server** (`geminiDocs`) | Live-Suche (`gemini_search_docs`) und Volltext-Abruf (`gemini_get_doc`) über die gesamte Gemini-Dokumentation. | Bereits aktiv in `git-labor.code-workspace`, `.vscode/mcp.json` und `.mcp.json` (`https://gemini-api-docs-mcp.dev`). |
| **2. Machine-Readable Docs (`llms.txt`)** | Saubere Markdown-Seiten (`.md`-Endung oder `Accept: text/markdown`) ohne HTML-Ballast. | Index: `https://aistudio.google.com/docs/llms.txt`<br/>Volltext: `https://aistudio.google.com/docs/llms-full.txt` |
| **3. Offizielle Gemini Agent Skills** | Schritt-für-Schritt-Regeln, aktuelle Modellnamen und Hilfsskripte, die der Agent nur bei Bedarf lädt. | `gemini-api-dev`, `gemini-live-api-dev`, `gemini-omni-flash-api` (via `npx skills`, Context7 oder Antigravity Plugin). |
| **4. Antigravity `learning-docs` Skill** | Sitemap & Schnellreferenz für Antigravity CLI (`agy`), IDE, Antigravity 2.0 und Python SDK. | Als Skill-Vorlage (`SKILL.md`) mit Hybrid-Retrieval auf `https://antigravity.google/docs` verfügbar. |

</details>

<details>
<summary>1.2 Offizielle Gemini-Skills installieren (CLI & Antigravity)</summary>

Sobald Node.js (`npx`) im Terminal verfügbar ist oder du in Antigravity (`agy`) arbeitest, kannst du die offiziellen Google-Skills global oder im Projekt installieren:

```bash
# 1. Alle verfügbaren Skills im offiziellen Google-Repository auflisten
npx skills add google-gemini/gemini-skills --list

# 2. Die 3 Kern-Skills global installieren (über skills.sh)
npx skills add google-gemini/gemini-skills --skill gemini-api-dev --global
npx skills add google-gemini/gemini-skills --skill gemini-live-api-dev --global
npx skills add google-gemini/gemini-skills --skill gemini-omni-flash-api --global

# Alternativ über Context7 installieren:
npx ctx7 skills install /google-gemini/gemini-skills gemini-api-dev

# Alternativ in Google Antigravity (bündelt MCP + alle 3 Skills + API-Key-Tools):
agy plugin install https://github.com/google-gemini/gemini-skills
```

### Überblick über die 3 offiziellen Gemini-Skills:
* **`gemini-api-dev`:** Interactions API (`client.interactions.create`), `google-genai` (Python) & `@google/genai` (TS), Streaming, Structured Outputs, Function Calling, Deep Research & Migration von Legacy-Code.
* **`gemini-live-api-dev`:** Echtzeit-Audio/Video-Streaming über WebSockets, Ephemeral Client Tokens, Voice Activity Detection (VAD) und Barge-In.
* **`gemini-omni-flash-api`:** Video-Generierung und -Bearbeitung mit Gemini Omni Flash inkl. fertiger Python-Hilfsskripte (`upload_file.py`, `generate_video.py`, `prep_video.py`, `inspect_video.py`).

</details>

<details>
<summary>1.3 Aufbau eines eigenen Agent-Skills (<code>SKILL.md</code>)</summary>

Ein Skill ist ein eigener Ordner unter `.agents/skills/<skill-name>/` (für den Workspace) oder `C:\Users\strik\.copilot\skills\<skill-name>\` (benutzerweit).

```text
.agents/skills/mein-spezial-skill/
├── SKILL.md              # Pflicht: YAML-Header (name, description) + Ablaufregeln
├── references/           # Optional: Detail-Dokumentation (wird nur bei Bedarf gelesen)
│   └── api-details.md
└── scripts/              # Optional: Ausführbare PowerShell-, Bash- oder Python-Skripte
    └── check-status.ps1
```

**Wichtigste Regel für `SKILL.md`:**
Der `name` im YAML-Frontmatter muss exakt mit dem Ordnernamen übereinstimmen, und die `description` entscheidet darüber, **wann** der Agent diesen Skill automatisch aktiviert:

```markdown
---
name: mein-spezial-skill
description: Prüft und formatiert technische Messdaten aus CSV- und JSON-Dateien. Verwenden, wenn der Nutzer Sensordaten, Messreihen oder CSV-Importe analysieren oder bereinigen möchte.
---

# Messdaten-Analyse Skill

## 1. Wann dieser Skill genutzt wird
Aktivieren, sobald Messreihen oder CSV-Dateien im Projekt verarbeitet werden sollen.

## 2. Verbindlicher Ablauf
1. Prüfe zuerst das Dateiformat und die Spaltenköpfe.
2. Lies bei komplexen Einheiten die Referenz unter `references/api-details.md`.
3. Führe nach der Bereinigung das Prüfskript `scripts/check-status.ps1` aus.
```

</details>

<details>
<summary>1.4 Statusprüfung & Verifikation der Ausrüstung</summary>

Um zu testen, ob dein Agent korrekt mit dem `geminiDocs` MCP-Server und den Gemini-Regeln ausgerüstet ist, stelle ihm im Chat folgende Testaufgabe:

> *„Schlage das Request-Schema für die Gemini Interactions API in der offiziellen Dokumentation nach und zeige ein minimales Python-Beispiel.“*

**Erwartetes Verhalten eines korrekt ausgerüsteten Agenten:**
1. Er ruft `gemini_search_docs` / `gemini_get_doc` auf dem `geminiDocs` MCP-Server (oder `llms.txt`) auf.
2. Er schreibt Code mit `from google import genai` und `client.interactions.create(...)`.

| Umgebung | MCP-Server prüfen | Geladene Skills prüfen |
| :--- | :--- | :--- |
| **VS Code (Copilot)** | `Strg+Shift+P` $\rightarrow$ `MCP: List Servers` | Im Chat auf **Select Tools / Configure Tools** klicken |
| **Antigravity** | *Customizations $\rightarrow$ Connections* | *Customizations $\rightarrow$ Rules* oder `/skills list` |
| **Claude Code / Codex** | `/mcp` bzw. `codex mcp list` | `/skills` bzw. `~/.codex/skills/` |

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **On-Demand-Vorteil:** Warum laden moderne Agenten die detaillierten Anweisungen eines Skills (`SKILL.md`) erst dann in den Arbeitsspeicher, wenn deine Frage zur `description` des Skills passt?
2. **Skill-Ordnerregel:** Du legst den Ordner `.agents/skills/code-erklaeren/` an. Wie muss die Datei darin heißen und welchen Wert muss das Feld `name:` im YAML-Header zwingend haben?
3. **Markdown-Abruf ohne HTML:** Wie kannst du von jeder Dokumentationsseite unter `https://aistudio.google.com/docs/...` direkt den reinen Markdown-Quelltext für einen Agenten abrufen (nenne zwei Methoden aus `Agent_setup.md`)?

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [Gemini API Coding Agents & MCP Setup Guide](https://aistudio.google.com/docs/coding-agents)
* [Offizielles `google-gemini/gemini-skills` Repository auf GitHub](https://github.com/google-gemini/gemini-skills)
* [Gemini API Dokumentation als `llms.txt` Index](https://aistudio.google.com/docs/llms.txt)
* [VS Code Agent Skills Dokumentation](https://code.visualstudio.com/docs/copilot/customization/agent-skills)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **Live-Doku schlägt Trainingsdaten:** Der `geminiDocs` MCP-Server (`https://gemini-api-docs-mcp.dev`) und `llms.txt` verhindern veralteten Gemini-Code.
* **Skills = Modulare Werkzeugkoffer:** Ein Skill kapselt Regeln (`SKILL.md`), Unterdokumente (`references/`) und Skripte (`scripts/`) und wird nur bei Bedarf geladen.
* **Die `description` im YAML-Kopf ist der Auslöser:** Formuliere im Feld `description:` glasklar, bei welchen Stichworten und Aufgaben der Agent den Skill ziehen muss.
* **Direkte `.md`-URLs sparen Token:** Jede Seite auf `aistudio.google.com/docs/...` liefert durch Anhängen von `.md` oder den Header `Accept: text/markdown` schlankes Markdown statt großem HTML.

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
<li>└─ <a href="04_agenten-trainieren-primen-und-orchestrieren.md">04 • Agenten trainieren, primen &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../../.github/agents/light.agent.md">@light</a> <a class="doku-arch-badge" href="../../.github/agents/rig.agent.md">@rig</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
