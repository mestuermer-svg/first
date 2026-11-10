> **Thema:** KI-Agenten erstellen – Prompts, Instructions (`*.instructions.md`), Rules (`AGENTS.md`) & Custom Agents (`*.agent.md`)
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

<details>
<summary><b>Lernziele</b></summary>

* Die vier Anpassungsebenen (**Chat-Prompt**, **Instruction/Rule**, **Skill** und **Custom Agent**) klar voneinander abgrenzen.
* Das Konzept des **Model Harness** (GitHub Copilot, Claude Code, Codex) und das Zusammenspiel mit dem **Language Server Protocol (LSP)** verstehen.
* Die dynamische Auswahl von **Sprachmodellen, Reasoning-Stufen (Thinking)** und lokalen Modellen (für 100 % Datensouveränität) steuern.
* Wissen, in welchen **Ordnern und Dateiformaten** (`AGENTS.md`, `GEMINI.md`, `.github/instructions/*.instructions.md`, `.github/agents/*.agent.md`) Regeln abgelegt werden müssen, damit VS Code Copilot und Google Antigravity sie automatisch erkennen.
* Einen eigenen **Custom Agent (`*.agent.md`)** und eine dateispezifische **Instruction (`applyTo`)** mit sauberem YAML-Frontmatter erstellen.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Die 4 Bausteine der Agenten-Steuerung im Vergleich</summary>

| Baustein | Wann wird er geladen? | Typischer Zweck | Beispiel |
| :--- | :--- | :--- | :--- |
| **1. Chat-Prompt** | Einmalig bei deiner aktuellen Nachricht im Chat. | Konkreter Einzelauftrag mit Ziel, Grenze und Prüfkriterium. | *„Erkläre die Funktion `berechne_summe`, ändere noch keine Datei.“* |
| **2. Instruction / Rule** | Automatisch (global oder passend zum Dateimuster `applyTo` / `globs`). | Dauerhafte Projekt- und Coding-Standards (Sprache, SDK-Pflicht, Vorschau-Pflicht). | `.github/instructions/gemini-api.instructions.md` (`applyTo: "**/*.py"`) |
| **3. Skill (`SKILL.md`)** | Bei Bedarf (*On-Demand*), wenn die Aufgabe zur `description` passt. | Mehrstufiges Spezialwissen inkl. Hilfsskripten und Vorlagen. | `.agents/skills/live-transfer-status-monitor/SKILL.md` |
| **4. Custom Agent (`*.agent.md`)** | Wenn du den Agenten gezielt auswählst oder mit `@name` aufrufst. | Eigene Rolle/Persönlichkeit mit festem Aufgabenbereich und Werkzeugkasten. | `General Cyborg` (global, `VanstrikeCyborg`) & `General Sim` (SimRacer-Leitstand) |

</details>

<details>
<summary>1.2 Alle wichtigen Speicherorte für VS Code Copilot & Google Antigravity</summary>

Ein häufiger Fehler besteht darin, eine Regeldatei im falschen Ordner abzulegen, sodass der Agent sie ignoriert. Diese Tabelle zeigt die exakten Pfade in deinem Workspace:

| Zielplattform | Art der Anpassung | Exakter Pfad im Projekt / auf dem PC |
| :--- | :--- | :--- |
| **Copilot & Antigravity gemeinsam** | Projektweite Basisregeln | **`AGENTS.md`** im Repository-Hauptordner (`C:\Users\strik\git-labor\AGENTS.md`) |
| **VS Code (Global für alle Projekte)** | Globale Benutzer-Instructions | **`C:\Users\strik\.copilot\instructions\*.instructions.md`** oder `%APPDATA%\Code\User\prompts\` |
| **VS Code Copilot (Projekt)** | Dateispezifische Instructions | **`.github/instructions/<name>.instructions.md`** (mit `applyTo`-Muster) |
| **VS Code Copilot (Projekt)** |Eigene Custom Agents (`@name`) | **`.github/agents/<name>.agent.md`** |
| **Google Antigravity** | Antigravity-spezifische Regeln | **`GEMINI.md`** oder **`.agents/rules/<name>.md`** (mit `trigger: glob`) |
| **Beide Plattformen** | Projekt-Skills | **`.agents/skills/<skill-name>/SKILL.md`** bzw. **`C:\Users\strik\.copilot\skills\`** |

</details>

<details>
<summary>1.3 Bauplan 1: Dateispezifische Instruction (<code>.github/instructions/*.instructions.md</code>)</summary>

Mit dem YAML-Attribut `applyTo` sorgst du dafür, dass eine Regel nur dann Token im Kontextfenster verbraucht, wenn der Agent tatsächlich an passenden Dateien arbeitet (wie unsere aktive Datei `.github/instructions/gemini-api.instructions.md`):

```markdown
---
name: "Gemini API & SDK Guidelines"
description: "Regeln für die Entwicklung mit der Google Gemini API, dem aktuellen google-genai / @google/genai SDK, der Interactions API und dem geminiDocs MCP-Server."
applyTo: "**/*.{py,ts,js,mjs,ipynb}"
---

