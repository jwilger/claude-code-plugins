---
name: design
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Event Modeling facilitation for domain discovery, workflow design, GWT scenarios, architecture decisions, and design systems. Use for event-sourced system design.
tags:
  - event-modeling
  - domain-discovery
  - workflow-design
  - architecture
  - design-system
portability: tool-specific
dependencies:
  - event-modeling
  - atomic-design
  - orchestration-protocol
  - user-input-protocol
allowed-tools: Bash, Read, Write, Task, AskUserQuestion, Grep
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Before completing, store event model discoveries in auto memory:
            - Domain concepts discovered
            - Events, commands, and views identified
            - GWT scenarios created
            - Any deferred questions or open items

            Output ONLY: {"ok": true}
---

# Design Skill

**Version:** 1.0.0
**Portability:** Tool-specific (requires event modeling agents)

---

## Objective

Facilitate Event Modeling workflow: domain discovery → workflow design → GWT scenarios → architecture decisions → design system.

**Purpose:** Guide teams through structured domain understanding before implementation.

**Scope:**
- **Included:** Domain discovery, workflow design, GWT generation, model validation, architecture ADRs, design system creation
- **Excluded:** Implementation (use TDD workflow), task creation (use plan skill)

---

## Core Principles

### Principle 1: Domain Understanding Before Tech Decisions

Event modeling is about understanding the business domain. NO architecture or technical decisions during modeling (except mandatory integrations).

### Principle 2: Progressive Phases

Discovery → Workflows → GWT → Validation → Architecture → Design System

Each phase builds on previous.

### Principle 3: Agent Delegation

All design work delegated to specialized agents via Task tool.

---

## Usage Patterns

### Arguments

- `discover` - Domain discovery
- `workflow <name>` - Design workflow
- `gwt <workflow-name>` - Generate GWT scenarios
- `validate` - Validate event model
- `arch` - Architecture decisions
- `design-system` - Create/update design system
- (no args) - Resume where left off

### Standard Invocations

**Discovery:**
```bash
/design discover
# Delegates to sdlc:discovery agent
```

**Workflow Design:**
```bash
/design workflow user-registration
# Delegates to sdlc:workflow-designer agent
```

**GWT Scenarios:**
```bash
/design gwt user-registration
# Delegates to sdlc:gwt agent
```

**Architecture:**
```bash
/design arch
# Delegates to sdlc:design-facilitator agent
```

**Design System:**
```bash
/design design-system
# Delegates to sdlc:ux agent
```

---

## Integration

**Works well with:**
- event-modeling (core methodology)
- atomic-design (design system structure)
- user-input-protocol (agent checkpoints)

**Prerequisites:**
- `.claude/sdlc.yaml` with `mode: event-modeling`
- `docs/event_model/` directory structure

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- Agent delegation pattern
- Progressive phase enforcement

---

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:design command
