#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing NACK handling"

i2cset -y ${I2C_BUS} 0x55 0xAA 2>/dev/null && \
    { log_error "Unexpected ACK"; exit 1; } || \
    log_success "NACK received"

sleep 1
i2cdetect -y ${I2C_BUS} >/dev/null 2>&1 && log_success "Bus recovered" || exit 1

for i in {1..5}; do
    i2cget -y ${I2C_BUS} 0x56 0x00 2>/dev/null || true
done

is_device_detected ${I2C_LCD_ADDR} && log_success "Device accessible" || exit 1

assert_summary || exit 1
exit 0
