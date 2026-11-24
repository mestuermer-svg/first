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
from datetime import datetime, timedelta, timezone
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
        self.policy_file = self.agents_base_path / "general-SIM" / "pitwall_control_policy.json"
        self.frozen_policy_file = self.agents_base_path / "general-SIM" / "approval_policy.json"
        self.mutex_lock_file = self.agents_base_path / "general-SIM" / "execution_mutex.lock"
        self.mutex_meta_file = self.agents_base_path / "general-SIM" / "execution_mutex.json"
        self.mqtt_broker_ip = "192.168.178.86"
        self.mqtt_broker_port = 1883
        self.protected_patterns = (
            ".agent.md", "agents.md", ".instructions.md", "skill.md",
            "approval_policy.json", "pitwall_control_policy.json",
            "settings.json", "mcp.json", "tasks.json", ".code-workspace",
            "start_general_terminal.ps1", "start_light_terminal.ps1",
            "start_rig_terminal.ps1", "start_dark_terminal.ps1",
            "start_sarah_terminal.ps1", "worker.ps1", "runner.ps1", "rick_worker.py",
        )
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
        """Setzt die operative Freigabepolicy in pitwall_control_policy.json (approval_policy.json bleibt per Change-Freeze gesperrt)."""
        m = mode.upper().strip()
        if m not in ["AUTO", "DELEGATED", "MANUAL"]:
            m = "MANUAL"
        try:
            existing: Dict[str, Any] = {}
            if self.policy_file.exists():
                existing = json.loads(self.policy_file.read_text(encoding="utf-8"))
            existing["mode"] = m
            existing["updated_at"] = datetime.now(timezone.utc).isoformat()
            existing["updated_by"] = "SimAgentBridge"
            self.policy_file.parent.mkdir(parents=True, exist_ok=True)
            self.policy_file.write_text(json.dumps(existing, indent=2, ensure_ascii=False), encoding="utf-8")
            return True
        except Exception:
            return False

    def validate_no_cross_agent_tampering(self, action: str, prompt: str, params: Optional[Dict[str, Any]] = None) -> None:
        """Verhindert, dass ein Agent eigene oder fremde .agent.md, Skills, System-Configs oder Worker-Skripte modifiziert."""
        blob = f"{action} {prompt} {json.dumps(params or {}, ensure_ascii=False)}".lower()
        for pat in self.protected_patterns:
            if pat in blob:
                raise PermissionError(
                    f"[CHANGE-FREEZE & CROSS-AGENT-SCHUTZ] Zugriff verweigert: '{pat}' ist schreibgeschützt. "
                    "Kein Agent darf eigene oder fremde Agenten-Konfigurationen oder Skills ohne Nutzer-Freigabe ändern."
                )

    def enforce_hierarchy(self, issued_by: str, target_agent: str) -> None:
        """Prüft die strenge Befehlskette (General_Cyborg/General_Sim -> Light -> Worker)."""
        allowed_issuers = {"General_Cyborg", "General_Sim", "Light"}
        if issued_by not in allowed_issuers:
            raise PermissionError(f"[HIERARCHIE-BLOCK] Unbekannter Issuer '{issued_by}'.")
        target = target_agent.lower().lstrip("@")
        if issued_by == "Light" and target in {"general", "light"}:
            raise PermissionError(
                f"[HIERARCHIE-BLOCK] Light darf nur untergeordnete Worker (dark, rig, sarah, rick) ansteuern, nicht '@{target}'."
            )

    def enforce_pitwall_gate(self, target_agent: str, issued_by: str) -> None:
        """Prüft das globale Pitwall-Gate und die Einzelsperren in pitwall_control_policy.json."""
        policy = self.get_approval_policy()
        if policy.get("agents_paused") is True:
            raise PermissionError("[PITWALL-GATE BLOCK] Globale Pitwall-Freigabe ist PAUSIERT (agents_paused=true).")
        target = target_agent.lower().lstrip("@")
        agent_states = policy.get("agent_states") or {}
        ag_state = str(agent_states.get(target, "active")).lower()
        if ag_state in {"paused", "disabled"}:
            raise PermissionError(
                f"[PITWALL-GATE BLOCK] Agent '@{target}' ist auf der Pitwall auf '{ag_state}' gesetzt."
            )
        mode = str(policy.get("mode", "MANUAL")).upper()
        if mode == "MANUAL" and target in {"dark", "rig", "sarah", "rick"} and issued_by not in {"General_Cyborg", "General_Sim", "Light"}:
            raise PermissionError("[PITWALL-GATE BLOCK] Modus MANUAL erfordert Freigabe durch General/Light.")

    def get_mutex_status(self) -> Dict[str, Any]:
        """Liefert den aktuellen Status des exklusiven XOR-Ausführungs-Locks."""
        lock_exists = self.mutex_lock_file.exists()
        meta: Optional[Dict[str, Any]] = None
        if self.mutex_meta_file.exists():
            try:
                meta = json.loads(self.mutex_meta_file.read_text(encoding="utf-8"))
            except Exception:
                meta = None
        expired = False
        if meta and meta.get("expires_at"):
            try:
                exp = datetime.fromisoformat(str(meta["expires_at"]))
                if exp.tzinfo is None:
                    exp = exp.replace(tzinfo=timezone.utc)
                if datetime.now(timezone.utc) > exp:
                    expired = True
            except Exception:
                pass
        return {
            "locked": lock_exists and not expired,
            "lock_file_present": lock_exists,
            "expired": expired,
            "meta": meta,
        }

    def _has_foreign_inbox_task(self, execution_context: str) -> Optional[str]:
        """Prüft, ob in den Worker-Inboxen ein aktiver Task eines anderen execution_context liegt."""
        for ag in ("general", "light", "rig", "dark", "sarah"):
            inbox = self.get_agent_paths(ag)["inbox"]
            if not inbox.exists():
                continue
            for tf in inbox.glob("*.json"):
                try:
                    data = json.loads(tf.read_text(encoding="utf-8", errors="ignore"))
                    ctx = data.get("execution_context")
                    if ctx and ctx != execution_context:
                        return f"Inbox {tf.name} aktiv für Kontext '{ctx}'"
                except Exception:
                    continue
        return None

    def acquire_execution_mutex(
        self,
        execution_context: str,
        issued_by: str,
        target_agent: str,
        wait_seconds: int = 30,
        ttl_seconds: int = 120,
    ) -> str:
        """Erwirbt das atomare XOR-Lock oder blockiert sequentiell gegen parallele Kontexte."""
        self.mutex_lock_file.parent.mkdir(parents=True, exist_ok=True)
        lock_id = uuid.uuid4().hex
        deadline = time.monotonic() + max(0, wait_seconds)

        while True:
            conflict = self._has_foreign_inbox_task(execution_context)
            if not conflict:
                st = self.get_mutex_status()
                if st["lock_file_present"] and st["expired"]:
                    try:
                        self.mutex_lock_file.unlink(missing_ok=True)
                        self.mutex_meta_file.unlink(missing_ok=True)
                    except Exception:
                        pass
                try:
                    fd = os.open(str(self.mutex_lock_file), os.O_CREAT | os.O_EXCL | os.O_WRONLY)
                    now = datetime.now(timezone.utc)
                    meta_obj = {
                        "lock_id": lock_id,
                        "holder_context": execution_context,
                        "issued_by": issued_by,
                        "target_agent": target_agent,
                        "pid": os.getpid(),
                        "acquired_at": now.isoformat(),
                        "expires_at": (now + timedelta(seconds=ttl_seconds)).isoformat(),
                    }
                    payload_bytes = json.dumps(meta_obj, indent=2, ensure_ascii=False).encode("utf-8")
                    try:
                        os.write(fd, payload_bytes)
                    finally:
                        os.close(fd)
                    self.mutex_meta_file.write_bytes(payload_bytes)
                    return lock_id
                except FileExistsError:
                    pass

            if time.monotonic() >= deadline:
                cur = self.get_mutex_status()
                meta = cur.get("meta") or {}
                holder = conflict or (
                    f"Kontext '{meta.get('holder_context')}' ({meta.get('issued_by')}) bis {meta.get('expires_at')}"
                    if meta else "anderer aktiver Task"
                )
                raise RuntimeError(f"[XOR-MUTEX BLOCK] Parallele Ausführung verhindert: {holder}")
            time.sleep(1.0)

    def release_execution_mutex(self, lock_id: str) -> None:
        """Gibt das atomare XOR-Lock frei, sofern es noch diesem Aufrufer gehört."""
        if not lock_id:
            return
        try:
            if self.mutex_meta_file.exists():
                meta = json.loads(self.mutex_meta_file.read_text(encoding="utf-8"))
                if meta.get("lock_id") and meta.get("lock_id") != lock_id:
                    return
            self.mutex_meta_file.unlink(missing_ok=True)
            self.mutex_lock_file.unlink(missing_ok=True)
        except Exception:
            pass

    def infer_context_subset(self, target_agent: str, action: str, prompt: str) -> List[str]:
        """Berechnet das Need-to-Know Context_Subset zur Vermeidung von Halluzinationen auf lokalen GPUs."""
        txt = f"{action} {prompt}".lower()
        subsets: List[str] = []
        if any(k in txt for k in ("race.ini", "video.ini", "csp", "preset", "setup", ".ini")):
            subsets.extend(["Assetto_Corsa_Config", "ini_parsing"])
        if any(k in txt for k in ("vr", "steamvr", "focus", "vive", "ffb", "fanatec", "gpu", "vram")):
            subsets.append("Hardware_VR_Telemetry")
        if any(k in txt for k in ("docker", "sandbox", "container", "novnc", "8006", "2222")):
            subsets.append("Docker_Sandbox_Guest")
        if any(k in txt for k in ("replay", "video", "cut", "mp4", "stint", "lap", "sector", "telemetr")):
            subsets.append("Telemetry_Coaching_Media")
        if any(k in txt for k in ("mqtt", "relay", "mosquitto", "8080", "1883", "git")):
            subsets.append("Edge_Relay_MQTT")
        if not subsets:
            defaults = {
                "dark": ["Docker_Sandbox_Guest", "ini_parsing"],
                "light": ["Assetto_Corsa_Config", "Docker_Sandbox_Guest"],
                "rig": ["Hardware_VR_Telemetry"],
                "sarah": ["Telemetry_Coaching_Media"],
                "rick": ["Edge_Relay_MQTT"],
            }
            subsets = defaults.get(target_agent, ["Workspace_Orchestration"])
        return list(dict.fromkeys(subsets))

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
        folder = "general-SIM" if ag == "general" else ag
        agent_dir = self.agents_base_path / folder
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
        cleanup_result: bool = False,
        execution_context: str = "git-labor-ssh",
        issued_by: str = "General_Cyborg",
        lock_wait_seconds: int = 30,
        lock_ttl_seconds: int = 120,
    ) -> Dict[str, Any]:
        """
        Sendet einen Task als JSON in die Inbox des Zielagenten (mit Hierarchie-, Pitwall-Gate- & XOR-Mutex-Schutz).
        Prompts werden als reine Textdaten im Feld 'prompt' übertragen (keine Shell-Code-Ausführung).
        Falls wait_for_result=True, blockiert die Methode und wartet auf result_<taskId>.json in outbox/.
        """
        target = target_agent.lower().lstrip("@")
        self.validate_no_cross_agent_tampering(action=action, prompt=prompt, params=params)
        self.enforce_hierarchy(issued_by=issued_by, target_agent=target)
        self.enforce_pitwall_gate(target_agent=target, issued_by=issued_by)
        now = datetime.now(timezone.utc)
        task_id = f"task_{now.strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:6]}"
        effective_action = ("note" if target == "rick" else "ProcessPrompt") if prompt else action
        ctx_subset = self.infer_context_subset(target, effective_action, prompt)
        mem_scope = "memories/sandbox" if target == "dark" else f"memories/host/{target}"
        task_payload = {
            "task_id": task_id,
            "target": target,
            "target_agent": target,
            "sender": source,
            "source": source,
            "issued_by": issued_by,
            "approved_by": issued_by,
            "execution_context": execution_context,
            "priority": 2,
            "origin": "ssh_cyborg",
            "hop_count": 0,
            "action": effective_action,
            "prompt": prompt,
            "context_subset": ctx_subset,
            "memory_scope": mem_scope,
            "parameters": params or {},
            "created_at": now.isoformat()
        }

        lock_id = self.acquire_execution_mutex(
            execution_context=execution_context,
            issued_by=issued_by,
            target_agent=target,
            wait_seconds=lock_wait_seconds,
            ttl_seconds=lock_ttl_seconds,
        )
        try:
            # Parallel als Echtzeit-Wakeup an Mosquitto MQTT (:1883) publizieren
            self.publish_mqtt_task(target, {
                "task_id": task_id,
                "target": target,
                "action": effective_action,
                "execution_context": execution_context,
                "context_subset": ctx_subset,
                "timestamp": now.isoformat(),
            })

            if target == "rick":
                import tempfile
                payload_str = json.dumps(task_payload, indent=2, ensure_ascii=False)
                with tempfile.NamedTemporaryFile("w", suffix=".json", encoding="utf-8", delete=False) as tf:
                    tf.write(payload_str)
                    tmp_path = Path(tf.name)
                try:
                    scp_res = subprocess.run(
                        ["scp", "-q", str(tmp_path), f"{self.strikerpi_host}:/opt/rick-agent/inbox/{task_id}.json"],
                        capture_output=True, text=True, timeout=10
                    )
                finally:
                    tmp_path.unlink(missing_ok=True)
                if scp_res.returncode != 0:
                    return {
                        "task_id": task_id,
                        "target_agent": "rick",
                        "action": effective_action,
                        "status": "Failed",
                        "error": scp_res.stderr.strip() or f"SCP exit {scp_res.returncode}",
                    }
                response = {
                    "task_id": task_id,
                    "target_agent": "rick",
                    "action": effective_action,
                    "status": "Submitted",
                    "task_file": f"{self.strikerpi_host}:/opt/rick-agent/inbox/{task_id}.json",
                }
                if not wait_for_result:
                    return response
                start_time = time.time()
                while time.time() - start_time < timeout_seconds:
                    chk = subprocess.run(
                        ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=3", self.strikerpi_host, f"cat /opt/rick-agent/outbox/result_{task_id}.json 2>/dev/null"],
                        capture_output=True, text=True, timeout=6
                    )
                    if chk.returncode == 0 and chk.stdout.strip():
                        try:
                            return json.loads(chk.stdout)
                        except json.JSONDecodeError:
                            pass
                    time.sleep(1.0)
                response["status"] = "Timeout"
                response["error"] = f"Keine Rückmeldung nach {timeout_seconds}s auf {self.strikerpi_host}"
                return response

            paths = self.get_agent_paths(target)
            paths["inbox"].mkdir(parents=True, exist_ok=True)
            paths["outbox"].mkdir(parents=True, exist_ok=True)

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
        finally:
            self.release_execution_mutex(lock_id)


if __name__ == "__main__":
    bridge = SimAgentBridge()
    print("=== SimAgentBridge Status-Check ===")
    report = bridge.verify_repository()
    print(f"Repo Pfad: {report['repository_path']}")
    print(f"Vollständig: {report['complete']} | Gesamtdateien: {report['total_files']} | Größe: {report['total_size_mb']} MB")
    print(f"Video Config Vorschau: {bridge.read_user_video_config().get('VIDEO', {})}")
    pol = bridge.get_approval_policy()
    mtx = bridge.get_mutex_status()
    print(f"Pitwall Global-Gate: paused={pol.get('agents_paused', False)} | mode={pol.get('mode', 'MANUAL')}")
    print(f"XOR-Mutex: {'GESPERRT (' + str(mtx.get('meta')) + ')' if mtx.get('locked') else 'FREI'}")
    print("\n--- SimRacer Agenten-Queues Check ---")
    for ag in bridge.known_agents:
        st = bridge.get_agent_status(ag)
        print(f"[{ag.upper():<7}] Erreichbar: {st['connected']} | Queue: {st['queue_count']} Tasks")
