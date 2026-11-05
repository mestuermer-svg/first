import socket, time

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

send("alt-tab", 0.5)
send("ret", 0.3)
send("esc", 0.2)

keys = ["minus", "equal", "bracket_left", "bracket_right", "semicolon", "apostrophe", "grave_accent", "backslash", "slash"]
for k in keys:
    for c in k:
        send(c)
    send("colon" if ":" in k else "spc")
    send(k)
    send("spc")
    send("spc")

send("ret", 0.3)
s.close()
print("Key test sent!")
