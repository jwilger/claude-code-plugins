#!/usr/bin/env bash
#
# check-adr-format.sh
# Enforces: Architecture commits must use (arch) scope and contain ADR structure
#
# Usage: check-adr-format.sh <commit-msg-file>
#
# Exit codes:
#   0 - Check passed
#   1 - Violation detected (blocks commit)

set -e

commit_msg_file="$1"

if [[ ! -f "$commit_msg_file" ]]; then
  echo "❌ ERROR: Commit message file not found: $commit_msg_file"
  exit 1
fi

# Read commit message
commit_msg=$(cat "$commit_msg_file")

# Get files in this commit (from staging area)
staged_files=$(git diff --cached --name-only)

# Check if ARCHITECTURE.md is in the commit
arch_in_commit=false
while IFS= read -r file; do
  if [[ "$file" == "docs/ARCHITECTURE.md" ]] || [[ "$file" == *"/ARCHITECTURE.md" ]]; then
    arch_in_commit=true
    break
  fi
done <<< "$staged_files"

# If ARCHITECTURE.md is not in commit, skip validation
if [[ "$arch_in_commit" == "false" ]]; then
  exit 0
fi

# ARCHITECTURE.md is in commit - validate format

# Check 1: Subject line must use (arch) scope
subject_line=$(echo "$commit_msg" | head -n 1)
if ! echo "$subject_line" | grep -qE '^(feat|fix|refactor|docs|chore|style|test|perf|ci|build|revert)\(arch\):'; then
  echo "❌ ARCHITECTURE COMMIT FORMAT VIOLATION"
  echo ""
  echo "Architecture commits must use conventional commits with (arch) scope."
  echo ""
  echo "Your subject line:"
  echo "  $subject_line"
  echo ""
  echo "Expected format:"
  echo "  feat(arch): <description>"
  echo "  fix(arch): <description>"
  echo "  refactor(arch): <description>"
  echo "  docs(arch): <description>"
  echo ""
  echo "Examples:"
  echo "  feat(arch): adopt event sourcing for core domain"
  echo "  fix(arch): correct authentication flow diagram"
  echo "  refactor(arch): restructure deployment section"
  echo ""
  exit 1
fi

# Check 2: Body must contain ADR structure
if ! echo "$commit_msg" | grep -q "## Context and Problem Statement"; then
  echo "❌ ARCHITECTURE COMMIT ADR FORMAT VIOLATION"
  echo ""
  echo "Architecture commits must include ADR-formatted body."
  echo ""
  echo "Your commit message is missing: '## Context and Problem Statement'"
  echo ""
  echo "Required sections:"
  echo "  ---"
  echo "  status: accepted"
  echo "  date: YYYY-MM-DD"
  echo "  decision-makers: <names>"
  echo "  ---"
  echo ""
  echo "  # <Decision Title>"
  echo ""
  echo "  ## Context and Problem Statement"
  echo "  <Why are we making this decision?>"
  echo ""
  echo "  ## Decision Drivers"
  echo "  * <Factor 1>"
  echo "  * <Factor 2>"
  echo ""
  echo "  ## Considered Options"
  echo "  * <Option 1>"
  echo "  * <Option 2>"
  echo ""
  echo "  ## Decision Outcome"
  echo "  Chosen option: \"<option>\", because <rationale>."
  echo ""
  echo "  ### Consequences"
  echo "  * Good, because <benefit>"
  echo "  * Bad, because <tradeoff>"
  echo ""
  echo "📋 See MADR template:"
  echo "  https://adr.github.io/madr/"
  echo ""
  echo "OR use /arch skill to guide you through the process:"
  echo "  /arch \"<your architecture change>\""
  echo ""
  exit 1
fi

# Check passed
exit 0
