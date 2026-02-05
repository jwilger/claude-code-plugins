---
name: pr
version: 1.0.0
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

**Version:** 1.0.0
**Portability:** Tool-specific (requires gh CLI, git, code-reviewer and mutation agents)

---

## Objective

Create or update pull requests after running three-stage code review (spec compliance, code quality, domain integrity) and enforcing mutation testing for test quality assurance.

**Purpose:** Ensure all PRs meet quality standards before requesting review, reducing review cycles and catching issues early.

**Scope:**
- **Included:** Three-stage code review, mutation testing, PR creation/update, architecture-only PR handling, task linking
- **Excluded:** Implementation work (use TDD agents), PR merging (manual), task completion (use complete skill)

---

## Core Principles

### Principle 1: Three-Stage Review Before PR

**The Principle:** Every PR undergoes three review stages: spec compliance, code quality, and domain integrity.

**Why this matters:** Catching issues before PR creation reduces review cycles, prevents rework, and ensures consistent quality. Reviewers see only high-quality code.

**Review Stages:**
1. **Spec Compliance**: Verify all acceptance criteria implemented and tested
2. **Code Quality**: Review maintainability, clarity, patterns
3. **Domain Integrity**: Audit domain types for compile-time enforcement opportunities

**How to apply:**
```bash
# Invoke code-reviewer agent via Task tool
Task(subagent_type="sdlc:code-reviewer"):
  Context:
  - Task: <task-id>
  - Branch: feature/<task-id>
  - Files changed: <git diff --name-only main..HEAD>

  Review stages:
  1. Spec: Verify acceptance criteria coverage
  2. Quality: Review code maintainability
  3. Domain: Invoke sdlc:domain agent for type safety audit

  Report: CRITICAL, IMPORTANT, SUGGESTION, FLAG
```

**Severity handling:**
- **CRITICAL**: Block PR, must fix
- **IMPORTANT**: Warn, recommend fixing
- **SUGGESTION**: Proceed, note in PR body
- **FLAG (compile-time opportunities)**: List in PR body as "Recommended improvements"

### Principle 2: Mutation Testing Enforcement

**The Principle:** 100% mutation score is the target. Surviving mutants indicate insufficient test coverage.

**Why this matters:** Tests that don't catch mutations are ineffective. Mutation testing ensures tests actually verify behavior, not just execute code.

**How to apply:**
```bash
# Invoke mutation agent via Task tool
Task(subagent_type="sdlc:mutation"):
  Run mutation testing on branch changes.
  Enforce 100% mutation score.
  Report surviving mutants if any.
```

**If mutation score < 100%:**
- Show surviving mutants with file/line
- Warn PR can still be created but may need additional tests
- Ask user: fix now or proceed?

### Principle 3: Architecture-Only PR Fast Path

**The Principle:** PRs that only touch ARCHITECTURE.md skip code review and mutation testing.

**Why this matters:** Architecture changes follow a different review process (decision quality, not code quality). Skipping irrelevant checks speeds up workflow.

**Detection:**
```bash
# Get all changed files
git diff --name-only main..HEAD

# If output is ONLY docs/ARCHITECTURE.md (or */ARCHITECTURE.md):
# → Architecture PR
# → Skip code review and mutation testing
# → Use latest commit message for PR title/body
# → Add "architecture" label
```

**Architecture PR handling:**
- Use commit subject as PR title
- Use commit body as PR description (contains ADR)
- Add `architecture` label automatically
- Skip to push step

### Principle 4: Task Remains Active During Review

**The Principle:** dot tasks stay `active` during PR review. Manual completion after merge verifies actual merge (not just PR close).

**Why this matters:** PRs can be closed without merging. Manual completion step ensures verification and allows checking parent task status.

**Workflow:**
1. Create PR → task remains `active`
2. PR reviewed and merged
3. User runs `/complete <task-id>` to:
   - Verify PR was merged (not just closed)
   - Check if parent task should close
   - Add final notes to memory

**PR body note:**
```markdown
---
**Note:** After merging, run `/complete <task-id>` to close the task.

Related task: <task-id>
```

