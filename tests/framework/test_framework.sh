#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_logger.sh"
source "${SCRIPT_DIR}/test_assertions.sh"
source "${SCRIPT_DIR}/test_config.sh"

TOTAL=0; PASSED=0; FAILED=0

echo "TEST,RESULT,DURATION,TIMESTAMP" > "${RESULT_CSV}"

run_test() {
    local test="$1"
    local cat="$2"
    local name=$(basename "${test}" .sh)
    local log="${LOG_BASE_DIR}/${cat}/${name}.log"
    
    TOTAL=$((TOTAL+1))
    log_test_start "${name}"
    
    local start=$(date +%s)
    if timeout ${TEST_TIMEOUT} bash "${test}" > "${log}" 2>&1; then
        PASSED=$((PASSED+1))
        log_test_pass "${name}"
        echo "${cat}/${name},PASS,$(($(date +%s)-start)),$(date -Iseconds)" >> "${RESULT_CSV}"
    else
        FAILED=$((FAILED+1))
        log_test_fail "${name}" "See ${log}"
        echo "${cat}/${name},FAIL,$(($(date +%s)-start)),$(date -Iseconds)" >> "${RESULT_CSV}"
    fi
}

run_category() {
    local cat="$1"
    local dir="${PROJECT_ROOT}/tests/${cat}"
    [[ -d "${dir}" ]] || return
    for test in "${dir}"/tc_*.sh; do
        [[ -x "${test}" ]] && run_test "${test}" "${cat}"
    done
}

run_category controller
run_category slave
run_category integration
run_category negative
run_category stress

echo ""
log_info "═══════════ SUMMARY ═══════════"
log_info "Total:  ${TOTAL}"
log_success "Passed: ${PASSED}"
[[ ${FAILED} -gt 0 ]] && log_error "Failed: ${FAILED}"
log_info "Results: ${RESULT_CSV}"

[[ ${FAILED} -eq 0 ]]
