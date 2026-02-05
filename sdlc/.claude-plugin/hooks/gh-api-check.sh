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
    "additionalContext": "⚠️ gh api LAST RESORT CHECK\n\n📚 Why avoid? gh api is low-level and error-prone. Extensions provide:\n- Better error messages\n- Validation and safety checks\n- Simpler command syntax\n\n🔧 Before proceeding, check:\n1. Installed extensions: gh extension list\n   - gh-issue-ext, gh-project-ext, gh-pr-review\n2. Native gh commands: gh issue, gh pr, gh project\n3. Available extensions: gh extension search\n\n✅ Proceed only if no extension exists for this operation.\n\n📖 See: github-issues skill for patterns"
  }
}
EOF
exit 0
