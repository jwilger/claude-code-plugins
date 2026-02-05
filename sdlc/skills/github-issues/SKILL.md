---
name: github-issues
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: GitHub CLI patterns for issue/PR management using native commands and extensions
tags:
  - github
  - issues
  - project-management
  - cli
portability: tool-specific
dependencies: []
---

# GitHub Issues and PR Management

**Version:** 1.0.0
**Portability:** Tool-Specific (requires GitHub CLI + extensions)

---

## Objective

Teaches effective GitHub issue and PR management using the GitHub CLI (`gh`) and purpose-built extensions, following a priority hierarchy that favors higher-level abstractions over low-level API calls.

**Purpose:** Manage GitHub issues, PRs, and project boards efficiently from the command line with maintainable, discoverable commands rather than fragile API calls.

**Scope:**
- **Included:** gh CLI command patterns, extension usage, sub-issue workflows, project board management, PR review handling
- **Excluded:** GitHub web UI usage, GitHub Actions, repository administration

**Tool Requirements:**
- GitHub CLI (`gh`): https://cli.github.com/
- Optional extensions: `gh-issue-ext`, `gh-project-ext`, `gh-pr-review`

---

## Core Principles

### Principle 1: Extension Priority Hierarchy

**The Principle:** Use the highest-level abstraction available: Extensions > Native gh commands > gh api.

**Why this matters:** Low-level API calls (`gh api`) are fragile, require knowledge of GitHub's internal API structure, and break when APIs change. Higher-level commands abstract complexity and are maintained by their authors.

**The Hierarchy:**
1. **Extension commands** (highest level) - Purpose-built for specific workflows
2. **Native gh commands** (middle level) - Official GitHub CLI commands
3. **gh api** (lowest level, last resort) - Raw API access

**How to apply:**
1. Check for extension commands first (`gh extension list`)
2. If no extension, use native gh commands (`gh issue`, `gh pr`, `gh project`)
3. Only use `gh api` when no CLI alternative exists
4. Before using `gh api`, search for extensions: `gh extension search <keywords>`

**Example:**
```bash
# ❌ Bad: Using gh api for sub-issues (fragile)
gh api graphql -f query='mutation {
  linkIssue(input: {parentId: "I_xxx", childId: "I_yyy"}) {
    ...
  }
}'

# ✓ Good: Using extension (maintainable)
gh issue-ext sub add 10 42
```

**Benefits:**
- Extensions handle API complexity
- Commands have better error messages
- Easier to remember and discover
- More resilient to API changes

### Principle 2: Sub-Issues Require Two Steps

**The Principle:** GitHub does not support creating sub-issues in a single command. Always use a two-step process.

**Why this matters:** Attempting to create and link a sub-issue in one command will fail. The API requires the child issue to exist before linking.

**The Two Steps:**
1. Create the issue (get issue number)
2. Link as sub-issue (using issue numbers)

**How to apply:**
```bash
# Step 1: Create child issue
CHILD=$(gh issue create --title "Child Issue" --body "..." | grep -oP '#\K\d+')

# Step 2: Link as sub-issue
gh issue-ext sub add <parent-number> $CHILD
```

**Common mistake:**
```bash
# ❌ This does NOT work (no --parent flag)
gh issue create --title "Child" --parent 10

# ❌ This does NOT work (--sub-issue flag doesn't exist)
gh issue create --title "Child" --sub-issue-of 10
```

**Correct approach:**
```bash
# ✓ Create first, then link
gh issue create --title "Child Issue" --body "..."
# Returns: #42

gh issue-ext sub add 10 42  # Make #42 a sub-issue of #10
```

### Principle 3: Extensions Are Discoverable and Installable

**The Principle:** Before writing custom `gh api` calls, search for and consider installing extensions that solve your need.

**Why this matters:** Many common workflows already have well-maintained extensions. Using them saves time and reduces maintenance burden.

**How to apply:**
1. Search for extensions: `gh extension search <keywords>`
2. Install if found: `gh extension install <repo>`
3. List installed: `gh extension list`
4. Upgrade extensions: `gh extension upgrade --all`

**Example (sub-issues):**
```bash
# Search for issue management extensions
gh extension search issues

# Output shows: gh-issue-ext (sub-issues, blocking, branches)

# Install
gh extension install github/gh-issue-ext

# Use
gh issue-ext sub add 10 42
```

