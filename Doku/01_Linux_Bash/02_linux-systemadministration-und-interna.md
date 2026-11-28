> **Thema:** Linux Systemadministration, Kernel-Interna, LVM, Prozesse, Boot-Prozess & Sicherheit
> **Autor:** Michael Stürmer
> **Datum:** 08.11.2026

# 02 – Linux Systemadministration, Speicherverwaltung & System-Interna

<!-- DOKU-SUBNAV-START -->
<details>
<summary><b>🧭 Rubrik-Navigation &amp; Modul-Übersicht (01 Linux & Bash)</b></summary>

**Zentrale:** [📚 Doku-Index](../README.md) · [📂 Rubrik 01 Linux & Bash](./README.md) · **Vorheriges:** [⬅️ 01 • Bash CLI, Text-Tools, Streams & Expansions](./01_bash-grundlagen-und-skripting.md) · **Nächstes:** [03 • Arch Linux, Omarchy, Remote-SSH & Nginx ➡️](./03_arch-linux-omarchy-und-remote-ssh.md)

**Alle Module in `01_Linux_Bash/`:**
- [01 • Bash CLI, Text-Tools, Streams & Expansions](./01_bash-grundlagen-und-skripting.md) · `check-env.sh`
- 👉 **[02 • Inodes, LVM, Prozesse, Boot-Prozess & systemd](./02_linux-systemadministration-und-interna.md)** *(aktuell)*
- [03 • Arch Linux, Omarchy, Remote-SSH & Nginx](./03_arch-linux-omarchy-und-remote-ssh.md)
- [04 • Advanced Bash: Arrays, getopts & Backups](./04_fortgeschrittenes-bash-skripting-und-automatisierung.md)
- [05 • Docker Grundlagen & Sandbox Micro-VMs (sbx)](./05_docker-und-sbx-micro-vms.md)

**Weitere Rubriken:** [🧩 02 VS Code & MCP](../02_VSCode_Env/README.md) · [🐍 03 Python](../03_Python_Coding/README.md) · [🌐 04 JS/TS Web](../04_JS_TS_Web/README.md) · [🤖 05 Agents](../05_Agents/README.md) · [🏎️ 06 AC KN5 Modding](../06_AC_KN5_Modding/README.md) · [🥽 07 VR Engineering](../07_VR_Engineering/README.md)

</details>
<!-- DOKU-SUBNAV-END -->

<details>
<summary><b>Lernziele</b></summary>

* Die Unix-Philosophie **„Everything is a file“**, Inodes, Hardlinks und symbolische Links (`ln -s`) tiefgreifend verstehen.
* Benutzer-, Gruppen- und Rechtestrukturen (`/etc/passwd`, `/etc/shadow`, `sudoers`, `chmod`, `chown`, `umask`, **SUID, SGID, Sticky-Bit**) sicher konfigurieren.
* Linux-**Prozesse, Signale (`SIGTERM`, `SIGKILL`, `SIGHUP`)**, Prozesszustände (Zombie, Sleeping, Running) und **Job Control (`&`, `jobs`, `fg`, `bg`, `nohup`)** beherrschen.
* Die Funktionsweise des **Linux Boot-Prozesses (UEFI/BIOS → GRUB → Kernel/Initramfs → systemd Targets)** und die Reparatur fehlerhafter Boot-Konfigurationen verstehen.
* Speicher, Partitionen und **Logical Volume Management (LVM: PV, VG, LV)** im laufenden Betrieb verwalten und Dateisysteme (`ext4`, `btrfs`, `xfs`) über `/etc/fstab` einbinden.
* Netzwerk-Telemetrie und Paketdiagnose (`ip a`, `ss -tulpn`, `dig`, `curl`, `tcpdump`, Wireshark) anwenden sowie Systeme mit **`firewalld`** und **SELinux** härten.

</details>

<details>
<summary><b>Kernkonzepte</b></summary>

<details>
<summary>1.1 Unix-Philosophie: „Everything is a file“ & Inodes</summary>

