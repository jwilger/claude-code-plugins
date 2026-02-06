---
name: task-management
version: 2.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: dot CLI patterns for local task management with parent-child hierarchies and dependencies
tags:
  - tasks
  - dot-cli
  - task-management
  - dependencies
portability: tool-specific
dependencies: []
---

# Task Management with dot CLI

**Version:** 2.0.0
**Portability:** Tool-Specific (requires dot CLI)

---

## Current Task State

!`dot ls --status active 2>/dev/null || echo "No active tasks (dot CLI not available or no tasks)"`

## Objective

Teaches effective local task management using the `dot` CLI for file-based, hierarchical task tracking with dependency management.

**Purpose:** Manage tasks locally with parent-child relationships, blocking dependencies, and status tracking using simple CLI commands and markdown files.

**Scope:**
- **Included:** dot CLI command patterns, parent-child hierarchies, task dependencies, status management, task queries
- **Excluded:** GitHub Issues/Projects, remote task syncing, team collaboration features

**Tool Requirements:**
- dot CLI (v0.6.4+): https://github.com/ajeetdsouza/dot

---

## Core Principles

### Principle 1: File-Based Storage

**The Principle:** Tasks are stored as markdown files in `.dots/` directory, making them greppable, version-controllable, and human-readable.

**Why this matters:** File-based storage works offline, integrates with git, and allows direct editing when needed.

**How to apply:**
- Tasks are stored in `.dots/<task-id>.md`
- Task metadata is in YAML frontmatter
- Task descriptions are markdown content
- The entire `.dots/` directory can be committed to version control

**Example:**
```bash
# List .dots/ files
ls .dots/

# Output:
# myproject-add-login-abc123.md
# myproject-fix-validation-def456.md
# epic-authentication-ghi789.md
```

### Principle 2: Parent-Child Hierarchies

**The Principle:** Use parent-child relationships to model epics → stories → subtasks, enabling top-down task breakdown.

**Why this matters:** Complex features need breakdown into manageable pieces. Parent-child relationships preserve context and show progress.

**How to apply:**
```bash
# Create parent (epic)
EPIC_ID=$(dot add "Epic: User Authentication" -p 1 | grep -oP 'Created task: \K[^\s]+')

# Create children with -P flag
dot add "Implement login form" -P "$EPIC_ID" -p 2
dot add "Add password validation" -P "$EPIC_ID" -p 2
dot add "Create authentication endpoint" -P "$EPIC_ID" -p 2

# View hierarchy
dot tree "$EPIC_ID"
```

**Benefits:**
- Clear feature decomposition
- Progress tracking at multiple levels
- Context preservation
- Natural prioritization (finish children to complete parent)

### Principle 3: Task IDs as Branch Names

**The Principle:** Use full task IDs (prefix-slug-hash) as git branch names for automatic traceability.

**Why this matters:** Branch names containing task IDs enable automatic task lookup from git context without manual linking.

**How to apply:**
```bash
# Create task
TASK_ID=$(dot add "Add login form" | grep -oP 'Created task: \K[^\s]+')
# Output: myproject-add-login-abc123

# Create branch with task ID
git checkout -b "feature/$TASK_ID"

# Later, extract task ID from branch
BRANCH=$(git branch --show-current)
TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')

# Get task details
dot show "$TASK_ID"
```

**Benefits:**
- Automatic task-branch linkage
- No separate tracking needed
- Easy context recovery
- Works with PRs and code review

### Principle 4: Status Lifecycle

**The Principle:** Tasks progress through a strict lifecycle: `open` → `active` → `closed`.

**Why this matters:** Clear status transitions prevent confusion about what's ready, in-progress, or complete.

**Status meanings:**
- **open**: Ready to work on (if not blocked)
- **active**: Work has begun
- **closed**: Completed

**How to apply:**
```bash
# Check status
dot show "$TASK_ID" --json | jq -r '.status'

# Start work (open → active)
dot on "$TASK_ID"

# Complete work (active → closed)
dot off "$TASK_ID" -r "Completed via PR #123"
```

