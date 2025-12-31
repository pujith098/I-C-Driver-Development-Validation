#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing sysfs interface"

SYSFS="/sys/bus/i2c/devices/${I2C_BUS}-00$(printf '%02x' ${I2C_LCD_ADDR})"

[[ -d "${SYSFS}" ]] || { log_error "Sysfs not found"; exit 1; }

for attr in stats display_control clear_display; do
    [[ -f "${SYSFS}/${attr}" ]] || { log_error "${attr} missing"; exit 1; }
    log_success "${attr} exists"
done

cat "${SYSFS}/stats" && log_success "Stats readable"

assert_summary || exit 1
exit 0
