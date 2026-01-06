#!/bin/bash
# Uninstall BabyComeBack

set -e

echo "Uninstalling BabyComeBack..."

INSTALL_DIR="$HOME/.local/bin"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_AGENTS_DIR/com.babycomebackapp.plist"

# Stop and unload LaunchAgent
if [ -f "$PLIST_PATH" ]; then
    echo "Stopping BabyComeBack..."
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    rm "$PLIST_PATH"
fi

# Remove binaries
echo "Removing binaries..."
rm -f "$INSTALL_DIR/BabyComeBack"
rm -f "$INSTALL_DIR/claude-status-notify"

# Note: We don't remove hooks or settings - user may want to keep them
echo ""
echo "Uninstalled. Hook scripts in ~/.claude/hooks/ were preserved."
echo "Remove them manually if desired, and edit ~/.claude/settings.json"
