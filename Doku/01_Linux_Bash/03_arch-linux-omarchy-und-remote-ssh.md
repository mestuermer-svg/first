> **Thema:** Arch Linux, Omarchy (Hyprland), systemd-Dienste, Remote-SSH & Nginx-Webserver
> **Autor:** Michael Stürmer
> **Datum:** 08.11.2026

# 03 – Arch Linux, Omarchy, Remote-SSH & Webserver-Deployment

<details>
<summary><b>Lernziele</b></summary>

* Paketverwaltung unter **Arch Linux (`pacman`)** und Rolling-Release-Wartung fehlerfrei beherrschen.
* Die Vorzüge von **Linux Omarchy (Hyprland Wayland Compositor)** (inkl. `idle_inhibit` für Kiosk-Displays) und **Arch Linux ARM auf dem Raspberry Pi 4** als hochperformante Entwickler- und Server-Umgebungen verstehen.
* Sichere **SSH-Schlüssel (`ed25519`)**, `~/.ssh/config` und den **VS Code Remote-SSH Workflow** einrichten.
* Produktive Webserver (**Nginx** und **Caddy** als Reverse Proxy) sowie gehärtete **Node.js `systemd`-Livedienste** auf Arch Linux / Raspberry Pi 4 bereitstellen und verifizieren.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Paketverwaltung unter Arch Linux (<code>pacman</code>)</summary>

Arch Linux (sowie darauf basierende Umgebungen wie **Omarchy** oder **Arch Linux ARM auf dem Raspberry Pi 4**) folgt dem **Rolling-Release-Prinzip** und nutzt den blitzschnellen C-basierten Paketmanager **`pacman`**:

| Befehl | Funktion | Beschreibung |
| :--- | :--- | :--- |
| `sudo pacman -Syu` | **System-Update** | Synchronisiert Paketdatenbanken und aktualisiert alle Systempakete in einem konsistenten Schritt. |
| `sudo pacman -S <paket>` | **Installieren** | Installiert Pakete (z. B. `sudo pacman -S git nginx python nodejs`). |
| `pacman -Ss <suchbegriff>` | **Suchen** | Durchsucht Paket-Repositories nach Namen und Beschreibungen. |
| `pacman -Qi <paket>` | **Paket-Info** | Zeigt Version, Abhängigkeiten, Lizenz und Installationsgröße an. |
| `sudo pacman -Rns <paket>` | **Sauber entfernen** | Deinstalliert das Paket inklusive verwaister Abhängigkeiten (`-s`) und Konfigurationsdateien (`-n`). |
| `sudo pacman -Sc` | **Cache bereinigen** | Entfernt alte Paket-Tarballs aus `/var/cache/pacman/pkg/`. |

</details>

<details>
<summary>1.2 Hintergrunddienste steuern mit <code>systemd</code> & <code>journalctl</code></summary>

Server-Dienste (wie `sshd`, `nginx`, `docker` oder eigene KI-Worker) werden unter Linux über **`systemd`** als Units verwaltet:

```bash
# Status eines Dienstes prüfen (Aktivität, PID, RAM-Verbrauch, letzte Logs)
sudo systemctl status sshd

# Dienst sofort starten / neu starten / stoppen
sudo systemctl start nginx
sudo systemctl restart nginx
sudo systemctl stop nginx

# Dienst im Systemstart verankern und sofort ausführen (--now)
sudo systemctl enable --now nginx

# Konfiguration ohne Verbindungsabbruch neu einlesen (Hot-Reload)
sudo systemctl reload nginx

# Live-Protokolle (Logs) eines bestimmten Dienstes auslesen
journalctl -u nginx -n 50 -f
```

</details>

<details>
<summary>1.3 Linux Omarchy & Hyprland (Tastatur-zentrierter Entwickler-Workflow)</summary>

