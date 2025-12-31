#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing power management"

SYSFS="/sys/bus/i2c/devices/${I2C_BUS}-00$(printf '%02x' ${I2C_LCD_ADDR})"

if [[ -f "${SYSFS}/display_control" ]]; then
    echo "off" | sudo tee "${SYSFS}/display_control" >/dev/null
    [[ "$(cat ${SYSFS}/display_control)" == "off" ]] && log_success "Display OFF"
    
    echo "on" | sudo tee "${SYSFS}/display_control" >/dev/null
    [[ "$(cat ${SYSFS}/display_control)" == "on" ]] && log_success "Display ON"
else
    log_warning "Power management not available"
fi

assert_summary || exit 1
exit 0
