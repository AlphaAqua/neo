#!/bin/bash
# System test for neo - verifies digital rain is drawn to terminal

set -e

# Output directory for test results
RESULTS_DIR="${RESULTS_DIR:-test-results}"
mkdir -p "$RESULTS_DIR"
JUNIT_FILE="$RESULTS_DIR/junit.xml"

# Start JUnit XML
START_TIME=$(date +%s)

echo "=== Neo System Test ==="
echo "Testing that neo draws digital rain to the terminal..."

# Initialize test results
TOTAL_TESTS=0
FAILED_TESTS=0
TEST_CASES=""

# Helper function to record test result
record_test() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    local time="$4"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [ "$status" = "fail" ]; then
        FAILED_TESTS=$((FAILED_TESTS + 1))
        TEST_CASES="$TEST_CASES
    <testcase name=\"$test_name\" classname=\"neo.SystemTest\" time=\"$time\">
      <failure message=\"$message\"/>
    </testcase>"
    else
        TEST_CASES="$TEST_CASES
    <testcase name=\"$test_name\" classname=\"neo.SystemTest\" time=\"$time\"/>"
    fi
}

# Check if tmux is available
if ! command -v tmux &> /dev/null; then
    echo "ERROR: tmux is required for system tests"
    record_test "Prerequisites.tmux_available" "fail" "tmux is not installed" "0"
    # Write JUnit XML and exit
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    cat > "$JUNIT_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
  <testsuite name="neo.SystemTest" tests="$TOTAL_TESTS" failures="$FAILED_TESTS" time="$DURATION">
$TEST_CASES
  </testsuite>
</testsuites>
EOF
    exit 1
fi

# Check if neo binary exists
if [ ! -f "./src/neo" ]; then
    echo "ERROR: neo binary not found at ./src/neo"
    echo "Please build neo first with: ./autogen.sh && ./configure && make"
    record_test "Prerequisites.neo_binary_exists" "fail" "neo binary not found at ./src/neo" "0"
    # Write JUnit XML and exit
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    cat > "$JUNIT_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
  <testsuite name="neo.SystemTest" tests="$TOTAL_TESTS" failures="$FAILED_TESTS" time="$DURATION">
$TEST_CASES
  </testsuite>
</testsuites>
EOF
    exit 1
fi

record_test "Prerequisites.tmux_available" "pass" "" "0"
record_test "Prerequisites.neo_binary_exists" "pass" "" "0"

# Create a unique session name
SESSION_NAME="neo-test-$$"

# Create a tmux session and run neo
echo "Starting neo in tmux session..."
tmux new-session -d -s "$SESSION_NAME" -x 80 -y 24

# Run neo with ASCII charset for reliable testing
# Use a timeout to automatically exit after 2 seconds
tmux send-keys -t "$SESSION_NAME" "timeout 2s ./src/neo --charset=ascii || true" C-m

# Give it time to start and draw
sleep 2.5

# Capture the terminal output
echo "Capturing terminal output..."
CAPTURE_FILE=$(mktemp)
tmux capture-pane -t "$SESSION_NAME" -p > "$CAPTURE_FILE"

# Kill the tmux session
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

# Analyze the output
echo "Analyzing output..."

TEST_START=$(date +%s)

# Check if we have non-empty output
if [ ! -s "$CAPTURE_FILE" ]; then
    echo "FAIL: No output captured from neo"
    TEST_END=$(date +%s)
    record_test "DigitalRain.output_captured" "fail" "No output captured from neo" "$((TEST_END - TEST_START))"
    rm -f "$CAPTURE_FILE"
else
    TEST_END=$(date +%s)
    record_test "DigitalRain.output_captured" "pass" "" "$((TEST_END - TEST_START))"
fi

# Count non-whitespace characters (digital rain should fill the screen)
TEST_START=$(date +%s)
CHAR_COUNT=$(grep -o '[[:alnum:][:punct:]]' "$CAPTURE_FILE" | wc -l)

echo "Found $CHAR_COUNT characters in output"

# Digital rain should have drawn many characters on screen
if [ "$CHAR_COUNT" -lt 50 ]; then
    echo "FAIL: Too few characters drawn ($CHAR_COUNT). Expected digital rain effect."
    echo "Output preview:"
    head -20 "$CAPTURE_FILE"
    TEST_END=$(date +%s)
    record_test "DigitalRain.sufficient_characters" "fail" "Too few characters drawn ($CHAR_COUNT), expected at least 50" "$((TEST_END - TEST_START))"
    rm -f "$CAPTURE_FILE"
else
    TEST_END=$(date +%s)
    record_test "DigitalRain.sufficient_characters" "pass" "" "$((TEST_END - TEST_START))"
fi

# Check that we have multiple lines with content (vertical streams)
TEST_START=$(date +%s)
LINES_WITH_CONTENT=$(grep -c '[[:alnum:][:punct:]]' "$CAPTURE_FILE" || true)

echo "Found $LINES_WITH_CONTENT lines with content"

if [ "$LINES_WITH_CONTENT" -lt 3 ]; then
    echo "FAIL: Too few lines with content ($LINES_WITH_CONTENT). Expected vertical streams."
    TEST_END=$(date +%s)
    record_test "DigitalRain.vertical_streams" "fail" "Too few lines with content ($LINES_WITH_CONTENT), expected at least 3" "$((TEST_END - TEST_START))"
    rm -f "$CAPTURE_FILE"
else
    TEST_END=$(date +%s)
    record_test "DigitalRain.vertical_streams" "pass" "" "$((TEST_END - TEST_START))"
fi

# Check for variety of characters (not just the same character repeated)
TEST_START=$(date +%s)
UNIQUE_CHARS=$(grep -o '[[:alnum:][:punct:]]' "$CAPTURE_FILE" | sort -u | wc -l)

echo "Found $UNIQUE_CHARS unique character types"

if [ "$UNIQUE_CHARS" -lt 5 ]; then
    echo "FAIL: Too few unique characters ($UNIQUE_CHARS). Expected variety in digital rain."
    TEST_END=$(date +%s)
    record_test "DigitalRain.character_variety" "fail" "Too few unique characters ($UNIQUE_CHARS), expected at least 5" "$((TEST_END - TEST_START))"
    rm -f "$CAPTURE_FILE"
else
    TEST_END=$(date +%s)
    record_test "DigitalRain.character_variety" "pass" "" "$((TEST_END - TEST_START))"
fi

# Generate JUnit XML report
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$JUNIT_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
  <testsuite name="neo.SystemTest" tests="$TOTAL_TESTS" failures="$FAILED_TESTS" time="$DURATION">
$TEST_CASES
  </testsuite>
</testsuites>
EOF

echo ""
echo "Test results written to: $JUNIT_FILE"

# Success summary
if [ "$FAILED_TESTS" -eq 0 ]; then
    echo ""
    echo "✓ PASS: All tests passed ($TOTAL_TESTS/$TOTAL_TESTS)"
    echo "  - $CHAR_COUNT characters drawn"
    echo "  - $LINES_WITH_CONTENT lines with content"
    echo "  - $UNIQUE_CHARS unique character types"

    # Cleanup
    rm -f "$CAPTURE_FILE"
    exit 0
else
    echo ""
    echo "✗ FAIL: $FAILED_TESTS/$TOTAL_TESTS tests failed"

    # Cleanup
    rm -f "$CAPTURE_FILE"
    exit 1
fi
