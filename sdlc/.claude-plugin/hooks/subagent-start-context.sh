#!/usr/bin/env bash
#
# subagent-start-context.sh - SubagentStart hook for TDD agent context injection
#
# Fires when red, green, or domain agents spawn. Injects dynamic context:
# - Current dot CLI task info
# - ARCHITECTURE.md existence
# - TDD cycle position reminder

set -euo pipefail

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')

CONTEXT="TDD AGENT CONTEXT (injected via SubagentStart hook)\n"
CONTEXT="${CONTEXT}Agent: ${AGENT_TYPE}\n\n"

# Inject current task info from dot CLI
if command -v dot &>/dev/null; then
  ACTIVE_TASKS=$(dot ls --status active 2>/dev/null | head -10 || true)
  if [ -n "$ACTIVE_TASKS" ]; then
    CONTEXT="${CONTEXT}CURRENT ACTIVE TASKS:\n${ACTIVE_TASKS}\n\n"
  else
    CONTEXT="${CONTEXT}No active tasks in dot CLI.\n\n"
  fi
else
  CONTEXT="${CONTEXT}dot CLI not available.\n\n"
fi

# Check for ARCHITECTURE.md
if [ -f "docs/ARCHITECTURE.md" ]; then
  CONTEXT="${CONTEXT}ARCHITECTURE.md: EXISTS at docs/ARCHITECTURE.md - Read it before proceeding with any work.\n\n"
elif [ -f "ARCHITECTURE.md" ]; then
  CONTEXT="${CONTEXT}ARCHITECTURE.md: EXISTS at ARCHITECTURE.md - Read it before proceeding with any work.\n\n"
else
  CONTEXT="${CONTEXT}ARCHITECTURE.md: NOT FOUND - Use general DDD best practices.\n\n"
fi

# Add TDD cycle position context based on agent type
case "$AGENT_TYPE" in
  red)
    CONTEXT="${CONTEXT}TDD POSITION: You are in the RED phase. Write ONE failing test. After you complete, domain review is MANDATORY before green.\n"
    ;;
  green)
    CONTEXT="${CONTEXT}TDD POSITION: You are in the GREEN phase. Implement MINIMAL code to pass the failing test. After you complete, domain review is MANDATORY.\n"
    ;;
  domain)
    CONTEXT="${CONTEXT}TDD POSITION: You are in the DOMAIN phase. Review for domain integrity and create/refine type definitions as needed.\n"
    ;;
  *)
    CONTEXT="${CONTEXT}TDD CYCLE: RED -> DOMAIN -> GREEN -> DOMAIN. Ensure proper phase sequencing.\n"
    ;;
esac

# Escape for JSON
CONTEXT_ESCAPED=$(printf '%s' "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' ' ')

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "${CONTEXT_ESCAPED}"
  }
}
EOF
exit 0
