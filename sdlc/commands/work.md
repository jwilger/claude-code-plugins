---
description: Start working on a GitHub issue - shows ready items, handles assignment and branch creation
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
  - mcp__memento__semantic_search
  - mcp__memento__open_nodes
---

# SDLC Work

Start or continue working on a GitHub issue. This command:
1. Checks for clean git state
2. Shows issues ready for work (including any currently in progress)
3. Lets you select which issue to work on
4. Assigns the issue, moves to In Progress, creates branch

## Arguments

`$ARGUMENTS` - Optional issue number to work on directly (e.g., `/sdlc:work 123`)

## Steps

### 1. Load Configuration

Read `.claude/sdlc.yaml` to get:
- Git workflow preference (git-spice vs standard)
- GitHub project settings
- Board status names

If config doesn't exist, inform user to run `/sdlc:setup` first.

### 2. Check Git State

#### a. Check for uncommitted changes

```bash
git status --porcelain
```

If there are uncommitted changes, ERROR:

```
Cannot start new work with uncommitted changes.

Options:
1. Commit your changes: git add . && git commit
2. Stash your changes: git stash
3. Discard changes: git checkout .

Then run /sdlc:work again.
```

#### b. Pull latest for current branch

Fetch and pull the latest changes:
```bash
git fetch origin
git pull --ff-only
```

If pull fails due to diverged history, inform user and suggest resolution.

### 3. Search Memento for Context

Before showing issues, search memento for relevant project context:

```
mcp__memento__semantic_search: "current work in progress [project-name]"
```

This helps identify if there's already work in progress that should be the default.

### 4. Get Available Issues

If using GitHub Projects:
```bash
gh project-ext ready  # Shows Ready items sorted by priority
```

Also get In Progress items:
```bash
gh project item-list <project-number> --owner <owner> --format json | \
  jq '.items[] | select(.status == "In Progress")'
```

If not using projects, fall back to:
```bash
gh issue list --state open --json number,title,labels,assignees
```

### 5. Detect Current Work

Check the current branch for linked issues:
```bash
git branch --show-current
```

If branch name contains an issue number (e.g., `feature/123-add-login`), that issue should be the default selection.

Also check:
```bash
gh issue list --assignee @me --state open
```

### 6. Present Options

Use AskUserQuestion to show available work:

Format issues as options:
- **Currently working on** (if detected): "#123 - Issue title [In Progress]"
- **Ready items** (sorted by priority): "#456 - Issue title [P0]"

Include context from memento search if relevant.

Let user select an issue or enter a custom issue number.

### 7. Start Work on Selected Issue

#### a. Assign to self (if not already assigned)
```bash
gh issue edit <number> --add-assignee @me
```

#### b. Move to In Progress (if using projects)
```bash
gh project-ext move <number> "In Progress"
```

#### c. Create branch

Generate slug from issue title (lowercase, hyphens, max 50 chars).

**If using git-spice:**

First, determine current branch and default branch:
```bash
git branch --show-current
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
```

**If on default branch (main/master):**

Simply create the new branch:
```bash
gs branch create <issue-number>-<slug>
```

**If NOT on default branch:**

Check if there's a PR for the current branch:
```bash
gh pr view --json state,url,mergedAt 2>/dev/null
```

**Scenario 1: No PR exists for current branch**

Use AskUserQuestion:

> **No PR for current branch**
>
> Branch `<current-branch>` doesn't have a PR yet. For proper stacking with git-spice, the base branch should have a PR.
>
> Options:
> - **Create PR first** — Run `/sdlc:pr` to create a PR for `<current-branch>`, then run `/sdlc:work` again
> - **Start new stack from main** — Switch to main and start fresh (parallel work, no stacking)
> - **Stack anyway (advanced)** — Create stacked branch without base PR (you'll need to create PRs in order later)

If "Create PR first": Stop and inform user to run `/sdlc:pr`
If "Start new stack from main":
```bash
git checkout <default-branch>
git pull --ff-only
gs branch create <issue-number>-<slug>
```
If "Stack anyway":
```bash
gs branch create <issue-number>-<slug>
```

**Scenario 2: PR exists but is merged**

Use AskUserQuestion:

> **PR already merged**
>
> The PR for `<current-branch>` has been merged. You should switch to main and pull the updates before starting new work.
>
> Options:
> - **Switch to main and pull** — Recommended: checkout main, pull updates, then create branch
> - **Stay here** — Keep working from this branch (not recommended)

If "Switch to main and pull":
```bash
git checkout <default-branch>
git pull --ff-only
gs branch create <issue-number>-<slug>
```

**Scenario 3: PR exists and is open**

Use AskUserQuestion:

> **Stack on current branch?**
>
> You're on `<current-branch>` which has an open PR. When using git-spice, you can:
> - **Stack on current branch** — Creates new branch as a child of `<current-branch>` (stacked PR workflow)
> - **Start new stack from main** — Switches to main first, then creates branch (parallel work)

If "Stack on current branch":
```bash
gs branch create <issue-number>-<slug>
```

If "Start new stack from main":
```bash
git checkout <default-branch>
git pull --ff-only
gs branch create <issue-number>-<slug>
```

**If using standard git:**
```bash
git checkout -b feature/<issue-number>-<slug>
```

#### d. Store in memento

Create a memory noting the current work:
```
mcp__memento__create_entities:
  name: "Current Work Session [date]"
  entityType: "work_session"
  observations:
    - "Working on issue #<number>: <title>"
    - "Project: <project-name> | Path: <repo-path>"
    - "Branch: <branch-name>"
```

### 8. Display Work Context

Show the issue details and acceptance criteria:

```bash
gh issue view <number>
```

If the issue has sub-issues:
```bash
gh issue-ext sub list <number>
```

### 9. Ready to Work

Display:

```
Ready to work on #<number>: <title>

Branch: <branch-name>
Status: In Progress

Acceptance Criteria:
<from issue body>

Sub-issues:
<if any>

The SDLC will guide your TDD workflow. Just describe what you want to implement.
```

## Error Handling

- **No config**: Direct to `/sdlc:setup`
- **Dirty git state**: Show cleanup options
- **Pull fails (diverged)**: Inform user of conflict, suggest `git pull --rebase` or manual resolution
- **No ready issues**: Suggest creating issues or checking project board
- **Issue not found**: Show error with issue number
- **No PR for current branch (git-spice)**: Offer to create PR first, start new stack, or stack anyway
- **PR already merged (git-spice)**: Suggest switching to main and pulling updates
- **Feature branch with open PR (git-spice)**: Ask about stacking vs new stack
