> **Thema:** Hisense-TV & Windows-/NVIDIA-Display-Optimierung am SimRacer (`task_20261125_052359_3ndb`, Vorher/Nachher-Vergleich & Empfehlungen)
> **Autor:** Michael Stürmer
> **Datum:** 25.11.2026

# Hisense-TV Display- & Text-Schärfe-Optimierung (SimRacer `192.168.178.68`)

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (05 Agents)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 05 Agents](./README.md) · **Vorheriges:** [⬅️ Letztstand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md) · **Nächstes:** [Stand 24.11. (Parity, Qwen 3.5 & Nacharbeiten) ➡️](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md)

**Alle Module in `05_Agents/`:**
- [01 • Agent-Stilfibel, Didaktik-Ruler & 7-Stufen-Aufbau](./01_agent-stilfibel-und-didaktik-ruler.md)
- [02 • Agenten erstellen: Instructions, Rules & Prompts](./02_agenten-erstellen-instructions-rules-und-prompts.md) · `gemini.instructions`
- [03 • Agenten ausrüsten: Skills & MCP-Tools](./03_agenten-ausruesten-skills-und-mcp-tools.md) · `SKILL.md`
- [04 • Priming, Memory & Multi-Agent-Orchestrierung](./04_agenten-trainieren-primen-und-orchestrieren.md) · `@light`
- [05 • Schnittstelle, Terminals & XOR-Mutex](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md) · `Bridge`
- [06 • Multi-Workspace Netzwerk & 6-Rollen-Verbund](./05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md)
- [Letztstand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md)
- 👉 **[Praxis-Referenz 25.11. (Hisense 4K-TV & ClearType)](./HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md)** *(aktuell)*
- [Stand 24.11. (Parity, Qwen 3.5 & Nacharbeiten)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md)
- [Stand 23.11. (ToS-Bereinigung, Ollama & Pitwall v1.5)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md)
- [Änderungsprotokoll 11.11. (MQTT, Gatekeeper & Caddy)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md)
- [Pitwall & Systemreferenz (NotebookLM-Quelle)](./PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md)
- [Boxencrew & Teamchef Konzept (NotebookLM)](./PITWALL_BOXENCREW_TEAMCHEF_KONZEPT_NOTEBOOKLM.md)

