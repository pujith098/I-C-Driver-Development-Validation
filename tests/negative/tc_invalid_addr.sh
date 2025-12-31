#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing invalid address"

for addr in 0x00 0x7F; do
    i2cget -y ${I2C_BUS} ${addr} 2>/dev/null && \
        log_warning "Address accepted" || \
        log_success "Address rejected"
done

assert_summary || exit 1
exit 0
