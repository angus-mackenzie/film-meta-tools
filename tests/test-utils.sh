#!/usr/bin/env bash

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
FAILED_TESTS=0

# Logging functions
log_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

log_test() {
    echo -e "\n${BLUE}Test: $1${NC}"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Assert function
assert() {
    local message="$1"
    local command="$2"
    ((TOTAL_TESTS++))
    
    if eval "$command" > /dev/null 2>&1; then
        log_success "$message"
        return 0
    else
        log_error "$message"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Print final summary
print_summary() {
    local test_file="$1"
    echo -e "\n${BLUE}Summary for ${test_file}:${NC}"
    echo "Tests run: $TOTAL_TESTS"
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
    else
        echo -e "${RED}Failed tests: $FAILED_TESTS${NC}"
    fi
} 