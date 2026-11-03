# Git & Source Control in VS Code: Einsteiger-Anleitung zur Synchronisation

**Zielgruppe:** Einsteiger & neue Teammitglieder  
**Workspace:** `C:\Users\strik\git-labor`  
**Speicherort:** `C:\Users\strik\git-labor\#$_Lernmaterial_to_sort`  
**System:** Visual Studio Code / Google Antigravity & GitHub  

---

## 1. Das Grundprinzip: Die 3 Stationen deiner Dateien

Git speichert Änderungen nicht einfach direkt im Internet, sondern in drei Schritten. Dadurch behältst du immer die volle Kontrolle darüber, welche Dateien hochgeladen werden:

```mermaid
flowchart LR
    A["1. Arbeitsbereich<br>(Working Directory)<br><i>Dateien bearbeitet / neu</i>"] -->|"+" Klick<br>(Stage)| B["2. Vorbereitung<br>(Staged Changes)<br><i>Bereit zum Speichern</i>"]
    B -->|"Commit"<br>(Lokal sichern)| C["3. Lokales Git-Repo<br><i>Gespeichert auf deinem PC</i>"]
    C -->|"Sync Changes"<br>(Push)| D["4. GitHub Server<br>(Remote Repository)<br><i>Online gesichert</i>"]
```

1. **Arbeitsbereich (Changes / Untracked):** Du erstellst oder bearbeitest Dateien in VS Code.
2. **Staging-Bereich (Staged Changes):** Du wählst mit dem **`+`** gezielt aus, welche Änderungen in das nächste Paket gepackt werden sollen.
3. **Lokaler Commit:** Du schnürst das Paket mit einer kurzen Beschreibung (Nachricht) und speicherst es lokal auf deiner Festplatte.
4. **Synchronisation (Sync / Push):** Das Paket wird an den GitHub-Server übertragen (`origin/main`).

---

## 2. Wo finde ich die Source-Control-Erweiterung?

* **Per Mausklick:** Klicke in der linken Seitenleiste auf das **Verzweigungs-Symbol** (drei Punkte mit Verbindungslinien).
* **Per Tastatur:** Drücke **`Strg + Shift + G`**.

In dieser Ansicht siehst du die Liste aller geänderten und neuen Dateien:
* **Untracked (U):** Neue Dateien, die Git bisher noch gar nicht kennt.
* **Modified (M):** Existierende Dateien, an denen du etwas geändert hast.
* **Deleted (D):** Dateien, die du gelöscht hast.

> [!TIP]
> Wenn du in der Liste auf eine Datei klickst, öffnet sich der **Diff-Editor**:
> * **Rot (links):** Alter Stand vor deinen Änderungen.
> * **Grün (rechts):** Dein neuer Stand.

---

## 3. Schritt-für-Schritt-Ablauf für neue User

### Schritt 1: Dateien zum Commit hinzufügen (Staging / `git add`)
Nicht jede geänderte Datei muss sofort hochgeladen werden. Du entscheidest:

* **Einzelne Datei hinzufügen:** Fahre mit der Maus über die gewünschte Datei und klicke auf das kleine **`+`**-Symbol (**Stage Changes**).
* **Alle Dateien auf einmal hinzufügen:** Klicke in der Überschriftenzeile **Changes** ganz oben auf das **`+`**-Symbol (**Stage All Changes**).
* *Fehler gemacht?* Klicke neben der Datei auf das **`-`**-Symbol (**Unstage Changes**), um sie wieder aus der Vorbereitung zu entfernen.

Die Datei wandert nun in den Bereich **Staged Changes** (Bereitgestellte Änderungen).

---

### Schritt 2: Paket schnüren (Commit / `git commit`)
Sobald alle gewünschten Dateien unter **Staged Changes** stehen:

