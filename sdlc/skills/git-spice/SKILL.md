---
user-invocable: false
name: git-spice
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Stacked pull request workflow patterns using git-spice for incremental, reviewable changes
tags:
  - git
  - stacked-prs
  - version-control
  - workflow
portability: tool-specific
dependencies: []
---

# Git-Spice Stacked PR Workflow

**Version:** 1.0.0
**Portability:** Tool-Specific (requires git-spice CLI)

---

## Objective

Teaches stacked pull request workflows using git-spice (`gs`), enabling incremental, dependent changes that are easier to review and safer to merge than large, monolithic PRs.

**Purpose:** Break large features into small, independently reviewable PRs that build on each other, improving code review quality and reducing merge conflicts.

**Scope:**
- **Included:** Stacked PR patterns, git-spice command usage, stack navigation, error recovery, post-sync verification
- **Excluded:** Git fundamentals, GitHub PR mechanics, code review process

**Tool Requirement:** git-spice CLI (`gs`) must be installed. See: https://abhinav.github.io/git-spice/

---

## Core Principles

### Principle 1: Small, Incremental Changes (Stacking)

**The Principle:** Break large features into a stack of small, dependent PRs rather than one large PR.

**Why this matters:** Small PRs are easier to review, faster to merge, and less likely to introduce bugs. Reviewers can understand and approve each small change independently.

