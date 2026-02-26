# agent-msg

Lightweight message bus for coordinating AI coding agents across repositories. SQLite-backed, zero infrastructure, five shell scripts.

## Why

When you have AI agents (Claude Code, Cursor, Aider, etc.) working in related repositories, they need a way to communicate. Schema changes in one repo affect another. Deployments need coordination. But most multi-agent tools are overengineered for this.

agent-msg is the simplest thing that works: a shared SQLite database with five bash scripts.

## Use cases

### Cross-repo coordination

You have an app repo and an infrastructure repo. An agent working on the app changes the database schema. It publishes a message so the infra agent knows to update the worker:

```bash
# App agent
agent-pub myproject/infra "Added email_verified column to User table - update worker queries"

# Infra agent checks later
agent-check myproject/infra
```

Works for any set of related repos: frontend/backend, monorepo services, app/deploy configs, client/server, etc.

### Git worktree isolation

You have multiple agents working on the same repo in different git worktrees (e.g., one on a feature branch, another on a bugfix). They need to avoid stepping on each other:

```bash
# Agent on feature/auth branch
agent-pub myapp/worktree "Refactoring lib/db.ts - don't modify until I'm done"

# Agent on fix/login branch checks before touching shared files
agent-check myapp/worktree
```

Prevents merge conflicts and wasted work when agents modify overlapping files across worktrees.

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

### Claim an identity

```bash
agent-whoami                  # auto-detect repo from git
agent-whoami my-project       # explicit repo name
```

Each agent gets a unique identity: `repo-name/GentlemanName` (e.g. `ripit/Humphrey`, `myapp/Cornelius`). The repo name is auto-detected from git. Multiple agents in the same repo get different names — claimed names are registered and won't be reused. Names expire after 24 hours.

Run this once at startup. Use the name when publishing messages:

```bash
AGENT_NAME=ripit/Humphrey agent-pub ripit/backend "Schema changed"
```

Or export it for the session if your environment supports persistent env vars:

```bash
export AGENT_NAME=$(agent-whoami)
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

### Browse active topics

```bash
agent-topics [hours] [project-prefix]
```

```bash
agent-topics                      # active in last 24h
agent-topics 72                   # active in last 72h
agent-topics 48 myproject         # myproject/* active in last 48h
```

Shows each topic with message count, unread count, active senders, and last activity time. Useful for onboarding into a project or getting situational awareness at startup.

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

### Claude Code skill (recommended)

Copy the skill to your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/agent-msg
cp skill/SKILL.md ~/.claude/skills/agent-msg/SKILL.md
```

This lets Claude Code automatically understand and use the messaging commands. Say things like "check my messages" or "notify the backend agent that the API changed".

### Manual setup (CLAUDE.md)

Alternatively, add something like this to each repo's `CLAUDE.md` (or `.cursorrules`, etc.):

````markdown
## Agent Messaging

You are connected to a shared message bus for coordinating with other AI agents.

**First thing you must do when starting a session:**
1. Run `agent-whoami` to claim your identity. Remember the name it gives you.
2. Run `agent-topics` to see recently active projects and channels.
3. Run `agent-check` to read any unread messages.

**Publishing messages:**
When you make changes that affect other repos (schema changes, API changes, dependency updates, breaking changes), notify other agents:
```
AGENT_NAME=<your-identity> agent-pub <project/channel> "<message>"
```

**Checking messages:**
- `agent-check` - all unread messages
- `agent-check myproject` - unread under myproject/*
- `agent-check myproject/backend` - exact topic

**Acknowledging messages:**
- `agent-ack <id>` or `agent-ack all [topic-prefix]`
````

## Configuration

| Variable | Default | Description |
|---|---|---|
| `AGENT_NAME` | `unknown` | Identifies the sender in messages |
| `AGENT_MSG_DB` | `<install-dir>/messages.db` | Override the database location |

## How it works

- Messages are stored in a SQLite database with a `messages` table
- Agent names are tracked in an `agent_names` table to prevent collisions within a repo
- Claimed names expire after 24 hours and are automatically recycled
- WAL mode is enabled for safe concurrent reads and writes from multiple agents
- Messages persist until explicitly acknowledged
- No daemons, no containers, no background processes
- Scripts resolve the database path relative to their own location (works via symlinks)

## Uninstall

```bash
rm ~/.local/bin/agent-pub ~/.local/bin/agent-check ~/.local/bin/agent-ack ~/.local/bin/agent-topics ~/.local/bin/agent-whoami
rm -rf /path/to/agent-msg
```
