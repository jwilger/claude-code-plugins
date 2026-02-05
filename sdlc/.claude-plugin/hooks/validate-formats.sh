#!/usr/bin/env bash
# validate-formats.sh - Validate hook return formats
#
# Ensures all hooks follow correct format standards:
# - Prompt hooks: {"ok": true} or {"ok": false, "reason": "..."}
# - Command hooks: {"hookSpecificOutput": {"hookEventName": "...", ...}}

set -euo pipefail

ERRORS=0

echo "🔍 Validating hook formats..."
echo

# Check agent hooks (YAML frontmatter)
echo "Checking agent hooks..."
find ../agents -name "*.md" -type f | while read -r file; do
    # Extract hooks section from YAML frontmatter
    if grep -q "^hooks:" "$file"; then
        echo "  Checking: $(basename "$file")"

        # Check for prompt-based hooks
        # Look for "type: prompt" followed by "prompt: |"
        if grep -A 10 "type: prompt" "$file" | grep -q "prompt:"; then
            # Check if prompt hooks have {"ok": true} output
            if ! grep -A 20 "type: prompt" "$file" | grep -q '{"ok": true}'; then
                echo "    ❌ Prompt hook missing {\"ok\": true} output"
                ERRORS=$((ERRORS + 1))
            fi
        fi

        # Check for command-based hooks
        if grep -A 10 "type: command" "$file" | grep -q "command:"; then
            # Check if command hooks reference hookSpecificOutput
            if ! grep -A 30 "type: command" "$file" | grep -q 'hookSpecificOutput'; then
                echo "    ⚠️  Command hook may be missing hookSpecificOutput (check manually)"
            fi
        fi
    fi
done

echo
echo "Checking shell script hooks..."

# Check command hooks (.sh files)
find . -name "*.sh" -type f ! -name "validate-formats.sh" | while read -r file; do
    echo "  Checking: $(basename "$file")"

    # Check for JSON output
    if grep -q '"ok"' "$file"; then
        # This looks like a prompt-style hook
        if ! grep -q '{"ok": true}' "$file"; then
            echo "    ⚠️  Hook has partial JSON - verify format manually"
        fi
    fi

    # Check for hookSpecificOutput (command hooks)
    if grep -q 'hookSpecificOutput' "$file"; then
        if ! grep -q 'hookEventName' "$file"; then
            echo "    ❌ Command hook has hookSpecificOutput but missing hookEventName"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

echo
if [[ $ERRORS -eq 0 ]]; then
    echo "✅ All hook formats validated successfully"
    exit 0
else
    echo "❌ Found $ERRORS hook format errors"
    exit 1
fi
