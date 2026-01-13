---
description: Start working on a GitHub issue - shows ready items, handles assignment and branch creation
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
  - mcp__memento__semantic_search
  - mcp__memento__open_nodes
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            SDLC CONFIG CHECK (runs once per session)

            Verify .claude/sdlc.yaml exists before proceeding.
            If it doesn't exist, stop and tell user to run /sdlc:setup first.

            Respond with: {"ok": true}
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Before completing, store the current work context in memento:
            - Issue being worked on
            - Branch name
            - Any decisions or discoveries made

            Output ONLY: {"ok": true}
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

Verify clean state and sync with remote:

```bash
git status --porcelain
git fetch origin
git pull --ff-only
```

If uncommitted changes exist, ERROR with options: commit, stash, or discard.
If pull fails due to diverged history, inform user and suggest resolution.

Also detect current work context:
```bash
git branch --show-current
gh issue list --assignee @me --state open
```

If branch name contains an issue number (e.g., `feature/123-add-login`), that issue becomes the default selection.

### 3. Search Memento for Context

Before showing issues, search memento for relevant project context:

```
mcp__memento__semantic_search({ "query": "current work in progress [project-name]" })
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

### 4a. Get Sub-Issues of In Progress Items

For each In Progress issue (only), fetch non-closed sub-issues:
```bash
gh issue-ext sub list <issue-number> --json
```
Include sub-issues where state is NOT "CLOSED". Collect with parent context for presentation.

### 5. Present Options

Use AskUserQuestion to show available work:

Format issues as options:
- **Currently working on** (if detected): "#123 - Issue title [In Progress]"
- **Sub-issues of In Progress items**: "#789 - Sub-issue title [sub-issue of #123: Parent title]"
- **Ready items** (sorted by priority): "#456 - Issue title [P0]"

**Sub-issue Priority**: Sub-issues of In Progress items should be shown prominently (after any "Currently working on" item but before general Ready items) since they represent work that's already been scoped and is blocking completion of the parent.

Include context from memento search if relevant.

Let user select an issue or enter a custom issue number.

### 6. Start Work on Selected Issue

#### a. Assign to self (if not already assigned)
```bash
gh issue edit <number> --add-assignee @me
```

#### b. Move to In Progress (if using projects)

Load the project configuration from `.claude/sdlc.yaml`:
```bash
owner=$(yq '.github.owner' .claude/sdlc.yaml)
project=$(yq '.github.project' .claude/sdlc.yaml)
```

If project is not null/empty:
```bash
gh project-ext move <number> "In Progress" --owner "$owner" --project "$project"
```

If project is null or not configured, skip the move step with an informational message:
```
Note: No GitHub Project configured. To configure, run: /sdlc:setup
```

#### c. Create branch

Generate slug from issue title (lowercase, hyphens, max 50 chars).

**If using git-spice:** For git-spice workflow guidance, invoke the `sdlc:shared/git-spice` skill or see its documentation.

**If using standard git:**
```bash
git checkout -b feature/<issue-number>-<slug>
```

#### d. Store in memento

Create a memory noting the current work:
```
mcp__memento__create_entities({
  "entities": [{
    "name": "Current Work Session [date]",
    "entityType": "work_session",
    "observations": [
      "Working on issue #<number>: <title>",
      "Project: <project-name> | Path: <repo-path>",
      "Branch: <branch-name>"
    ]
  }]
})
```

### 7. Display Work Context

Show the issue details and acceptance criteria:

```bash
gh issue view <number>
```

If the issue has sub-issues:
```bash
gh issue-ext sub list <number>
```

### 8. Ready to Work

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
- **Git-spice branching issues**: See `sdlc:shared/git-spice` skill for handling stacking scenarios
