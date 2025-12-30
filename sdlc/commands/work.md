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

If using git-spice:
```bash
gs branch create <issue-number>-<slug>
```

If using standard git:
```bash
git checkout -b feature/<issue-number>-<slug>
```

Generate slug from issue title (lowercase, hyphens, max 50 chars).

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
- **No ready issues**: Suggest creating issues or checking project board
- **Issue not found**: Show error with issue number
- **Already on a feature branch**: Ask if user wants to switch or continue
