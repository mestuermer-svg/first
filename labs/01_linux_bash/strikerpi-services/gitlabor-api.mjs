import http from "node:http";
import os from "node:os";
import fs from "node:fs";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

const HOST = "127.0.0.1";
const PORT = 8085;
const WATCHED_UNITS = [
  "caddy.service",
  "gitlabor-api.service",
  "telemetry-relay.service",
  "mosquitto.service",
  "rick-agent.service",
  "sshd.service",
];

async function runCmd(cmd, args, timeout = 3000) {
  try {
    const { stdout, stderr } = await execFileAsync(cmd, args, { timeout });
    return { ok: true, stdout: stdout.trim(), stderr: stderr.trim() };
  } catch (err) {
    return {
      ok: false,
      stdout: (err.stdout || "").toString().trim(),
      stderr: (err.stderr || err.message || "").toString().trim(),
    };
  }
}

async function getUnitDetails(unit) {
  const res = await runCmd("systemctl", [
    "show",
    unit,
    "--property=Id,ActiveState,SubState,MainPID,MemoryCurrent,ExecMainStartTimestamp",
  ]);
  const map = {};
  for (const line of res.stdout.split("\n")) {
    const idx = line.indexOf("=");
    if (idx > 0) {
      map[line.slice(0, idx)] = line.slice(idx + 1);
    }
  }
  const memBytes = Number(map.MemoryCurrent);
  return {
    unit,
    activeState: map.ActiveState || "unknown",
    subState: map.SubState || "unknown",
    pid: Number(map.MainPID || 0),
    memoryMb: Number.isFinite(memBytes) && memBytes > 0 ? Number((memBytes / (1024 * 1024)).toFixed(1)) : null,
    startedAt: map.ExecMainStartTimestamp || "-",
  };
}

function readCpuTempC() {
  try {
    const raw = fs.readFileSync("/sys/class/thermal/thermal_zone0/temp", "utf8").trim();
    const milli = Number(raw);
    return Number.isFinite(milli) ? Number((milli / 1000).toFixed(1)) : null;
  } catch {
    return null;
  }
}

function readCaddyAccessTail(limit = 8) {
  try {
    const raw = fs.readFileSync("/var/log/caddy/gitlabor-access.log", "utf8").trim();
    if (!raw) return [];
    return raw
      .split("\n")
      .slice(-limit)
      .reverse()
      .map((line) => {
        try {
          const parsed = JSON.parse(line);
          return {
            ts: parsed.ts || null,
            method: parsed.request?.method || "-",
            uri: parsed.request?.uri || "-",
            status: parsed.status || 0,
            durationMs: parsed.duration ? Number((parsed.duration * 1000).toFixed(2)) : 0,
            remoteIp: parsed.request?.remote_ip || "-",
          };
        } catch {
          return { raw: line };
        }
      });
  } catch {
    return [];
  }
}

function sendJson(res, statusCode, payload) {
  const body = JSON.stringify(payload, null, 2);
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
  });
  res.end(body);
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || "/", `http://${req.headers.host || "localhost"}`);

  if (req.method === "GET" && url.pathname === "/api/linux/health") {
    return sendJson(res, 200, { ok: true, service: "gitlabor-api", pid: process.pid, node: process.version });
  }

  if (req.method === "GET" && url.pathname === "/api/linux/status") {
    const services = await Promise.all(WATCHED_UNITS.map(getUnitDetails));
    const totalMemMb = Math.round(os.totalmem() / (1024 * 1024));
    const freeMemMb = Math.round(os.freemem() / (1024 * 1024));
    return sendJson(res, 200, {
      host: os.hostname(),
      arch: os.arch(),
      platform: os.platform(),
      kernel: os.release(),
      nodeVersion: process.version,
      uptimeSeconds: Math.floor(os.uptime()),
      loadAvg: os.loadavg().map((v) => Number(v.toFixed(2))),
      cpuTempC: readCpuTempC(),
      memory: {
        totalMb: totalMemMb,
        freeMb: freeMemMb,
        usedMb: totalMemMb - freeMemMb,
      },
      services,
      timestamp: new Date().toISOString(),
    });
  }

  if (req.method === "GET" && url.pathname === "/api/linux/ports") {
    const ssRes = await runCmd("ss", ["-tulpnH"]);
    const lines = ssRes.stdout
      ? ssRes.stdout.split("\n").map((l) => l.trim()).filter(Boolean)
      : [];
    return sendJson(res, 200, { count: lines.length, sockets: lines });
  }

  if (req.method === "GET" && url.pathname === "/api/linux/logs") {
    const unit = url.searchParams.get("unit") || "caddy.service";
    if (!WATCHED_UNITS.includes(unit)) {
      return sendJson(res, 400, { error: "Unbekannte oder nicht freigegebene Unit", allowed: WATCHED_UNITS });
    }
    const jRes = await runCmd("journalctl", ["-u", unit, "-n", "15", "--no-pager", "-o", "short-iso"]);
    return sendJson(res, 200, {
      unit,
      lines: jRes.stdout ? jRes.stdout.split("\n") : [],
      caddyAccessTail: unit === "caddy.service" ? readCaddyAccessTail(8) : undefined,
    });
  }

  if (req.method === "POST" && url.pathname === "/api/linux/echo") {
    let rawBody = "";
    for await (const chunk of req) {
      rawBody += chunk;
      if (rawBody.length > 16384) break;
    }
    let parsed = null;
    try {
      parsed = rawBody ? JSON.parse(rawBody) : null;
    } catch {
      parsed = rawBody;
    }
    return sendJson(res, 200, {
      proxiedVia: "Caddy Reverse Proxy -> gitlabor-api.service (127.0.0.1:8085)",
      receivedAt: new Date().toISOString(),
      headers: {
        host: req.headers.host || "",
        "x-forwarded-for": req.headers["x-forwarded-for"] || "",
        "x-forwarded-proto": req.headers["x-forwarded-proto"] || "",
      },
      payload: parsed,
    });
  }

  return sendJson(res, 404, {
    error: "Not Found",
    endpoints: [
      "GET /api/linux/health",
      "GET /api/linux/status",
      "GET /api/linux/ports",
      "GET /api/linux/logs?unit=caddy.service",
      "POST /api/linux/echo",
    ],
  });
});

server.listen(PORT, HOST, () => {
  console.log(`[gitlabor-api] Lauscht auf http://${HOST}:${PORT} (Node ${process.version})`);
});
