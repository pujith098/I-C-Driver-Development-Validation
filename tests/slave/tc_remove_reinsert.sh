#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing remove/reinsert"

sudo dtoverlay -r i2c-lcd-2004a-overlay 2>/dev/null || true
sleep 2

sudo dtoverlay i2c-lcd-2004a-overlay 2>/dev/null || exit 1
sleep 3

is_device_detected ${I2C_LCD_ADDR} && log_success "Device reinserted" || exit 1

assert_summary || exit 1
exit 0
