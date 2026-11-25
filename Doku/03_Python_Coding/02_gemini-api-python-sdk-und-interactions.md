> **Thema:** Programmieren mit dem aktuellen Google GenAI Python SDK (`google-genai`) & der Interactions API
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (03 Python)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 03 Python](./README.md) · **Vorheriges:** [⬅️ 01 • Python Setup: uv, .venv, Pylance & Notebooks](./01_python-setup-uv-venv-und-notebooks.md) · **Nächstes:** [03 • Automatisierung, Datenanalyse & pytest ➡️](./03_python-automatisierung-datenanalyse-und-tests.md)

**Alle Module in `03_Python_Coding/`:**
- [01 • Python Setup: uv, .venv, Pylance & Notebooks](./01_python-setup-uv-venv-und-notebooks.md) · `.ipynb`
- 👉 **[02 • Google GenAI SDK (google-genai) & Interactions API](./02_gemini-api-python-sdk-und-interactions.md)** *(aktuell)*
- [03 • Automatisierung, Datenanalyse & pytest](./03_python-automatisierung-datenanalyse-und-tests.md) · `sensor_demo.py`

**Weitere Rubriken:** [🐧 01 Linux & Bash](../01_Linux_Bash/README.md) · [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md) · [🤖 05 Agents](../05_Agents/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

<details>
<summary><b>Lernziele</b></summary>

* Das aktuelle **`google-genai` SDK** sicher vom veralteten Legacy-Paket (`google-generativeai`) abgrenzen und installieren.
* Moderne KI-Aufrufe über die **Interactions API (`client.interactions.create`)** für Textgenerierung, Multi-Turn-Konversationen und Streaming implementieren.
* **Structured Outputs** (typsichere JSON-Antworten mit Pydantic) sowie **Function Calling (Tools)** in Python einsetzen.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Wichtigste Grundregel: Aktuelles SDK vs. Veraltetes Legacy-SDK</summary>

Viele ältere Tutorials im Internet zeigen noch abgekündigte Bibliotheken und Modelle. In unserem Workspace gilt (verankert in `.github/instructions/gemini-api.instructions.md`):

| Kriterium | ❌ VERALTET (Niemals verwenden!) | ✅ AKTUELL (Immer verwenden!) |
| :--- | :--- | :--- |
| **Python-Paketname** | `pip install google-generativeai` | **`uv add google-genai`** (`pip install google-genai`) |
| **Import im Code** | `import google.generativeai as genai` | **`from google import genai`** |
| **Client-Initialisierung** | `genai.configure(api_key=...)` | **`client = genai.Client()`** |
| **Standard-API-Methode** | `model.generate_content(...)` | **`client.interactions.create(...)`** |
| **Modell-Generation** | `gemini-1.5-pro` / `gemini-1.5-flash` | Aktuelle Gemini-Modelle (siehe `geminiDocs` MCP / `aistudio.google.com/docs/models`) |

</details>

<details>
<summary>1.2 Schnellstart mit der Interactions API (<code>client.interactions.create</code>)</summary>

Der `genai.Client()` liest den Schlüssel automatisch aus der Umgebungsvariable `GEMINI_API_KEY`:

```python
from google import genai

# Liest GEMINI_API_KEY automatisch aus der Umgebung
client = genai.Client()

interaction = client.interactions.create(
    model="gemini-2.5-flash",
    input="Erkläre das Prinzip eines PID-Reglers in drei kurzen Sätzen.",
)

print(interaction.output_text)
```

</details>

<details>
<summary>1.3 Strukturierte JSON-Ausgaben (Structured Outputs mit Pydantic)</summary>

Wenn ein Python-Skript Daten weiterverarbeiten soll, darf das Sprachmodell keinen freien Prosatext liefern, sondern muss sich strikt an ein **Pydantic-Datenmodell** halten:

```python
from pydantic import BaseModel, Field
from google import genai


class BauteilAnalyse(BaseModel):
    bauteil_name: str = Field(description="Name der technischen Komponente")
    kritikalitaet: int = Field(description="Stufe von 1 (niedrig) bis 5 (kritisch)")
    empfohlene_aktion: list[str] = Field(description="Konkrete Prüfschritte")


client = genai.Client()

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Analysiere einen überhitzten Frequenzumrichter im Schaltschrank.",
    config={
        "response_mime_type": "application/json",
        "response_schema": BauteilAnalyse,
        "temperature": 0.0,
    },
)

print(response.text)  # Garantiert valides JSON exakt nach dem Schema BauteilAnalyse!
```

</details>

<details>
<summary>1.4 Eigene Python-Funktionen als KI-Werkzeuge bereitstellen (Function Calling)</summary>

Du kannst dem Modell normale Python-Funktionen mit **Typannotationen und Docstrings** übergeben, damit es Berechnungen oder Systemabfragen exakt ausführt:

```python
from google import genai


def berechne_leistung_kw(spannung_v: float, strom_a: float, cos_phi: float = 0.85) -> float:
    """Berechnet die elektrische Wirkleistung in Kilowatt (kW) für Drehstrom."""
    import math
    return round((math.sqrt(3) * spannung_v * strom_a * cos_phi) / 1000.0, 2)


client = genai.Client()

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Welche Wirkleistung hat ein Antrieb bei 400 V, 16 A und cos_phi 0.88?",
    config={"tools": [berechne_leistung_kw]},
)

print(response.text)
```

</details>

<details>
<summary>1.5 Remote Managed Agents mit Geminis Interactions API starten</summary>

Über die Interactions API lassen sich sogar entfernte Agenten-Umgebungen inklusive gemounteter Skill-Repositories ansteuern:

```python
from google import genai

client = genai.Client()

interaction = client.interactions.create(
    agent="antigravity-preview-09-2026",
    input="Erstelle ein Python-Skript, das System-Logs nach Fehlern durchsucht.",
    environment={
        "type": "remote",
        "sources": [
            {
                "type": "repository",
                "source": "https://github.com/google-gemini/gemini-skills",
                "target": ".agents",
            }
        ],
    },
)
```

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Legacy-Code erkennen:** Ein älteres Codebeispiel enthält `import google.generativeai as genai` und `genai.configure(...)`. Schreibe diese beiden Zeilen auf das aktuelle `google-genai` SDK um.
2. **Pydantic-Schema entwerfen:** Schreibe eine Pydantic-Klasse `LogEintrag` mit den Feldern `zeitstempel: str`, `fehlercode: int` und `ist_kritisch: bool` für einen Structured-Output-Aufruf.
3. **Warum Temperatur `0.0`?** Erkläre, warum man bei der Extraktion strukturierter Daten oder der Codegenerierung die Temperatur im `config`-Objekt auf `0.0` setzt.

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [Gemini API Interactions Overview](https://aistudio.google.com/docs/interactions-overview)
* [Google GenAI Python SDK auf GitHub (`googleapis/python-genai`)](https://github.com/googleapis/python-genai)
* [Gemini API Vollständiger Dokumentations-Index (`llms.txt`)](https://aistudio.google.com/docs/llms.txt)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **Immer `from google import genai` nutzen:** Das Paket `google-generativeai` ist veraltet und darf in neuem Code nicht mehr verwendet werden.
* **`client.interactions.create` bevorzugen:** Die moderne Schnittstelle für Text, Chat, Agenten und Hintergrund-Interaktionen.
* **Pydantic erzwingt Typsicherheit:** Mit `response_schema` liefert Gemini garantiert parsbares JSON statt unstrukturiertem Freitext.
* **Docstrings + Type Hints = KI-Tools:** Python-Funktionen mit sauberen Typannotationen können direkt als ausführbare Tools an das Modell übergeben werden.

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
<div class="doku-arch-root"><span>🏛️ <a href="../README.md">VanstrikeCyborg — git-labor Doku-Index</a></span> · <a href="../../README.md">Repo-README</a> · <a href="../../AGENTS.md">AGENTS.md</a> · <a href="../../notebook-agent-environments/README.md">Notebooks</a> · <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md">Letztstand 25.11. (v5)</a></div>
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
<li>├─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md">Letztstand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)</a></li>
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
