---
name: ready
description: List items in Ready status, sorted by priority (P0 first)
argument-hint: "[--all] [--all-repos]"
allowed-tools:
  - Bash
---

# Show Ready Items

Display items in "Ready" status, sorted by priority for picking up work.

## Command

```bash
gh project-ext ready
```

## Options

- `--all` - Include sub-issues (default: top-level items only)
- `--all-repos` - Include items from all repositories (default: current repo only)
- `--json` - Output as JSON for processing

## Usage Examples

```bash
# Ready items from current repo (default)
gh project-ext ready

# Include sub-issues
gh project-ext ready --all

# All repos, including sub-issues
gh project-ext ready --all --all-repos
```

## Output Format

Items are grouped by priority:

```
Ready Items (5)

=== P0 ===
  #42: Critical security fix
  #43: Urgent bug

=== P1 ===
  #45: Important feature

=== P2 ===
  #50: Nice enhancement
  #51: Documentation update
```

## Typical Workflow

After viewing ready items, claim one to start working:

```bash
gh project-ext ready          # See what's available
gh project-ext claim 42       # Start working on #42
```

## Prerequisites

Ensure gh-project-ext is configured:
```bash
gh project-ext setup
```
