import glob

print("--- Checking /run/*.sh for install / script / shared hooks ---")
for f in sorted(glob.glob("/run/*.sh")):
    try:
        with open(f, "r", errors="ignore") as fp:
            lines = [l.strip() for l in fp if any(k in l.lower() for k in ["shared", "oem", "custom", "bootstrap", "script"])]
            if lines:
                print(f"File {f}: ({len(lines)} matches)")
                for l in lines[:5]:
                    print("  ", l)
    except Exception as e:
        pass
