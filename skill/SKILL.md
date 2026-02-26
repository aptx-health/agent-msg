# Agent Messaging Skill

You have access to a cross-repo message bus for coordinating with other AI agents.

## Identity

Your agent name is set via the `AGENT_NAME` environment variable. Use it when publishing messages.

## Commands

**Publish a message:**
```bash
agent-pub <project/channel> "<message>"
```

**Check for unread messages:**
```bash
agent-check [topic-prefix]
```

**Acknowledge messages:**
```bash
agent-ack <id|all> [topic-prefix]
```

## Topic format

Topics use `project/channel` hierarchy. Query by prefix to match all sub-topics:
- `agent-check myproject/backend` - exact topic
- `agent-check myproject` - all topics under myproject/*
- `agent-check` - everything

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
