---
name: complete
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Mark task complete after PR merge. Use when PR merged or when user asks to close/complete task.
tags:
  - workflow
  - task-management
portability: tool-specific
dependencies:
  - github-issues
allowed-tools: Bash, Read
---

# Complete Skill

**Version:** 1.1.0
**Portability:** Tool-specific (requires dot CLI, gh CLI)

---

## Quick Start

Close task in under 1 minute.

### What This Does
Marks task complete, verifies PR merged, evaluates parent task completion.

### Fastest Path
```bash
/sdlc:complete <task-id>
# Verifies PR merged
# Marks task complete
# Checks if parent can complete
# Cleans up worktree (if applicable)
```

---

## Common Examples

### Example 1: Single Task
**After:** PR merged
**Invoke:** `/sdlc:complete myproject-feature-abc123`
**Result:** Task marked complete

### Example 2: Child Task (Parent Evaluation)
**After:** Child task PR merged
**Invoke:** `/sdlc:complete myproject-child-abc`
**Result:** Checks if all siblings complete → parent completes

---

## When to Use

**Use when:**
- PR merged
- Task finished
- User asks to "complete" or "close task"

**Don't use when:**
- PR not merged yet
- Work still in progress

**Related:**
- `/sdlc:pr` - Create PR first
- `/sdlc:work` - Start next task

---

## Metadata

**Version:** 1.1.0 (2026-02-05): Progressive disclosure
**Dependencies:** github-issues
