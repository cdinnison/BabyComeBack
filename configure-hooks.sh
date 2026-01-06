#!/bin/bash
# Automatically configure Claude Code hooks for ClaudeStatusBar

set -e

SETTINGS_FILE="$HOME/.claude/settings.json"
HOOKS_DIR="$HOME/.claude/hooks"

echo "Configuring Claude Code hooks..."

# Create .claude directory if needed
mkdir -p "$HOME/.claude"

# Create or update settings.json using Python for proper JSON handling
python3 << 'PYTHON'
import json
import os
from pathlib import Path

settings_path = Path.home() / ".claude" / "settings.json"
hooks_dir = Path.home() / ".claude" / "hooks"

# Load existing settings or start fresh
if settings_path.exists():
    with open(settings_path) as f:
        settings = json.load(f)
else:
    settings = {}

# Ensure hooks section exists
if "hooks" not in settings:
    settings["hooks"] = {}

# Add Notification hook for needs-attention
notification_hook = {
    "matcher": "permission_prompt|idle_prompt",
    "hooks": [
        {
            "type": "command",
            "command": str(hooks_dir / "claude-needs-attention.sh")
        }
    ]
}

# Check if our hook already exists
existing_notifications = settings["hooks"].get("Notification", [])
has_our_hook = any(
    "claude-needs-attention.sh" in str(h.get("hooks", [{}])[0].get("command", ""))
    for h in existing_notifications
)

if not has_our_hook:
    existing_notifications.append(notification_hook)
    settings["hooks"]["Notification"] = existing_notifications
    print("Added Notification hook")
else:
    print("Notification hook already configured")

# Add Stop hook for resumed
stop_hook = {
    "hooks": [
        {
            "type": "command",
            "command": str(hooks_dir / "claude-resumed.sh")
        }
    ]
}

existing_stops = settings["hooks"].get("Stop", [])
has_stop_hook = any(
    "claude-resumed.sh" in str(h.get("hooks", [{}])[0].get("command", ""))
    for h in existing_stops
)

if not has_stop_hook:
    existing_stops.append(stop_hook)
    settings["hooks"]["Stop"] = existing_stops
    print("Added Stop hook")
else:
    print("Stop hook already configured")

# Add PreToolUse hook (clears when permission granted)
resumed_hook = {
    "hooks": [
        {
            "type": "command",
            "command": str(hooks_dir / "claude-resumed.sh")
        }
    ]
}

for event_name in ["PreToolUse", "UserPromptSubmit"]:
    existing = settings["hooks"].get(event_name, [])
    has_hook = any(
        "claude-resumed.sh" in str(h.get("hooks", [{}])[0].get("command", ""))
        for h in existing
    )
    if not has_hook:
        existing.append(resumed_hook.copy())
        settings["hooks"][event_name] = existing
        print(f"Added {event_name} hook")
    else:
        print(f"{event_name} hook already configured")

# Write settings
with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print(f"\nSettings saved to {settings_path}")
PYTHON

echo ""
echo "Done! Claude Code will now notify the status bar when waiting."
echo "Restart any running Claude sessions for hooks to take effect."
