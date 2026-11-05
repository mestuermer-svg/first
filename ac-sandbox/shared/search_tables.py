with open('/run/network.sh') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'getHostPorts' in l:
        print(f"Line {i+1}: {l.strip()}")
        for j in range(max(0, i-5), min(len(lines), i+25)):
            print(f"  {j+1}: {lines[j]}", end="")
        print("="*40)
