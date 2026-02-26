CREATE TABLE IF NOT EXISTS messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  topic TEXT NOT NULL,
  sender TEXT NOT NULL,
  message TEXT NOT NULL,
  read INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_topic_read ON messages(topic, read);
CREATE INDEX IF NOT EXISTS idx_created_at ON messages(created_at);

-- Enable WAL mode for concurrent access
PRAGMA journal_mode=WAL;
