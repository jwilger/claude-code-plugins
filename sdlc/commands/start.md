---
description: INVOKE to begin work. Auto-detects project state and routes to appropriate phase
allowed-tools:
  - Bash
  - Read
  - Glob
  - AskUserQuestion
  - mcp__memento__semantic_search
---

# SDLC Start

Smart entry point that detects the current SDLC phase and routes to the appropriate command.

## Steps

### 1. Check for SDLC Configuration

```bash
test -f .claude/sdlc.yaml && echo "CONFIG_EXISTS" || echo "NO_CONFIG"
```

**If NO_CONFIG**:
```
SDLC not configured for this project.

To get started, run:
  /sdlc:setup

This will configure:
- Event modeling vs traditional mode
- dot CLI task management
- Project-specific TDD hooks
```
Then STOP - don't proceed further.

### 2. Load Configuration

```bash
cat .claude/sdlc.yaml
```

Check the mode (event-modeling vs traditional).

**Version check:**

```bash
grep "^sdlc_version:" .claude/sdlc.yaml || echo "sdlc_version: unknown"
```

If the version in the config doesn't match the current plugin version (**7.0.0**), show a warning:

```
⚠️  SDLC UPDATE AVAILABLE

Your SDLC configuration was created with v<version> but you're running v7.0.0.

Updates may include improved hooks, bug fixes, or new features.

To update, run:
  /sdlc:setup

(The update process will preserve your existing configuration choices)
```

