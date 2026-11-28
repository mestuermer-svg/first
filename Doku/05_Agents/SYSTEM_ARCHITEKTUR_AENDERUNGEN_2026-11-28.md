> **Thema:** System- & Architektur-Änderungen vom 28.11.2026 — Neue Labs `06 KN5` & `07 VR`, Sandbox-`.kn5`-Reparatur, VR-Log-Diagnose & Multi-Workspace-Bereinigung (Pakete A–D2)
> **Autor:** Michael Stürmer
> **Datum:** 28.11.2026 *(Letztstand nach Nutzer-Freigabe & Verifikation gegen SimRacer)*

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (05 Agents)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 05 Agents](./README.md) · **Vorheriges:** [⬅️ Stand 27.11.](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-27.md)

**Aktuelle System-Chronik (`05_Agents/`):**
- 👉 **[Letztstand 28.11. (Labs 06/07, `.kn5`-Repair, VR-Logs & Workspace-Cleanup)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-28.md)** *(aktuell)*
- [Stand 27.11. (Host/Sandbox, Pitwall & Auto-Dual-GPU)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-27.md)
- [Stand 26.11. (Dual-GPU Ollama, Registry & SQLite Leitstand-DB)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-26.md)
- [Stand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md)

**Weitere Rubriken:** [🐧 01 Linux & Bash](../01_Linux_Bash/README.md) · [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🐍 03 Python](../03_Python_Coding/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md) · [🏎️ 06 AC KN5 Modding](../06_AC_KN5_Modding/README.md) · [🥽 07 VR Engineering](../07_VR_Engineering/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

<details>
<summary><b>Lernziele</b></summary>

* Den vollständigen Änderungsstand vom **28.11.2026** über alle Workspaces (**`git-labor`**, **`assetto-corsa-content`**, **`strikerpi-hub`**) und den Live-SimRacer (`192.168.178.68`) nachvollziehen.
* Verstehen, wie fehlende `.kn5`-Dateien (`gp_2025_rb21` & GP-2025-Serie), VR-Startabstürze (`libcef.DLL` OOM / `0xc0000374` Heap Corruption) und Compositor-Timeouts (`AcquireSync WAIT_TIMEOUT`) technisch behoben und über die neuen **Labs 06 & 07** dauerhaft prüfbar gemacht wurden.
* Die Bereinigung der VS-Code-Tasks, SSH-Profile, Altlasten-Skripte und Backups (**Pakete A, B, C, D1, D2 — unter Beibehaltung von D3**) inklusive Change-Freeze-Grenzen sicher anwenden.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Neue Fachrubriken &amp; Praxis-Labs (`06_AC_KN5_Modding` &amp; `07_VR_Engineering`)</summary>

Am **28.11.2026** wurden zwei neue Fachrubriken inklusive geprüfter CLI-Werkzeuge ergänzt und nahtlos in die Doku-Architektur eingebunden (`7` Rubriken gesamt):

1. **Rubrik 06 – AC `.kn5` Modding ([`Doku/06_AC_KN5_Modding/`](../06_AC_KN5_Modding/README.md) · [`labs/06_ac_kn5_modding/`](../../labs/06_ac_kn5_modding/README.md)):**
   - [`inspect_kn5.py`](../../labs/06_ac_kn5_modding/inspect_kn5.py): Python-3.12-Stdlib-Inspektor (`--file`, `--check-car-dir`, `--json`) für `sc6969`-Header, Texturen, Materialien/Shader, LODs und `ui_car.json`.
   - Verifikation gegen `gp_2025_rb21` auf SimRacer: `HEALTHY`, `4` `.kn5`-Dateien (`collider.kn5` `7.382 B`, Hauptmodell `105,78 MB`, `v=6`), **`101` Texturen (`88,32 MB`)** und **`77` Materialien** fehlerfrei geparst (`EXIT=0`).
   - [`ext_config_template.ini`](../../labs/06_ac_kn5_modding/templates/ext_config_template.ini): Vorlage für nicht-destruktive CSP-Shader- und Bremslicht-Tweaks ohne Re-Export der `.kn5`.

2. **Rubrik 07 – VR-Engineering ([`Doku/07_VR_Engineering/`](../07_VR_Engineering/README.md) · [`labs/07_vr_engineering/`](../../labs/07_vr_engineering/README.md)):**
   - [`analyze_vr_compositor.py`](../../labs/07_vr_engineering/analyze_vr_compositor.py): Analysiert SteamVR `vrcompositor.txt` inklusive `[N messages suppressed]`, `App CPU/GPU` vs. `90-Hz`-Budget (`11,111 ms`). Live-Lauf für `Nov 28 2026`: `506` Zeilen, `4` Sessions, Session 4 mit `48.410` Presents (`0` dropped, `0` reprojected), **`App CPU 11,374 ms` / `App GPU 10,711 ms`**, `5.934× AcquireSync TIMEOUT` (`EXIT=0`).
   - [`Check-VrInvariants.ps1`](../../labs/07_vr_engineering/Check-VrInvariants.ps1): Schreibgeschützte Prüfung von `video.ini`, `vr_tweaks.ini`, `graphics_adjustments.ini` und `grass_fx.ini` (`AST_SYNTAX_ERRORS=0`, Live-Run gegen SimRacer `cfg`: **`OK=13 | WARN=0 | FAIL=0`**).

</details>

<details>
<summary>1.2 Workspace-, Terminal- &amp; Skript-Bereinigung (Pakete A, B, C, D1, D2 — D3 unverändert)</summary>

Nach expliziter Diff-Vorlage und Nutzer-Freigabe (*„Alle außer D3“*) wurden Altlasten und Doppelstrukturen bereinigt:

| Paket | Gegenstand | Umgesetzte Maßnahme &amp; Verifikation |
| :--- | :--- | :--- |
| **A (Tasks &amp; SSH)** | [`git-labor.code-workspace`](../../git-labor.code-workspace), [`Agent-Terminals.ps1`](../../labs/Agent-Terminals.ps1), [`tasks.json`](../../../assetto-corsa-content/.vscode/tasks.json) | Doppelte SimRacer-SSH-Profile zu `SSH: SimRacer Host (.68)` konsolidiert (`5` Profile). Doppel-SSH-Loops bei `@light`/`@rig` und rohe Shell bei `@dark` direkt auf `start_*_terminal.ps1 -ClientMode` umgestellt; `Terminal: @cyborg (Laptop Master)` ergänzt; `@general` auf `@general-sim` umgestellt (`10` Agenten-Tasks in `git-labor.code-workspace`). `assetto-corsa-content/.vscode/tasks.json` von `21` auf **`10`** Infrastruktur-Tasks entschlackt (`ConvertFrom-Json` OK, `AST_SYNTAX_ERRORS=0`). |
| **B (Tote Skripte)** | `git-labor` &amp; `assetto-corsa-content` | **`20`** benannte Alt-Skripte (`debug.log`, `Invoke-SimAgentSsh.ps1`, `launch_all_terminals.ps1`, `Invoke-DarkAgent.ps1`, `Invoke-RigAgent.ps1`, `8` Einmal-Skripte in `ac-sandbox/`, `7` Migrations-/Alt-Skripte inkl. `launch_agent_terminals.ps1` in `shared/scripts/`) sowie **`59`** Einmal-Dateien direkt im Root von `ac-sandbox/shared/` entfernt. Die `5` aktiven Bootstrap-Dateien (`activate_win.ps1`, `bootstrap.bat`, `guest-status.json`, `OpenSSH.msi`, `SteamSetup.exe`) blieben erhalten. |
| **C (Backups)** | `strikerpi-hub` &amp; SimRacer `shared\scripts\` | `4` getrackte `.bak_*`-Dateien in `strikerpi-hub` per `git rm` entfernt; auf SimRacer (`\\192.168.178.68\ac-sandbox\shared\scripts\`) je Skript die **`12`** neuesten `.bak_*` behalten und **`26`** ältere Sicherungen nach `_archive_bak/` verschoben. |
| **D1 &amp; D2 (Settings)** | [`git-labor/.vscode/settings.json`](../../.vscode/settings.json), User `settings.json` | Workspace-Python-Config von `system`/`pip` auf `ms-python.python:venv` &amp; `ms-python.python:uv` korrigiert; in User `settings.json` Altlast `easyatm.cliproxy-for-copilot` entfernt und `antigravity.serverPort` auf `0` gestellt. |
| **D3 (Unverändert)** | ScheduledTask `AgentTerminal_General` | Wie vom Nutzer vorgegeben **nicht** beendet (`State: Running`), damit die Legacy-Übergangsstrecke bis zum finalen E2E-Cutover aktiv bleibt. |

</details>

<details>
<summary>1.3 Sandbox-`.kn5`-Reparatur &amp; VR-Startlog-Auswertung (`28.11.2026`)</summary>

* **Diagnose &amp; Behebung fehlender `.kn5`-Dateien (`@dark` / `runner.ps1`):** In [`runner.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/agents/dark/runner.ps1) wurden eine echte `.kn5`-Vollständigkeitsprüfung (`collider.kn5` + Modell-`.kn5` + `ui/ui_car.json`), ein `ForceReinstall`-Filter in `SyncCoreAssets`, die Log-Auswertung `ReadLogs`, eine 6-s-Post-Start-Prüfung (`Test-SandboxAcsPostStart`) sowie `1280×720 Fullscreen=1` / `FPS_CAP_MS=50` ergänzt (`SyntaxErrors=0`). Sämtliche `10` Fahrzeuge der GP-2025-Serie wurden in `ac-win11-sandbox` repariert und das Silverstone-RB21-Replay über `@light -> @dark` sauber verifiziert (`ERROR_FOUND=False`).
* **VR-Startlog-Analyse &amp; Agent-Priming:** Der Bericht [`Auswertung_VR_Startlogs_20261128_0736.md`](../../Systemtests/Auswertung_VR_Startlogs_20261128_0736.md) dokumentiert das 32-Bit-Speicherlimit von `AssettoCorsa.exe` (`libcef.DLL` `0x4000001f` bei `337` Fahrzeugen), sporadische `0xc0000374`-Heap-Crashes beim Start, `Tcpip Event 4231` (Ephemeral Ports) und `AcquireSync`-Timeouts; die Profile von `@light`, `@dark` und `rig_dark_optimization_core` wurden darauf aufbauend aktualisiert.

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Aufgabe 1 — Terminal-Matrix &amp; JSON-Check nach Bereinigung:**
   Führe `.\labs\Agent-Terminals.ps1 -StatusOnly` aus und prüfe, dass `@cyborg` (`LOKAL BEREIT`), `@general-sim` (`READY`) sowie `@light`, `@rig`, `@dark` und `@rick` ohne Doppel-SSH-Schleife angesprochen werden.
