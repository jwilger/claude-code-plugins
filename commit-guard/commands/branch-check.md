---
name: branch-check
description: Check if current branch is safe for commits (not protected, not merged, not stale)
allowed-tools:
  - Bash
---

# Branch Safety Check

Perform a comprehensive safety check on the current git branch to determine if it's appropriate for making commits.

## Checks to Perform

Run all checks and compile a status report:

### 1. Basic Branch Info

```bash
# Get current branch
git branch --show-current

# Get repository info (if GitHub repo)
gh repo view --json nameWithOwner,defaultBranchRef -q '{owner_repo: .nameWithOwner, default_branch: .defaultBranchRef.name}' 2>/dev/null || echo "Not a GitHub repo or gh not configured"
```

### 2. Branch Protection Status

Check if the current branch has protection rules requiring pull requests:

```bash
# Get owner/repo and branch
OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
BRANCH=$(git branch --show-current)

# Check protection rules
gh api "repos/${OWNER_REPO}/branches/${BRANCH}/protection" --jq '.required_pull_request_reviews' 2>/dev/null
```

- If this returns data: Branch is PROTECTED - commits should not be made directly
- If this returns an error (404): Branch is not protected

### 3. PR Status Check

Check if this branch has an associated PR and its status:

```bash
BRANCH=$(git branch --show-current)

# Check for open PRs
gh pr list --head "$BRANCH" --state open --json number,title,url

# Check for merged PRs
gh pr list --head "$BRANCH" --state merged --json number,title,url

# Check for closed (not merged) PRs
gh pr list --head "$BRANCH" --state closed --json number,title,url
```

Report findings:
- Open PR: Safe to commit (adding to existing PR)
- Merged PR: UNSAFE - branch was already merged, create a new branch
- Closed PR: UNSAFE - PR was closed without merging, probably abandoned

### 4. Divergence Check

Check how far behind the default branch this branch is:

```bash
# Fetch latest from remote
git fetch origin --quiet 2>/dev/null || true

# Get default branch
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo "main")

# Count commits behind
BEHIND=$(git rev-list --count HEAD..origin/${DEFAULT_BRANCH} 2>/dev/null || echo "unknown")
echo "Commits behind origin/${DEFAULT_BRANCH}: ${BEHIND}"

# Also show commits ahead
AHEAD=$(git rev-list --count origin/${DEFAULT_BRANCH}..HEAD 2>/dev/null || echo "unknown")
echo "Commits ahead of origin/${DEFAULT_BRANCH}: ${AHEAD}"
```

If more than 5 commits behind: WARN about potential merge conflicts

## Output Format

Present a clear status report:

```
Branch Safety Report
====================

Current Branch: <branch-name>
Repository: <owner/repo>
Default Branch: <default-branch>

Status Checks:
  [PASS/FAIL] Branch Protection: <status>
  [PASS/FAIL] PR Status: <status>
  [PASS/WARN] Branch Divergence: <X commits behind, Y ahead>

Overall: SAFE TO COMMIT / BLOCKED / WARNING

<If blocked, explain why and suggest resolution>
<If warning, explain concern and suggest action>
```

## Error Handling

- If not in a git repository: Inform user
- If gh CLI not installed/authenticated: Note that GitHub-specific checks were skipped
- If not a GitHub repository: Note that only local git checks were performed
