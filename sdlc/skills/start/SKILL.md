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
# - No domain? → /sdlc:specify discover
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
**Suggests:** `/sdlc:specify discover`

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

## Auto-Invocation

Claude automatically invokes this skill when you say:
- "Let's start working"
- "What should I do next?"
- "I'm ready to begin"
- "Where do I start?"
- "Let's get started"

You don't need to type `/sdlc:start` explicitly - Claude will detect these requests and invoke the skill for you.

---

## Metadata

**Version:** 1.1.0 (2026-02-05): Progressive disclosure
**Dependencies:** event-modeling, orchestration-protocol
