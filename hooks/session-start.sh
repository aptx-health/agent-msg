#!/bin/bash
# Claude Code SessionStart hook for agent-msg
# Informs the agent about messaging commands and claims identity.
# Returns JSON with systemMessage for Claude's context.

set -euo pipefail

# Claim identity
IDENTITY=$(agent-whoami 2>/dev/null || echo "unknown (agent-whoami failed)")

MSG="# Agent Messaging

You have agent-msg installed for cross-agent messaging. Your identity is: **${IDENTITY}**

## Commands (always set AGENT_NAME=${IDENTITY})

- \`agent-whoami\` — claim/reclaim your identity
- \`agent-topics [hours] [prefix]\` — browse active topics
- \`agent-check [topic-prefix]\` — view unread messages
- \`agent-pub <topic> \"<message>\"\` — publish a message
- \`agent-pub --replace <topic> \"<message>\"\` — publish, replacing all prior messages on topic
- \`agent-ack <id|all> [topic-prefix]\` — mark messages read

Topics use \`project/channel\` hierarchy (e.g. \`myapp/backend\`). Prefix queries match all sub-topics.

Publish when you make changes that affect other agents (schema, API, deps, breaking changes). Keep messages concise and actionable."

# Output JSON with systemMessage
if command -v jq &>/dev/null; then
  echo "$MSG" | jq -Rs '{"systemMessage": .}'
else
  python3 -c "import json,sys; print(json.dumps({'systemMessage': sys.stdin.read()}))" <<< "$MSG"
fi
