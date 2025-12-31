#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing LCD initialization sequence"

dmesg | tail -100 | grep -iq "initialization completed" && \
    log_success "Init message found" || log_warning "Init message not found"

i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null && \
    log_success "Device responsive" || exit 1

assert_summary || exit 1
exit 0
