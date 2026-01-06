#!/bin/bash
# Hook script for Claude Code Stop events (agent finished responding)
# Optimized for instant notification - no Python overhead

# Fire notification immediately in background
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' 2>/dev/null | head -1 | cut -d'"' -f4)

"$HOME/.local/bin/claude-status-notify" resumed "$SESSION_ID" &
exit 0
