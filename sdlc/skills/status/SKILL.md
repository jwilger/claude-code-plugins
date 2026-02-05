---
name: status
version: 1.1.0
disable-model-invocation: true
author: jwilger
repository: jwilger/claude-code-plugins
description: Show complete SDLC project state including config, branch, task, TDD cycle, and recent activity. Use when user asks "where am I?" or "what's the status?".
tags:
  - workflow
  - status
  - context
  - navigation
portability: tool-specific
dependencies:
  - orchestration-protocol
allowed-tools: Bash, Read, Glob
---

# Status Skill

**Version:** 1.0.0
**Portability:** Tool-specific (requires gh CLI, dot CLI, git)

---

## Quick Start

Get complete project status in under 10 seconds.

### What This Does
Shows comprehensive view of: configuration, current branch/task, TDD cycle state, PR status, and next steps.

### Fastest Path
```bash
/sdlc:status

# Output:
# ✅ Configuration: Event Modeling mode
# 🌿 Branch: feature/myproject-add-auth-abc123
# 📋 Task: myproject-add-auth-abc123 (In Progress)
# 🧪 TDD Cycle: GREEN phase (in progress)
# 🔀 PR: Not created yet
# ⏭️  Next: Complete implementation, then /sdlc:pr
```

---

## Current Context

!`bash -c "echo '**Working Directory:** ' && pwd"`!

!`bash -c "echo '**Git Status:** ' && git status -s 2>/dev/null | head -5 || echo 'No git repo'"`!

---

## Common Examples

### Example 1: Mid-Implementation
**When:** Working on feature, want quick status check
**Invoke:** `/sdlc:status`
**Result:** Shows branch, task, TDD phase, suggests next action

### Example 2: After Break
**When:** Returning after hours/days, need context
**Invoke:** `/sdlc:status`
**Result:** Full context: what you were working on, where you left off

### Example 3: Before PR
**When:** Ready to create PR, want pre-flight check
**Invoke:** `/sdlc:status`
**Result:** Shows commits ready, suggests `/sdlc:pr`

---

## When to Use

**Use when:**
- Starting new session (need context)
- Mid-work status check
- Unsure what to do next
- User asks "where am I?" or "what's the status?"

**Don't use when:**
- Project not set up (run `/sdlc:setup` first)
- Need to take action (use workflow skills directly)

**Related:**
- `/sdlc:start` - Smart routing based on status
- `/sdlc:work` - Start/continue work
- `/sdlc:pr` - Create pull request

---

## Auto-Invocation

Claude automatically invokes this skill when you say:
- "What's the current status?"
- "Where am I in the workflow?"
- "Show me the project state"
- "What am I working on?"
- "Give me a status report"

You don't need to type `/sdlc:status` explicitly - Claude will detect these requests and invoke the skill for you.

---

## Status Display Format

The status output shows:

### 1. Configuration Status
- ✅ Configured: Shows workflow mode (Event Modeling / Traditional)
- ❌ Not configured: Suggests `/sdlc:setup`

### 2. Branch & Task
- Current git branch
- Associated task ID and title
- Task status (Pending / In Progress / Completed)
- Worktree location (if using worktrees)

### 3. TDD Cycle State
- ✅ Red: Test written
- ✅ Domain: Types reviewed
- 🔄 Green: Implementation in progress
- ⏳ Blocked: Waiting for domain review

### 4. PR Status
- No PR: Will be created when ready
- PR #123: Link and review status
- Review comments: Count if any

### 5. Next Steps
- Suggested next action based on current state
- Link to relevant skill

### 6. Recent Activity
- Last 3 commits (timestamp + message)
- Recent agent invocations
- Time since last change

---

## Implementation Details

This skill:
- Reads git state (branch, commits, status)
- Checks dot task state for current work
- Analyzes task list for TDD cycle phase
- Queries gh CLI for PR status
- Reads `.claude/sdlc.yaml` for configuration
- Fast, read-only (no Task tool usage)

**Performance:** < 2 seconds typical response time

---

## Metadata

**Version:** 1.0.0 (2026-02-05): Initial release
**Dependencies:** orchestration-protocol
**Portability:** Tool-specific (gh, dot, git required)
