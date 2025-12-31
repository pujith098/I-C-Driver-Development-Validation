#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing overlay failure"

sudo dtoverlay non-existent-overlay 2>/dev/null && \
    { log_error "Bad overlay loaded"; exit 1; } || \
    log_success "Bad overlay rejected"

i2cdetect -y ${I2C_BUS} >/dev/null 2>&1 && log_success "Bus OK" || exit 1

assert_summary || exit 1
exit 0
