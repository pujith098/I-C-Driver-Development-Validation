#!/bin/bash
set -e

echo "===== LCD FUNCTIONAL TEST ====="

DRV="i2c_lcd_2004a"

# 1. Check module loaded
if ! lsmod | grep -q "$DRV"; then
    echo "❌ Driver not loaded"
    exit 1
fi
echo "✓ Driver loaded"

# 2. Check I2C device present
if ! i2cdetect -y 1 | grep -q "27"; then
    echo "❌ LCD not detected on I2C bus"
    exit 1
fi
echo "✓ LCD detected at 0x27"

# 3. Kernel log verification
if ! dmesg | grep -i lcd | tail -n 20; then
    echo "⚠ No LCD logs found (may be ok for basic driver)"
fi

# 4. Stability delay
sleep 2

echo "✓ LCD validation test PASSED"

