#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing frequency stress"

for cycle in {1..10}; do
    for i in {1..100}; do
        i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || exit 1
    done
    log_info "Cycle ${cycle}/10 complete"
done

log_success "Frequency stress test passed"
assert_summary || exit 1
exit 0
