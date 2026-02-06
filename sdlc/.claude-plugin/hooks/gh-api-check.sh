#!/usr/bin/env bash
#
# gh-api-check.sh - PreToolUse hook for gh api commands
#
# Reminds to check for extension alternatives before using gh api directly.

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract the command from tool_input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Check if this is a gh api command
if [[ "$COMMAND" != *"gh api"* ]]; then
    # Not a gh api command, allow
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Not a gh api command"
  }
}
EOF
    exit 0
fi

# Acceptable gh api uses (no extension alternative exists)
ACCEPTABLE_PATTERNS=(
    "repos/.*/settings"
    "repos/.*/rulesets"
    "repos/.*/hooks"
    "repos/.*/actions/secrets"
    "orgs/.*/settings"
)

for pattern in "${ACCEPTABLE_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$pattern"; then
        cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Acceptable gh api use - no extension alternative exists"
  }
}
EOF
        exit 0
    fi
done

# For other gh api calls, add context reminding to check extensions
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "REMINDER: gh api should be a last resort. Before proceeding, ensure you have checked: (1) Installed extensions via 'gh extension list' (gh-issue-ext, gh-project-ext, gh-pr-review), (2) Native gh subcommands (gh issue, gh pr, gh project), (3) Available extensions via 'gh extension search'. If an extension can perform this operation, prefer using it over gh api."
  }
}
EOF
exit 0
