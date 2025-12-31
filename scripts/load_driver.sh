#!/bin/bash
set -e

echo "===== LOAD DRIVER ====="

KO_FILE=$(find driver -name "*.ko" | head -n 1)

if [ -z "$KO_FILE" ]; then
    echo "❌ Kernel module not found"
    exit 1
fi

echo "Loading module: $KO_FILE"
sudo insmod "$KO_FILE"

dmesg | tail -n 20

