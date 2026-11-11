# Technische Hardware- und Stabilitätsanalyse: Docker-Sandbox, KI-Agenten & Sim-Setup

<details>
<summary><h2>1. Systemübersicht & Ausgangslage</h2></summary>

Die vorliegende Analyse bewertet die Stabilität und Praxistauglichkeit des MSI Cyborg 15 (B2RWFKG) für den Parallelbetrieb von Visual Studio Code, lokalen KI-Agenten (Antigravity/Copilot), MCP-Servern sowie einer virtualisierten Windows-11-Sandbox unter Docker.

<details>
<summary><h3>1.1 Hardware-Kenndaten des Host-Systems</h3></summary>

* **Modell:** MSI Cyborg 15 B2RWFKG
* **Prozessor:** Intel Core 7 240H (10 Kerne / 16 Threads, Basistakt 2.50 GHz, Turbotakt bis zu 5.20 GHz)
* **Arbeitsspeicher:** 16 GB DDR5-5600 Dual-Channel (2x 8 GB Kingston MSI56S46BS6MD-8KM)
* **Grafikkarte:** NVIDIA GeForce RTX 5060 Laptop GPU (8 GB GDDR7 VRAM, TGP 55 W) + Intel Graphics
* **Massenspeicher:** 1 TB NVMe SSD (Sandisk PC SN5000S, ~160 GB frei von 954 GB) + externe HDD
* **Betriebssystem:** Windows 11 Home 64-Bit (Version 26H2, Build 26300.9711)
* **Virtualisierungsbasis:** Windows Subsystem for Linux (WSL2 Version 3.0.3.0) mit Docker Desktop

</details>

<details>
<summary><h3>1.2 Parallele Systemlast (Das Betriebsszenario)</h3></summary>

Im Arbeitsbetrieb greifen vier ressourcenintensive Ebenen gleichzeitig auf dieselbe Hardware zu:
1. **Windows 11 Host:** Grundbetriebssystem, Treiber, Hintergrunddienste, MSI Center.
2. **Entwicklungsumgebung:** VS Code, CLI-Proxy (`cli-proxy-api.exe`), Sprachserver und mehrere MCP-Server (Filesystem, Chrome DevTools, Search, NVIDIA).
3. **Virtualisierungsschicht:** WSL2-Subsystem (`vmmemWSL`) und Docker Desktop Engine.
4. **Gast-System (Sandbox):** Ein vollständiges Windows 11 (`dockurr/windows`) mit KVM/QEMU-Emulation, Portweiterleitungen (8006/3389) und geteilten Ordnern für Assetto Corsa & Content Manager.

</details>

</details>

<details>
<summary><h2>2. Detaillierte Komponenten- und Stabilitätsanalyse</h2></summary>

<details>
<summary><h3>2.1 Prozessor (CPU): Intel Core 7 240H</h3></summary>

* **Bewertung:** **Sehr hohe Leistungsreserve / Vollständig stabil.**
* **Details:**
  * Die moderne Hybrid-Architektur (Performance- und Efficient-Cores) ist ideal für Virtualisierungsaufgaben geeignet.
  * Unterstützt hardwareseitig Intel VT-x und verschachtelte Virtualisierung (Nested Virtualization).
  * Bei einer typischen Allokation von 4 vCPUs für den Windows-11-Container verbleiben 6 physische Kerne exklusiv für Host-Tasks, VS Code und die KI-Modellverarbeitung. CPU-Engpässe sind unter normalen Betriebsbedingungen ausgeschlossen.

</details>

<details>
<summary><h3>2.2 Arbeitsspeicher (RAM): 16 GB DDR5-5600 (Kritischer Pfad)</h3></summary>

* **Bewertung:** **Funktionsfähig, stellt jedoch den primären Flaschenhals dar.**
* **Reale Lastverteilung im Regelbetrieb:**
  * Host-Betriebssystem & Windows-Dienste: ca. 5.0 – 6.0 GB
  * VS Code + Copilot/Antigravity + Node/MCP-Dienste: ca. 2.0 – 3.0 GB
  * WSL2 Virtual Machine (`vmmemWSL`): ca. 2.5 – 4.0 GB
  * Windows-11-Sandbox (`ac-win11-sandbox`): **6.0 GB** (gemäß Voreinstellung `docker-compose.yml`)
