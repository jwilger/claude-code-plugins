---
name: start
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Smart entry point that detects project state and routes to appropriate workflow phase. Use when user asks to "start work", "begin", or wants guidance on next steps.
tags:
  - workflow
  - router
  - onboarding
portability: tool-specific
dependencies:
  - event-modeling
  - orchestration-protocol
allowed-tools: Bash, Read, Glob, AskUserQuestion
---

# Start Skill

**Version:** 1.1.0
**Portability:** Tool-specific

---

## Quick Start

Get started in under 1 minute.

### What This Does
Analyzes project state and suggests next appropriate action.

### Fastest Path
```bash
/sdlc:start
# Detects current phase and suggests:
# - No config? → /sdlc:setup
# - No domain? → /sdlc:design discover
# - No tasks? → /sdlc:plan
# - Ready to code? → /sdlc:work
# - On feature branch? → /sdlc:pr or /sdlc:review
```

---

## Common Examples

### Example 1: First Time
**Invoke:** `/sdlc:start`
**Detects:** No config
**Suggests:** `/sdlc:setup`

### Example 2: After Setup
**Invoke:** `/sdlc:start`
**Detects:** No event model
**Suggests:** `/sdlc:design discover`

### Example 3: Ready to Code
**Invoke:** `/sdlc:start`
**Detects:** Tasks exist
**Suggests:** `/sdlc:work`

---

## When to Use

**Use when:**
- Unsure what to do next
- Starting new session
- User asks "what should I do?"

**Related:** All other skills (routes to them)

---

## Metadata

**Version:** 1.1.0 (2026-02-05): Progressive disclosure
**Dependencies:** event-modeling, orchestration-protocol
