---
description: INVOKE when ready to create PR. Runs three-stage code review and mutation testing
allowed-tools:
  - Bash
  - Read
  - Task
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
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Before completing, store the PR context in memento:
            - PR URL and number
            - Task it addresses
            - Mutation testing results

            Output ONLY: {"ok": true}
---

# SDLC Pull Request

Create or update a pull request for the current work. This command:
1. Performs three-stage code review (spec compliance, code quality, domain integrity)
2. Runs mutation testing to verify test quality
3. Closes the task and commits `.dots/` changes on the feature branch
4. Creates or updates the PR (with task closure included)
5. When PR merges, main branch reflects the task as completed

## Steps

### 1. Load Configuration

Read `.claude/sdlc.yaml` for git workflow settings.

### 2. Detect Current Task

From the current branch name, extract the full task ID:
```bash
git branch --show-current
```

Parse task ID from branch name (e.g., `feature/myproject-add-login-abc123` → `myproject-add-login-abc123`).

If no task ID in branch, ask user which task this PR is for.

### 3. Run Three-Stage Code Review

**Before mutation testing**, run the code reviewer to catch issues early.

First, check if experimental parallel review is enabled:
```bash
echo "${SDLC_EXPERIMENTAL_PARALLEL_REVIEW:-0}"
```

#### Sequential Review (Default)

If `SDLC_EXPERIMENTAL_PARALLEL_REVIEW` is not set or is `0`, use the standard sequential review:

Use the sdlc:code-reviewer agent:

```
Task tool with subagent_type="sdlc:code-reviewer":
  Perform a three-stage code review:

  Context:
  - Task: <task-id>
  - Branch: feature/<task-id>
  - Base: main (or configured base branch)

  Acceptance Criteria:
  <fetch from task description via 'dot show <task-id>' or GWT scenarios>

  Files Changed:
  <output of git diff --name-only main..HEAD>

  Tests Added/Modified:
  <output of git diff --name-only main..HEAD | grep -E 'test|spec'>

  Stage 1: Verify all acceptance criteria are implemented and tested.
  Stage 2: Review code quality and maintainability.
  Stage 3: Domain integrity - invoke sdlc:domain to:
    - Audit tests for compile-time enforcement opportunities
    - Verify domain type usage
    - Check validation boundaries

  Report issues by severity (CRITICAL, IMPORTANT, SUGGESTION, FLAG).
```

#### Parallel Review (Experimental)

If `SDLC_EXPERIMENTAL_PARALLEL_REVIEW=1`, use agent teams to run the three review stages in parallel. This requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` to also be enabled.

**IMPORTANT:** This is experimental and uses significantly more tokens (approximately 3x). The TDD cycle is completely unaffected -- parallel review applies ONLY to this code review step.

Instruct the orchestrator to create an agent team:

```
Create an agent team to perform a parallel three-stage code review of this PR.

Context for all reviewers:
- Task: <task-id>
- Branch: feature/<task-id>
- Base: main
- Files changed: <output of git diff --name-only main..HEAD>
- Tests: <output of git diff --name-only main..HEAD | grep -E 'test|spec'>
- Acceptance criteria: <from dot show>

Spawn three reviewer teammates:

1. SPEC COMPLIANCE REVIEWER: Check that all acceptance criteria are implemented
   and tested. For each criterion, verify implementing code exists, a test covers
   it, and the implementation matches the spec exactly. Report MISSING, INCOMPLETE,
   OVER-BUILT, or DIVERGENT issues.

2. CODE QUALITY REVIEWER: Review code clarity, domain type usage, error handling,
   test quality, and YAGNI compliance. Run static analysis if available (cargo
   clippy, eslint). Report BUG_RISK, MAINTAINABILITY, STYLE, and PERFORMANCE issues.

