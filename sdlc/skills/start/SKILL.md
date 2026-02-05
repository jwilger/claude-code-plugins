---
name: start
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Smart entry point that detects project state and routes to appropriate workflow phase. Use when user asks to "start work", "begin", or wants guidance on next steps.
tags:
  - workflow
  - router
  - onboarding
portability: tool-specific
dependencies:
  - event-modeling
  - orchestration-protocol
allowed-tools: Bash, Read, Glob, AskUserQuestion
---

# Start Skill

**Version:** 1.0.0
**Portability:** Tool-specific (requires SDLC setup)

---

## Objective

Auto-detect current SDLC phase and route to appropriate next step. Acts as smart entry point for users unfamiliar with workflow.

**Purpose:** Reduce cognitive load by analyzing project state and suggesting next action.

**Scope:**
- **Included:** Config detection, version checking, phase detection, routing guidance, worktree orphan detection
- **Excluded:** Actual work execution (delegates to other skills)

---

## Core Principles

### Principle 1: Progressive Workflow Detection

**Detection Order:**
1. No config → `/setup`
2. Config but no domain → `/design discover`
3. Domain but no workflows → `/design workflow`
4. Workflows but no GWT → `/design gwt`
5. GWT but no architecture → `/design arch`
6. Architecture but no tasks → `/plan`
7. Tasks exist, on feature branch → show PR/review options
8. Tasks exist, active tasks → show continue/switch options
9. Tasks exist, on main → `/work`

### Principle 2: Orphaned Worktree Detection (v7.0.0)

Check if user is in a worktree for a completed task and offer cleanup.

### Principle 3: Mode-Specific Guidance

Traditional mode: Show direct work commands
Event modeling mode: Show discovery/design/plan/work progression

---

## Usage Pattern

**Standard Start Invocation:**

1. Check for `.claude/sdlc.yaml`
   - If missing → Direct to `/setup`
2. Load config and check version
   - If version mismatch → Show update warning
3. If worktree coordination enabled → Check for orphaned worktrees
4. Check mode (traditional vs event-modeling)
5. If traditional → Show work/pr/review commands
6. If event-modeling → Detect phase and suggest next step
7. Display appropriate guidance

**Example (Event Modeling, Mid-Workflow):**
```bash
# Check config
test -f .claude/sdlc.yaml  # Exists

# Check for workflows
ls -d docs/event_model/workflows/*/  # Exists

# Check for GWT
grep -q "## GWT Scenarios" docs/event_model/workflows/*/slices/*.md  # Missing

# Result:
# "Workflow 'user-registration' needs GWT scenarios.
#
# Next step:
#   /design gwt user-registration
#
# GWT scenarios define acceptance criteria for each slice."
```

---

## Integration

**Works well with:**
- event-modeling (understands workflow phases)
- All other SDLC skills (routes to them)

**Prerequisites:**
- Git repository

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- Progressive detection
- Worktree orphan detection
- Mode-specific routing

---

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:start command
