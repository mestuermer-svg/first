> **Thema:** Konsolidierte MCP-Server, Ollama (`:11434`), Port-Architektur &amp; Archiv entfernter Proxy-Altlasten in VS Code
> **Autor:** Michael Stürmer
> **Datum:** 24.11.2026 *(Altlasten-Abgleich, Qwen 3.5 &amp; Single-Source-of-Truth)*

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (02 VS Code & MCP)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 02 VS Code & MCP](./README.md) · **Vorheriges:** [⬅️ 02 • Git, GitHub Workflow & Multi-Root Workspaces](./02_git-github-und-multi-root-workspaces.md) · **Nächstes:** [04 • Gemini Ökosystem, Google AI Studio & API-Keys ➡️](./04_gemini-oekosystem-ai-studio-und-api-keys.md)

**Alle Module in `02_VSCode_Env/`:**
- [01 • VS Code Architektur, Sprachserver (LSP) & Remote](./01_vscode-architektur-lsp-und-remote.md)
- [02 • Git, GitHub Workflow & Multi-Root Workspaces](./02_git-github-und-multi-root-workspaces.md) · `Workspace`
- 👉 **[03 • MCP-Server, Ollama (:11434) & Ports (Archiv: Proxy)](./03_mcp-server-localhost-proxy-und-ports.md)** *(aktuell)* · `mcp.json`
- [04 • Gemini Ökosystem, Google AI Studio & API-Keys](./04_gemini-oekosystem-ai-studio-und-api-keys.md)
- [05 • 5-Knoten-Verbund, Parity & Parallel-Limits](./05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md)

