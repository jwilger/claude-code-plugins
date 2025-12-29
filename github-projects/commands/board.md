---
name: board
description: Show Kanban board overview with items grouped by status and priority
argument-hint: "[--all] [--all-repos]"
allowed-tools:
  - Bash
---

# Show Project Board

Display a text-based Kanban board showing items grouped by Status columns and Priority.

## Command

```bash
gh project-ext board
```

## Options

- `--all` - Include sub-issues (default: top-level items only)
- `--all-repos` - Include items from all repositories (default: current repo only)
- `--json` - Output as JSON for processing

## Usage Examples

```bash
# Default board (current repo, top-level items)
gh project-ext board

# Full board with all items
gh project-ext board --all --all-repos

# JSON output
gh project-ext board --json
```

## Output Format

The board displays items grouped by status column, with priority sub-groups:

```
[Backlog] (5)
  P0:
    #42: Critical item
  P1:
    #43: Important item

[Ready] (3)
  P0:
    #44: Ready P0 item
  P2:
    #45: Normal priority

[In progress] (2)
  P1:
    #46: Currently working

[In review] (1)
  P2:
    #47: Awaiting review

[Done] (10)
  ...
```

## Prerequisites

Ensure gh-project-ext is configured:
```bash
gh project-ext setup
```