**Weitere Rubriken:** [🐧 01 Linux & Bash](../01_Linux_Bash/README.md) · [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🐍 03 Python](../03_Python_Coding/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md) · [🏎️ 06 AC KN5 Modding](../06_AC_KN5_Modding/README.md) · [🥽 07 VR Engineering](../07_VR_Engineering/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

Diese Dokumentation hält die vom Multi-Agenten-Verbund (`General SIM` &rarr; `@light` &rarr; `@rig` auf lokaler **RTX 5070 Ti / `qwen3.5:9b`** &rarr; `@light` 2-Stufen-QA) ausgeführte Windows-Display-Optimierung für den angeschlossenen **Hisense 4K-TV** fest — einschließlich Backup-Pfad, gemessener Vorher/Nachher-Vergleichsliste sowie der ergänzenden Hardware-Einstellungen für **Visual Studio Code**, **Docker Desktop** und **WhatsApp**.

<details>
<summary><b>Lernziele</b></summary>

Nach dem Durcharbeiten dieser Referenz kannst du:
1. die auf dem SimRacer gemessenen **Windows-ClearType- und Gamma-Änderungen** (`FontSmoothingGamma` `0` &rarr; `1200`, `ClearTypeLevel` &rarr; `100`, `PixelStructure` &rarr; `1` RGB) und den zugehörigen **Backup-Rollout** nachvollziehen,
2. die Aufgabenteilung zwischen **automatisierbaren Windows-Registry-Schärfeparametern** (`rig_display_tuner.py`) und **manuellen NVIDIA-Control-Panel- / TV-HDMI-Schaltern** (Chroma `RGB 4:4:4`, Dynamikbereich `Voll 0–255`, TV-Modus `PC/Spiel`) sauber trennen,
3. erklären, warum Electron-/WebView-Apps (**VS Code, Docker Desktop, WhatsApp**) besonders empfindlich auf Subpixel-Chroma-Subsampling (`YCbCr 4:2:0` / `4:2:2`) und `FontSmoothingGamma = 0` reagieren.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary><b>1. Ausführungsprotokoll &amp; 2-Stufen-QA-Nachweis (<code>task_20261125_052359_3ndb</code>)</b></summary>

- **Auftragskette:** `General_SIM` &rarr; `@light` (`PID 45340`) &rarr; `@rig` (`PID 7468`) &rarr; lokales Ollama `qwen3.5:9b` &rarr; `rig_display_tuner.py --mode apply` &rarr; `@light` `light_verifier.py`
- **Status im Leitstand (`General SIM` / Pitwall):** **`VerifiedSuccess`** (`error_code: NONE`)
- **Angelegtes Registry-Backup:** `C:\ac-sandbox\shared\agents\rig\backups\display_backup_20261125_052402.json`
- **Verifikation Stufe A (Real-State-Test):** `FontSmoothing=2`, `Type=2`, `Gamma=1200`, `AvalonCT=100`, `GPU=NVIDIA GeForce RTX 5070 Ti`, Backup-Datei vorhanden.
- **Verifikation Stufe B (Sauberer Pfad):** Registriertes Werkzeug `apply_display_sharpness_profile` aus `shared/memories/host/rig/toolbox.json`, echte Vorher/Nachher-Evidenz, `0` Platzhalter.

</details>

<details>
<summary><b>2. Vorher/Nachher-Vergleichsliste (Windows Display &amp; ClearType auf SimRacer)</b></summary>

#### A) Durch `@rig` (`rig_display_tuner.py`) angewendete Änderungen

| Einstellung / Registry-Pfad | Vorher (Ist) | Nachher (Neu) | Wirkung für VS Code / Docker Desktop / WhatsApp |
| :--- | :--- | :--- | :--- |
| **`HKCU\Control Panel\Desktop\FontSmoothing`** | `"2"` | **`"2"`** | Grundsätzliche Schriftglättung aktiv |
| **`HKCU\Control Panel\Desktop\FontSmoothingType`** | `2` | **`2` (ClearType)** | Subpixel-Antialiasing aktiv |
| **`HKCU\Control Panel\Desktop\FontSmoothingOrientation`** | `1` | **`1` (RGB)** | Passend zur Standard-RGB-Subpixelstruktur |
| **`HKCU\Control Panel\Desktop\FontSmoothingGamma`** | `0` | **`1200`** | Korrigiert ausgewaschene/zu dünne dunkle Glyphen auf VA-/LCD-TVs |
| **`HKCU\Software\Microsoft\Avalon.Graphics\DISPLAY1\ClearTypeLevel`** | `null` (nicht gesetzt) | **`100`** | Volle ClearType-Kontrastschärfe für WPF-/Modern-Desktop-Apps (z. B. Docker Desktop / Windows UI) |
| **`HKCU\Software\Microsoft\Avalon.Graphics\DISPLAY1\PixelStructure`** | `null` (nicht gesetzt) | **`1` (RGB)** | Explizite RGB-Ausrichtung im DirectWrite/WPF-Stack |

#### B) Unveränderte Hardware- &amp; Systembasis (Ist-Stand)

| Komponente | Gemessener Wert | Status |
| :--- | :--- | :--- |
| **Monitor-EDID** | `DISPLAY\HECB340\...` · Hersteller `HEC` · Name **`HISENSE`** · Serial `1735156332` | Erkannt |
| **GPU &amp; Treiber** | **NVIDIA GeForce RTX 5070 Ti** · Treiber **`621.40`** (`32.0.16.2140`) | Aktiv (`43–56 °C`) |
| **Auflösung &amp; Bildrate** | **`3840 × 2160 @ 60 Hz`** (`32 bpp`) | Native 4K-Auflösung |
| **Per-Monitor-DPI / Scaling** | `win8_dpi_scaling = 0`, Per-Monitor-DPI in `PerMonitorSettings`; `HIGHDPIAWARE` auf AC/SteamVR | Apps nutzen native Windows-Monitor-Skalierung |

</details>

<details>
<summary><b>3. Ergänzende manuelle Feineinstellung (NVIDIA Control Panel &amp; Hisense TV)</b></summary>

Da NVIDIA-Control-Panel-HDMI-Chroma-Parameter und geräteinterne TV-Bildmodi nicht über die Windows-Registry schaltbar sind, empfiehlt `@rig` ergänzend diese drei einmaligen Sichtprüfungen am TV/NVCP:

1. **NVIDIA Systemsteuerung &rarr; Anzeige &rarr; Auflösung ändern:**
   - **Ausgabe-Farbformat:** **`RGB`** (statt `YCbCr 4:2:0` oder `4:2:2`) — verhindert farbige Treppenstufen an feinen 1-px-Buchstaben in **VS Code**, **Docker Desktop** und **WhatsApp**.
   - **Dynamischer Ausgabebereich:** **`Voll` (`0–255`)** statt `Begrenzt` (`16–235`).
   - **Ausgabe-Farbtiefe:** `8 bpc` (oder `10 bpc` bei HDMI 2.1, solange `RGB` ohne Chroma-Subsampling erhalten bleibt).
2. **Hisense-TV Gerätemenü (HDMI-Eingang):**
   - **HDMI-Format:** **`Erweitertes Format`** (HDMI 2.0/2.1).
   - **Bildmodus:** **`PC`** oder **`Spiel`** (deaktiviert TV-Rauschunterdrückung, Overscan und Zwischenbildberechnung).
   - **TV-Schärfe (`Sharpness`):** auf **`0`** (neutral, keine künstlichen weißen Halos um Text).
3. **Windows Bildschirm-Skalierung (bei 4K `3840×2160` auf großem TV):**
   - Empfohlen **`150 %`** oder **`200 %`** plus aktivierte Option *„Apps mit unscharfer Darstellung korrigieren“*, falls Electron-Fenster nach einem Display-Wechsel weich wirken (App danach einmal neu starten).

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **ClearType nach Ab-/Anmelden prüfen:** Nach einmaligem Ab- und wieder Anmelden (oder App-Neustart von VS Code / Docker Desktop / WhatsApp) die Textschärfe am Hisense-TV vergleichen.
2. **Rollback bei Bedarf:** Sollte der alte Zustand (`FontSmoothingGamma = 0`) wiederhergestellt werden müssen, stehen die Ausgangswerte 1:1 in `C:\ac-sandbox\shared\agents\rig\backups\display_backup_20261125_052402.json`.
3. **NVCP-Check:** In der NVIDIA Systemsteuerung kontrollieren, ob Ausgabe-Farbformat auf **`RGB`** und Dynamischer Bereich auf **`Voll`** steht.

</details>

<details>
<summary><b>Weiterführende Links &amp; Quellen</b></summary>

- **Architekturprotokoll (25.11.2026):** [`SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md`](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md)
- **Leitstand-DocHandoff (Maschinenbeleg):** [`handoff_task_20261125_052359_3ndb.md`](file:///192.168.178.68/ac-sandbox/shared/agents/general-SIM/doc_handoffs/handoff_task_20261125_052359_3ndb.md) · [`handoff_task_20261125_052359_3ndb.json`](file:///192.168.178.68/ac-sandbox/shared/agents/general-SIM/doc_handoffs/handoff_task_20261125_052359_3ndb.json)
- **Ausführendes Tool:** [`rig_display_tuner.py`](file:///192.168.178.68/ac-sandbox/shared/scripts/rig_display_tuner.py)
- **Registry-Backup auf SimRacer:** [`display_backup_20261125_052402.json`](file:///192.168.178.68/ac-sandbox/shared/agents/rig/backups/display_backup_20261125_052402.json)

</details>

<details>
<summary><b>Chips &amp; Kernaussagen</b></summary>

- **Echter GPU-Agentenlauf (`VerifiedSuccess`):** `@light` delegierte an `@rig`, `qwen3.5:9b` rief `apply_display_sharpness_profile` auf und `@light` verifizierte die Live-Registry + Backup unabhängig.
- **Messbares Ergebnis:** `FontSmoothingGamma` wurde von `0` auf `1200`, `Avalon.Graphics\DISPLAY1\ClearTypeLevel` auf `100` und `PixelStructure` auf `1` (`RGB`) gesetzt.
- **NVCP-Restcheck für 4K-TV-Schärfe:** Die wichtigste verbleibende Stellschraube gegen Farbsäume an Text in VS Code / Docker / WhatsApp ist **NVIDIA Systemsteuerung &rarr; `RGB` + `Voll (0–255)`** sowie TV-Bildmodus **`PC/Spiel`**.

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
.doku-arch-card.r6 { border-left-color: #f97316; border-top-color: #f97316; }
.doku-arch-card.r7 { border-left-color: #06b6d4; border-top-color: #06b6d4; }
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
details.doku-minimap .dot.r6 { background: #f97316; }
details.doku-minimap .dot.r7 { background: #06b6d4; }
details.doku-minimap .minimap-body { padding: 4px 12px 6px 12px; }
</style>
<details class="doku-minimap">
<summary><span>🗺️ Doku-Minimap (7 Rubriken &amp; Labs)</span><span class="minimap-toggle" title="Klicken zum Vergrößern / Einklappen"></span></summary>
<div class="minimap-preview-strip"><span><i class="dot r1"></i>Linux</span><span><i class="dot r2"></i>VSCode</span><span><i class="dot r3"></i>Python</span><span><i class="dot r4"></i>JS/TS</span><span><i class="dot r5"></i>Agents</span><span><i class="dot r6"></i>KN5</span><span><i class="dot r7"></i>VR</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root"><span>🏛️ <a href="../README.md">VanstrikeCyborg — git-labor Doku-Index</a></span> · <a href="../../README.md">Repo-README</a> · <a href="../../AGENTS.md">AGENTS.md</a> · <a href="../../notebook-agent-environments/README.md">Notebooks</a> · <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-28.md">Letztstand 28.11.</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🐧 <a href="../01_Linux_Bash/README.md">01_Linux_Bash (Linux, Shell &amp; Container)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../01_Linux_Bash/01_bash-grundlagen-und-skripting.md">01 • Bash CLI, Text-Tools, Streams &amp; Expansions</a> <a class="doku-arch-badge" href="../../labs/01_linux_bash/check-env.sh">check-env.sh</a></li>
<li>├─ <a href="../01_Linux_Bash/02_linux-systemadministration-und-interna.md">02 • Inodes, LVM, Prozesse, Boot-Prozess &amp; systemd</a></li>
<li>├─ <a href="../01_Linux_Bash/03_arch-linux-omarchy-und-remote-ssh.md">03 • Arch Linux, Omarchy, Remote-SSH &amp; Nginx</a></li>
<li>├─ <a href="../01_Linux_Bash/04_fortgeschrittenes-bash-skripting-und-automatisierung.md">04 • Advanced Bash: Arrays, getopts &amp; Backups</a></li>
<li>└─ <a href="../01_Linux_Bash/05_docker-und-sbx-micro-vms.md">05 • Docker Grundlagen &amp; Sandbox Micro-VMs (sbx)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🧩 <a href="../02_VSCode_Env/README.md">02_VSCode_Env (IDE, Git, MCP &amp; Gemini)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../02_VSCode_Env/01_vscode-architektur-lsp-und-remote.md">01 • VS Code Architektur, Sprachserver (LSP) &amp; Remote</a></li>
<li>├─ <a href="../02_VSCode_Env/02_git-github-und-multi-root-workspaces.md">02 • Git, GitHub Workflow &amp; Multi-Root Workspaces</a> <a class="doku-arch-badge" href="../../git-labor.code-workspace">Workspace</a></li>
<li>├─ <a href="../02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md">03 • MCP-Server, Ollama (:11434) &amp; Ports (Archiv: Proxy)</a> <a class="doku-arch-badge" href="../../.vscode/mcp.json">mcp.json</a></li>
<li>├─ <a href="../02_VSCode_Env/04_gemini-oekosystem-ai-studio-und-api-keys.md">04 • Gemini Ökosystem, Google AI Studio &amp; API-Keys</a></li>
<li>└─ <a href="../02_VSCode_Env/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">05 • 5-Knoten-Verbund, Parity &amp; Parallel-Limits</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🐍 <a href="../03_Python_Coding/README.md">03_Python_Coding (Python, uv &amp; GenAI SDK)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../03_Python_Coding/01_python-setup-uv-venv-und-notebooks.md">01 • Python Setup: uv, .venv, Pylance &amp; Notebooks</a> <a class="doku-arch-badge" href="../../notebook-agent-environments/agent_demo.ipynb">.ipynb</a></li>
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
<li>├─ <a href="../05_Agents/03_agenten-ausruesten-skills-und-mcp-tools.md">03 • Agenten ausrüsten: Skills &amp; MCP-Tools</a> <a class="doku-arch-badge" href="../../.agents/skills/live-transfer-status-monitor/SKILL.md">SKILL.md</a></li>
<li>├─ <a href="../05_Agents/04_agenten-trainieren-primen-und-orchestrieren.md">04 • Priming, Memory &amp; Multi-Agent-Orchestrierung</a> <a class="doku-arch-badge" href="../../.github/agents/light.agent.md">@light</a></li>
<li>├─ <a href="../05_Agents/05_workspace-schnittstelle-simracer-und-agenten-terminals.md">05 • Schnittstelle, Terminals &amp; XOR-Mutex</a> <a class="doku-arch-badge" href="../../labs/03_python/sim_agent_bridge.py">Bridge</a></li>
<li>├─ <a href="../05_Agents/05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md">06 • Multi-Workspace Netzwerk &amp; 7-Rollen-Verbund</a></li>
<li>└─ <a href="../05_Agents/SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-28.md">Letztstand 28.11. (Labs 06/07, Cleanup &amp; KN5-Fix)</a></li>
</ul>
</div>
<div class="doku-arch-card r6">
<div class="doku-arch-card-title">🏎️ <a href="../06_AC_KN5_Modding/README.md">06_AC_KN5_Modding (.kn5 &amp; Toolchain)</a></div>
<ul class="doku-arch-lines">
<li>└─ <a href="../06_AC_KN5_Modding/01_kn5-format-entwicklungsumgebung-und-setup.md">01 • .kn5-Format, ext_config &amp; Sandbox-Gate</a> <a class="doku-arch-badge" href="../../labs/06_ac_kn5_modding/inspect_kn5.py">inspect_kn5.py</a></li>
</ul>
</div>
<div class="doku-arch-card r7">
<div class="doku-arch-card-title">🥽 <a href="../07_VR_Engineering/README.md">07_VR_Engineering (90 Hz VR &amp; @rig)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../07_VR_Engineering/01_vr-architektur-frametimes-und-diagnose.md">01 • VR-Architektur, Frametimes &amp; Compositor</a> <a class="doku-arch-badge" href="../../labs/07_vr_engineering/analyze_vr_compositor.py">analyze_vr_compositor.py</a></li>
<li>└─ <a href="../../labs/07_vr_engineering/README.md">Lab 07 • VR-Invarianten &amp; Read-Only Check</a> <a class="doku-arch-badge" href="../../labs/07_vr_engineering/Check-VrInvariants.ps1">Check-VrInvariants.ps1</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
