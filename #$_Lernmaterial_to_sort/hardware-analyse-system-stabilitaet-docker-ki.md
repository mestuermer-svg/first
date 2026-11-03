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
