#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing continuous R/W (${STRESS_ITERATIONS} ops)"

ERRORS=0
for i in $(seq 1 ${STRESS_ITERATIONS}); do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0xAA 2>/dev/null || ERRORS=$((ERRORS + 1))
    (( i % 1000 == 0 )) && log_info "Progress: ${i}/${STRESS_ITERATIONS}"
done

RATE=$(awk "BEGIN {printf \"%.4f\", (${ERRORS}/${STRESS_ITERATIONS})*100}")
log_info "Error rate: ${RATE}%"

(( $(echo "${RATE} < 1.0" | bc -l) )) && exit 0 || exit 1
