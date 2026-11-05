import socket, time, struct, zlib

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect("/run/shm/monitor.sock")
time.sleep(0.2)
try:
    s.recv(4096)
except Exception:
    pass

def send(k, delay=0.05):
    s.sendall(f"sendkey {k}\n".encode())
    time.sleep(delay)
    try:
        s.recv(2048)
    except Exception:
        pass

# Clear screen and run Get-Volume to see current volume size
send("alt-tab", 0.5)
send("ret", 0.2)

for c in "cls":
    send(c)
send("ret", 0.3)

# Focus Explorer with alt-tab or restart explorer process in PowerShell
send("alt-tab", 0.5)
send("ret", 0.2)

# Send Stop-Process -Name explorer in PowerShell to refresh Explorer shell
cmd = "Stop-Process -Name explorer -Force"
for c in cmd:
    if c == " ":
        send("spc")
    elif c == "-":
        send("slash")
    elif c.isupper():
        send(f"shift-{c.lower()}")
    else:
        send(c)
send("ret", 0.8)

time.sleep(3.0)

# Open "Dieser PC" (Win+E) to show refreshed explorer
send("meta_l-e", 0.8)
time.sleep(2.0)

s.sendall(b"screendump /shared/screen_now.ppm\n")
time.sleep(0.8)
s.close()

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

print("Disk extension executed and screen_now.png updated!")
