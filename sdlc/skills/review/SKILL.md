---
name: review
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Address PR feedback systematically. Use when PR has review comments or when user asks to respond to review.
tags:
  - workflow
  - pull-request
  - code-review
portability: tool-specific
dependencies:
  - github-issues
  - orchestration-protocol
allowed-tools: Bash, Read, Task
---

# Review Skill

**Version:** 1.1.0
**Portability:** Tool-specific (requires gh CLI)

---

## Quick Start

Address PR feedback in under 10 minutes.

### What This Does
Fetches PR comments, categorizes feedback, and guides systematic response.

### Fastest Path
1. Run `/sdlc:review`
2. Fetches all review comments
3. Shows categorized feedback (CRITICAL/IMPORTANT/SUGGESTION)
4. Address each systematically
5. Re-run `/sdlc:pr` to update

### Basic Example
```bash
/sdlc:review

# Output:
# PR #42 feedback:
#
# CRITICAL (must fix):
# - src/auth.rs:23: "SQL injection risk"
#
# IMPORTANT (should fix):
# - tests/auth_test.rs:45: "Missing error case test"
#
# SUGGESTIONS:
# - README.md:10: "Consider adding usage example"
#
# Address feedback, then run: /sdlc:pr
```

### Current Context

!`bash -c "echo '**Branch:** ' && git branch --show-current 2>/dev/null || echo 'No branch'"`!

!`bash -c "echo '**PR Status:** ' && gh pr view --json number,title,url,reviewDecision 2>/dev/null | jq -r '\"#\\(.number) - \\(.title)\\nDecision: \\(.reviewDecision // \\\"Pending\\\")\\n\\(.url)\"' || echo 'No active PR'"`!

!`bash -c "echo '**Review Comments:** ' && gh pr view --json comments 2>/dev/null | jq '[.comments[] | select(.author.login != \\\"github-actions\\\")] | length' || echo '0'"`!

---

## Common Examples

### Example 1: Fetch and Fix
**When:** PR has review comments
**Invoke:** `/sdlc:review`
**Result:** Shows categorized feedback, fix and re-PR

### Example 2: In-Thread Response
**When:** Reviewer question needs clarification
**Invoke:** `/sdlc:review` with comment ID
**Result:** Posts response in PR thread

### Example 3: Request Re-Review
**When:** All feedback addressed
**Invoke:** `/sdlc:pr` (updates PR, notifies reviewers)

---

## When to Use

**Use when:**
- PR has review comments
- Reviewer requested changes
- User asks to "address feedback"

**Don't use when:**
- No PR exists (create with `/sdlc:pr`)
- PR approved (complete with `/sdlc:complete`)

**Related:**
- `/sdlc:pr` - Create/update PR
- `/sdlc:complete` - After merge

---

## Auto-Invocation

Claude automatically invokes this skill when you say:
- "Address the PR feedback"
- "Let's respond to review comments"
- "Fix the review issues"
- "Check PR comments"
- "What did the reviewer say?"
- "Respond to code review"

You don't need to type `/sdlc:review` explicitly - Claude will detect these requests and invoke the skill for you.

---

## Metadata

**Version:** 1.1.0 (2026-02-05): Progressive disclosure
**Dependencies:** github-issues, orchestration-protocol
**Portability:** Tool-specific (gh required)
