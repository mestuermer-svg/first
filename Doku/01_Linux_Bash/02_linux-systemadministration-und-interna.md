> **Thema:** Linux Systemadministration, Kernel-Interna, LVM, Prozesse, Boot-Prozess & Sicherheit
> **Autor:** Michael Stürmer
> **Datum:** 08.11.2026

# 02 – Linux Systemadministration, Speicherverwaltung & System-Interna

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
# Findet schnell heraus, welcher Dienst Port 80, 443 oder 8317 belegt!

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
sudo firewall-cmd --permanent --add-port=8317/tcp
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
4. **Port- & Prozess-Diagnose:** Ermittle mit `ss -tulpn`, welcher Prozess Port `8317` oder `22` belegt, und visualisiere dessen Abstammung im Prozessbaum mit `pstree -p <PID>`.
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
