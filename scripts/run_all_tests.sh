#!/bin/bash
# Run all tests, continue even if some fail
set +e

echo "===== RUNNING ALL I2C DRIVER TESTS ====="

TOTAL=0
PASSED=0
FAILED=0

for category in framework controller edge_cases hardware integration slave negative stress; do
    echo ">>> Running tests in category: $category"
    mkdir -p logs/$category
    for test_script in tests/$category/*.sh; do
        TOTAL=$((TOTAL + 1))
        echo "--- Running $(basename $test_script) ---"
        bash $test_script > logs/$category/$(basename $test_script).log 2>&1
        rc=$?
        if [ $rc -eq 0 ]; then
            echo "✓ $(basename $test_script) PASSED"
            PASSED=$((PASSED + 1))
        else
            echo "❌ $(basename $test_script) FAILED (see logs/$category/$(basename $test_script).log)"
            FAILED=$((FAILED + 1))
        fi
    done
done

echo "===== TEST SUMMARY ====="
echo "Total tests: $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"

# Return non-zero if any test failed
if [ $FAILED -gt 0 ]; then
    exit 1
fi