Unter Linux wird fast jede Ressource (Dateien, Verzeichnisse, Festplatten, Sockets, Pipes, Prozessinformationen) als Byte-Strom über Dateideskriptoren angesprochen:
* **Inodes (Index Nodes):** Jeder Datenträger besitzt eine Inode-Tabelle. Eine Inode speichert Metadaten einer Datei (Größe, Besitzer-UID, Gruppen-GID, Zugriffsrechte, Zeitstempel, Block-Zeiger auf der Festplatte) – jedoch **nicht** den Dateinamen!
* **Verzeichnis als Tabelle:** Ein Ordner ist eine Datei, die Dateinamen den entsprechenden Inode-Nummern zuordnet.
* **Hardlink vs. Softlink (Symlink):**
  * **Hardlink (`ln quelle ziel`):** Ein zweiter Dateiname, der auf dieselbe Inode-Nummer verweist. Wird die Originaldatei gelöscht, bleiben die Daten erhalten, solange der Inode-Link-Counter > 0 ist. Funktioniert nur innerhalb desselben Dateisystems.
  * **Symbolischer Link / Symlink (`ln -s quelle ziel`):** Eine eigenständige kleine Datei mit eigener Inode, die den Pfad zur Zieldatei enthält (wie eine Verknüpfung unter Windows). Kann dateisystem- und rechnerübergreifend zeigen.

```bash
# Inode-Nummer einer Datei anzeigen (-i)
ls -li datei.txt

# Hardlink erstellen (beide teilen sich dieselbe Inode)
ln original.txt hardlink.txt

# Softlink (Symlink) erstellen
ln -s /var/log/nginx/access.log ~/web_access.log

# Gerätedateien in /dev prüfen
ls -l /dev/sda       # Block-Device (b) für Festplatte
ls -l /dev/urandom   # Character-Device (c) für Zufallszahlen
ls -l /dev/null      # Das Null-Gerät (wirft alle Daten weg)
```

</details>

<details>
<summary>1.2 Benutzer-, Gruppen- und Berechtigungsverwaltung</summary>

Linux unterscheidet strikt zwischen Systembenutzern (Dienste wie `nginx`, `systemd-resolve`) und menschlichen Benutzern:

| Datei | Bedeutung | Sicherheitsrelevanz |
| :--- | :--- | :--- |
| `/etc/passwd` | Liste aller Benutzerkonten (UID, GID, Home-Pfad, Login-Shell) | Für alle lesbar (`644`), Passwörter sind hier durch `x` maskiert |
| `/etc/shadow` | Verschlüsselte Passwort-Hashes (z. B. SHA-512 / yescrypt) | Nur für Root lesbar (`600` / `640`) |
| `/etc/group` | Definition aller Benutzergruppen und deren Mitglieder | Für alle lesbar (`644`) |
| `/etc/sudoers` | Reglementiert, welche Benutzer administrative Rechte via `sudo` erhalten | Niemals direkt editieren, sondern immer mit `sudo visudo` (Syntaxprüfung!) |

```bash
# Neuen Benutzer mit Home-Verzeichnis und Bash-Shell anlegen
sudo useradd -m -s /bin/bash entwickler

# Passwort für den Benutzer vergeben
sudo passwd entwickler

# Benutzer zu einer Gruppe hinzufügen (z. B. docker, wheel oder sudo)
sudo usermod -aG docker entwickler

# Eigene UID, GID und Gruppenmitgliedschaften anzeigen
id
```

</details>

<details>
<summary>1.3 Erweiterte Dateirechte: umask & Spezial-Bits (SUID, SGID, Sticky-Bit)</summary>

Neben den Standardrechten (`rwx` für User, Group, Others) existieren drei spezielle Berechtigungsbits:

1. **SUID (Set User ID, Oktalwert 4000):** Wird auf ausführbare Binärdateien gesetzt. Das Programm läuft mit den Rechten des Dateibesitzers (oft `root`), egal wer es ausführt (z. B. `/usr/bin/passwd`).
2. **SGID (Set Group ID, Oktalwert 2000):** 
   * Auf Binärdateien: Läuft mit den Rechten der Gruppe.
   * Auf Verzeichnissen: Alle neu erstellten Dateien erben automatisch die Gruppen-ID des Verzeichnisses (unverzichtbar für Team-Freigaben).
3. **Sticky-Bit (Oktalwert 1000):** Auf Verzeichnissen verhindert es, dass Benutzer Dateien anderer Benutzer löschen oder umbenennen können, selbst wenn sie Schreibrecht im Ordner besitzen.
4. **`umask` (User Mask):** Bestimmt die Standardrechte neu erstellter Dateien (Standard meist `022` $\rightarrow$ Dateien erhalten `644`, Ordner `755`).

