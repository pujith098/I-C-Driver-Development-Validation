#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing signal integrity (SW check)"

for i in $(seq 1 100); do
    i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || exit 1
done

log_success "Signal integrity test passed"
assert_summary || exit 1
exit 0
