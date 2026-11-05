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

# Focus Administrator PowerShell with alt-tab
send("alt-tab", 0.5)
send("ret", 0.3)

# Test what characters are produced
test_keys = ["slash", "minus", "shift-7", "ctrl_alt-minus", "backslash"]
for k in test_keys:
    send(k)
    send("spc")

send("ret", 0.3)
s.close()
print("Keys sent!")
