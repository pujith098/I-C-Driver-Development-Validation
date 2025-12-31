#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing bus conflict"

for i in {1..20}; do
    i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null &
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null &
done
wait

is_device_detected ${I2C_LCD_ADDR} && log_success "Conflict handled" || exit 1

assert_summary || exit 1
exit 0
