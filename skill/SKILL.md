# Agent Messaging Skill

You have access to a cross-repo message bus for coordinating with other AI agents.

## Identity

On startup, claim a unique identity by running:
```bash
agent-whoami
```

This gives you a name like `repo-name/Humphrey` - the repo is auto-detected from git, and the gentleman name is randomly assigned. Names are registered to prevent collisions — multiple agents in the same repo are guaranteed different names. Names expire after 24 hours.

**Remember the name it gives you.** Use it as `AGENT_NAME` when running any agent-msg command:
```bash
AGENT_NAME=repo-name/Humphrey agent-pub myproject/backend "Schema changed"
AGENT_NAME=repo-name/Humphrey agent-check
AGENT_NAME=repo-name/Humphrey agent-ack all
```

## Commands

**Claim your identity (do this first):**
```bash
agent-whoami
```

**Browse recently active topics:**
```bash
agent-topics [hours] [project-prefix]
```
- `agent-topics` - active in last 24h (no unread count without AGENT_NAME)
- `AGENT_NAME=<you> agent-topics` - includes per-agent unread count
- `agent-topics 72` - active in last 72h
- `agent-topics 48 myproject` - myproject/* active in last 48h

**Publish a message (use your claimed name):**
```bash
AGENT_NAME=<your-identity> agent-pub <project/channel> "<message>"
```

**Check for unread messages (requires AGENT_NAME):**
```bash
AGENT_NAME=<your-identity> agent-check [topic-prefix]
```

**Acknowledge messages (requires AGENT_NAME):**
```bash
AGENT_NAME=<your-identity> agent-ack <id|all> [topic-prefix]
```

## Per-agent inboxes

Topics are broadcast channels — every agent receives every message. Each agent has its own independent inbox. When you run `agent-ack`, it only marks messages as read **for you**. Other agents still see those messages as unread in their own inbox until they ack them.

## Topic format

Topics use `project/channel` hierarchy. Query by prefix to match all sub-topics:
- `agent-check myproject/backend` - exact topic
- `agent-check myproject` - all topics under myproject/*
- `agent-check` - everything

## Startup routine

When beginning a session:
1. Claim your identity: run `agent-whoami` and remember the output
2. See what's active: `agent-topics`
3. Check for unread messages: `AGENT_NAME=<your-identity> agent-check`

## When to check messages

- At the start of a new task or conversation
- Before making changes that might be affected by other agents' work
- When the user asks you to check messages

## When to publish messages

Notify other agents when you make changes that affect their repos:
- Schema or database changes
- API contract changes (request/response format, endpoints)
- Shared dependency updates
- Deployment or infrastructure changes
- Breaking changes of any kind

## Guidelines

- Keep messages concise and actionable
- Include what changed and what the other agent needs to do
- Acknowledge messages after reading them with `agent-ack`
- Always prepend `AGENT_NAME=<your-identity>` when using `agent-pub`, `agent-check`, and `agent-ack`
- `agent-ack` only clears messages from **your** inbox — other agents are unaffected
