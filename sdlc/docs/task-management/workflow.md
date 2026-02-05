# Task Management Workflows

## Standard Workflow

### 1. Create Tasks

**From Event Model Slices:**
```bash
/sdlc:plan
# Creates epic + story tasks from workflow slices
```

**Manual Creation:**
```bash
dot add "Task title" -p 2 -d "Description"
```

### 2. Start Work

```bash
/sdlc:work
# Shows ready tasks, marks selected as active, creates branch
```

### 3. Develop

TDD cycle with hooks enforcement:
- Write failing test (sdlc:red agent)
- Review types (sdlc:domain agent)
- Implement (sdlc:green agent)
- Review implementation (sdlc:domain agent)

**With Session Task Tracking (v7.0.0):**

If `features.session_task_tracking: true`, TaskTools provides "what's next?" visibility:

```
## Current Session State

Story: myproject-add-login-abc123 - Add user login form
Worktree: ../myproject-worktrees/myproject-add-login-abc123

### Active TDD Cycle

✅ Red: Write test for login validation
✅ Domain (after red): Review test and create types
🔄 Green: Implement login validation
⏳ Domain (after green): Review implementation

### What's Next?

You are in GREEN phase.
Implement minimal code to make test pass. Run tests after each change.
When test passes, domain review will automatically run.
```

The orchestrator creates TDD cycle tasks on-demand (when you start implementing) and displays session state after each phase completion.

### 4. Create PR

```bash
/sdlc:pr
# Creates PR referencing task
```

### 5. Complete Task

```bash
# After PR merges:
/sdlc:complete
# Verifies PR merged, closes task, checks parent
```

## Event Modeling Workflow

```bash
# 1. Domain Discovery
/sdlc:design discover

# 2. Design Workflow
/sdlc:design workflow "User Registration"

# 3. Generate GWT Scenarios
/sdlc:design gwt "User Registration"

# 4. Architecture Decisions
/sdlc:design arch

# 5. Create Tasks from Slices
/sdlc:plan
# Creates:
#   - Epic (parent task for workflow)
#   - Stories (child tasks for each slice)

# 6. Work on Stories
/sdlc:work
# Select story, create branch, implement
```

## Parallel Development (Worktrees)

```bash
# Enable in .claude/sdlc.yaml:
git:
  worktrees: true

# Start first task
/sdlc:work myproject-task-one-abc123
# Creates: ../myproject-worktrees/myproject-task-one-abc123/

# In separate terminal, start second task
cd /path/to/main/project
/sdlc:work myproject-task-two-def456
# Creates: ../myproject-worktrees/myproject-task-two-def456/

# Each gets isolated workspace
```

## Epic Completion Pattern

```bash
# Check epic progress
dot tree <epic-id>

# Complete last child
/sdlc:complete <last-child-id>
# Prompts: "All children complete. Close parent?"

# Close epic
# (Handled by /sdlc:complete prompt)
```

## Dependency Workflow

```bash
# Create blocker
dot add "Create database schema" -p 1
# Returns: myproject-create-schema-abc123

# Create dependent (blocked by first)
dot add "Implement repository" \
  -a myproject-create-schema-abc123 \
  -p 2

# Check ready tasks (dependent won't appear until blocker closes)
dot ready

# Complete blocker
dot off myproject-create-schema-abc123 -r "Schema complete"

# Now dependent appears in ready
dot ready  # Shows myproject-implement-repository-def456
```

## Task Queries

```bash
# All tasks
dot ls

# By status
dot ls --status open
dot ls --status active
dot ls --status closed

# Ready (unblocked + open)
dot ready

# Hierarchy
dot tree <epic-id>

# JSON for scripts
dot ls --json | jq -r '.[].title'
dot ready --json | jq -r '.[].id'
```

## Integration with Git

```bash
# Task → Branch
TASK_ID="myproject-add-login-abc123"
dot on "$TASK_ID"
git checkout -b "feature/$TASK_ID"

# Branch → Task
BRANCH=$(git branch --show-current)
TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')
dot show "$TASK_ID"

# PR → Task
gh pr create --body "Task: $TASK_ID ..."

# Merge → Complete
/sdlc:complete  # Auto-detects from branch
```

## Best Practices

1. **Use dot ready**, not `dot ls --status open` (respects blockers)
2. **Full task IDs in branches** (`feature/<task-id>`)
3. **Close with reasons** (`dot off <id> -r "Completed via PR #123"`)
4. **Hierarchical breakdown** (epic → stories → subtasks)
5. **Declare dependencies upfront** (`-a` flag on create)
6. **Commit .dots/** to version control (or add to .gitignore)

## See Also

- **Command Reference**: `dot-cli.md`
- **Full Guide**: `sdlc/skills/task-management/SKILL.md`
- **Migration**: `../MIGRATION.md`
