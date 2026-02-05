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

# Structured detection: Parse JSONL transcript for Task tool usage
# More reliable than text grep - looks for actual tool invocations
TASK_TOOL_FOUND=false

# Check last 50 lines (performance optimization)
tail -n 50 "$TRANSCRIPT_PATH" 2>/dev/null | while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        # Parse each JSONL line as JSON
        TOOL_NAME=$(echo "$line" | jq -r '.content[]?.name // empty' 2>/dev/null)

        # Check if this line contains Task tool invocation
        if [[ "$TOOL_NAME" == "Task" ]]; then
            TASK_TOOL_FOUND=true
            break
        fi

        # Also check for orchestration-protocol skill loading
        SKILL_NAME=$(echo "$line" | jq -r '.content[]?.skill // empty' 2>/dev/null)
        if [[ "$SKILL_NAME" == "orchestration-protocol" ]]; then
            TASK_TOOL_FOUND=true
            break
        fi
    fi
done

if [[ "$TASK_TOOL_FOUND" == "true" ]]; then
    # Orchestrator context detected - warn (EDUCATIONAL)
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