**How to apply:**
- Each PR in the stack should be independently reviewable
- Each PR should ideally be < 400 lines of changes
- Stack PRs build on each other (PR #2 depends on PR #1)
- Bottom of stack (PR #1) branches from main
- Top of stack is your current work

**Example Stack:**
```
main
  └─ PR #1: Add User type definition (50 lines)
      └─ PR #2: Implement User repository interface (150 lines)
          └─ PR #3: Add authentication logic (200 lines)
              └─ PR #4: Add login UI (100 lines)

Instead of: Single PR with 500 lines changing types + repository + auth + UI
```

**Benefits:**
- PR #1 can be reviewed and merged quickly
- Once PR #1 merges, PR #2 automatically rebases onto main
- Reviewers see clear progression
- Smaller surface area for bugs

### Principle 2: Git-Spice Manages Stack State

**The Principle:** Let git-spice track branch relationships and handle rebase operations rather than manual git commands.

**Why this matters:** Stacked branches require careful rebasing when lower PRs merge. git-spice automates this, preventing errors and saving time.

**How git-spice helps:**
- Tracks which branches stack on which
- Automatically rebases when base branches merge
- Provides navigation commands (up/down the stack)
- Submits entire stacks as PRs with one command

**How to apply:**
- Use `gs branch create` instead of `git checkout -b` for stack branches
- Use `gs stack submit` instead of manual PR creation
- Use `gs repo sync` instead of `git pull --rebase`
- Trust gs to handle rebases (but verify results!)

### Principle 3: Verify After Every Sync (Safety)

**The Principle:** After `gs repo sync`, immediately verify your branch is based on the correct parent and files exist.

**Why this matters:** git-spice makes assumptions about stack structure. When PRs merge, gs rebases dependent branches but can sometimes guess wrong, moving your branch onto an unexpected base.

**How to apply:**
1. Run `gs repo sync`
2. Check the output for "moved upstack onto <branch>"
3. Verify files: `ls -la` shows expected project files
4. Check base: `git log --oneline -3` shows expected commits
5. If wrong, use `gs upstack onto <correct-base>` to fix

**Example of verification:**
```bash
# Run sync
$ gs repo sync

# Check output
INF feature/auth: moved upstack onto main ✓ (Good!)
# OR
INF feature/auth: moved upstack onto feature/old-branch ✗ (Bad!)

# Verify files exist
$ ls Cargo.toml package.json
Cargo.toml  # ✓ Good
ls: cannot access 'Cargo.toml': No such file or directory  # ✗ Bad!

# If bad, recover
$ gs upstack onto main
$ ls Cargo.toml  # Verify recovery
```

### Principle 4: Stacking Decision (When to Stack vs Regular Git)

**The Principle:** Use git-spice for dependent work, regular git for independent work.

**Why this matters:** git-spice adds complexity. Only use it when you benefit from stacked workflows.

**When to use git-spice:**
- Building on work in progress (PR #1 not merged yet, starting PR #2)
- Large feature split into incremental PRs
- Already on a gs-managed branch
- Want automatic rebase when lower PRs merge

**When to use regular git:**
- Starting fresh, independent work from main
- Simple, standalone changes
- No dependencies on other PRs
- git-spice not available in environment

**Decision Tree:**
```
Is current branch gs-managed?
├─ Yes → Use gs commands
└─ No → Starting new work?
    ├─ Independent → Regular git
    └─ Depends on unmerged PR → gs branch create (start stack)
```

---

## Constraints and Boundaries

### DO:
- Use `gs branch create` for new branches in a stack
- Use `gs stack submit` to create PRs
- Verify branch state after every `gs repo sync`
- Check file existence after sync (`ls` key project files)
- Use `gs upstack onto <branch>` to recover from bad sync
- Navigate stack with `gs up` / `gs down`
- Use `gs log short` to visualize stack

### DON'T:
- Mix `gs` and manual `git rebase` commands (confuses gs state)
- Skip verification after sync (catch problems immediately)
- Assume sync always guesses correctly (it doesn't)
- Use git-spice for simple, independent branches (unnecessary complexity)
- Forget to check `gs branch checkout` output (tells you current gs state)

**Rationale:** git-spice automates complex rebasing, but requires verification to catch incorrect assumptions.

---

## Usage Patterns

### Pattern 1: Starting a New Stack

**Scenario:** Building a feature that will be split into multiple PRs.

**Approach:**

**Step 1: Sync and create base branch**
```bash
# Ensure main is up to date
gs repo sync

# Create first branch in stack (from main)
gs branch create feature/user-types

# Make changes, commit
git add src/user.rs
git commit -m "Add User and Email types"
```

**Step 2: Submit first PR**
```bash
# Submit as PR
gs stack submit

# Output shows created PR #1
```

**Step 3: Create dependent branch**
```bash
# Create next branch (stacks on current)
gs branch create feature/user-repository

# Make changes, commit
git add src/repository.rs
git commit -m "Implement UserRepository trait"

# Submit (creates PR #2, dependent on PR #1)
gs stack submit
```

**Result:** Two PRs where PR #2 builds on PR #1. When PR #1 merges, PR #2 automatically rebases onto main.

### Pattern 2: Navigating an Existing Stack

**Scenario:** Working in a stack, need to move between branches.

**Approach:**

**View stack structure:**
```bash
# Quick overview
gs log short

# Output:
# main
# └─ feature/user-types (PR #1)
#     └─ feature/user-repository (PR #2)
#         └─ feature/auth-logic (PR #3) ← current
```

**Navigate up (toward main):**
```bash
# Move down the stack (toward older branches)
gs down

# Now on: feature/user-repository
```

**Navigate down (toward newest work):**
```bash
# Move up the stack (toward newer branches)
gs up

# Now on: feature/auth-logic
```

**Jump to specific branch:**
```bash
gs branch checkout feature/user-types
```

### Pattern 3: Recovering from Bad Sync

**Scenario:** After `gs repo sync`, branch is based on wrong parent.

**Symptoms:**
```bash
$ gs repo sync
INF feature/auth-logic: moved upstack onto feature/old-branch

$ ls Cargo.toml
ls: cannot access 'Cargo.toml': No such file or directory  # Missing!

$ git log --oneline -2
abc123 Implement authentication
def456 Some old commit that shouldn't be here
```

**Recovery:**

**Step 1: Confirm the problem**
```bash
# Check current commits
git log --oneline -5

# Check what main has
git log main --oneline -5

# Confirm: We should be based on main, but we're not
```

**Step 2: Move to correct base**
```bash
# Explicitly move onto main
gs upstack onto main
```

**Step 3: Verify recovery**
```bash
# Files should exist now
ls Cargo.toml
# Output: Cargo.toml ✓

# Commits should match expectation
git log --oneline -3
# Output shows commits from main, then your work ✓

# Check diff
git diff main --stat
# Output shows only your changes ✓
```

**Step 4: If gs commands fail, use git**
```bash
# Fall back to manual rebase
git rebase --onto main <wrong-base> feature/auth-logic

# Example:
git rebase --onto main feature/old-branch feature/auth-logic
```

### Pattern 4: Submitting an Entire Stack

**Scenario:** Multiple dependent branches ready for review.

**Approach:**

**From any branch in the stack:**
```bash
# View stack
gs log short
# Output:
# main
# └─ feature/step1
#     └─ feature/step2
#         └─ feature/step3 ← current

# Submit entire stack
gs stack submit
```

**Result:**
- PR #1: feature/step1 → main
- PR #2: feature/step2 → feature/step1
- PR #3: feature/step3 → feature/step2

**As PRs merge bottom-up:**
1. PR #1 merges to main
2. `gs repo sync` rebases PR #2 onto main (no longer depends on PR #1)
3. PR #2 merges to main
4. `gs repo sync` rebases PR #3 onto main
5. PR #3 merges to main

---

## Integration with Other Skills

**Works well with:**
- **tdd-constraints:** Each PR in stack can be one TDD cycle (test + types + implementation)
- **github-issues:** Each stacked PR addresses one sub-issue of a larger feature issue
- **debugging-protocol:** When sync goes wrong, use systematic debugging to understand state

**Prerequisites:**
- git-spice CLI installed
- GitHub CLI (`gh`) for PR management
- Understanding of git rebase
- Understanding of PR workflows

---

## Common Pitfalls

### Pitfall 1: Skipping Post-Sync Verification

**Problem:** Run `gs repo sync`, assume everything is fine, continue working

**Solution:** ALWAYS verify after sync:
```bash
gs repo sync
ls <key-project-file>  # Does it exist?
git log --oneline -3   # Are commits correct?
```

### Pitfall 2: Using Regular Git Rebase with gs Branches

**Problem:** Mix `git rebase` commands with gs-managed branches, confusing gs state

**Solution:** Use gs commands for gs-managed branches. If you must use git, verify gs state afterward:
```bash
gs branch checkout  # Shows current gs-managed branch and its base
```

### Pitfall 3: Creating Too Many Stacked PRs

**Problem:** Stack of 10+ dependent PRs, reviewers overwhelmed

**Solution:** Keep stacks shallow (3-5 PRs maximum). If feature needs more, break into multiple independent stacks.

### Pitfall 4: Not Detecting Failed Sync Early

**Problem:** Sync moves branch incorrectly, continue working for hours before noticing

**Solution:** Immediate verification catches problems before wasted work:
```bash
gs repo sync && ls Cargo.toml || echo "PROBLEM DETECTED!"
```

---

## Examples

### Example 1: Three-Level Stack for Authentication Feature

**Scenario:** Building authentication feature, split into 3 PRs.

**Stack Structure:**
```
main
└─ PR #1: feature/auth-types (User, Email, Password types)
    └─ PR #2: feature/auth-repository (UserRepository implementation)
        └─ PR #3: feature/auth-endpoint (HTTP endpoint for login)
```

**Implementation:**

**PR #1: Types**
```bash
# Start from main
git checkout main
gs repo sync

# Create first branch
gs branch create feature/auth-types

# Add types
cat > src/user.rs << 'EOF'
pub struct User {
    pub email: Email,
    pub password_hash: PasswordHash,
}

pub struct Email(String);
pub struct PasswordHash(String);
EOF

git add src/user.rs
git commit -m "Add User, Email, and PasswordHash types"

# Submit PR #1
gs stack submit
# Creates PR #1: feature/auth-types → main
```

**PR #2: Repository**
```bash
# Create second branch (stacks on current)
gs branch create feature/auth-repository

# Add repository
cat > src/repository.rs << 'EOF'
use crate::user::User;

pub trait UserRepository {
    fn find_by_email(&self, email: &Email) -> Option<User>;
    fn save(&self, user: &User) -> Result<(), Error>;
}
EOF

git add src/repository.rs
git commit -m "Add UserRepository trait"

# Submit PR #2
gs stack submit
# Creates PR #2: feature/auth-repository → feature/auth-types
```

**PR #3: Endpoint**
```bash
# Create third branch
gs branch create feature/auth-endpoint

# Add HTTP endpoint
cat > src/handlers/login.rs << 'EOF'
pub async fn login(req: LoginRequest) -> Result<Response> {
    let user = repository.find_by_email(&req.email)?;
    user.authenticate(&req.password)?;
    Ok(Response::ok())
}
EOF

git add src/handlers/login.rs
git commit -m "Add login HTTP endpoint"

# Submit PR #3
gs stack submit
# Creates PR #3: feature/auth-endpoint → feature/auth-repository
```

**Review Process:**
1. PR #1 reviewed first (types only, small, easy)
2. PR #1 merges to main
3. `gs repo sync` → PR #2 automatically rebases onto main
4. PR #2 reviewed (repository implementation)
5. PR #2 merges to main
6. `gs repo sync` → PR #3 automatically rebases onto main
7. PR #3 reviewed (endpoint)
8. PR #3 merges to main

**Benefits:**
- Each PR < 200 lines
- Each PR independently reviewable
- Early PRs unblock later work
- Conflicts resolved incrementally

### Example 2: Recovery from Bad Sync (Real-World)

**Scenario:** Working on `feature/sqlite-event-store`, dependent on `feature/event-store-trait`. The trait PR merges, but sync guesses wrong base.

**Problem:**
```bash
$ gs repo sync

INF feature/sqlite-event-store: moved upstack onto feature/task-types
#   ↑ WRONG! Should have moved onto main, not feature/task-types

$ ls Cargo.toml
ls: cannot access 'Cargo.toml': No such file or directory

$ git log --oneline -3
abc123 Implement SQLite event store
def456 Add TaskId and TaskStatus types  ← From feature/task-types
ghi789 Some other unrelated commit
```

**Analysis:**
- Current base: `feature/task-types` (wrong)
- Should be based on: `main`
- `Cargo.toml` missing (because `feature/task-types` doesn't have it)

**Recovery:**
```bash
# Step 1: Confirm desired base
git log main --oneline -3
# Shows: main has Cargo.toml, event-store-trait merged

# Step 2: Move to correct base
gs upstack onto main

# Output:
# INF feature/sqlite-event-store: restacked onto main

# Step 3: Verify
ls Cargo.toml
# Output: Cargo.toml ✓ (exists now)

git log --oneline -3
# abc123 Implement SQLite event store
# <commits from main including merged event-store-trait>
# ✓ Correct!

git diff main --stat
# src/event_store/sqlite.rs | 150 +++++++++++++++++++++++++++++++
# ✓ Only my changes
```

**Prevention Next Time:**
```bash
# Add verification to sync command
gs repo sync && {
    test -f Cargo.toml || {
        echo "ERROR: Cargo.toml missing after sync!"
        echo "Run: gs upstack onto main"
        exit 1
    }
}
```

### Example 3: When NOT to Use git-spice

**Scenario 1: Simple Bug Fix (Independent)**
```bash
# Bad: Unnecessary complexity
gs branch create fix/typo-in-readme
# ... fix typo ...
gs stack submit

# Good: Just use git
git checkout -b fix/typo-in-readme
# ... fix typo ...
gh pr create
```

**Scenario 2: Parallel Features (No Dependencies)**
```bash
# Feature A: User profile
# Feature B: Admin dashboard
# No dependency between A and B

# Bad: Forcing a stack
gs branch create feature/user-profile
# ... work ...
gs branch create feature/admin-dashboard  # Stacks on profile (wrong!)

# Good: Separate branches from main
git checkout main
git checkout -b feature/user-profile
# ... work ...
gh pr create

git checkout main
git checkout -b feature/admin-dashboard
# ... work ...
gh pr create
```

**When git-spice DOES make sense:**
```bash
# Feature: Admin dashboard with multiple PRs
# PR #1: Admin auth middleware
# PR #2: Admin routes (needs auth)
# PR #3: Admin UI (needs routes)

gs branch create feature/admin-auth
# ... work ...
gs stack submit

gs branch create feature/admin-routes
# ... work ...
gs stack submit

gs branch create feature/admin-ui
# ... work ...
gs stack submit

# Stack enforces correct dependency order
```

---

## Verification Checklist

Use this checklist to verify you're using git-spice correctly:

- [ ] Used `gs branch create` for branches in stack (not `git checkout -b`)
- [ ] Verified after every `gs repo sync` (checked files + commits)
- [ ] Used `gs stack submit` to create PRs
- [ ] Checked `gs log short` to visualize stack structure
- [ ] Used `gs upstack onto <branch>` when sync guessed wrong
- [ ] Avoided mixing `gs` and manual `git rebase` commands
- [ ] Only stacked when branches were actually dependent
- [ ] Kept stack shallow (3-5 PRs max, not 10+)
- [ ] Submitted PRs bottom-up (base of stack first)

---

## References

**Source Documentation:**
- sdlc plugin: commands/shared/git-spice.md
- git-spice official docs: https://abhinav.github.io/git-spice/

**Related Skills:**
- github-issues - Linking stacked PRs to sub-issues
- tdd-constraints - Each stack level can be one TDD cycle

**External Resources:**
- git-spice GitHub: https://github.com/abhinav/git-spice
- Stacked PRs explanation: https://www.stacking.dev/

---

## Version History

### v1.0.0 (2026-02-04)
- Initial extraction from sdlc plugin
- Stacked PR workflow patterns
- git-spice command reference
- Post-sync verification protocol
- Error recovery procedures
- Tool-specific (requires git-spice CLI)

---

## Metadata

**Extraction Source:** sdlc/commands/shared/git-spice.md
**Extraction Date:** 2026-02-04
**Last Updated:** 2026-02-04
**Compatibility:** Tool-specific (requires git-spice CLI + GitHub)
**License:** MIT
