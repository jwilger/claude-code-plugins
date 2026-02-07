# Task Management Examples

## Table of Contents

- [Event Modeling Workflow](#event-modeling-workflow)
- [Branch-Based Workflow](#branch-based-workflow)
- [Dependency Chains](#dependency-chains)
- [Epic Completion](#epic-completion)
- [Rich Acceptance Criteria Patterns](#rich-acceptance-criteria-patterns)
- [Querying and Filtering](#querying-and-filtering)

## Event Modeling Workflow

Creating tasks from event model slices with structured acceptance criteria.

### Create epic and stories

```bash
EPIC_ID=$(dot add "Epic: User Registration Workflow" -p 1 | grep -oP 'Created task: \K[^\s]+')

# Slice 1: Command pattern
S1_ID=$(dot add "User submits registration form" -P "$EPIC_ID" -p 2 | grep -oP 'Created task: \K[^\s]+')

# Slice 2: View pattern
S2_ID=$(dot add "Display email verification prompt" -P "$EPIC_ID" -p 2 | grep -oP 'Created task: \K[^\s]+')

# Slice 3: Automation pattern
S3_ID=$(dot add "Send verification email" -P "$EPIC_ID" -p 2 | grep -oP 'Created task: \K[^\s]+')
```

### Add rich acceptance criteria by editing the files

Edit `.dots/$EPIC_ID/$S1_ID.md` to add:

```markdown
## Slice: SubmitRegistration

**Pattern**: Command

### Acceptance Criteria

- [ ] **Given** an unregistered user
  **When** they submit a valid registration form
  **Then** a user account is created with status "pending_verification"

- [ ] **Given** an unregistered user
  **When** they submit a form with an already-registered email
  **Then** a clear error message is displayed without revealing account existence

### Done Criteria

- Command handler tested with unit tests
- Integration test covers happy path and duplicate email
- Event published to message bus
```

### Add dependencies between slices

```bash
# View and email both depend on registration command
dot add "Display email verification prompt" -a "$S1_ID"
dot add "Send verification email" -a "$S1_ID"
```

### Check ready work

```bash
dot ready
# Only shows "User submits registration form" — other two are blocked
```

## Branch-Based Workflow

Using task IDs as git branch names for traceability.

```bash
# Find ready tasks
dot ready

# Start work
TASK_ID="myapp-add-login-form-abc123"
dot on "$TASK_ID"
git checkout -b "feature/$TASK_ID"

# During development — recover context from branch
BRANCH=$(git branch --show-current)
TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')
dot show "$TASK_ID"

# Close task and commit .dots/ changes on the feature branch
dot off "$TASK_ID" -r "Completed"
git add .dots/
git commit -m "chore: close task $TASK_ID"

# Create PR (includes task closure)
gh pr create \
  --title "Add login form" \
  --body "Task: $TASK_ID

## Changes
- Added login form component
- Added form validation"

# When PR merges, main reflects task as closed
```

## Dependency Chains

Modeling sequential work where each step depends on the previous.

```bash
# Step 1: Schema (no dependencies)
dot add "Create database schema" -p 1
# → myapp-create-database-schema-abc123

# Step 2: Repository (blocked by schema)
dot add "Implement user repository" \
  -a myapp-create-database-schema-abc123 -p 2

# Step 3: Service (blocked by repository)
dot add "Implement user service" \
  -a myapp-implement-user-repository-def456 -p 2

# Step 4: API (blocked by service)
dot add "Create user API endpoint" \
  -a myapp-implement-user-service-ghi789 -p 2

# Only schema task shows in dot ready
dot ready
```

## Epic Completion

Checking if all children are done and closing the parent.

```bash
# Check hierarchy
dot tree "$EPIC_ID"
# myapp-epic-user-auth-abc123 (active)
# ├── myapp-implement-login-def456 (closed)
# ├── myapp-add-auth-api-ghi789 (active)    ← last one
# └── myapp-add-sessions-jkl012 (closed)

# Complete last child (on its feature branch, before PR)
dot off myapp-add-auth-api-ghi789 -r "Completed"

# Check if parent should close
CHILDREN=$(dot tree "$EPIC_ID" --json | jq -r '.children[] | .status')
INCOMPLETE=$(echo "$CHILDREN" | grep -cv "closed")

if [ "$INCOMPLETE" -eq 0 ]; then
  dot off "$EPIC_ID" -r "All child tasks completed"
fi
```

## Rich Acceptance Criteria Patterns

### Command/Write Slice

```markdown
## Context

Part of the User Registration workflow (Event Model slice 1).
Handles the SubmitRegistration command.

## Acceptance Criteria

- [ ] **Given** valid registration data (email, password, display name)
  **When** SubmitRegistration command is processed
  **Then** UserRegistered event is stored with all fields

- [ ] **Given** a password shorter than 12 characters
  **When** SubmitRegistration command is processed
  **Then** command is rejected with validation error

- [ ] **Given** an email that already exists in the read model
  **When** SubmitRegistration command is processed
  **Then** command is rejected with DuplicateEmail error

## Technical Notes

- Use CQRS command handler pattern
- Validate against read model, not event store
- Password hashing happens in the command handler, not the domain
```

### View/Read Slice

```markdown
## Context

Dashboard view showing user's recent activity.
Read model built from UserLoggedIn and PageViewed events.

## Acceptance Criteria

- [ ] Displays last 10 login timestamps
- [ ] Shows most-viewed pages in descending order
- [ ] Updates within 5 seconds of new events
- [ ] Shows empty state message for new users

## Done Criteria

- Read model projection tested with event fixtures
- Component renders correctly with 0, 1, and 10+ items
- Loading and error states handled
```

### Bug Fix

```markdown
## Context

Users report that dates display incorrectly when timezone
is not UTC. Root cause: `toLocaleDateString()` called without
locale parameter.

## Acceptance Criteria

- [ ] Dates display correctly in US Eastern timezone
- [ ] Dates display correctly in UTC+12
- [ ] Dates display correctly in UTC-12
- [ ] Existing date formatting in other views is not affected

## Reproduction Steps

1. Set system timezone to America/New_York
2. Navigate to /reports
3. Observe dates show previous day for evening events
```

## Querying and Filtering

### JSON output for scripting

```bash
# All tasks as JSON
dot ls --json | jq '.[] | {id, title, status}'

# Ready tasks as JSON
dot ready --json

# Tasks by priority
dot ls --json | jq 'sort_by(.priority) | .[] | {priority, title}'

# Search by title
dot ls --json | jq '.[] | select(.title | contains("login"))'

# Children of a parent
dot tree "$EPIC_ID" --json
```