```bash
# Sticky-Bit setzen (Standard für /tmp):
chmod 1777 /tmp
ls -ld /tmp
# Ausgabe: drwxrwxrwt ... (das 't' am Ende signalisiert das Sticky-Bit)

# SGID auf ein Projektverzeichnis setzen (Gruppen-Vererbung):
chmod 2775 /srv/projekt-team
chmod g+s /srv/projekt-team

# SUID auf ein Skript/Binary setzen:
chmod u+s /usr/local/bin/spezial-tool
```

</details>

<details>
<summary>1.4 Linux-Prozesse, Signale & Monitoring (ps, top, kill)</summary>

Jedes gestartete Programm ist ein Prozess mit eindeutiger Prozess-ID (**PID**), Elternprozess-ID (**PPID**) und Besitzer:
* **Prozesszustände:**
  * `R` (Running / Runnable): Wird gerade auf der CPU ausgeführt oder wartet im Scheduler.
  * `S` (Interruptible Sleep): Wartet auf ein Ereignis (I/O, Tastendruck, Timer).
  * `D` (Uninterruptible Sleep): Wartet meist auf Festplatten- oder Hardware-I/O (kann nicht mit `kill` beendet werden!).
  * `Z` (Zombie): Beendeter Prozess, dessen Exit-Status noch nicht vom Elternprozess via `wait()` abgeholt wurde.
* **Wichtige POSIX-Signale:**
  * `SIGTERM` (15): Höfliche Aufforderung zum Beenden (Dienst kann Sockets schließen und aufräumen).
  * `SIGKILL` (9): Unmittelbare Terminierung durch den Kernel (kann vom Prozess nicht abgefangen werden).
  * `SIGHUP` (1): Hangup – signalisiert vielen Daemons (Nginx, SSH), die Konfiguration neu einzulesen.
  * `SIGINT` (2): Interrupt von der Tastatur (`Ctrl + C`).

```bash
# Prozess-Übersicht anzeigen
ps aux | grep nginx               # Nach Nginx-Prozessen filtern
pstree -p                         # Prozessbaum mit PIDs anzeigen
htop                              # Interaktiver Prozess-Monitor

# Signale an Prozesse senden
kill -15 1234                     # Beenden via SIGTERM (Standard)
kill -9 1234                      # Sofortiges Zwangs-Killen via SIGKILL
kill -HUP $(cat /var/run/nginx.pid) # Nginx Konfiguration ohne Neustart neu laden
pkill -f "python worker.py"       # Alle Prozesse mit dem Namen terminieren
```

</details>

<details>
<summary>1.5 Job Control: Hintergrund-Jobs, nohup & disown</summary>

Wenn ein Terminal geschlossen wird oder eine SSH-Verbindung abreißt, sendet der Kernel `SIGHUP` an alle Kindprozesse, was diese beendet. **Job Control** ermöglicht langlebige Hintergrundprozesse:

```bash
# 1. Befehl direkt im Hintergrund starten (&)
python langlaeufer.py &
# Ausgabe: [1] 45892 (Job-Nummer 1, PID 45892)

# 2. Laufenden Vordergrund-Prozess anhalten und in den Hintergrund schieben
# Im Terminal: Ctrl + Z drücken (sendet SIGTSTP)
bg                                # Hält den angehaltenen Job im Hintergrund am Laufen
jobs -l                           # Alle aktiven Jobs dieses Terminals auflisten
fg %1                             # Job 1 wieder in den Vordergrund holen

# 3. Prozess immun gegen Verbindungsabbrüche machen (nohup)
nohup python datenverarbeitung.py > output.log 2>&1 &

# 4. Bereits laufenden Hintergrund-Job von der aktuellen Shell abkoppeln
disown %1
```

</details>

<details>
<summary>1.6 Paketverwaltung im Vergleich: pacman, apt & dnf</summary>

Linux-Distributionen unterscheiden sich primär durch ihren Paketmanager:

