"""
Sim-Agent-Bridge für Git-Labor
Verbindet das Python- und Agenten-System im Git-Labor mit dem ultra-schlanken
Assetto Corsa, Content Manager & CSP Repository (ac-cm-csp-sandbox) sowie dem SimRacer (192.168.178.68).
"""

import os
import sys
import json
import time
import uuid
import subprocess
import configparser
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Any, List, Optional

WORKSPACE_ROOT = Path(__file__).resolve().parents[2]
AC_SANDBOX_REPO = WORKSPACE_ROOT.parent / "ac-cm-csp-sandbox"

class SimAgentBridge:
    def __init__(self, repo_path: Optional[Path] = None, agents_base_path: Optional[Path] = None):
        self.repo_path = repo_path or AC_SANDBOX_REPO
        self.simracer_ip = "192.168.178.68"
        self.strikerpi_host = "strikerpi"
        # Standard: Shared SMB-Pfad zum SimRacer
        self.agents_base_path = agents_base_path or Path(rf"\\{self.simracer_ip}\ac-sandbox\shared\agents")
        self.known_agents = ["general", "light", "rig", "dark", "sarah", "rick"]
        self.policy_file = self.agents_base_path / "general" / "approval_policy.json"
        self.mqtt_broker_ip = "192.168.178.86"
        self.mqtt_broker_port = 1883
        self.packages = {
            "setups": self.repo_path / "01_Documents_AC_Setups",
            "user_cfg": self.repo_path / "02_Documents_AC_Cfg",
            "cm_presets": self.repo_path / "03_CM_AppData_Presets_Data",
            "steam_cfg": self.repo_path / "04_Steam_AC_Cfg",
            "python_apps": self.repo_path / "05_Steam_AC_Apps_Python",
            "csp_extension": self.repo_path / "06_Steam_AC_Extension_Lua_Config",
            "cm_binary": self.repo_path / "07_Content_Manager_Binary",
            "engine_binaries": self.repo_path / "08_Steam_AC_Binaries",
            "system_core": self.repo_path / "09_Steam_AC_System_Core",
            "content_core": self.repo_path / "10_Steam_AC_Content_Core",
        }

    def verify_repository(self) -> Dict[str, Any]:
        """Prüft die Vollständigkeit aller 10 Pakete im Repository."""
        status = {}
        all_present = True
        total_files = 0
        total_bytes = 0

        for name, path in self.packages.items():
            exists = path.exists()
            files_count = len(list(path.rglob("*"))) if exists else 0
            size = sum(f.stat().st_size for f in path.rglob("*") if f.is_file()) if exists else 0
            total_files += files_count
            total_bytes += size
            if not exists:
                all_present = False
            status[name] = {
                "exists": exists,
                "files": files_count,
                "size_mb": round(size / (1024 * 1024), 2)
            }

        return {
            "repository_path": str(self.repo_path),
            "complete": all_present,
            "total_files": total_files,
            "total_size_mb": round(total_bytes / (1024 * 1024), 2),
            "packages": status
        }

    def read_pitfile_setup(self, car_folder: str, track_folder: str, setup_name: str) -> Optional[str]:
        """Liest eine Setup-Datei (.ini) aus dem Setups-Paket."""
        setup_path = self.packages["setups"] / car_folder / track_folder / f"{setup_name}.ini"
        if not setup_path.exists():
            # Alternative: direkt unter car_folder
            setup_path = self.packages["setups"] / car_folder / f"{setup_name}.ini"
        
        if setup_path.exists():
            return setup_path.read_text(encoding="utf-8", errors="ignore")
        return None

    def read_user_video_config(self) -> Dict[str, Any]:
        """Liest die video.ini (Auflösung, VR, FPS-Limit) der SimRacer-Umgebung."""
        video_ini_path = self.packages["user_cfg"] / "video.ini"
        if not video_ini_path.exists():
            return {}

        config = configparser.ConfigParser(strict=False)
        config.read(video_ini_path, encoding="utf-8")
        result = {}
        for section in config.sections():
            result[section] = dict(config.items(section))
        return result

    def get_csp_weather_configs(self) -> List[str]:
        """Listet verfügbare CSP Wetter- und Controller-Skripte auf."""
        weather_dir = self.packages["csp_extension"] / "lua" / "weather"
        if weather_dir.exists():
            return [f.name for f in weather_dir.iterdir() if f.is_dir() or f.suffix == ".lua"]
        return []

    # =========================================================================
    # Approval Policy & MQTT Gate
    # =========================================================================

    def get_approval_policy(self) -> Dict[str, Any]:
        """Liest die aktuelle Freigabepolicy (AUTO vs. MANUAL) von General Sim."""
        if self.policy_file.exists():
            try:
                return json.loads(self.policy_file.read_text(encoding="utf-8"))
            except Exception:
                pass
        return {"mode": "MANUAL", "description": "Standard Fallback"}

    def set_approval_policy(self, mode: str) -> bool:
        """Setzt die Freigabepolicy auf 'AUTO' (Dauerfreigabe) oder 'MANUAL' (Warten)."""
        m = mode.upper().strip()
        if m not in ["AUTO", "MANUAL"]:
            m = "MANUAL"
        data = {
            "mode": m,
            "description": "Steuert das General Sim Freigabe-Gate: MANUAL = Warten auf Bestaetigung; AUTO = Dauerfreigabe",
            "updated_at": datetime.now(timezone.utc).isoformat()
        }
        try:
            self.policy_file.parent.mkdir(parents=True, exist_ok=True)
            self.policy_file.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
            return True
        except Exception:
            return False

    def publish_mqtt_task(self, target_agent: str, payload: Dict[str, Any]) -> bool:
        """Publiziert eine Aufgabe als MQTT-Event direkt an den Broker auf StrikerPi."""
        target = target_agent.lower().lstrip("@")
        topic = f"agents/{target}/inbox"
        msg = json.dumps(payload, ensure_ascii=False)
        # Via SSH-Aufruf auf StrikerPi mosquitto_pub fuer maximale Zuverlaessigkeit ohne externe Python-Deps
        try:
            cmd = [
                "ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=3",
                self.strikerpi_host,
                f"mosquitto_pub -h 127.0.0.1 -p 1883 -t '{topic}' -m '{msg}'"
            ]
            res = subprocess.run(cmd, capture_output=True, timeout=5)
            return res.returncode == 0
        except Exception:
            return False

    # =========================================================================
    # Task-Queue & Agenten-Terminal Interaktion
    # =========================================================================

    def get_agent_paths(self, agent_name: str) -> Dict[str, Path]:
        """Ermittelt die Verzeichnisse (inbox, outbox, logs) eines Agenten."""
        ag = agent_name.lower().lstrip("@")
        if ag == "sarah":
            sarah_dir = self.agents_base_path.parent / "telemetry"
            return {
                "root": sarah_dir,
                "inbox": sarah_dir / "inbox",
                "outbox": sarah_dir / "outbox",
                "logs": sarah_dir / "logs",
            }
        agent_dir = self.agents_base_path / ag
        return {
            "root": agent_dir,
            "inbox": agent_dir / "inbox",
            "outbox": agent_dir / "outbox",
            "logs": agent_dir / "logs",
        }

    def get_agent_status(self, agent_name: str) -> Dict[str, Any]:
        """Gibt den aktuellen Queue-Status und die Verfügbarkeit eines Agenten zurück."""
        if agent_name.lower().lstrip("@") == "rick":
            try:
                res = subprocess.run(
                    ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=2", self.strikerpi_host, "cat /opt/rick-agent/status.json"],
                    capture_output=True, text=True, timeout=4
                )
                connected = res.returncode == 0
                return {
                    "agent": "rick",
                    "connected": connected,
                    "queue_count": 0,
                    "busy": False,
                    "latest_results": [],
                    "inbox_path": f"{self.strikerpi_host}:/opt/rick-agent/inbox"
                }
            except Exception:
                return {"agent": "rick", "connected": False, "queue_count": 0, "busy": False, "latest_results": [], "inbox_path": f"{self.strikerpi_host}:/opt/rick-agent/inbox"}

        paths = self.get_agent_paths(agent_name)
        inbox_exists = paths["inbox"].exists()
        outbox_exists = paths["outbox"].exists()

        queue_count = len(list(paths["inbox"].glob("*.json"))) if inbox_exists else 0
        latest_results = []
        if outbox_exists:
            for r_file in sorted(paths["outbox"].glob("result_*.json"), key=lambda f: f.stat().st_mtime, reverse=True)[:5]:
                latest_results.append(r_file.name)

        return {
            "agent": agent_name,
            "connected": inbox_exists,
            "queue_count": queue_count,
            "busy": queue_count > 0,
            "latest_results": latest_results,
            "inbox_path": str(paths["inbox"])
        }

    def send_agent_task(
        self,
        target_agent: str,
        action: str = "ProcessPrompt",
        params: Optional[Dict[str, Any]] = None,
        prompt: str = "",
        source: str = "git-labor-python",
        wait_for_result: bool = False,
        timeout_seconds: int = 60,
        cleanup_result: bool = False
    ) -> Dict[str, Any]:
        """
        Sendet einen Task als JSON in die Inbox des Zielagenten.
        Prompts werden als reine Textdaten im Feld 'prompt' übertragen (keine Shell-Code-Ausführung).
        Falls wait_for_result=True, blockiert die Methode und wartet auf result_<taskId>.json in outbox/.
        """
        target = target_agent.lower().lstrip("@")
        paths = self.get_agent_paths(target)
        paths["inbox"].mkdir(parents=True, exist_ok=True)
        paths["outbox"].mkdir(parents=True, exist_ok=True)

        now = datetime.now(timezone.utc)
        task_id = f"task_{now.strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:6]}"
        effective_action = "ProcessPrompt" if prompt else action
        task_payload = {
            "task_id": task_id,
            "target_agent": target,
            "source": source,
            "action": effective_action,
            "prompt": prompt,
            "parameters": params or {},
            "created_at": now.isoformat()
        }

        task_file = paths["inbox"] / f"{task_id}.json"
        task_file.write_text(json.dumps(task_payload, indent=2, ensure_ascii=False), encoding="utf-8")

        response = {
            "task_id": task_id,
            "target_agent": target,
            "action": effective_action,
            "status": "Submitted",
            "task_file": str(task_file)
        }

        if not wait_for_result:
            return response

        # Warten auf Rückmeldung in outbox
        result_file = paths["outbox"] / f"result_{task_id}.json"
        log_file = paths["logs"] / f"task_{task_id}.log"
        start_time = time.time()

        while time.time() - start_time < timeout_seconds:
            if result_file.exists():
                try:
                    content = json.loads(result_file.read_text(encoding="utf-8", errors="ignore"))
                    content["log_file"] = str(log_file) if log_file.exists() else None
                    if cleanup_result:
                        try:
                            result_file.unlink()
                        except Exception:
                            pass
                    return content
                except json.JSONDecodeError:
                    pass  # Datei evtl. noch im Schreibvorgang
            time.sleep(1.0)

        response["status"] = "Timeout"
        response["error"] = f"Keine Rückmeldung nach {timeout_seconds}s in {result_file}"
        return response


if __name__ == "__main__":
    bridge = SimAgentBridge()
    print("=== SimAgentBridge Status-Check ===")
    report = bridge.verify_repository()
    print(f"Repo Pfad: {report['repository_path']}")
    print(f"Vollständig: {report['complete']} | Gesamtdateien: {report['total_files']} | Größe: {report['total_size_mb']} MB")
    print(f"Video Config Vorschau: {bridge.read_user_video_config().get('VIDEO', {})}")
    print("\n--- SimRacer Agenten-Queues Check ---")
    for ag in bridge.known_agents:
        st = bridge.get_agent_status(ag)
        print(f"[{ag.upper():<7}] Erreichbar: {st['connected']} | Queue: {st['queue_count']} Tasks")
