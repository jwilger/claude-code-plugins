#!/usr/bin/env bash
# Heartbeat update hook - maintains worktree liveness tracking
# Runs on Stop event to update last_heartbeat timestamp

set -euo pipefail

# Check if we're in a git repository
if ! git rev-parse --git-dir &>/dev/null; then
  # Not in a git repo, nothing to update
  echo '{"ok": true}'
  exit 0
fi

# Get current branch to determine task ID
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ -z "$BRANCH" ]; then
  # Not on a branch (detached HEAD), nothing to update
  echo '{"ok": true}'
  exit 0
fi

# Extract task ID from branch name (e.g., feature/myproject-add-login-abc123 → myproject-add-login-abc123)
TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')

# Check if this looks like a valid task ID (contains at least two hyphens)
if [[ ! "$TASK_ID" =~ .*-.* ]]; then
  # Not a task branch, nothing to update
  echo '{"ok": true}'
  exit 0
fi

# Find git root
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
WORKTREE_REGISTRY="$GIT_ROOT/.dots/.worktrees"
TASK_REGISTRY="$WORKTREE_REGISTRY/$TASK_ID"

# Check if worktree coordination is enabled
if [ ! -f "$GIT_ROOT/.claude/sdlc.yaml" ]; then
  echo '{"ok": true}'
  exit 0
fi

if ! grep -q "worktree_coordination: true" "$GIT_ROOT/.claude/sdlc.yaml" 2>/dev/null; then
  # Coordination not enabled, nothing to update
  echo '{"ok": true}'
  exit 0
fi

# Update heartbeat if registration exists
if [ -d "$TASK_REGISTRY" ]; then
  LOCK_FILE="$WORKTREE_REGISTRY/lock"

  # Acquire lock (with timeout)
  attempt=0
  while ! mkdir "$LOCK_FILE" 2>/dev/null; do
    attempt=$((attempt + 1))
    if [ $attempt -gt 10 ]; then
      # Couldn't acquire lock, but this is non-critical
      echo '{"ok": true}'
      exit 0
    fi
    sleep 1
  done

  # Update heartbeat
  date +%s > "$TASK_REGISTRY/last_heartbeat"

  # Release lock
  rmdir "$LOCK_FILE" 2>/dev/null || true
fi

# Always allow stopping
echo '{"ok": true}'