Then proceed with the current configuration (don't block work, just notify).

### 2a. Check for Orphaned Worktree Session (v7.0.0)

**If worktree coordination enabled (`features.worktree_coordination: true`):**

Check if we're currently in a worktree with a completed or closed task:

```bash
# Detect if in a worktree
WORKTREE_PATH=$(git rev-parse --show-toplevel)
MAIN_REPO=$(git worktree list --porcelain | grep "^worktree" | head -n1 | cut -d' ' -f2)

if [ "$WORKTREE_PATH" != "$MAIN_REPO" ]; then
  # We're in a worktree
  BRANCH=$(git branch --show-current)
  TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')

  # Check task status in dot (need to run from main repo)
  TASK_STATUS=$(cd "$MAIN_REPO" && dot show "$TASK_ID" --json 2>/dev/null | jq -r '.status')

  if [ "$TASK_STATUS" = "closed" ]; then
    echo "⚠️  You're in a worktree for a completed task"
    echo ""
    echo "Task:     $TASK_ID"
    echo "Status:   $TASK_STATUS"
    echo "Worktree: $WORKTREE_PATH"
    echo ""
    echo "Options:"
    echo "  1. Return to main repo:  cd $MAIN_REPO"
    echo "  2. Clean up worktree:    cd $MAIN_REPO && git worktree remove $WORKTREE_PATH"
    echo "  3. Start new work:       cd $MAIN_REPO && /sdlc:work"
    exit 0
  fi
fi
```

If the task is closed, STOP and show the options above. The user needs to navigate back to the main repository or clean up the worktree.

**If mode is `traditional`**:
```
This project uses traditional development mode.

Available commands:
  /sdlc:work  - Start working on a task
  /sdlc:pr    - Create/update a pull request
  /sdlc:complete - Complete a task after PR merge
  /sdlc:review - Handle PR review feedback

Task management:
  dot ls       - List all tasks
  dot ready    - Show unblocked tasks
  dot add      - Create a new task

To switch to event modeling, run /sdlc:setup again.
```
Then STOP.

### 3. Check Domain Discovery

```bash
test -f docs/event_model/domain/overview.md && echo "DOMAIN_EXISTS" || echo "NO_DOMAIN"
```

**If NO_DOMAIN**:
```
Event model not started.

Next step:
  /sdlc:design discover

This will help you understand:
- Who uses the system
- What they're trying to accomplish
- What workflows to model
```
Then STOP.

### 4. Check for Workflows

```bash
ls -d docs/event_model/workflows/*/ 2>/dev/null | head -1 || echo "NO_WORKFLOWS"
```

**If NO_WORKFLOWS**:

This indicates the domain overview was written but no workflows were designed yet.
This is a normal progression after discovery, or may indicate the workflow directory
was accidentally deleted. Check domain overview for suggested starting workflow.

```
Domain discovered, but no workflows designed yet.

Next step:
  /sdlc:design workflow <name>

Check docs/event_model/domain/overview.md for suggested workflows to design first.
```
Then STOP.

### 5. Check for GWT Scenarios

```bash
# Find workflows without GWT scenarios in their slices
for workflow in docs/event_model/workflows/*/; do
  name=$(basename "$workflow")
  if ! grep -q "## GWT Scenarios" "$workflow/slices/"*.md 2>/dev/null; then
    echo "NEEDS_GWT:$name"
  fi
done
```

**If any workflow NEEDS_GWT**:
```
Workflow "<name>" needs GWT scenarios.

Next step:
  /sdlc:design gwt <name>

GWT scenarios define the acceptance criteria for each slice.
```
Then STOP.

### 6. Check for Architecture

```bash
test -f docs/ARCHITECTURE.md && echo "ARCH_EXISTS" || echo "NO_ARCH"
```

**If NO_ARCH**:
```
Event model complete, but architecture not defined.

Next step:
  /sdlc:design arch

This will guide you through:
- Technology stack decisions
- Domain boundary definitions
- Integration approaches
- Cross-cutting concerns

The result is docs/ARCHITECTURE.md - the authoritative source for all architecture questions.
```
Then STOP.

### 7. Check for dot Tasks from Slices

```bash
# Check if .dots/ directory exists
test -d .dots || echo "NO_DOTS"

# Check if any slices exist
SLICE_COUNT=$(find docs/event_model/workflows/*/slices/*.md 2>/dev/null | wc -l)

# Check for tasks (look for epic tasks created from workflows)
if [ -d .dots ]; then
  TASK_COUNT=$(dot ls --json 2>/dev/null | jq 'length' 2>/dev/null || echo "0")
else
  TASK_COUNT="0"
fi

echo "SLICES:$SLICE_COUNT"
echo "TASKS:$TASK_COUNT"
```

**If NO_DOTS**:
```
dot CLI not initialized.

Next step:
  /sdlc:setup

This will initialize task management for the project.
```
Then STOP.

**If SLICES > 0 and TASKS == 0**:
```
Event model and architecture complete, but no tasks created.

Next step:
  /sdlc:plan

This will create:
- Epic tasks for each workflow
- Story tasks for each slice
- Acceptance criteria from GWT scenarios
```
Then STOP.

### 8. Check for In-Progress Work

```bash
# Check current branch
BRANCH=$(git branch --show-current)

# Check for active tasks
if [ -d .dots ]; then
  ACTIVE_TASKS=$(dot ls --status active --json 2>/dev/null)
  ACTIVE_COUNT=$(echo "$ACTIVE_TASKS" | jq 'length' 2>/dev/null || echo "0")
fi
```

**If on a feature branch** (not main/master):
```
Currently on branch: <branch>

To check status:
  git status
  gh pr status

To continue working:
  (Just start coding - TDD hooks will guide you)

To create/update PR:
  /sdlc:pr

After PR merges:
  /sdlc:complete

To handle review feedback:
  /sdlc:review
```
Then STOP.

**If active tasks exist**:
```
You have active tasks:

<list tasks from ACTIVE_TASKS>

To continue working on one:
  /sdlc:work <task-id>

Or let me pick the next ready task:
  /sdlc:work
```
Then STOP.

### 9. Default - Ready for New Work

```
Project fully configured and up to date.

To start new work:
  /sdlc:work

This will show ready items from your project board.
```