# Gemini API Guidelines

- **Dokumentation vorab prüfen:** Nutze vor dem Schreiben von Gemini-API-Code den `geminiDocs` MCP-Server (`gemini_search_docs` / `gemini_get_doc`) oder `https://aistudio.google.com/docs/llms.txt`.
- **Aktuelles SDK verwenden:** Verwende immer `google-genai` (Python) bzw. `@google/genai` (TypeScript/JS). Verwende niemals `google-generativeai` oder `@google/generative-ai`.
- **Interactions API bevorzugen:** Nutze standardmäßig `client.interactions.create` für neue Anwendungen.
```

Für **Antigravity-Regeln** unter `.agents/rules/webcode.md` lautet der YAML-Header analog:
```markdown
---
trigger: glob
globs: "**/*.html, **/*.ts, **/*.js"
description: "Qualitätsregeln für HTML-, TypeScript- und JavaScript-Dateien."
---
```

</details>

<details>
<summary>1.4 Bauplan 2: Eigenen Custom Agent erstellen (<code>.github/agents/*.agent.md</code>)</summary>

Ein **Custom Agent** definiert eine klar abgegrenzte Expertenrolle. Er besitzt eine `description` (damit Haupt-Agenten wissen, wann sie ihn als Subagenten aufrufen sollen) und präzise Verhaltensregeln:

```markdown
---
description: Python- & Notebook-Spezialist im git-labor für typsichere Skripte, uv-Umgebungen, pytest und das google-genai SDK.
argument-hint: Eine Aufgabe zu Python-Skripten, Jupyter Notebooks oder Gemini-API-Code.
---

# Python-Labor-Agent (@pylab)

Du bist der spezialisierte **Python- & Notebook-Experte** im Workspace `git-labor`.

## Deine Kernregeln
1. **Umgebung:** Nutze immer die lokale `.venv` bzw. `uv run` – führe niemals globales `pip install` aus.
2. **Typsicherheit:** Schreibe vollständige Python Type Hints (`list[str]`, `float | None`) und prüfe Dateien nach jeder Änderung auf Pylance-Fehler.
3. **Gemini SDK:** Verwende ausschließlich `from google import genai` und `client.interactions.create`.
4. **Verifikation:** Sichere neue Logik mit einem `pytest`-Testfall ab.
```

</details>

<details>
<summary>1.5 Model Harnesses, LSP & dynamische Reasoning-Stufen (Thinking)</summary>

In modernen Entwicklungsumgebungen agiert der Editor nicht mehr als starrer Chatbot, sondern als modularer **Model Harness**:

```
┌────────────────────────────────────────────────────────┐
│  VS Code Multi-Prozess UI (Renderer)                   │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│  Agent Harness (GitHub Copilot, Claude Code, Codex)     │
├───────────────────────────┬────────────────────────────┤
│ • Prompt-Assembly         │ • Kontext-Fenster-Budget   │
│ • Tool-Orchestrierung     │ • Model-Sampling & Fallback│
└─────────────┬─────────────┴─────────────┬──────────────┘
              │                           │
