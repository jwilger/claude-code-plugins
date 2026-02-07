---
name: task-management
description: >
  Local task management using the dot CLI with file-based markdown storage,
  parent-child hierarchies, and blocking dependencies. Use when managing tasks,
  creating stories or epics, tracking work items, breaking down features, writing
  acceptance criteria, or querying task status. Triggers on: "create a task",
  "add a story", "break down this feature", "what's ready to work on",
  "show task status", "dot add", "dot ls", "dot ready", "dot tree", or any
  reference to the dot CLI or .dots/ directory.
allowed-tools: Bash(dot *)
---

# Task Management with dot CLI

!`dot ls --status active 2>/dev/null || echo "No active tasks (dot CLI not available or no tasks)"`

## Core Concept: Tasks Are Markdown Files

Tasks are stored as markdown files in `.dots/`. Each file has YAML frontmatter
(title, status, priority, issue-type) and a **markdown body that IS the task
description**. This means rich, multi-line acceptance criteria belong in the file
body — not crammed into a `-d` flag.

**File format:**
```markdown
---
title: Implement user registration
status: open
priority: 2
issue-type: task
created-at: 2026-02-06T10:00:00Z
---

## Context

Users need to create accounts to access the application.

## Acceptance Criteria

- [ ] Registration form accepts email, password, and display name
- [ ] Password must be >= 12 characters with complexity requirements
- [ ] Email verification sent on successful registration
- [ ] Duplicate email returns clear error message

## Done Criteria

- All acceptance criteria checked off
- Unit and integration tests passing
- PR reviewed and merged
```

**File locations:**
- Top-level tasks: `.dots/<id>/<id>.md`
- Child tasks: `.dots/<parent-id>/<child-id>.md`

**IDs** follow the format `<prefix>-<slug>-<hash>` where prefix comes from
`.dots/config`.

## Workflow: Creating Tasks with Rich Descriptions

### Step 1: Create the task

```bash
dot add "Implement user registration" -p 2
# Output: Created task: myapp-implement-user-registration-a1b2c3
```

The `-d` flag works for short descriptions, but for anything beyond a sentence,
edit the file directly.

### Step 2: Add rich acceptance criteria

Open `.dots/myapp-implement-user-registration-a1b2c3/myapp-implement-user-registration-a1b2c3.md`
and add structured content after the frontmatter:

```markdown
## Context

[Why this task exists, background, links to designs]

## Acceptance Criteria

- [ ] [Specific, testable criterion]
- [ ] [Another criterion]

## Done Criteria

- [What "done" means beyond acceptance criteria]

## Notes

- [Implementation hints, constraints, edge cases]
```

### Step 3: Read task context before starting work

```bash
dot show <task-id>          # Prints full file content
```

Or read the `.md` file directly for the complete markdown.

## Parent-Child Hierarchies

Model epics, stories, and subtasks with parent-child relationships.

```bash
# Create parent (epic)
EPIC_ID=$(dot add "Epic: User Authentication" -p 1 | grep -oP 'Created task: \K[^\s]+')

# Create children
dot add "Implement login form" -P "$EPIC_ID" -p 2
dot add "Add password validation" -P "$EPIC_ID" -p 2
dot add "Create auth endpoint" -P "$EPIC_ID" -p 2

# View hierarchy
dot tree "$EPIC_ID"
```

Children are stored as files inside the parent's directory:
```
.dots/myapp-epic-user-authentication-x1y2z3/
├── myapp-epic-user-authentication-x1y2z3.md          # Parent
├── myapp-implement-login-form-a1b2c3.md               # Child
├── myapp-add-password-validation-d4e5f6.md            # Child
└── myapp-create-auth-endpoint-g7h8i9.md               # Child
```

## Blocking Dependencies

Declare that task B cannot start until task A is done:

```bash
# Create blocker
dot add "Create database schema" -p 1
# Output: myapp-create-database-schema-abc123

# Create dependent task (blocked by schema)
dot add "Implement user repository" -a myapp-create-database-schema-abc123 -p 2
```

**Always use `dot ready`** to find unblocked work — `dot ls` shows everything
including blocked tasks.

```bash
dot ready              # Only unblocked, open tasks
dot ready --json       # JSON output for scripting
```

## Status Lifecycle

Tasks progress: **open** → **active** → **closed**

```bash
dot on <task-id>                    # Start work (open → active)
dot off <task-id> -r "reason"       # Complete (→ closed)
```

Always provide a close reason with `-r` for audit trail.

**Close tasks on the feature branch.** When a task is done, close it and commit
the `.dots/` changes on the feature branch *before* creating the PR. This way,
when the PR merges, main reflects the task as completed.

```bash
dot off <task-id> -r "Completed"
git add .dots/
git commit -m "chore: close task <task-id>"
# Then create PR — task closure is included
```

## Searching

```bash
dot find "query"       # Searches titles, descriptions, and close-reasons
dot ls --json          # Full JSON for custom filtering
```

## Command Reference

| Command | Purpose | Key Flags |
|---------|---------|-----------|
| `dot add "title"` | Create task | `-p` priority, `-d` description, `-P` parent, `-a` blocker |
| `dot ls` | List tasks | `--status open\|active\|closed`, `--json` |
| `dot ready` | Unblocked open tasks | `--json` |
| `dot show <id>` | Full task details | `--json` |
| `dot tree <id>` | Hierarchy view | `--json` |
| `dot on <id>` | Start work (→ active) | |
| `dot off <id>` | Close task | `-r "reason"` (required) |
| `dot rm <id>` | Delete task | |
| `dot find "query"` | Search tasks | Searches titles, descriptions, close-reasons |
| `dot fix` | Repair broken state | |
| `dot purge` | Remove closed tasks | |
| `dot init` | Initialize .dots/ | |

### Frontmatter Fields

| Field | Values | Notes |
|-------|--------|-------|
| `title` | string | Set by `dot add` |
| `status` | `open`, `active`, `closed` | Managed by `dot on`/`dot off` |
| `priority` | integer (1=highest) | Set with `-p` |
| `issue-type` | `task`, `epic`, etc. | Optional |
| `created-at` | ISO 8601 timestamp | Auto-set |
| `closed-at` | ISO 8601 timestamp | Auto-set on close |
| `close-reason` | string | Set with `-r` |

## Constraints

**DO:**
- Edit task `.md` files directly for rich acceptance criteria
- Use `dot ready` (not `dot ls`) to find next work
- Use `-P` for parent-child and `-a` for blocking dependencies
- Use full task IDs in git branch names for traceability
- Provide close reasons with `-r`
- Close tasks on the feature branch and commit `.dots/` changes before creating the PR
- Track `.dots/` in version control so task state lands on main with PRs

**DON'T:**
- Skip `dot ready` — `dot ls` shows blocked tasks too
- Create circular dependencies
- Use short IDs or issue numbers in branch names
- Close tasks after PR merge — close them before so `.dots/` changes are in the PR

## Detailed Examples

For extended workflow examples including event modeling task creation,
branch-based workflows, dependency chains, and epic completion scripts,
see [references/examples.md](references/examples.md).
