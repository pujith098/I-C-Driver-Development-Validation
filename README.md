# I2C Driver Validation Framework v2.0

Industrial-grade I2C driver validation for Raspberry Pi 4.

## Quick Start

```bash
# 1. Setup environment
bash scripts/setup_env.sh

# 2. Build
make

# 3. Load driver
sudo insmod driver/i2c_lcd_2004a.ko
sudo dtoverlay dts/i2c-lcd-2004a-overlay.dtbo

# 4. Run tests
cd tests && bash framework/test_framework.sh

# 5. View results
cat ../logs/reports/test_results.csv
```

## Checking Results

```bash
# Quick summary
cat logs/reports/test_results.csv | column -t -s','

# Failed tests only
grep FAIL logs/reports/test_results.csv

# View specific test log
cat logs/controller/tc_bus_enumeration.log

# Check driver
dmesg | grep -i lcd | tail -20

# Check device stats
cat /sys/bus/i2c/devices/1-0027/stats
```

## Test Categories

- **Controller (15)**: Bus enumeration, clock accuracy, timeout handling
- **Slave (9)**: Device probe, sysfs interface, power management
- **Integration (6)**: Controller+slave, hotplug, concurrent access
- **Negative (7)**: Invalid addresses, error handling
- **Stress (5)**: 10K operations, long duration, memory leak
- **Edge Cases (5)**: Boundary values, rapid changes
- **Hardware (4)**: Signal integrity, timing, electrical params

**Total: 51 comprehensive tests**