┌─────────────▼─────────────┐ ┌───────────▼──────────────┐
│ Language Server (LSP)     │ │ MCP Tools & Endpoints    │
│ (Pylance, TypeScript LSP) │ │ (geminiDocs, Terminal)   │
└───────────────────────────┘ └──────────────────────────┘
```

* **Was ist ein Model Harness?**
  Der *Harness* ist das Software-Gerüst, das das rohe Sprachmodell einspannt. Er übernimmt das Zusammenstellen von Prompts (System-Prompt + Instructions + geöffnete Dateien), prüft Token-Grenzen, ruft Werkzeuge auf (Tool Calling via MCP) und verarbeitet die Antworten des Modells.
* **Entkopplung durch das Language Server Protocol (LSP):**
  Sprachspezifische Intelligenz (Pylance für Python, tsserver für TypeScript) läuft in separaten Prozessen über standardisiertes JSON-RPC. Der Agent greift über LSP-Tools (wie `get_errors`, `vscode_listCodeUsages`, `vscode_renameSymbol`) auf exakte Compiler-Fakten zu, statt Dateiinhalte erraten zu müssen.
* **Dynamische Modell- & Reasoning-Auswahl:**
  Je nach Komplexität der Aufgabe wählt der Entwickler das passende Modell und Reasoning-Level:
  * **Low-Latency / Flash-Modelle:** Für Inline-Autovervollständigung, schnelle Erklärungen und kleine Syntax-Korrekturen.
  * **High-Reasoning / Thinking-Modelle:** Für Architektur-Entscheidungen, Multi-Root-Refactorings und tiefgehende Ursachenanalysen (RCA). Hier formuliert das Modell vor der Code-Änderung eine interne Denk-Kette (Chain-of-Thought).
  * **Lokale Modelle (100 % Datensouveränität):** Über den Localhost-Proxy (`http://127.0.0.1:8317`) oder lokale Ollama-Instanzen können sensible Projekte komplett ohne Datenabfluss zu externen Cloud-Servern bearbeitet werden.

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Speicherort-Entscheidung:** Du möchtest eine Regel erstellen, die ausschließlich beim Bearbeiten von `.sh`-Bash-Skripten greift (`set -euo pipefail` erzwingen). In welchem Ordner und mit welchem `applyTo`-Eintrag legst du diese Datei für VS Code Copilot an?
2. **Model Harness & LSP:** Warum führt ein rechenintensives Refactoring durch einen KI-Agenten dank der Multi-Prozess-Architektur und LSP in VS Code nicht zum Einfrieren der Editor-Benutzeroberfläche?
3. **Reasoning-Stufen gezielt wählen:** Für welche Aufgaben nutzt du schnelle Flash-Modelle und für welche Aufgaben schaltest du auf erweiterte Denk-Modelle (Thinking / High-Reasoning)?
4. **Guter vs. schlechter Prompt:** Formuliere den unklaren Prompt *„Mach das Python-Skript besser“* in einen präzisen 3-Teile-Auftrag (Ziel + Dateigrenze + Prüfkriterium) um.

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* **Projekt-Regeln &amp; Instructions:** [`AGENTS.md`](../../AGENTS.md) · [`gemini-api.instructions.md`](../../.github/instructions/gemini-api.instructions.md) · [`vscode-experte.instructions.md`](../../../.copilot/instructions/vscode-experte.instructions.md) · [`01_agent-stilfibel-und-didaktik-ruler.md`](./01_agent-stilfibel-und-didaktik-ruler.md)
* **Aktive Custom Agents (`.github/agents/`):** [`general.agent.md`](../../.github/agents/general.agent.md) · [`rig.agent.md`](../../.github/agents/rig.agent.md) · [`light.agent.md`](../../.github/agents/light.agent.md) · [`dark.agent.md`](../../.github/agents/dark.agent.md) · [`sarah.agent.md`](../../.github/agents/sarah.agent.md)
* [VS Code Custom Instructions Dokumentation](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
* [VS Code Custom Agents (`.agent.md`) Dokumentation](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
* [Microsoft Language Server Protocol (LSP) Spezifikation](https://microsoft.github.io/language-server-protocol/)
* [Google Antigravity Rules & Workflows](https://antigravity.google/docs/rules-workflows)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **4 Steuerungsebenen:** Prompts für Ad-hoc-Fragen, Instructions für Projektregeln (`applyTo`), Skills für modulare Arbeitsabläufe, Custom Agents (`*.agent.md`) für Expertenrollen.
* **Model Harness als Dirigent:** Der Agent Harness verbindet UI, Sprachmodell, Language Server (LSP) und Werkzeuge (MCP) zu einem reaktionsschnellen System.
* **LSP garantiert Fakten:** Der Agent stützt sich bei Diagnosen auf Sprachserver-Fakten (`get_errors`), nicht auf Halluzinationen.
* **Reasoning nach Bedarf:** Nutze schnelle Modelle für repetitive Routineaufgaben und High-Reasoning-Modelle für Systemarchitektur und Fehlersuche.
* **Datensouveränität möglich:** Lokale Endpoints (`localhost:8317`) erlauben den Einsatz privater Modelle ohne Cloud-Leakage.
* **`AGENTS.md` = Projekt-Grundgesetz:** Wird sowohl von VS Code Copilot als auch von Google Antigravity im Projektstamm automatisch gelesen.
* **`applyTo` spart Kontext-Token:** Dateispezifische Regeln unter `.github/instructions/*.instructions.md` werden nur geladen, wenn passende Dateien betroffen sind.
* **Custom Agents (`*.agent.md`) schaffen klare Zuständigkeiten:** Jeder Agent hat eine eindeutige Rolle, feste Grenzen und eine prägnante `description`.
* **Überprüfbare Regeln formulieren:** Schreibe konkrete Prüfbefehle (z. B. *„Führe `uv run pytest` nach Codeänderungen aus“*) statt vager Wünsche.

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
