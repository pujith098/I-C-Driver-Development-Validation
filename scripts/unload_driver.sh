#!/bin/bash

MOD_NAME="i2c_lcd_2004a"

if lsmod | grep -q "$MOD_NAME"; then
    sudo rmmod "$MOD_NAME"
    echo "✓ Driver unloaded"
else
    echo "✓ Driver not loaded"
fi

