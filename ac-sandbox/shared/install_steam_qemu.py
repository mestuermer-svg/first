import socket
import time

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect("/run/shm/monitor.sock")
time.sleep(0.3)
s.recv(4096)

def send_key(key):
    s.sendall(f"sendkey {key}\n".encode())
    time.sleep(0.08)
    s.recv(2048)

print("Sending Win+R...")
send_key("meta_l-r")
time.sleep(2.0)

# In Run dialog, execute PowerShell to launch Steam installer from shared folder
cmd = r"powershell -WindowStyle Hidden -Command Start-Process -FilePath \\host.lan\Data\SteamSetup.exe -ArgumentList /S -Wait"

key_map = {
    " ": "spc",
    "-": "minus",
    "\\": "backslash",
    "/": "slash",
    ":": "shift-semicolon",
    ".": "dot",
    "$": "shift-4",
    "_": "shift-minus",
}

for ch in cmd:
    if ch in key_map:
        send_key(key_map[ch])
    elif ch.isupper():
        send_key(f"shift-{ch.lower()}")
    else:
        send_key(ch)
    time.sleep(0.04)

time.sleep(0.5)
send_key("ret")
time.sleep(1.0)
s.close()
print("Run command sent successfully!")
