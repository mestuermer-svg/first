# Lehrmaterial & Architektur-Dokumentation: KI-Agenten, SimRacer & Docker-Sandbox

Dieses Verzeichnis bündelt alle technischen Analysen, Architektur-Übersichten und Praxisanleitungen für das Zusammenspiel aus **VanstrikeCyborg (Engineering-Laptop)**, **SimRacer (Simulations- & Compute-Workstation)**, **VS Code KI-Agenten (Copilot, Gemini, Antigravity)** und der **Docker-Windows-11-Sandbox**.

---

<details>
<summary><h2>1. KI-Agenten, Localhost-Proxy & Git-Architektur</h2></summary>

* **[Architektur-Übersicht: VS Code Agent, Localhost-Proxy, Gemini & Antigravity](./uebersicht-vscode-agent-localhost-gemini-antigravity.md)**
  * Erklärt das Zusammenspiel zwischen lokalem VS Code, dem `cli-proxy-api.exe` Localhost-Endpunkt, den lokalen MCP-Servern (`127.0.0.1:13508`) und den Cloud-Sprachmodellen (Gemini / Antigravity).
  * Beinhaltet die Erklärung zur zweigeteilten Speicherung des Git-Repositorys auf der lokalen SSD (Klartext-Arbeitsverzeichnis vs. komprimierte/Hash-codierte `.git`-Datenbank).

</details>

<details>
<summary><h2>2. Backup & System-Wiederherstellung (SimRacer)</h2></summary>

* **[Praxisanleitung: System-Image & Wiederherstellung (Veeam Agent Free) für SimRacer](./simracer-system-backup-wiederherstellung-veeam.md)**
  * Schritt-für-Schritt-Anleitung für ein schlankes, bootfähiges Windows-11-Systemabbild (25–40 GB) inklusive aller Treiber (NVIDIA RTX 5070 Ti, Fanatec, HTC VIVE Focus Vision).
  * Ausschluss der großen Steam-Spiele (`steamapps\common`) und Bare-Metal-Recovery via USB-Rettungsstick in 10–15 Minuten.

</details>

<details>
<summary><h2>3. Multi-PC-Topologie & Hardware-Analysen</h2></summary>

* **[Multi-PC-Architektur & Einsatzkonzept: KI-Agents, Simulation & Entwicklung](./multi-pc-architektur-ki-agents-simracing.md)**
  * Gegenüberstellung von *VanstrikeCyborg* (MSI Cyborg 15) und *SimRacer* (Ryzen 9 3900X, 32 GB RAM, RTX 5070 Ti).
  * Drei strategische Betriebsmodelle (u. a. „PG & Leitstand“ nach Vorbild der industriellen Automatisierungstechnik).
* **[Technische Hardware- und Stabilitätsanalyse: Docker-Sandbox, KI-Agenten & Sim-Setup](./hardware-analyse-system-stabilitaet-docker-ki.md)**
  * Detailbewertung von CPU, RAM-Flaschenhals (16 GB vs. 32 GB), GPU und NVMe-SSD sowie Dokumentation der NVIDIA App MCP-Integration.

</details>

<details>
<summary><h2>4. Docker-Windows-Sandbox & Assetto Corsa Planung</h2></summary>

* **[Docker Windows-11 Sandbox: Steam & KI-Agenten-Architektur](./docker-windows-steam-ki-agent-architektur.md)**
  * Technische Funktionsweise von `dockurr/windows` (QEMU/KVM), Steam-Ausführung im Container und Anbindung von KI-Agenten via OpenSSH, MCP-Worker oder Shared Folder.
* **[Projektplanung, Umsetzungs-Logbuch & Master-Checkliste: Assetto Corsa & Container-Infrastruktur](./planing.md)**
  * Technische Spezifikation für **Sarah Coach** (`sarah_targets.json`), Pitfile-Optimizer (`.ini`) und die 3-stufige Agent-Fokus-Steuerung (`ENGINEERING`, `LIVE_RACE`, `PITBOX_SETUP`).
  * Enthält das **aktuelle Umsetzungs-Logbuch (erledigte Meilensteine am SimRacer `192.168.178.68`)** sowie die **Master-Checkliste für alle nächsten Arbeitsschritte**.

</details>