1. Klicke oben in das Eingabefeld **Message** (Nachricht).
2. Schreibe eine kurze, aussagekräftige Erklärung, was geändert wurde:
   * *Gute Beispiele:* 
     * `docs: Antigravity Port-Fehlerbehebung dokumentiert`
     * `fix: Startskript für Docker-Sandbox korrigiert`
     * `feat: Neue Lernmaterialien hinzugefügt`
3. Klicke auf den blauen Button **Commit** (oder drücke **`Strg + Enter`**).

*Ergebnis:* Deine Änderungen sind nun sicher in deiner lokalen Git-Historie auf dem PC gespeichert.

---

### Schritt 3: Mit dem GitHub-Server synchronisieren (Push & Pull / `git push`)
Damit deine Änderungen auch online auf GitHub landen und Teammitglieder sie sehen können:

1. Klicke in der Source-Control-Seitenleiste auf den blauen Button **Sync Changes** (oder unten links in der blauen Statusleiste auf das Kreis-/Pfeil-Symbol neben deinem Branch `main`).
2. VS Code führt jetzt zwei Schritte automatisch aus:
   * **Pull:** Holt eventuell vorhandene neue Änderungen vom GitHub-Server ab.
   * **Push:** Lädt deine lokalen Commits auf GitHub hoch.

Sobald der Ladebalken verschwindet, sind lokaler PC und GitHub-Server synchron!

---

## 4. Wichtig: Was gehört NICHT auf den GitHub-Server?

Einige Dateien dürfen **niemals** auf GitHub hochgeladen werden:
* **Passwörter & API-Keys** (z. B. `.env`-Dateien, Google Cloud Keys).
* **Sehr große Binärdaten oder Festplatten-Images** (z. B. Virtual Disks aus `ac-sandbox/storage/`).
* **Temporäre Systemdateien oder Node-Module** (`node_modules/`).

### Wie ignoriere ich Dateien dauerhaft?
1. Klicke in der Source Control Liste mit der **rechten Maustaste** auf die Datei oder den Ordner.
2. Wähle **Add to .gitignore** (Zur .gitignore hinzufügen).
3. Git trägt den Pfad automatisch in die Datei `.gitignore` ein und ignoriert ihn ab sofort.

---

## 5. Spickzettel & Tastenkürzel

| Aktion | Wo klicken? | Tastenkürzel | Terminal-Befehl |
| :--- | :--- | :--- | :--- |
| **Source Control öffnen** | Seitenleiste Verzweigungs-Icon | `Strg + Shift + G` | `git status` |
| **Datei vormerken (Stage)** | `+` neben der Datei | – | `git add <datei>` |
| **Alle vormerken** | `+` neben "Changes" | – | `git add .` |
| **Vormerkung aufheben** | `-` neben der Datei | – | `git restore --staged <datei>` |
| **Commit ausführen** | Blauer Button "Commit" | `Strg + Enter` | `git commit -m "Nachricht"` |
| **Mit GitHub syncen** | Blauer Button "Sync Changes" | – | `git pull && git push` |

---

## 6. Häufige Fragen & Troubleshooting

### Warum ist der Button "Sync Changes" nicht sichtbar?
Wenn du noch keinen Commit gemacht hast oder dein lokaler Stand bereits exakt dem Server entspricht, gibt es nichts zu synchronisieren. Sobald du einen Commit machst, erscheint der Button mit einer Ziffer (z. B. `1 ↑` = 1 Commit zum Hochladen bereit).

### Was tun bei "Merge Conflict" (Konflikt beim Synchronisieren)?
Wenn jemand anderes die gleiche Zeile auf dem Server geändert hat wie du:
1. VS Code markiert die betroffene Datei mit einem roten **`C`** (Conflict).
2. Öffne die Datei. Du siehst Buttons wie:
   * `Accept Current Change` (Deine lokale Version behalten)
   * `Accept Incoming Change` (Version vom Server übernehmen)
   * `Accept Both Changes` (Beide Versionen behalten)
3. Wähle die gewünschte Option, speichere mit `Strg + S` und klicke wieder auf `+` (Stage) & Commit.
