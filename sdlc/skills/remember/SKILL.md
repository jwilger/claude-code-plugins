---
name: remember
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Store patterns, conventions, and insights in auto memory. Use when you solve problems, learn conventions, or discover patterns worth remembering.
tags:
  - memory
  - knowledge-management
  - patterns
portability: universal
dependencies:
  - memory-protocol
allowed-tools: Bash, Write, Read
---

# Remember Skill

**Version:** 1.1.0
**Portability:** Universal

---

## Quick Start

Store knowledge in under 1 minute.

### What This Does
Saves patterns, conventions, and insights to auto memory for future reference.

### Fastest Path
```bash
/sdlc:remember patterns "Email validation with semantic types"
# Prompts: Describe the pattern
# Saves to: ~/.claude/projects/<project>/memory/patterns/
```

### Categories
- `patterns` - Reusable design patterns
- `conventions` - Project conventions
- `debugging` - Problem solutions
- `architecture` - Architecture decisions (use `/sdlc:arch` for formal ADRs)
- `tools` - Tool discoveries and workarounds

---

## Common Examples

### Example 1: Design Pattern
```bash
/sdlc:remember patterns "Parse-don't-validate with Email type"
```

### Example 2: Convention
```bash
/sdlc:remember conventions "Test file naming: <feature>_test.rs"
```

### Example 3: Debug Solution
```bash
/sdlc:remember debugging "Fixing gh CLI rate limit with GH_TOKEN"
```

---

## When to Use

**Use when:**
- Solved non-trivial problem
- Discovered project convention
- Found useful pattern

**Don't use for:**
- Trivial info
- Temporary notes

**Related:** `/sdlc:recall` - Search memory

---

## Auto-Invocation

Claude automatically invokes this skill when you say:
- "Remember this pattern"
- "Save this solution"
- "Store this in memory"
- "I want to remember this approach"
- "Add this to our conventions"

You don't need to type `/sdlc:remember` explicitly - Claude will detect these requests and invoke the skill for you.

---

## Metadata

**Version:** 1.1.0 (2026-02-05): Progressive disclosure
**Dependencies:** memory-protocol
