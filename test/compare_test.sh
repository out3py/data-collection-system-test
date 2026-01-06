#!/bin/bash
set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEST_TMP="${SCRIPT_DIR}/tmp"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

setup() {
    echo "Setting up test environment..."
    mkdir -p "${TEST_TMP}/reports"
    mkdir -p "${TEST_TMP}/daily_pages/content-123"
}

cleanup() {
    echo "Cleaning up..."
    rm -rf "${TEST_TMP}"
}

create_stats_md() {
    local created="$1"
    local updated="$2"
    cat > "${TEST_TMP}/stats.md" << EOF
---
layout: page
title: "Stats Test"
---

# Content Management Statistics

## Summary

- **Files Created**: ${created}
- **Files Updated**: ${updated}  
- **Files Deleted**: 0

---
EOF
}

create_event_json() {
    local new_links="$1"
    local updated_links="$2"
    cat > "${TEST_TMP}/event.json" << EOF
{
  "event_type": "test",
  "client_payload": {
    "url": "https://test.example.com",
    "revision_id": "test-revision-$(date +%s)",
    "found_links": 100,
    "new_links": ${new_links},
    "updated_links": ${updated_links}
  }
}
EOF
}

run_test() {
    local test_name="$1"
    local stats_created="$2"
    local stats_updated="$3"
    local payload_new="$4"
    local payload_updated="$5"
    local expected_created_match="$6"
    local expected_updated_match="$7"
    
    echo ""
    echo -e "${YELLOW}TEST: ${test_name}${NC}"
    echo "  Stats:   FILES_CREATED=${stats_created}, FILES_UPDATED=${stats_updated}"
    echo "  Payload: new_links=${payload_new}, updated_links=${payload_updated}"
    echo "  Expected: CREATED=${expected_created_match}, UPDATED=${expected_updated_match}"
    
    create_stats_md "${stats_created}" "${stats_updated}"
    create_event_json "${payload_new}" "${payload_updated}"
    
    rm -f "${TEST_TMP}/reports/"*.md
    
    pushd "${TEST_TMP}" > /dev/null
    export GITHUB_EVENT_PATH="${TEST_TMP}/event.json"
    
    set +e
    bash "${PROJECT_ROOT}/scripts/compare.sh" > /dev/null 2>&1
    local exit_code=$?
    set -e
    
    popd > /dev/null
    
    local report_file=$(ls -t "${TEST_TMP}/reports/"*.md 2>/dev/null | head -1)
    if [[ -z "${report_file}" ]]; then
        echo -e "  ${RED}❌ FAIL: No report generated${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return
    fi
    
    local created_result=$(grep "Created vs NewLinks" "${report_file}" | grep -oE '(OK|MISMATCH)' | tail -1)
    local updated_result=$(grep "Updated vs UpdatedLinks" "${report_file}" | grep -oE '(OK|MISMATCH)' | tail -1)
    
    echo "  Results: CREATED=${created_result}, UPDATED=${updated_result}"
    
    if [[ "${created_result}" == "${expected_created_match}" ]] && [[ "${updated_result}" == "${expected_updated_match}" ]]; then
        echo -e "  ${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}❌ FAIL${NC}"
        echo "  Report content:"
        grep -E "(Created vs|Updated vs)" "${report_file}" | sed 's/^/    /'
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

run_all_tests() {
    echo "=========================================="
    echo "Running compare.sh parsing tests"
    echo "=========================================="
    
    run_test "Both values match" \
        10 5 \
        10 5 \
        "OK" "OK"
    
    run_test "Created mismatch" \
        10 5 \
        8 5 \
        "MISMATCH" "OK"
    
    # Test 3: Updated mismatch
    run_test "Updated mismatch" \
        10 5 \
        10 3 \
        "OK" "MISMATCH"
    
    run_test "Both mismatch" \
        10 5 \
        8 3 \
        "MISMATCH" "MISMATCH"
    
    run_test "Zero in stats, non-zero in payload" \
        10 0 \
        10 5 \
        "OK" "MISMATCH"
    
    run_test "Both zeros - should be OK" \
        10 0 \
        10 0 \
        "OK" "OK"
    
    run_test "Large numbers match" \
        500 250 \
        500 250 \
        "OK" "OK"
    
    run_test "Zero created match" \
        0 5 \
        0 5 \
        "OK" "OK"
    
    run_test "All zeros" \
        0 0 \
        0 0 \
        "OK" "OK"
}

print_summary() {
    echo ""
    echo "=========================================="
    echo "TEST SUMMARY"
    echo "=========================================="
    echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "Failed: ${RED}${TESTS_FAILED}${NC}"
    echo "=========================================="
    
    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    fi
}

trap cleanup EXIT
setup
run_all_tests
print_summary