---

## Constraints and Boundaries

### DO:
- Use `dot add -P <parent>` to create child tasks
- Use `dot add -a <blocker>` to create dependencies
- Use full task IDs in git branch names
- Query with `dot ready` to find unblocked tasks
- Use `dot tree` to visualize hierarchies
- Commit .dots/ directory to version control
- Use task descriptions for acceptance criteria

### DON'T:
- Mix task management tools (pick dot OR GitHub Issues, not both)
- Manually edit .dots/ files (use dot commands)
- Create circular dependencies (A blocks B blocks A)
- Skip status transitions (open → closed without active)
- Ignore blocked tasks (check `dot ready` not just `dot ls`)
- Use issue numbers in branches (use full task IDs)

**Rationale:** Consistent patterns make automation possible and reduce cognitive overhead.

---

## Usage Patterns

### Pattern 1: Epic-Story Breakdown

**Scenario:** Breaking a large feature into trackable stories.

**Approach:**

**Step 1: Create epic**
```bash
dot add "Epic: User Authentication" \
  -p 1 \
  -d "Complete authentication system with login, registration, and password reset"

# Output: Created task: myproject-epic-user-authentication-abc123
EPIC_ID="myproject-epic-user-authentication-abc123"
```

**Step 2: Create stories as children**
```bash
dot add "Implement login form" \
  -P "$EPIC_ID" \
  -p 2 \
  -d "Create login UI with email and password fields"

dot add "Add authentication API" \
  -P "$EPIC_ID" \
  -p 2 \
  -d "Implement /api/auth/login endpoint"

dot add "Add session management" \
  -P "$EPIC_ID" \
  -p 2 \
  -d "Store and validate user sessions"
```

**Step 3: View hierarchy**
```bash
dot tree "$EPIC_ID"

# Output:
# myproject-epic-user-authentication-abc123 (open)
# ├── myproject-implement-login-form-def456 (open)
# ├── myproject-add-authentication-api-ghi789 (open)
# └── myproject-add-session-management-jkl012 (open)
```

**Benefits:**
- Clear feature scope
- Independent story development
- Progress visibility
- Automatic epic completion when all children done

### Pattern 2: Dependency Management

**Scenario:** Task B depends on Task A being complete first.

**Approach:**

**Create tasks with dependencies:**
```bash
# Create blocker task
dot add "Create database schema" -p 1
# Output: myproject-create-database-schema-abc123

# Create dependent task (blocked by first)
dot add "Implement user repository" \
  -a myproject-create-database-schema-abc123 \
  -p 2 \
  -d "Database access layer for users (requires schema)"
```

**Query ready tasks (unblocked only):**
```bash
dot ready

# Output shows only unblocked tasks
# Will NOT show "Implement user repository" until schema task is closed
```

**Check what blocks a task:**
```bash
dot show myproject-implement-user-repository-def456

# Output includes:
# blocked_by: [myproject-create-database-schema-abc123]
```

**Complete blocker to unblock dependent:**
```bash
dot off myproject-create-database-schema-abc123 -r "Schema migration complete"

# Now "Implement user repository" appears in dot ready
```

**Benefits:**
- Prevents starting blocked work
- Clear dependency visualization
- Automatic ready-state calculation
- No manual dependency tracking

### Pattern 3: Branch-Based Workflow

**Scenario:** Starting work on a task with automatic branch naming.

**Approach:**

**Select task and start:**
```bash
# Find ready tasks
dot ready --json

# Start work on selected task
TASK_ID="myproject-add-login-form-abc123"
dot on "$TASK_ID"

# Create branch with task ID
git checkout -b "feature/$TASK_ID"
```

**During development:**
```bash
# Get task details from branch
BRANCH=$(git branch --show-current)
TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')

dot show "$TASK_ID"
```

**On PR creation:**
```bash
# Include task ID in PR body
gh pr create \
  --title "Add login form" \
  --body "Task: $TASK_ID

## Changes
- Added login form component
- Added form validation

Related task: $TASK_ID"
```

