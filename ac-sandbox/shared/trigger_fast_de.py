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

# Clear whatever was on the line
send("esc", 0.2)

# Type: & \\host.lan\Data\fast.ps1
# On German keyboard layout:
# '&' is shift-6
# '\' is ctrl_alt-minus
# '.' is dot
# ':' is shift-dot
# '-' is slash

send("shift-6")
send("spc")
send("ctrl_alt-minus")
send("ctrl_alt-minus")

for c in "host":
    send(c)
send("dot")
for c in "lan":
    send(c)

send("ctrl_alt-minus")

send("shift-d")
for c in "ata":
    send(c)

send("ctrl_alt-minus")

for c in "fast":
    send(c)
send("dot")
for c in "ps1":
    send(c)

send("ret", 0.5)
s.close()
print("Command sent!")
