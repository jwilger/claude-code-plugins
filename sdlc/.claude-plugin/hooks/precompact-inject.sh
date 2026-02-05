#!/usr/bin/env bash
#
# precompact-inject.sh - PreCompact hook for context preservation
#
# Injects critical context before conversation compaction to preserve:
# - Current domain types and model
# - TDD cycle state and phase
# - Active constraints and requirements
#
# Keeps injection under 2000 chars for Claude Code performance.

set -euo pipefail

# Initialize context buffer
CONTEXT=""

# Helper to add section if content exists
add_section() {
  local title="$1"
  local content="$2"
  if [[ -n "$content" ]]; then
    CONTEXT+="## $title\n\n$content\n\n"
  fi
}

# 1. Capture current branch and task
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [[ -n "$BRANCH" ]]; then
  TASK_ID="${BRANCH#feature/}"
  add_section "Current Work" "Branch: $BRANCH\nTask: $TASK_ID"
fi

# 2. Capture TDD cycle state from task list
if command -v dot &>/dev/null && [[ -n "$BRANCH" ]]; then
  # Try JSON format first (more reliable)
  if dot task show "$TASK_ID" --format=json &>/dev/null; then
    TASK_JSON=$(dot task show "$TASK_ID" --format=json 2>/dev/null || echo "")
    if [[ -n "$TASK_JSON" ]]; then
      # Extract structured data with jq
      TITLE=$(echo "$TASK_JSON" | jq -r '.title // empty')
      STATUS=$(echo "$TASK_JSON" | jq -r '.status // empty')
      PHASE=$(echo "$TASK_JSON" | jq -r '.metadata.phase // empty')

      if [[ -n "$TITLE" ]]; then
        PHASE_INFO="Task: $TITLE\nStatus: $STATUS"
        if [[ -n "$PHASE" ]]; then
          PHASE_INFO+="\nPhase: $PHASE"
        fi
        add_section "TDD Cycle State" "$PHASE_INFO"
      fi
    fi
  else
    # Fallback to text parsing for older dot CLI versions
    TASK_STATE=$(dot task show "$TASK_ID" 2>/dev/null || echo "")
    if [[ -n "$TASK_STATE" ]]; then
      PHASE_INFO=$(echo "$TASK_STATE" | grep -E "^\s*(✅|🔄|⏳)" | head -5 || echo "")
      if [[ -n "$PHASE_INFO" ]]; then
        add_section "TDD Cycle State" "$PHASE_INFO"
      fi
    fi
  fi
fi

# 3. Capture recent domain types (from src/domain or similar)
DOMAIN_FILES=$(find . -path "*/src/domain/*" -o -path "*/lib/domain/*" -o -path "*/domain/*" 2>/dev/null | grep -E "\.(rs|ts|js|py|rb|go)$" | head -3 || echo "")
if [[ -n "$DOMAIN_FILES" ]]; then
  DOMAIN_SUMMARY=""
  while IFS= read -r file; do
    if [[ -f "$file" ]]; then
      # Extract type definitions (struct, class, interface, type alias)
      TYPES=$(grep -E "^(pub )?struct|^class|^interface|^type |^data " "$file" 2>/dev/null | head -2 || echo "")
      if [[ -n "$TYPES" ]]; then
        DOMAIN_SUMMARY+="$file:\n$TYPES\n\n"
      fi
    fi
  done <<< "$DOMAIN_FILES"

  if [[ -n "$DOMAIN_SUMMARY" ]]; then
    add_section "Domain Types" "$DOMAIN_SUMMARY"
  fi
fi

# 4. Capture active constraints from config
if [[ -f ".claude/sdlc.yaml" ]]; then
  # Extract key constraints (workflow mode, enforcement level)
  CONSTRAINTS=$(grep -E "^(workflow|enforcement|mode):" .claude/sdlc.yaml 2>/dev/null || echo "")
  if [[ -n "$CONSTRAINTS" ]]; then
    add_section "Active Constraints" "$CONSTRAINTS"
  fi
fi

# 5. Capture last commit message for context
LAST_COMMIT=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "")
if [[ -n "$LAST_COMMIT" ]]; then
  add_section "Recent Progress" "Last commit: $LAST_COMMIT"
fi

# Truncate to 2000 chars if needed (Claude Code recommendation)
if [[ ${#CONTEXT} -gt 2000 ]]; then
  CONTEXT="${CONTEXT:0:1997}..."
fi

# Output as prompt-based hook format (PreCompact uses prompt-based)
if [[ -n "$CONTEXT" ]]; then
  cat <<EOF
{
  "ok": true,
  "additionalContext": "🔄 CONTEXT PRESERVATION (Pre-Compaction)\n\n${CONTEXT}This context will help maintain continuity after compaction."
}
EOF
else
  # No context to inject, just allow compaction
  cat <<EOF
{
  "ok": true
}
EOF
fi

exit 0
