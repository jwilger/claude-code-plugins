---
name: pr
version: 1.1.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Create pull request after three-stage code review and mutation testing. Use when ready to create PR, request review, or when user asks to submit changes for review.
tags:
  - workflow
  - pull-request
  - code-review
  - mutation-testing
  - quality
portability: tool-specific
dependencies:
  - tdd-constraints
  - github-issues
  - orchestration-protocol
allowed-tools: Bash, Read, Task, TaskGet, TaskList
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

# Pull Request Skill

**Version:** 1.1.0
**Portability:** Tool-specific (requires gh CLI, git, code-reviewer and mutation agents)

---

## Quick Start

Create a high-quality PR in under 5 minutes.

### What This Does
Runs three-stage code review, enforces mutation testing, and creates/updates GitHub PR with comprehensive description.

### Fastest Path
1. Ensure all tests pass
2. Run `/sdlc:pr`
3. Review findings (if any)
4. Fix issues if needed
5. PR created automatically

### Basic Example
```bash
/sdlc:pr

# Runs:
# Stage 1/3: Spec compliance... ✓
# Stage 2/3: Code quality... ✓
# Stage 3/3: Domain integrity... ✓
#
# Mutation testing... 100% killed ✓
#
# Creating PR:
# https://github.com/org/repo/pull/42
#
# ✓ PR created
# ✓ Task linked
# ✓ Ready for review
```

### Current Context

!`bash -c "echo '**Branch:** ' && git branch --show-current 2>/dev/null || echo 'No branch'"`!

!`bash -c "echo '**Commits since base:** ' && BASE=\\$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|origin/||') && git log \\$BASE..HEAD --oneline 2>/dev/null | wc -l || echo '0'"`!

!`bash -c "echo '**Recent commits:** ' && git log --oneline -3 2>/dev/null || echo 'No commits'"`!

!`bash -c "echo '**PR Status:** ' && gh pr view --json number,title,url 2>/dev/null | jq -r '\"#\\(.number) - \\(.title)\\n\\(.url)\"' || echo 'No PR yet (will be created)'"`!

---

## Common Examples

### Example 1: Standard PR (All Green)
**When:** Work complete, tests passing
**Invoke:** `/sdlc:pr`
**Result:** Three-stage review passes, mutation test passes, PR created

### Example 2: Architecture-Only PR
**When:** Only ARCHITECTURE.md changed
**Invoke:** `/sdlc:pr`
**Result:** Skips code review and mutation testing (architecture fast-path)

### Example 3: Review Finds Issues
**When:** PR invoked but code has issues
**Invoke:** `/sdlc:pr`
**Result:** Shows CRITICAL/IMPORTANT findings, blocks PR until fixed

### Example 4: Mutation Score < 100%
**When:** Tests exist but don't catch all mutations
**Invoke:** `/sdlc:pr`
**Result:** Reports surviving mutants, suggests additional tests

### Example 5: Updating Existing PR
**When:** PR exists, pushed new commits
**Invoke:** `/sdlc:pr`
**Result:** Updates PR description, runs review again

---

## When to Use

**Use this skill when:**
- Ready to create PR for current branch
- All tests passing
- Work complete per acceptance criteria
- User asks to "create PR" or "request review"

**Don't use when:**
- Tests failing (fix first)
- Work incomplete
- On main/master branch
- No changes committed

**Related skills:**
- `/sdlc:work` - Start implementation
- `/sdlc:review` - Address PR feedback
- `/sdlc:complete` - After PR merged

---

## Auto-Invocation

Claude automatically invokes this skill when you say:
- "Create a pull request"
- "I'm ready to submit for review"
- "Let's make a PR"
- "Submit this for review"
- "Create PR for this branch"
- "Ready for code review"

You don't need to type `/sdlc:pr` explicitly - Claude will detect these requests and invoke the skill for you.

---

## Three-Stage Review

**Stage 1: Spec Compliance**
- All acceptance criteria implemented?
- Tests cover all scenarios?
- No missing functionality?

**Stage 2: Code Quality**
- Maintainable and clear?
- Following project patterns?
- No code smells?

**Stage 3: Domain Integrity**
- Types enforce constraints at compile-time?
- No primitive obsession?
- Invalid states unrepresentable?

**Mutation Testing**
- 100% mutation score required
- All mutants killed by tests
- Reports surviving mutants if any

---

## Architecture Fast-Path

If ONLY `docs/ARCHITECTURE.md` changed:
- Skips code review stages
- Skips mutation testing
- Creates PR immediately

Rationale: Architecture decisions documented in ADR-format commit messages, not code-reviewed.

---

## Reference

See original SKILL-old.md for:
- Detailed principle explanations
- Comprehensive examples
- Integration patterns
- Troubleshooting

---

## Metadata

**Version History:**
- v1.1.0 (2026-02-05): Progressive disclosure restructure
- v1.0.0: Initial extraction from sdlc plugin v8.0.0

**Dependencies:** tdd-constraints, github-issues, orchestration-protocol
**Portability:** Tool-specific (gh, git, agents required)
