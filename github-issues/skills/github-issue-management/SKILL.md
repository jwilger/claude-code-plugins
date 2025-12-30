---
name: GitHub Issue Management
description: |
  This skill provides comprehensive knowledge for managing GitHub issues using the gh CLI,
  including sub-issues (parent/child hierarchies), blocking relationships, linked development
  branches, and standard issue operations. Use this skill when the user asks about managing
  GitHub issues, creating issue hierarchies, tracking dependencies, or linking branches to issues.

  Trigger phrases: "create sub-issue", "add child issue", "mark as blocked", "blocking issue",
  "link branch to issue", "issue hierarchy", "epic with stories", "github issue management",
  "gh issue", "issue dependencies", "parent issue", "sub-task"
version: 1.0.0
---

# GitHub Issue Management

## Overview

This skill teaches comprehensive GitHub issue management using the `gh` CLI and the `gh-issue-ext` extension. It covers:

1. **Standard issue operations** - Create, view, edit, close, list issues
2. **Sub-issues** - Parent/child relationships for hierarchical organization
3. **Blocking relationships** - Dependency tracking between issues
4. **Linked branches** - Development branch management tied to issues

## Prerequisites

Before using advanced issue management features, ensure the `gh-issue-ext` extension is installed:

```bash
gh extension install jwilger/gh-issue-ext
```

Verify installation:
```bash
gh issue-ext --version
```

## Permission Configuration

Add these patterns to Claude Code settings for auto-approval:

```
Bash(gh issue:*)
Bash(gh issue-ext:*)
```

This grants access to all issue management operations without requiring per-command approval.

---

## Standard Issue Operations

### Creating Issues

```bash
# Basic issue creation
gh issue create --title "Add user authentication" --body "Implement OAuth2 flow"

# With labels and assignees
gh issue create --title "Fix login bug" --label "bug" --label "P1-high" --assignee "@me"

# Interactive creation (prompts for details)
gh issue create
```

### Viewing Issues

```bash
# View issue details
gh issue view 42

# View in web browser
gh issue view 42 --web

# Get specific fields as JSON
gh issue view 42 --json number,title,state,body,labels

# Get issue node ID (needed for some GraphQL operations)
gh issue view 42 --json id --jq '.id'
```

### Listing Issues

```bash
# List open issues
gh issue list

# List with filters
gh issue list --state closed --label "bug"
gh issue list --assignee "@me" --limit 50

# JSON output for processing
gh issue list --json number,title,state,labels
```

### Editing Issues

```bash
# Edit title
gh issue edit 42 --title "New title"

# Add labels
gh issue edit 42 --add-label "enhancement"

# Assign
gh issue edit 42 --add-assignee "@me"

# Edit body (opens editor)
gh issue edit 42 --body "Updated description"
```

### Closing/Reopening

```bash
# Close an issue
gh issue close 42

# Close with comment
gh issue close 42 --comment "Fixed in PR #50"

# Reopen
gh issue reopen 42
```

---

## Sub-Issues (Parent/Child Relationships)

Sub-issues allow hierarchical organization:
- **Epics** contain stories
- **Stories** contain tasks
- **Tasks** can have sub-tasks

### Adding Sub-Issues

```bash
# Add issue #42 as a sub-issue of parent #10
gh issue-ext sub add 10 42

# Example: Create an epic with stories
gh issue create --title "User Authentication Epic" --label "epic"
# Creates #100

gh issue create --title "Implement login form"
# Creates #101

gh issue create --title "Add OAuth2 integration"
# Creates #102

gh issue-ext sub add 100 101
gh issue-ext sub add 100 102
```

### Listing Sub-Issues

```bash
# List all sub-issues of an issue
gh issue-ext sub list 100

# JSON output
gh issue-ext sub list 100 --json
```

### Removing Sub-Issue Relationships

```bash
# Remove #42 from parent #10
gh issue-ext sub remove 10 42
```

### Reordering Sub-Issues

Sub-issues have a display order within their parent:

```bash
# Move #102 to appear after #101
gh issue-ext sub reorder 100 102 --after 101

# Move #101 to appear before #102
gh issue-ext sub reorder 100 101 --before 102
```

### Querying Parent

To find an issue's parent:

```bash
gh issue-ext show 101
# Shows parent in output

# Or via JSON
gh issue-ext show 101 --json | jq '.parent'
```

---

## Blocking Relationships

Blocking relationships track dependencies:
- Issue A **is blocked by** Issue B (A cannot proceed until B is done)
- Issue B **is blocking** Issue A

### Adding Blocking Relationships

```bash
# Mark issue #15 as blocked by issue #14
# (Issue #15 cannot be completed until #14 is done)
gh issue-ext blocking add 15 14

# Example workflow:
# #20: "Deploy to production" is blocked by #19: "Pass QA testing"
gh issue-ext blocking add 20 19
```

### Listing Blocking Relationships

```bash
# Show what blocks issue #15 and what #15 blocks
gh issue-ext blocking list 15

# JSON output
gh issue-ext blocking list 15 --json
```

