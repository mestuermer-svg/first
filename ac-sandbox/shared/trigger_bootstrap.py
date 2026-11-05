import socket, time

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect("/run/shm/monitor.sock")
time.sleep(0.2)
try:
    s.recv(4096)
except Exception:
    pass

def send_key(key, delay=0.06):
    s.sendall(f"sendkey {key}\n".encode())
    time.sleep(delay)
    try:
        s.recv(2048)
    except Exception:
        pass

def type_de(text):
    for ch in text:
        if ch == " ":
            send_key("spc", 0.05)
        elif ch == "/":
            send_key("shift-7", 0.05)
        elif ch == ".":
            send_key("dot", 0.05)
        elif ch == "y":
            send_key("z", 0.05)
        elif ch == "z":
            send_key("y", 0.05)
        elif ch.isupper():
            send_key(f"shift-{ch.lower()}", 0.05)
        else:
            send_key(ch, 0.05)

# PowerShell is ALREADY focused at C:\Users\Docker>!
# Do NOT send Alt+Esc! Just copy fast.ps1 and run it!
send_key("esc", 0.3)
type_de("cd //host.lan/Data")
send_key("ret", 0.8)
type_de("cp fast.ps1 /Users/Docker/fast.ps1")
send_key("ret", 0.8)
type_de("cd /Users/Docker")
send_key("ret", 0.8)
type_de("powershell ")
send_key("slash", 0.1)
type_de("ep Bypass ")
send_key("slash", 0.1)
type_de("File fast.ps1")
send_key("ret", 1.0)
s.close()
print("Executed updated fast.ps1 with local OpenSSH.msi in focused PowerShell")
