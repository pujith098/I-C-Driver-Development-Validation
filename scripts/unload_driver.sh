#!/bin/bash
sudo dtoverlay -r i2c-lcd-2004a-overlay 2>/dev/null || true
sudo rmmod i2c_lcd_2004a 2>/dev/null || true
echo "✓ Driver unloaded"
