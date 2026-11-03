# Multi-PC-Architektur & Einsatzkonzept: KI-Agents, Simulation & Entwicklung

# Markdown heading
<details>
<summary><h2>1. Ausgangslage & Hardware-Gegenüberstellung</h2></summary>

Zur optimalen Verteilung von Rechenlasten, Entwicklungsaufgaben und Simulationsanwendungen stehen zwei dedizierte Windows-11-Systeme zur Verfügung:

<h1>Inline HTML heading</h1>
<details>
<summary><h3>1.1 Rechner 1: VanstrikeCyborg (Laptop / MSI Cyborg 15)</h3></summary>

* **CPU:** Intel Core 7 240H (10 Kerne / 16 Threads)
* **RAM:** 16 GB DDR5-5600 Dual-Channel
* **GPU:** NVIDIA GeForce RTX 5060 Laptop (8 GB GDDR7 VRAM, 55 W TGP)
* **Speicher:** 1 TB NVMe SSD (~160 GB frei)
* **Charakteristik:** Mobil, kompakt, energieeffizient. Ideal als flexibles Programmiergerät (PG) und Steuerungszentrale.

</details>

<details>
<summary><h3>1.2 Rechner 2: SimRacer (Desktop-Workstation)</h3></summary>

* **CPU:** AMD Ryzen 9 3900X (12 Kerne / 24 Threads, 3.80 – 4.20 GHz)
* **RAM:** 32 GB DDR4
* **GPU:** NVIDIA GeForce RTX 5070 Ti (16 GB GDDR7 VRAM, 256-Bit Bus, 8960 CUDA-Kerne)
* **Speicher:** 1 TB interne NVMe System-SSD (`C:`) + 1.8 TB externe USB-SSD (`D:`)
* **Peripherie:** HTC VIVE Focus Vision VR-Headset (DisplayPort, Dual 2.5K @ 120 Hz), Fanatec ClubSport V2.5 Wheel Base + Formula V2.0, 4K-Display (Hisense)
* **Charakteristik:** Massives Rechenkraftwerk mit doppelter Speicherkapazität, doppelter VRAM-Größe und enormer Multithreading-Leistung.

</details>

</details>

<details>
<summary><h2>2. Die drei strategischen Einsatzvarianten</h2></summary>

<details>
<summary><h3>Variante 1: Master-Worker-Verbund / „PG & Leitstand“ (Empfohlene Architektur)</h3></summary>

Dieses Modell entspricht dem bewährten Prinzip der industriellen Automatisierungstechnik (Klassische Trennung von **Programmiergerät/Engineering Station** und **Prozess-/Simulationsstation**):

* **VanstrikeCyborg (Laptop als Engineering Station):**
  * Hier läuft Visual Studio Code, die KI-Steuerung (Google Antigravity, Copilot, Gemini CLI), Versionsverwaltung (Git) und MCP-Server.
  * Sie programmieren, schreiben Prompts, erstellen Skripte und analysieren Logs flexibel (z. B. am Schreibtisch oder unterwegs).
* **SimRacer (Desktop als Compute & Simulation Node):**
  * Hier laufen die schweren Lasten: Docker Desktop, die Windows-11-Sandbox (`dockurr/windows`), Assetto Corsa, Content Manager und Telemetrie-Dienste.
  * Optional: Bereitstellung eines lokalen KI-Inferenz-Servers (z. B. Ollama oder vLLM), auf den der Laptop über das lokale Netzwerk via API zugreift (Nutzung der 16 GB VRAM der RTX 5070 Ti).
* **Verbindung:**
  * Git als Datensynchronisation oder direkte VS-Code-Anbindung über *Remote - SSH* bzw. geteilte Netzlaufwerke (SMB/Shared Folder).

* **Vorteile:**
  * Der Laptop bleibt thermisch leise, akkuschonend und seine 16 GB RAM sind zu 100 % für VS Code und Agenten frei (kein RAM-Kollaps durch Docker).
  * Der SimRacer nutzt seine 32 GB RAM, 24 CPU-Threads und 16 GB VRAM der 5070 Ti für performante Virtualisierung ohne Auslagerungsruckler.
* **Nachteile:**
  * Beide Rechner müssen im Betrieb eingeschaltet und im selben Netzwerk verbunden sein.

</details>

<details>
<summary><h3>Variante 2: Strikte Funktionstrennung (Coding-PC vs. Dedizierte Sim-Station)</h3></summary>

Komplette Entkopplung von Entwicklung und Fahrbetrieb:

* **VanstrikeCyborg (Laptop):**
  * Reine Entwicklungs-, Büro- und KI-Maschine.
  * Kleine lokale Tests, Skripterstellung, Dokumentation. Keine anspruchsvollen Virtualisierungsmaschinen im Dauereinsatz.
