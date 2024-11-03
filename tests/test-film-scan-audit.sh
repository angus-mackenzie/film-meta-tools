#!/usr/bin/env bash

set -euo pipefail

# Source test utilities
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/test-utils.sh"

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BIN_DIR="${PROJECT_ROOT}/bin"
FIXTURES_DIR="${SCRIPT_DIR}/fixtures"

# Set up trap before function definition
trap cleanup EXIT

# shellcheck disable=SC2317
cleanup() {
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

setup() {
    TEST_DIR=$(mktemp -d)
    log_header "Setting up test environment"
    
    # Create test structure
    mkdir -p "$TEST_DIR/roll1"
    mkdir -p "$TEST_DIR/roll2/nested"
    
    # Copy test fixtures
    cp "$FIXTURES_DIR/normal-scan.JPG" "$TEST_DIR/roll1/normal1.JPG"
    cp "$FIXTURES_DIR/normal-scan.JPG" "$TEST_DIR/roll1/normal2.JPG"
    cp "$FIXTURES_DIR/frontier-1988.JPG" "$TEST_DIR/roll1/sus1.JPG"
    cp "$FIXTURES_DIR/frontier-1988.JPG" "$TEST_DIR/roll2/nested/sus2.JPG"
    
    # Add non-image files
    touch "$TEST_DIR/roll1/ignore.txt"
    touch "$TEST_DIR/roll2/ignore.doc"
}

test_basic_scan() {
    log_test "Basic scan detection"
    
    local output
    output=$("${BIN_DIR}/film-scan-audit" "$TEST_DIR")
    
    assert "Detects suspicious files" \
        "echo \"$output\" | grep -q \"Found suspicious file: sus1.JPG\""
    
    assert "Shows directory summary" \
        "echo \"$output\" | grep -q \"Directory summary: 1/3 files suspicious\""
    
    assert "Shows correct total counts" \
        "echo \"$output\" | grep -q \"Total image files found: 4\""
}

test_verbose_mode() {
    log_test "Verbose mode output"
    
    local output
    output=$("${BIN_DIR}/film-scan-audit" --verbose "$TEST_DIR")
    
    assert "Shows normal files" \
        "echo \"$output\" | grep -q \"Normal file: normal1.JPG\""
    
    assert "Shows ISO values" \
        "echo \"$output\" | grep -q \"ISO: 400\""
}

test_nested_directories() {
    log_test "Nested directory handling"
    
    local output
    output=$("${BIN_DIR}/film-scan-audit" "$TEST_DIR")
    
    assert "Processes nested files" \
        "echo \"$output\" | grep -q \"Found suspicious file: sus2.JPG\""
}

test_non_image_files() {
    log_test "Non-image file handling"
    
    local output
    output=$("${BIN_DIR}/film-scan-audit" "$TEST_DIR")
    
    assert "Ignores text files" \
        "! echo \"$output\" | grep -q \"ignore.txt\""
    
    assert "Ignores doc files" \
        "! echo \"$output\" | grep -q \"ignore.doc\""
}

# Run tests
setup
test_basic_scan
test_verbose_mode
test_nested_directories
test_non_image_files
print_summary "$(basename "$0")"
exit "$FAILED_TESTS"