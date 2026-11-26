> **Thema:** KI-Agenten erstellen – Prompts, Instructions (`*.instructions.md`), Rules (`AGENTS.md`) & Custom Agents (`*.agent.md`)
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (05 Agents)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 05 Agents](./README.md) · **Vorheriges:** [⬅️ 01 • Agent-Stilfibel, Didaktik-Ruler & 7-Stufen-Aufbau](./01_agent-stilfibel-und-didaktik-ruler.md) · **Nächstes:** [03 • Agenten ausrüsten: Skills & MCP-Tools ➡️](./03_agenten-ausruesten-skills-und-mcp-tools.md)

**Alle Module in `05_Agents/`:**
- [01 • Agent-Stilfibel, Didaktik-Ruler & 7-Stufen-Aufbau](./01_agent-stilfibel-und-didaktik-ruler.md)
- 👉 **[02 • Agenten erstellen: Instructions, Rules & Prompts](./02_agenten-erstellen-instructions-rules-und-prompts.md)** *(aktuell)* · `gemini.instructions`
- [03 • Agenten ausrüsten: Skills & MCP-Tools](./03_agenten-ausruesten-skills-und-mcp-tools.md) · `SKILL.md`
- [04 • Priming, Memory & Multi-Agent-Orchestrierung](./04_agenten-trainieren-primen-und-orchestrieren.md) · `@light`
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

