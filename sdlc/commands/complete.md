---
description: Mark a task as complete after PR merge. Closes the task and checks parent completion.
argument-hint: [task-id]
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
  - mcp__memento__create_entities
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
            - PR merged
            - Parent status if applicable

            Output ONLY: {"ok": true}
---

# SDLC Complete

Mark a task as complete after its PR has been merged. This command replaces GitHub's automatic "Closes #123" behavior with an explicit completion step.

## Why Manual Completion?

Unlike GitHub Issues which close automatically via "Closes #123" in PR descriptions, dot tasks require explicit completion. This gives you control to:
1. Verify the PR was actually merged (not just closed)
2. Add a completion note referencing the PR number
3. Check if the parent task should also be closed (all children done?)
4. Update memento with final notes about the work

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

### 2. Verify PR Was Merged

Check that a PR exists for this task and that it was merged (not just closed):

```bash
# Find PR for this branch
PR_NUM=$(gh pr list --head "feature/$TASK_ID" --state merged --json number --jq '.[0].number')

if [ -z "$PR_NUM" ]; then
  # No merged PR found - check if one exists but wasn't merged
  CLOSED_PR=$(gh pr list --head "feature/$TASK_ID" --state closed --json number --jq '.[0].number')

  if [ -n "$CLOSED_PR" ]; then
    echo "⚠️  Warning: PR #$CLOSED_PR for this task was closed without merging"
    echo ""
    # Ask user if they want to complete anyway
    # Use AskUserQuestion
  else
    echo "⚠️  Warning: No PR found for task $TASK_ID"
    echo ""
    # Ask user if they want to complete anyway
  fi
fi
```

Use AskUserQuestion if no merged PR found:

**Question: No merged PR found. Complete task anyway?**
- "Yes, complete the task" - Task can be completed without PR (maybe work was done differently)
- "No, cancel" - Stop without completing

### 3. Get Task Details

```bash
# Get task info
TASK_INFO=$(dot show "$TASK_ID" --json)
TASK_TITLE=$(echo "$TASK_INFO" | jq -r '.title')
PARENT_ID=$(echo "$TASK_INFO" | jq -r '.parent // empty')
```

### 4. Close the Task

```bash
# Close task with reason
if [ -n "$PR_NUM" ]; then
  dot off "$TASK_ID" -r "Completed via PR #$PR_NUM"
else
  dot off "$TASK_ID" -r "Completed manually"
fi
```

### 5. Check Parent Task

If this task has a parent, check if all sibling tasks are now complete:

```bash
if [ -n "$PARENT_ID" ]; then
  # Get all children of parent
  CHILDREN=$(dot tree "$PARENT_ID" --json | jq -r '.children[] | .id + " " + .status')

  # Count how many are still open or active
  INCOMPLETE=$(echo "$CHILDREN" | grep -v "closed" | wc -l)

  if [ "$INCOMPLETE" -eq 0 ]; then
    echo "✅ All child tasks of $PARENT_ID are complete!"
    echo ""
    # Ask if user wants to close parent
  fi
fi
```

If all children are done, use AskUserQuestion:

**Question: All child tasks complete. Close parent task $PARENT_ID?**
- "Yes, close parent task" - Epic is complete, close it
- "No, leave open" - Parent may have additional work or serves as reference

If user chooses "Yes":
```bash
dot off "$PARENT_ID" -r "All child tasks completed"
```

### 6. Store in Memento

```
mcp__memento__create_entities:
  name: "Task Completion: <task-title> [date]"
  entityType: "task_completion"
  observations:
    - "Task: <task-id> - <title>"
    - "Completed via PR #<pr-number>"
    - "Parent: <parent-id if applicable>"
    - "Parent also closed: <yes/no if applicable>"
```

### 7. Clean Up Branch (Optional)

If the PR was merged and branch is no longer needed:

```bash
# Delete local branch (if not currently on it)
if [ "$(git branch --show-current)" != "feature/$TASK_ID" ]; then
  git branch -d "feature/$TASK_ID" 2>/dev/null || echo "Branch already deleted or still checked out"
fi

# Note: Remote branch should be auto-deleted by GitHub if configured in /sdlc:setup
```

### 8. Display Result

```
✅ Task completed!

Task: <task-id> - <title>
Status: closed
Completed via: PR #<pr-number>

<if parent was also closed>
Parent task also closed: <parent-id>
</if>

Next:
  - dot ls --status active  # See remaining active tasks
  - dot ready               # See tasks ready to start
  - /sdlc:work              # Start next task
```

## Error Handling

- **No task ID and not on feature branch**: Show usage, suggest providing task ID explicitly
- **Task not found**: Show error with task ID, suggest `dot ls` to see all tasks
- **Task already closed**: Show info about when/how it was closed, ask if user wants to reopen
- **PR not merged but user confirms completion**: Proceed but note in memento that completion was manual
- **Parent closure fails**: Show error but don't roll back child completion

## Example Usage

From a feature branch after PR merge:
```
/sdlc:complete
```

Explicit task ID:
```
/sdlc:complete myproject-add-login-abc123
```

## Integration with Other Commands

- `/sdlc:pr` now includes a reminder to run this command after merge
- `/sdlc:work` can detect completed tasks and won't show them as available
- `/sdlc:start` will suggest this command if there are merged PRs with active tasks
