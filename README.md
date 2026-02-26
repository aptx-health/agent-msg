# agent-msg

Lightweight message bus for coordinating AI coding agents across repositories. SQLite-backed, zero infrastructure, three shell scripts.

## Why

When you have AI agents (Claude Code, Cursor, Aider, etc.) working in related repositories, they need a way to communicate. Schema changes in one repo affect another. Deployments need coordination. But most multi-agent tools are overengineered for this.

agent-msg is the simplest thing that works: a shared SQLite database with three bash scripts.

## Requirements

- bash
- sqlite3 (pre-installed on macOS and most Linux distros)

**Windows**: Use WSL or Git Bash. Install sqlite3 if not present.

**Linux**: If sqlite3 is missing: `sudo apt install sqlite3`

## Install

```bash
git clone https://github.com/your-user/agent-msg.git
cd agent-msg
./install.sh
```

This symlinks the scripts to `~/.local/bin` and initializes the database. Make sure `~/.local/bin` is on your PATH.

To install to a different location:

```bash
./install.sh /usr/local/bin
```

## Usage

Set `AGENT_NAME` in each terminal/session to identify the sender:

```bash
export AGENT_NAME="my-app"
```

### Publish a message

```bash
agent-pub <project/channel> <message>
```

```bash
agent-pub myproject/backend "Database schema changed - User table has new email_verified column"
agent-pub myproject/frontend "API response format changed for /api/users endpoint"
agent-pub infra/deploy "Backend service redeployed to staging"
```

### Check for messages

```bash
agent-check [topic-prefix]
```

```bash
agent-check                      # all unread messages
agent-check myproject             # all unread under myproject/*
agent-check myproject/backend     # exact topic only
```

### Acknowledge messages

```bash
agent-ack <id|all> [topic-prefix]
```

```bash
agent-ack 5                      # mark message 5 as read
agent-ack all myproject/backend   # mark all myproject/backend as read
agent-ack all myproject           # mark all myproject/* as read
agent-ack all                     # mark everything as read
```

## Topic hierarchy

Topics follow a `project/channel` convention. When you query by prefix (no `/`), it matches all sub-topics:

```
myproject/backend     - backend repo messages
myproject/frontend    - frontend repo messages
myproject             - matches both of the above

infra/deploy          - deployment notifications
infra/monitoring      - monitoring alerts
infra                 - matches both of the above
```

You can use whatever hierarchy makes sense for your setup.

## AI agent integration

Add something like this to each repo's context file (e.g., `CLAUDE.md`, `.cursorrules`, etc.):

```markdown
## Agent Messaging
This agent is `my-backend`. Periodically check for messages with `agent-check myproject/backend`.
When making changes that affect other repos, notify them with `agent-pub myproject/<channel> <message>`.
```

Your AI agent will pick up the instructions and use the commands naturally.

## Configuration

| Variable | Default | Description |
|---|---|---|
| `AGENT_NAME` | `unknown` | Identifies the sender in messages |
| `AGENT_MSG_DB` | `<install-dir>/messages.db` | Override the database location |

## How it works

- Messages are stored in a SQLite database with a single `messages` table
- WAL mode is enabled for safe concurrent reads and writes from multiple agents
- Messages persist until explicitly acknowledged
- No daemons, no containers, no background processes
- Scripts resolve the database path relative to their own location (works via symlinks)

## Uninstall

```bash
rm ~/.local/bin/agent-pub ~/.local/bin/agent-check ~/.local/bin/agent-ack
rm -rf /path/to/agent-msg
```
