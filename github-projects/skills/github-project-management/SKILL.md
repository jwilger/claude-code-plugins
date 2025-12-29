---
name: GitHub Project Management
description: |
  This skill should be used when the user asks about "github project", "kanban board",
  "project board", "move issue to", "claim issue", "ready items", "in progress",
  "board status", "priority swimlanes", "project workflow", or needs help managing
  work items across Status columns and Priority levels. Provides comprehensive knowledge
  for managing GitHub Projects V2 Kanban boards using the gh CLI and gh-project-ext extension.

  Trigger phrases: "show project board", "what's ready to work on", "move to in progress",
  "claim this issue", "project status", "kanban view", "board overview", "priority queue",
  "project-ext", "gh project"
version: 1.0.0
---

# GitHub Project Management

## Overview

This skill teaches comprehensive GitHub Projects V2 management using the `gh` CLI and the
`gh-project-ext` extension. It covers Kanban-style board management with Status columns
(Backlog, Ready, In progress, In review, Done) and Priority swimlanes (P0, P1, P2).

## Prerequisites

Before using project management features, ensure the `gh-project-ext` extension is installed:

```bash
gh extension install jwilger/gh-project-ext
```

Verify installation and configure default project:
```bash
gh project-ext setup
```

The `project` scope is required for the GitHub token:
```bash
gh auth refresh -s project
```

## Permission Configuration

Add these patterns to Claude Code settings for auto-approval:

```
Bash(gh project:*)
Bash(gh project-ext:*)
```

This grants access to all project management operations without requiring per-command approval.

---

## Core Concepts

### Board Structure

GitHub Projects V2 boards organize work using:

- **Status Field** (columns): Backlog → Ready → In progress → In review → Done
- **Priority Field** (swimlanes): P0 (critical), P1 (high), P2 (normal)
- **Repository Scope**: Items can come from multiple repositories
- **Parent/Child Filtering**: Top-level items vs. sub-issues

### Configuration File

The extension uses a `.github-project` config file (in repo root or `~/.config/gh-project-ext/config`):

```yaml
owner: jwilger
project: 11
```

---

## Viewing Work

### Show Ready Items

List items in "Ready" status, sorted by priority:

```bash
# Current repo, top-level items only (default)
gh project-ext ready

# Include sub-issues
gh project-ext ready --all

# Include all repositories
gh project-ext ready --all-repos

# JSON output for processing
gh project-ext ready --json
```

### Show Board Overview

Display a text-based Kanban board:

```bash
# Default view (current repo, top-level items)
gh project-ext board

# Full board with all items and repos
gh project-ext board --all --all-repos
```

Output shows items grouped by Status column and Priority:
```
[Ready] (5)
  P0:
    #42: Critical security fix
  P1:
    #45: Important feature
  P2:
    #50: Nice to have
```

### Show Project Structure

Display project metadata and field definitions:

```bash
gh project-ext show
```

This shows Status options, Priority options, and their IDs (useful for debugging).

---

## Managing Work

### Moving Items

Change an item's status column:

```bash
# Move to specific status
gh project-ext move 42 "In progress"
gh project-ext move 42 "In review"
gh project-ext move 42 "Done"
```

Valid status values: `Backlog`, `Ready`, `In progress`, `In review`, `Done`

The extension resolves status names to their internal IDs automatically.

### Claiming Issues

Assign an issue to yourself and move to In Progress in one command:

```bash
gh project-ext claim 42
```

This command:
1. Moves the issue to "In progress" status
2. Assigns the current user to the issue
3. Prompts to create a linked development branch (uses gh-issue-ext if available)

### Workflow Example

Typical workflow for picking up work:

```bash
# See what's ready
gh project-ext ready

# Claim an item
gh project-ext claim 42

# When ready for review
gh project-ext move 42 "In review"

# When complete
gh project-ext move 42 "Done"
```

---

## Native gh project Commands

The extension builds on native `gh project` commands. For advanced operations:

### Listing Items

```bash
# List all project items
gh project item-list 11 --owner jwilger --format json

# With limit
gh project item-list 11 --owner jwilger --limit 100 --format json
```

### Adding Items

```bash
# Add an issue to the project
gh project item-add 11 --owner jwilger --url https://github.com/owner/repo/issues/42
```

### Viewing Fields

```bash
# List project fields and their options
gh project field-list 11 --owner jwilger --format json
```

### Editing Items (Native)

The native `item-edit` requires field and option IDs:

```bash
# Complex native syntax (gh-project-ext handles this automatically)
gh project item-edit --id PVTI_xxx --field-id PVTSSF_xxx \
  --single-select-option-id abc123 --project-id PVT_xxx
```

Use `gh-project-ext` commands instead for simpler status updates.

---

## Filtering Strategies

### Top-Level Items Only (Default)

By default, commands filter to items without a parent issue. This matches the typical
Kanban view configuration of `no:parent-issue`.

Override with `--all` to include sub-issues.

### Current Repository Only (Default)

Commands filter to items from the current git repository by default.

Override with `--all-repos` to see items from all repositories in the project.

### Combining Filters

```bash
# All items from all repos (full board view)
gh project-ext board --all --all-repos

# Just current repo but including sub-issues
gh project-ext ready --all
```

---

## Integration with github-issues Plugin

This plugin integrates with the github-issues plugin for comprehensive issue management:

### Sub-Issues and Hierarchies

Use `gh-issue-ext` for parent/child relationships:
```bash
gh issue-ext sub add 100 101    # Add #101 as sub-issue of #100
gh issue-ext sub list 100       # List sub-issues
```

### Linked Branches

When claiming an issue, the extension prompts to create a linked branch:
```bash
gh issue-ext branch create 42   # Create linked dev branch
```

### Blocking Relationships

Track dependencies between issues:
```bash
gh issue-ext blocking add 20 19  # #20 blocked by #19
```

See the github-issues plugin skill for comprehensive sub-issue and blocking workflows.

---

## Troubleshooting

### "Missing project scope"
```bash
gh auth refresh -s project
```

### "Project not configured"
Run setup to configure default project:
```bash
gh project-ext setup
```

### "Issue not found in project"
Ensure the issue has been added to the project:
```bash
gh project item-add 11 --owner jwilger --url https://github.com/owner/repo/issues/42
```

### "Invalid status"
Status names are case-sensitive. Valid options:
- `Backlog`
- `Ready`
- `In progress`
- `In review`
- `Done`

---

## Best Practices

1. **Start each session** with `gh project-ext ready` to see available work
2. **Claim before starting** - Use `claim` to signal work has begun
3. **Move promptly** - Update status as work progresses
4. **Use branches** - Accept the branch creation prompt for traceability
5. **Filter appropriately** - Use `--all` and `--all-repos` flags as needed
6. **Review regularly** - Use `board` command for overall project health

---

## Reference Files

For detailed command reference and advanced usage:
- `references/gh-project-commands.md` - Native gh project CLI commands
- `references/workflow-patterns.md` - Common workflow patterns
