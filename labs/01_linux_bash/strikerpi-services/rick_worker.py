#!/usr/bin/env python3
"""
Rick Agent Worker (StrikerPi 24/7 Edge Hub - 192.168.178.86)
- Ueberwacht /opt/rick-agent/inbox/*.json (oder *.txt) und verarbeitet Aufgaben asynchron.
- Aktualisiert alle 15s /opt/rick-agent/status.json (Relay, Mosquitto, Caddy, GitLabor-API, Bare-Git, LAN-Reachability).
"""

import json
import socket
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.request import urlopen

BASE_DIR = Path("/opt/rick-agent")
INBOX_DIR = BASE_DIR / "inbox"
OUTBOX_DIR = BASE_DIR / "outbox"
LOG_DIR = BASE_DIR / "logs"
STATUS_FILE = BASE_DIR / "status.json"
LOG_FILE = LOG_DIR / "rick-worker.log"

GITLABOR_ROOT = Path("/srv/git-labor")
GITLABOR_WEB = GITLABOR_ROOT / "web"
GITLABOR_APPS = GITLABOR_ROOT / "apps"
CADDY_CONFD = Path("/etc/caddy/conf.d")
CADDY_LOG_DIR = Path("/var/log/caddy")

NODES = {
    "simracer_ssh": ("192.168.178.68", 22),
    "simracer_stream": ("192.168.178.68", 8090),
    "sandbox_vnc": ("192.168.178.68", 8006),
    "sandbox_ssh": ("192.168.178.68", 2222),
    "archibald_ssh": ("192.168.178.98", 22),
    "strikerpi_caddy": ("127.0.0.1", 80),
    "strikerpi_relay": ("127.0.0.1", 8080),
    "strikerpi_gitlabor_api": ("127.0.0.1", 8085),
    "strikerpi_mqtt": ("127.0.0.1", 1883),
}


def log(msg: str) -> None:
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{ts}] {msg}"
    print(line, flush=True)
    try:
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        with LOG_FILE.open("a", encoding="utf-8") as f:
            f.write(line + "\n")
    except Exception:
        pass


def check_tcp(host: str, port: int, timeout: float = 1.0) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except Exception:
        return False


def check_systemd(service: str) -> str:
    try:
        res = subprocess.run(
            ["systemctl", "is-active", service],
            capture_output=True,
            text=True,
            timeout=3,
        )
        return (res.stdout or res.stderr).strip() or "unknown"
    except Exception as exc:
        return f"error: {exc}"


def fetch_relay_status() -> dict:
    try:
        with urlopen("http://127.0.0.1:8080/api/status", timeout=2.0) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except Exception:
        return {}


def write_status() -> dict:
    relay = fetch_relay_status()
    nodes = {name: check_tcp(host, port) for name, (host, port) in NODES.items()}
    git_bare_ok = Path("/srv/git/simrig.git/HEAD").exists()
    data = {
        "agent": "Rick",
        "host": socket.gethostname(),
        "ip": "192.168.178.86",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "services": {
            "caddy": check_systemd("caddy.service"),
            "gitlabor_api": check_systemd("gitlabor-api.service"),
            "telemetry_relay": check_systemd("telemetry-relay.service"),
            "mosquitto": check_systemd("mosquitto.service"),
            "rick_agent": check_systemd("rick-agent.service"),
            "sshd": check_systemd("sshd.service"),
        },
        "git_bare_repo": "/srv/git/simrig.git" if git_bare_ok else None,
        "gitlabor_webroot": str(GITLABOR_WEB) if GITLABOR_WEB.exists() else None,
        "nodes": nodes,
        "relay_snapshot": {
            "mode": relay.get("mode"),
            "active_source": relay.get("active_source"),
            "packets_received": relay.get("packets_received"),
        },
    }
    STATUS_FILE.write_text(json.dumps(data, indent=2), encoding="utf-8")
    return data


