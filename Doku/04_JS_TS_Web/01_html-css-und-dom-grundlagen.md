> **Thema:** HTML5, CSS3 & Browser-DOM – Wie Webseiten und interaktive Oberflächen im Browser funktionieren
> **Autor:** Michael Stürmer
> **Datum:** 07.11.2026

<details>
<summary><b>Lernziele</b></summary>

* Die strikte Rollentrennung zwischen **HTML (Struktur & Inhalt)**, **CSS (Layout & Gestaltung)** und **JavaScript (Verhalten & Logik)** verstehen.
* Nachvollziehen, wie der **Browser** als Laufzeitumgebung eine `.html`-Datei in das **DOM (Document Object Model)** übersetzt und auf Benutzerklicks (**Events**) reagiert.
* Eine eigenständige, fehlerrobuste Web-Anwendung (`rechner.html`) ohne externe Bibliotheken aufbauen und systematisch testen.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Die drei Bausteine jeder Web-Oberfläche</summary>

| Technologie | Art der Sprache | Aufgabe im Browser | Analogie (Schaltschrank / HMI) |
| :--- | :--- | :--- | :--- |
| **HTML** (`index.html`) | Auszeichnungssprache (*Markup*) | Definiert **welche Elemente** existieren (Überschrift, Eingabefeld, Button, Ausgabetext). | Montageplatte mit eingebauten Tastern, Schaltern und Anzeigen. |
| **CSS** (`style.css`) | Stylesheet-Sprache | Bestimmt **Aussehen, Farben, Abstände und Layout** (Flexbox / Grid). | Beschriftungsschilder, Gehäusefarbe und symmetrische Anordnung auf dem Panel. |
| **JavaScript** (`app.js`) | Echte Programmiersprache | Steuert das **Verhalten**: Liest Eingaben, rechnet, prüft Fehler und aktualisiert die Anzeige. | Das SPS-/HMI-Steuerprogramm hinter den Tastern. |

</details>

<details>
<summary>1.2 Vom Klick zum Ergebnis: Das Document Object Model (DOM)</summary>

Wenn du eine `.html`-Datei im Browser öffnest, erzeugt der Browser im Arbeitsspeicher einen Baum aus Objekten (**DOM**). JavaScript greift über eindeutige `id`-Attribute auf diese Elemente zu:

```mermaid
flowchart LR
    U["Benutzer gibt Zahlen ein\n& klickt auf Button"] -->|"click Event"| JS["JavaScript Event-Listener\n1. Liest .value (als String)\n2. Prüft auf leere Eingabe\n3. Wandelt mit Number() in Zahl\n4. Berechnet Summe"]
    JS -->|"Schreibt .textContent"| DOM["Ergebnis-Feld im Browser\nwird sofort aktualisiert"]
```

**Wichtige Stolperfalle bei Eingabefeldern:**
Ein HTML-Eingabefeld (`<input>`) liefert seinen Inhalt (`element.value`) immer zuerst als **Text (`String`)** zurück!
* Würde man `"5" + "3"` als Text addieren, käme `"53"` heraus (String-Verkettung).
* Deshalb muss der Text vor dem Rechnen mit `Number(wert)` oder `parseFloat(wert)` explizit in eine Zahl umgewandelt und mit `Number.isNaN()` geprüft werden.

</details>

<details>
<summary>1.3 Komplettes Lernbeispiel: <code>rechner.html</code> (HTML + CSS + JS in einer Datei)</summary>

Dieses Beispiel zeigt das saubere Zusammenspiel aller drei Schichten ohne externe Abhängigkeiten:

