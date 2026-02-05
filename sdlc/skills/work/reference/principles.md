# Work Skill - Core Principles

## Principle 1: Clean State Before Work

**The Principle:** Never start work with uncommitted changes, unpulled updates, or unclear task context.

**Why this matters:** Dirty git state leads to merge conflicts, lost work, and confusion about what belongs to which task. Starting clean ensures every task has a clear beginning state.

**How to apply:**
- Check `git status --porcelain` before proceeding
- Pull latest from remote with `git fetch && git pull --ff-only`
- Block work if uncommitted changes exist
- Offer stash/commit options if dirty state detected

**Example:**
```bash
# GOOD: Clean state detected
git status --porcelain  # (empty output)
git pull --ff-only      # Already up to date
# ✓ Ready to create branch

# BAD: Uncommitted changes
git status --porcelain  # M src/foo.rs
# ❌ BLOCKED: Must commit, stash, or discard changes first
```

## Principle 2: Task Selection Hierarchy

**The Principle:** Show tasks in priority order: current work → child tasks of active parents → ready tasks (unblocked).

**Why this matters:** This ordering reflects natural workflow progression. Current work should be finished first, then child tasks complete their parents, then new work starts.

**Task Priority:**
1. **Currently working on** (detected from branch name or active status)
2. **Child tasks of active parents** (scoped work blocking parent completion)
3. **Ready tasks** (unblocked, sorted by priority)

## Principle 3: Worktree Isolation (Optional)

**The Principle:** When worktrees enabled, each task gets its own directory with isolated git state.

**Why this matters:** Multiple features can be developed in parallel without branch switching overhead. Each worktree has clean, independent state.

**Configuration:**
```yaml
# .claude/sdlc.yaml
git:
  worktrees: true
  worktree_coordination: true  # Optional: prevent conflicts
```

## Principle 4: Context Assembly

**The Principle:** Before showing options, gather context from git state, active tasks, and auto memory.

**Why this matters:** User might already be mid-work or have context from previous sessions. Presenting this context avoids redundant questions and helps user pick up where they left off.

**Context sources:**
1. **Git branch:** Extract task ID from branch name
2. **Active tasks:** Show tasks already in progress
3. **Auto memory:** Search for recent work context
4. **Child tasks:** Show sub-tasks of active parents
