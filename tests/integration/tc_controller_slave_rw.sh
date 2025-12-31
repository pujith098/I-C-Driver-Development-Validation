#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing controller-slave read/write"

SUCCESS=0
for i in $(seq 1 50); do
    if i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null && \
       i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null; then
        SUCCESS=$((SUCCESS + 1))
    fi
done

RATE=$(awk "BEGIN {printf \"%.1f\", (${SUCCESS}/50)*100}")
log_info "Success rate: ${RATE}%"

(( $(echo "${RATE} >= 95.0" | bc -l) )) && exit 0 || exit 1
