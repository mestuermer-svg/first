import socket, time, zlib, struct

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect("/run/shm/monitor.sock")
time.sleep(0.2)
try:
    s.recv(4096)
except Exception:
    pass
s.sendall(b"screendump /shared/screen_now.ppm\n")
time.sleep(0.6)
s.close()

with open("/shared/screen_now.ppm", "rb") as f:
    data = f.read()

# Parse P6 PPM header
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
print(f"PNG written: {w}x{h}")

