#!/bin/bash
# Hook script for Claude Code Notification events (permission_prompt, idle_prompt)
# Reads JSON from stdin and posts a distributed notification

set -e

# Read JSON from stdin
INPUT=$(cat)

# Extract fields using Python (available on all Macs)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id',''))" 2>/dev/null || echo "")
MESSAGE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','Claude needs attention'))" 2>/dev/null || echo "Claude needs attention")
NOTIFICATION_TYPE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('notification_type',''))" 2>/dev/null || echo "")

# Post notification to the menu bar app
NOTIFY_CMD="$HOME/.local/bin/claude-status-notify"

if [ -x "$NOTIFY_CMD" ]; then
    "$NOTIFY_CMD" needs-attention "$SESSION_ID" "$MESSAGE"
fi

# Always exit 0 so we don't block Claude
exit 0
