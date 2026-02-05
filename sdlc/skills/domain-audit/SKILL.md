---
name: domain-audit
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Audit domain types for primitive obsession, invalid state representability, type safety gaps. Use on-demand or before PR.
tags:
  - domain
  - type-safety
  - code-quality
portability: tool-specific
dependencies:
  - tdd-constraints
allowed-tools: Task
invocation: user
---

# Domain Audit Skill

**Version:** 1.0.0
**Portability:** Tool-specific (requires sdlc:domain agent)

---

## Objective

Perform focused audit of domain types, identifying compile-time enforcement opportunities.

**Purpose:** Ensure type system makes invalid states unrepresentable.

**Scope:**
- **Included:** Finding domain types, checking semantic vs structural, identifying runtime checks that could be compile-time
- **Excluded:** Implementation (done by domain agent if user approves)

---

## Core Principles

### Principle 1: Semantic vs Structural Types

Semantic types (DiagramTitle) convey meaning. Structural types (NonEmptyString) only enforce shape.

### Principle 2: Parse Don't Validate

Catch invariants at type boundaries, not runtime assertions.

### Principle 3: Focused Audit

No documentation files - just analysis and actionable findings.

---

## Usage Pattern

```bash
/domain-audit
```

**Invokes:**
```
Task(subagent_type="sdlc:domain"):
  Audit domain types for:
  - Structural vs semantic types
  - Confusable fields (both String)
  - Runtime checks that could be compile-time
```

**Output Format:**
```
FILE: <path>
ISSUE: <type>
CURRENT: <code>
PROPOSED: <improvement>
RATIONALE: <one sentence>
```

---

## Integration

Lightweight version runs automatically:
- After Red phase: Check test uses semantic types
- After Green phase: Check implementation respects type boundaries

This skill is for deeper on-demand analysis.

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0

---

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:domain-audit command
