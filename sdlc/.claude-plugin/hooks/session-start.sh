#!/usr/bin/env bash
#
# session-start.sh - SessionStart hook for comprehensive context injection
#
# Injects work context to help "pick up where we left off":
# - Last 3 commits with messages
# - Active branch and associated task
# - Open tasks status
# - Recent PR activity
# - Memory protocol reminder

set -euo pipefail

# Load prerequisite checking utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/check-prerequisites.sh
source "$SCRIPT_DIR/lib/check-prerequisites.sh" || {
  echo "Warning: Could not load prerequisite checking utilities" >&2
}

# Write environment variables to CLAUDE_ENV_FILE (if provided)
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
  # Determine project root
  PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  echo "export PROJECT_ROOT='$PROJECT_ROOT'" >> "$CLAUDE_ENV_FILE"

  # Load sdlc config if exists
  if [[ -f "$PROJECT_ROOT/.claude/sdlc.yaml" ]] && command -v yq &>/dev/null; then
    WORKFLOW=$(yq eval '.workflow_mode' "$PROJECT_ROOT/.claude/sdlc.yaml" 2>/dev/null || echo "")
    if [[ -n "$WORKFLOW" ]]; then
      echo "export SDLC_WORKFLOW='$WORKFLOW'" >> "$CLAUDE_ENV_FILE"
    fi
  fi

  # Detect active task from branch
  BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  if [[ -n "$BRANCH" ]] && [[ "$BRANCH" == feature/* ]]; then
    TASK_ID="${BRANCH#feature/}"
    echo "export SDLC_ACTIVE_TASK='$TASK_ID'" >> "$CLAUDE_ENV_FILE"
  fi
fi

# Build context message
CONTEXT="🚀 SESSION START - Work Context\n\n"

# 1. Current branch and task
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [[ -n "$BRANCH" ]]; then
  CONTEXT+="📍 Branch: $BRANCH\n"

  # Try to get task info if using dot CLI
  if command -v dot &>/dev/null; then
    TASK_ID="${BRANCH#feature/}"
    TASK_INFO=$(dot task show "$TASK_ID" 2>/dev/null | grep -E "^(Title|Status):" | sed 's/^/  /' || echo "")
    if [[ -n "$TASK_INFO" ]]; then
      CONTEXT+="📋 Active Task:\n$TASK_INFO\n"
    fi
  else
    # dot CLI not available - add helpful note
    CONTEXT+="💡 Note: Install dot CLI for task management integration\n"
    CONTEXT+="   cargo install dot-task (https://github.com/jwilger/dot-task)\n"
  fi
fi

# 2. Last 3 commits for context
COMMITS=$(git log -3 --pretty=format:"  %ar: %s" 2>/dev/null || echo "")
if [[ -n "$COMMITS" ]]; then
  CONTEXT+="\n📝 Recent Commits:\n$COMMITS\n"
fi

# 3. PR status if on feature branch
if [[ -n "$BRANCH" ]] && [[ "$BRANCH" == feature/* ]]; then
  if command -v gh &>/dev/null; then
    PR_INFO=$(gh pr view --json number,title,reviewDecision 2>/dev/null | jq -r '"  PR #\(.number): \(.title)\n  Status: \(.reviewDecision // \"Pending\")"' || echo "")
    if [[ -n "$PR_INFO" ]]; then
      CONTEXT+="\n🔀 Pull Request:\n$PR_INFO\n"
    fi
  else
    # gh CLI not available - add helpful note
    CONTEXT+="\n💡 Note: Install gh CLI for GitHub integration\n"
    CONTEXT+="   https://cli.github.com/\n"
  fi
fi

# 4. Open tasks summary (if using dot CLI)
if command -v dot &>/dev/null; then
  OPEN_COUNT=$(dot task list --status pending,in-progress 2>/dev/null | wc -l || echo "0")
  if [[ "$OPEN_COUNT" -gt 0 ]]; then
    CONTEXT+="\n📊 Open Tasks: $OPEN_COUNT ready or in progress\n"
  fi
fi

# 5. Memory protocol reminder
CONTEXT+="\n🧠 MEMORY TIP: Use /sdlc:recall \"<topic>\" to search past solutions and conventions.\n"

# 6. Quick status command reminder
CONTEXT+="\n💡 TIP: Run /sdlc:status for detailed project state anytime.\n"

# Output as command-based SessionStart hook
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$CONTEXT"
  }
}
EOF

exit 0
