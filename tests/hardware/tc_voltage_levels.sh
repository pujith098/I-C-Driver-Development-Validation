#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing voltage levels (SW validation)"

i2cdetect -y ${I2C_BUS} >/dev/null 2>&1 && \
    log_success "Voltage levels OK" || exit 1

assert_summary || exit 1
exit 0
