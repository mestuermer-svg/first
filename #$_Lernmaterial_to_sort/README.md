# Lernmaterial-Übersicht & Index (`#$_Lernmaterial_to_sort`)

Dieses Verzeichnis enthält die Dokumentationen, Leitfäden und Diagnoseberichte des Projekts, unterteilt in thematische Schwerpunkte:

---

## 1. KI-Agenten, Regeln & Workflows

- [Agent-guidline.md](Agent-guidline.md) – Grundlegende Verhaltensrichtlinien und Rollenverständnis für den KI-Agenten.
- [agent_ruler.md](agent_ruler.md) – Regelwerk und Leitplanken für automatisierte Bearbeitung und Code-Qualität.
- [Agent_setup.md](Agent_setup.md) – Schritt-für-Schritt-Einrichtung und Aktivierung der Agenten-Konfiguration.
- [SKILL.md](SKILL.md) – Skill-Definitionen und Fähigkeiten des Agenten im Workspace.

---

## 2. VS Code, Git & MCP (Model Context Protocol)

- [uebersicht-vscode-agent-localhost-gemini-antigravity.md](uebersicht-vscode-agent-localhost-gemini-antigravity.md) – **NEU:** Architektur-Übersicht: VS Code Agent, Localhost-Proxy (`cli-proxy-api.exe`), Gemini/Antigravity, lokale MCP-Server & zweigeteilter Git-Mirror (`.git`-Datenbank vs. Klartext).
- [visual_studio_code_doku.md](visual_studio_code_doku.md) – Umfassende Dokumentation zur VS Code Umgebung.
- [vsc.md](vsc.md) – Schnelleinstieg & nützliche Shortcuts für Visual Studio Code.
- [vsc+git.md](vsc+git.md) – Zusammenspiel von VS Code und Git Versionskontrolle.
- [git-source-control-anleitung-fuer-einsteiger.md](git-source-control-anleitung-fuer-einsteiger.md) – Leitfaden für Git-Befehle, Branches und Commits.
- [VS_Code_KI_Agent_MCP_Gemini_Anleitung.md](VS_Code_KI_Agent_MCP_Gemini_Anleitung.md) – Zusammenspiel von VS Code, MCP-Servern und Gemini.
- [diagnose-und-einrichtung-mcp-git-vscode.md](diagnose-und-einrichtung-mcp-git-vscode.md) – Fehleranalyse und Einrichtung der MCP-Schnittstellen.
- [diagnose-und-loesung-nvidia-app-agent-mcp-zugriff.md](diagnose-und-loesung-nvidia-app-agent-mcp-zugriff.md) – Fehlerbehebung beim Aktivieren des NVIDIA App Agent-Zugriffs (MCP-Server, Named Pipe, NvContainer).

---

## 3. Docker, Sandbox & Virtualisierung

- [docker.md](docker.md) – Grundlagen und Befehle für Docker Container.
- [docker-sbx-anleitung.md](docker-sbx-anleitung.md) – Anleitung zur isolierten Sandbox-Containerumgebung.
- [SANDBOX_ANLEITUNG.md](SANDBOX_ANLEITUNG.md) – Vollständige Anleitung zum Windows-11-Sandbox-System in Docker.
- [docker-windows-steam-ki-agent-architektur.md](docker-windows-steam-ki-agent-architektur.md) – Virtualisierungs-Analyse (Steam unter QEMU/Docker) & 3 Architekturen zur KI-Agenten-Integration.

---

## 4. Google Antigravity & Gemini Ökosystem

- [gemini_kosystem_bersicht.md](gemini_kosystem_bersicht.md) – Überblick über das Gemini-Modell- und API-Ökosystem.
- [gemini-code-1792359280588.md](gemini-code-1792359280588.md) – Referenzcode und spezifische Gemini-Konfigurationen.
- [lernmaterial-google-antigravity.md](lernmaterial-google-antigravity.md) – Hintergrundwissen zu Google Antigravity & Agenten-Routing.
- [verbindungsbericht-vscode-github-gemini.md](verbindungsbericht-vscode-github-gemini.md) – Verbindungs- und Testbericht zu GitHub & Gemini.

---

## 5. Systemarchitektur, Hardware, Backup & Simracing

- [simracer-system-backup-wiederherstellung-veeam.md](simracer-system-backup-wiederherstellung-veeam.md) – **NEU:** Praxisanleitung für ein bootfähiges System-Image (Veeam Agent Free) des SimRacers ohne Steam-Spiele (`steamapps\common`) inkl. Bare-Metal-Recovery.
- [multi-pc-architektur-ki-agents-simracing.md](multi-pc-architektur-ki-agents-simracing.md) – Netzwerk- und Host-Architektur für verteilte KI-Agenten im Simracing (Assetto Corsa).
- [hardware-analyse-system-stabilitaet-docker-ki.md](hardware-analyse-system-stabilitaet-docker-ki.md) – Hardware-Ressourcen, CPU/RAM-Auslastung und Stabilitätsanalyse.

---

## 6. Protokolle, Diagnosen & Schlüssel

- [diagnose-und-loesung-antigravity-server-port8000-8317.md](diagnose-und-loesung-antigravity-server-port8000-8317.md) – Fehlerbehebung bei Port-Konflikten (8000/8317).
- [diagnose-und-reparatur-docker-antigravity.md](diagnose-und-reparatur-docker-antigravity.md) – Reparaturanleitung für die Docker-Antigravity-Pipeline.
- [prozess-log.md](prozess-log.md) – Chronologisches Protokoll der Einrichtung und Änderungen.
- [API_Keys.md](API_Keys.md) – Konfiguration und Verwaltung der API-Schlüssel.