| Aufgabe | Arch Linux (`pacman`) | Debian / Ubuntu (`apt`) | RHEL / Fedora / CentOS (`dnf`) |
| :--- | :--- | :--- | :--- |
| **Paketdatenbanken aktualisieren** | `sudo pacman -Sy` | `sudo apt update` | `sudo dnf check-update` |
| **Vollständiges System-Upgrade** | `sudo pacman -Syu` | `sudo apt upgrade` / `dist-upgrade` | `sudo dnf upgrade` |
| **Paket installieren** | `sudo pacman -S git` | `sudo apt install git` | `sudo dnf install git` |
| **Paket suchen** | `pacman -Ss nginx` | `apt search nginx` | `dnf search nginx` |
| **Paket mit Abhängigkeiten löschen** | `sudo pacman -Rns paket` | `sudo apt autoremove --purge paket` | `sudo dnf remove paket` |
| **Integritätsprüfung installierter Dateien** | `pacman -Qk` | `debsums -c` | `rpm -Va` |

**Umgang mit Paket- & Abhängigkeitskonflikten:**
Bei Upgrades können Konflikte auftreten (z. B. zwei Bibliotheken erfordern unterschiedliche Versionen desselben Pakets). Vorgehensweise:
1. Paket-Cache leeren und Mirrors synchronisieren.
2. Prüfen, welches Paket die kollidierende Datei besitzt (`pacman -Qo /pfad/datei` bzw. `dpkg -S /pfad/datei`).
3. Veraltete PPA-/Third-Party-Quellen temporär deaktivieren.

</details>

<details>
<summary>1.7 Der Linux Boot-Prozess: UEFI/BIOS bis systemd Targets</summary>

Der Startvorgang eines modernen Linux-Systems läuft in 5 exakt definierten Phasen ab:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Phase 1     │────▶│  Phase 2     │────▶│  Phase 3     │────▶│  Phase 4     │────▶│  Phase 5     │
│  UEFI / BIOS │     │  GRUB Boot-  │     │  Kernel &    │     │  systemd     │     │  Target-     │
│  POST & ESP  │     │  loader      │     │  Initramfs   │     │  (PID 1)     │     │  Erreichung  │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
```

1. **UEFI / BIOS:** Führt Power-On Self-Test (POST) durch und lädt den Bootloader aus der EFI-Systempartition (`/boot/efi`).
2. **GRUB 2 (Grand Unified Bootloader):** Zeigt das Bootmenü an, lädt den komprimierten Kernel (`vmlinuz`) und das initiale RAM-Dateisystem (`initramfs`).
3. **Kernel-Initialisierung:** Der Kernel erkennt CPUs, RAM und PCI-Geräte, lädt minimale Treiber aus dem `initramfs`, bindet das echte Root-Dateisystem (`/`) schreibgeschützt ein und übergibt die Kontrolle an den ersten Userspace-Prozess: **systemd (PID 1)**.
4. **systemd Initialization:** systemd liest die Konfiguration aus `/etc/systemd/system` und startet abhängigkeitsgesteuert Systemdienste parallel.
5. **Systemd Targets (Ersatz für SysV-Runlevels):**
   * `emergency.target`: Minimalste Root-Shell bei beschädigtem Dateisystem.
   * `rescue.target`: Single-User-Wartungsmodus.
   * `multi-user.target`: Normaler Headless-Serverbetrieb (Netzwerk, SSH, Webserver aktiv, ohne GUI).
   * `graphical.target`: Voller Desktop-Betrieb (inkl. Display-Manager wie GDM oder SDDM).

```bash
# Aktuelles Standard-Target ermitteln
systemctl get-default

# Auf reinen Server-Betrieb (ohne GUI) umstellen:
sudo systemctl set-default multi-user.target
```

</details>

<details>
<summary>1.8 Speicher, Partitionen & Logical Volume Management (LVM)</summary>

Klassische Partitionen haben feste Größen und lassen sich bei volllaufenden Platten nur schwer vergrößern. **LVM (Logical Volume Manager)** fügt eine flexible Abstraktionsschicht zwischen physischen Festplatten und Dateisystemen ein:

* **PV (Physical Volume):** Eine physische Partition oder Festplatte (z. B. `/dev/sdb1`), die für LVM initialisiert wurde.
* **VG (Volume Group):** Ein Speicher-Pool, der mehrere PVs zusammenfasst (virtuelle Festplatte).
* **LV (Logical Volume):** Die eigentliche Partition, auf der das Dateisystem (`ext4`, `xfs`) liegt.

```bash
# 1. Festplatten und Blockgeräte inspizieren
lsblk -f                          # Zeigt UUIDs, Dateisysteme und Mountpoints
sudo fdisk -l                     # Detaillierte Partitionsübersicht

