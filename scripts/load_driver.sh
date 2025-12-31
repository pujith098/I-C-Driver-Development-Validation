#!/bin/bash
set -euo pipefail

echo "===== LOAD DRIVER ====="
sudo insmod driver/i2c_lcd_2004a.ko
lsmod | grep i2c_lcd_2004a
sudo dtoverlay dts/i2c-lcd-2004a-overlay.dtbo
echo "✓ Driver loaded"
