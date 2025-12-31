#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing concurrent access"

for round in {1..5}; do
    for proc in {1..5}; do
        (i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null) &
    done
    wait
done

i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null && \
    log_success "Device responsive" || exit 1

assert_summary || exit 1
exit 0
