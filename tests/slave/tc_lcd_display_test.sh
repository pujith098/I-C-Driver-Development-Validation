#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing LCD display"

i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null
sleep 0.1

for i in {1..10}; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x80 2>/dev/null || exit 1
done

log_success "Display test completed"
assert_summary || exit 1
exit 0
