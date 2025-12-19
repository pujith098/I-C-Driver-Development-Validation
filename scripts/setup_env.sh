#!/bin/bash
set -euo pipefail

# ---------- CONFIG ----------
LOG_DIR="logs/system"
LOG_FILE="${LOG_DIR}/setup.log"

# ---------- PREP ----------
mkdir -p "${LOG_DIR}"

echo "===== SETUP ENV =====" | tee "${LOG_FILE}"
echo "[SETUP] Host: $(hostname)" | tee -a "${LOG_FILE}"
echo "[SETUP] Date: $(date)" | tee -a "${LOG_FILE}"

# ---------- INSTALL TOOLS ----------
echo "[SETUP] Installing required packages" | tee -a "${LOG_FILE}"

sudo apt-get update >> "${LOG_FILE}" 2>&1
sudo apt-get install -y \
    i2c-tools \
    build-essential \
    stress-ng \
    >> "${LOG_FILE}" 2>&1

# ---------- VERIFY I2C ----------
echo "[SETUP] Checking I2C devices" | tee -a "${LOG_FILE}"

if ls /dev/i2c-* >/dev/null 2>&1; then
    ls /dev/i2c-* >> "${LOG_FILE}"
else
    echo "[WARN] No /dev/i2c-* devices found" | tee -a "${LOG_FILE}"
fi

echo "[SETUP] Environment ready" | tee -a "${LOG_FILE}"

