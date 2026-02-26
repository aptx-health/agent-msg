# agent-msg

Lightweight cross-repo message bus for AI coding agents. SQLite-backed, zero infrastructure.

## Setup

```bash
# Init the database (one time)
sqlite3 ~/repos/agent-msg/messages.db < ~/repos/agent-msg/setup.sql

# Symlink to PATH
ln -sf ~/repos/agent-msg/agent-pub ~/.local/bin/agent-pub
ln -sf ~/repos/agent-msg/agent-check ~/.local/bin/agent-check
ln -sf ~/repos/agent-msg/agent-ack ~/.local/bin/agent-ack
```

Set `AGENT_NAME` in each repo/session to identify the sender:

```bash
export AGENT_NAME="ripit-app"
```

## Usage

### Publish

```bash
agent-pub <project/channel> <message>
```

```bash
agent-pub ripit/infra "Prisma schema changed - Exercise has new category field"
agent-pub ripit/app "Cloud Run worker redeployed"
agent-pub homelab/plex "New media synced"
```

### Check messages

```bash
agent-check [topic-prefix]
```

```bash
agent-check                  # all unread
agent-check ripit             # all unread under ripit/*
agent-check ripit/infra       # exact topic only
```

### Acknowledge

```bash
agent-ack <id|all> [topic-prefix]
```

```bash
agent-ack 5                  # mark message 5 as read
agent-ack all ripit/infra     # mark all ripit/infra as read
agent-ack all ripit           # mark all ripit/* as read
agent-ack all                 # mark everything as read
```

## Topic hierarchy

Topics use `project/channel` format. Prefix queries match all sub-topics:

```
ripit/app         - app repo messages
ripit/infra       - infra repo messages
ripit              - matches both of the above
homelab/plex      - plex server messages
homelab/network   - network messages
homelab            - matches both of the above
```

## Claude Code integration

Add to each repo's `CLAUDE.md`:

```markdown
## Agent Messaging
This agent is `<agent-name>`. Check for messages periodically with `agent-check <topic>`.
Publish updates for other agents with `agent-pub <project/channel> <message>`.
```

## How it works

- SQLite database at `~/repos/agent-msg/messages.db`
- WAL mode enabled for safe concurrent reads/writes
- Messages persist until acknowledged
- No daemons, no containers, no infrastructure
