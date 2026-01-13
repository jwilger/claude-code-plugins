---
description: INVOKE when designing event-sourced systems. Defines 4 patterns and workflow rules
user-invocable: false
---

# Event Sourcing Development Process

Follow Martin Dilger's "Understanding Eventsourcing" methodology.

## Core Principles (Always Enforce)

- Events are immutable facts in **past tense** using **business language**
- "Not losing information" is foundational - store what happened, not just current state
- Every Read Model attribute must trace back to an event (information completeness)

## The Four Patterns

1. **State Change:** Command → Event (only way to modify state)
2. **State View:** Events → Read Model (query stored events)
3. **Automation:** Event → Process → Command → Event (background work)
4. **Translation:** External data → Internal event (anti-corruption layer)

## Event Model ↔ Work Tracking Mapping (NON-NEGOTIABLE)

| Dilger Concept | GitHub Equivalent |
|----------------|-------------------|
| Workflow | Epic (parent issue) |
| Vertical Slice | Story Issue (1:1) |
| GWT Scenarios | Acceptance Criteria |
| Chapter/Theme | Epic |

**One vertical slice = One story issue.** No exceptions.

## Artifacts Location

`docs/event_model/` in project directory

## When to Use `/sdlc:design`

- Starting a new project or feature
- Designing workflows with event modeling
- Creating GWT scenarios for acceptance criteria

## Three Perspectives for Story Review

1. **sdlc:story**: Business value, slice thinness
2. **sdlc:architect**: Technical feasibility, complexity, risks
3. **sdlc:ux**: User journey coherence, accessibility