```html
<!doctype html>
<html lang="de">
<head>
  <meta charset="utf-8" />
  <title>Git-Labor Zahlenrechner</title>
  <style>
    /* 1. CSS: Gestaltung & Layout */
    body {
      font-family: system-ui, sans-serif;
      background: #0f172a;
      color: #f8fafc;
      display: flex;
      justify-content: center;
      padding-top: 4rem;
    }
    .card {
      background: #1e293b;
      padding: 1.5rem;
      border-radius: 10px;
      width: 340px;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
    }
    input, button {
      width: 100%;
      padding: 0.6rem;
      margin-top: 0.5rem;
      border-radius: 6px;
      border: 1px solid #475569;
      box-sizing: border-box;
      font-size: 1rem;
    }
    button {
      background: #3b82f6;
      color: white;
      font-weight: bold;
      cursor: pointer;
      border: none;
      margin-top: 1rem;
    }
    .result {
      margin-top: 1rem;
      padding: 0.75rem;
      background: #0f172a;
      border-radius: 6px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <!-- 2. HTML: Struktur & Bedienelemente -->
  <div class="card">
    <h2>Zahlenrechner</h2>
    <label for="zahlA">Erste Zahl:</label>
    <input id="zahlA" type="number" step="any" placeholder="z. B. 12.5" />

    <label for="zahlB">Zweite Zahl:</label>
    <input id="zahlB" type="number" step="any" placeholder="z. B. 7.5" />

    <button id="btnAddieren" type="button">Addieren (+)</button>
    <div id="ausgabe" class="result">Ergebnis: –</div>
  </div>

  <!-- 3. JavaScript: Verhalten & Berechnungslogik -->
  <script>
    const inputA = document.getElementById("zahlA");
    const inputB = document.getElementById("zahlB");
    const button = document.getElementById("btnAddieren");
    const ausgabe = document.getElementById("ausgabe");

    button.addEventListener("click", () => {
      const textA = inputA.value.trim();
      const textB = inputB.value.trim();

      if (textA === "" || textB === "") {
        ausgabe.textContent = "Bitte beide Zahlenfelder ausfüllen!";
        return;
      }

      const wertA = Number(textA);
      const wertB = Number(textB);

      if (Number.isNaN(wertA) || Number.isNaN(wertB)) {
        ausgabe.textContent = "Ungültige Zahleneingabe!";
        return;
      }

      const summe = wertA + wertB;
      ausgabe.textContent = `Ergebnis: ${summe}`;
    });
  </script>
</body>
</html>
```

</details>

<details>
<summary>1.4 Systematisches Testen einer Web-Komponente</summary>

Vor jeder Freigabe einer Oberfläche sollten mindestens drei Testkategorien geprüft werden:
1. **Normalfall (Happy Path):** `12.5` und `7.5` eingeben $\rightarrow$ Erwartete Anzeige: `Ergebnis: 20`.
2. **Grenzwerte & Vorzeichen:** Negative Zahlen (`-10` und `4`) sowie `0` testen $\rightarrow$ Erwartete Anzeige: `Ergebnis: -6`.
3. **Fehler- / Randfall (Edge Case):** Ein oder beide Felder leer lassen und auf *Addieren* klicken $\rightarrow$ Darf nicht `NaN` oder `0` anzeigen, sondern den klaren Hinweis `Bitte beide Zahlenfelder ausfüllen!`.

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **String- vs. Zahlen-Addition:** Was gibt JavaScript aus, wenn du ohne `Number()`-Umwandlung direkt `"10" + "20"` berechnest, und warum passiert das?
2. **Erweiterung planen:** Du möchtest in `rechner.html` einen zweiten Button *Subtrahieren (-)* ergänzen. Welche Stellen im HTML-Bereich und im `<script>`-Bereich müssen dafür angepasst werden?
3. **Browser DevTools:** Mit welcher Taste öffnest du im Browser (Chrome/Edge) oder im integrierten VS Code Browser die Entwicklerkonsole, um JavaScript-Fehler oder DOM-Elemente live zu untersuchen?

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [MDN Web Docs – HTML Grundlagen](https://developer.mozilla.org/de/docs/Learn/Getting_started_with_the_web/HTML_basics)
* [MDN Web Docs – CSS Flexbox & Grid](https://developer.mozilla.org/de/docs/Learn/CSS/CSS_layout/Flexbox)
* [MDN Web Docs – Einführung in das DOM](https://developer.mozilla.org/de/docs/Web/API/Document_Object_Model/Introduction)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **HTML = Struktur, CSS = Aussehen, JS = Logik:** Halte diese drei Verantwortlichkeiten gedanklich und architektonisch immer sauber getrennt.
* **Der Browser ist die Laufzeit:** Für reine `.html`/`.css`/`.js`-Dateien wird kein Compiler benötigt – der Browser führt sie direkt aus.
* **Eingabefelder liefern immer Strings:** Vor mathematischen Operationen immer erst auf Leerstring (`trim() === ""`) prüfen und dann mit `Number()` konvertieren.
* **Jede Änderung mit 3 Fällen testen:** Positiver Normalfall, negative/Null-Werte und leere/fehlerhafte Benutzereingabe.

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
<div class="doku-arch-card-title">🌐 <a href="README.md">04_JS_TS_Web (HTML/CSS, JS/TS &amp; Web-SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="01_html-css-und-dom-grundlagen.md">01 • HTML5, CSS3 &amp; DOM-Manipulation Grundlagen</a> <a class="doku-arch-badge" href="../../labs/04_js_ts_web/rechner.html">rechner.html</a></li>
<li>├─ <a href="02_modernes-javascript-und-typescript.md">02 • Modernes JavaScript (ES6+) &amp; TypeScript</a></li>
<li>└─ <a href="03_gemini-sdk-typescript-und-web-apps.md">03 • Google GenAI SDK (@google/genai) für Web-Apps</a></li>
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
