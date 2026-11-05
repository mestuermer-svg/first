import socket, time

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect("/run/shm/monitor.sock")
time.sleep(0.2)
try:
    s.recv(4096)
except Exception:
    pass

def send(k, delay=0.04):
    s.sendall(f"sendkey {k}\n".encode())
    time.sleep(delay)
    try:
        s.recv(2048)
    except Exception:
        pass

def type_text(text):
    for c in text:
        if c == " ":
            send("spc")
        elif c == "-":
            send("minus")
        elif c == "\\":
            send("backslash")
        elif c == ":":
            send("shift-semicolon")
        elif c == ".":
            send("dot")
        elif c == "/":
            send("slash")
        elif c == "=":
            send("equal")
        elif c.isupper():
            send(f"shift-{c.lower()}")
        else:
            send(c)

# Clear any line in powershell
send("ctrl-c", 0.5)
send("esc", 0.2)

type_text('exit')
send("ret", 0.8)

s.close()
print("Exit sent!")
