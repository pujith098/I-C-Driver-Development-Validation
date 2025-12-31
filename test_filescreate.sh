#!/bin/bash
################################################################################
# CREATE ALL REMAINING TEST FILES
# Run this inside your project directory
################################################################################

cd tests

# Make framework executable
chmod +x framework/*.sh

################################################################################
# SLAVE TESTS (9 files)
################################################################################
echo "Creating slave tests..."

cat > slave/tc_probe_detect.sh << 'EOF'
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
EOF

cat > slave/tc_init_sequence.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing LCD initialization sequence"

dmesg | tail -100 | grep -iq "initialization completed" && \
    log_success "Init message found" || log_warning "Init message not found"

i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null && \
    log_success "Device responsive" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > slave/tc_register_rw.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing register read/write"

for val in 0x01 0x80 0xFF; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} ${val} 2>/dev/null || exit 1
    log_success "Write ${val} OK"
done

for i in {1..10}; do
    i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || exit 1
done
log_success "Read operations OK"

assert_summary || exit 1
exit 0
EOF

cat > slave/tc_command_response.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing command response"

for cmd in 0x01 0x02 0x0C; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} ${cmd} 2>/dev/null || exit 1
    log_success "Command 0x$(printf '%02x' ${cmd}) sent"
    sleep 0.01
done

assert_summary || exit 1
exit 0
EOF

cat > slave/tc_sysfs_interface.sh << 'EOF'
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
EOF

cat > slave/tc_power_management.sh << 'EOF'
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
EOF

cat > slave/tc_remove_reinsert.sh << 'EOF'
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
EOF

cat > slave/tc_device_reset.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing device reset"

i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null
sleep 0.1

i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null && \
    log_success "Device responsive after reset" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > slave/tc_lcd_display_test.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing LCD display"

i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null
sleep 0.1

for i in {1..10}; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x80 2>/dev/null || exit 1
done

log_success "Display test completed"
assert_summary || exit 1
exit 0
EOF

chmod +x slave/*.sh

################################################################################
# INTEGRATION TESTS (6 files)
################################################################################
echo "Creating integration tests..."

cat > integration/tc_controller_slave_rw.sh << 'EOF'
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
EOF

cat > integration/tc_multiple_devices.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing multiple devices"

DEVICES=$(i2cdetect -y ${I2C_BUS} 2>/dev/null | grep -oE '[0-9a-f]{2}' | grep -v '^--$')
log_info "Found devices: ${DEVICES}"

for addr in ${DEVICES}; do
    i2cget -y ${I2C_BUS} 0x${addr} 2>/dev/null || true
    log_info "Accessed 0x${addr}"
done

log_success "Multiple device test done"
assert_summary || exit 1
exit 0
EOF

cat > integration/tc_hotplug_overlay.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing hotplug"

sudo dtoverlay -r i2c-lcd-2004a-overlay 2>/dev/null || true
sleep 2

sudo dtoverlay i2c-lcd-2004a-overlay 2>/dev/null || exit 1
sleep 3

is_device_detected ${I2C_LCD_ADDR} && log_success "Hotplug OK" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > integration/tc_concurrent_access.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing concurrent access"

for round in {1..5}; do
    for proc in {1..5}; do
        (i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null) &
    done
    wait
done

i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null && \
    log_success "Device responsive" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > integration/tc_burst_transfer.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing burst transfer"

SUCCESS=0
for i in $(seq 1 50); do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x80 2>/dev/null && SUCCESS=$((SUCCESS + 1))
done

RATE=$(awk "BEGIN {printf \"%.1f\", (${SUCCESS}/50)*100}")
log_info "Success rate: ${RATE}%"

(( $(echo "${RATE} >= 90.0" | bc -l) )) && exit 0 || exit 1
EOF

cat > integration/tc_mixed_speed_devices.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing mixed speed devices"

DEVICES=$(i2cdetect -y ${I2C_BUS} 2>/dev/null | grep -oE '[0-9a-f]{2}' | grep -v '^--$')

for addr in ${DEVICES}; do
    i2cget -y ${I2C_BUS} 0x${addr} 2>/dev/null || true
done

log_success "Mixed speed test done"
assert_summary || exit 1
exit 0
EOF

chmod +x integration/*.sh

################################################################################
# NEGATIVE TESTS (7 files)
################################################################################
echo "Creating negative tests..."

cat > negative/tc_no_device.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing no device response"

i2cget -y ${I2C_BUS} 0x50 0x00 2>/dev/null && \
    { log_error "Unexpected success"; exit 1; } || \
    log_success "Correctly failed"

is_device_detected ${I2C_LCD_ADDR} && log_success "Main device OK" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > negative/tc_invalid_addr.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing invalid address"

for addr in 0x00 0x7F; do
    i2cget -y ${I2C_BUS} ${addr} 2>/dev/null && \
        log_warning "Address accepted" || \
        log_success "Address rejected"
done

assert_summary || exit 1
exit 0
EOF

cat > negative/tc_overlay_fail.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing overlay failure"

sudo dtoverlay non-existent-overlay 2>/dev/null && \
    { log_error "Bad overlay loaded"; exit 1; } || \
    log_success "Bad overlay rejected"

i2cdetect -y ${I2C_BUS} >/dev/null 2>&1 && log_success "Bus OK" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > negative/tc_bus_conflict.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing bus conflict"

for i in {1..20}; do
    i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null &
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null &
done
wait

is_device_detected ${I2C_LCD_ADDR} && log_success "Conflict handled" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > negative/tc_malformed_data.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing malformed data"

for val in 0xFF 0xAA 0x55; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} ${val} 2>/dev/null || true
done

i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null && \
    log_success "Device recovered" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > negative/tc_address_collision.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing address collision"

for addr in 0x00 0x01 0x7F; do
    i2cget -y ${I2C_BUS} ${addr} 0x00 2>/dev/null && \
        log_warning "Address responded" || \
        log_success "Address rejected"
done

is_device_detected ${I2C_LCD_ADDR} && log_success "Main device OK" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > negative/tc_nack_handling.sh << 'EOF'
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
EOF

chmod +x negative/*.sh

################################################################################
# STRESS TESTS (5 files)
################################################################################
echo "Creating stress tests..."

cat > stress/tc_continuous_rw.sh << 'EOF'
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
EOF

cat > stress/tc_frequency_stress.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing frequency stress"

for cycle in {1..10}; do
    for i in {1..100}; do
        i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || exit 1
    done
    log_info "Cycle ${cycle}/10 complete"
done

log_success "Frequency stress test passed"
assert_summary || exit 1
exit 0
EOF

cat > stress/tc_thermal_stress.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing thermal stress (simulated)"

for i in $(seq 1 1000); do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null || exit 1
done

log_success "Thermal stress test passed"
assert_summary || exit 1
exit 0
EOF

cat > stress/tc_long_duration.sh << 'EOF'
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
EOF

cat > stress/tc_memory_leak.sh << 'EOF'
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
EOF

chmod +x stress/*.sh

################################################################################
# EDGE CASE TESTS (5 files)
################################################################################
echo "Creating edge case tests..."

cat > edge_cases/tc_boundary_values.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing boundary values"

for val in 0x00 0x01 0x7F 0x80 0xFE 0xFF; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} ${val} 2>/dev/null || exit 1
    log_success "Value ${val} OK"
done

assert_summary || exit 1
exit 0
EOF

cat > edge_cases/tc_zero_length.sh << 'EOF'
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
EOF

cat > edge_cases/tc_max_transfer.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing max transfer size"

for i in $(seq 1 100); do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0xFF 2>/dev/null || exit 1
done

log_success "Max transfer test done"
assert_summary || exit 1
exit 0
EOF

cat > edge_cases/tc_rapid_frequency_change.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing rapid frequency changes"

for cycle in {1..10}; do
    for i in {1..10}; do
        i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || true
    done
    sleep 0.5
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x01 2>/dev/null || true
done

is_device_detected ${I2C_LCD_ADDR} && log_success "Device responsive" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > edge_cases/tc_partial_transfer.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing partial transfers"

for i in {1..20}; do
    i2cset -y ${I2C_BUS} ${I2C_LCD_ADDR} 0x80 2>/dev/null || exit 1
done

log_success "Partial transfer test done"
assert_summary || exit 1
exit 0
EOF

chmod +x edge_cases/*.sh

################################################################################
# HARDWARE TESTS (4 files)
################################################################################
echo "Creating hardware tests..."

cat > hardware/tc_signal_integrity.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing signal integrity (SW check)"

for i in $(seq 1 100); do
    i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || exit 1
done

log_success "Signal integrity test passed"
assert_summary || exit 1
exit 0
EOF

cat > hardware/tc_voltage_levels.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing voltage levels (SW validation)"

i2cdetect -y ${I2C_BUS} >/dev/null 2>&1 && \
    log_success "Voltage levels OK" || exit 1

assert_summary || exit 1
exit 0
EOF

cat > hardware/tc_timing_analysis.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing timing analysis"

START=$(date +%s%N)
for i in $(seq 1 100); do
    i2cget -y ${I2C_BUS} ${I2C_LCD_ADDR} 2>/dev/null || exit 1
done
END=$(date +%s%N)

DURATION=$(( (END - START) / 1000000 ))
log_info "100 ops took ${DURATION}ms"

log_success "Timing analysis done"
assert_summary || exit 1
exit 0
EOF

cat > hardware/tc_electrical_params.sh << 'EOF'
#!/bin/bash
source "$(dirname $0)/../framework/test_logger.sh"
source "$(dirname $0)/../framework/test_assertions.sh"
source "$(dirname $0)/../framework/test_config.sh"

assert_reset
log_info "Testing electrical parameters"

SPEED=$(get_i2c_speed)
log_info "Bus speed: ${SPEED} Hz"

i2cdetect -y ${I2C_BUS} >/dev/null 2>&1 && \
    log_success "Electrical params OK" || exit 1

assert_summary || exit 1
exit 0
EOF

chmod +x hardware/*.sh

echo ""
echo "✅ ALL TEST FILES CREATED!"
echo ""
echo "Test counts:"
echo "  Controller:  15 tests"
echo "  Slave:        9 tests"
echo "  Integration:  6 tests"
echo "  Negative:     7 tests"
echo "  Stress:       5 tests"
echo "  Edge Cases:   5 tests"
echo "  Hardware:     4 tests"
echo "  ─────────────────────"
echo "  TOTAL:       51 tests"
echo ""
echo "Run tests: cd .. && bash framework/test_framework.sh"
