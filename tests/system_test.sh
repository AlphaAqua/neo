#!/bin/bash
# System test for neo - verifies digital rain is drawn to terminal

set -e

echo "=== Neo System Test ==="
echo "Testing that neo draws digital rain to the terminal..."

# Check if tmux is available
if ! command -v tmux &> /dev/null; then
    echo "ERROR: tmux is required for system tests"
    exit 1
fi

# Check if neo binary exists
if [ ! -f "./src/neo" ]; then
    echo "ERROR: neo binary not found at ./src/neo"
    echo "Please build neo first with: ./autogen.sh && ./configure && make"
    exit 1
fi

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

# Check if we have non-empty output
if [ ! -s "$CAPTURE_FILE" ]; then
    echo "FAIL: No output captured from neo"
    rm -f "$CAPTURE_FILE"
    exit 1
fi

# Count non-whitespace characters (digital rain should fill the screen)
CHAR_COUNT=$(grep -o '[[:alnum:][:punct:]]' "$CAPTURE_FILE" | wc -l)

echo "Found $CHAR_COUNT characters in output"

# Digital rain should have drawn many characters on screen
if [ "$CHAR_COUNT" -lt 50 ]; then
    echo "FAIL: Too few characters drawn ($CHAR_COUNT). Expected digital rain effect."
    echo "Output preview:"
    head -20 "$CAPTURE_FILE"
    rm -f "$CAPTURE_FILE"
    exit 1
fi

# Check that we have multiple lines with content (vertical streams)
LINES_WITH_CONTENT=$(grep -c '[[:alnum:][:punct:]]' "$CAPTURE_FILE" || true)

echo "Found $LINES_WITH_CONTENT lines with content"

if [ "$LINES_WITH_CONTENT" -lt 5 ]; then
    echo "FAIL: Too few lines with content ($LINES_WITH_CONTENT). Expected vertical streams."
    rm -f "$CAPTURE_FILE"
    exit 1
fi

# Check for variety of characters (not just the same character repeated)
UNIQUE_CHARS=$(grep -o '[[:alnum:][:punct:]]' "$CAPTURE_FILE" | sort -u | wc -l)

echo "Found $UNIQUE_CHARS unique character types"

if [ "$UNIQUE_CHARS" -lt 5 ]; then
    echo "FAIL: Too few unique characters ($UNIQUE_CHARS). Expected variety in digital rain."
    rm -f "$CAPTURE_FILE"
    exit 1
fi

# Success!
echo ""
echo "✓ PASS: Neo successfully drew digital rain to the terminal"
echo "  - $CHAR_COUNT characters drawn"
echo "  - $LINES_WITH_CONTENT lines with content"
echo "  - $UNIQUE_CHARS unique character types"

# Cleanup
rm -f "$CAPTURE_FILE"

exit 0