**Weitere Rubriken:** [🐧 01 Linux & Bash](../01_Linux_Bash/README.md) · [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🐍 03 Python](../03_Python_Coding/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

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
  * **Lokale Modelle (100 % Datensouveränität):** Über native lokale Ollama-Instanzen (`http://127.0.0.1:11434` auf Cyborg bzw. `http://192.168.178.68:11434` auf SimRacer) können sensible Projekte komplett ohne Datenabfluss zu externen Cloud-Servern bearbeitet werden *(der frühere Localhost-Proxy `:8317` wurde am 23.11.2026 entfernt)*.

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
* **Aktive Custom Agents:** [`General Cyborg` (Global)](../../../.copilot/agents/general.agent.md) · [`General Sim` (AC-Workspace)](../../../assetto-corsa-content/.github/agents/general.agent.md) · [`rig.agent.md`](../../.github/agents/rig.agent.md) · [`light.agent.md`](../../.github/agents/light.agent.md) · [`dark.agent.md`](../../.github/agents/dark.agent.md) · [`sarah.agent.md`](../../.github/agents/sarah.agent.md) · [`rick.agent.md`](../../.github/agents/rick.agent.md)
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
* **Datensouveränität möglich:** Lokale Ollama-Endpoints (`127.0.0.1:11434` / `192.168.178.68:11434`) erlauben den Einsatz lokaler Modelle ohne Cloud-Leakage.
* **`AGENTS.md` = Projekt-Grundgesetz:** Wird sowohl von VS Code Copilot als auch von Google Antigravity im Projektstamm automatisch gelesen.
* **`applyTo` spart Kontext-Token:** Dateispezifische Regeln unter `.github/instructions/*.instructions.md` werden nur geladen, wenn passende Dateien betroffen sind.
* **Custom Agents (`*.agent.md`) schaffen klare Zuständigkeiten:** Jeder Agent hat eine eindeutige Rolle, feste Grenzen und eine prägnante `description`.
* **Überprüfbare Regeln formulieren:** Schreibe konkrete Prüfbefehle (z. B. *„Führe `uv run pytest` nach Codeänderungen aus“*) statt vager Wünsche.

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
<div class="doku-arch-root"><span>🏛️ <a href="../README.md">VanstrikeCyborg — git-labor Doku-Index</a></span> · <a href="../../README.md">Repo-README</a> · <a href="../../AGENTS.md">AGENTS.md</a> · <a href="../../notebook-agent-environments/README.md">Notebooks</a> · <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md">Letztstand 26.11.</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🐧 <a href="../01_Linux_Bash/README.md">01_Linux_Bash (Linux, Shell & Container)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 • Bash CLI, Text-Tools, Streams & Expansions</a> <a class="doku-arch-badge" href="../../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="../01_Linux_Bash/02_linux-systemadministration-und-interna.md">02 • Inodes, LVM, Prozesse, Boot-Prozess & systemd</a></li>
<li>├─ <a href="../01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">03 • Arch Linux, Omarchy, Remote-SSH & Nginx</a></li>
<li>├─ <a href="../01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">04 • Advanced Bash: Arrays, getopts & Backups</a></li>
<li>└─ <a href="../01_Linux_Bash/05_docker-und-sbx-micro-vms.md">05 • Docker Grundlagen & Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="../02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP & Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) & Remote</a></li>
<li>├─ <a href="../02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow & Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="../02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Ollama (:11434) & Ports (Archiv: Proxy)</a> <a class="doku-arch-badge" href="../../.vscode/mcp.json">mcp.json</a></li>
<li>├─ <a href="../02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio & API-Keys</a></li>
<li>└─ <a href="../02_VSCode_Env/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">05 • 5-Knoten-Verbund, Parity & Parallel-Limits</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="../03_Python_Coding/README.md">03_Python_Coding (Python, uv & GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance & Notebooks</a> <a class="doku-arch-badge" href="../../notebook-agent-environments/agent_demo.ipynb">.ipynb</a></li>
<li>├─ <a href="../03_Python_Coding/02_gemini-api-python-sdk-und-interactions.md">02 • Google GenAI SDK (google-genai) & Interactions API</a></li>
<li>└─ <a href="../03_Python_Coding/03_python-automatisierung-datenanalyse-und-tests.md">03 • Automatisierung, Datenanalyse & pytest</a> <a class="doku-arch-badge" href="../../labs/03_python/sensor_demo.py">sensor_demo.py</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">🌐 <a href="../04_JS_TS_Web/README.md">04_JS_TS_Web (HTML/CSS, JS/TS & Web-SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../04_JS_TS_Web/01_html-css-und-dom-grundlagen.md">01 • HTML5, CSS3 & DOM-Manipulation Grundlagen</a> <a class="doku-arch-badge" href="../../labs/04_js_ts_web/rechner.html">rechner.html</a></li>
<li>├─ <a href="../04_JS_TS_Web/02_modernes-javascript-und-typescript.md">02 • Modernes JavaScript (ES6+) & TypeScript</a></li>
<li>└─ <a href="../04_JS_TS_Web/03_gemini-sdk-typescript-und-web-apps.md">03 • Google GenAI SDK (@google/genai) für Web-Apps</a></li>
</ul>
</div>
<div class="doku-arch-card r5">
<div class="doku-arch-card-title">🤖 <a href="../05_Agents/README.md">05_Agents (KI-Agenten, Skills & Orchestrierung)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../05_Agents/01_agent-stilfibel-und-didaktik-ruler.md">01 • Agent-Stilfibel, Didaktik-Ruler & 7-Stufen-Aufbau</a></li>
<li>├─ <a href="../05_Agents/02_agenten-erstellen-instructions-rules-und-prompts.md">02 • Agenten erstellen: Instructions, Rules & Prompts</a> <a class="doku-arch-badge" href="../../.github/instructions/gemini-api.instructions.md">gemini.instructions</a></li>
<li>├─ <a href="../05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills & MCP-Tools</a> <a class="doku-arch-badge" href="../../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>├─ <a href="../05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Priming, Memory & Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../../.github/agents/light.agent.md">@light</a></li>
<li>├─ <a href="../05_Agents/05_workspace-schnittstelle-simracer-und-agenten-terminals.md">05 • Schnittstelle, Terminals & XOR-Mutex</a> <a class="doku-arch-badge" href="../../labs/03_python/sim_agent_bridge.py">Bridge</a></li>
<li>├─ <a href="../05_Agents/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">06 • Multi-Workspace Netzwerk & 6-Rollen-Verbund</a></li>
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md">Letztstand 26.11. (Dual-GPU Ollama &amp; Pitwall GPU-Modelle)</a></li>
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md">Stand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)</a></li>
<li>├─ <a href="../05_Agents/HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md">Praxis-Referenz 25.11. (Hisense 4K-TV & ClearType)</a></li>
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md">Stand 24.11. (Parity, Qwen 3.5 & Nacharbeiten)</a></li>
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md">Stand 23.11. (ToS-Bereinigung, Ollama & Pitwall v1.5)</a></li>
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md">Änderungsprotokoll 11.11. (MQTT, Gatekeeper & Caddy)</a></li>
<li>├─ <a href="../05_Agents/PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md">Pitwall & Systemreferenz (NotebookLM-Quelle)</a></li>
<li>└─ <a href="../05_Agents/PITWALL_BOXENCREW_TEAMCHEF_KONZEPT_NOTEBOOKLM.md">Boxencrew & Teamchef Konzept (NotebookLM)</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
