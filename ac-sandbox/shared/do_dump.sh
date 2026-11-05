#!/bin/bash
tcpdump -n -i any port 3389 > /shared/tcpdump_3389.log 2>&1 &
TCP_PID=$!
sleep 1
python3 /shared/test_connect_22.py
sleep 1
kill $TCP_PID
cat /shared/tcpdump_3389.log
