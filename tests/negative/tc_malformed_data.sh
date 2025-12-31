#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing malformed data"

for val in 0xFF 0xAA 0x55; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} ${val} 2>/dev/null || true
done

i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null && \
    log_success "Device recovered" || exit 1

assert_summary || exit 1
exit 0
