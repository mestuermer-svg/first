interface SystemdServiceInfo {
  unit: string;
  activeState: string;
  subState: string;
  pid: number;
  memoryMb: number | null;
  startedAt: string;
}

interface LinuxStatusResponse {
  host: string;
  arch: string;
  platform: string;
  kernel: string;
  nodeVersion: string;
  uptimeSeconds: number;
  loadAvg: number[];
  cpuTempC: number | null;
  memory: {
    totalMb: number;
    freeMb: number;
    usedMb: number;
  };
  services: SystemdServiceInfo[];
  timestamp: string;
}

interface PortsResponse {
  count: number;
  sockets: string[];
}

interface CaddyLogEntry {
  ts?: number | null;
  method?: string;
  uri?: string;
  status?: number;
  durationMs?: number;
  remoteIp?: string;
  raw?: string;
}

interface LogsResponse {
  unit: string;
  lines: string[];
  caddyAccessTail?: CaddyLogEntry[];
}

interface EchoResponse {
  proxiedVia: string;
  receivedAt: string;
  headers: Record<string, string>;
  payload: unknown;
}

let activeUnit = "caddy.service";

function byId<T extends HTMLElement>(id: string): T {
  const el = document.getElementById(id);
  if (!el) {
    throw new Error(`Element #${id} nicht gefunden`);
  }
  return el as T;
}

function formatDuration(sec: number): string {
  const h = Math.floor(sec / 3600);
  const m = Math.floor((sec % 3600) / 60);
  const s = sec % 60;
  return `${h}h ${m}m ${s}s`;
}

async function fetchJson<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, init);
  if (!res.ok) {
    throw new Error(`HTTP ${res.status} bei ${url}`);
  }
  return (await res.json()) as T;
}

function renderServices(services: SystemdServiceInfo[]): void {
  const tbody = byId<HTMLTableSectionElement>("servicesBody");
  tbody.innerHTML = "";

  for (const svc of services) {
    const tr = document.createElement("tr");
    if (svc.unit === activeUnit) {
      tr.classList.add("selected");
    }

    const isOk = svc.activeState === "active";
    const badgeClass = isOk ? "badge ok" : "badge err";

    tr.innerHTML = `
      <td><strong>${svc.unit}</strong></td>
      <td><span class="${badgeClass}">${svc.activeState}</span></td>
      <td>${svc.subState}</td>
      <td>${svc.pid || "-"}</td>
      <td>${svc.memoryMb !== null ? `${svc.memoryMb} MB` : "-"}</td>
      <td>${svc.startedAt}</td>
    `;

    tr.addEventListener("click", () => {
      activeUnit = svc.unit;
      void refreshLogs();
      renderServices(services);
    });

    tbody.appendChild(tr);
  }
}

async function refreshStatus(): Promise<void> {
  const data = await fetchJson<LinuxStatusResponse>("/api/linux/status");
  byId("valHost").textContent = `${data.host} (${data.arch})`;
  byId("valKernel").textContent = `${data.platform} · Kernel ${data.kernel}`;
  byId("valUptime").textContent = formatDuration(data.uptimeSeconds);
  byId("valLoad").textContent = `Load: ${data.loadAvg.join(" / ")}`;
  byId("valMem").textContent = `${data.memory.usedMb} / ${data.memory.totalMb} MB`;
  byId("valTemp").textContent = data.cpuTempC !== null ? `CPU-Temp: ${data.cpuTempC} °C` : "CPU-Temp: n/a";
  byId("valNode").textContent = data.nodeVersion;
  byId("valTime").textContent = new Date(data.timestamp).toLocaleTimeString("de-DE");
  renderServices(data.services);
}

async function refreshPorts(): Promise<void> {
  const data = await fetchJson<PortsResponse>("/api/linux/ports");
  byId("portsBox").textContent = data.sockets.join("\n") || "(keine offenen Sockets)";
}

async function refreshLogs(): Promise<void> {
  byId("selectedUnit").textContent = activeUnit;
  const data = await fetchJson<LogsResponse>(`/api/linux/logs?unit=${encodeURIComponent(activeUnit)}`);
  const parts: string[] = [];
  if (data.caddyAccessTail && data.caddyAccessTail.length > 0) {
    parts.push("=== Caddy Access-Log (neueste Requests) ===");
    for (const entry of data.caddyAccessTail) {
      if (entry.raw) {
        parts.push(entry.raw);
      } else {
        parts.push(`${entry.method ?? "-"} ${entry.uri ?? "-"} -> HTTP ${entry.status ?? 0} (${entry.durationMs ?? 0} ms) [${entry.remoteIp ?? "-"}]`);
      }
    }
    parts.push("");
  }
  parts.push(`=== journalctl -u ${data.unit} ===`);
  parts.push(...data.lines);
  byId("logsBox").textContent = parts.join("\n");
}

async function sendEcho(): Promise<void> {
  const input = byId<HTMLInputElement>("echoInput");
  const box = byId("echoBox");
  try {
    const res = await fetchJson<EchoResponse>("/api/linux/echo", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        message: input.value,
        clientTime: new Date().toISOString(),
        source: "ts-linux-lab",
      }),
    });
    box.textContent = JSON.stringify(res, null, 2);
  } catch (err) {
    box.textContent = `Fehler: ${String(err)}`;
  }
}

async function refreshAll(): Promise<void> {
  try {
    await Promise.all([refreshStatus(), refreshPorts(), refreshLogs()]);
  } catch (err) {
    byId("logsBox").textContent = `API-Fehler: ${String(err)}`;
  }
}

byId("btnRefresh").addEventListener("click", () => void refreshAll());
byId("btnEcho").addEventListener("click", () => void sendEcho());

void refreshAll();
window.setInterval(() => void refreshAll(), 5000);
