# ClaudeStatusBar

A macOS menu bar indicator that shows a blinking terminal cursor when any Claude Code instance is waiting for user input.

## Install

```bash
git clone <repo> && cd ClaudeStatusBar
./install.sh
./configure-hooks.sh
```

Restart any running Claude sessions for hooks to take effect.

## How it works

- **Idle**: `▪` (gray square)
- **Needs attention**: `█` (blinking orange cursor)

The app tracks multiple Claude sessions. The cursor blinks if **any** session needs attention and stops when **all** are cleared.

### Hook events

| Event | Action |
|-------|--------|
| `Notification` (permission_prompt, idle_prompt) | Start blinking |
| `PreToolUse` | Clear (permission was granted) |
| `UserPromptSubmit` | Clear (user is engaged) |
| `Stop` | Clear (Claude finished) |

## Manual test

```bash
# Trigger the indicator
~/.local/bin/claude-status-notify needs-attention test123 "Test message"

# Clear it
~/.local/bin/claude-status-notify resumed test123
```

## Uninstall

```bash
./uninstall.sh
```
