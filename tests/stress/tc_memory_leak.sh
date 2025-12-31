#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing memory leak"

BEFORE=$(free -m | grep Mem | awk '{print $3}')

for i in $(seq 1 1000); do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null || true
done

sleep 2
AFTER=$(free -m | grep Mem | awk '{print $3}')
DIFF=$((AFTER - BEFORE))

log_info "Memory delta: ${DIFF}MB"
(( DIFF < 100 )) && log_success "No significant leak" || log_warning "Memory increased"

assert_summary || exit 1
exit 0
