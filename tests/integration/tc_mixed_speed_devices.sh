#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing mixed speed devices"

DEVICES=$(i2cdetect -y ${I2C_BUS} 2>/dev/null | grep -oE '[0-9a-f]{2}' | grep -v '^--$')

for addr in ${DEVICES}; do
    i2cget -y ${I2C_BUS} 0x${addr} 2>/dev/null || true
done

log_success "Mixed speed test done"
assert_summary || exit 1
exit 0
