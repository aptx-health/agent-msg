#!/bin/bash
# Install agent-msg Claude Code hooks into target project repos.
# Creates or merges .claude/settings.local.json in each target.
#
# Usage: ./setup-hooks.sh ~/repos/project1 ~/repos/project2 ...

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/hooks"

if [ $# -eq 0 ]; then
  echo "Usage: $0 <project-dir> [project-dir ...]"
  echo ""
  echo "Installs agent-msg Claude Code hooks into each project's"
  echo ".claude/settings.local.json so agents automatically claim"
  echo "identity, check inbox, and learn the messaging skill."
  exit 1
fi

# Verify hook scripts exist
for script in session-start.sh pre-compact.sh; do
  if [ ! -f "$HOOKS_DIR/$script" ]; then
    echo "Error: $HOOKS_DIR/$script not found. Run install.sh first." >&2
    exit 1
  fi
done

# Build the hooks JSON
HOOKS_JSON=$(cat <<EOF
{
  "hooks": {
    "SessionStart": [{"matcher": "*", "hooks": [
      {"type": "command", "command": "$HOOKS_DIR/session-start.sh", "timeout": 15}
    ]}],
    "PreCompact": [{"matcher": "*", "hooks": [
      {"type": "command", "command": "$HOOKS_DIR/pre-compact.sh", "timeout": 15}
    ]}]
  }
}
EOF
)

for PROJECT_DIR in "$@"; do
  # Resolve to absolute path
  PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
    echo "Warning: $PROJECT_DIR does not exist, skipping." >&2
    continue
  }

  CLAUDE_DIR="$PROJECT_DIR/.claude"
  SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"

  mkdir -p "$CLAUDE_DIR"

  if [ -f "$SETTINGS_FILE" ]; then
    # Merge with existing settings
    EXISTING=$(cat "$SETTINGS_FILE")
    if command -v jq &>/dev/null; then
      echo "$EXISTING" | jq --argjson hooks "$(echo "$HOOKS_JSON" | jq '.hooks')" '.hooks = $hooks' > "$SETTINGS_FILE"
    else
      python3 -c "
import json, sys
existing = json.loads(sys.argv[1])
new_hooks = json.loads(sys.argv[2])
existing['hooks'] = new_hooks['hooks']
print(json.dumps(existing, indent=2))
" "$EXISTING" "$HOOKS_JSON" > "$SETTINGS_FILE"
    fi
    echo "Updated $SETTINGS_FILE (merged hooks into existing settings)"
  else
    # Write new settings file
    if command -v jq &>/dev/null; then
      echo "$HOOKS_JSON" | jq '.' > "$SETTINGS_FILE"
    else
      echo "$HOOKS_JSON" > "$SETTINGS_FILE"
    fi
    echo "Created $SETTINGS_FILE"
  fi
done

echo ""
echo "Done! Hooks installed. agent-msg commands (agent-whoami, agent-check, etc.)"
echo "must be on your PATH. If not already, run: ./install.sh"
