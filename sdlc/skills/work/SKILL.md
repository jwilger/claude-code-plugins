---
name: work
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Start or continue work on an issue. Shows ready tasks, creates branch, marks task active. Use when beginning work, switching tasks, or when user asks to start development.
tags:
  - workflow
  - tdd
  - github
  - task-management
  - git-workflow
portability: tool-specific
dependencies:
  - tdd-constraints
  - github-issues
  - orchestration-protocol
  - memory-protocol
allowed-tools: Bash, Read, AskUserQuestion, Grep, TaskCreate, TaskUpdate
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            SDLC CONFIG CHECK (runs once per session)

            Verify .claude/sdlc.yaml exists before proceeding.
            If it doesn't exist, stop and tell user to run /sdlc:setup first.

            Respond with: {"ok": true}
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Before completing, store the current work context in auto memory:
            - Issue being worked on
            - Branch name
            - Any decisions or discoveries made

            Output ONLY: {"ok": true}
---

# Work Skill

**Version:** 1.1.0
**Portability:** Tool-specific (requires gh CLI, dot CLI, git)

---

## Quick Start

Start working on a task in under 2 minutes.

### What This Does
Helps you select and begin work on a task, creating the proper git branch/worktree and marking the task as active.

### Fastest Path
1. Ensure clean git state (no uncommitted changes)
2. Run `/sdlc:work`
3. Select task from list (or provide task ID)
4. Start implementing with TDD cycle

### Basic Example
```bash
# In project directory
/sdlc:work

# Output shows:
# "Ready tasks:
#   1. myproject-add-search-def456 - Add search feature [P1]
#   2. myproject-fix-bug-ghi789 - Fix login bug [P2]
#
# Select task (1-2) or enter ID:"

# After selection:
# ✓ Task marked active
# ✓ Branch created: feature/myproject-add-search-def456
#
# Acceptance Criteria:
# - User can search by keyword
# - Results display in <200ms
#
# Next: Start TDD cycle with /sdlc:red
```

---

## Common Examples

### Example 1: Starting First Task
**When:** Clean project, ready to begin implementation
**Invoke:** `/sdlc:work`
**Result:** Shows ready tasks, creates branch, displays acceptance criteria

### Example 2: Continuing Active Work
**When:** Returning after break, have active task
**Invoke:** `/sdlc:work`
**Result:** Detects current work, offers to continue or switch

### Example 3: Switching Tasks
**When:** Need to work on higher-priority task
**Invoke:** `/sdlc:work` → select different task
**Result:** Switches branch (after confirming current work committed)

### Example 4: Worktree Mode
**When:** `git.worktrees: true` in config
**Invoke:** `/sdlc:work`
**Result:** Creates worktree in `../worktrees/<task-id>`, isolates work

### Example 5: Child Task Priority
**When:** Active parent has child tasks
**Invoke:** `/sdlc:work`
**Result:** Shows children first (scoped work completes parents)

---

## When to Use

**Use this skill when:**
- Starting work on a new task
- Returning to work after a break
- Switching between tasks
- User asks "what should I work on next?"

**Don't use when:**
- No tasks exist yet (use `/sdlc:plan` to create tasks first)
- Need to create PR (use `/sdlc:pr` after work complete)
- Addressing PR feedback (use `/sdlc:review` instead)
- Project not set up (run `/sdlc:setup` first)

**Related skills:**
- `/sdlc:plan` - Create tasks from event model
- `/sdlc:pr` - Create pull request
- `/sdlc:review` - Address PR feedback
- `/sdlc:complete` - Mark task done

---

## Before You Start

**MANDATORY:** Search auto memory for relevant work context.

```bash
MEMORY_PATH="$HOME/.claude/projects/$(pwd | sed 's/\//-/g' | sed 's/^-//')/memory"
find "$MEMORY_PATH" -name "*.md" -mtime -30 2>/dev/null | \
  xargs grep -l -i "current work\|in progress" 2>/dev/null | \
  head -5
```

Displays relevant patterns from past work sessions.

---

## Reference

For detailed information:
- [Principles](./reference/principles.md) - Clean state, task hierarchy, worktrees, context assembly
- [Constraints](./reference/constraints.md) - DO/DON'T rules, integration points, error handling
- [Examples](./reference/examples.md) - Comprehensive scenarios with commands

---

## Metadata

**Version History:**
- v1.1.0 (2026-02-05): Progressive disclosure restructure, memory search integration
- v1.0.0: Initial extraction from sdlc plugin v8.0.0

**Dependencies:** tdd-constraints, github-issues, orchestration-protocol, memory-protocol
**Portability:** Tool-specific (gh, dot, git required)
