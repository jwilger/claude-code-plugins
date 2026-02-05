---
name: recall
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Search auto memory for patterns, conventions, and past solutions. Use before starting work or when facing problems.
tags:
  - memory
  - knowledge-management
  - search
portability: universal
dependencies:
  - memory-protocol
allowed-tools: Bash, Grep, Read
---

# Recall Skill

**Version:** 1.1.0
**Portability:** Universal

---

## Quick Start

Search memory in under 30 seconds.

### What This Does
Searches auto memory for relevant patterns, conventions, and solutions.

### Fastest Path
```bash
/sdlc:recall email validation
# Searches across all memory categories
# Displays matching files with context
```

### Search Scope
- patterns/
- conventions/
- debugging/
- architecture/
- tools/

---

## Common Examples

### Example 1: Find Pattern
```bash
/sdlc:recall domain types
# Shows domain modeling patterns
```

### Example 2: Find Convention
```bash
/sdlc:recall test naming
# Shows test file naming conventions
```

### Example 3: Find Solution
```bash
/sdlc:recall rate limit
# Shows past debugging solutions
```

---

## When to Use

**Use when:**
- Starting new work
- Facing familiar problem
- Need project context

**Auto-invoked by:**
- work skill (before showing tasks)
- arch skill (before decisions)
- design skill (before modeling)

**Related:** `/sdlc:remember` - Store knowledge

---

## Metadata

**Version:** 1.1.0 (2026-02-05): Progressive disclosure
**Dependencies:** memory-protocol
