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

# Get-Process -Id (Get-NetTCPConnection -LocalPort 22).OwningProcess
cmd = "Get-Process -Id 4612"
for c in cmd:
    if c == " ":
        send("spc")
    elif c == "-":
        send("slash")
    elif c.isupper():
        send(f"shift-{c.lower()}")
    else:
        send(c)
send("ret", 0.5)

s.close()
print("Get-Process sent!")
