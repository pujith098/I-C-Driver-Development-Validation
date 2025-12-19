#!/bin/bash
set -euo pipefail

LOG_DIR="logs/integration"
LOG_FILE="${LOG_DIR}/probe.log"

mkdir -p "${LOG_DIR}"

echo "===== I2C PROBE TEST =====" | tee "${LOG_FILE}"

if ! command -v i2cdetect >/dev/null 2>&1; then
    echo "[FAIL] i2cdetect not installed" | tee -a "${LOG_FILE}"
    exit 1
fi

echo "[TEST] Running i2cdetect on bus 1" | tee -a "${LOG_FILE}"
i2cdetect -y 1 | tee -a "${LOG_FILE}"

echo "[PASS] I2C probe test completed" | tee -a "${LOG_FILE}"