---

## Constraints and Boundaries

### DO:
- Run three-stage code review before mutation testing
- Block PR creation on CRITICAL issues
- Warn on IMPORTANT issues, allow proceed
- Include SUGGESTIONS and FLAGS in PR body
- Detect architecture-only PRs and skip code review
- Use commit message for architecture PR title/body
- Add `architecture` label to architecture PRs
- Link task in PR body
- Keep task status as `active` during review
- Update existing PR if one exists for current branch

### DON'T:
- Create PR without running code review first
- Skip mutation testing for non-architecture PRs
- Auto-close tasks when PR is created
- Mix architecture and implementation in same PR
- Bypass review stages without user confirmation
- Force PR creation on CRITICAL issues

**Rationale:** These boundaries ensure quality standards while respecting architecture workflow separation.

---

## Usage Patterns

### Pattern 1: Creating Standard PR After Implementation

**Scenario:** User has completed implementation and tests, ready to create PR.

**Approach:**
1. Load `.claude/sdlc.yaml` for git workflow settings
2. Detect current task from branch name
3. Run three-stage code review
4. If CRITICAL issues, block and require fixes
5. If IMPORTANT issues, warn and ask to proceed or fix
6. Run mutation testing
7. If mutation score < 100%, show mutants and ask to proceed or fix
8. Check for existing PR with `gh pr list --head <branch>`
9. Push changes (git or git-spice)
10. Create or update PR with task link in body

**Example:**
```bash
# User invokes: /pr

# Detect task
BRANCH=$(git branch --show-current)  # feature/myproject-add-search-abc123
TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')

# Run code review
Task(subagent_type="sdlc:code-reviewer"):
  Review branch feature/myproject-add-search-abc123
  Task: myproject-add-search-abc123

# Results: 0 CRITICAL, 1 IMPORTANT, 2 SUGGESTIONS
# "IMPORTANT: Consider extracting search logic to separate function"
# Ask user: Fix now or proceed?
# User: Proceed

# Run mutation testing
Task(subagent_type="sdlc:mutation"):
  Run mutation tests on branch changes

# Results: 98% mutation score, 2 surviving mutants
# Ask user: Fix now or proceed?
# User: Proceed

# Check for existing PR
gh pr list --head "$BRANCH" --json number
# No existing PR

# Push changes
git push -u origin "$BRANCH"

# Create PR
gh pr create \
  --title "Add search feature" \
  --body "Task: myproject-add-search-abc123

## Summary
Adds search functionality to user dashboard.

## Changes
- New search component
- Search API endpoint
- Tests for search behavior

## Code Review
- 1 IMPORTANT issue (proceeding as discussed)
- 2 SUGGESTIONS (see review comments)

## Testing
- All tests passing
- Mutation score: 98% (2 surviving mutants noted)

---
**Note:** After merging, run \`/complete myproject-add-search-abc123\` to close the task.

Related task: myproject-add-search-abc123"

# Display result
echo "✅ PR created: https://github.com/owner/repo/pull/123"
```

### Pattern 2: Creating Architecture-Only PR

**Scenario:** User has made architecture changes (only ARCHITECTURE.md modified).

**Approach:**
1. Detect current task from branch name
2. Check files changed with `git diff --name-only main..HEAD`
3. If only ARCHITECTURE.md changed, flag as architecture PR
4. Check for existing PR
5. If existing, offer to update with latest commit message
6. If new, use commit subject/body for PR title/description
7. Add `architecture` label
8. Skip code review and mutation testing

**Example:**
```bash
# User invokes: /pr

# Detect architecture-only PR
git diff --name-only main..HEAD
# Output: docs/ARCHITECTURE.md

# Check for existing PR
gh pr view --json number -q .number 2>/dev/null
# Output: 45

# Get latest commit
COMMIT_SUBJECT=$(git log -1 --format=%s)
COMMIT_BODY=$(git log -1 --format=%b)

# Ask user
echo "Existing architecture PR found: #45"
echo ""
echo "Latest commit:"
echo "  Subject: $COMMIT_SUBJECT"
echo ""
echo "Update PR title and description to match latest commit?"
# User: Yes

# Update PR
gh pr edit 45 \
  --title "$COMMIT_SUBJECT" \
  --body "$COMMIT_BODY"

echo "✅ PR #45 updated"
```