* **SimRacer (Desktop):**
  * Reine High-End-Simulations- und VR-Station.
  * Exklusiver Fokus auf Assetto Corsa in nativer Windows-Umgebung mit HTC VIVE Focus Vision (120 Hz DisplayPort-Modus) und Fanatec-Direct-Drive-Treiberpaket.
  * Fertige Skripte und Mods werden per Git/Netzwerk aufgespielt und dort ohne Virtualisierungsoverhead ausgeführt.

* **Vorteile:**
  * Maximale Bildraten, geringste Latenzen und null Ruckler im VR-Headset (keine Hintergrund-Container oder Agentenprozesse, die Lenkrad-FFB oder VR-Tracking stören).
  * Höchste Betriebssicherheit.
* **Nachteile:**
  * Der Laptop muss KI-Workloads und Entwicklungs-Tools alleine stemmen (16 GB RAM Grenze).
  * Die brachliegende Rechenpower des SimRacers wird nicht für Agenten genutzt, wenn nicht gefahren wird.

</details>

<details>
<summary><h3>Variante 3: SimRacer als autarker KI-Power-Tower (Standalone)</h3></summary>

Konsolidierung aller ressourcenintensiven Aufgaben auf der Desktop-Hardware:

* **SimRacer (Desktop):**
  * Führt alles auf einer Maschine aus: VS Code, Antigravity, Docker-Sandbox, lokale LLMs und Simulation.
* **VanstrikeCyborg (Laptop):**
  * Dient als mobile Backup-Station oder reines Anzeigeterminal (z. B. Remotedesktop/VNC auf den SimRacer).

* **Vorteile:**
  * Höchstmögliche Einzelrechner-Leistung, kein Netzwerk-Setup notwendig.
  * 32 GB RAM und 2.8 TB SSD bieten ausreichend Puffer für sehr große Docker-Container und Offline-KI-Modelle (z. B. 70B Quantized Models).
* **Nachteile:**
  * Keine Mobilität beim Arbeiten.
  * Gleichzeitiger VR-Betrieb und Container-Einsatz kann bei Spitzenlast zu Frame-Drops in VR führen.

</details>

</details>

<details>
<summary><h2>3. Konkrete Aufgabenverteilung: Was läuft wo am besten?</h2></summary>

| Komponente / Task | Empfohlener Rechner | Technische Begründung |
| :--- | :---: | :--- |
| **VS Code & Agent-Orchestrierung** | **VanstrikeCyborg** | Flexibles Arbeiten, geringer Hardwarebedarf für die Steuerung. |
| **Docker-Sandbox (`dockurr/windows`)** | **SimRacer** | 32 GB RAM verhindern Swapping; 24 CPU-Threads stecken QEMU/KVM mühelos weg. |
| **Lokale LLMs / Inferenz (Ollama)** | **SimRacer** | Die RTX 5070 Ti bietet **16 GB VRAM** (ggü. 8 GB am Laptop) – erlaubt doppelt so große Modelle mit voller GPU-Beschleunigung. |
| **Assetto Corsa VR (VIVE Focus Vision)** | **SimRacer** | Dual 2.5K Auflösung bei 120 Hz benötigt zwingend die Rechenpower und VRAM-Bandbreite der Desktop-5070 Ti. |
| **Telemetrie- & Python-Skripte schreiben** | **VanstrikeCyborg** | Code-Entwicklung und Log-Analyse entkoppelt vom Fahrbetrieb. |
| **Datenspeicher & Modell-Checkpoints** | **SimRacer** | 2.8 TB SSD-Kapazität bietet massiven Puffer für Container, ISOs, Mod-Bibliotheken und Datensätze. |

</details>

<details>
<summary><h2>4. Fazit & Empfohlene nächste Schritte</h2></summary>

<details>
<summary><h3>4.1 Kernfazit</h3></summary>

Die vorhandene Hardware ergänzt sich ideal:

1. Der **MSI Cyborg Laptop** ist das agile Programmierwerkzeug.
2. Der **SimRacer Desktop** ist der Hochleistungs-Knoten für Virtualisierung, schwere KI-Inferenz und das VR-Simulationserlebnis.

Die Auslagerung der Docker-Sandbox vom Laptop auf den Desktop löst sofort das 16-GB-RAM-Problem des Laptops, ohne dass zusätzliche Hardware gekauft werden muss.

</details>

<details>
<summary><h3>4.2 Konkrete Schritte zur Inbetriebnahme des Verbunds</h3></summary>

1. **Netzwerk-Freigabe:** Ordner `git-labor` per Git (GitHub/GitLab) synchronisieren oder ein geteiltes Netzlaufwerk zwischen beiden PCs einrichten.
2. **Sandbox-Umzug:** Docker Desktop auf dem SimRacer starten und die `docker-compose.yml` dort ausführen (mit komfortablen 8–12 GB RAM für die Sandbox).
3. **Lokaler KI-Endpunkt:** Auf dem SimRacer einen Ollama-Dienst auf Port 11434 starten – der Laptop kann diesen Endpunkt in VS Code als lokalen, kostenlosen und datenschutzsicheren KI-Agenten ansteuern.

</details>

</details>
