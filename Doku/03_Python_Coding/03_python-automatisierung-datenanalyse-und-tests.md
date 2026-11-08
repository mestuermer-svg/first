> **Thema:** Python für Automatisierung, statische Typprüfung (Pylance), Datenanalyse & Unit-Tests (`pytest`)
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

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
<div class="doku-arch-card-title">🐍 <a href="README.md">03_Python_Coding (Python, uv &amp; GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance &amp; Notebooks</a></li>
<li>├─ <a href="02_gemini-api-python-sdk-und-interactions.md">02 • Google GenAI SDK (google-genai) &amp; Interactions API</a></li>
<li>└─ <a href="03_python-automatisierung-datenanalyse-und-tests.md">03 • Automatisierung, Datenanalyse &amp; pytest</a> <a class="doku-arch-badge" href="../../labs/03_python/sensor_demo.py">sensor_demo.py</a></li>
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