### Pattern 3: Updating Existing PR After Fixes

**Scenario:** User addressed review feedback and wants to update the existing PR.

**Approach:**
1. Detect task from branch
2. Check for existing PR
3. Run code review again (verify fixes)
4. Run mutation testing again (if code changed)
5. Push changes (automatically updates PR)
6. Display PR URL

**Example:**
```bash
# User invokes: /pr

# Detect existing PR
gh pr list --head "$(git branch --show-current)" --json number,url
# Output: PR #123 exists

# Run review again
Task(subagent_type="sdlc:code-reviewer"):
  Review updated changes

# Results: 0 CRITICAL, 0 IMPORTANT, 1 SUGGESTION
# "All previous issues addressed"

# Run mutation testing
Task(subagent_type="sdlc:mutation"):
  Run mutation tests

# Results: 100% mutation score

# Push changes (auto-updates PR)
git push

# Display
echo "✅ PR #123 updated: https://github.com/owner/repo/pull/123"
echo "All review issues addressed"
echo "Mutation score: 100%"
```

---

## Integration with Other Skills

**Works well with:**
- **tdd-constraints:** Ensures TDD cycle was followed before PR
- **github-issues:** Links PRs to issues
- **orchestration-protocol:** Delegates review work to specialized agents
- **git-spice:** Submits stacked PRs with `gs stack submit`

**Prerequisites:**
- `.claude/sdlc.yaml` must exist
- `gh` CLI installed and authenticated
- Code committed to feature branch
- sdlc:code-reviewer agent available
- sdlc:mutation agent available

---

## Common Pitfalls

### Pitfall 1: Creating PR Without Running Review

**Problem:** User tries to skip code review to save time.

**Solution:**
- Review is MANDATORY before PR creation
- This skill always runs review first
- If user bypasses skill, CI will catch issues anyway

### Pitfall 2: Ignoring CRITICAL Issues

**Problem:** User wants to proceed despite CRITICAL issues.

**Solution:**
- CRITICAL issues BLOCK PR creation
- User must fix issues before creating PR
- No override option for CRITICAL severity

### Pitfall 3: Forgetting to Complete Task After Merge

**Problem:** PR merges but task stays `active`, appearing in ready lists.

**Solution:**
- PR body includes reminder: "After merging, run `/complete <task-id>`"
- Task status check before starting new work will catch this
- Use `dot ls --status active` to see forgotten tasks

### Pitfall 4: Missing Architecture Label on Arch PRs

**Problem:** Architecture PR created without `architecture` label, goes through code review.

**Solution:**
- Skill automatically detects architecture-only PRs
- Checks if ONLY ARCHITECTURE.md changed
- Adds `architecture` label automatically
- Skips code review and mutation testing

---

## Verification Checklist

Use this checklist to verify you're applying this skill correctly:

- [ ] `.claude/sdlc.yaml` loaded for workflow settings
- [ ] Task ID detected from branch name
- [ ] Files changed checked with `git diff --name-only main..HEAD`
- [ ] Architecture-only detection performed
- [ ] If architecture PR, commit message used for title/body
- [ ] If architecture PR, `architecture` label added
- [ ] If standard PR, three-stage code review completed
- [ ] If standard PR, mutation testing completed
- [ ] CRITICAL issues block PR creation
- [ ] IMPORTANT issues warned, user decides
- [ ] Existing PR checked with `gh pr list --head`
- [ ] Changes pushed to remote
- [ ] PR created or updated with task link
- [ ] Task remains `active` (not auto-closed)

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- Three-stage code review enforcement
- Mutation testing integration
- Architecture-only PR fast path
- Manual task completion workflow

---

## Metadata

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:pr command
**Extraction Date:** 2026-02-05
**Last Updated:** 2026-02-05
**Compatibility:** Claude Code (requires gh CLI, git, code-reviewer/mutation agents)
**License:** MIT
