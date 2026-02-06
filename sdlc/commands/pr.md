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
3. Creates or updates the PR
4. References the task in PR body
5. Task remains active (must be manually completed with /sdlc:complete after PR merge)

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

### 5. Check for Existing PR

```bash
gh pr list --head $(git branch --show-current) --json number,url
```

If PR exists, we'll update it. If not, we'll create it.

### 6. Push Changes

If using git-spice (see [shared/git-spice](mdc:shared/git-spice) for usage):
```bash
gs stack submit
```

If using standard git:
```bash
git push -u origin $(git branch --show-current)
```

### 7. Create/Update PR

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

---
**Note:** After merging, run `/sdlc:complete <task-id>` to close the task.

Related task: <task-id>" \
  --assignee @me
```

**Important:** Unlike GitHub Issues with `Closes #123` syntax, dot tasks must be manually completed with `/sdlc:complete` after PR merge.

#### If updating existing PR:

```bash
# Push already happened, just ensure it's up to date
gh pr view --json url
```

### 8. Task Status

The task remains in `active` status during PR review. It must be manually completed after merge using `/sdlc:complete <task-id>`.

This manual step allows you to:
- Verify the PR was actually merged (not just closed)
- Check if the parent task should also be closed (all children done?)
- Add any final notes to memento about the work

### 9. Display Result

```
Pull Request created/updated!

PR: <url>
Task: <task-id> - <title>
Mutation Score: <score>%

Status:
  - Task: active (complete with /sdlc:complete after merge)

Next steps:
  - Wait for review feedback
  - Run /sdlc:review when you have comments to address
  - After PR merges, run: /sdlc:complete <task-id>
```

## Error Handling

- **Not on feature branch**: Warn that we're on main/master
- **No commits**: Nothing to create PR for
- **Mutation testing fails**: Show results, offer to proceed anyway
- **PR creation fails**: Show error, suggest manual creation
