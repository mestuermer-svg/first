import socket

for p in [22, 135, 139, 445, 3389, 5985]:
    s = socket.socket()
    s.settimeout(0.5)
    res = s.connect_ex(("172.30.0.2", p))
    s.close()
    status = "OPEN" if res == 0 else "CLOSED"
    print(f"Port {p}: {status}")