3. DOMAIN INTEGRITY REVIEWER: Audit tests for compile-time enforcement opportunities,
   verify domain type usage consistency, check validation boundaries, and verify
   state representation. Report COMPILE-TIME FLAGS and domain violations.

Each reviewer should produce their stage output in the standard format (STAGE N: ...).
Synthesize all three into the unified CODE REVIEW SUMMARY format when complete.

If any teammate fails, fall back to sequential review for that stage.
```

**Fallback:** If agent teams are not available (feature not enabled or not supported), automatically fall back to the sequential review above. Log a note:
```
Note: Parallel review requested but agent teams not available. Using sequential review.
```

**Review Results:**
- **CRITICAL issues**: Block PR. User must fix before proceeding.
- **IMPORTANT issues**: Warn. Recommend fixing, but allow proceeding.
- **SUGGESTIONS only**: Proceed to mutation testing.
- **COMPILE-TIME FLAGS**: Strongly recommended but not blocking.

If user chooses to proceed with unfixed IMPORTANT issues, note them in PR body.
If FLAGS exist, list them in PR body as "Recommended improvements".

### 4. Run Mutation Testing

Use the sdlc:mutation agent to run mutation testing:

```
Task tool with subagent_type="sdlc:mutation":
  Run mutation testing on the changes in this branch. Enforce 100% mutation score.
  Report any surviving mutants that need additional test coverage.
```

If mutation score is below 100%:
- Show the surviving mutants
- Warn that PR can still be created but may need additional tests
- Ask user if they want to proceed or fix first

### 5. Close the Task

Close the task so the `.dots/` changes are included in this PR. When the PR merges, main branch will reflect the task as completed.

```bash
dot off <task-id> -r "Completed via PR (pending merge)"
```

#### Check Parent Task

If the task has a parent, check if all siblings are now complete:

```bash
PARENT_ID=$(dot show <task-id> --json | jq -r '.parent // empty')
if [ -n "$PARENT_ID" ]; then
  CHILDREN=$(dot tree "$PARENT_ID" --json | jq -r '.children[] | .status')
  INCOMPLETE=$(echo "$CHILDREN" | grep -cv "closed")
  if [ "$INCOMPLETE" -eq 0 ]; then
    # All children done — close parent too
    dot off "$PARENT_ID" -r "All child tasks completed"
  fi
fi
```

If all children are complete, use AskUserQuestion to confirm closing the parent before doing so.

#### Commit .dots/ Changes

Stage and commit the `.dots/` changes on the feature branch:

```bash
git add .dots/
git commit -m "chore: close task <task-id>"
```

This commit ensures the task closure travels with the PR. When merged, main shows the task as closed.

### 6. Check for Existing PR

```bash
gh pr list --head $(git branch --show-current) --json number,url
```

If PR exists, we'll update it. If not, we'll create it.

### 7. Push Changes

```bash
git push -u origin $(git branch --show-current)
```

### 8. Create/Update PR

#### If creating new PR:

Get task details for PR body:
```bash
dot show <task-id> --json | jq -r '.title, .description'
```

Create PR with reference to task:
```bash
gh pr create \
  --title "<task-title>" \
  --body "Task: <task-id>

## Summary
<brief summary of changes>

## Changes
<list of key changes>

## Testing
- All tests passing
- Mutation score: <score>%

Related task: <task-id>" \
  --assignee @me
```

#### If updating existing PR:

```bash
# Push already happened, just ensure it's up to date
gh pr view --json url
```

### 9. Display Result

```
Pull Request created/updated!

PR: <url>
Task: <task-id> - <title> (closed)
Mutation Score: <score>%

Next steps:
  - Wait for review feedback
  - Run /sdlc:review when you have comments to address
  - When PR merges, task closure lands on main automatically
```

## Error Handling

- **Not on feature branch**: Warn that we're on main/master
- **No commits**: Nothing to create PR for
- **Mutation testing fails**: Show results, offer to proceed anyway
- **PR creation fails**: Show error, suggest manual creation
