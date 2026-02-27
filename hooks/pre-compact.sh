#!/bin/bash
# Claude Code PreCompact hook for agent-msg
# Re-injects the messaging skill, identity, and inbox after context compaction.
# Returns JSON with systemMessage that gets preserved in compacted context.

set -euo pipefail

# Resolve agent-msg repo location via symlink
SOURCE="$0"
while [ -L "$SOURCE" ]; do SOURCE="$(readlink "$SOURCE")"; done
SCRIPT_DIR="$(cd "$(dirname "$SOURCE")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Read the skill definition
SKILL_CONTENT=$(cat "$REPO_DIR/skill/SKILL.md" 2>/dev/null || echo "Warning: SKILL.md not found")

# Re-claim identity (refresh)
IDENTITY=$(agent-whoami 2>/dev/null || echo "unknown (agent-whoami failed)")

# Check for unread messages
INBOX=$(agent-check 2>/dev/null || echo "Could not check messages")

# Build the system message with compaction reminder
MSG="# Agent Messaging (re-injected after context compaction)

> **Note:** Your context was just compacted. This skill and identity info has been re-injected so you don't lose it.

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
if command -v jq &>/dev/null; then
  echo "$MSG" | jq -Rs '{"systemMessage": .}'
else
  python3 -c "import json,sys; print(json.dumps({'systemMessage': sys.stdin.read()}))" <<< "$MSG"
fi
