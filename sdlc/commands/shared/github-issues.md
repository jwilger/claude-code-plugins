---
description: INVOKE when managing GitHub issues, projects, or PRs. Extension command reference
user-invocable: false
---

# GitHub CLI Extensions (MANDATORY)

The SDLC workflow depends on three GitHub CLI extensions. **Always prefer these extensions over `gh api` calls.**

## Extension Priority Hierarchy

1. **Extension commands** (most abstracted, purpose-built)
2. **Native gh commands** (e.g., `gh issue`, `gh pr`, `gh project`)
3. **`gh api` calls** (only when no CLI alternative exists)

## Available Extensions

| Extension | Purpose | Example Commands |
|-----------|---------|------------------|
| `gh-issue-ext` | Sub-issues, blocking, linked branches | `gh issue-ext sub list`, `gh issue-ext blocking add` |
| `gh-project-ext` | Project board management | `gh project-ext ready`, `gh project-ext move` |
| `gh-pr-review` | PR review thread handling | `gh pr-review review view`, `gh pr-review comments reply` |

## Sub-Issue Creation (CRITICAL - Two Steps Required)

GitHub does NOT support creating sub-issues in a single command. You MUST:

1. **Create the issue first**:
   ```bash
   gh issue create --title "Child Issue" --label "..." --body "..."
   # Returns: https://github.com/owner/repo/issues/42
   ```

2. **Then link as sub-issue**:
   ```bash
   gh issue-ext sub add <parent-number> <child-number>
   # Example: gh issue-ext sub add 10 42
   ```

**DO NOT** attempt to use `--parent`, `--sub-issue`, or similar flags on `gh issue create` - they do not exist.

## `gh api` Is a LAST RESORT

**NEVER use `gh api` without first exhausting alternatives.**

Before ANY `gh api` call:
1. Check native `gh` commands first
2. Check installed extensions: `gh extension list`
3. Search for extensions: `gh extension search <keywords>`
4. Ask user whether to install extension or proceed with `gh api`

### Acceptable `gh api` Uses (skip the search)

- Repository settings (merge methods, delete branch on merge)
- Branch rulesets configuration
- Webhook management
- Repository secrets management

## Quick Reference

```bash
# Sub-issues
gh issue-ext sub list 10              # List sub-issues of #10
gh issue-ext sub add 10 42            # Make #42 a sub-issue of #10

# Blocking
gh issue-ext blocking add 15 14       # #15 is blocked by #14
gh issue-ext blocking list 15         # What blocks #15?

# Linked branches
gh issue-ext branch create 42         # Create and link branch for #42

# Project board
gh project-ext ready                  # Show Ready items
gh project-ext move 42 "In Progress"  # Move #42 to In Progress
gh project-ext claim 42               # Assign to me + move to In Progress

# PR reviews
gh pr-review review view --pr 123 --unresolved
gh pr-review comments reply --thread-id <id> --body "Fixed!"
gh pr-review threads resolve --thread-id <id>
```

## Task Management

GitHub Issues and Projects are the **source of truth** for all task tracking. Use `/sdlc:work` to find and start working on issues.

TodoWrite is a local scratchpad for the current session only.
