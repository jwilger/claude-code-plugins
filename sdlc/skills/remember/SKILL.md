---
name: remember
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Store discoveries, insights, and knowledge in auto memory for future retrieval. Use after solving problems or learning conventions.
tags:
  - memory
  - knowledge-management
portability: universal
dependencies:
  - memory-protocol
model: haiku
allowed-tools: Read, Write, Glob, Grep
---

# Remember Skill

**Version:** 1.0.0
**Portability:** Universal (file-based patterns)

---

## Objective

Store knowledge in file-based auto memory system.

**Purpose:** Preserve discoveries for future sessions, avoid repeating research.

**Scope:**
- **Included:** Categorization, file naming, duplicate checking, content storage
- **Excluded:** Retrieval (use recall skill)

---

## Core Principles

### Principle 1: Category-Based Organization

| Category | Use For |
|----------|---------|
| debugging | Problem solutions, error fixes |
| architecture | Design decisions, patterns |
| conventions | Coding standards, preferences |
| tools | CLI quirks, API behaviors |
| patterns | Reusable general knowledge |

### Principle 2: Check for Duplicates

Search existing files before creating new ones. Update existing files when related.

### Principle 3: Descriptive Filenames

Use kebab-case: `cargo-test-timeout.md`, `postgres-jsonb-queries.md`

---

## Usage Pattern

```bash
/remember "Found workaround for cargo test timeout issue"
```

**Steps:**
1. Categorize knowledge (debugging/architecture/conventions/tools/patterns)
2. Search for existing related files
3. Create descriptive filename
4. Write markdown content
5. Update MEMORY.md if critical

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- File-based auto memory

---

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:remember command
