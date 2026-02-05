---
name: setup
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: One-time SDLC configuration and tool installation. Run this first before using any other skills.
tags:
  - workflow
  - setup
  - configuration
portability: tool-specific
dependencies: []
allowed-tools: Bash, Write, AskUserQuestion
---

# Setup Skill

**Version:** 1.1.0
**Portability:** Tool-specific

---

## Quick Start

Configure SDLC in under 3 minutes.

### What This Does
Creates `.claude/sdlc.yaml` config, installs required tools, sets up project structure.

### Fastest Path
```bash
/sdlc:setup
# Prompts for:
# - Mode (event-modeling vs traditional)
# - Git workflow (standard, worktrees, git-spice)
# - Creates config and installs tools
```

---

## Common Examples

### Example 1: Event Modeling Mode
**Choose:** Event modeling mode
**Result:** Domain-first workflow with Event Modeling

### Example 2: Traditional Mode
**Choose:** Traditional mode
**Result:** Direct issue → work → PR flow

---

## When to Use

**Use when:**
- First time using SDLC in project
- `.claude/sdlc.yaml` doesn't exist
- User asks to "set up" or "configure"

**Run this first:** Required before all other skills

---

## Metadata

**Version:** 1.1.0 (2026-02-05): Progressive disclosure
