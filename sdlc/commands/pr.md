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
            - Issue it closes
            - Mutation testing results

            Output ONLY: {"ok": true}
---

# SDLC Pull Request

Create or update a pull request for the current work. This command:
1. Performs three-stage code review (spec compliance, code quality, domain integrity)
2. Runs mutation testing to verify test quality
3. Creates or updates the PR
4. Links PR to the issue
5. Keeps issue in "In Progress" (PR goes to Review)

## Steps

### 1. Load Configuration

Read `.claude/sdlc.yaml` for git workflow settings.

### 2. Detect Current Issue

From the current branch name, extract the issue number:
```bash
git branch --show-current
```

Parse issue number from branch name (e.g., `feature/123-add-login` → `123`).

If no issue number in branch, ask user which issue this PR is for.

### 3. Run Three-Stage Code Review

**Before mutation testing**, run the code reviewer to catch issues early.

Use the sdlc:code-reviewer agent:

```
Task tool with subagent_type="sdlc:code-reviewer":
  Perform a three-stage code review:

  Context:
  - Issue: #<issue-number>
  - Branch: <branch-name>
  - Base: main (or configured base branch)

  Acceptance Criteria:
  <fetch from issue body or GWT scenarios>

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

Get issue details for PR body:
```bash
gh issue view <issue-number> --json title,body
```

Create PR with link to issue:
```bash
gh pr create \
  --title "<issue-title>" \
  --body "Closes #<issue-number>

## Summary
<brief summary of changes>

## Changes
<list of key changes>

## Testing
- All tests passing
- Mutation score: <score>%

---
Related: #<issue-number>" \
  --assignee @me
```

#### If updating existing PR:

```bash
# Push already happened, just ensure it's up to date
gh pr view --json url
```

### 8. Branch-Issue Linking

The branch should already be linked to the issue from `/sdlc:work`. If not, you can verify/create the link:

```bash
# Check if branch is linked
gh issue-ext branch list <issue-number>

# If not linked, create link (note: creates branch if it doesn't exist)
gh issue-ext branch create <issue-number> --name <branch-name>
```

The `Closes #<issue-number>` in the PR body also creates an automatic link that will close the issue when the PR merges.

### 9. Update Project Status

The PR should show in Review status. If using projects:
- PR status tracks separately from issue
- Issue stays in "In Progress" until PR is merged

### 10. Display Result

```
Pull Request created/updated!

PR: <url>
Issue: #<number> - <title>
Mutation Score: <score>%

Status:
  - PR: In Review
  - Issue: In Progress (will close when PR merges)

Next steps:
  - Wait for review feedback
  - Run /sdlc:review when you have comments to address
```

## Error Handling

- **Not on feature branch**: Warn that we're on main/master
- **No commits**: Nothing to create PR for
- **Mutation testing fails**: Show results, offer to proceed anyway
- **PR creation fails**: Show error, suggest manual creation
