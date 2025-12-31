#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing multiple devices"

DEVICES=$(i2cdetect -y ${I2C_BUS} 2>/dev/null | grep -oE '[0-9a-f]{2}' | grep -v '^--$')
log_info "Found devices: ${DEVICES}"

for addr in ${DEVICES}; do
    i2cget -y ${I2C_BUS} 0x${addr} 2>/dev/null || true
    log_info "Accessed 0x${addr}"
done

log_success "Multiple device test done"
assert_summary || exit 1
exit 0
