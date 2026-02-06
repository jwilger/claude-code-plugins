---
name: plan
version: 2.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Convert event model slices to development tasks (dots) with dependencies. Use after Event Modeling to create implementation plan.
tags:
  - workflow
  - planning
  - dot-cli
  - event-modeling
portability: tool-specific
dependencies:
  - event-modeling
  - dot-cli
allowed-tools: Bash, Read, Grep
---

# Plan Skill

**Version:** 2.0.0
**Portability:** Tool-specific (requires dot CLI)

---

## Quick Start

Create development tasks from event model in under 5 minutes.

### What This Does
Reads event model slices and creates development tasks (dots) with proper dependencies.

### Fastest Path
1. Complete Event Modeling (`/sdlc:specify`)
2. Run `/sdlc:plan`
3. Creates dots for each slice
4. Sets up dependency graph (`-a` flag)
5. Ready for `/sdlc:work`

### Basic Example
```bash
/sdlc:plan

# Reads: docs/event_model/workflows/*/slices/*.md
#
# Creates dots:
# myproject-user-registration-slice1 (priority 1)
# myproject-user-registration-slice2 (priority 2, after slice1)
# myproject-user-registration-slice3 (priority 3, after slice2)
#
# Output:
# ✓ Created 12 dots
# ✓ Dependencies configured
# Ready: dot ready (or /sdlc:work)
```

---

## Common Examples

### Example 1: Full Event Model
**When:** Complete event model, need tasks
**Invoke:** `/sdlc:plan`
**Result:** All slices → dots with dependencies

### Example 2: Single Workflow
**When:** One workflow designed
**Invoke:** `/sdlc:plan <workflow-name>`
**Result:** Dots for that workflow only

---

## When to Use

**Use when:**
- Event model complete
- Need implementation tasks
- User asks to "create tasks" or "plan work"

**Don't use when:**
- No event model (run `/sdlc:specify` first)
- Tasks already exist (check with `dot ls`)
- Not using Event Modeling (create dots manually with `dot add`)

**Related:**
- `/sdlc:specify` - Create event model
- `/sdlc:work` - Start implementation
- `dot ready` - See unblocked tasks

---

## Auto-Invocation

Claude automatically invokes this skill when you say:
- "Create tasks from the event model"
- "Let's plan the implementation"
- "Create the development plan"
- "Convert workflows to tasks"
- "I'm ready to create dots"

You don't need to type `/sdlc:plan` explicitly - Claude will detect these requests and invoke the skill for you.

---

## Metadata

**Version:** 2.0.0 (2026-02-05): Use dot CLI instead of GitHub issues
**Dependencies:** event-modeling, dot-cli
**Portability:** Tool-specific (dot required)
