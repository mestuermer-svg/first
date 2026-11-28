> **Thema:** System-Letztstand 24.11.2026 – SimRacer-Speicherbereinigung, 1:1-Parity-Sync, Qwen-3.5-GPU-Offload, Workspace-Agenten-Isolation, XOR-Mutex, Parallel-Ressourcenlimits & Nacharbeiten-Register
> **Autor:** Michael Stürmer
> **Datum:** 24.11.2026

# 5.8 System-Letztstand (24.11.2026): Qwen 3.5 GPU-Offload, Parallel-Ressourcenlimits & Nacharbeiten-Register

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (05 Agents)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 05 Agents](./README.md) · **Vorheriges:** [⬅️ Praxis-Referenz 25.11. (Hisense 4K-TV & ClearType)](./HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md) · **Nächstes:** [Stand 23.11. (ToS-Bereinigung, Ollama & Pitwall v1.5) ➡️](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md)

**Alle Module in `05_Agents/`:**
- [01 • Agent-Stilfibel, Didaktik-Ruler & 7-Stufen-Aufbau](./01_agent-stilfibel-und-didaktik-ruler.md)
- [02 • Agenten erstellen: Instructions, Rules & Prompts](./02_agenten-erstellen-instructions-rules-und-prompts.md) · `gemini.instructions`
- [03 • Agenten ausrüsten: Skills & MCP-Tools](./03_agenten-ausruesten-skills-und-mcp-tools.md) · `SKILL.md`
- [04 • Priming, Memory & Multi-Agent-Orchestrierung](./04_agenten-trainieren-primen-und-orchestrieren.md) · `@light`
- [05 • Schnittstelle, Terminals & XOR-Mutex](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md) · `Bridge`
- [06 • Multi-Workspace Netzwerk & 6-Rollen-Verbund](./05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md)
- [Letztstand 25.11. (Architektur v5, Toolbox & Pitwall v2.1)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-25.md)
- [Praxis-Referenz 25.11. (Hisense 4K-TV & ClearType)](./HISENSE_TV_DISPLAY_OPTIMIERUNG_2026-11-25.md)
- 👉 **[Stand 24.11. (Parity, Qwen 3.5 & Nacharbeiten)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-24.md)** *(aktuell)*
- [Stand 23.11. (ToS-Bereinigung, Ollama & Pitwall v1.5)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md)
- [Änderungsprotokoll 11.11. (MQTT, Gatekeeper & Caddy)](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md)
- [Pitwall & Systemreferenz (NotebookLM-Quelle)](./PITWALL_STEUERUNG_UND_FUNKTIONSREFERENZ_NOTEBOOKLM.md)
- [Boxencrew & Teamchef Konzept (NotebookLM)](./PITWALL_BOXENCREW_TEAMCHEF_KONZEPT_NOTEBOOKLM.md)