**Omarchy** kombiniert Arch Linux mit dem modernen Wayland-Tiling-Window-Manager **Hyprland**:
* **Minimaler Overhead:** Kein schwerer Desktop-Unterbau (wie GNOME oder KDE) – ideal für Arbeitsplatz-Laptops, damit maximal viel Arbeitsspeicher für Sprachmodelle, Container und Compiler frei bleibt.
* **Tiling-Prinzip:** Fenster ordnen sich automatisch kachelförmig auf virtuellen Desktops (*Workspaces 1–9*) an.
* **Kiosk- & Dauerbetrieb (`idle_inhibit` / Screensaver-Schutz & `Pitwall.desktop`):** Für dauerhaft laufende Monitore (z. B. das Pitwall-Dashboard auf **Archibald** `192.168.178.98`) verhindert Hyprland über Fensterregeln in `~/.config/hypr/hyprland.lua` (`idle_inhibit = "always"`) sowie `omarchy-toggle-idle stay-awake` und `omarchy-toggle screensaver-off on` zuverlässig das Abdunkeln durch `hypridle` oder den Screensaver. Zusätzlich stellt `~/ac-pitwall/launch_pitwall.sh` samt `~/.local/share/applications/Pitwall.desktop` (mit eigenem Icon `pitwall.png`/`pitwall.svg`) sicher, dass die Pitwall jederzeit über den Omarchy App-Launcher (`SUPER + SPACE` $\rightarrow$ *Pitwall*) oder automatisch nach dem Aufwecken via `wake_archibald.ps1` im Vollbild auf Workspace 1 eingeblendet wird.
* **Linux-Workspace-Einstellungen in VS Code:**
  Unter Linux ist darauf zu achten, dass Zeilenenden auf **`LF` (`\n`)** statt `CRLF` (`\r\n`) stehen, damit Bash-Skripte nicht mit `bad interpreter: ^M` abbrechen:
  ```json
  {
    "terminal.integrated.defaultProfile.linux": "bash",
    "files.eol": "\n"
  }
  ```

</details>

<details>
<summary>1.4 SSH-Schlüssel (<code>ed25519</code>) & <code>~/.ssh/config</code></summary>

Für die sichere, passwortlose Verbindung zwischen deinem Windows-11-Hauptarbeitsplatz (`VanstrikeCyborg`), Linux-Laptops und Headless-Servern (Raspberry Pi 4) wird das moderne **Ed25519-Verfahren** eingesetzt:

```bash
# 1. Schlüsselpaar auf dem Arbeitsplatz erzeugen (falls noch nicht vorhanden)
ssh-keygen -t ed25519 -C "strik@VanstrikeCyborg"

# 2. Öffentlichen Schlüssel auf das Linux-Zielsystem übertragen
ssh-copy-id -i ~/.ssh/id_ed25519.pub alarm@192.168.178.50
```

Über die Datei **`~/.ssh/config`** (unter Windows `C:\Users\strik\.ssh\config`) definierst du sprechende Aliase:

```sshconfig
# Linux Edge-Server / Raspberry Pi 4 (Arch Linux ARM)
Host pi4
    HostName 192.168.178.50
    User alarm
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Linux Laptop (Omarchy)
Host omarchy
    HostName 192.168.178.55
    User strik
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

</details>

<details>
<summary>1.5 VS Code Remote-SSH: Lokale UI, Remote-Ausführung</summary>

Mit der Erweiterung **VS Code Remote - SSH (`ms-vscode-remote.remote-ssh`)** bleibt die grafische Benutzeroberfläche auf deinem Hauptgerät, während der **VS Code Remote Server**, das Terminal und alle Sprachserver direkt auf dem entfernten Linux-Host laufen:

```mermaid
flowchart LR
    subgraph Client ["Hauptarbeitsplatz (VanstrikeCyborg)"]
        UI["VS Code Editor & UI-Renderer"]
        COPILOT["Copilot Chat / Antigravity Client"]
    end

    subgraph Remote ["Arch Linux Server (Raspberry Pi 4 / Omarchy)"]
        SRV["VS Code Remote Extension Host"]
        SH["Bash Shell & Werkzeuge"]
        SRV_NGINX["Nginx Webserver (:80 / :443)"]
        PYTHON["Python venv & Git-Repo"]
        SRV --> SH
        SRV --> PYTHON
    end

    UI <-->|"Verschlüsselter SSH-Tunnel (:22)"| SRV
```

1. In VS Code `Strg + Shift + P` $\rightarrow$ **`Remote-SSH: Connect to Host...`**
2. Wähle den Host aus deiner Konfiguration (z. B. `pi4`).
3. Öffne den Projektordner direkt auf dem Remote-System – ohne langsame Dateisynchronisation oder Pfadkonflikte.

</details>

<details>
<summary>1.6 Nginx Webserver auf Arch Linux / Raspberry Pi 4 einrichten</summary>

Der Leichtbau-Webserver **Nginx** eignet sich optimal für ressourcenschonende Serverumgebungen:

```bash
# 1. Nginx installieren
sudo pacman -S nginx

# 2. Standard-Webroot anlegen und Testseite erstellen
sudo mkdir -p /srv/http/git-labor
sudo chown -R alarm:alarm /srv/http/git-labor