def setup_caddy_gitlabor() -> dict:
    GITLABOR_WEB.mkdir(parents=True, exist_ok=True)
    (GITLABOR_WEB / "labs" / "04_js_ts_web").mkdir(parents=True, exist_ok=True)
    (GITLABOR_APPS / "linux-monitor-api").mkdir(parents=True, exist_ok=True)
    CADDY_CONFD.mkdir(parents=True, exist_ok=True)
    CADDY_LOG_DIR.mkdir(parents=True, exist_ok=True)
    subprocess.run(["chown", "-R", "caddy:caddy", str(CADDY_LOG_DIR)], check=True, timeout=10)
    subprocess.run(["chmod", "-R", "a+rX", str(GITLABOR_ROOT)], check=True, timeout=10)

    main_caddyfile = Path("/etc/caddy/Caddyfile")
    main_content = (
        "{\n"
        "    admin unix//run/caddy/admin.socket\n"
        "}\n\n"
        "import /etc/caddy/conf.d/*.caddy\n"
    )
    main_caddyfile.write_text(main_content, encoding="utf-8")

    site_caddy = CADDY_CONFD / "git-labor.caddy"
    site_content = (
        ":80 {\n"
        "    root * /srv/git-labor/web\n"
        "    encode gzip zstd\n\n"
        "    log {\n"
        "        output file /var/log/caddy/gitlabor-access.log {\n"
        "            roll_size 5MiB\n"
        "            roll_keep 3\n"
        "        }\n"
        "        format json\n"
        "    }\n\n"
        "    handle /api/linux/* {\n"
        "        reverse_proxy 127.0.0.1:8085\n"
        "    }\n\n"
        "    handle /mqtt* {\n"
        "        reverse_proxy 127.0.0.1:9001\n"
        "    }\n\n"
        "    handle {\n"
        "        file_server {\n"
        "            browse\n"
        "        }\n"
        "    }\n"
        "}\n"
    )
    site_caddy.write_text(site_content, encoding="utf-8")

    subprocess.run(["caddy", "fmt", "--overwrite", str(main_caddyfile)], check=False, timeout=10)
    subprocess.run(["caddy", "fmt", "--overwrite", str(site_caddy)], check=False, timeout=10)

    val = subprocess.run(
        ["caddy", "validate", "--config", "/etc/caddy/Caddyfile"],
        capture_output=True,
        text=True,
        timeout=15,
    )
    if val.returncode != 0:
        raise RuntimeError(f"Caddyfile validation failed: {val.stderr or val.stdout}")

    subprocess.run(["systemctl", "enable", "--now", "caddy.service"], check=True, timeout=15)
    subprocess.run(["systemctl", "restart", "caddy.service"], check=True, timeout=15)

    unit_file = Path("/etc/systemd/system/gitlabor-api.service")
    if unit_file.exists():
        subprocess.run(["systemctl", "daemon-reload"], check=True, timeout=15)
        subprocess.run(["systemctl", "enable", "--now", "gitlabor-api.service"], check=True, timeout=15)
        subprocess.run(["systemctl", "restart", "gitlabor-api.service"], check=True, timeout=15)

    return {
        "caddyfile": str(main_caddyfile),
        "site_config": str(site_caddy),
        "webroot": str(GITLABOR_WEB),
        "validation": (val.stdout or val.stderr).strip(),
        "caddy_status": check_systemd("caddy.service"),
        "gitlabor_api_status": check_systemd("gitlabor-api.service"),
    }


def build_ts_labs() -> dict:
    built = []
    if not GITLABOR_WEB.exists():
        return {"built": built, "message": "Webroot nicht vorhanden"}
    for tsconfig in sorted(GITLABOR_WEB.rglob("tsconfig.json")):
        if "node_modules" in tsconfig.parts:
            continue
        proj_dir = tsconfig.parent
        res = subprocess.run(
            ["tsc", "-p", str(proj_dir)],
            capture_output=True,
            text=True,
            timeout=60,
        )
        built.append({
            "project": str(proj_dir),
            "returncode": res.returncode,
            "stdout": res.stdout.strip(),
            "stderr": res.stderr.strip(),
        })
        if res.returncode != 0:
            raise RuntimeError(f"tsc failed in {proj_dir}: {res.stdout} {res.stderr}")
    subprocess.run(["chmod", "-R", "a+rX", str(GITLABOR_WEB)], check=True, timeout=10)
    return {"built": built}


