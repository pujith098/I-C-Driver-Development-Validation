#!/bin/bash
set -e
LOG=logs/build/load_driver.log

echo "[LOAD] Building driver" | tee $LOG
cd driver
make clean >> ../$LOG 2>&1
make >> ../$LOG 2>&1

echo "[LOAD] Loading module" | tee -a ../$LOG
sudo insmod i2c_lcd_2004a.ko >> ../$LOG 2>&1

echo "[LOAD] Loading DT overlay" | tee -a ../$LOG
sudo dtoverlay i2c-lcd-2004a >> ../$LOG 2>&1

dmesg | tail -50 >> ../$LOG

