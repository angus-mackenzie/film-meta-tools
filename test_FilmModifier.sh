#!/bin/bash

# Setup function
setup() {
    TEST_DIR=$(mktemp -d)
    ORIGINAL_DIR=$(mktemp -d)
    cp img/* "$ORIGINAL_DIR/"
    cp img/* "$TEST_DIR/"
    echo "Test directory created at: $TEST_DIR"
}

# Cleanup function
cleanup() {
    rm -rf "$TEST_DIR"
    rm -rf "$ORIGINAL_DIR"
    echo "Cleaned up test directories"
}

# Reset function
reset_test_files() {
    rm -f "$TEST_DIR"/*
    cp "$ORIGINAL_DIR"/* "$TEST_DIR/"
    echo "Reset test files to original state"
}

# Run tests
run_tests() {
    echo "Running tests..."
    
    # Test 1: Basic functionality with defaults
    echo -e "\nTest 1: Basic functionality with defaults"
    reset_test_files
    PREFIX="test_roll"
    ./FilmModifier.sh "$TEST_DIR" --name "$PREFIX"
    
    # Known suspicious files (1988 files)
    SUS_FILES=("41" "46" "47")
    
    # Check all files are renamed sequentially
    for i in {1..6}; do
        new_name="$TEST_DIR/${PREFIX}_$(printf "%03d" $i).JPG"
        
        if [[ -f "$new_name" ]]; then
            echo "✓ File exists with correct name: $(basename "$new_name")"
            
            # Check default copyright
            COPYRIGHT=$(exiftool -copyright "$new_name" | awk -F': ' '{print $2}')
            if [[ "$COPYRIGHT" == "© Angus Mackenzie" ]]; then
                echo "✓ Default copyright correctly set"
            else
                echo "✗ Default copyright not set correctly"
            fi
        fi
    done

    # Test 2: Custom ISO and copyright
    echo -e "\nTest 2: Custom ISO and copyright"
    reset_test_files
    ./FilmModifier.sh "$TEST_DIR" --name "test_iso" --iso 400 --copyright "John Doe"
    
    for i in {1..6}; do
        new_name="$TEST_DIR/test_iso_$(printf "%03d" $i).JPG"
        
        if [[ -f "$new_name" ]]; then
            # Check ISO
            ISO=$(exiftool -iso "$new_name" | awk -F': ' '{print $2}')
            if [[ "$ISO" == "400" ]]; then
                echo "✓ Custom ISO correctly set for $(basename "$new_name")"
            else
                echo "✗ Custom ISO not set correctly for $(basename "$new_name")"
            fi
            
            # Check custom copyright
            COPYRIGHT=$(exiftool -copyright "$new_name" | awk -F': ' '{print $2}')
            if [[ "$COPYRIGHT" == "© John Doe" ]]; then
                echo "✓ Custom copyright correctly set"
            else
                echo "✗ Custom copyright not set correctly"
            fi
        fi
    done

    # Test 3: ISO preservation
    echo -e "\nTest 3: ISO preservation"
    reset_test_files
    # First set an ISO value
    exiftool -iso=200 "$TEST_DIR"/*
    # Then run the script with a different ISO
    ./FilmModifier.sh "$TEST_DIR" --name "test_iso_preserve" --iso 400
    
    for i in {1..6}; do
        new_name="$TEST_DIR/test_iso_preserve_$(printf "%03d" $i).JPG"
        
        if [[ -f "$new_name" ]]; then
            ISO=$(exiftool -iso "$new_name" | awk -F': ' '{print $2}')
            if [[ "$ISO" == "200" ]]; then
                echo "✓ Original ISO correctly preserved for $(basename "$new_name")"
            else
                echo "✗ Original ISO not preserved for $(basename "$new_name")"
            fi
        fi
    done
}

# Run the tests
setup
run_tests
cleanup