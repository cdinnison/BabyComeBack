#!/bin/bash
# Hook script for Claude Code Stop events (agent finished responding)
# Clears the waiting indicator for this session

set -e

# Read JSON from stdin
INPUT=$(cat)

# Extract session_id
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id',''))" 2>/dev/null || echo "")

# Post notification to clear this session
NOTIFY_CMD="$HOME/.local/bin/claude-status-notify"

if [ -x "$NOTIFY_CMD" ]; then
    "$NOTIFY_CMD" resumed "$SESSION_ID"
fi

exit 0
