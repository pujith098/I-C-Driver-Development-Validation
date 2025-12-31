#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Running tc_repeated_start"

# Test implementation here
assert_device_exists "${I2C_DEVICE}" || exit 1
i2cdetect -y ${I2C_BUS} >/dev/null 2>&1 || exit 1

log_success "tc_repeated_start completed"
assert_summary || exit 1
exit 0
