---
name: review
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Handle PR review feedback by fetching comments, addressing each systematically, and responding in-thread. Use when PR has review comments or when user needs to respond to feedback.
tags:
  - workflow
  - code-review
  - pull-request
  - feedback
portability: tool-specific
dependencies:
  - tdd-constraints
  - orchestration-protocol
allowed-tools: Bash, Read, Task
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            SDLC CONFIG CHECK (runs once per session)

            Verify .claude/sdlc.yaml exists before proceeding.
            If it doesn't exist, stop and tell user to run /sdlc:setup first.

            Respond with: {"ok": true}
---

# Review Skill

**Version:** 1.0.0
**Portability:** Tool-specific (requires gh CLI with gh-pr-review extension)

---

## Objective

Handle PR review feedback by systematically addressing comments, making code changes, and responding in-thread.

**Purpose:** Streamline review feedback cycles by organizing comments, delegating fixes to appropriate agents, and ensuring all feedback is addressed.

**Scope:**
- **Included:** Comment fetching, organizing by file, delegating fixes to agents, in-thread responses
- **Excluded:** PR creation (use pr skill), merging (manual)

---

## Core Principles

### Principle 1: Organized Comment Display

Group comments by file and line for systematic handling.

### Principle 2: Delegate to Appropriate Agents

- Test changes → sdlc:red
- Implementation → sdlc:green
- Domain types → sdlc:domain

### Principle 3: Always Reply In-Thread

Use `gh pr-review comments reply` for all responses. Never post general PR comments.

### Principle 4: Three Response Types

1. **Change made**: "Good catch! Added email validation using the `validator` crate."
2. **No change needed**: "This is intentional because [reason]. Happy to discuss."
3. **Question/clarification**: "Yes, we handle that in [location]. More detail?"

---

## Usage Pattern

**Standard Review Handling:**

1. Detect current PR from branch: `gh pr view --json number,url`
2. Fetch unresolved comments: `gh pr-review review view --pr <number> --unresolved`
3. Display comments grouped by file
4. Ask user: "Address all comments automatically?"
5. For each comment:
   - Make code change via appropriate agent
   - Reply in-thread with `gh pr-review comments reply --thread-id <id>`
6. Commit and push changes
7. Request re-review: `gh api repos/{owner}/{repo}/pulls/<number>/requested_reviewers`

**Example:**
```bash
# Fetch comments
gh pr-review review view --pr 123 --unresolved

# Display:
# "PR #123 has 3 pending comments:
# File: src/auth.rs
#   Line 42: @reviewer - 'Validate email format'
#   Line 89: @reviewer - 'Use Result instead of Option'
# File: src/main.rs
#   Line 15: @reviewer - 'Add documentation'"

# Address each comment
# → Fix via sdlc:green agent
# → Reply: "Added email validation using validator crate"

# Commit and push
git add .
git commit -m "Address review feedback"
git push

# Request re-review
gh api repos/owner/repo/pulls/123/requested_reviewers -f reviewers[]="reviewer"
```

---

## Integration

**Works well with:**
- tdd-constraints (delegates fixes to red/green/domain agents)
- orchestration-protocol (coordinates agent work)

**Prerequisites:**
- gh CLI with `gh-pr-review` extension installed
- Current branch has associated PR

---

## Common Pitfalls

**Pitfall**: Posting general PR comments instead of in-thread replies

**Solution**: Always use `gh pr-review comments reply --thread-id` for responses

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- Organized comment display
- Agent delegation
- In-thread response enforcement

---

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:review command
