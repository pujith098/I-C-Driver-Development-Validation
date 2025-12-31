#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing device probe detection"

assert_module_loaded "${DRIVER_MODULE}" || exit 1

if is_device_detected ${I2C_LCD_ADDR}; then
    log_success "Device detected at 0x$(printf '%02x' ${I2C_LCD_ADDR})"
else
    log_error "Device not detected"
    exit 1
fi

dmesg | tail -100 | grep -iq "LCD probe" && log_success "Probe message found"

assert_summary || exit 1
exit 0