2. **Aufgabe 2 — `.kn5`- &amp; VR-Invarianten nachweisbar abfragen:**
   Starte [`inspect_kn5.py`](../../labs/06_ac_kn5_modding/inspect_kn5.py) gegen `gp_2025_rb21` sowie [`Check-VrInvariants.ps1`](../../labs/07_vr_engineering/Check-VrInvariants.ps1) im Read-Only-Modus und vergleiche die Kennzahlen mit Kapitel `1.1`.

</details>

<details>
<summary><b>Weiterführende Links &amp; Quellen</b></summary>

* [`Doku/06_AC_KN5_Modding/README.md`](../06_AC_KN5_Modding/README.md) · [`labs/06_ac_kn5_modding/`](../../labs/06_ac_kn5_modding/README.md)
* [`Doku/07_VR_Engineering/README.md`](../07_VR_Engineering/README.md) · [`labs/07_vr_engineering/`](../../labs/07_vr_engineering/README.md)
* [`Systemtests/Auswertung_VR_Startlogs_20261128_0736.md`](../../Systemtests/Auswertung_VR_Startlogs_20261128_0736.md)
* [`assetto-corsa-content/docs/03_agenten_system/rollen-terminals-pitwall-umsetzung.md`](../../../assetto-corsa-content/docs/03_agenten_system/rollen-terminals-pitwall-umsetzung.md)

</details>

<details>
<summary><b>Chips &amp; Kernaussagen</b></summary>

`Labs 06 &amp; 07` · `7 Fachrubriken` · `10+10 Tasks statt 32` · `-ClientMode Direktstart` · `79 Altlasten entfernt` · `26 Backups archiviert` · `D3 AgentTerminal_General aktiv` · `.kn5 Integrity Gate` · `OK=13 VR-Invarianten`

- **Merksatz 1:** Alle Agenten-Terminals starten direkt im `-ClientMode` ohne rekursive SSH-Schleifen; Host-Aufträge laufen über [`Send-SimAgentTask.ps1`](../../labs/Send-SimAgentTask.ps1) statt über entfernte Legacy-Wrapper (`Invoke-DarkAgent.ps1`, `Invoke-RigAgent.ps1`, `Invoke-SimAgentSsh.ps1`).
- **Merksatz 2:** `DOKU-MINIMAP` und Link-Checks halten `git-labor/Doku/` und `assetto-corsa-content/docs/` konsistent auf dem `7`-Rubriken-Stand.

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
