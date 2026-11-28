# Autonomer Sandbox-Testbericht (`20261128_005825`)

- **SimRacer Host:** `192.168.178.68`
- **DryRun:** `False`
- **Gesamtdauer:** 225.99 s

| Phase | Agent | Task-ID | Status | Dauer (s) | Details |
| :--- | :--- | :--- | :--- | ---: | :--- |
| 0. Pre-Flight & Policy | pitwall | `-` | **OK** | 0.1 | Mode=DELEGATED, Paused=False |
| 1. Docker Sandbox Start | light | `autotest_20261128_005835_v2yr` | **Unsupported** | 91.75 | Container gestartet & @dark Handshake |
| 2. @dark Readiness | dark | `autotest_20261128_005957_vi20` | **Success** | 5.38 | @dark antwortet in der Sandbox |
| 3. Auto Transfer & Install | light->dark | `autotest_20261128_010008_531l` | **Pending** | 77.14 | Car=13_pub2 uebertragen & verifiziert |
| 4. Strecke & Trainingssession | dark | `autotest_20261128_010125_rhy2` | **Success** | 51.59 | Session: 13_pub2 @ monza (Practice) |