**After PR merge:**
```bash
# Close task
dot off "$TASK_ID" -r "Completed via PR #123"
```

**Benefits:**
- Automatic task-branch linkage
- No manual tracking required
- Easy context recovery
- Clear completion audit trail

### Pattern 4: Querying and Filtering

**Scenario:** Finding the right task to work on.

**Approach:**

**View all tasks:**
```bash
dot ls --json | jq '.[] | {id, title, status}'
```

**View only ready tasks (unblocked, open):**
```bash
dot ready
```

**View active tasks:**
```bash
dot ls --status active
```

**View by priority:**
```bash
dot ls --json | jq 'sort_by(.priority) | .[] | {priority, title}'
```

**Search by title:**
```bash
dot ls --json | jq '.[] | select(.title | contains("login"))'
```

**View children of a parent:**
```bash
dot tree "$EPIC_ID" --json
```

---

## Integration with Other Skills

**Works well with:**
- **git-spice:** Use task IDs in stacked branches
- **tdd-constraints:** Create sub-tasks for each TDD phase (red, domain, green)
- **orchestration-protocol:** Use dot tasks as work queue for agents

**Prerequisites:**
- dot CLI installed (https://github.com/ajeetdsouza/dot)
- Initialized `.dots/` directory (`dot init`)

---

## Common Pitfalls

### Pitfall 1: Not Using Parent-Child Relationships

**Problem:** Creating flat list of tasks instead of hierarchical breakdown

**Solution:** Use `-P` flag for children:
```bash
# ❌ Bad: Flat structure
dot add "Epic: Auth"
dot add "Login form"
dot add "API endpoint"

# ✓ Good: Hierarchical
EPIC=$(dot add "Epic: Auth" | grep -oP 'Created task: \K[^\s]+')
dot add "Login form" -P "$EPIC"
dot add "API endpoint" -P "$EPIC"
```

### Pitfall 2: Skipping Dependency Declaration

**Problem:** Not declaring blocking relationships, leading to starting blocked work

**Solution:** Use `-a` flag:
```bash
# ✓ Declare dependency upfront
dot add "Implement repository" \
  -a myproject-create-schema-abc123
```

### Pitfall 3: Using Issue Numbers in Branches

**Problem:** Branch name `feature/123` loses context outside GitHub

**Solution:** Use full task ID:
```bash
# ❌ Bad
git checkout -b feature/123

# ✓ Good
git checkout -b feature/myproject-add-login-abc123
```

### Pitfall 4: Not Checking `dot ready`

**Problem:** Using `dot ls` and accidentally starting blocked tasks

**Solution:** Always use `dot ready` to see only unblocked work:
```bash
# ❌ Shows all open tasks (including blocked)
dot ls --status open

# ✓ Shows only unblocked tasks
dot ready
```

---

## Examples

### Example 1: Event Modeling Workflow

**Scenario:** Creating tasks from event model slices.

**Epic Creation:**
```bash
# Create epic for workflow
dot add "Epic: User Registration Workflow" \
  -p 1 \
  -d "Complete user registration with email verification"

# Output: myproject-epic-user-registration-workflow-abc123
EPIC_ID="myproject-epic-user-registration-workflow-abc123"
```

**Story Creation from Slices:**
```bash
# Slice 1: Command pattern
dot add "User submits registration form" \
  -P "$EPIC_ID" \
  -p 2 \
  -d "## Slice: SubmitRegistration
**Pattern**: Command

### Acceptance Criteria
- [ ] **Given**: Unregistered user
- [ ] **When**: Submit valid registration form
- [ ] **Then**: User account created pending verification"

# Slice 2: View pattern
dot add "Display email verification prompt" \
  -P "$EPIC_ID" \
  -p 2 \
  -d "## Slice: EmailVerificationPrompt
**Pattern**: View

### Acceptance Criteria
- [ ] **Given**: Registration submitted
- [ ] **When**: User views confirmation page
- [ ] **Then**: Instructions shown to check email"

# Slice 3: Automation pattern
dot add "Send verification email" \
  -P "$EPIC_ID" \
  -p 2 \
  -d "## Slice: SendVerificationEmail
**Pattern**: Automation

### Acceptance Criteria
- [ ] **Given**: User account created
- [ ] **When**: Registration event fires
- [ ] **Then**: Verification email sent with token"
```

**Add Dependencies:**
```bash
# Verification prompt depends on registration command
dot add "Display email verification prompt" \
  -a myproject-user-submits-registration-form-def456

# Email automation depends on registration command
dot add "Send verification email" \
  -a myproject-user-submits-registration-form-def456
```

**View Ready Work:**
```bash
dot ready

# Output:
# myproject-user-submits-registration-form-def456 - User submits registration form [P2]
# (Other two slices not shown - they're blocked)
```

### Example 2: Task Completion with Parent Closure

**Scenario:** Completing all children and closing the epic.

**Check Hierarchy:**
```bash
dot tree "$EPIC_ID"

# Output:
# myproject-epic-user-authentication-abc123 (active)
# ├── myproject-implement-login-form-def456 (closed)
# ├── myproject-add-authentication-api-ghi789 (active)
# └── myproject-add-session-management-jkl012 (closed)
```

**Complete Last Child:**
```bash
dot off myproject-add-authentication-api-ghi789 -r "Completed via PR #125"
```

**Check If Parent Should Close:**
```bash
# Get children of epic
CHILDREN=$(dot tree "$EPIC_ID" --json | jq -r '.children[] | .id + " " + .status')

# Count incomplete
INCOMPLETE=$(echo "$CHILDREN" | grep -v "closed" | wc -l)

if [ "$INCOMPLETE" -eq 0 ]; then
  echo "All children complete - ready to close epic"
  dot off "$EPIC_ID" -r "All child tasks completed"
fi
```

---

## Command Reference

### Task Creation
```bash
dot add "Task title" [-p priority] [-d description] [-P parent-id] [-a blocker-id]
```

### Status Management
```bash
dot on <task-id>          # Mark active
dot off <task-id> -r "reason"  # Mark closed
```

### Querying
```bash
dot ls                    # All tasks
dot ls --status <status>  # Filter by status
dot ready                 # Ready tasks (unblocked, open)
dot show <task-id>        # Task details
dot tree <task-id>        # Hierarchy view
```

### Filters
```bash
--status open|active|closed
--json                    # JSON output
```

---

## Verification Checklist

Use this checklist to verify you're using dot CLI effectively:

- [ ] Installed dot CLI (`dot --version`)
- [ ] Initialized project (`dot init`, `.dots/` exists)
- [ ] Using parent-child hierarchies for epics/stories
- [ ] Declaring blocking dependencies with `-a`
- [ ] Using `dot ready` to find unblocked work
- [ ] Using full task IDs in git branch names
- [ ] Closing tasks with completion reasons
- [ ] Committing `.dots/` to version control
- [ ] Using `dot tree` to visualize progress

---

## References

**Source Documentation:**
- sdlc plugin v5.0.0
- dot CLI: https://github.com/ajeetdsouza/dot

**Related Skills:**
- git-spice - Task IDs in stacked branches
- orchestration-protocol - dot tasks as work queue
- event-modeling - Creating tasks from slices

---

## Version History

### v2.0.0 (2026-02-04)
- **BREAKING**: Complete rewrite for dot CLI (replacing GitHub Issues)
- File-based task storage in `.dots/`
- Parent-child hierarchies with `-P` flag
- Blocking dependencies with `-a` flag
- Status lifecycle: open → active → closed
- Task IDs as branch names pattern
- Local-first, offline-capable

### v1.0.0 (2026-02-04)
- Initial version for GitHub Issues
- (Deprecated - see v2.0.0)

---

## Metadata

**Extraction Source:** sdlc v5.0.0 migration from GitHub Issues to dot CLI
**Last Updated:** 2026-02-04
**Compatibility:** Tool-specific (requires dot CLI v0.6.4+)
**License:** MIT
