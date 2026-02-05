---
name: design
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Event Modeling facilitation for domain discovery, workflow design, GWT scenarios, and architecture decisions. Use for event-sourced system design or when user asks about domain modeling.
tags:
  - event-modeling
  - domain-discovery
  - workflow-design
  - architecture
portability: tool-specific
dependencies:
  - event-modeling
  - orchestration-protocol
  - user-input-protocol
  - memory-protocol
allowed-tools: Bash, Read, Write, Task, AskUserQuestion, Grep
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Before completing, store event model discoveries in auto memory.
            Output ONLY: {"ok": true}
---

# Design Skill (Event Modeling)

**Version:** 1.1.0
**Portability:** Tool-specific

---

## Quick Start

Start Event Modeling in under 5 minutes.

### What This Does
Facilitates Event Modeling workflow: domain discovery → workflow design → GWT scenarios → architecture.

### Fastest Path
1. Run `/sdlc:design discover` - Answer 5 domain questions
2. Run `/sdlc:design workflow <name>` - Design one workflow
3. Run `/sdlc:design gwt <workflow>` - Generate acceptance criteria
4. Ready to plan tasks

### Basic Example
```bash
/sdlc:design discover
# Answers 5 questions:
# 1. What does the business do?
# 2. Who are the actors?
# 3. What are major processes?
# 4. What external systems?
# 5. Which workflow to start with?
#
# Creates: docs/event_model/domain-overview.md

/sdlc:design workflow user-registration
# Interactive 7-step workflow design
# Creates: docs/event_model/workflows/user-registration/

/sdlc:design gwt user-registration
# Generates Given-When-Then scenarios
# Ready for: /sdlc:plan
```

---

## Common Examples

### Example 1: New Project (Full Event Modeling)
**When:** Starting event-sourced system
**Path:** discover → workflow → gwt → validate → arch
**Result:** Complete event model ready for planning

### Example 2: Single Workflow
**When:** Adding feature to existing system
**Path:** workflow <name> → gwt <name>
**Result:** New workflow integrated with existing model

### Example 3: Validating Model
**When:** Event model complete, verify consistency
**Invoke:** `/sdlc:design validate`
**Result:** Checks information flow, GWT coverage

---

## When to Use

**Use this skill when:**
- Starting event-sourced project
- Need domain understanding before coding
- Designing complex workflows
- User asks about "event modeling" or "domain design"

**Don't use when:**
- Simple CRUD features (overkill)
- Domain well-understood (skip to `/sdlc:arch`)
- Ready to implement (use `/sdlc:work`)

**Related skills:**
- `/sdlc:plan` - Convert event model to tasks
- `/sdlc:arch` - Architecture decisions

---

## Subcommands

- `discover` - Domain discovery (5 questions)
- `workflow <name>` - Design workflow
- `gwt <workflow>` - Generate GWT scenarios
- `validate` - Validate event model
- `arch` - Architecture decisions
- `design-system` - UI component system
- (no args) - Resume where left off

---

## Before You Start

**MANDATORY:** Search auto memory for domain patterns.

```bash
MEMORY_PATH="$HOME/.claude/projects/$(pwd | sed 's/\//-/g' | sed 's/^-//')/memory"
find "$MEMORY_PATH" -name "*.md" -type f 2>/dev/null | \
  xargs grep -l -i "domain\|event\|workflow" 2>/dev/null
```

---

## Reference

See SKILL-old.md for:
- Event Modeling methodology
- Agent delegation patterns
- Complete phase descriptions

---

## Metadata

**Version History:**
- v1.1.0 (2026-02-05): Progressive disclosure, memory integration
- v1.0.0: Initial extraction

**Dependencies:** event-modeling, orchestration-protocol, user-input-protocol, memory-protocol
