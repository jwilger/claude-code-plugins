---
description: INVOKE to start or continue work on an issue. Shows ready items, creates branch
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
  - Grep
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
            Before completing, store the current work context in auto memory using /sdlc:remember:
            - Issue being worked on
            - Branch name
            - Any decisions or discoveries made

            Output ONLY: {"ok": true}
---

# SDLC Work

Start or continue working on a task. This command:
1. Checks for clean git state
2. Shows tasks ready for work (unblocked and open status)
3. Shows active tasks with their child tasks
4. Lets you select which task to work on
5. Marks task as active, creates branch

## Arguments

`$ARGUMENTS` - Optional task ID to work on directly (e.g., `/sdlc:work myproject-add-login-abc123`)

## Steps

### 1. Load Configuration

Read `.claude/sdlc.yaml` to get:
- Git workflow preference (git-spice vs standard)
- **Worktree mode** (`git.worktrees: true` enables parallel development)
- GitHub project settings
- Board status names

If config doesn't exist, inform user to run `/sdlc:setup` first.

**Version check:**

```bash
grep "^sdlc_version:" .claude/sdlc.yaml || echo "sdlc_version: unknown"
```

If the version in the config doesn't match the current plugin version (**5.0.0**), show a warning:

```
⚠️  SDLC UPDATE AVAILABLE

Your SDLC configuration was created with v<version> but you're running v5.0.0.

To update (preserves your configuration choices):
  /sdlc:setup
```

Then proceed with the current configuration (don't block work, just notify).

**Worktree Detection**: If `git.worktrees: true`, this command will create isolated worktrees for parallel development of independent vertical slices.

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
dot ls --status active --json
```

If branch name contains a task ID (e.g., `feature/myproject-add-login-abc123`), that task becomes the default selection.

### 3. Check Auto Memory for Context

Before showing issues, check auto memory for relevant project context using Grep:

```bash
# Search for current work context
MEMORY_PATH="$HOME/.claude/projects/$(pwd | sed 's/\//-/g' | sed 's/^-//')/memory"
grep -r -i "current work\|in progress" "$MEMORY_PATH" --include="*.md" 2>/dev/null || true
```

This helps identify if there's already work in progress that should be the default.

### 4. Get Available Tasks

Get tasks ready for work (unblocked, open status):
```bash
dot ready --json
```

This shows all tasks that:
- Have `status: open`
- Are not blocked by any other tasks
- Are sorted by priority

Also get active tasks:
```bash
dot ls --status active --json
```

### 4a. Get Child Tasks of Active Parents

For each active task, fetch child tasks to show sub-task progress:
```bash
for parent_id in $(echo "$ACTIVE_TASKS" | jq -r '.[].id'); do
  dot tree "$parent_id" --json
done
```

This shows the hierarchy and helps identify if parent tasks have remaining children to complete.

### 5. Present Options

Use AskUserQuestion to show available work:

Format tasks as options:
- **Currently working on** (if detected): "myproject-add-login-abc123 - Task title [Active]"
- **Child tasks of active parents**: "myproject-validate-form-def456 - Child task title [child of: Parent title]"
- **Ready tasks** (sorted by priority): "myproject-new-feature-ghi789 - Task title [P1]"

**Child Task Priority**: Child tasks of active parents should be shown prominently (after any "Currently working on" item but before general Ready tasks) since they represent work that's already been scoped and is blocking completion of the parent.

Include context from auto memory search if relevant.

Let user select a task or enter a custom task ID.

### 6. Start Work on Selected Task

#### a. Mark task as active
```bash
dot on <task-id>
```

This changes the task status from `open` to `active`, indicating work has begun.

**Note**: Unlike GitHub Issues, dot tasks don't have assignment - all tasks in .dots/ belong to the current user/project.

#### b. Create branch (or worktree)

Use the full task ID as the branch name (e.g., `feature/myproject-add-login-abc123`). The task ID already contains a slug from the title, so no need to generate one.

**If worktrees enabled (`git.worktrees: true`):**

Worktrees enable parallel development of independent vertical slices. Each worktree is an isolated workspace with its own working directory.

```bash
# Determine worktree location
# Priority: existing .worktrees/ or worktrees/ > sibling directory
worktree_base="../$(basename $(pwd))-worktrees"
mkdir -p "$worktree_base"

# Create worktree with new branch using task ID
git worktree add "$worktree_base/<task-id>" -b feature/<task-id>

# Verify worktree location
echo "Worktree created at: $worktree_base/<task-id>"
```

After creating the worktree:
1. Note the worktree path for the user
2. Run any project setup (npm install, cargo build, etc.)
3. Run baseline tests to ensure clean starting state
4. Optionally store worktree path in auto memory using /sdlc:remember if needed for context

**If using git-spice (no worktrees):** For git-spice workflow guidance, invoke the `sdlc:shared/git-spice` skill or see its documentation.

**If using standard git (no worktrees):**
```bash
git checkout -b feature/<task-id>
```

**Parallel Development Note**: With worktrees enabled, you can work on multiple independent slices simultaneously. Each slice gets its own isolated worktree directory.

**How to work in parallel:**
1. In your main project, run `/sdlc:work myproject-slice-one-abc123` → creates worktree at `../myproject-worktrees/myproject-slice-one-abc123`
2. Open a **new terminal window**, `cd` to the worktree directory
3. Launch a **separate Claude Code instance** there (`claude`)
4. Back in your main project, run `/sdlc:work myproject-slice-two-def456` for another slice
5. Repeat for each parallel slice

**Why separate instances?**
- Each Claude instance has isolated context (no confusion about which files)
- Git operations don't conflict
- Each slice gets full TDD workflow attention

**When parallel development is safe:**
- Vertical slices are designed to be independent
- Slices share only event schemas (documented contracts from event modeling)
- Integration points are spec'd BEFORE dependent work begins
- Shared code (integration points) should be merged to main before dependent slices start

#### c. Store in auto memory

Use /sdlc:remember to note the current work session:

```bash
/sdlc:remember "Working on task <task-id>: <title>
Project: <project-name> | Path: <repo-path>
Branch: feature/<task-id>
Date: $(date +%Y-%m-%d)"
```

### 7. Display Work Context

Show the task details and acceptance criteria:

```bash
dot show <task-id>
```

If the task has child tasks:
```bash
dot tree <task-id>
```

### 8. Ready to Work

Display:

```
Ready to work on <task-id>: <title>

Branch: feature/<task-id>
Status: active

Description:
<from task description>

Child tasks:
<if any, from dot tree>

The SDLC will guide your TDD workflow. Just describe what you want to implement.
```

## Error Handling

- **No config**: Direct to `/sdlc:setup`
- **No .dots/ directory**: Direct to `/sdlc:setup` to initialize dot
- **Dirty git state**: Show cleanup options
- **Pull fails (diverged)**: Inform user of conflict, suggest `git pull --rebase` or manual resolution
- **No ready tasks**: Suggest using `/sdlc:plan` to create tasks from event model slices, or manually creating tasks with `dot add`
- **Task not found**: Show error with task ID, suggest `dot ls` to see all tasks
- **Git-spice branching issues**: See `sdlc:shared/git-spice` skill for handling stacking scenarios
