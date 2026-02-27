#!/bin/bash
# Install agent-msg: symlink scripts to PATH and init the database

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${1:-$HOME/.local/bin}"

mkdir -p "$BIN_DIR"

ln -sf "$SCRIPT_DIR/agent-pub" "$BIN_DIR/agent-pub"
ln -sf "$SCRIPT_DIR/agent-check" "$BIN_DIR/agent-check"
ln -sf "$SCRIPT_DIR/agent-ack" "$BIN_DIR/agent-ack"
ln -sf "$SCRIPT_DIR/agent-topics" "$BIN_DIR/agent-topics"
ln -sf "$SCRIPT_DIR/agent-whoami" "$BIN_DIR/agent-whoami"

chmod +x "$SCRIPT_DIR/hooks/session-start.sh" "$SCRIPT_DIR/hooks/pre-compact.sh" "$SCRIPT_DIR/setup-hooks.sh"

sqlite3 "$SCRIPT_DIR/messages.db" < "$SCRIPT_DIR/setup.sql"

echo "Installed agent-msg:"
echo "  Scripts symlinked to $BIN_DIR"
echo "  Database at $SCRIPT_DIR/messages.db"
echo ""
echo "Make sure $BIN_DIR is on your PATH."
echo ""
echo "To auto-integrate with Claude Code via hooks:"
echo "  ./setup-hooks.sh ~/repos/project1 ~/repos/project2 ..."