def handle_task(task_path: Path) -> None:
    try:
        raw = task_path.read_text(encoding="utf-8-sig").strip()
        if task_path.suffix == ".json":
            task = json.loads(raw)
        else:
            task = {"action": "note", "prompt": raw}
    except Exception as exc:
        log(f"Fehler beim Lesen von {task_path.name}: {exc}")
        task_path.unlink(missing_ok=True)
        return

    task_id = task.get("task_id") or task_path.stem
    action = str(task.get("action", "")).lower()
    prompt = str(task.get("prompt") or "")
    sender = str(task.get("sender") or "Unknown")

    log(f"Task {task_id} von {sender}: action={action} prompt={prompt}")
    result = {
        "task_id": task_id,
        "agent": "Rick",
        "sender": sender,
        "action": action,
        "status": "ok",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }

    try:
        if action in ("status", "health", "ping"):
            result["data"] = write_status()
        elif action == "setup_caddy_gitlabor":
            result["data"] = setup_caddy_gitlabor()
            result["message"] = "Caddy Webserver & /srv/git-labor/web fuer JS+TS Lernprojekte eingerichtet"
        elif action in ("caddy_reload", "caddy_validate"):
            val = subprocess.run(
                ["caddy", "validate", "--config", "/etc/caddy/Caddyfile"],
                capture_output=True,
                text=True,
                timeout=15,
            )
            if val.returncode != 0:
                raise RuntimeError(val.stderr or val.stdout)
            if action == "caddy_reload":
                subprocess.run(["systemctl", "reload", "caddy.service"], check=True, timeout=15)
            result["message"] = f"{action} erfolgreich: {(val.stdout or val.stderr).strip()}"
        elif action == "caddy_status":
            ver = subprocess.run(["caddy", "version"], capture_output=True, text=True, timeout=5)
            result["data"] = {
                "service": check_systemd("caddy.service"),
                "version": ver.stdout.strip(),
                "port_80": check_tcp("127.0.0.1", 80),
                "gitlabor_api_service": check_systemd("gitlabor-api.service"),
                "port_8085": check_tcp("127.0.0.1", 8085),
            }
        elif action == "build_ts_labs":
            result["data"] = build_ts_labs()
            result["message"] = "TypeScript-Projekte unter /srv/git-labor/web kompiliert"
        elif action == "restart_gitlabor_api":
            subprocess.run(["systemctl", "restart", "gitlabor-api.service"], check=True, timeout=15)
            result["message"] = "gitlabor-api.service neu gestartet"
        elif action == "restart_relay":
            subprocess.run(["systemctl", "restart", "telemetry-relay.service"], check=True, timeout=15)
            result["message"] = "telemetry-relay.service neu gestartet"
        elif action == "restart_mqtt":
            subprocess.run(["systemctl", "restart", "mosquitto.service"], check=True, timeout=15)
            result["message"] = "mosquitto.service neu gestartet"
        elif action == "mqtt_mode":
            mode = str(task.get("mode") or "ENGINEERING")
            subprocess.run(
                ["mosquitto_pub", "-h", "127.0.0.1", "-t", "simrig/mode", "-m", mode],
                check=True,
                timeout=5,
            )
            result["message"] = f"MQTT simrig/mode={mode} publiziert"
        elif action == "git_status":
            res = subprocess.run(
                ["git", "--git-dir=/srv/git/simrig.git", "log", "-n", "5", "--oneline"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            result["message"] = res.stdout.strip() or res.stderr.strip()
        elif action == "note":
            result["message"] = f"Nachricht von {sender} empfangen: {prompt}"
        else:
            result["status"] = "ignored"
            result["message"] = f"Unbekannte Action '{action}' von {sender} ignoriert"
    except Exception as exc:
        result["status"] = "error"
        result["error"] = str(exc)

    OUTBOX_DIR.mkdir(parents=True, exist_ok=True)
    out_file = OUTBOX_DIR / f"result_{task_id}.json"
    out_file.write_text(json.dumps(result, indent=2), encoding="utf-8")
    task_path.unlink(missing_ok=True)
    log(f"Task {task_id} abgeschlossen -> {out_file.name} ({result['status']})")


def main() -> None:
    INBOX_DIR.mkdir(parents=True, exist_ok=True)
    OUTBOX_DIR.mkdir(parents=True, exist_ok=True)
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log("Rick Agent Worker gestartet (StrikerPi 192.168.178.86).")

    last_status = 0.0
    while True:
        now = time.monotonic()
        if now - last_status >= 15.0:
            try:
                write_status()
            except Exception as exc:
                log(f"Status-Fehler: {exc}")
            last_status = now

        for item in sorted(INBOX_DIR.iterdir()):
            if item.is_file() and item.suffix in (".json", ".txt"):
                handle_task(item)

        time.sleep(2.0)


if __name__ == "__main__":
    main()
