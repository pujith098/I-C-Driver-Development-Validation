#!/bin/bash
FREQ=$1
LOG=logs/system/i2c_freq_$FREQ.log

echo "[I2C] Setting frequency to $FREQ" | tee $LOG
sudo sed -i "s/i2c_arm_baudrate=.*/i2c_arm_baudrate=$FREQ/" /boot/config.txt
echo "[I2C] Reboot required" | tee -a $LOG

