#!/bin/bash
set -euo pipefail
export PATH=$PATH:/usr/sbin:/sbin

echo "===== SETUP ENV ====="
sudo apt-get update -qq
sudo apt-get install -y i2c-tools build-essential device-tree-compiler python3 bc
ls /dev/i2c-* 2>&1 || echo "No I2C devices"
echo "✓ Setup complete"
