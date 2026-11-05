import socket

for p in [22, 3389, 445]:
    s = socket.socket()
    s.settimeout(2.0)
    try:
        s.connect(("172.30.0.2", p))
        print(f"SUCCESS CONNECTED to 172.30.0.2:{p}!")
        s.close()
    except Exception as e:
        print(f"FAILED on port {p}:", type(e), e)
