#!/usr/bin/env bash
#
# check-branch-consistency.sh
# Enforces: If branch has ANY ARCHITECTURE.md commits, ALL commits must ONLY touch ARCHITECTURE.md
#
# Exit codes:
#   0 - Check passed
#   1 - Violation detected (blocks push)

set -e

# Get the range of commits being pushed
# This is provided by git in pre-push hook via stdin
# Format: <local ref> <local sha> <remote ref> <remote sha>

# Read from stdin (git pre-push hook provides this)
while read local_ref local_sha remote_ref remote_sha; do
  # If we're deleting a branch, skip
  if [[ "$local_sha" == "0000000000000000000000000000000000000000" ]]; then
    continue
  fi

  # If remote doesn't exist yet, compare against main/master
  if [[ "$remote_sha" == "0000000000000000000000000000000000000000" ]]; then
    # Find main or master branch
    if git rev-parse --verify main >/dev/null 2>&1; then
      base_ref="main"
    elif git rev-parse --verify master >/dev/null 2>&1; then
      base_ref="master"
    else
      # No base branch found, skip check
      continue
    fi
    commit_range="$base_ref..$local_sha"
  else
    commit_range="$remote_sha..$local_sha"
  fi

  # Get all commits in range
  commits=$(git rev-list "$commit_range" 2>/dev/null || echo "")

  if [[ -z "$commits" ]]; then
    continue
  fi

  # Check if any commit touches ARCHITECTURE.md
  arch_commits=()
  mixed_commits=()

  while IFS= read -r commit; do
    files=$(git show --name-only --format="" "$commit")

    # Check if this commit touches ARCHITECTURE.md
    arch_in_commit=false
    other_in_commit=false

    while IFS= read -r file; do
      if [[ "$file" == "docs/ARCHITECTURE.md" ]] || [[ "$file" == *"/ARCHITECTURE.md" ]]; then
        arch_in_commit=true
      else
        other_in_commit=true
      fi
    done <<< "$files"

    if [[ "$arch_in_commit" == "true" ]]; then
      arch_commits+=("$commit")

      if [[ "$other_in_commit" == "true" ]]; then
        mixed_commits+=("$commit")
      fi
    fi
  done <<< "$commits"

  # If branch has architecture commits, ALL commits must be architecture-only
  if [[ ${#arch_commits[@]} -gt 0 ]]; then
    # Check if ANY commits touch both ARCHITECTURE.md and other files
    if [[ ${#mixed_commits[@]} -gt 0 ]]; then
      echo "❌ ARCHITECTURE BRANCH CONSISTENCY VIOLATION"
      echo ""
      echo "This branch contains ARCHITECTURE.md commits mixed with other changes."
      echo ""
      echo "Architecture branches must contain ONLY ARCHITECTURE.md commits."
      echo "Implementation branches must NOT contain ARCHITECTURE.md commits."
      echo ""
      echo "Commits with mixed changes:"
      for commit in "${mixed_commits[@]}"; do
        commit_subject=$(git show -s --format=%s "$commit")
        echo "  $commit: $commit_subject"
      done
      echo ""
      echo "📋 How to fix:"
      echo "  1. Create separate branches for architecture vs implementation"
      echo "  2. Use 'git cherry-pick' to move commits to correct branches"
      echo ""
      echo "Example:"
      echo "  # Create architecture branch"
      echo "  git checkout -b arch/my-decision main"
      echo "  git cherry-pick <architecture-commit-sha>"
      echo ""
      echo "  # Create implementation branch"
      echo "  git checkout -b feat/my-feature main"
      echo "  git cherry-pick <implementation-commit-sha>"
      echo ""
      exit 1
    fi
  fi
done

# Check passed
exit 0
