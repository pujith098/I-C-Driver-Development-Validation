#!/bin/bash
LOG=logs/build/unload_driver.log

sudo dtoverlay -r i2c-lcd-2004a >> $LOG 2>&1 || true
sudo rmmod i2c_lcd_2004a >> $LOG 2>&1 || true

