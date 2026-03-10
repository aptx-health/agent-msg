CREATE TABLE IF NOT EXISTS messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  topic TEXT NOT NULL,
  sender TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_topic ON messages(topic);
CREATE INDEX IF NOT EXISTS idx_created_at ON messages(created_at);

CREATE TABLE IF NOT EXISTS acks (
  message_id INTEGER NOT NULL,
  agent_name TEXT NOT NULL,
  acked_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (message_id, agent_name)
);

CREATE INDEX IF NOT EXISTS idx_acks_agent ON acks(agent_name);

CREATE TABLE IF NOT EXISTS agent_names (
  repo TEXT NOT NULL,
  name TEXT NOT NULL,
  claimed_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (repo, name)
);

CREATE INDEX IF NOT EXISTS idx_agent_names_repo ON agent_names(repo, claimed_at);

-- Enable WAL mode for concurrent access
PRAGMA journal_mode=WAL;
