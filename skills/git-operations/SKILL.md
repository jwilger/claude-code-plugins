---
name: git-operations
description: Handles git operations including commits with proper message format, branching, pushing, status checks, and pre-commit hook management. Enforces commit message conventions and verifies commit success. Use for git commit, push, branch, status, or when addressing commit failures.
allowed-tools: [Bash, Read]
---

# Git Operations Workflow

Standardized procedures for git operations with proper error handling and verification.

## Git Commit Protocol

**ALWAYS use Bash tool for git operations.**

### Core Commit Rules

1. **ALWAYS use Bash tool for git commits**
2. **Proceed directly to commit** - Do NOT ask for commit message approval; user will be prompted when Bash tool executes git command
3. **NEVER use --no-verify flag** - This is absolutely FORBIDDEN under all circumstances
4. **NEVER bypass pre-commit hooks** - Pre-commit rules must always be respected
5. **NEVER modify pre-commit rules** - Only user can explicitly authorize changes to pre-commit configuration

### Commit Message Requirements

- Focus on clear, descriptive messages that explain the "why" rather than "what"
- Do NOT include any "Generated with Claude Code" footers or co-authorship attributions
- Keep messages concise and professional
- Follow the repository's existing commit message conventions

### Commit Message Format

Use heredoc for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
Brief summary of change

Detailed explanation if needed
EOF
)"
```

## Source Control Failure Handling Protocol

### Commit Verification (REQUIRED)

1. **ALWAYS verify commit success** by checking git status after EVERY commit attempt
2. **NEVER assume commits succeeded** - always verify with git status via Bash tool
3. **If commit fails**: IMMEDIATELY report failure with specific error details
4. **NEVER proceed** with further git operations if commit failed

**Verification Command:**
```bash
git status
```

Look for "nothing to commit, working tree clean" or similar success indicators.

### Pre-commit Hook Failure Handling (MANDATORY)

When pre-commit hooks fail:

1. **Identify the failure type**:
   - Code quality issues (clippy, rustfmt): Requires code fixes
   - Formatting issues: Requires documentation/formatting fixes
   - Test failures: Requires test fixes

2. **Report specific details**:
   - Which pre-commit hooks failed
   - Which files need attention
   - Exact error messages

3. **NEVER ignore pre-commit hook failures**
4. **NEVER proceed** until all pre-commit hook issues are resolved

### File Staging Protocol (REQUIRED)

When pre-commit hooks modify files:

1. **IMMEDIATELY stage the modified files**
   ```bash
   git add <modified-files>
   ```

2. **Re-attempt commit** after staging pre-commit hook changes
   ```bash
   git commit -m "message"
   ```

3. **Verify final commit success** with git status
   ```bash
   git status
   ```

## Common Git Operations

### Creating a Branch

```bash
git checkout -b feature/branch-name
```

### Staging Files

```bash
# Stage specific files
git add file1.rs file2.rs

# Stage all changes
git add .
```

### Pushing to Remote

```bash
# First push with upstream tracking
git push -u origin branch-name

# Subsequent pushes
git push
```

### Checking Status

```bash
git status
```

### Viewing Diff

```bash
# Unstaged changes
git diff

# Staged changes
git diff --cached

# Comparing branches
git diff main...HEAD
```

### Viewing Log

```bash
# Recent commits
git log -10

# Commits since branch diverged from main
git log main..HEAD

# Oneline format
git log --oneline -10
```

## Error Recovery

### Commit Failed - Pre-commit Hook Modifications

**Scenario**: Pre-commit hooks modified files but commit still failed

**Solution**:
1. Review what pre-commit hooks changed: `git diff`
2. Stage the changes: `git add .`
3. Re-attempt commit: `git commit -m "message"`
4. Verify success: `git status`

### Commit Failed - Validation Errors

**Scenario**: Pre-commit hooks found errors that need fixing

**Solution**:
1. Read the error output carefully
2. Fix the identified issues in the code
3. Stage the fixes: `git add <fixed-files>`
4. Re-attempt commit: `git commit -m "message"`
5. Verify success: `git status`

### Wrong Commit Message

**Scenario**: Committed with wrong message (last commit not pushed)

**Solution**:
```bash
git commit --amend -m "$(cat <<'EOF'
Corrected commit message
EOF
)"
```

**CAUTION**: Only amend commits that haven't been pushed. Never amend published commits.

## Task Completion Protocol

When invoked for git operations:

1. **Execute the requested git operation** using Bash tool
2. **Verify success** using git status or appropriate verification command
3. **Handle any failures** according to protocols above
4. **Report outcome** clearly: success with verification or failure with specific errors
5. **If failures require fixes**: Report what needs to be fixed, don't proceed until resolved
