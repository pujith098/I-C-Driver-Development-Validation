#!/bin/bash
ASSERT_TOTAL=0
ASSERT_PASSED=0
ASSERT_FAILED=0

assert_reset() { ASSERT_TOTAL=0; ASSERT_PASSED=0; ASSERT_FAILED=0; }
assert_device_exists() { ASSERT_TOTAL=$((ASSERT_TOTAL+1)); [[ -e "$1" ]] && ASSERT_PASSED=$((ASSERT_PASSED+1)) || ASSERT_FAILED=$((ASSERT_FAILED+1)); }
assert_module_loaded() { ASSERT_TOTAL=$((ASSERT_TOTAL+1)); lsmod | grep -q "^$1" && ASSERT_PASSED=$((ASSERT_PASSED+1)) || ASSERT_FAILED=$((ASSERT_FAILED+1)); }
assert_summary() { [[ ${ASSERT_FAILED} -eq 0 ]]; }
export -f assert_reset assert_device_exists assert_module_loaded assert_summary
