# Work Skill - Comprehensive Examples

## Example 1: Starting New Work (Clean State)

**Scenario:** User wants to start working on the next ready task.

**Approach:**
1. Check for `.claude/sdlc.yaml`, verify version
2. Verify clean git state and sync with remote
3. Search auto memory for recent work context
4. Fetch ready tasks with `dot ready --json`
5. Fetch active tasks with `dot ls --status active --json`
6. Show options in priority order
7. User selects task (or enters task ID directly)
8. Mark task as `active` with `dot on <task-id>`
9. Create branch or worktree using full task ID
10. Display task details and acceptance criteria

**Commands:**
```bash
# Check config
test -f .claude/sdlc.yaml || echo "Run /sdlc:setup first"

# Verify clean state
git status --porcelain  # Must be empty
git fetch && git pull --ff-only

# Get ready tasks
dot ready --json | jq -r '.[] | "\(.id) - \(.title) [P\(.priority // "")]"'

# User selects: myproject-add-search-def456
dot on myproject-add-search-def456
git checkout -b feature/myproject-add-search-def456
```

## Example 2: Continuing Active Work

**Scenario:** User returns to work after break, has active task.

**Approach:**
1. Check config and git state
2. Detect active tasks
3. Show current branch/worktree status
4. Offer to continue or switch

**Commands:**
```bash
# Detect current work
CURRENT_BRANCH=$(git branch --show-current)
# feature/myproject-add-login-abc123

# Get active tasks
dot ls --status active --json

# Show context
echo "Currently on: myproject-add-login-abc123"
echo "Continue this work? [Y/n]"
```

## Example 3: Worktree Mode

**Scenario:** Worktrees enabled, starting parallel work.

**Approach:**
1. Check for worktree configuration
2. Create worktree in ../worktrees/ directory
3. Register worktree (if coordination enabled)
4. Switch to worktree directory

**Commands:**
```bash
# Check worktree config
grep "worktrees: true" .claude/sdlc.yaml

# Create worktree
TASK_ID="myproject-feature-xyz789"
WORKTREE_PATH="../worktrees/$TASK_ID"
git worktree add "$WORKTREE_PATH" -b "feature/$TASK_ID"

# Register (if coordination enabled)
if grep -q "worktree_coordination: true" .claude/sdlc.yaml; then
  echo "$TASK_ID:$(hostname):$$:$(date +%s)" >> .git/worktree-registry.txt
fi

# Switch to worktree
cd "$WORKTREE_PATH"
```

## Example 4: Task Selection with Children

**Scenario:** Active parent task has child tasks, user should see children first.

**Approach:**
1. Get active tasks
2. For each active task, get children
3. Show children before ready tasks
4. Explain why (scoped work completes parents)

**Commands:**
```bash
# Get active parent tasks
ACTIVE=$(dot ls --status active --json | jq -r '.[].id')

# For each parent, get children
for parent in $ACTIVE; do
  dot tree "$parent" --json | jq -r '.children[]? | "\(.id) - \(.title)"'
done

# Show to user
echo "Active parent: myproject-user-auth-parent123"
echo "  Child tasks (complete these first):"
echo "    1. myproject-user-auth-child-a - Login form"
echo "    2. myproject-user-auth-child-b - JWT tokens"
```

## Example 5: Switching Tasks

**Scenario:** User wants to switch from current task to different one.

**Approach:**
1. Verify current work committed
2. Show available tasks
3. Switch branch/worktree
4. Update task status

**Commands:**
```bash
# Check for uncommitted work
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️ Uncommitted changes. Commit or stash first."
  exit 1
fi

# Show ready tasks
dot ready --json

# Switch (traditional mode)
git checkout main
git checkout -b feature/new-task-id

# Switch (worktree mode)
cd ../worktrees/new-task-id  # If worktree exists
# OR create new worktree
```
