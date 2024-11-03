#!/usr/bin/env bash

set -euo pipefail

# Source test utilities
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/test-utils.sh"

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BIN_DIR="${PROJECT_ROOT}/bin"

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
    cp "${SCRIPT_DIR}/fixtures/"*.JPG "$TEST_DIR/"
}

test_basic_functionality() {
    log_test "Basic functionality with defaults"
    
    local PREFIX="test_roll"
    "${BIN_DIR}/film-scan-fix" "$TEST_DIR" --name "$PREFIX" > /dev/null 2>&1
    
    assert "File renamed correctly (001)" \
        "[[ -f '$TEST_DIR/${PREFIX}_001.JPG' ]]"
        
    assert "Default copyright set" \
        "exiftool -copyright '$TEST_DIR/${PREFIX}_001.JPG' | grep -q '© Angus Mackenzie'"
}

test_custom_settings() {
    log_test "Custom ISO and copyright"
    
    local PREFIX="custom"
    "${BIN_DIR}/film-scan-fix" "$TEST_DIR" \
        --name "$PREFIX" \
        --iso "800" \
        --copyright "© Test User" > /dev/null 2>&1
        
    assert "Custom copyright applied" \
        "exiftool -copyright '$TEST_DIR/${PREFIX}_001.JPG' | grep -q '© Test User'"
        
    assert "Custom ISO set" \
        "exiftool -iso '$TEST_DIR/${PREFIX}_001.JPG' | grep -q '800'"
}

# Run tests
setup
test_basic_functionality
test_custom_settings
print_summary "$(basename "$0")"
exit "$FAILED_TESTS"