#!/bin/bash
# Claude Code SessionStart hook for agent-msg
# Injects the messaging skill, claims identity, and checks inbox.
# Returns JSON with systemMessage for Claude's context.

set -euo pipefail

# Resolve agent-msg repo location via symlink
SOURCE="$0"
while [ -L "$SOURCE" ]; do SOURCE="$(readlink "$SOURCE")"; done
SCRIPT_DIR="$(cd "$(dirname "$SOURCE")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Read the skill definition
SKILL_CONTENT=$(cat "$REPO_DIR/skill/SKILL.md" 2>/dev/null || echo "Warning: SKILL.md not found")

# Claim identity
IDENTITY=$(agent-whoami 2>/dev/null || echo "unknown (agent-whoami failed)")

# Check for unread messages
INBOX=$(agent-check 2>/dev/null || echo "Could not check messages")

# Build the system message
MSG="# Agent Messaging (auto-injected by SessionStart hook)

${SKILL_CONTENT}

---

## Your Identity

You claimed: **${IDENTITY}**

Remember this name. Use it as AGENT_NAME when publishing messages:
\`\`\`bash
AGENT_NAME=${IDENTITY} agent-pub <project/channel> \"<message>\"
\`\`\`

## Inbox

${INBOX}

---
Use agent-ack to acknowledge messages after reading them."

# Output JSON with systemMessage
# Use jq if available, fall back to python3
if command -v jq &>/dev/null; then
  echo "$MSG" | jq -Rs '{"systemMessage": .}'
else
  python3 -c "import json,sys; print(json.dumps({'systemMessage': sys.stdin.read()}))" <<< "$MSG"
fi