cat << 'EOF' > /srv/http/git-labor/index.html
<!DOCTYPE html>
<html lang="de">
<head><meta charset="utf-8"><title>git-labor Server</title></head>
<body style="font-family: sans-serif; background: #0f172a; color: #f8fafc; padding: 40px;">
  <h1>🚀 git-labor Webserver auf Arch Linux (Pi 4)</h1>
  <p>Bereitgestellt via Nginx &amp; systemd.</p>
</body>
</html>
EOF

# 3. Nginx Serverblock (/etc/nginx/nginx.conf bzw. /etc/nginx/sites-available/)
# Minimaler Serverblock in der http-Sektion von /etc/nginx/nginx.conf:
# server {
#     listen 80;
#     server_name pi4.local;
#     root /srv/http/git-labor;
#     index index.html;
#     location / {
#         try_files $uri $uri/ =404;
#     }
# }

# 4. Konfiguration auf Syntaxfehler prüfen (lebensrettend vor jedem Reload!)
sudo nginx -t

# 5. Dienst aktivieren und starten
sudo systemctl enable --now nginx
```

</details>

<details>
<summary>1.7 Praxis-Setup: Caddy-Webserver, Reverse Proxy &amp; gehärtete Node.js systemd-Dienste (StrikerPi)</summary>

Auf unserem produktiven Edge-Hub **StrikerPi (`192.168.178.86`, Arch Linux ARM)** läuft statt Nginx der moderne Go-Webserver **Caddy (`:80`)** zusammen mit einem eigenen Node.js-Systemd-Livedienst (`gitlabor-api.service` auf `127.0.0.1:8085`). Die vollständigen Konfigurations- und Quell-Dateien liegen im Workspace unter [`labs/01_linux_bash/strikerpi-services/`](../../labs/01_linux_bash/strikerpi-services/).

#### 1. Warum Caddy als Edge-Webserver & Reverse Proxy?
* **Modulare Konfiguration:** `/etc/caddy/Caddyfile` bindet über `import /etc/caddy/conf.d/*.caddy` gezielt Teilkonfigurationen (z. B. `git-labor.caddy`) ein und nutzt den Admin-Socket `unix//run/caddy/admin.socket`.
* **Eingebauter Reverse Proxy & WebSockets:** Anfragen an `/api/linux/*` gehen intern an `127.0.0.1:8085` (Node.js-API) und `/mqtt*` an `127.0.0.1:9001` (Mosquitto WebSockets), während statische Webseiten aus `/srv/git-labor/web` mit `gzip`/`zstd` ausgeliefert werden.
* **Strukturierte Access-Logs:** Caddy schreibt jeden HTTP-Request im JSON-Format nach `/var/log/caddy/gitlabor-access.log` (mit automatischer Log-Rotation: `roll_size 5MiB`, `roll_keep 3`).

```caddyfile
:80 {
    root * /srv/git-labor/web
    encode gzip zstd

    log {
        output file /var/log/caddy/gitlabor-access.log {
            roll_size 5MiB
            roll_keep 3
        }
        format json
    }

    handle /api/linux/* {
        reverse_proxy 127.0.0.1:8085
    }

    handle /mqtt* {
        reverse_proxy 127.0.0.1:9001
    }

    handle {
        file_server {
            browse
        }
    }
}
```

```bash
# Caddy-Konfiguration formatieren, prüfen und ohne Verbindungsabbruch neu laden
sudo caddy fmt --overwrite /etc/caddy/Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl reload caddy.service
```

#### 2. Gehärteter Node.js-Livedienst (`gitlabor-api.service`)
Das Backend [`gitlabor-api.mjs`](../../labs/01_linux_bash/strikerpi-services/gitlabor-api.mjs) läuft ausschließlich auf Loopback (`127.0.0.1:8085`) und ist von außen nur über den Caddy Reverse Proxy erreichbar. Die zugehörige Unit [`gitlabor-api.service`](../../labs/01_linux_bash/strikerpi-services/gitlabor-api.service) demonstriert zentrale **Systemd-Sandboxing-Direktiven**:

```ini
[Service]
Type=simple
ExecStart=/usr/bin/node /srv/git-labor/apps/linux-monitor-api/server.mjs
WorkingDirectory=/srv/git-labor/apps/linux-monitor-api
Restart=always
RestartSec=3

# Linux-Service-Isolation (minimale Rechte)
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=strict
ReadOnlyPaths=/var/log/caddy /sys/class/thermal
```

| Direktive | Sicherheitswirkung |
| :--- | :--- |
| **`NoNewPrivileges=true`** | Verhindert Privilege Escalation durch Kindprozesse. |
| **`PrivateTmp=true`** | Isoliert `/tmp` und `/var/tmp` pro Dienst. |
| **`ProtectHome=true`** | Sperrt jeglichen Zugriff auf `/home` und `/root`. |
| **`ProtectSystem=strict`** | Setzt das gesamte Dateisystem auf Read-Only (außer explizite Ausnahmen). |
| **`ReadOnlyPaths=...`** | Erlaubt gezielten Lesezugriff auf Caddy-Logs und CPU-Temperatursensor (`/sys/class/thermal`). |

* **Bereitgestellte Live-Endpunkte (via `http://192.168.178.86/api/linux/...`):** `GET /health`, `GET /status` (Systemd-Units, RAM, CPU-Temp, Load), `GET /ports` (`ss -tulpnH`), `GET /logs?unit=...` (`journalctl` + Caddy Access-Log) und `POST /echo` (Proxy-Header-Roundtrip).
* **Automatisierung über `@rick`:** Der Worker [`rick_worker.py`](../../labs/01_linux_bash/strikerpi-services/rick_worker.py) verwaltet Caddy & Dienst-Neustarts über die Inbox-Actions `setup_caddy_gitlabor`, `caddy_validate`, `caddy_reload`, `caddy_status`, `build_ts_labs` und `restart_gitlabor_api`.

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Pacman-Diagnose:** Führe auf einem Arch-System `pacman -Qi nginx` oder `pacman -Qi caddy` aus und identifiziere Konfigurationsdateien sowie Abhängigkeiten.
2. **Konfigurations-Syntaxcheck:** Prüfe die Webserver-Konfiguration vor einem Reload mit `sudo nginx -t` bzw. `sudo caddy validate --config /etc/caddy/Caddyfile`. Welchen Exit-Code liefert ein absichtlicher Syntaxfehler?
3. **SSH Keep-Alive:** Warum bricht eine SSH-Sitzung ab, wenn der Laptop für 15 Minuten zugeklappt wird, und wie verhindert der Parameter `ServerAliveInterval 60` in `~/.ssh/config` diesen Abbruch?
4. **Systemd-Härtung prüfen:** Vergleiche die Direktiven in [`gitlabor-api.service`](../../labs/01_linux_bash/strikerpi-services/gitlabor-api.service) und prüfe auf StrikerPi mit `systemd-analyze security gitlabor-api.service`, wie die Isolation bewertet wird.

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [ArchWiki – Pacman Paketmanager](https://wiki.archlinux.org/title/Pacman)
* [ArchWiki – Nginx Webserver Setup & Tuning](https://wiki.archlinux.org/title/Nginx)
* [Offizielle Caddy Dokumentation – Caddyfile & Reverse Proxy](https://caddyserver.com/docs/caddyfile)
* [Systemd Exec Sandboxing (ProtectSystem, ProtectHome)](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html)
* [VS Code Remote Development via SSH](https://code.visualstudio.com/docs/remote/ssh)
* [Hyprland Wayland Compositor Wiki](https://wiki.hyprland.org/)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **`pacman -Syu` vor Neuinstallationen:** Halte Rolling-Release-Systeme stets synchron, um Bibliotheksinkonsistenzen zu vermeiden.
* **Syntaxcheck vor Reload:** Lade Webserver niemals blind neu – nutze `nginx -t` bzw. `caddy validate --config /etc/caddy/Caddyfile`.
* **Reverse Proxy + Loopback-API:** Binde interne Backend-Dienste (wie `gitlabor-api.service` auf `127.0.0.1:8085`) nur an `127.0.0.1` und veröffentliche sie kontrolliert über Caddy (`:80`) inkl. `ProtectSystem=strict` und `ProtectHome=true`.
* **Entkoppelte Entwicklung:** Mit VS Code Remote-SSH programmierst du mit gewohntem Komfort auf dem Laptop, während Build, Tests und Webserver direkt auf dem Linux-Host (Pi 4 / Omarchy) laufen.
* **Keep-Alive im SSH-Tunnel:** `ServerAliveInterval 60` in `~/.ssh/config` schützt langlebige Remote-Sitzungen vor NAT-Timeouts im Heimnetzwerk.

</details>

---
*Hinweis zur Organisation:* Die erstellte Dokumentation ist am Drehlaufwerk abgelegt und mit einer kurzen Zusammenfassung von den Chips auch in den Notebooks verlinkt.