### Principle 4: Project Boards as Source of Truth

**The Principle:** GitHub Projects should be the authoritative source for task state, not local notes or separate tools.

**Why this matters:** Distributed teams need shared visibility. Local notes don't sync. GitHub Projects integrate with issues and PRs.

**How to apply:**
- Move issues between columns to track progress
- Use project views to see team workload
- Automate status updates when PRs merge
- Use project fields for metadata (priority, size, team)

**Example:**
```bash
# Claim issue (assign to self + move to In Progress)
gh project-ext claim 42

# Move issue
gh project-ext move 42 "In Review"

# View Ready items
gh project-ext ready
```

---

## Constraints and Boundaries

### DO:
- Use extension commands when available
- Fall back to native gh commands if no extension
- Search for extensions before using gh api
- Create issues first, then link as sub-issues (two steps)
- Keep project board updated (source of truth)
- Use meaningful issue titles and descriptions
- Link PRs to issues explicitly

### DON'T:
- Use `gh api` without exhausting alternatives
- Attempt to create sub-issues in one step (doesn't work)
- Hard-code GraphQL queries when extensions exist
- Use flags like `--parent` or `--sub-issue-of` on `gh issue create` (they don't exist)
- Maintain task state in local notes instead of GitHub Projects
- Skip searching for extensions (`gh extension search`)

**Rationale:** Higher-level abstractions are more maintainable, discoverable, and resilient to API changes.

---

## Usage Patterns

### Pattern 1: Sub-Issue Workflow

**Scenario:** Breaking a large issue into smaller, trackable sub-issues.

**Approach:**

**Step 1: Identify parent issue**
```bash
# Parent issue already exists
# Example: #10 "Implement user authentication"
```

**Step 2: Create sub-issues**
```bash
# Sub-issue 1: Types
gh issue create \
  --title "Define User and Email types" \
  --label "sub-issue,domain-modeling" \
  --body "Create type definitions for User, Email, Password"
# Returns: #41

gh issue-ext sub add 10 41

# Sub-issue 2: Repository
gh issue create \
  --title "Implement UserRepository" \
  --label "sub-issue,implementation" \
  --body "Implement UserRepository trait with database access"
# Returns: #42

gh issue-ext sub add 10 42

# Sub-issue 3: Endpoint
gh issue create \
  --title "Add /login endpoint" \
  --label "sub-issue,api" \
  --body "Create HTTP endpoint for user login"
# Returns: #43

gh issue-ext sub add 10 43
```

**Step 3: View sub-issues**
```bash
gh issue-ext sub list 10
# Output:
# - #41: Define User and Email types
# - #42: Implement UserRepository
# - #43: Add /login endpoint
```

**Benefits:**
- Clear task breakdown visible in GitHub
- Each sub-issue can have own PR
- Progress tracked independently
- Parent issue shows completion status

### Pattern 2: Blocking Dependencies

**Scenario:** Issue #15 depends on #14 being complete first.

**Approach:**

**Add blocking relationship:**
```bash
# #15 is blocked by #14
gh issue-ext blocking add 15 14
```

**Query blocking issues:**
```bash
# What blocks #15?
gh issue-ext blocking list 15
# Output: #14: Implement database schema
```

**Check if ready to start:**
```bash
# Check if #14 is closed
gh issue view 14 --json state --jq '.state'
# Output: OPEN (not ready yet)

# Later, after #14 closes
gh issue view 14 --json state --jq '.state'
# Output: CLOSED (ready to start #15)
```

**Benefits:**
- Explicit dependencies visible
- Prevents starting blocked work
- Team understands task order

### Pattern 3: Branch Linking

**Scenario:** Create a branch for an issue and automatically link them.

**Approach:**

**Using extension:**
```bash
# Create and link branch for issue #42
gh issue-ext branch create 42

# Output:
# Created branch: 42-implement-user-repository
# Linked to issue #42
# Switched to branch
```

**Manual approach:**
```bash
# Get issue title
TITLE=$(gh issue view 42 --json title --jq '.title')

# Create branch (slug from title)
BRANCH="42-${TITLE,,}"  # Convert to lowercase
BRANCH="${BRANCH// /-}" # Replace spaces with hyphens

git checkout -b "$BRANCH"

# Link via commit (when you commit)
git commit -m "Implement UserRepository

Closes #42"
```

**Benefits:**
- Consistent branch naming
- Automatic issue-PR linking
- Easy to find branch for issue

### Pattern 4: Project Board Management

**Scenario:** Managing issues through a project board workflow.

**Approach:**

**View available work:**
```bash
# Show issues in "Ready" column
gh project-ext ready
```

**Claim an issue:**
```bash
# Assign to self + move to "In Progress"
gh project-ext claim 42
```

**Update status:**
```bash
# Move to "In Review" (PR created)
gh project-ext move 42 "In Review"

# Move to "Done" (after merge)
gh project-ext move 42 "Done"
```

**Check your workload:**
```bash
# Show issues assigned to you
gh issue list --assignee @me --state open
```

---

## Integration with Other Skills

**Works well with:**
- **git-spice:** Link each stacked PR to a sub-issue
- **tdd-constraints:** Create sub-issues for each TDD phase (red, domain, green)
- **orchestration-protocol:** Use GitHub issues as task queue for agents

**Prerequisites:**
- GitHub repository with issues enabled
- GitHub CLI authenticated (`gh auth login`)
- GitHub Projects set up (optional but recommended)

---

## Common Pitfalls

### Pitfall 1: Attempting One-Step Sub-Issue Creation

**Problem:** Trying to create sub-issue with a `--parent` flag

**Solution:** Use two steps:
```bash
gh issue create --title "Child" ...  # Step 1: Create
gh issue-ext sub add 10 42          # Step 2: Link
```

### Pitfall 2: Using `gh api` Without Searching for Extensions

**Problem:** Writing complex GraphQL queries when extension exists

**Solution:** Search first:
```bash
gh extension search <keywords>
# Find extension, install, use
```

### Pitfall 3: Not Installing Required Extensions

**Problem:** Commands fail with "unknown command: issue-ext"

**Solution:** Install extensions:
```bash
gh extension install github/gh-issue-ext
gh extension install github/gh-project-ext
gh extension install github/gh-pr-review
```

### Pitfall 4: Hard-Coding Issue Numbers in Scripts

**Problem:** Scripts break when issue numbers change

**Solution:** Query issues dynamically:
```bash
# Bad: Hard-coded
gh issue-ext sub add 10 42

# Good: Query parent by label
PARENT=$(gh issue list --label "epic:auth" --json number --jq '.[0].number')
gh issue-ext sub add $PARENT 42
```

---

## Examples

### Example 1: Complete Sub-Issue Workflow

**Scenario:** Feature with 3 sub-issues.

**Parent Issue:**
```bash
# Create parent issue
gh issue create \
  --title "User Authentication System" \
  --label "epic,feature" \
  --body "Implement complete authentication with types, repository, and endpoint"
# Returns: #10
```

**Sub-Issue 1:**
```bash
# Create
gh issue create \
  --title "Define authentication domain types" \
  --label "sub-issue,domain" \
  --body "Create User, Email, Password, AuthError types"
# Returns: #41

# Link
gh issue-ext sub add 10 41

# Create branch
gh issue-ext branch create 41
# Branch: 41-define-authentication-domain-types

# Work on issue...
# Commit with: "Closes #41"

# Create PR
gh pr create --title "Define authentication domain types" --body "Closes #41"
```

**Sub-Issue 2:**
```bash
# Mark #41 as blocking #42 before creating
gh issue create \
  --title "Implement UserRepository" \
  --label "sub-issue,implementation" \
  --body "Database access layer for users"
# Returns: #42

gh issue-ext sub add 10 42
gh issue-ext blocking add 42 41  # Blocked by #41

# Wait for #41 to close...

# Create branch
gh issue-ext branch create 42

# Work, commit, PR...
gh pr create --title "Implement UserRepository" --body "Closes #42"
```

**Sub-Issue 3:**
```bash
gh issue create \
  --title "Add /login HTTP endpoint" \
  --label "sub-issue,api" \
  --body "RESTful endpoint for user login"
# Returns: #43

gh issue-ext sub add 10 43
gh issue-ext blocking add 43 42  # Blocked by #42

# Work, commit, PR...
```

**Track Progress:**
```bash
# View sub-issues
gh issue-ext sub list 10
# - #41: Define authentication domain types [CLOSED] ✓
# - #42: Implement UserRepository [OPEN]
# - #43: Add /login HTTP endpoint [OPEN]

# Parent closes when all sub-issues close
```

### Example 2: PR Review Thread Management

**Scenario:** Responding to PR review comments.

**View unresolved threads:**
```bash
gh pr-review review view --pr 123 --unresolved

# Output:
# Thread #1 (file: src/auth.rs, line 42):
# Reviewer: "Should we use bcrypt instead of sha256?"
```

**Reply to thread:**
```bash
gh pr-review comments reply \
  --thread-id <thread-id> \
  --body "Good point! Updated to use bcrypt."
```

**Make code changes, then resolve:**
```bash
# Push fixes
git add src/auth.rs
git commit -m "Use bcrypt for password hashing"
git push

# Resolve thread
gh pr-review threads resolve --thread-id <thread-id>
```

### Example 3: Acceptable `gh api` Usage

**Scenario:** Configuring repository settings (no native command exists).

**Enable auto-delete branches:**
```bash
# No native gh command for this
gh api repos/{owner}/{repo} \
  --method PATCH \
  -f delete_branch_on_merge=true
```

**Set merge methods:**
```bash
# No native gh command for this
gh api repos/{owner}/{repo} \
  --method PATCH \
  -f allow_squash_merge=true \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false
```

**These are acceptable because:**
- No native gh command exists
- No extension provides this functionality
- Repository settings are administrative (one-time setup)

---

## Extensions Reference

### gh-issue-ext

**Purpose:** Enhanced issue management (sub-issues, blocking, branches)

**Installation:**
```bash
gh extension install github/gh-issue-ext
```

**Commands:**
```bash
# Sub-issues
gh issue-ext sub add <parent> <child>
gh issue-ext sub list <parent>
gh issue-ext sub remove <parent> <child>

# Blocking
gh issue-ext blocking add <blocked> <blocker>
gh issue-ext blocking list <issue>

# Branches
gh issue-ext branch create <issue>
```

### gh-project-ext

**Purpose:** Project board management from CLI

**Installation:**
```bash
gh extension install github/gh-project-ext
```

**Commands:**
```bash
# View columns
gh project-ext ready
gh project-ext in-progress
gh project-ext in-review

# Move issues
gh project-ext move <issue> "<column>"

# Claim issues
gh project-ext claim <issue>  # Assign + move to In Progress
```

### gh-pr-review

**Purpose:** PR review thread management

**Installation:**
```bash
gh extension install github/gh-pr-review
```

**Commands:**
```bash
# View reviews
gh pr-review review view --pr <number> --unresolved

# Comment management
gh pr-review comments reply --thread-id <id> --body "..."
gh pr-review threads resolve --thread-id <id>
```

---

## Verification Checklist

Use this checklist to verify you're using GitHub CLI effectively:

- [ ] Installed GitHub CLI (`gh --version`)
- [ ] Authenticated (`gh auth status`)
- [ ] Installed useful extensions (`gh extension list`)
- [ ] Used extension commands when available (not `gh api`)
- [ ] Created sub-issues in two steps (create, then link)
- [ ] Linked branches to issues
- [ ] Used project board for task tracking
- [ ] Linked PRs to issues (via "Closes #N" in description)
- [ ] Searched for extensions before writing gh api calls

---

## References

**Source Documentation:**
- sdlc plugin: commands/shared/github-issues.md
- GitHub CLI: https://cli.github.com/

**Related Skills:**
- git-spice - Link stacked PRs to sub-issues
- orchestration-protocol - Use GitHub issues as task queue

**External Resources:**
- GitHub CLI Manual: https://cli.github.com/manual/
- gh-issue-ext: https://github.com/github/gh-issue-ext
- gh-project-ext: https://github.com/github/gh-project-ext
- gh-pr-review: https://github.com/github/gh-pr-review

---

## Version History

### v1.0.0 (2026-02-04)
- Initial extraction from sdlc plugin
- Extension priority hierarchy
- Sub-issue two-step workflow
- Project board management patterns
- PR review thread handling
- Tool-specific (requires gh CLI + extensions)

---

## Metadata

**Extraction Source:** sdlc/commands/shared/github-issues.md
**Extraction Date:** 2026-02-04
**Last Updated:** 2026-02-04
**Compatibility:** Tool-specific (requires GitHub CLI + extensions)
**License:** MIT
