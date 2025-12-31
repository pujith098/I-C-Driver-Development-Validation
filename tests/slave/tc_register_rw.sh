#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing register read/write"

for val in 0x01 0x80 0xFF; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} ${val} 2>/dev/null || exit 1
    log_success "Write ${val} OK"
done

for i in {1..10}; do
    i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || exit 1
done
log_success "Read operations OK"

assert_summary || exit 1
exit 0
