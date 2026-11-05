import socket, time, struct, zlib

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

# Send Enter first to wake up prompt
send("ret", 0.3)

# Send Esc to clear prompt
send("esc", 0.2)

# Type "powershell -ep Unrestricted -file fast.ps1"
keys = [
    "p", "o", "w", "e", "r", "s", "h", "e", "l", "l", "spc",
    "slash", "e", "p", "spc",
    "shift-u", "n", "r", "e", "s", "t", "r", "i", "c", "t", "e", "d", "spc",
    "slash", "f", "i", "l", "e", "spc",
    "f", "a", "s", "t", "dot", "p", "s", "1",
    "ret"
]
for k in keys:
    send(k)

print("powershell -ep Unrestricted -file fast.ps1 sent! Waiting 30 seconds for bootstrap to run...")
time.sleep(30.0)

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

print("dir Desktop executed and screen_now.png updated!")
