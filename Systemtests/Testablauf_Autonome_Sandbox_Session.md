# Testablauf: Autonome Docker-Sandbox & Assetto-Corsa-Trainingssession

- **Thema:** Vollautomatischer End-to-End-Test ohne manuelle Nutzer-Eingriffe (`@rig`, `@light`, `@dark`)
- **Skript:** [Start-AutonomousSandboxTest.ps1](file:///c:/Users/strik/git-labor/Systemtests/Start-AutonomousSandboxTest.ps1)

---

## 1. Voraussetzungen für den komplett autonomen Lauf

1. **Pitwall-Gate freigegeben:** In `\\192.168.178.68\ac-sandbox\shared\agents\general-SIM\pitwall_control_policy.json` muss `agents_paused` auf `false` stehen (und `mode` idealerweise auf `"AUTO"`).
2. **Agenten-Terminals aktiv:** `@light` und `@rig` laufen auf dem SimRacer-Host (`192.168.178.68`); `@dark` startet mit dem Container `ac-win11-sandbox`.
3. **SMB-Zugriff:** `\\192.168.178.68\ac-sandbox\shared\agents` ist erreichbar.

---

## 2. Phasen des Testablaufs

| Phase | Ziel-Agent | Aktion / Mechanismus | Verifikation |
| :--- | :--- | :--- | :--- |
| **0. Pre-Flight** | Pitwall / SMB | Prüft `agents_paused` und Policy-Modus | Abbruch bei `agents_paused = true` |
| **1. Docker Sandbox** | `@rig` → `@light` | `Status`-Check; falls gestoppt: `@light` (`ProcessPrompt` zum Sandbox-Start) | Container `ac-win11-sandbox` läuft |
| **2. `@dark` Start** | `@dark` | `Status`-Handshake in `dark\inbox` / `dark\outbox` | `@dark` meldet Bereitschaft in Sandbox |
| **3. Auto-Transfer** | `@dark` → `@light` → `@dark` | `@dark` `ListContent` → Abgleich mit SimRacer-Host → `@light` `ProvideAcContent` (`cars`) triggert `@dark` `SyncCoreAssets` | Erneutes `@dark` `ListContent` enthält neues Auto |
| **4. Strecke & Training** | `@dark` | `SetSession` (`race.ini` mit `car` & `track`) → `LaunchSession` (`practice`) | `@dark` `Status` prüft laufende Session (`acs.exe`) |

---

## 3. Ausführung

```powershell
# Trockenlauf (prüft Policy & zeigt geplante Payloads ohne Inbox-Schreibvorgang)
.\Start-AutonomousSandboxTest.ps1 -DryRun

# Vollständiger autonomer Test (Auto wird automatisch vom Host gewählt, falls nicht in Sandbox)
.\Start-AutonomousSandboxTest.ps1 -Track monza

# Mit explizitem Fahrzeug
.\Start-AutonomousSandboxTest.ps1 -Car ks_porsche_911_gt3_r_2016 -Track ks_red_bull_ring
```

Nach dem Lauf wird automatisch ein Markdown-Bericht unter `Systemtests\Testbericht_Autonome_Sandbox_<timestamp>.md` abgelegt.
