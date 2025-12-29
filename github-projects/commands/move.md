---
name: move
description: Move an issue to a different status column
argument-hint: "<issue-number> <status>"
allowed-tools:
  - Bash
---

# Move Issue Status

Change an item's status column on the project board.

## Command

```bash
gh project-ext move <issue-number> <status>
```

## Arguments

- `<issue-number>` - The issue number to move (e.g., 42)
- `<status>` - Target status (case-sensitive)

## Valid Status Values

- `Backlog` - Not yet ready for work
- `Ready` - Groomed and ready to be picked up
- `In progress` - Currently being worked on
- `In review` - PR created, awaiting review
- `Done` - Completed

## Usage Examples

```bash
# Move issue to In Progress
gh project-ext move 42 "In progress"

# Move to review
gh project-ext move 42 "In review"

# Mark as done
gh project-ext move 42 "Done"

# Move back to Ready (work paused)
gh project-ext move 42 "Ready"
```

## Common Workflow

```bash
# Start working
gh project-ext move 42 "In progress"

# Create PR, ready for review
gh project-ext move 42 "In review"

# After merge
gh project-ext move 42 "Done"
```

## Notes

- The extension automatically resolves status names to internal IDs
- Status names are case-sensitive
- Use quotes for statuses with spaces (e.g., "In progress")

## Prerequisites

Ensure gh-project-ext is configured:
```bash
gh project-ext setup
```
