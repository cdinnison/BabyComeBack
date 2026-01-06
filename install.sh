#!/bin/bash
# BabyComeBack installer
# One-command install for the Claude Code status indicator

set -e

echo "Installing BabyComeBack..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
HOOKS_DIR="$HOME/.claude/hooks"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$HOOKS_DIR"
mkdir -p "$LAUNCH_AGENTS_DIR"

# Build the Swift binaries
echo "Building binaries..."
cd "$SCRIPT_DIR"
swift build -c release

# Install binaries
echo "Installing binaries to $INSTALL_DIR..."
cp ".build/release/BabyComeBack" "$INSTALL_DIR/"
cp ".build/release/claude-status-notify" "$INSTALL_DIR/"

# Install hook scripts
echo "Installing hook scripts to $HOOKS_DIR..."
cp "$SCRIPT_DIR/hooks/claude-needs-attention.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/hooks/claude-resumed.sh" "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR/claude-needs-attention.sh"
chmod +x "$HOOKS_DIR/claude-resumed.sh"

# Create LaunchAgent for auto-start
PLIST_PATH="$LAUNCH_AGENTS_DIR/com.babycomebackapp.plist"
echo "Creating LaunchAgent at $PLIST_PATH..."
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.babycomebackapp</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/BabyComeBack</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# Load the LaunchAgent (start now)
echo "Starting BabyComeBack..."
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo ""
echo "Installation complete!"
echo ""
echo "Next step: Add hooks to your Claude settings."
echo ""
echo "Add this to ~/.claude/settings.json (or create the file):"
echo ""
cat << 'SETTINGS'
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt|idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/claude-needs-attention.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/claude-resumed.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS
echo ""
echo "Or run: ./configure-hooks.sh to auto-configure"
