#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing command response"

for cmd in 0x01 0x02 0x0C; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} ${cmd} 2>/dev/null || exit 1
    log_success "Command 0x$(printf '%02x' ${cmd}) sent"
    sleep 0.01
done

assert_summary || exit 1
exit 0
