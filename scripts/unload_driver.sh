#!/bin/bash
set -e

echo "[UNLOAD] Unloading I2C dummy driver"
rmmod i2c_dummy_driver

echo "[UNLOAD] Driver unloaded successfully"

