#!/bin/bash
set -euo pipefail

LOG_DIR="logs/build"
LOG_FILE="${LOG_DIR}/load_driver.log"

mkdir -p "${LOG_DIR}"

echo "===== LOAD DRIVER =====" | tee "${LOG_FILE}"

echo "[LOAD] Inserting kernel module" | tee -a "${LOG_FILE}"
sudo insmod driver/i2c_lcd_2004a.ko >> "${LOG_FILE}" 2>&1 || true

echo "[LOAD] Checking module status" | tee -a "${LOG_FILE}"
lsmod | grep i2c_lcd_2004a >> "${LOG_FILE}" || true

echo "[LOAD] Loading device tree overlay" | tee -a "${LOG_FILE}"
sudo dtoverlay i2c-lcd-2004a-overlay >> "${LOG_FILE}" 2>&1 || true

echo "[LOAD] Driver load step completed" | tee -a "${LOG_FILE}"