### Removing Blocking Relationships

```bash
# Remove the blocking relationship
gh issue-ext blocking remove 15 14
```

---

## Linked Development Branches

Link development branches directly to issues for tracking.

### Creating Linked Branches

```bash
# Create a branch linked to issue #42 (auto-generates name)
gh issue-ext branch create 42

# Create with specific name
gh issue-ext branch create 42 --name feature/user-authentication

# After creation, checkout locally:
git fetch origin
git checkout feature/user-authentication
```

### Alternative: Using Built-in gh issue develop

The built-in `gh issue develop` command also creates linked branches:

```bash
# Create and checkout in one step
gh issue develop 42 --checkout

# Specify branch name
gh issue develop 42 --name feature/auth --checkout

# Create from specific base branch
gh issue develop 42 --base develop --checkout
```

### Listing Linked Branches

```bash
# List branches linked to an issue
gh issue-ext branch list 42

# Using built-in command
gh issue develop --list 42
```

### Unlinking Branches

```bash
# Unlink a branch from an issue
gh issue-ext branch delete 42 feature/user-authentication

# Note: This only removes the link, not the branch itself
# To also delete the branch:
git push origin --delete feature/user-authentication
```

---

## Comprehensive Issue View

View all relationships for an issue at once:

```bash
gh issue-ext show 42
```

Output includes:
- Issue details (number, title, state, URL)
- Parent issue (if any)
- Sub-issues
- Blocked by / Blocking relationships
- Linked branches
- Related pull requests

JSON output for processing:

```bash
gh issue-ext show 42 --json
```

---

## Workflow Patterns

### Epic-Story-Task Hierarchy

```bash
# Create epic
gh issue create --title "Payment System" --label "epic"
# #100

# Create stories under epic
gh issue create --title "Credit card processing"
# #101
gh issue-ext sub add 100 101

gh issue create --title "Invoice generation"
# #102
gh issue-ext sub add 100 102

# Create tasks under stories
gh issue create --title "Integrate Stripe SDK"
# #103
gh issue-ext sub add 101 103

gh issue create --title "Add payment form component"
# #104
gh issue-ext sub add 101 104
```

### Dependency Chain

```bash
# Create issues with dependencies
gh issue create --title "Design database schema"     # #10
gh issue create --title "Implement data models"       # #11
gh issue create --title "Create API endpoints"        # #12
gh issue create --title "Build frontend components"   # #13

# Set up dependency chain
gh issue-ext blocking add 11 10   # #11 blocked by #10
gh issue-ext blocking add 12 11   # #12 blocked by #11
gh issue-ext blocking add 13 12   # #13 blocked by #12
```

### Feature Branch Workflow

```bash
# Create issue for new feature
gh issue create --title "Add dark mode support"
# #50

# Create linked development branch
gh issue-ext branch create 50 --name feature/dark-mode

# Work on the feature locally
git fetch origin
git checkout feature/dark-mode
# ... make changes ...
git push origin feature/dark-mode

# Create PR (automatically links to issue via branch)
gh pr create --title "Add dark mode support" --body "Closes #50"
```

---

## Error Handling

Common errors and solutions:

### "Could not find issue"
The issue number doesn't exist or you don't have access:
```bash
gh issue view 999  # Verify issue exists
```

### "Extension not found"
Install the extension:
```bash
gh extension install jwilger/gh-issue-ext
```

### "GraphQL error"
Usually indicates permissions. Ensure you're authenticated:
```bash
gh auth status
gh auth refresh  # If needed
```

### "Branch already exists"
The branch name is already taken:
```bash
# Use a different name
gh issue-ext branch create 42 --name feature/auth-v2
```

---

## Commands

### /github-issues:create-subtask

**Preferred method for creating sub-issues.** This command atomically creates a new issue AND links it as a sub-issue of a parent, preventing orphaned issues.

```bash
/github-issues:create-subtask <parent-issue-number> "<title>"
```

**Why use this?** When manually creating sub-issues, it's easy to:
1. Run `gh issue create`
2. Mention "Parent: #NNN" in the body
3. **Forget** to run `gh issue-ext sub add` to actually link them

The `/create-subtask` command eliminates this risk by doing both steps atomically.

---

## Best Practices

1. **Use `/github-issues:create-subtask` for sub-issues** - Prevents orphaned issues
2. **Use descriptive issue titles** - Makes sub-issue lists readable
3. **Label issues by type** - epic, story, task, bug for clarity
4. **Link blocking relationships early** - Helps planning and prioritization
5. **Use consistent branch naming** - `feature/`, `fix/`, `chore/` prefixes
6. **Close parent issues last** - Ensure all sub-issues are complete
7. **Use JSON output for scripting** - `--json` flag for automation

---

## Reference Files

For detailed examples and patterns, see:
- `references/basic-operations.md` - Standard gh issue commands
- `references/sub-issues.md` - Sub-issue management details
- `references/blocking.md` - Blocking relationship patterns
- `references/linked-branches.md` - Branch linking workflows
