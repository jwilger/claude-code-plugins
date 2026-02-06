#!/usr/bin/env bash
#
# pre-compact.sh - PreCompact hook for TDD state preservation
#
# Injects TDD cycle state into compaction context so the orchestrator
# retains awareness of the current workflow position after compaction.

set -euo pipefail

INPUT=$(cat)
TRIGGER=$(echo "$INPUT" | jq -r '.trigger // "unknown"')

# Build TDD state context
TDD_STATE=""

# Check dot CLI for current task state
if command -v dot &>/dev/null; then
  ACTIVE_TASKS=$(dot ls --status active 2>/dev/null | head -20 || true)
  if [ -n "$ACTIVE_TASKS" ]; then
    TDD_STATE="ACTIVE TASKS (from dot CLI):\n${ACTIVE_TASKS}\n\n"
  else
    TDD_STATE="No active tasks found in dot CLI.\n\n"
  fi
else
  TDD_STATE="dot CLI not available - check .dots/ directory manually if needed.\n\n"
fi

# Check for .claude/sdlc.yaml TDD state
if [ -f ".claude/sdlc.yaml" ]; then
  PHASE=$(grep "current_phase:" .claude/sdlc.yaml 2>/dev/null | head -1 | sed 's/.*: *//' || true)
  LAST_AGENT=$(grep "last_agent:" .claude/sdlc.yaml 2>/dev/null | head -1 | sed 's/.*: *//' || true)
  if [ -n "$PHASE" ] && [ "$PHASE" != "null" ]; then
    TDD_STATE="${TDD_STATE}TDD STATE FROM CONFIG:\n  Phase: ${PHASE}\n  Last agent: ${LAST_AGENT}\n\n"
  fi
fi

# Escape for JSON
TDD_STATE_ESCAPED=$(printf '%s' "$TDD_STATE" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' ')

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreCompact",
    "additionalContext": "TDD CYCLE STATE (PRESERVE THROUGH COMPACTION):\n\n${TDD_STATE_ESCAPED}\nREMINDER: The TDD cycle is strictly: RED -> DOMAIN (review test) -> GREEN -> DOMAIN (review implementation). After compaction, check dot CLI ('dot ls --status active') for current task state. NEVER skip domain review after red or green phases. If unsure of current phase, check recent file modifications and agent outputs to determine where you are in the cycle.\n\nBefore compaction, save any unsaved discoveries to memory using /sdlc:remember."
  }
}
EOF
exit 0
