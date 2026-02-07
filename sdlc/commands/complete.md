---
description: Mark a task as complete. Closes the task and commits .dots/ changes on the current branch.
argument-hint: [task-id]
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            SDLC CONFIG CHECK (runs once per session)

            Verify .claude/sdlc.yaml and .dots/ exist before proceeding.
            If missing, stop and tell user to run /sdlc:setup first.

            Respond with: {"ok": true}
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Store task completion in memento:
            - Task closed
            - Parent status if applicable

            Output ONLY: {"ok": true}
---

# SDLC Complete

Mark a task as complete. Closes the task and commits the `.dots/` changes on the current branch so they can be included in a PR.

## When to Use

- **Before `/sdlc:pr`** — Close the task, then create the PR. The `.dots/` changes travel with the PR and land on main when merged.
- **Without a PR** — For tasks completed without a pull request (config changes, spikes, etc.).
- **Parent closure** — Close a parent/epic task after all children are done.

**Note:** `/sdlc:pr` automatically closes the task as part of its workflow. Use `/sdlc:complete` directly only when you need to close a task independently of PR creation.

## Arguments

`$ARGUMENTS` may contain:
- `<task-id>` - Explicit task ID to complete
- (no args) - Auto-detect from current branch name

## Steps

### 1. Determine Task ID

If task ID provided as argument, use it. Otherwise, extract from current branch:

```bash
BRANCH=$(git branch --show-current)

# Extract task ID from branch name (e.g., feature/myproject-add-login-abc123 → myproject-add-login-abc123)
TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')

# Verify task exists
dot show "$TASK_ID" &>/dev/null || {
  echo "Error: Task $TASK_ID not found"
  echo "Usage: /sdlc:complete [task-id]"
  echo "  or run from a feature branch"
  exit 1
}
```

### 2. Check Task Status

```bash
TASK_INFO=$(dot show "$TASK_ID" --json)
TASK_TITLE=$(echo "$TASK_INFO" | jq -r '.title')
TASK_STATUS=$(echo "$TASK_INFO" | jq -r '.status')
PARENT_ID=$(echo "$TASK_INFO" | jq -r '.parent // empty')
```

If the task is already closed, inform the user and stop.

### 3. Close the Task

```bash
dot off "$TASK_ID" -r "Completed"
```

### 4. Check Parent Task

If this task has a parent, check if all sibling tasks are now complete:

```bash
if [ -n "$PARENT_ID" ]; then
  CHILDREN=$(dot tree "$PARENT_ID" --json | jq -r '.children[] | .status')
  INCOMPLETE=$(echo "$CHILDREN" | grep -cv "closed")

  if [ "$INCOMPLETE" -eq 0 ]; then
    echo "All child tasks of $PARENT_ID are complete!"
  fi
fi
```

If all children are done, use AskUserQuestion:

**Question: All child tasks complete. Close parent task $PARENT_ID?**
- "Yes, close parent task" - Epic is complete, close it
- "No, leave open" - Parent may have additional work

If user chooses "Yes":
```bash
dot off "$PARENT_ID" -r "All child tasks completed"
```

### 5. Commit .dots/ Changes

Stage and commit the `.dots/` changes on the current branch:

```bash
git add .dots/
git commit -m "chore: close task $TASK_ID"
```

This ensures the task closure is part of the branch. When included in a PR and merged, main will reflect the task as closed.

### 6. Display Result

```
Task completed!

Task: <task-id> - <title>
Status: closed

<if parent was also closed>
Parent task also closed: <parent-id>
</if>

The .dots/ changes have been committed on this branch.

Next:
  - /sdlc:pr              # Create PR (includes task closure)
  - dot ready             # See tasks ready to start
  - /sdlc:work            # Start next task
```

## Error Handling

- **No task ID and not on feature branch**: Show usage, suggest providing task ID explicitly
- **Task not found**: Show error with task ID, suggest `dot ls` to see all tasks
- **Task already closed**: Show info about when/how it was closed
- **Parent closure fails**: Show error but don't roll back child completion
