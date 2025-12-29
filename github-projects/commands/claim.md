---
name: claim
description: Assign an issue to yourself and move to In Progress
argument-hint: "<issue-number>"
allowed-tools:
  - Bash
  - AskUserQuestion
---

# Claim Issue

Assign an issue to yourself and move it to "In Progress" status in one command.

## Command

```bash
gh project-ext claim <issue-number>
```

## Arguments

- `<issue-number>` - The issue number to claim (e.g., 42)

## What This Does

1. Moves the issue to "In progress" status
2. Assigns the current GitHub user to the issue
3. Prompts to create a linked development branch

## Usage Example

```bash
gh project-ext claim 42
```

Output:
```
Claimed #42 (assigned to jwilger, moved to In Progress)

Create linked development branch? [y/N]
```

## Branch Creation

If you answer "y" to the branch prompt:

- If `gh-issue-ext` is installed: Uses `gh issue-ext branch create`
- Otherwise: Falls back to `gh issue develop --checkout`

The branch will be named based on the issue (e.g., `42-issue-title` or `feature/42-description`).

## Complete Workflow

```bash
# See what's ready to work on
gh project-ext ready

# Claim highest priority item
gh project-ext claim 42

# Accept branch creation prompt
# Start coding on the new branch
```

## Integration with github-issues

For best experience, install the github-issues plugin and gh-issue-ext:

```bash
gh extension install jwilger/gh-issue-ext
```

This enables linked branch creation with proper GitHub issue linking.

## Prerequisites

Ensure gh-project-ext is configured:
```bash
gh project-ext setup
```
