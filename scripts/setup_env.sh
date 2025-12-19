#!/bin/bash
set -e
LOG=logs/system/setup.log

echo "[SETUP] Installing tools" | tee $LOG
sudo apt update >> $LOG 2>&1
sudo apt install -y i2c-tools stress-ng >> $LOG 2>&1

ls /dev/i2c-* >> $LOG

