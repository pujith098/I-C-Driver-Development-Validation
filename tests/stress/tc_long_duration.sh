#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing long duration (5 min)"

END_TIME=$(($(date +%s) + 300))
OPS=0
ERRORS=0

while [[ $(date +%s) -lt ${END_TIME} ]]; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x80 2>/dev/null && \
        OPS=$((OPS + 1)) || ERRORS=$((ERRORS + 1))
    (( OPS % 100 == 0 )) && log_info "Ops: ${OPS}, Errors: ${ERRORS}"
    sleep 0.1
done

RATE=$(awk "BEGIN {printf \"%.4f\", (${ERRORS}/${OPS})*100}")
log_info "Error rate: ${RATE}%"

(( $(echo "${RATE} < 1.0" | bc -l) )) && exit 0 || exit 1