* **Konsequenz:**
  * Der kumulierte Speicherbedarf übersteigt bei Spitzenlast die physischen 16 GB.
  * Windows weicht in diesem Fall auf die Auslagerungsdatei (Pagefile auf der NVMe-SSD) aus. Zwar ist die NVMe-SSD schnell, Speicher-Swapping führt jedoch bei Virtualisierung und Inbetriebnahmesimulationen zu spürbaren Mikrorucklern und verlangsamten I/O-Reaktionszeiten.

</details>

<details>
<summary><h3>2.3 Grafikkarte (GPU): NVIDIA GeForce RTX 5060 Laptop (8 GB GDDR7)</h3></summary>

* **Bewertung:** **Exzellente Leistung für Host & KI-Inferenz.**
* **Details:**
  * Mit 8 GB schnellem GDDR7-Speicher und dedizierten Tensor-Kernen eignet sich die GPU hervorragend für lokale Inferenz, CUDA-Berechnungen und die Darstellung anspruchsvoller Simulationen.
  * In der virtuellen Docker-Maschine (`dockurr/windows`) erfolgt das Rendering vorwiegend über die QEMU-Software/VirtIO-Schnittstelle. Für den Host und native Tests steht die volle GPU-Bandbreite verzögerungsfrei zur Verfügung.

</details>

<details>
<summary><h3>2.4 Massenspeicher (NVMe SSD): Sandisk SN5000S 1 TB</h3></summary>

* **Bewertung:** **Geschwindigkeit exzellent, Füllstand erfordert Beachtung.**
* **Details:**
  * Hohe Lese- und Schreibgeschwindigkeiten gewährleisten schnelle Container-Bootzeiten und zügiges Laden von VM-Images.
  * Aktueller Stand: 793 GB belegt (~160 GB frei).
  * Da die Windows-11-Sandbox mit Basissystem, virtuellem Laufwerk (`storage`) und temporären Downloads ca. 30–60 GB beansprucht, sollte der freie Speicherplatz nicht unter 100 GB absinken, um SSD-Wear-Leveling und thermisches Drosseln zu vermeiden.

</details>

</details>

<details>
<summary><h2>3. Praxisorientierte Handlungsempfehlungen</h2></summary>

<details>
<summary><h3>3.1 Sofortmaßnahmen (Software-Konfiguration)</h3></summary>

1. **Sandbox-RAM-Deckelung anpassen:**
   * In der Konfigurationsdatei `C:\Users\strik\git-labor\ac-sandbox\docker-compose.yml` die RAM-Zuweisung von `RAM: "6G"` temporär auf `RAM: "4G"` reduzieren.
   * *Effekt:* Die Gast-Windows-11-Instanz läuft für Diagnose-, Skript- und Konfigurationsarbeiten weiterhin flüssig, entlastet aber den Host sofort um 2 GB physischen Arbeitsspeicher.
2. **Ressourcenfresser vor Inbetriebnahmeläufen beenden:**
   * Ungenutzte Anwendungen mit hoher Speicherauslastung (z. B. Chrome mit vielen Tabs, Steam-Downloads, Discord) vor dem Start des Docker-Stacks schließen.
3. **Host-Leistungsprofil beibehalten:**
   * Das in den Systemeigenschaften hinterlegte Profil *„Höchstleistung / Extreme Performance (Turbo)“* sichert kontinuierliche Taktraten für die Virtualisierungsschicht.

</details>

<details>
<summary><h3>3.2 Zukunftsoption: Hardware-Upgrade (32 GB RAM)</h3></summary>

* **Potenzial:**
  * Das MSI Cyborg 15 verfügt über zwei zugängliche SO-DIMM-DDR5-Steckplätze.
  * Ein Austausch der 2x 8 GB Riegel gegen ein Kit mit 2x 16 GB DDR5-5600 (gesamt 32 GB) behebt die Speicherengpässe vollständig.
  * Damit können der Sandbox dauerhaft 8 GB RAM zugewiesen werden, während dem Host komfortable 16+ GB für Entwicklung, Sim-Tools und Browser zur Verfügung stehen.

</details>

</details>

<details>
<summary><h2>4. Dokumentation der MCP-Konfiguration (NVIDIA App)</h2></summary>

Zur Einbindung des Streamable HTTP MCP-Servers der NVIDIA App (`NvAppMcpServer.exe`) auf Port `13508` wurden die entsprechenden Konfigurationen systemweit hinterlegt:

