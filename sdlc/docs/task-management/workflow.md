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

### 4. Create PR

```bash
/sdlc:pr
# Closes the task, commits .dots/ changes, creates PR
# When PR merges, main reflects the task as completed
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

# Complete last child (via /sdlc:pr or /sdlc:complete)
# Both commands check parent completion and prompt:
# "All children complete. Close parent?"

# Parent closure is committed on the branch with .dots/ changes
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

# Close task → Commit .dots/ → Create PR
dot off "$TASK_ID" -r "Completed"
git add .dots/ && git commit -m "chore: close task $TASK_ID"
gh pr create --body "Task: $TASK_ID ..."

# When PR merges, main reflects task as closed
```

## Best Practices

1. **Use dot ready**, not `dot ls --status open` (respects blockers)
2. **Full task IDs in branches** (`feature/<task-id>`)
3. **Close tasks on the feature branch** so `.dots/` changes are part of the PR
4. **Close with reasons** (`dot off <id> -r "Completed"`)
5. **Hierarchical breakdown** (epic → stories → subtasks)
6. **Declare dependencies upfront** (`-a` flag on create)
7. **Commit .dots/** to version control (track task state in the repo)

## See Also

- **Command Reference**: `dot-cli.md`
- **Full Guide**: `sdlc/skills/task-management/SKILL.md`
- **Migration**: `../MIGRATION.md`
