#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing partial transfers"

for i in {1..20}; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x80 2>/dev/null || exit 1
done

log_success "Partial transfer test done"
assert_summary || exit 1
exit 0
