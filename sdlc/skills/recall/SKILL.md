---
name: recall
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Search and retrieve knowledge from auto memory. Use before ANY task to check for existing solutions.
tags:
  - memory
  - search
  - knowledge-retrieval
portability: universal
dependencies:
  - memory-protocol
model: haiku
allowed-tools: Grep, Read, Glob
---

# Recall Skill

**Version:** 1.0.0
**Portability:** Universal (file-based patterns)

---

## Objective

Search and retrieve relevant knowledge from auto memory.

**Purpose:** Find existing solutions before starting work, avoid reinventing.

**Scope:**
- **Included:** Keyword extraction, recursive search, file reading
- **Excluded:** Storage (use remember skill)

---

## Core Principles

### Principle 1: Extract Key Terms

Identify tool names, error keywords, domain concepts from query.

### Principle 2: Search with Context

Use `grep -r -i -C 3` for better match quality.

### Principle 3: Read Relevant Files

From grep results, read most relevant files in full.

---

## Usage Pattern

```bash
/recall "test patterns for this project"
```

**Steps:**
1. Extract search terms from query
2. Search memory directory with grep
3. Read matching files
4. Present findings

**Example:**
```bash
MEMORY_PATH="$HOME/.claude/projects/$(pwd | sed 's/\//-/g' | sed 's/^-//')/memory"
grep -r -i -C 3 "test patterns" "$MEMORY_PATH" --include="*.md"
```

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- File-based auto memory search

---

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:recall command
