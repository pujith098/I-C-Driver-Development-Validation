#!/bin/bash
set -euo pipefail

LOG_DIR="logs/system"
LOG_FILE="${LOG_DIR}/setup.log"

mkdir -p "${LOG_DIR}"

echo "===== SETUP ENV =====" | tee "${LOG_FILE}"
echo "[SETUP] Host: $(hostname)" | tee -a "${LOG_FILE}"
echo "[SETUP] Date: $(date)" | tee -a "${LOG_FILE}"

echo "[SETUP] Installing required packages" | tee -a "${LOG_FILE}"
sudo apt-get update >> "${LOG_FILE}" 2>&1
sudo apt-get install -y \
    i2c-tools \
    build-essential \
    stress-ng >> "${LOG_FILE}" 2>&1

echo "[SETUP] Checking I2C devices" | tee -a "${LOG_FILE}"
ls /dev/i2c-* >> "${LOG_FILE}" 2>&1 || true

which i2cdetect >> "${LOG_FILE}" 2>&1 || {
    echo "[ERROR] i2cdetect not found" | tee -a "${LOG_FILE}"
    exit 1
}

echo "[SETUP] Environment ready" | tee -a "${LOG_FILE}"

