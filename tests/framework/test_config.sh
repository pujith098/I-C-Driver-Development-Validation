#!/bin/bash
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export LOG_BASE_DIR="${PROJECT_ROOT}/logs"
export I2C_BUS=1
export I2C_LCD_ADDR=0x27
export DRIVER_MODULE="i2c_lcd_2004a"
export TEST_TIMEOUT=300
export STRESS_ITERATIONS=10000
export RESULT_CSV="${LOG_BASE_DIR}/reports/test_results.csv"

is_device_detected() { i2cdetect -y ${I2C_BUS} 2>/dev/null | grep -q "$(printf '%02x' $1)"; }
export -f is_device_detected
