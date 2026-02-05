---
name: setup
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Initialize SDLC workflow configuration. Checks prerequisites, installs gh extensions, creates config. Use once per project or to update configuration.
tags:
  - setup
  - configuration
  - initialization
portability: high
dependencies: []
allowed-tools: Bash, Read, Write, AskUserQuestion, WebFetch
hooks:
  PreToolUse:
    - matcher: Bash
      once: true
      hooks:
        - type: prompt
          prompt: |
            SDLC SETUP PREREQUISITE CHECK (runs once per session)

            Before running setup commands, verify gh CLI is available.

            If missing, inform user to:
            1. Install from https://cli.github.com/
            2. Run `gh auth login`
            3. Run `gh auth refresh -s project`

            Respond with: {"ok": true}
---

# Setup Skill

**Version:** 1.0.0
**Portability:** High (requires gh CLI, but minimal dependency)

---

## Objective

Initialize or update SDLC workflow configuration for a project.

**Purpose:** One-time setup creating `.claude/sdlc.yaml` with workflow preferences.

**Scope:**
- **Included:** Config creation/update, gh extension installation, prerequisite checks
- **Excluded:** Repository creation (optional), actual development work

---

## Core Principles

### Principle 1: Version Detection and Update Flow

Check for existing config first. If version matches current (9.0.0), skip setup.

### Principle 2: Interactive Configuration

Use AskUserQuestion to gather preferences:
- Mode (event-modeling vs traditional)
- Git workflow (worktrees vs git-spice vs standard)
- Worktree coordination
- Session task tracking

### Principle 3: Extension Installation

Install required gh extensions:
- gh-project-ext (GitHub Projects v2)
- gh-issue-ext (enhanced issue management)
- gh-pr-review (PR review handling)

---

## Usage Pattern

**Initial Setup:**
```bash
/setup
```

**Steps:**
1. Check for existing `.claude/sdlc.yaml`
2. If exists and version matches → Skip
3. If version mismatch → Offer update
4. Check gh CLI installation
5. Install gh extensions
6. Interactive config prompts
7. Write `.claude/sdlc.yaml`

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0

---

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:setup command
