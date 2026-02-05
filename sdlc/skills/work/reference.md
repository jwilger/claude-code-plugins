# Work Skill - Reference Documentation

This document provides detailed implementation steps for the work skill.

## Complete Workflow Steps

### Step 1: Load Configuration

Read `.claude/sdlc.yaml` to get:
- Git workflow preference (git-spice vs standard vs worktrees)
- Worktree mode (`git.worktrees: true` enables parallel development)
- Worktree coordination (`features.worktree_coordination: true` enables conflict prevention)
- Session task tracking (`features.session_task_tracking: true`)
- GitHub project settings
- Board status names

```bash
cat .claude/sdlc.yaml
```

If config doesn't exist, inform user to run `/sdlc:setup` first and STOP.

**Version check:**

```bash
grep "^sdlc_version:" .claude/sdlc.yaml || echo "sdlc_version: unknown"
```

If the version in the config doesn't match the current plugin version (**9.0.0**), show a warning:

```
⚠️  SDLC UPDATE AVAILABLE

Your SDLC configuration was created with v<version> but you're running v9.0.0.

To update (preserves your configuration choices):
  /sdlc:setup
```

Then proceed with the current configuration (don't block work, just notify).

### Step 2: Check Git State

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

### Step 3: Check Auto Memory for Context

Before showing issues, check auto memory for relevant project context using Grep:

```bash
# Search for current work context
MEMORY_PATH="$HOME/.claude/projects/$(pwd | sed 's/\//-/g' | sed 's/^-//')/memory"
grep -r -i "current work\|in progress" "$MEMORY_PATH" --include="*.md" 2>/dev/null || true
```

This helps identify if there's already work in progress that should be the default.

### Step 4: Get Available Tasks

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

### Step 4a: Get Child Tasks of Active Parents

For each active task, fetch child tasks to show sub-task progress:
```bash
for parent_id in $(echo "$ACTIVE_TASKS" | jq -r '.[].id'); do
  dot tree "$parent_id" --json
done
```

This shows the hierarchy and helps identify if parent tasks have remaining children to complete.

### Step 5: Present Options

Use AskUserQuestion to show available work:

Format tasks as options:
- **Currently working on** (if detected): "myproject-add-login-abc123 - Task title [Active]"
- **Child tasks of active parents**: "myproject-validate-form-def456 - Child task title [child of: Parent title]"
- **Ready tasks** (sorted by priority): "myproject-new-feature-ghi789 - Task title [P1]"

**Child Task Priority**: Child tasks of active parents should be shown prominently (after any "Currently working on" item but before general Ready tasks) since they represent work that's already been scoped and is blocking completion of the parent.

Include context from auto memory search if relevant.

Let user select a task or enter a custom task ID.

### Step 6: Start Work on Selected Task

#### a. Mark task as active

```bash
dot on <task-id>
```

This changes the task status from `open` to `active`, indicating work has begun.

**Note**: Unlike GitHub Issues, dot tasks don't have assignment - all tasks in .dots/ belong to the current user/project.

#### b. Initialize worktree coordination (v7.0.0)

**If worktree coordination enabled (`features.worktree_coordination: true` in `.claude/sdlc.yaml`):**

Before creating the worktree, register it to prevent conflicts with parallel Claude instances:

```bash
TASK_ID="<selected-task-id>"
WORKTREE_REGISTRY=".dots/.worktrees"
TASK_REGISTRY="$WORKTREE_REGISTRY/$TASK_ID"
LOCK_FILE="$WORKTREE_REGISTRY/lock"

# Ensure registry directory exists
mkdir -p "$WORKTREE_REGISTRY"

# Acquire lock for coordination (simple file lock with timeout)
attempt=0
while ! mkdir "$LOCK_FILE" 2>/dev/null; do
  attempt=$((attempt + 1))
  if [ $attempt -gt 30 ]; then
    echo "⚠️  Failed to acquire coordination lock after 30 seconds"
    echo "Another instance may be starting work. Try again in a moment."
    exit 1
  fi
  sleep 1
done

# Cleanup stale registrations (> 2 hours old)
find "$WORKTREE_REGISTRY" -maxdepth 1 -type d -name "*-*-*" | while read -r reg; do
  if [ -f "$reg/last_heartbeat" ]; then
    HB_TIME=$(cat "$reg/last_heartbeat")
    CURRENT_TIME=$(date +%s)
    AGE=$((CURRENT_TIME - HB_TIME))
    if [ $AGE -gt 7200 ]; then
      echo "Cleaning stale registration: $(basename $reg)"
      rm -rf "$reg"
    fi
  fi
done

# Check if task already has active worktree
if [ -d "$TASK_REGISTRY" ] && [ -f "$TASK_REGISTRY/last_heartbeat" ]; then
  HB_TIME=$(cat "$TASK_REGISTRY/last_heartbeat")
  CURRENT_TIME=$(date +%s)
  AGE=$((CURRENT_TIME - HB_TIME))

  if [ $AGE -lt 1800 ]; then
    # Active within last 30 minutes
    WORKTREE_LOC=$(cat "$TASK_REGISTRY/location" 2>/dev/null || echo "unknown")
    SESSION_ID=$(cat "$TASK_REGISTRY/session_id" 2>/dev/null || echo "unknown")
    rmdir "$LOCK_FILE"
    echo "⚠️  Task $TASK_ID is already being worked on"
    echo ""
    echo "Worktree: $WORKTREE_LOC"
    echo "Session:  $SESSION_ID"
    echo "Last activity: $((AGE / 60)) minutes ago"
    echo ""
    echo "This task is active in another Claude instance. To avoid conflicts:"
    echo "  - Work on a different task, or"
    echo "  - Close the other Claude instance first"
    exit 1
  else
    # Stale (> 30 min), offer to reclaim
    echo "⚠️  Task $TASK_ID has a stale worktree registration"
    echo "Last activity: $((AGE / 60)) minutes ago"
    echo ""
    # Use AskUserQuestion to confirm reclaim
    # If user confirms: rm -rf "$TASK_REGISTRY"
  fi
fi

# Check if blockers are in progress elsewhere
BLOCKERS=$(dot show "$TASK_ID" --json | jq -r '.blockers[]? // empty')
for blocker in $BLOCKERS; do
  if [ -d "$WORKTREE_REGISTRY/$blocker" ] && [ -f "$WORKTREE_REGISTRY/$blocker/last_heartbeat" ]; then
    HB_TIME=$(cat "$WORKTREE_REGISTRY/$blocker/last_heartbeat")
    CURRENT_TIME=$(date +%s)
    AGE=$((CURRENT_TIME - HB_TIME))

    if [ $AGE -lt 1800 ]; then
      BLOCKER_TITLE=$(dot show "$blocker" --json | jq -r '.title')
      rmdir "$LOCK_FILE"
      echo "⚠️  Blocker task is being worked on in parallel"
      echo ""
      echo "Task:     $blocker"
      echo "Title:    $BLOCKER_TITLE"
      echo "Activity: $((AGE / 60)) minutes ago"
      echo ""
      echo "This blocker is active in another Claude instance."
      echo "Wait for it to complete or coordinate with the other instance."
      exit 1
    fi
  fi
done

# Release lock (will register after worktree creation)
rmdir "$LOCK_FILE"
```

**If coordination not enabled:** Skip this section, proceed to branch/worktree creation.

#### c. Create branch (or worktree)

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
1. **Register the worktree** (if coordination enabled - v7.0.0)
2. Note the worktree path for the user
3. Run any project setup (npm install, cargo build, etc.)
4. Run baseline tests to ensure clean starting state
5. Optionally store worktree path in auto memory if needed for context

**Worktree Registration (v7.0.0):**

If coordination is enabled, register the worktree immediately after creation:

```bash
if grep -q "worktree_coordination: true" .claude/sdlc.yaml 2>/dev/null; then
  WORKTREE_PATH="$worktree_base/$TASK_ID"
  TASK_REGISTRY=".dots/.worktrees/$TASK_ID"
  LOCK_FILE=".dots/.worktrees/lock"

  # Acquire lock
  while ! mkdir "$LOCK_FILE" 2>/dev/null; do sleep 1; done

  # Create registration
  mkdir -p "$TASK_REGISTRY"
  echo "$WORKTREE_PATH" > "$TASK_REGISTRY/location"
  echo "$CLAUDE_SESSION_ID" > "$TASK_REGISTRY/session_id"
  date +%s > "$TASK_REGISTRY/started_at"
  date +%s > "$TASK_REGISTRY/last_heartbeat"

  # Store task list ID for session resumability
  TASK_LIST_ID="sdlc-$TASK_ID-$(date +%s)"
  echo "$TASK_LIST_ID" > "$TASK_REGISTRY/task_list_id"
  echo "$TASK_LIST_ID" > "$WORKTREE_PATH/.claude-task-list-id"

  # Set for current session
  export CLAUDE_CODE_TASK_LIST_ID="$TASK_LIST_ID"

  # Release lock
  rmdir "$LOCK_FILE"

  echo "✓ Worktree registered for coordination"
fi
```

**If using git-spice (no worktrees):**

```bash
gs branch create feature/<task-id>
```

For git-spice workflow guidance, see the `git-spice` skill documentation.

**If using standard git (no worktrees):**

```bash
git checkout -b feature/<task-id>
```

**Parallel Development Note**: With worktrees enabled, you can work on multiple independent slices simultaneously. Each slice gets its own isolated worktree directory.

**How to work in parallel:**
1. In your main project, run `/work myproject-slice-one-abc123` → creates worktree at `../myproject-worktrees/myproject-slice-one-abc123`
2. Open a **new terminal window**, `cd` to the worktree directory
3. Launch a **separate Claude Code instance** there (`claude`)
4. Back in your main project, run `/work myproject-slice-two-def456` for another slice
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

**Worktree Coordination (v7.0.0):**
- With `worktree_coordination: true`, the system prevents conflicts automatically
- Attempting to work on the same task in two instances will be blocked
- Working on a task while its blocker is in progress elsewhere will warn you
- Stale registrations (> 30 min inactive) can be reclaimed

#### d. Store in auto memory

Note the current work session in auto memory:

```
Working on task <task-id>: <title>
Project: <project-name> | Path: <repo-path>
Branch: feature/<task-id>
Date: $(date +%Y-%m-%d)
```

#### e. Create session task tracking (v7.0.0)

**If session task tracking enabled (`features.session_task_tracking: true` in `.claude/sdlc.yaml`):**

Create a story-level task in TaskTools to track "what's next?" for this session:

**IMPORTANT:** Use the TaskCreate tool with these parameters:

```
subject: "Work on: <task-title>"
description: "
Story: <task-id>
Worktree: <worktree-path-or-branch>

Acceptance Criteria:
<from dot show output>
"
activeForm: "Working on story"
metadata: {
  dotTaskId: "<task-id>",
  worktreePath: "<worktree-path-if-applicable>",
  type: "story-session"
}
```

Then immediately mark it as in_progress:

```
TaskUpdate with taskId and status: "in_progress"
```

**Note:** TDD cycle tasks (Red → Domain → Green → Domain) will be created on-demand when starting a TDD cycle, not upfront. They will be nested under this story task.

### Step 7: Display Work Context

Show the task details and acceptance criteria:

```bash
dot show <task-id>
```

If the task has child tasks:
```bash
dot tree <task-id>
```

### Step 8: Ready to Work

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
- **Git-spice branching issues**: See `git-spice` skill for handling stacking scenarios
- **Worktree coordination conflict**: Show active session details, offer to wait or switch tasks
- **Stale worktree registration**: Offer to reclaim with confirmation

## Arguments

`$ARGUMENTS` - Optional task ID to work on directly (e.g., `/work myproject-add-login-abc123`)

If task ID provided, skip task selection and proceed directly to that task.
