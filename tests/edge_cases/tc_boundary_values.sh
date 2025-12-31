#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing boundary values"

for val in 0x00 0x01 0x7F 0x80 0xFE 0xFF; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} ${val} 2>/dev/null || exit 1
    log_success "Value ${val} OK"
done

assert_summary || exit 1
exit 0
