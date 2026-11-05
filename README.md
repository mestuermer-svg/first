# Git-Labor – Zentraler Multi-Root Workspace (`mestuermer-svg/first`)

Dieses Repository ist das **Steuerungs-, Dokumentations- und KI-Agenten-Zentrum** des gesamten Multi-Root-Workspaces (`git-labor.code-workspace`).

---

## Architektur der 3 GitHub-Repositories im Workspace

Über die einzige zentrale Workspace-Datei [`git-labor.code-workspace`](./git-labor.code-workspace) werden alle drei Repositories gemeinsam in VS Code verwaltet:

| # | Name im VS Code Explorer | Lokaler Pfad | GitHub-Repository | Aufgabe & Inhalt |
|---|---|---|---|---|
| **1** | `1_Git-Labor (mestuermer-svg/first)` | `C:\Users\strik\git-labor` | `mestuermer-svg/first` | **Master-Workspace, KI-Agenten & Dokumentation:** Zentrale `.code-workspace`, Custom Agents (`.github/agents/`), Workspace-Skills (`.agents/skills/`), MCP-Konfiguration (`.mcp.json`) und Wissensdatenbank (`#$_Lernmaterial_to_sort/`). |
| **2** | `2_Assetto-Corsa-Content (mestuermer-svg/assetto-corsa-content)` | `C:\Users\strik\assetto-corsa-content` | `mestuermer-svg/assetto-corsa-content` | **Assetto Corsa, Content Manager & Sandbox (`ac-sandbox/`):** Alle 7 AC/CM-Sync-Pakete (`cm-github-sync`), Fahrzeug-Setups/Pitfiles (`.ini`), Python-Apps, Telemetrie, Docker-Sandbox-Konfigurationen und SimRacer-Backupskripte. |
| **3** | `3_Local-Cyborg (mestuermer-svg/local_Cyborg)` | `C:\local_Cyborg` | `mestuermer-svg/local_Cyborg` | **Lokale Workstation-Tools & Ressourcen:** `Apps und Treiber`, `Gemini`, `Opencode`, `Tool-Box` und lokale Lern-/Systemdokumente für den VanstrikeCyborg-Laptop. |

---

## Verwendung

1. **Workspace öffnen:** Immer über `C:\Users\strik\git-labor\git-labor.code-workspace` starten.
2. **Git Source Control (Strg+Shift+G):** In der Quellcodeverwaltung von VS Code werden alle 3 Repositories getrennt aufgelistet und können unabhängig voneinander committed, gepullt und gepusht werden.
