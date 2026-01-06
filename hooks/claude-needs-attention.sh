#!/bin/bash
# Hook script for Claude Code Notification events (permission_prompt, idle_prompt)
# Optimized for instant notification - no Python overhead

# Fire notification immediately in background (don't block hook)
# Use grep/cut for fast session_id extraction
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' 2>/dev/null | head -1 | cut -d'"' -f4)

"$HOME/.local/bin/claude-status-notify" needs-attention "$SESSION_ID" "Claude needs attention" &
exit 0
