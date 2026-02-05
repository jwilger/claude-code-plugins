---
name: complete
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Mark task complete after PR merge. Verifies merge, closes task, checks parent completion, cleans up worktree registration. Use after PR merges.
tags:
  - workflow
  - task-management
  - completion
portability: tool-specific
dependencies:
  - memory-protocol
allowed-tools: Bash, Read, AskUserQuestion
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            SDLC CONFIG CHECK (runs once per session)

            Verify .claude/sdlc.yaml and .dots/ exist.
            If missing, tell user to run /setup first.

            Respond with: {"ok": true}
---

# Complete Skill

**Version:** 1.0.0
**Portability:** Tool-specific (requires gh CLI, dot CLI)

---

## Objective

Mark task complete after PR merge, with verification and parent task checking.

**Purpose:** Manual completion ensures PR was merged (not just closed) and triggers parent task evaluation.

**Scope:**
- **Included:** PR merge verification, task closure, parent checking, worktree cleanup
- **Excluded:** PR merging (manual), task creation

---

## Core Principles

### Principle 1: Verify Merge, Not Just Close

Check PR state is "merged", not just "closed".

### Principle 2: Parent Task Evaluation

If all sibling tasks complete, offer to close parent epic.

### Principle 3: Worktree Registration Cleanup (v7.0.0)

Remove `.dots/.worktrees/<task-id>` registry when task completes.

---

## Usage Pattern

**From Feature Branch:**
```bash
/complete  # Auto-detects task from branch
```

**Explicit Task ID:**
```bash
/complete myproject-add-login-abc123
```

**Steps:**
1. Determine task ID (from args or branch)
2. Verify PR was merged
3. Close task with `dot off <task-id>`
4. Check parent task children status
5. If all children done, offer to close parent
6. Clean up worktree registration
7. Store completion in auto memory

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- PR merge verification
- Parent task evaluation
- Worktree cleanup

---

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:complete command
