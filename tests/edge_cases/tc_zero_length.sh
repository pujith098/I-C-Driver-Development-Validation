#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing zero length transfers"

i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || log_warning "Zero read failed"

log_success "Zero length test done"
assert_summary || exit 1
exit 0
