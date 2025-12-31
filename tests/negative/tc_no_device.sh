#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing no device response"

i2cget -y ${I2C_BUS} 0x50 0x00 2>/dev/null && \
    { log_error "Unexpected success"; exit 1; } || \
    log_success "Correctly failed"

is_device_detected ${I2C_LCD_ADDR} && log_success "Main device OK" || exit 1

assert_summary || exit 1
exit 0
