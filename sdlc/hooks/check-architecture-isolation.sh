#!/usr/bin/env bash
#
# check-architecture-isolation.sh
# Enforces: ARCHITECTURE.md changes ONLY in isolation (no other files in same commit)
#
# Exit codes:
#   0 - Check passed
#   1 - Violation detected (blocks commit)

set -e

# Get staged files
staged_files=$(git diff --cached --name-only)

# Check if ARCHITECTURE.md is staged
arch_staged=false
other_staged=false

while IFS= read -r file; do
  if [[ "$file" == "docs/ARCHITECTURE.md" ]] || [[ "$file" == *"/ARCHITECTURE.md" ]]; then
    arch_staged=true
  else
    other_staged=true
  fi
done <<< "$staged_files"

# If both ARCHITECTURE.md and other files are staged, block
if [[ "$arch_staged" == "true" ]] && [[ "$other_staged" == "true" ]]; then
  echo "❌ ARCHITECTURE ISOLATION VIOLATION"
  echo ""
  echo "Architecture changes must be committed in isolation."
  echo ""
  echo "Staged files:"
  echo "$staged_files" | sed 's/^/  /'
  echo ""
  echo "📋 How to fix:"
  echo "  1. Unstage other files:     git reset HEAD <file>..."
  echo "  2. Commit ARCHITECTURE.md:  git commit -m 'feat(arch): <description>'"
  echo "  3. Then commit other files separately"
  echo ""
  echo "OR:"
  echo "  1. Unstage ARCHITECTURE.md: git reset HEAD docs/ARCHITECTURE.md"
  echo "  2. Commit other files:      git commit -m '<message>'"
  echo "  3. Then commit ARCHITECTURE.md separately with ADR format"
  echo ""
  exit 1
fi

# Check passed
exit 0
