#!/usr/bin/env bash
#
# check-architecture-isolation.sh
# Enforces: ARCHITECTURE.md changes ONLY in isolation (no other files in same commit)
#
# Uses common hook library for reusable functions

set -euo pipefail

# Load common hook utilities
HOOK_DIR="$(dirname "$0")"
source "$HOOK_DIR/../.claude-plugin/hooks/lib/common.sh"

# Get staged files
STAGED=$(get_staged_files)

# Find ARCHITECTURE.md if staged
ARCH_FILE=$(echo "$STAGED" | grep "ARCHITECTURE.md" || echo "")

# Check if ARCHITECTURE.md is staged along with other files
if [[ -n "$ARCH_FILE" ]]; then
    OTHER_FILES=$(echo "$STAGED" | grep -v "ARCHITECTURE.md" || echo "")

    if [[ -n "$OTHER_FILES" ]]; then
        # Show violation using library function
        show_violation \
            "ARCHITECTURE ISOLATION VIOLATION" \
            "Architecture changes must be committed in isolation.\n\nStaged files:\n$(echo "$STAGED" | sed 's/^/  /')" \
            "Option 1:\n  1. Unstage other files: git reset HEAD <file>...\n  2. Commit ARCHITECTURE.md: git commit -m 'feat(arch): <description>'\n  3. Then commit other files separately\n\nOption 2:\n  1. Unstage ARCHITECTURE.md: git reset HEAD docs/ARCHITECTURE.md\n  2. Commit other files: git commit -m '<message>'\n  3. Then commit ARCHITECTURE.md separately with ADR format"

        exit 1
    fi
fi

# Check passed
exit 0
