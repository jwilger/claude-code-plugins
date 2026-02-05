---
name: plan
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Convert event model slices to GitHub issues with dependencies. Use after Event Modeling to create implementation tasks.
tags:
  - workflow
  - planning
  - github
  - event-modeling
portability: tool-specific
dependencies:
  - event-modeling
  - github-issues
allowed-tools: Bash, Read, Grep
---

# Plan Skill

**Version:** 1.1.0
**Portability:** Tool-specific (requires gh CLI, dot CLI)

---

## Quick Start

Create tasks from event model in under 5 minutes.

### What This Does
Reads event model slices and creates GitHub issues with proper dependencies.

### Fastest Path
1. Complete Event Modeling (`/sdlc:design`)
2. Run `/sdlc:plan`
3. Creates issues for each slice
4. Sets up dependency graph
5. Ready for `/sdlc:work`

### Basic Example
```bash
/sdlc:plan

# Reads: docs/event_model/workflows/*/slices/*.md
#
# Creates issues:
# - myproject-user-registration-slice1
# - myproject-user-registration-slice2
# - myproject-user-registration-slice3
#
# Sets dependencies (slice2 blocks slice3, etc.)
#
# Output:
# ✓ Created 12 issues
# ✓ Dependencies configured
# Ready: /sdlc:work
```

---

## Common Examples

### Example 1: Full Event Model
**When:** Complete event model, need tasks
**Invoke:** `/sdlc:plan`
**Result:** All slices → issues with dependencies

### Example 2: Single Workflow
**When:** One workflow designed
**Invoke:** `/sdlc:plan <workflow-name>`
**Result:** Issues for that workflow only

---

## When to Use

**Use when:**
- Event model complete
- Need implementation tasks
- User asks to "create tasks" or "plan work"

**Don't use when:**
- No event model (run `/sdlc:design` first)
- Tasks already exist
- Not using Event Modeling (create issues manually)

**Related:**
- `/sdlc:design` - Create event model
- `/sdlc:work` - Start implementation

---

## Auto-Invocation

Claude automatically invokes this skill when you say:
- "Create tasks from the event model"
- "Let's plan the implementation"
- "Generate GitHub issues"
- "Convert workflows to tasks"
- "I'm ready to create tasks"

You don't need to type `/sdlc:plan` explicitly - Claude will detect these requests and invoke the skill for you.

---

## Metadata

**Version:** 1.1.0 (2026-02-05): Progressive disclosure
**Dependencies:** event-modeling, github-issues
**Portability:** Tool-specific (gh, dot required)