**Weitere Rubriken:** [🐧 01 Linux & Bash](../01_Linux_Bash/README.md) · [🐍 03 Python](../03_Python_Coding/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md) · [🤖 05 Agents](../05_Agents/README.md) · [🏎️ 06 AC KN5 Modding](../06_AC_KN5_Modding/README.md) · [🥽 07 VR Engineering](../07_VR_Engineering/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

<details>
<summary><b>Lernziele</b></summary>

* Die **ToS-konforme Hybrid-Architektur** verstehen: Lokale LLM-Inferenz über **Ollama (`:11434`)** auf `VanstrikeCyborg` und `SimRacer` sowie offizielle Cloud-SDKs (`google-genai`, `@google/genai`, Vertex AI ADC) und lokale/remote **MCP-Server**.
* Die **aktuelle Port-Zuordnung** sicher beherrschen (**`11434`** Ollama, **`8317`** legitimer Google Antigravity IDE Hub `agy.exe`, **`13508`** NVIDIA App MCP, **`8080`** StrikerPi Pitwall Hub).
* Die **bereinigte MCP-Single-Source-of-Truth** (`4` globale Server in `User/mcp.json` + `2` exklusive Workspace-Server in `.vscode/mcp.json`) von den am **23.11.2026 entfernten Proxy-Altlasten** (`CLIProxyAPI`, `llm-gateway` `:8420`, `mcp_proxy.js`) abgrenzen und typische MCP-Fehler diagnostizieren können.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Aktuelle Architektur: Ollama (:11434), offizielle SDKs &amp; konsolidierte MCP-Server (Stand: 24.11.2026)</summary>

In der bereinigten Entwicklungsumgebung auf `VanstrikeCyborg` und `SimRacer` greifen lokale GPUs, offizielle Cloud-APIs und verschlankte MCP-Werkzeuge direkt ohne inoffizielle Drittanbieter-Proxys ineinander:

```mermaid
flowchart TD
    subgraph Cloud ["Offizielle Cloud / KI-Backends"]
        GEM["Google Vertex AI / Gemini API<br/>(Projekt: gen-lang-client-0668043276, europe-west3)"]
        COP["GitHub Copilot (nativ / integrierter GitHub-MCP)"]
        GDOCS["Gemini Docs MCP (https://gemini-api-docs-mcp.dev)"]
        MSDOCS["Microsoft Learn MCP (https://learn.microsoft.com/api/mcp)"]
    end

    subgraph Localhost ["Lokale Knoten (Cyborg 127.0.0.1 &amp; SimRacer 192.168.178.68)"]
        VSC["VS Code + Google Antigravity + Gemini Code Assist"]
        OLL_L["Ollama Laptop (127.0.0.1:11434)<br/>qwen3.5:4b, gemma4:e4b (RTX 5060 8 GB)"]
        OLL_S["Ollama SimRacer (192.168.178.68:11434)<br/>qwen3.5:9b, gemma4:12b, qwen2.5-coder:14b (RTX 5070 Ti 16 GB)"]
        AGY["Antigravity IDE Hub (agy.exe)<br/>Port 8317 (Cyborg) / 0 (SimRacer)"]

        subgraph MCP ["Konsolidierte MCP-Server (4 Global Cyborg / 5 Global SimRacer + 2 Workspace)"]
            CDT["chrome-devtools-mcp (npx stdio)"]
            MKD["markitdown-mcp (uvx stdio, Cyborg &amp; SimRacer)"]
            FS["local-workspace-filesystem (Workspace)"]
            GSEARCH["google-ai-search-mcp (Workspace, Cyborg)"]
            NV["NVIDIA App MCP (http://127.0.0.1:13508/mcp, SimRacer)"]
        end
    end

    VSC <-->|"Native Ollama API"| OLL_L
    VSC <-->|"LAN Ollama API"| OLL_S
    VSC <-->|"Offizielles SDK / OAuth"| GEM
    VSC <-->|"HTTP MCP"| GDOCS
    VSC <-->|"HTTP MCP"| MSDOCS
    VSC -->|"stdio"| CDT
    VSC -->|"stdio"| FS
    VSC -->|"stdio"| GSEARCH
```

</details>

<details>
<summary>1.2 Aktuelle Ports &amp; bereinigte MCP-Konfigurationsdateien (Single Source of Truth)</summary>

| Port / Typ | Dienst / Komponente | Host / Protokoll | Zweck &amp; Aktueller Status (24.11.2026) |
| :--- | :--- | :--- | :--- |
| **Port `11434`** | **Ollama Server (`ollama.exe`)** | `127.0.0.1` (Cyborg) &amp; `0.0.0.0` (SimRacer) | Primärer lokaler &amp; LAN-LLM-Endpunkt (`qwen3.5:4b`, `gemma4:e4b` bzw. `qwen3.5:9b`, `gemma4:12b`, Legacy `qwen2.5-coder:14b`) als Ersatz für alle entfernten Proxy-Gateways. |
| **Port `8317`** | **Google Antigravity Hub (`agy.exe`)** | `127.0.0.1` (Cyborg; `0` = dynamisch auf SimRacer) | Legitimer `antigravity.serverPort` der offiziellen `google.google-antigravity` Extension (**nicht** mehr `CLIProxyAPI`). |
| **Port `13508`** | **NVIDIA App MCP (`NvAppMcpServer.exe`)** | `127.0.0.1` HTTP (`/mcp`) | Auf SimRacer aktiv in Global `mcp.json`; auf Cyborg entfernt (dort `0` aktive Tools). |
| **Port `8080`** | **StrikerPi Pitwall Hub (`telemetry_relay.py`)** | `192.168.178.86` HTTP / WS | Live-Telemetrie, Lobby-Streams, Sandbox-Steuerung, **Agenten &amp; Light Steuerungskonsole** + **Antigravity Sprachchat-Button**. |
| **HTTPS Remote** | **Gemini Docs (`geminiDocs`) &amp; Microsoft Learn** | Streamable HTTP | Globale Referenz-MCP-Server in `User\mcp.json` auf beiden Knoten. |
| **`stdio` Lokal** | **`chrome-devtools`, `markitdown`, `local-workspace-filesystem`, `google-ai-search-mcp`** | Standard I/O (`npx` / `uvx`) | `chrome-devtools` &amp; `markitdown` global auf beiden PCs (`uvx 0.13.9` auf SimRacer nachgezogen); `local-workspace-filesystem` &amp; `google-ai-search-mcp` exklusiv im Workspace. |

### Konsolidierte Speicherorte der MCP- &amp; Provider-Konfigurationen (Stand: 24.11.2026):
1. **VS Code Global User-MCP (`VanstrikeCyborg`):** `C:\Users\strik\AppData\Roaming\Code\User\mcp.json` (`4` Server: `geminiDocs`, `microsoft-learn`, `chrome-devtools`, `markitdown`)
2. **VS Code Global User-MCP (`SimRacer`):** `C:\Users\Mike\AppData\Roaming\Code\User\mcp.json` (`5` Server: `geminiDocs`, `nvidia-app`, `microsoft-learn`, `chrome-devtools`, `markitdown` via `uvx 0.13.9`)
3. **VS Code Workspace-MCP (`git-labor`):** `C:\Users\strik\git-labor\.vscode\mcp.json` (`2` Server: `local-workspace-filesystem`, `io.github.shariqriazz/google-ai-search-mcp`)
4. **VS Code Workspace-MCP (`ac-sandbox` auf SimRacer):** `C:\ac-sandbox\.vscode\mcp.json` (`1` exklusiver Server: `local-workspace-filesystem`)
5. **Bereinigte Alt-Dateien &amp; Ollama Single-Source-of-Truth (`chatLanguageModels.json`):** `git-labor\.mcp.json` (`{ "mcpServers": {} }`), `assetto-corsa-content\.vscode\mcp.json` (`{ "servers": {} }`). In `C:\Users\strik\AppData\Roaming\Code\User\chatLanguageModels.json` bleibt ausschließlich **`Ollama (SimRacer RTX 5070 Ti)`** (`http://192.168.178.68:11434`) eingetragen — `127.0.0.1:11434` kommt einmalig über `"ollama.endpoint"` in `settings.json`, um doppelte Modelleinträge im Dropdown zu vermeiden.

</details>

<details>
<summary>1.3 Fallstudie: NVIDIA App MCP-Server Timeout (Fehlercode <code>-2147467259</code>)</summary>

* **Symptom:** Beim Aktivieren von *„Agent-Zugriff“* in der NVIDIA App springt der Schalter nach ~10 Sekunden mit `MCP server did not become ready in time` zurück.
* **Ursache:** Der Dienst `NvContainerLocalSystem` hatte wegen eines verwaisten Plugin-Ordners aufgehört, das Verzeichnis `C:\Program Files\NVIDIA Corporation\NvContainer\plugins\AIUser` zu überwachen. Dadurch wurde `McpServerPlugin.dll` nicht geladen und die Named Pipe `\\.\pipe\nvidia-nvapp-mcp-server-...` fehlte.
* **Schnellbehebung &amp; Prüfung:**
  ```powershell
  # 1. NVIDIA Container-Dienst neu starten
  Restart-Service NvContainerLocalSystem

  # 2. Prüfen, ob die Named Pipe aktiv ist oder Port 13508 lauscht
  [System.IO.Directory]::GetFiles("\\.\\pipe\\") | Where-Object { $_ -match "nvapp-mcp" }
  Get-NetTCPConnection -LocalPort 13508 -State Listen -ErrorAction SilentlyContinue
  ```

</details>

<details>
<summary>1.4 Fallstudie: <code>github-mcp-server</code> nativ / Copilot-integriert statt über Docker betreiben</summary>

* **Symptom:** `open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.`
* **Ursache:** Der `github-mcp-server` war früher als Docker-Container (`docker run ... ghcr.io/github/github-mcp-server`) konfiguriert. Wenn Docker Desktop nicht läuft, schlägt der Start sofort fehl.
* **Aktuelle Lösung:** In VS Code läuft GitHub MCP direkt integriert über `github.copilot.chat.githubMcpServer.enabled: true` (`lockdown: true`, `readonly: true`); für externe CLI-Clients startet `C:\Users\strik\.local\bin\github-mcp-server.exe` nativ über `stdio` mit ~25 MB RAM statt 2–4 GB für Docker Desktop.

</details>

<details>
<summary>1.5 🗄️ Archiv: Entfernte Altlasten – <code>CLIProxyAPI</code>, <code>llm-gateway</code> &amp; Port-8000-Kollision ([ENTFERNT am 23.11.2026])</summary>

> [!NOTE]
> **Status: `[ENTFERNT / ARCHIVIERT – 23.11.2026]`** — Die folgenden Komponenten wurden vollständig aus VS Code, Workspaces und Startskripten entfernt (ToS-Compliance &amp; Übergang zu nativem Ollama `:11434`). Dieser Abschnitt dient nur noch der historischen Fehler-Referenz.

* **`CLIProxyAPI` (`cli-proxy-api.exe`) auf `:8317` und `github.copilot.llm-gateway.serverUrl` (`:8317` / `:8420`):** Durch Ollama (`:11434`) sowie offizielle Cloud-Provider (`google-genai`, Vertex AI ADC, offizielle Extensions) ersetzt. Alle zugehörigen Keys (`antigravityCopilot.*`, `llm-gateway.*`, `acpHub.*`, `oaicopilot.models`, `customLlm.models`) sowie **`mcp_proxy.js`** und insgesamt **26** Proxy-/Wrapper-Extensions (`settingsSync.ignoredExtensions`) wurden entfernt und blockiert.
* **Historische Fallstudie (`Unexpected token '&lt;'` bei Port `8000` vs. `8317`):** Tratt auf, wenn ein früheres LLM-Gateway fälschlicherweise `http://localhost:8000` (HTML-UI) statt einer JSON-REST-API abfragte. Prüfbefehl für Portkonflikte heute:
  ```powershell
  Get-NetTCPConnection -LocalPort 11434,8317,13508 -State Listen -ErrorAction SilentlyContinue | Format-Table LocalAddress, LocalPort, State, OwningProcess
  Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags"
  ```

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Ollama vs. Cloud-Endpunkt prüfen:** Verifiziere mit `Invoke-RestMethod http://127.0.0.1:11434/api/tags` und `http://192.168.178.68:11434/api/tags`, welche Modelle lokal vs. im LAN aktiv sind.
2. **Single Source of Truth prüfen:** Kontrolliere, warum alle globalen MCP-Server zentral in `AppData\Roaming\Code\User\mcp.json` liegen und nicht mehr in jeder `.code-workspace`-Datei dupliziert werden.
3. **MCP-Neustart:** Über welchen Befehl in der VS Code Befehlspalette (`Strg + Shift + P`) kannst du alle aktiven MCP-Server auflisten, deren Logs einsehen und einen Server gezielt neu starten (`MCP: List Servers`)?

</details>

<details>
<summary><b>Weiterführende Links &amp; Quellen</b></summary>

* [Model Context Protocol (MCP) Offizielle Spezifikation](https://modelcontextprotocol.io/)
* [VS Code Copilot MCP Server Dokumentation](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
* [Gemini Docs MCP Server (`gemini-api-docs-mcp.dev`)](https://aistudio.google.com/docs/coding-agents#mcp-setup)
* [Ollama REST API Dokumentation](https://github.com/ollama/ollama/blob/main/docs/api.md)

</details>

<details>
<summary><b>Chips &amp; Kernaussagen</b></summary>

* **Ollama `:11434` statt Proxy `:8317`/`llm-gateway`:** Inoffizielle OAuth-/LLM-Gateways sind seit dem **23.11.2026** entfernt und archiviert; lokal rechnet Ollama, in der Cloud das offizielle Google SDK (`Vertex AI ADC`).
* **Single Source of Truth (`4 + 2` MCP-Server):** `4` globale Server in `User/mcp.json`, exklusive Repo-Server in `.vscode/mcp.json` — keine Dubletten in `.code-workspace` oder `.mcp.json`.
* **Port `8317` gehört `agy.exe` (`antigravity.serverPort`):** Nach der Bereinigung vom **28.11.2026** auf Cyborg und SimRacer einheitlich auf `0` (dynamischer Port, statt statischem `8317`-Konflikt) konfiguriert.
* **NVIDIA MCP läuft über `AIUser`-Container:** Fehlt die Named Pipe oder Port `13508`, behebt `Restart-Service NvContainerLocalSystem` den blockierten Watchdog.

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
