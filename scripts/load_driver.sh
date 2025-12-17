#!/bin/bash
set -e

echo "[LOAD] Loading I2C dummy driver"
insmod "$(dirname "$0")/../driver/i2c_dummy_driver.ko"

echo "[LOAD] Driver loaded successfully"

