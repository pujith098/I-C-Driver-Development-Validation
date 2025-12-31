#!/bin/bash
mkdir -p logs/system
dmesg > logs/system/dmesg.log 2>&1 || true
journalctl -k --no-pager > logs/system/kernel.log 2>&1 || true
echo "✓ Logs collected"
