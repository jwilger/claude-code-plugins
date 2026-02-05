#!/usr/bin/env bash
# orchestrator-edit-detection.sh - PostToolUse hook for Edit/Write
# Detects orchestrator direct edits (EDUCATIONAL enforcement)

set -euo pipefail

INPUT=$(cat)

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
    # Can't determine - allow
    echo '{"ok": true}'
    exit 0
fi

# Heuristic: Check last 50 lines for Task tool usage
# If present, likely orchestrator context
RECENT_CONTEXT=$(tail -n 50 "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

if echo "$RECENT_CONTEXT" | grep -q '"name":\s*"Task"'; then
    # Orchestrator context - warn (EDUCATIONAL)
    cat <<'EOF'
{
  "ok": true,
  "additionalContext": "⚠️ ORCHESTRATION REMINDER: You directly edited a file. While not blocked, delegation to specialized agents is recommended for better separation of concerns. See docs/orchestration-patterns.md"
}
EOF
else
    # Subagent context - allow silently
    echo '{"ok": true}'
fi
