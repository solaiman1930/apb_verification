#!/bin/bash

set -o pipefail

# Configuration
TEST_PKG="../tb/test_lib/apb_test_pkg.sv"
SNAPSHOT="tb_top_sim"

# Regression counters
TOTAL=0
PASSED=0
FAILED=0

# Store test names
PASSED_TESTS=()
FAILED_TESTS=()

# Check whether the test package exists
if [[ ! -f "$TEST_PKG" ]]; then
    echo "ERROR: Test package not found: $TEST_PKG"
    exit 1
fi

# Extract test names from the package
# Exclude the base test because it is not a runnable test
mapfile -t TESTS < <(
    grep -oE '"apb_[^"]+_test\.sv"' "$TEST_PKG" |
    sed 's/"//g; s/\.sv$//' |
    grep -v '^apb_base_test$'
)

# Check whether any tests were found
if [[ ${#TESTS[@]} -eq 0 ]]; then
    echo "ERROR: No test cases found in $TEST_PKG"
    exit 1
fi

# Regression header
echo ""
echo "================================================"
echo "          APB VERIFICATION REGRESSION"
echo "================================================"
echo "Test package : $TEST_PKG"
echo "Snapshot     : $SNAPSHOT"
echo "Total tests  : ${#TESTS[@]}"
echo "================================================"

# Run all tests
for TEST in "${TESTS[@]}"; do

    ((TOTAL++))

    LOG_FILE="regression_${TEST}.log"

    echo ""
    echo "------------------------------------------------"
    echo "Running test: $TEST"
    echo "------------------------------------------------"

    # Run simulation and save the output
    if xsim "$SNAPSHOT" -runall \
        -testplusarg "TEST=$TEST" 2>&1 | tee "$LOG_FILE"; then
        SIM_STATUS=0
    else
        SIM_STATUS=1
    fi

    # Check simulation status and scoreboard result
    if [[ $SIM_STATUS -eq 0 ]] &&
       grep -q "DATA CHECK: PASS" "$LOG_FILE" &&
       ! grep -q "DATA CHECK: FAIL" "$LOG_FILE"; then

        echo ""
        echo "RESULT: PASS - $TEST"

        ((PASSED++))
        PASSED_TESTS+=("$TEST")

    else

        echo ""
        echo "RESULT: FAIL - $TEST"

        ((FAILED++))
        FAILED_TESTS+=("$TEST")

    fi

done

# Print regression summary
echo ""
echo "================================================"
echo "              REGRESSION SUMMARY"
echo "================================================"
echo "Total tests  : $TOTAL"
echo "Passed       : $PASSED"
echo "Failed       : $FAILED"
echo "================================================"

# Print passed tests
echo ""
echo "PASSED TESTS:"
echo "------------------------------------------------"

if [[ $PASSED -gt 0 ]]; then
    for TEST in "${PASSED_TESTS[@]}"; do
        echo "  + $TEST"
    done
else
    echo "  None"
fi

# Print failed tests
echo ""
echo "FAILED TESTS:"
echo "------------------------------------------------"

if [[ $FAILED -gt 0 ]]; then
    for TEST in "${FAILED_TESTS[@]}"; do
        echo "  - $TEST"
    done
else
    echo "  None"
fi

echo "================================================"
echo "Individual logs: regression_<test_name>.log"
echo "================================================"

# Return a failure status if any test failed
if [[ $FAILED -gt 0 ]]; then
    exit 1
else
    echo ""
    echo "ALL TESTS PASSED!"
    exit 0
fi