<details>
<summary><h3>4.1 Angepasste Konfigurationsdateien</h3></summary>

* **VS Code Benutzer-MCP:** `C:\Users\strik\AppData\Roaming\Code\User\mcp.json`
* **GitHub Copilot Agent MCP:** `C:\Users\strik\.copilot\mcp-config.json`
* **Google Antigravity / Gemini MCP:** `C:\Users\strik\.gemini\config\mcp_config.json`

```json
"nvidia-app": {
  "type": "http",
  "url": "http://127.0.0.1:13508/mcp"
}
```

Die Binärdatei ist unter `C:\Program Files\NVIDIA Corporation\NVIDIA App\McpServer\NvAppMcpServer.exe` verifiziert. Sobald die NVIDIA App den Port 13508 öffnet, greifen alle Agenten und VS-Code-Instanzen automatisch darauf zu.

</details>

</details>

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
details.doku-minimap { position: fixed; bottom: 18px; right: 18px; z-index: 9999; width: 265px; max-height: 76px; overflow: hidden; background: rgba(15, 23, 42, 0.94); border: 1px solid rgba(96, 165, 250, 0.65); border-radius: 10px; box-shadow: 0 8px 26px rgba(0, 0, 0, 0.65); backdrop-filter: blur(8px); transition: width 0.18s ease, max-height 0.18s ease; font-family: var(--vscode-font-family, sans-serif); }
details.doku-minimap:hover { border-color: #60a5fa; }
details.doku-minimap[open] { width: min(880px, 94vw); max-height: 84vh; overflow-y: auto; padding-bottom: 10px; }
details.doku-minimap > summary { cursor: pointer; list-style: none; padding: 8px 12px; font-weight: 700; font-size: 0.84em; color: #f8fafc; background: linear-gradient(90deg, rgba(37, 99, 235, 0.45), rgba(30, 41, 59, 0.9)); border-bottom: 1px solid rgba(148, 163, 184, 0.25); display: flex; align-items: center; justify-content: space-between; user-select: none; }
details.doku-minimap > summary::-webkit-details-marker { display: none; }
details.doku-minimap .minimap-preview-strip { display: flex; gap: 4px; padding: 5px 10px 7px 10px; font-size: 0.72em; color: #94a3b8; justify-content: space-between; }
details.doku-minimap[open] .minimap-preview-strip { display: none; }
details.doku-minimap .minimap-preview-strip span { background: rgba(30, 41, 59, 0.9); padding: 2px 6px; border-radius: 4px; border: 1px solid rgba(148, 163, 184, 0.25); }
details.doku-minimap .minimap-body { padding: 8px 12px 4px 12px; }
</style>
<details class="doku-minimap">
<summary><span>🏎️ AC-Doku-Minimap (SimRacer &amp; Sandbox)</span><span title="Klicken zum Vergrößern / Einklappen">⛶</span></summary>
<div class="minimap-preview-strip"><span>01 SimRacer</span><span>02 Sandbox</span><span>03 Agenten</span><span>04 AC-Sync</span></div>
<div class="minimap-body">
<div class="doku-arch-flow">
<div class="doku-arch-root">🏎️ <a href="../README.md">Assetto Corsa Content &amp; SimRacer Architektur (Doku-Index)</a>  |  <a href="../../README.md">Repo-README</a>  |  <a href="../../ac-sandbox/README.md">AC-Sandbox</a></div>
<div class="doku-arch-grid">
<div class="doku-arch-card r1">
<div class="doku-arch-card-title">🖥️ <a href="multi-pc-architektur-ki-agents-simracing.md">01_simracer_architektur (Hardware &amp; 4-PC-Netz)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="multi-pc-architektur-ki-agents-simracing.md">01 • 4-Knoten-Architektur (SimRacer, Cyborg, Omarchy, Pi)</a></li>
<li>├─ <a href="hardware-analyse-system-stabilitaet-docker-ki.md">02 • Hardware- &amp; Stabilitätsanalyse (Docker, KI &amp; VR)</a></li>
<li>├─ <a href="simracer-system-backup-wiederherstellung-veeam.md">03 • System-Backup &amp; Recovery (Veeam + Sekunden-Backup)</a> <a class="doku-arch-badge" href="../../ac-sandbox/backup-simracer-configs.ps1">Backup.ps1</a></li>
<li>└─ <a href="naechste-schritte-simracer-und-cyborg.md">04 • Roadmap &amp; Nächste Schritte (SimRacer &amp; Cyborg)</a></li>
</ul>
</div>
<div class="doku-arch-card r2">
<div class="doku-arch-card-title">🐳 <a href="../02_docker_sandbox/SANDBOX_ANLEITUNG.md">02_docker_sandbox (ac-win11-sandbox &amp; sbx)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../02_docker_sandbox/SANDBOX_ANLEITUNG.md">01 • Handbuch: Remote Windows-11-Sandbox (192.168.178.68)</a> <a class="doku-arch-badge" href="../../ac-sandbox/start-sandbox.ps1">Start.ps1</a></li>
<li>├─ <a href="../02_docker_sandbox/inside-the-simracing-sandbox-guide.md">02 • Inside the SimRacing Sandbox &amp; Dark-Agent-Betrieb</a></li>
<li>├─ <a href="../02_docker_sandbox/docker-windows-steam-ki-agent-architektur.md">03 • Prüflabor für Content Manager, Pitfiles (.ini) &amp; KI</a></li>
<li>├─ <a href="../02_docker_sandbox/sandbox-umzug-skalierung-simracer.md">04 • 64-GB Sandbox-Umzug &amp; Skalierung auf 160 GB</a></li>
<li>└─ <a href="../02_docker_sandbox/docker-sbx-anleitung.md">05 • Docker Sandboxes CLI (sbx)</a> · <a href="../02_docker_sandbox/docker.md">Coding Agent Sandbox</a></li>
</ul>
</div>
<div class="doku-arch-card r3">
<div class="doku-arch-card-title">🤖 <a href="../03_agenten_system/agenten-system-architektur-uebersicht.md">03_agenten_system (5-Rollen-Verbund &amp; REPL)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../03_agenten_system/agenten-system-architektur-uebersicht.md">01 • KI-Agenten-Systemarchitektur &amp; 5-Rollen-Handbuch</a></li>
<li>├─ <a href="../03_agenten_system/agenten-konsolen-repl-autostart-und-asset-handshake.md">02 • Agenten-Konsolen (REPL), Auto-Start &amp; Handshake</a> <a class="doku-arch-badge" href="../../ac-sandbox/shared/agents/README.md">Shared-Agents</a></li>
<li>├─ <a href="../../.github/agents/general.agent.md">Ebene 1: @general</a> · <a href="../../.github/agents/light.agent.md">Ebene 2: @light</a> · <a href="../../.github/agents/rig.agent.md">@rig</a></li>
<li>└─ <a href="../../.github/agents/dark.agent.md">Ebene 3 (Gast): @dark</a> · <a href="../../.github/agents/sarah.agent.md">Pitwall: @sarah (Coach)</a></li>
</ul>
</div>
<div class="doku-arch-card r4">
<div class="doku-arch-card-title">⚙️ <a href="../../ac-sandbox/LIGHT-AGENT-UND-AC-STRUKTUR.md">04_ac_sandbox_sync (7-Pakete, Presets &amp; Skripte)</a></div>
<ul class="doku-arch-lines">
<li>├─ <a href="../../ac-sandbox/LIGHT-AGENT-UND-AC-STRUKTUR.md">01 • Light Agent Anweisungen &amp; 7-Pakete AC-Struktur</a> <a class="doku-arch-badge" href="../../ac-sandbox/shared/scripts/sync-cm-github.ps1">Sync.ps1</a></li>
<li>├─ <a href="../../ac-sandbox/README.md">02 • AC-Sandbox Ordnerstruktur &amp; Bootstrap-Ablauf</a> <a class="doku-arch-badge" href="../../ac-sandbox/shared/scripts/bootstrap-guest.ps1">Bootstrap.ps1</a></li>
<li>├─ <a href="../../ac-sandbox/shared/presets_managed/README.md">03 • Managed Settings-Profile (Desktop vs. VR / CSP)</a></li>
<li>└─ <a href="../../ac-sandbox/LIVE-TRANSFER-STATUS.md">04 • Live-Transfer-Status</a> · <a href="../../ac-sandbox/shared/cm-github-sync/03_CM_AppData_Presets_Data/Data/README.md">CM AppData &amp; Presets</a></li>
</ul>
</div>
</div>
</div>
</div>
</details>
<!-- DOKU-MINIMAP-END -->
