#!/bin/bash
set -euo pipefail

LOG_DIR="logs/system"
LOG_FILE="${LOG_DIR}/setup.log"

mkdir -p "${LOG_DIR}"

echo "===== SETUP ENV =====" | tee "${LOG_FILE}"
echo "[SETUP] User: $(whoami)" | tee -a "${LOG_FILE}"
echo "[SETUP] Host: $(hostname)" | tee -a "${LOG_FILE}"
echo "[SETUP] Date: $(date)" | tee -a "${LOG_FILE}"

echo "[SETUP] Updating package lists" | tee -a "${LOG_FILE}"
sudo -n apt-get update >> "${LOG_FILE}" 2>&1 || {
    echo "[ERROR] sudo apt-get update failed (check sudo permissions)" | tee -a "${LOG_FILE}"
    exit 1
}

echo "[SETUP] Installing required packages" | tee -a "${LOG_FILE}"
sudo -n apt-get install -y \
    i2c-tools \
    build-essential \
    stress-ng >> "${LOG_FILE}" 2>&1 || {
    echo "[ERROR] Package installation failed" | tee -a "${LOG_FILE}"
    exit 1
}

echo "[SETUP] Verifying i2cdetect" | tee -a "${LOG_FILE}"
if ! command -v i2cdetect >/dev/null 2>&1; then
    echo "[ERROR] i2cdetect still not found after install" | tee -a "${LOG_FILE}"
    exit 1
fi

echo "[SETUP] Listing I2C devices" | tee -a "${LOG_FILE}"
ls /dev/i2c-* >> "${LOG_FILE}" 2>&1 || echo "[WARN] No I2C buses detected" | tee -a "${LOG_FILE}"

echo "[SETUP] Environment ready" | tee -a "${LOG_FILE}"