# 2. LVM einrichten:
# Festplatte als Physical Volume markieren:
sudo pvcreate /dev/sdb1
# Volume Group "vg_storage" erstellen:
sudo vgcreate vg_storage /dev/sdb1
# Logical Volume "lv_data" mit 50 GB Größe anlegen:
sudo lvcreate -L 50G -n lv_data vg_storage

# 3. Dateisystem anlegen und einhängen:
sudo mkfs.ext4 /dev/vg_storage/lv_data
sudo mkdir -p /mnt/daten
sudo mount /dev/vg_storage/lv_data /mnt/daten

# 4. Logical Volume im laufenden Betrieb vergrößern (Online-Expansion):
sudo lvextend -L +20G /dev/vg_storage/lv_data
sudo resize2fs /dev/vg_storage/lv_data   # Dateisystem auf neue Größe anpassen (ext4)
# Für XFS-Dateisysteme: xfs_growfs /mnt/daten

# 5. Dauerhafte Mounts in /etc/fstab hinterlegen (immer UUID nutzen!):
# UUID=xxxx-xxxx /mnt/daten ext4 defaults 0 2
```

</details>

<details>
<summary>1.9 Systemd Timer vs. Cronjobs</summary>

Regelmäßige Aufgaben (Backups, Log-Rotation, Aufräumarbeiten) wurden früher über `cron` abgewickelt. Unter modernem Linux sind **systemd Timer** der überlegene Standard:

| Feature | Cron (`/etc/crontab`) | systemd Timer (`*.timer`) |
| :--- | :--- | :--- |
| **Logging** | Begrenzt (Syslog/Mail) | Vollständig integriert in `journalctl -u dienst` |
| **Abhängigkeiten** | Keine (startet blind zur Uhrzeit) | Startet nur, wenn Netzwerk, Mount oder Dienst bereit ist |
| **Nachholen verpasster Läufe** | Erfordert `anacron` | Eingebaut via `Persistent=true` |
| **Ressourcenbegrenzung** | Nein | Vollständiges cgroups-Throttling (CPU, RAM, I/O) |

```ini
# Beispiel /etc/systemd/system/backup.timer
[Unit]
Description=Taegliches Backup-Skript

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
# Timer aktivieren und Liste aller aktiven Timer anzeigen
sudo systemctl enable --now backup.timer
systemctl list-timers
```

</details>

<details>
<summary>1.10 Netzwerk-Administration, Port-Diagnose & Wireshark/tcpdump</summary>

Netzwerkfehler auf Servern lassen sich systematisch von Layer 1 bis Layer 7 diagnostizieren:

```bash
# Layer 2 & 3: IP-Adressen und Routing prüfen
ip a                              # Netzwerkschnittstellen und IP-Adressen (Ersatz für ifconfig)
ip r                              # Routing-Tabelle (Default Gateway)

# Layer 4: Offene Ports & lauschende Dienste prüfen
ss -tulpn                         # t=TCP, u=UDP, l=Listening, p=Prozess, n=Numerisch
# Findet schnell heraus, welcher Dienst Port 80, 1883 (MQTT), 8080 (Pitwall) oder 11434 (Ollama) belegt!

# Layer 7: DNS-Auflösung & HTTP-Verbindung
cat /etc/resolv.conf              # Aktive Nameserver (DNS)
dig +short google.com             # DNS-Abfrage
curl -Iv https://example.com      # HTTP-Header und TLS-Handshake analysieren

# Paket-Mitschnitt für Tiefendiagnose (tcpdump / Wireshark)
sudo tcpdump -i eth0 port 80 -w http_traffic.pcap  # In Datei schreiben
# Diese .pcap-Datei kann anschließend in Wireshark geöffnet und detailliert analysiert werden!
```

</details>

<details>
<summary>1.11 Server-Absicherung: Firewalls (firewalld/ufw) & SELinux</summary>

Ein Linux-Server darf niemals ungeschützt ins Netz gestellt werden:

```bash
# 1. Firewall mit firewalld steuern (RHEL/CentOS/Fedora)
sudo firewall-cmd --state
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=11434/tcp   # z. B. Ollama LAN-Zugriff (Altlast Proxy :8317 entfernt)
sudo firewall-cmd --reload

