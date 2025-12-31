#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing device reset"

i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null
sleep 0.1

i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null && \
    log_success "Device responsive after reset" || exit 1

assert_summary || exit 1
exit 0
