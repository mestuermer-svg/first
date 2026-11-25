> **Thema:** Python für Automatisierung, statische Typprüfung (Pylance), Datenanalyse & Unit-Tests (`pytest`)
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (03 Python)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 03 Python](./README.md) · **Vorheriges:** [⬅️ 02 • Google GenAI SDK (google-genai) & Interactions API](./02_gemini-api-python-sdk-und-interactions.md) · **Nächstes:** *(Letztes Modul)*

**Alle Module in `03_Python_Coding/`:**
- [01 • Python Setup: uv, .venv, Pylance & Notebooks](./01_python-setup-uv-venv-und-notebooks.md) · `.ipynb`
- [02 • Google GenAI SDK (google-genai) & Interactions API](./02_gemini-api-python-sdk-und-interactions.md)
- 👉 **[03 • Automatisierung, Datenanalyse & pytest](./03_python-automatisierung-datenanalyse-und-tests.md)** *(aktuell)* · `sensor_demo.py`

**Weitere Rubriken:** [🐧 01 Linux & Bash](../01_Linux_Bash/README.md) · [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md) · [🤖 05 Agents](../05_Agents/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

<details>
<summary><b>Lernziele</b></summary>

* Python-Skripte mit vollständigen **Typannotationen (Type Hints)** schreiben, damit **Pylance** Fehler bereits während des Tippens im Editor erkennt.
* Dateien, Pfade und JSON-Konfigurationen plattformübergreifend (Windows & Linux) mit **`pathlib`** und **`json`** verarbeiten.
* Automatisierte **Unit-Tests mit `pytest`** erstellen, um Funktionen und Randfälle (z. B. leere Eingaben) zuverlässig abzusichern.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Statische Typannotationen (Type Hints) & Pylance</summary>

Aus Sprachen wie C# oder strukturiertem Text (SCL) in der SPS-Welt ist bekannt, wie wertvoll feste Datentypen sind. In modernem Python (3.11–3.14) versieht man Funktionsparameter und Rückgabewerte mit **Type Hints**, die der **Pylance Language Server** in Echtzeit prüft:

```python
from dataclasses import dataclass


@dataclass
class SensorMessung:
    sensor_id: str
    temperatur_c: float
    aktiv: bool = True


def berechne_durchschnitt(messungen: list[SensorMessung]) -> float | None:
    """Berechnet die Durchschnittstemperatur aller aktiven Sensoren."""
    aktive_werte = [m.temperatur_c for m in messungen if m.aktiv]
    if not aktive_werte:
        return None
    return round(sum(aktive_werte) / len(aktive_werte), 2)
```

* **`list[SensorMessung]`:** Liste, die ausschließlich `SensorMessung`-Objekte enthält.
* **`float | None`:** Gibt entweder eine Kommazahl oder `None` (bei leerer Liste) zurück – Pylance warnt dich automatisch, falls du vergisst, beim Aufrufer auf `None` zu prüfen!

</details>

<details>
<summary>1.2 Plattformunabhängige Dateipfade mit <code>pathlib</code></summary>

Damit deine Python-Skripte sowohl auf dem **VanstrikeCyborg (Windows `\` )** als auch unter **Arch Linux / Omarchy (Linux `/` )** ohne Änderung laufen, verwendet man immer **`pathlib.Path`** statt zusammengesetzter Strings:

```python
import json
from pathlib import Path

# Erzeugt automatisch den richtigen Pfad für Windows UND Linux
basis_ordner = Path(__file__).resolve().parent
config_datei = basis_ordner / "config" / "settings.json"

# Ordner sicher anlegen und JSON schreiben
config_datei.parent.mkdir(parents=True, exist_ok=True)
daten = {"projekt": "git-labor", "version": 1, "debug": False}
config_datei.write_text(json.dumps(daten, indent=2, ensure_ascii=False), encoding="utf-8")

# JSON wieder einlesen
geladene_daten = json.loads(config_datei.read_text(encoding="utf-8"))
print(f"Geladenes Projekt: {geladene_daten['projekt']}")
```

</details>

<details>
<summary>1.3 Automatisierte Tests schreiben mit <code>pytest</code></summary>

Ein gutes Programm wird nicht nur manuell ausprobiert, sondern durch reproduzierbare **Tests** abgesichert. In `pytest` reicht eine einfache Funktion mit `test_`-Präfix und dem Schlüsselwort `assert`:

```python
# Datei: test_sensoren.py
from sensoren import SensorMessung, berechne_durchschnitt


def test_durchschnitt_normale_werte() -> None:
    daten = [
        SensorMessung("S1", 20.0, aktiv=True),
        SensorMessung("S2", 30.0, aktiv=True),
        SensorMessung("S3", 99.0, aktiv=False),  # Inaktiv -> muss ignoriert werden!
    ]
    assert berechne_durchschnitt(daten) == 25.0


def test_durchschnitt_leere_liste_liefert_none() -> None:
    assert berechne_durchschnitt([]) is None
```

Ausführung im Terminal:
```powershell
uv run pytest -v
```

</details>

<details>
<summary>1.4 Datenanalyse & Cloud-Skalierung (Pandas & BigQuery BigFrames)</summary>

Für tabellarische Datenauswertungen, Zeitreihen und Machine Learning in Python stehen im Workspace spezialisierte Werkzeuge bereit:
* **Lokal im Speicher (`pandas` / `polars`):** Ideal für CSV-, JSON- und Log-Dateien bis zu einigen hundert Megabyte.
* **Cloud-skaliert (`bigframes.pandas`):** Wenn Datensätze im Gigabyte- oder Terabyte-Bereich in Google BigQuery liegen, nutzt du die vertraute Pandas-Syntax über `import bigframes.pandas as bpd`, während die Berechnung komplett auf den Google-Cloud-Servern ausgeführt wird.

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Pfad-Portabilität:** Schreibe den fehleranfälligen Ausdruck `pfad = "C:\\Users\\strik\\git-labor\\" + ordner + "\\daten.json"` in sauberen, betriebssystemunabhängigen `pathlib.Path`-Code um.
2. **Typprüfung verstehen:** Eine Funktion hat die Signatur `def finde_user(user_id: int) -> str | None:`. Warum markiert Pylance den Aufruf ` print(finde_user(5).upper())` als potenziellen Fehler, und wie behebst du ihn sauber?
3. **Randfall-Test:** Schreibe einen zusätzlichen `pytest`-Testfall für `berechne_durchschnitt`, bei dem zwar drei Sensoren in der Liste sind, aber alle drei auf `aktiv=False` stehen.

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [Python `pathlib` Dokumentation](https://docs.python.org/3/library/pathlib.html)
* [Pytest Getting Started Guide](https://docs.pytest.org/en/stable/getting-started.html)
* [Python Typing & Type Hints Cheat Sheet (Mypy/Pylance)](https://mypy.readthedocs.io/en/stable/cheat_sheet_py3.html)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **Type Hints + Pylance = Fehlerfinden vor dem Start:** Typannotationen machen Python genauso übersichtlich und wartbar wie statisch typisierte Sprachen (C#, TypeScript).
* **Immer `pathlib.Path` statt String-Slashes:** Mit dem `/`-Operator von `Path` funktionieren Skripte automatisch unter Windows und Linux.
* **`encoding="utf-8"` explizit angeben:** Verhindert kaputte deutsche Umlaute (`ä, ö, ü, ß`) beim Lesen und Schreiben unter Windows.
* **Jede Kernfunktion bekommt einen `pytest`-Test:** Prüfe immer mindestens den Normalfall und einen Grenzfall (z. B. leere Eingabe).

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
