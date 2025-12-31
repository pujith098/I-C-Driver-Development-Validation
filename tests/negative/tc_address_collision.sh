#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing address collision"

for addr in 0x00 0x01 0x7F; do
    i2cget -y ${I2C_BUS} ${addr} 0x00 2>/dev/null && \
        log_warning "Address responded" || \
        log_success "Address rejected"
done

is_device_detected ${I2C_LCD_ADDR} && log_success "Main device OK" || exit 1

assert_summary || exit 1
exit 0
