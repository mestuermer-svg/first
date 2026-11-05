import socket, time, struct, zlib, base64

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect("/run/shm/monitor.sock")
time.sleep(0.2)
try:
    s.recv(4096)
except Exception:
    pass

def send(k, delay=0.06):
    s.sendall(f"sendkey {k}\n".encode())
    time.sleep(delay)
    try:
        s.recv(2048)
    except Exception:
        pass

# Focus Administrator PowerShell with alt-tab
send("alt-tab", 0.5)
send("ret", 0.3)

# Clear line
send("esc", 0.2)

# PowerShell command to run fast.ps1 via full path
# Note in PowerShell: & "\\host.lan\Data\fast.ps1"
# Let's type:
# powershell -NoProfile -ExecutionPolicy Bypass -File \\host.lan\Data\fast.ps1
# We can also do:
# Set-Location \\host.lan\Data; .\fast.ps1

cmd_to_run = r"powershell -ExecutionPolicy Bypass -File \\host.lan\Data\fast.ps1"
b64 = base64.b64encode(cmd_to_run.encode("utf-16le")).decode()
print("Base64 command:", b64)

# In PowerShell, we can just run: powershell -e <b64>
# Note: "-" in German layout is "slash"
type_str = f"powershell /e {b64}"
for ch in type_str:
    if ch == " ":
        send("spc")
    elif ch == "/":
        send("slash")
    elif ch == "=":
        # Shift+0 on German layout is =
        send("shift-0")
    elif ch == "+":
        # On German layout, + is next to Enter
        send("bracket_right")
    elif ch.isupper():
        send(f"shift-{ch.lower()}")
    else:
        send(ch)

send("ret", 0.8)

print("powershell command sent! Waiting 60s for bootstrap (OpenSSH, AC Sync, etc.)...")
time.sleep(60.0)

s.sendall(b"screendump /shared/screen_now.ppm\n")
time.sleep(0.8)
s.close()

with open("/shared/screen_now.ppm", "rb") as f:
    data = f.read()

lines = []
idx = 0
while len(lines) < 3:
    nl = data.index(b"\n", idx)
    line = data[idx:nl].strip()
    if not line.startswith(b"#"):
        lines.append(line)
    idx = nl + 1

w, h = map(int, lines[1].split())
raw = data[idx:]

def chunk(tag, body):
    return struct.pack(">I", len(body)) + tag + body + struct.pack(">I", zlib.crc32(tag + body) & 0xffffffff)

rows = b"".join(b"\x00" + raw[y*w*3:(y+1)*w*3] for y in range(h))
png = (
    b"\x89PNG\r\n\x1a\n"
    + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
    + chunk(b"IDAT", zlib.compress(rows, 6))
    + chunk(b"IEND", b"")
)
with open("/shared/screen_now.png", "wb") as f:
    f.write(png)

print("Screen updated!")
