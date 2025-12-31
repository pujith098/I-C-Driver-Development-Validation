#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing timing analysis"

START=$(date +%s%N)
for i in $(seq 1 100); do
    i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || exit 1
done
END=$(date +%s%N)

DURATION=$(( (END - START) / 1000000 ))
log_info "100 ops took ${DURATION}ms"

log_success "Timing analysis done"
assert_summary || exit 1
exit 0
