#!/bin/bash
# File: scripts/run_all_tests.sh
set -e

TEST_ROOT="tests"
LOG_ROOT="logs"
mkdir -p "$LOG_ROOT"

echo "===== RUNNING ALL I2C DRIVER TESTS ====="

# Track failures
FAIL_COUNT=0

# Function to run tests in a category
run_category() {
    local category=$1
    local category_dir="${TEST_ROOT}/${category}"
    local log_dir="${LOG_ROOT}/${category}"
    mkdir -p "$log_dir"

    echo ">>> Running tests in category: $category"

    for test_script in "$category_dir"/*.sh; do
        [ -f "$test_script" ] || continue
        test_name=$(basename "$test_script")
        echo "--- Running $test_name ---"
        set +e
        bash "$test_script" &> "${log_dir}/${test_name%.sh}.log"
        RESULT=$?
        set -e

        if [ $RESULT -eq 0 ]; then
            echo "✓ $test_name PASSED"
        else
            echo "❌ $test_name FAILED (see ${log_dir}/${test_name%.sh}.log)"
            FAIL_COUNT=$((FAIL_COUNT+1))
        fi
    done
}

# Define the test categories in order
CATEGORIES=(
    "framework"
    "controller"
    "edge_cases"
    "hardware"
    "integration"
    "slave"
    "negative"
    "stress"
)

# Run all categories
for category in "${CATEGORIES[@]}"; do
    run_category "$category"
done

# Summary
echo "===== TEST SUMMARY ====="
if [ $FAIL_COUNT -eq 0 ]; then
    echo "All tests PASSED ✅"
else
    echo "$FAIL_COUNT test(s) FAILED ❌"
    exit 1
fi

