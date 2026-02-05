# dot CLI Quick Reference

For comprehensive documentation, see: `sdlc/skills/task-management/SKILL.md`

## Installation

```bash
cargo install dot-cli
dot --version  # Verify >= 0.6.4
```

## Essential Commands

```bash
# Create task
dot add "Task title" [-p priority] [-d description] [-P parent-id] [-a blocker-id]

# Start work
dot on <task-id>

# Complete work
dot off <task-id> -r "reason"

# List all tasks
dot ls [--status open|active|closed] [--json]

# Show ready tasks (unblocked, open)
dot ready [--json]

# Show task details
dot show <task-id> [--json]

# Show hierarchy
dot tree <task-id> [--json]
```

## Task ID Format

```
<prefix>-<slug>-<hash>
myproject-add-login-abc123
```

## Status Lifecycle

```
open → active → closed
```

## Branch Integration

```bash
# Create branch with task ID
git checkout -b "feature/<task-id>"

# Extract task ID from branch
TASK_ID=$(git branch --show-current | sed 's/^feature\///')
```

## See Also

- **Comprehensive Guide**: `sdlc/skills/task-management/SKILL.md`
- **Workflows**: `workflow.md`
- **Migration**: `../MIGRATION.md`