# 2. Firewall mit ufw steuern (Ubuntu/Debian)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable

# 3. SELinux (Security-Enhanced Linux) verstehen:
# Status prüfen (Enforcing, Permissive, Disabled)
sestatus

# SELinux-Kontexte von Dateien anzeigen (-Z)
ls -Z /var/www/html/
# Ausgabe: system_u:object_r:httpd_sys_content_t:s0 ...

# Kontext reparieren, falls Webserver 403 Forbidden meldet:
sudo restorecon -Rv /var/www/html/
```

</details>

</details>

<details>
<summary><b>Übungsaufgaben</b></summary>

1. **Inodes & Hardlinks analysieren:** Erstelle eine Datei `test.txt`, notiere deren Inode (`ls -i test.txt`), erstelle einen Hardlink `test_hl.txt` und einen Softlink `test_sl.txt`. Vergleiche die Inodes und lösche anschließend `test.txt`. Was passiert beim Lesen von `test_hl.txt` und `test_sl.txt`?
2. **Rechte & Spezial-Bits:** Erstelle ein Verzeichnis `/tmp/team_share`, setze das Sticky-Bit (`chmod 1777`) und teste mit zwei unterschiedlichen Benutzern, ob ein Benutzer die Datei des anderen löschen kann.
3. **LVM-Simulation:** Erstelle mit `dd if=/dev/zero of=loop_disk.img bs=1M count=200` eine 200 MB Imagedatei, richte sie als Loop-Device ein (`sudo losetup -fP loop_disk.img`), initialisiere darauf ein LVM PV (`pvcreate`), eine VG (`vgcreate`) und ein LV (`lvcreate`) und binde es mit `ext4` ein.
4. **Port- & Prozess-Diagnose:** Ermittle mit `ss -tulpn`, welcher Prozess Port `8080`, `11434` oder `22` belegt, und visualisiere dessen Abstammung im Prozessbaum mit `pstree -p <PID>`.
5. **Systemd-Timer:** Erstelle eine simple systemd-Service- und Timer-Unit, die alle 5 Minuten einen Zeitstempel in `/tmp/timer_test.log` schreibt, und überprüfe ihren Status mit `systemctl list-timers`.

</details>

<details>
<summary><b>Weiterführende Links & Quellen</b></summary>

* [Jannis Seemann – Linux System Administration & Inodes Guide](https://github.com/jannisseemann)
* [Red Hat Enterprise Linux – Managing Storage with LVM](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/)
* [ArchWiki – systemd Units, Timers and Journal](https://wiki.archlinux.org/title/Systemd)
* [Linux Kernel Documentation – Inodes and Virtual Filesystem (VFS)](https://docs.kernel.org/filesystems/vfs.html)

</details>

<details>
<summary><b>Chips & Kernaussagen</b></summary>

* **Inodes statt Dateinamen:** Der Dateiname ist lediglich ein Verzeichniseintrag, der auf eine Inode zeigt; Inodes halten Rechte, Größe und Datenblock-Zeiger.
* **Hardlinks vs. Symlinks:** Hardlinks teilen dieselbe Inode (Daten bleiben erhalten, solange Link-Counter > 0); Symlinks sind Wegweiser zu einem Pfad.
* **Spezial-Bits:** SUID führt Programme mit Rechten des Besitzers aus, SGID vererbt Gruppenrechte in Verzeichnissen, das Sticky-Bit schützt Dateien vor unbefugtem Löschen.
* **Prozess-Signale:** Beende Dienste primär mit `SIGTERM` (15); nutze `SIGKILL` (9) nur als Notbremse. Schütze Jobs vor SSH-Abbrüchen mit `nohup` oder `disown`.
* **LVM-Flexibilität:** Fasse physische Platten zu Volume Groups (VG) zusammen und vergrößere Logical Volumes (LV) im laufenden Betrieb ohne Neustart.
* **Boot-Kette & systemd:** UEFI $\rightarrow$ GRUB $\rightarrow$ Kernel/Initramfs $\rightarrow$ systemd (PID 1). Verwalte Hintergrundaufgaben bevorzugt mit systemd-Timern statt Cron.

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
