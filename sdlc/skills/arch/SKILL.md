---
name: arch
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Architecture change workflow with ADR-formatted commit messages. Use when making architectural decisions, updating ARCHITECTURE.md, or when user asks to document design choices.
tags:
  - architecture
  - adr
  - decision-records
  - git-workflow
portability: universal
dependencies:
  - user-input-protocol
  - memory-protocol
---

# Architecture Change Workflow

**Version:** 1.1.0
**Portability:** Universal

---

## Quick Start

Document an architecture decision in under 10 minutes.

### What This Does
Guides you through architecture decision-making, updates ARCHITECTURE.md, and commits with ADR-formatted message.

### Fastest Path
1. Run `/sdlc:arch`
2. Describe decision context
3. Edit ARCHITECTURE.md to reflect new architecture
4. Commit with generated ADR message
5. Create architecture-only PR

### Basic Example
```bash
/sdlc:arch

# Prompts for:
# - What decision are you making?
# - What options did you consider?
# - Why did you choose this option?
#
# Then:
# - Edits docs/ARCHITECTURE.md
# - Creates commit with ADR format:
#
#   feat(arch): adopt event sourcing
#
#   ## Context and Problem
#   [Your context]
#
#   ## Decision
#   [Your choice]
#
#   ## Rationale
#   [Why]
#
# Creates PR (architecture-only, skips code review)
```

---

## Common Examples

### Example 1: New Architecture Decision
**When:** Choosing between architectural approaches
**Invoke:** `/sdlc:arch`
**Result:** Conversation-guided decision, ARCHITECTURE.md updated, ADR commit

### Example 2: Updating Existing Architecture
**When:** Evolving architecture based on learning
**Invoke:** `/sdlc:arch`
**Result:** Edit ARCHITECTURE.md, commit explains what changed and why

### Example 3: Documenting Implicit Architecture
**When:** Team used pattern but never documented it
**Invoke:** `/sdlc:arch`
**Result:** Codifies existing architecture in ARCHITECTURE.md

---

## When to Use

**Use this skill when:**
- Making architecture decisions
- Choosing between design patterns
- Updating system architecture
- User asks to "document architecture" or "make architectural decision"

**Don't use when:**
- Creating initial ARCHITECTURE.md (use `/sdlc:design arch` instead)
- Implementing features (architecture documents, doesn't implement)
- Need event modeling (use `/sdlc:design` first)

**Related skills:**
- `/sdlc:design arch` - Initial architecture creation with Event Modeling
- `/sdlc:work` - Implementation follows architecture

---

## Core Principles

**Architecture as Living Document:**
- ARCHITECTURE.md is single source of truth
- Edit directly (not generated from ADR files)
- Decision rationale in commit message (ADR format)

**Commit Isolation:**
- Architecture commits touch ONLY ARCHITECTURE.md
- Implementation commits never touch ARCHITECTURE.md
- Separate branches for architecture vs implementation

**ADR Format in Commit Message:**
```
feat(arch): [short title]

## Context and Problem
[What situation prompted this decision?]

## Decision
[What approach did you choose?]

## Rationale
[Why this choice over alternatives?]

## Consequences
[What are the implications?]
```

---

## Before You Start

**MANDATORY:** Search auto memory for past architecture decisions.

```bash
MEMORY_PATH="$HOME/.claude/projects/$(pwd | sed 's/\//-/g' | sed 's/^-//')/memory"
find "$MEMORY_PATH" -name "*.md" -type f 2>/dev/null | \
  xargs grep -l -i "architecture\|decision\|pattern" 2>/dev/null
```

---

## Reference

See SKILL-old.md for:
- Detailed ADR template
- Git workflow examples
- Integration patterns
- Troubleshooting

---

## Metadata

**Version History:**
- v1.1.0 (2026-02-05): Progressive disclosure, memory search integration
- v1.0.0: Commit-based ADR workflow (v8.0.0 migration)

**Dependencies:** user-input-protocol, memory-protocol
**Portability:** Universal
