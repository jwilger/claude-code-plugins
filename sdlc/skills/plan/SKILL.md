---
name: plan
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Create dot tasks from event model slices. Maps workflows to epics, slices to stories, GWT to acceptance criteria. Use after event model and architecture complete.
tags:
  - planning
  - task-management
  - event-modeling
portability: tool-specific
dependencies:
  - event-modeling
  - orchestration-protocol
allowed-tools: Bash, Read, Glob, Write, Task, AskUserQuestion, Grep
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            SDLC PLAN PREREQUISITES CHECK

            Before creating tasks, verify:
            1. .claude/sdlc.yaml exists
            2. docs/ARCHITECTURE.md exists
            3. At least one workflow with slices exists

            If ARCHITECTURE.md is missing, stop and direct user to:
              /design arch

            Respond with: {"ok": true}
---

# Plan Skill

**Version:** 1.0.0
**Portability:** Tool-specific (requires dot CLI, event model)

---

## Objective

Create dot tasks from event model slices, mapping workflows to epics and slices to stories.

**Purpose:** Bridge design phase (event model + architecture) to actionable work items.

**Scope:**
- **Included:** Epic/story creation, dependency ordering, GWT as acceptance criteria
- **Excluded:** Event modeling (use design skill), implementation (use work skill)

---

## Core Principles

### Principle 1: NON-NEGOTIABLE Mapping

| Event Model | dot Task |
|-------------|----------|
| Workflow | Epic (parent) |
| Slice | Story (child) |
| GWT Scenarios | Acceptance Criteria |
| Pattern Type | Metadata tag |

### Principle 2: Dependency Ordering

Slice dependencies from event model become task blockers.

### Principle 3: Prerequisites Required

- Event model with slices
- ARCHITECTURE.md (technical context)
- dot CLI initialized

---

## Usage Pattern

**Standard Planning:**

```bash
/plan user-registration
# or
/plan  # Plans all unplanned workflows
```

**Steps:**
1. Verify prerequisites (config, architecture, event model)
2. Find workflows to plan
3. For each workflow:
   - Create epic task (workflow name)
   - For each slice:
     - Create story task (child of epic)
     - Add GWT scenarios as acceptance criteria
     - Add dependencies from slice metadata
4. Display task hierarchy

**Example:**
```bash
# Find workflows
ls -d docs/event_model/workflows/*/

# Create epic
EPIC_ID=$(dot add "Epic: User Registration" \
  --description "User registration workflow from event model" \
  --priority 1)

# Create stories from slices
for slice in docs/event_model/workflows/user-registration/slices/*.md; do
  TITLE=$(grep "^# " "$slice" | head -1 | sed 's/^# //')
  GWT=$(sed -n '/## GWT Scenarios/,/^## /p' "$slice")

  STORY_ID=$(dot add "$TITLE" \
    --description "$GWT" \
    --parent "$EPIC_ID")
done
```

---

## Integration

**Works well with:**
- event-modeling (source of slices)
- work skill (consumes created tasks)

**Prerequisites:**
- Event model complete with GWT scenarios
- ARCHITECTURE.md exists
- dot CLI initialized

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- Epic/story mapping
- GWT as acceptance criteria

---

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:plan command
