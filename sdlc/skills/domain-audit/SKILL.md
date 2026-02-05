---
name: domain-audit
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: On-demand domain type safety audit. Use when reviewing domain types or when user asks about type safety.
tags:
  - domain-modeling
  - type-safety
  - audit
portability: universal
dependencies:
  - tdd-constraints
allowed-tools: Read, Grep, Glob, Task
---

# Domain Audit Skill

**Version:** 1.1.0
**Portability:** Universal

---

## Quick Start

Audit domain types in under 5 minutes.

### What This Does
Reviews domain types for primitive obsession, invalid state representability, and type safety gaps.

### Fastest Path
```bash
/sdlc:domain-audit
# Scans domain types
# Reports issues:
# - Primitive obsession (String instead of Email)
# - Invalid states representable
# - Missing parse-don't-validate
```

---

## Common Examples

### Example 1: Pre-PR Audit
**When:** Before creating PR
**Invoke:** `/sdlc:domain-audit`
**Result:** Catches domain issues early

### Example 2: Periodic Review
**When:** Weekly/monthly review
**Invoke:** `/sdlc:domain-audit`
**Result:** Ensures domain integrity maintained

---

## When to Use

**Use when:**
- Reviewing domain types
- Before major PR
- User asks about "type safety" or "domain"

**Auto-invoked by:**
- `/sdlc:pr` (Stage 3: Domain Integrity)

**Related:**
- Domain agent (runs during TDD)

---

## Auto-Invocation

Claude automatically invokes this skill when you say:
- "Review the domain types"
- "Check for primitive obsession"
- "Audit type safety"
- "Is the domain model sound?"
- "Scan for domain issues"

You don't need to type `/sdlc:domain-audit` explicitly - Claude will detect these requests and invoke the skill for you.

---

## Metadata

**Version:** 1.1.0 (2026-02-05): Progressive disclosure
**Dependencies:** tdd-constraints