**Weitere Rubriken:** [🐧 01 Linux & Bash](../01_Linux_Bash/README.md) · [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🐍 03 Python](../03_Python_Coding/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md) · [🏎️ 06 AC KN5 Modding](../06_AC_KN5_Modding/README.md) · [🥽 07 VR Engineering](../07_VR_Engineering/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

Dieses Protokoll dokumentiert alle am **24.11.2026** umgesetzten und live verifizierten Änderungen nach der großen ToS-Bereinigung vom 23.11.2026 — sowie ein **dediziertes Register aller Nacharbeiten**, die nach den ursprünglichen Konfigurations- und Setup-Schritten notwendig wurden, um daraus systematisch für künftige Rollouts zu lernen.

<details>
<summary><b>Lernziele</b></summary>

Nach dem Durcharbeiten dieses Protokolls kannst du:
1. die **Speicher- vs. VRAM-Trennung** von Ollama (`D:\OllamaModels` auf Platte vs. `OLLAMA_MAX_LOADED_MODELS=1` im VRAM) sauber erklären und anhand gemessener Telemetrie (`80 % Peak`, `0` externe TCP-Verbindungen) nachweisen,
2. begründen, warum VS-Code-Erweiterungen nach Konfigurationserweiterungen einen **`> Developer: Reload Window`** brauchen und wie Duplikate zwischen `settings.json` (`ollama.endpoint`) und `chatLanguageModels.json` entstehen,
3. die **Workspace-Agenten-Isolation** (`chat.agentFilesLocations` + `user-invocable: false`), die **Hierarchie-Freigabe** und den **atomaren XOR-Mutex** (`execution_mutex.lock`) zwischen `git-labor` und `assetto-corsa-content` anwenden,
4. **Parallel-Ressourcenlimits** für Host, Ollama und Docker AC-Sandbox sauber austarieren und Windows-CPU-Deckel (`bcdedit numproc 12`) aufdecken,
5. aus den **9 dokumentierten Nacharbeits-Fällen** konkrete Checklisten-Regeln für künftige Inbetriebnahmen ableiten.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary><b>1. SimRacer C: &rarr; D:\Archiv_SimRacer Zero-Data-Loss-Bereinigung (+110,71 GB NVMe)</b></summary>

Um der System-NVMe (`C:`, 1 TB) auf dem SimRacer wieder großzügig Luft für Docker-Storage (`C:\ac-sandbox\storage\data.img`), VR-Caches und Paging zu verschaffen, wurden ohne Datenverlust **110,71 GB** auf `C:` freigegeben:

- **Vorab-Entlastung & Altlast-Korrektur:**
  - Ruhezustand (`hiberfil.sys`) deaktiviert (`powercfg /h off`): **`-12,77 GB`**.
  - `10` per SHA256 verifizierte `(1)`-Dateiduplikate in `C:\Users\Mike\Downloads` entfernt: **`-4,76 GB`**.
  - Riskante NTFS-Junction `D:\ac-sandbox` sicher per `cmd /c rmdir` entfernt (ohne Zieldaten zu berühren; `C:\ac-sandbox\storage\data.img` verifiziert intakt).
  - `D:\Backups\Veeam_Exclusions.txt` ergänzt um `CrossDevice\*`, `Assetto Corsa\replay\*`, `shared\content\*` und `shared\pure\*`.
- **8 Robocopy-Archiv-Jobs (`94,08 GB` über LAN-Monitor überwacht):**
  - Ausgeführt über [`archive-simracer-c-to-d.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/scripts/archive-simracer-c-to-d.ps1) mit 5s-Live-Fortschritt via [`watch-simracer-c-to-d.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/scripts/watch-simracer-c-to-d.ps1) ([`LIVE-TRANSFER-STATUS.md`](../../../assetto-corsa-content/ac-sandbox/LIVE-TRANSFER-STATUS.md) / [`LIVE-TRANSFER-STATUS.html`](../../../assetto-corsa-content/ac-sandbox/LIVE-TRANSFER-STATUS.html)): **`8/8` Jobs `done`, `0` Fehler**, SHA256-/Byte+Zeitstempel-verifiziert.
  - Ergebnis nach Abschluss & Freigabe: **`C:`** stieg von `65,83 GB` auf **`176,54 GB` frei**; **`D:`** liegt nach Archiv + `qwen3.5:9b`-Download bei **`473,01 GB` frei**.
  - Unberührt & verifiziert intakt: `assettocorsa\acs.exe`, `appmanifest_244210.acf`, `Documents\Annie`, jüngstes Replay (`< 30d`, `21,13 MB`), Steam-Bibliothek und `CrossDevice` (`0,00 GB` echte Belegung — Cloud-Platzhalter).
- **Read-Only-Mounts erweitert:** Beide Compose-Dateien ([`docker-compose.yml`](../../../assetto-corsa-content/ac-sandbox/docker-compose.yml) & [`docker-compose.simracer.yml`](../../../assetto-corsa-content/ac-sandbox/docker-compose.simracer.yml)) binden `Original_AC_Downloads_Archiv:ro` (`D:/Archiv_SimRacer/Downloads`) und `Original_AC_Replays_Archiv:ro` (`D:/Archiv_SimRacer/AC_Replays`) zusätzlich schreibgeschützt in die Sandbox ein.

</details>

<details>
<summary><b>2. SimRacer 1:1 VS-Code-Parity (76 Extensions), <code>uvx</code>, 5 MCP-Server &amp; Cyborg Read-Only Shares</b></summary>

- **Extensions & Python-Tooling (`SimRacer` `Mike`):**
  - `uv 0.13.9` & `uvx 0.13.9` installiert (`C:\Users\Mike\.local\bin`, User-`PATH`).
  - Alle `50` fehlenden VS-Code-Extensions per [`sync-simracer-vscode-extensions.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/scripts/sync-simracer-vscode-extensions.ps1) nachgezogen (`OK=50 | FAIL=0 | Gesamt=76`).
  - `C:\Users\Mike\AppData\Roaming\Code\User\mcp.json` (Backup `.bak_20261124`) erweitert auf alle `5` Server (`geminiDocs`, `nvidia-app`, `microsoft-learn`, `chrome-devtools` via `npx`, `markitdown` via `uvx`).
- **Cyborg Read-Only SMB-Shares & `simracer.code-workspace`:**
  - Auf `VanstrikeCyborg` über [`Setup-CyborgReadOnlyShares.ps1`](../../labs/Setup-CyborgReadOnlyShares.ps1) eingerichtet: **`Cyborg-GitLabor-RO`** (`C:\Users\strik\git-labor`) und **`Cyborg-AC-Content-RO`** (`C:\Users\strik\assetto-corsa-content`) mit striktem **`VANSTRIKECYBORG\strik | Allow | Read`** (kein Schreibrecht vom SimRacer).
  - `C:\ac-sandbox\simracer.code-workspace` (Backup `.bak_20261124`) ergänzt um `[HOST]`-Labels, `[CYBORG RO] Git-Labor (Read-Only)`, `[CYBORG RO] Assetto-Corsa-Content (Read-Only)`, `"files.readonlyInclude": { "//VanstrikeCyborg/**": true, "D:/git-labor/**": true }` sowie korrigierten Task-Pfad `general-SIM`. *(Offener Einmal-Schritt vom SimRacer aus: Windows-Credentials per `net use \\VanstrikeCyborg\Cyborg-GitLabor-RO /user:VANSTRIKECYBORG\strik * /persistent:yes` hinterlegen.)*

</details>

<details>
<summary><b>3. Qwen 3.5 Rollout, Disk-vs.-VRAM-Prinzip, RTX-5070-Ti-Lastbeweis (80 % Peak) &amp; Router-Update</b></summary>

#### Warum `qwen3.5` und warum mehrere Modelle in Ollama installiert sind
- Die Ollama-Extension (`ollama.ollama@0.0.14`) markiert `qwen2.5-coder` intern als veraltet (`outdatedAgentModelFamilies` in `out\recommendations.js`). Deshalb wurden auf beiden GPU-Knoten **Qwen 3.5**-Modelle installiert:
  - **`SimRacer` (RTX 5070 Ti, 16 GB VRAM, `D:\OllamaModels`, gesamt `21,94 GB`):** `qwen3.5:9b` (`6,6 GB`, `262144` Kontext, `completion/vision/tools/thinking`), `gemma4:12b` und Legacy `qwen2.5-coder:14b`.
  - **`VanstrikeCyborg` (RTX 5060 Laptop, 8 GB VRAM):** `qwen3.5:4b` (`3,3 GB`, `262144` Kontext, `completion/vision/tools/thinking`) und `gemma4:e4b`.
- **Festplatte vs. VRAM (`OLLAMA_MAX_LOADED_MODELS=1`):** Alle `3` SimRacer-Modelle liegen parallel auf `D:\OllamaModels`, es befindet sich aber **immer maximal 1 Modell gleichzeitig im VRAM** der RTX 5070 Ti. Wechselst du im Dropdown zwischen `qwen3.5:9b` und `gemma4:12b`, entlädt Ollama das vorherige Modell automatisch und lädt das neue — ein manueller Austausch ist nicht nötig. Optional kannst du das ältere `qwen2.5-coder:14b` jederzeit mit `ollama rm qwen2.5-coder:14b` vom SimRacer löschen, wenn du ~9 GB Plattenplatz sparen möchtest.

#### Verifizierter Live-Dauerlasttest auf der RTX 5070 Ti (`qwen3.5:9b`, 0 Cloud-Calls)

| Messgröße (`VanstrikeCyborg` &rarr; `192.168.178.68:11434`, `1100` Output-Tokens) | Gemessener Wert |
| :--- | :--- |
| **GPU Compute (`utilization.gpu`)** | **Peak 80 %** · **Ø 68,0 % aktiv** (durchgehend 69–80 %) |
| **Leistungsaufnahme &amp; Temperatur** | **43,7 W Leerlauf &rarr; 214,9 W Peak** · max. **53 °C** |
| **VRAM-Belegung &amp; `ollama ps`** | **8667 / 16303 MiB** · `qwen3.5:9b` (`5.9 GB`, **`100% GPU`**, Context `8192`) |
| **Geschwindigkeit (warm)** | **95,8 tok/s** (`1100` Tokens in `11,49 s`, Gesamt `12,58 s`, `load=0.00 s`) |
| **TCP-Verbindungen (`ollama.exe` &amp; `llama-server.exe`)** | **0 externe IPs** — `llama-server.exe --offline` (`127.0.0.1`), nur LAN `192.168.178.172` &harr; `.68:11434` |

- **Router-Update:** In [`hybrid_llm_router.py`](../../labs/03_python/hybrid_llm_router.py#L49-L52) wurden `SIMRACER_CODE_MODEL` auf **`qwen3.5:9b`** und `LAPTOP_CODE_MODEL` auf **`qwen3.5:4b`** umgestellt und per `--tier local --workload code --check` verifiziert (`simracer_ollama`, `http://192.168.178.68:11434`).
- **VS Code Provider-Bereinigung:** In `C:\Users\strik\AppData\Roaming\Code\User\chatLanguageModels.json` (Backup `.bak_20261124`) wurde der redundante lokale Eintrag `"Ollama"` (`127.0.0.1:11434`) entfernt; der Laptop kommt nun exakt einmal aus `settings.json` (`ollama.endpoint`) und der SimRacer über `"Ollama (SimRacer RTX 5070 Ti)"` (`192.168.178.68:11434`).

</details>

<details>
<summary><b>4. Workspace-Agenten-Sichtbarkeit, Hierarchie-Gate &amp; atomarer XOR-Mutex</b></summary>

Um doppelte Agenten-Einträge im Multi-Root-Chat-Dropdown und gleichzeitige Schreibkollisionen zwischen `git-labor` und `assetto-corsa-content` zu verhindern, greifen drei Schutzschichten:

1. **Multi-Root-Filter in [`git-labor.code-workspace`](../../git-labor.code-workspace):**
   - `"chat.agentFilesLocations": { ".github/agents": false, "../git-labor/.github/agents": true }` blendet `assetto-corsa-content\.github\agents\` und `local_Cyborg\...\.github\agents\` im `git-labor`-Fenster aus.
2. **`user-invocable: false` auf SSH-Workern:**
   - Alle `5` SSH-Schnittstellen in `git-labor\.github\agents\` (`dark`, `light`, `rig`, `sarah`, `rick`) tragen `user-invocable: false` (plus fehlerhafte Windows-`Hidden`-Attribute entfernt). Im `git-labor`-Dropdown bleiben gezielt **`General Cyborg`** (global) und **`Simwerkstatt: General Sim (SSH)`** direkt wählbar; im `assetto-corsa-content`-Workspace bleiben alle `6` Agenten unverändert aktiv.
3. **Hierarchie-, Pitwall-Gate &amp; atomarer XOR-Mutex (`execution_mutex.lock`):**
   - Implementiert in [`Send-SimAgentTask.ps1`](../../labs/Send-SimAgentTask.ps1) (Parameter `-WorkspaceContext`, `-IssuedBy`, `-LockWaitSeconds`, `-LockTtlSeconds`) und [`sim_agent_bridge.py`](../../labs/03_python/sim_agent_bridge.py).
   - Prüft vor jeder Task-Abgabe: (a) gültige Hierarchie (`General_Cyborg`/`General_Sim` &rarr; `Light` &rarr; Worker), (b) Pitwall-Policy (`pitwall_control_policy.json`) und (c) atomare Sperre unter `\\192.168.178.68\ac-sandbox\shared\agents\general-SIM\execution_mutex.lock` + `.json` (120 s TTL-Recovery + FIFO-Fremdkontext-Prüfung). Verifiziert durch `-QueryStatus` und `6/6` Python-Tests.

</details>

<details>
<summary><b>5. SimRacer Parallelbetrieb (Host + Ollama + AC-Sandbox) &amp; Hardware-Partitionierung</b></summary>

#### Aktueller Hardware-Engpass (`bcdedit numproc 12`)
Beim Audit auf `SimRacer` (`192.168.178.68`) wurde entdeckt, dass der **AMD Ryzen 9 3900X** (`12` Kerne / `24` Threads) per Windows-Boot-Eintrag **`bcdedit numproc 12`** aktuell auf **6 physische Kerne / 12 logische Prozessoren** begrenzt ist (`50 %` CPU liegen brach). Aufheben per Admin-CMD + Neustart:
```cmd
bcdedit /deletevalue "{current}" numproc
```

#### Eingerichtete Parallel-Aufteilung (Backups `*.bak_20261124` angelegt, `docker compose config --quiet` Exit `0`)

| Ressource | Vorher | Jetzt (24.11.2026) | Wirkung im Parallelbetrieb |
| :--- | :--- | :--- | :--- |
| **CPU** | `.wslconfig`: `processors=16` · Compose: `CPU_CORES: "8"` | `.wslconfig`: **`processors=6`** · Compose ([`docker-compose.yml`](../../../assetto-corsa-content/ac-sandbox/docker-compose.yml), [`docker-compose.simracer.yml`](../../../assetto-corsa-content/ac-sandbox/docker-compose.simracer.yml)): **`CPU_CORES: "6"`** + **`cpus: 6.0`** | Saubere **50/50-Trennung** (`6` Threads Sandbox / `6` Threads Host+Ollama unter `numproc 12`). *Ohne `numproc`-Deckel auf `10`/`8` hochsetzbar.* |
| **RAM (`31,92 GB`)** | `.wslconfig`: `memory=20GB` · Compose: `RAM_SIZE: "12G"` (~`18 GB` Host-Belegung) | `.wslconfig`: **`memory=14GB`**, `swap=4GB`, `autoMemoryReclaim=gradual` · Compose: **`RAM_SIZE: "10G"`** + **`mem_limit: 12g`** | Verhindert Host-Speicherdruck beim Start von Docker Desktop + Windows-11-Sandbox. |
| **GPU (`RTX 5070 Ti`, `16 GB`)** | Sandbox ohne GPU-Passthrough; `OLLAMA_KEEP_ALIVE=5m` | Sandbox nutzt **`0 MiB` VRAM / `0 %` GPU**. `start-ollama-simracer.ps1`: **`OLLAMA_KEEP_ALIVE=30m`** &amp; **`OLLAMA_NUM_PARALLEL=1`** *(ab nächstem Ollama-Neustart)* | `~7,5 GB` VRAM bleiben frei; kein Parallel-VRAM-Overflow bei mehreren LLM-Anfragen. |
| **Renn-Priorität** | Watchdog aktiv (`3 s`) | `SimRacer-Focus-Watchdog` ([`rig-hub.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/scripts/rig-hub.ps1#L184-L228)) | Pausiert Sandbox und entlädt Ollama (`keep_alive=0`) sofort bei Start von `acs`, `Content Manager` oder SteamVR. |

</details>

<details>
<summary><b>6. Nacharbeiten &amp; Lessons Learned (Änderungen NACH dem Erstellen von Einstellungen)</b></summary>

Die folgende Tabelle dokumentiert alle Punkte, bei denen nach dem ursprünglichen Konfigurieren zusätzliche Nacharbeiten nötig waren — inklusive der daraus abgeleiteten Standardregel für künftige Arbeiten:

| # | Symptom / Beobachtung | Technische Ursache (Root Cause) | Durchgeführte Nacharbeit | Lernregel für künftige Setups |
| :-: | :--- | :--- | :--- | :--- |
| **1** | **Doppelte `qwen3.5:4b` &amp; `gemma4:e4b` im Chat-Dropdown** | `127.0.0.1:11434` war doppelt gepflegt: in `settings.json` (`ollama.endpoint`) **und** in `chatLanguageModels.json` (`"Ollama"`). | Redundanten `"Ollama"`-Eintrag (`127.0.0.1`) aus `chatLanguageModels.json` entfernt (`Ollama (SimRacer RTX 5070 Ti)` behalten). | Lokalen Standard-Endpunkt nur einmal pflegen (`settings.json` **oder** `chatLanguageModels.json`), Remote-GPUs über `chatLanguageModels.json`. |
| **2** | **`ollama.ollama` warnte vor „veraltetem“ `qwen2.5-coder:14b`; `qwen3.5:9b` fehlte zunächst in UI** | `ollama.ollama@0.0.14` (`recommendations.js`) stuft `qwen2.5*` als *outdated* ein; neue Modelle erscheinen nach Pull oft erst nach `> Developer: Reload Window` (Befehlspalette braucht führendes `>`). | `qwen3.5:9b` &amp; `qwen3.5:4b` gepullt, `hybrid_llm_router.py` umgestellt, Reload-Hinweis mit explizitem `>`-Präfix ergänzt. | Nach `ollama pull` / `mcp.json`-Edit in VS Code immer **`> Developer: Reload Window`** einplanen; `>` bei Commands explizit mitnennen. |
| **3** | **Scheinbar `0–1 %` GPU-Last, VRAM stieg, erster 90s-Test Timed-Out** | Kaltladen von `6,6 GB` ab externer USB-HDD (`D:\OllamaModels`) dauert **`127–157 s`** (Compute-Last erst danach); Windows Task-Manager zeigt CUDA-Last oft nur im Subgraph **`CUDA`**, nicht unter `3D`. | Dauerlast-Stream-Test (nach Warm-Load: **80 % Peak**, `95,8 tok/s`); `OLLAMA_KEEP_ALIVE` in `start-ollama-simracer.ps1` von `5m` auf `30m` erhöht. | Große Modelle möglichst auf NVMe (`C:`) lagern oder ausreichend langes `KEEP_ALIVE` + `CUDA`-Graph-Prüfung im Task-Manager nutzen. |
| **4** | **Alle Worker doppelt im Chat-Dropdown + abgelehnte Absolute-Pfade** | Multi-Root lädt `.github/agents` aus allen `4` Roots; VS Code `1.146.0` lehnt `C:/`-Pfade in `chat.agentFilesLocations` ab; `Hidden`-Dateien fehlten ohne `Get-ChildItem -Force`. | Relative Pfad-Filter in `git-labor.code-workspace`, `user-invocable: false` auf SSH-Workern, `Hidden`-Attribute bereinigt. | Multi-Root-Agentenfilter immer über relative Workspace-Pfade prüfen und versteckte Dateien stets mit `-Force` inventarisieren. |
| **5** | **`Send-SimAgentTask.ps1 -QueryStatus` brach mit Fehler ab** | PowerShell reserviert **`$ExecutionContext`** als schreibgeschützte Automatik-Variable; ein Script-Parameter gleichen Namens scheitert beim Binden. | Parameter auf **`-WorkspaceContext`** umbenannt (JSON-Feld `"execution_context"` beibehalten). | PowerShell-Automatik-Variablen (`$ExecutionContext`, `$Host`, `$PID`, `$Args`) niemals als Parameternamen nutzen. |
| **6** | **SimRacer lief nur auf 6/12 Threads statt 12/24; `.wslconfig` überbucht** | Versteckte Boot-Option `bcdedit numproc 12` halbiert Ryzen 9 3900X; `.wslconfig` erlaubte `20 GB` / `16` Kerne bei `~18 GB` Host-RAM-Basislast. | `.wslconfig` (`14GB`/`6`), Compose (`10G`/`6`, `cpus`/`mem_limit`) begrenzt; Admin-Fix für `numproc` dokumentiert. | Hardware-Audits immer gegen `Win32_Processor`, `bcdedit` **und** reale Host-RAM-Belegung fahren, bevor Container-/VM-Quotas festgelegt werden. |
| **7** | **`ollama pull` brach zeitweise auf `7–40 KB/s` ein** | Parallel laufende `robocopy`-Archivierung (`94 GB`) sättigte die Write-Queue der externen USB-HDD `D:`. | Robocopy sauber zu Ende laufen lassen; danach stieg `ollama pull` sofort auf `14 MB/s`. | Große USB-HDD-Transfers und Model-Pulls auf demselben Ziellaufwerk strikt nacheinander ausführen. |
| **8** | **Umlaut-/Box-Zeichen-Mojibake &amp; SSH-Here-String-Abbrüche** | Windows PowerShell 5.1 nutzt standardmäßig Windows-1252 statt UTF-8 ohne BOM; verschachtelte `@'` in SSH-Inline-Befehlen zerstören Quoting. | SSH-PowerShell konsequent per UTF-16LE Base64 **`-EncodedCommand`**, Dateien strikt mit `UTF8Encoding($false)` schreiben; defekte Umlaute/Box-Zeichen in `Doku/README.md` &amp; `02_VSCode_Env/README.md` bereinigt. | Für Remote-PowerShell über SSH immer Base64 `-EncodedCommand` und explizites UTF-8 ohne BOM einsetzen. |
| **9** | **Unerwünschte `datacloud_*`-MCPs &amp; Extension-Empfehlungen nach Sync** | VS Code Default `chat.mcp.discovery.enabled.copilot: true` las `.copilot\mcp-config.json` mit ein; Alt-Empfehlungen steckten noch in `.vscode\extensions.json` auf beiden PCs. | `"copilot": false` in `chat.mcp.discovery.enabled` gesetzt, `extensions.ignoreRecommendations: true` aktiviert und Alt-IDs in beiden Repos bereinigt. | Nach Extension-/MCP-Bereinigungen immer `chat.mcp.discovery.enabled` und sämtliche Workspace-`extensions.json` auf beiden Knoten prüfen. |
| **10** | **Alle 30 s PowerShell-Fokus-Popup auf SimRacer (`Event 400`)** | `SimRacer-VR-Radio-Bridge` (`pythonw.exe`) rief in `_probe_audio_devices()` alle 30 s `powershell.exe` ohne `CREATE_NO_WINDOW` auf (`LogonTrigger` hielt sie 24/7 wach). | `CREATE_NO_WINDOW` in [`simracer_vr_radio_bridge.py`](../../../assetto-corsa-content/ac-sandbox/shared/telemetry/simracer_vr_radio_bridge.py) ergänzt; `SimRacer-Focus-Watchdog` ([`rig-hub.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/scripts/rig-hub.ps1)) startet Bridge nur bei aktivem `acs`/`acs_x86`. | Jede `subprocess.run`-Shell unter `pythonw.exe` muss zwingend `CREATE_NO_WINDOW` tragen; Audio-/VR-Bridges bedarfsgerecht über Watchdog schalten. |
| **11** | **`DOMTokenList`-Crash &amp; fehlende Agentenliste im Pitwall-Modus `MANUAL`** | `mState.classList.add('')` warf `SyntaxError` im `MANUAL`-Zweig von `renderApprovalState()`, bevor Agenten- und Kategorie-Karten gerendert wurden; manuelle Modus-Buttons blieben nach Fahrt auf `LIVE_RACE` hängen. | Pitwall v2.0 (`/opt/telemetry-relay/telemetry_relay.py`): Scroll-freies `100dvh`-6-Seiten-UI, `classList`-Guard, nicht-blockierende Toasts statt `confirm()`, automatische Read-Only-Modus-Pille (`ENGINEERING`/`PITBOX_SETUP`/`LIVE_RACE`), integrierte `xterm.js`-SSH-Terminals (`/ws/terminal/{agent}`), `/api/logs/history` mit `hardware_node`-Tagging sowie einklappbarer/deaktivierbarer Sprachchat (`/api/voice/dispatch` + Antigravity-Dock). | Niemals leere Strings an `classList.add()` übergeben; UI-Betriebsmodi aus realer Telemetrie/Prozesslage ableiten statt manuell umzuschalten. |
| **12** | **Phantom-Pakete &amp; stummer Sarah-Boxenfunk (`ac_telemetry_sender` / `sarah_worker`)** | `ac_telemetry_sender.py` hielt `acpmf_*` über `mmap.mmap(0, ...)` 24/7 offen (`gp_2025_rb21` bei `0 km/h`), störte CSP (`Local\acpmf_static`) und `sarah_worker.py` hatte keine Live-Coaching-Schleife. | `ac_telemetry_sender.py` prüft `acs.exe`/`acs_x86.exe` + `OpenFileMappingW` per `ctypes` (`0` Phantom-Pakete im Leerlauf); [`sarah_worker.py`](../../../assetto-corsa-content/ac-sandbox/shared/telemetry/sarah_worker.py) ergänzt um `RaceEngineerCoach` (Pit-Out, Rundenzeit/Delta, Reifentemp, Fuel &rarr; `sarah_voice.py` &rarr; `:8092`). | Windows-Shared-Memory-Reader dürfen nie unbesehen `mmap.mmap(0, ...)` ohne vorherigen `OpenFileMappingW`- &amp; Prozess-Check öffnen. |

</details>

<details>
<summary><b>7. Pitwall v2.0, Kiosk-Navigation, Integrierte Terminals &amp; Sarah Live-Coaching (24.11.2026 Abend)</b></summary>

1. **Scroll-freies 6-Seiten-Kiosk-Layout (`100dvh`, `StrikerPi :8080`):**
   - Hauptseiten: `🏁 Telemetrie`, `📺 Streams` (mit einzeiligem Live-Telemetrie-Ticker), `🧪 Sandbox`, `🛡️ Agenten` (Sub-Tabs `🤖 Agenten & Status`, `🤝 Freigabe-Matrix`, `📥 Anträge & Audit`), `💻 Terminals`, `📜 Logs`.
   - Topbar-Modus (`ENGINEERING`, `PITBOX_SETUP`, `LIVE_RACE`) ist eine reine **automatische Status-Pille** für Sarah/Rig — die manuellen Umschaltbuttons wurden entfernt.
   - Sichtbarkeits- &amp; seitenabhängiges Polling (`document.hidden`-Stopp), `sandbox_cache` (`10 s`), `approvals_cache` (`8 s`), SSH `ServerAliveInterval=5` und `vr_auto_paused`-Reset in `rig-hub.ps1` beenden unnötiges SSH-Dauerfeuer.
2. **Integrierte SSH-Terminals (`xterm.js` offline unter `/opt/telemetry-relay/static/` + `/ws/terminal/{agent}`):**
   - WebSocket-PTY auf `StrikerPi` (`@rick`, `@rig`, `@light`, `@dark`, `@sarah`, `@general` mit Host-Fallback) inklusive `TIOCSWINSZ`-Resize und sauberem Prozessgruppen-Cleanup (`SIGTERM`/`SIGKILL` &rarr; `0` verwaiste PTYs).
   - Jede Agenten-Zeile besitzt die vereinfachte Steuerung `▶️ Aktiv` / `⏸️ Pausiert` plus Direkt-Buttons `💻` (Terminal) und `📜` (Logs).
3. **Agenten-Logs, Prompt-Inspektor &amp; Hardware-Zuordnung (`/api/logs/history`):**
   - Master-Detail-Ansicht mit Agenten-, Typ- und Statusfilter sowie Suchfeld; zeigt behandelten `Prompt`, `Output`, `Task-Log`, `context_subset` und den ausführenden **`hardware_node`** (`VanstrikeCyborg`, `SimRacer`, `Win11-Sandbox`, `Archibald IdeaPad`, `StrikerPi`).
4. **Einklappbarer, deaktivierbarer Sprachchat (`#voiceFab` / `#voiceDrawer`):**
   - Im Leerlauf als kleine schwebende Pille eingeklappt und unter `⚙️` komplett abschaltbar; kombiniert direkten Pitwall-Funk (`POST /api/voice/dispatch`) mit einem wiederverwendbaren Companion-Fenster für die angemeldete Google-Antigravity-Sitzung *(Cross-Origin-Iframes blockiert Google per Header; Browser-Mikrofon `getUserMedia` erfordert HTTPS/localhost)*.
5. **Sarah Live-Renningenieur &amp; VR-Audio-Bridge-Abnahme:**
   - `ac_telemetry_sender.py` sendet im Leerlauf **`0`** Phantom-Pakete; `RaceEngineerCoach` in `sarah_worker.py` funkt Rundenzeiten, Reifentemperaturen und Tankwarnungen in Echtzeit an `SimRacer-VR-Radio-Bridge` (`:8092`, verifiziert mit `winmm_mci`, `VIVE Virtual Audio Device` erkannt, `0` Event-400-PowerShell-Popups).

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **CPU-Bremse auf SimRacer lösen:** Führe in einer Admin-CMD auf dem SimRacer `bcdedit /deletevalue "{current}" numproc` aus, starte einmal neu und prüfe anschließend mit `Get-CimInstance Win32_Processor`, dass wieder `12` Kerne / `24` logische Prozessoren aktiv sind (danach optional `.wslconfig` auf `processors=10` &amp; `CPU_CORES: "8"` hochsetzen).
2. **Cyborg Read-Only Share am SimRacer freischalten:** Einmal auf dem SimRacer `net use \\VanstrikeCyborg\Cyborg-GitLabor-RO /user:VANSTRIKECYBORG\strik * /persistent:yes` ausführen, damit die `[CYBORG RO]`-Ordner in `simracer.code-workspace` direkt laden.
3. **Optional — Ollama-Kaltstart auf ~4 s drücken:** Verschiebe bei Bedarf `D:\OllamaModels` (`21,94 GB`) auf die NVMe `C:\OllamaModels` (`176,2 GB` frei) und passe `OLLAMA_MODELS` in `start-ollama-simracer.ps1` + [`setup-ollama-node.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/scripts/setup-ollama-node.ps1) an.
4. **Optional — Legacy-Modell aufräumen:** Falls `qwen2.5-coder:14b` neben `qwen3.5:9b` nicht mehr benötigt wird, auf dem SimRacer `ollama rm qwen2.5-coder:14b` ausführen.

</details>

<details>
<summary><b>Weiterführende Links &amp; Quellen</b></summary>

- **Vorgänger-Protokoll (23.11.2026):** [`SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md`](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-23.md)
- **System-Protokoll (11./12.11.2026):** [`SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md`](./SYSTEM_ARCHITEKTUR_AENDERUNGEN_2026-11-11.md)
- **Workspace-Schnittstelle &amp; XOR-Mutex:** [`05_workspace-schnittstelle-simracer-und-agenten-terminals.md`](./05_workspace-schnittstelle-simracer-und-agenten-terminals.md)
- **Multi-Workspace-Verbund &amp; MCP/Ports:** [`05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md`](./05_multi-workspace-netzwerk-mcp-und-agenten-verbund.md) · [`03_mcp-server-localhost-proxy-und-ports.md`](../02_VSCode_Env/03_mcp-server-localhost-proxy-und-ports.md)
- **Router, Bridge &amp; Share-Setup:** [`hybrid_llm_router.py`](../../labs/03_python/hybrid_llm_router.py) · [`Send-SimAgentTask.ps1`](../../labs/Send-SimAgentTask.ps1) · [`sim_agent_bridge.py`](../../labs/03_python/sim_agent_bridge.py) · [`Setup-CyborgReadOnlyShares.ps1`](../../labs/Setup-CyborgReadOnlyShares.ps1)
- **SimRacer Bereinigung, Compose &amp; Watchdog:** [`archive-simracer-c-to-d.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/scripts/archive-simracer-c-to-d.ps1) · [`docker-compose.yml`](../../../assetto-corsa-content/ac-sandbox/docker-compose.yml) · [`docker-compose.simracer.yml`](../../../assetto-corsa-content/ac-sandbox/docker-compose.simracer.yml) · [`rig-hub.ps1`](../../../assetto-corsa-content/ac-sandbox/shared/scripts/rig-hub.ps1)

</details>

<details>
<summary><b>Chips &amp; Kernaussagen</b></summary>

- **Disk vs. VRAM (`MAX_LOADED=1`):** Mehrere Ollama-Modelle auf Platte kosten keinen laufenden VRAM; Ollama lädt beim Modellwechsel automatisch um (`1` Modell aktiv im VRAM, `0` manuelles Austauschen).
- **Verifizierter 5070-Ti-Offload (`0` Cloud-Calls):** `qwen3.5:9b` erreicht warm **`95,8 tok/s`** und **`80 % Peak GPU`** bei **`0`** externen TCP-Verbindungen; Engpass beim Kaltstart (`127–157 s`) war nur die USB-HDD `D:\OllamaModels`.
- **SimRacer CPU-Fund (`numproc 12`):** Windows Boot-Config halbiert den Ryzen 9 3900X auf `6/12` Threads; parallel wurden `.wslconfig` (`14GB`/`6`), Compose (`10G`/`6`) und Ollama (`KEEP_ALIVE=30m`, `NUM_PARALLEL=1`) auf konfliktfreien Parallelbetrieb eingestellt.
- **Agenten-Hygiene &amp; XOR-Mutex:** Relative `chat.agentFilesLocations` in `git-labor.code-workspace`, `user-invocable: false` auf SSH-Workern sowie `execution_mutex.lock` verhindern UI-Duplikate und Schreibrennen zwischen den Workspaces.
- **Nacharbeiten als Qualitätsregel:** Jede unerwartete Nachkorrektur (Base64-SSH, `$ExecutionContext`, `Reload Window`, USB-I/O-Serialisierung, `chatLanguageModels.json`-Single-Source) ist dauerhaft im Register Abschnitt 6 festgehalten.

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
