---
name: work
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Start or continue work on an issue. Shows ready tasks, creates branch, marks task active. Use when beginning work, switching tasks, or when user asks to start development.
tags:
  - workflow
  - tdd
  - github
  - task-management
  - git-workflow
portability: tool-specific
dependencies:
  - tdd-constraints
  - github-issues
  - orchestration-protocol
  - memory-protocol
allowed-tools: Bash, Read, AskUserQuestion, Grep, TaskCreate, TaskUpdate
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
            Before completing, store the current work context in auto memory:
            - Issue being worked on
            - Branch name
            - Any decisions or discoveries made

            Output ONLY: {"ok": true}
---

# Work Skill

**Version:** 1.0.0
**Portability:** Tool-specific (requires gh CLI, dot CLI, git)

---

## Objective

Start or continue working on a task with automated branch management, worktree isolation, and TDD workflow integration. This skill is the primary entry point for beginning new work on a story or switching between tasks.

**Purpose:** Provide a smooth transition from task selection to active development, ensuring clean git state, proper branch/worktree setup, and immediate access to task acceptance criteria.

**Scope:**
- **Included:** Task selection from ready/active lists, branch/worktree creation, work context setup, session tracking, worktree coordination
- **Excluded:** Task creation (use plan skill), PR creation (use pr skill), code implementation (delegated to TDD agents)

---

## Core Principles

### Principle 1: Clean State Before Work

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

### Principle 2: Task Selection Hierarchy

**The Principle:** Show tasks in priority order: current work → child tasks of active parents → ready tasks (unblocked).

**Why this matters:** This ordering reflects natural workflow progression. Current work should be finished first, then child tasks complete their parents, then new work starts.

**Task Priority:**
1. **Currently working on** (detected from branch name or active status)
2. **Child tasks of active parents** (scoped work blocking parent completion)
3. **Ready tasks** (unblocked, sorted by priority)

**How to apply:**
```bash
# Detect current work
git branch --show-current  # feature/myproject-add-login-abc123
# → Task myproject-add-login-abc123 becomes default

# Get active tasks and their children
dot ls --status active --json
for parent_id in $ACTIVE_TASKS; do
  dot tree "$parent_id" --json
done

# Get ready tasks
dot ready --json
```

### Principle 3: Worktree Isolation for Parallel Development

**The Principle:** Worktrees enable parallel development of independent vertical slices without branch switching or context loss.

**Why this matters:** Event-modeled systems produce independent slices that can be developed in parallel. Worktrees give each slice its own directory, avoiding git branch confusion and enabling multiple Claude instances to work simultaneously.

**When to use worktrees:**
- Project has `git.worktrees: true` in `.claude/sdlc.yaml`
- Multiple independent slices ready for work
- Team wants to parallelize development

**Worktree workflow:**
```bash
# Main repo: Start work on slice 1
cd ~/project
/work myproject-slice-one-abc123
# Creates: ~/project-worktrees/myproject-slice-one-abc123

# New terminal: Start work on slice 2
cd ~/project
/work myproject-slice-two-def456
# Creates: ~/project-worktrees/myproject-slice-two-def456

# Third terminal: Work in slice 1's worktree
cd ~/project-worktrees/myproject-slice-one-abc123
claude  # Launch separate Claude instance
# This instance only sees slice 1's files
```

**Coordination (v7.0.0+):**
- With `worktree_coordination: true`, system prevents conflicts
- Attempting same task in two instances → blocked
- Working on task while blocker is in progress elsewhere → warned
- Stale registrations (>30 min inactive) → can be reclaimed

### Principle 4: Context Assembly

**The Principle:** Before showing options, gather context from git state, active tasks, and auto memory.

**Why this matters:** User might already be mid-work or have context from previous sessions. Presenting this context avoids redundant questions and helps user pick up where they left off.

**Context sources:**
1. **Git branch:** Extract task ID from branch name
2. **Active tasks:** Show tasks already in progress
3. **Auto memory:** Search for recent work context
4. **Child tasks:** Show sub-tasks of active parents

**Example:**
```bash
# Context from git
BRANCH=$(git branch --show-current)  # feature/myproject-login-abc123
TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')

# Context from auto memory
MEMORY_PATH="$HOME/.claude/projects/$(pwd | sed 's/\//-/g' | sed 's/^-//')/memory"
grep -r -i "current work\|in progress" "$MEMORY_PATH" --include="*.md" 2>/dev/null

# Context from active tasks
dot ls --status active --json

# Assembled context presented to user:
# "You were working on: myproject-login-abc123 - Add login form
# Continue this work, or select a different task?"
```

---

## Constraints and Boundaries

### DO:
- Check for clean git state before any branch operations
- Pull latest from remote before starting work
- Show task hierarchy (current → children → ready)
- Extract task ID from branch name when possible
- Mark tasks as `active` when work begins
- Create worktrees when `git.worktrees: true`
- Register worktrees when `worktree_coordination: true`
- Store work context in auto memory
- Create session tracking task when `session_task_tracking: true`
- Show acceptance criteria from task description

### DON'T:
- Start work with uncommitted changes
- Skip version check against `.claude/sdlc.yaml`
- Create branches without checking remote sync
- Allow work on tasks with unresolved blockers
- Mix branch modes (git-spice vs standard vs worktrees)
- Skip worktree coordination when enabled
- Forget to update task status to `active`

**Rationale:** These boundaries ensure clean state, proper coordination, and clear task tracking.

---

## Usage Patterns

### Pattern 1: Starting New Work (Clean State)

**Scenario:** User wants to start working on the next ready task.

**Approach:**
1. Check for `.claude/sdlc.yaml`, verify version
2. Verify clean git state and sync with remote
3. Search auto memory for recent work context
4. Fetch ready tasks with `dot ready --json`
5. Fetch active tasks with `dot ls --status active --json`
6. Show options in priority order
7. User selects task (or enters task ID directly)
8. Mark task as `active` with `dot on <task-id>`
9. Create branch or worktree using full task ID
10. Display task details and acceptance criteria

**Example:**
```bash
# User invokes: /work

# Check config
test -f .claude/sdlc.yaml || echo "Run /sdlc:setup first"

# Check version
grep "^sdlc_version:" .claude/sdlc.yaml
# If version mismatch, show warning (don't block)

# Verify clean state
git status --porcelain  # Must be empty
git fetch && git pull --ff-only

# Get ready tasks
dot ready --json | jq -r '.[] | "\(.id) - \(.title) [P\(.priority // "")]"'

# Show options
# "Select a task to work on:
#  1. myproject-add-search-def456 - Add search feature [P1]
#  2. myproject-fix-login-bug-ghi789 - Fix login redirect [P2]"

# User selects option 1
dot on myproject-add-search-def456
git checkout -b feature/myproject-add-search-def456

# Show task details
dot show myproject-add-search-def456
echo "Ready to work! The TDD workflow will guide you."
```

### Pattern 2: Continuing Existing Work

**Scenario:** User returns to work and is already on a feature branch.

**Approach:**
1. Detect current branch with `git branch --show-current`
2. Extract task ID from branch name
3. Check task status with `dot show <task-id>`
4. Present current work as default option
5. Allow switching to different task if desired
6. If continuing, show task details and proceed

**Example:**
```bash
# User invokes: /work
# Current branch: feature/myproject-add-search-def456

BRANCH=$(git branch --show-current)
TASK_ID=$(echo "$BRANCH" | sed 's/^feature\///')

dot show "$TASK_ID" --json | jq -r '.status'
# Output: active

# Present options:
# "Currently working on: myproject-add-search-def456 - Add search feature [Active]
#
# Continue this work, or select a different task?
#  1. Continue: myproject-add-search-def456 (Recommended)
#  2. Switch to: myproject-fix-login-bug-ghi789 - Fix login redirect
#  3. Other (enter task ID)"

# If user continues, show task details
dot show "$TASK_ID"
```

### Pattern 3: Starting Work with Worktrees (Parallel Development)

**Scenario:** Project uses worktrees for parallel slice development.

**Approach:**
1. Detect `git.worktrees: true` in config
2. Check for worktree coordination setting
3. If coordination enabled, check for conflicts (task already active, blocker in progress)
4. Create worktree in sibling directory
5. Register worktree if coordination enabled
6. Note worktree path for user
7. Optionally run project setup in worktree

**Example:**
```bash
# User invokes: /work myproject-slice-one-abc123

# Check config
grep "worktrees: true" .claude/sdlc.yaml
grep "worktree_coordination: true" .claude/sdlc.yaml

# Coordination: Check for conflicts
TASK_REGISTRY=".dots/.worktrees/myproject-slice-one-abc123"
if [ -d "$TASK_REGISTRY" ]; then
  HB_TIME=$(cat "$TASK_REGISTRY/last_heartbeat")
  CURRENT_TIME=$(date +%s)
  AGE=$((CURRENT_TIME - HB_TIME))
  if [ $AGE -lt 1800 ]; then
    echo "⚠️  Task already being worked on in another instance"
    exit 1
  fi
fi

# Create worktree
WORKTREE_BASE="../$(basename $(pwd))-worktrees"
mkdir -p "$WORKTREE_BASE"
git worktree add "$WORKTREE_BASE/myproject-slice-one-abc123" -b feature/myproject-slice-one-abc123

# Register worktree
mkdir -p ".dots/.worktrees/myproject-slice-one-abc123"
echo "$WORKTREE_BASE/myproject-slice-one-abc123" > ".dots/.worktrees/myproject-slice-one-abc123/location"
date +%s > ".dots/.worktrees/myproject-slice-one-abc123/last_heartbeat"

# Display
echo "✓ Worktree created: $WORKTREE_BASE/myproject-slice-one-abc123"
echo ""
echo "To work on this task:"
echo "  1. Open new terminal"
echo "  2. cd $WORKTREE_BASE/myproject-slice-one-abc123"
echo "  3. Launch Claude Code"
```

### Pattern 4: Working with Child Tasks of Active Parents

**Scenario:** User has an active parent task with child tasks that need completion.

**Approach:**
1. Detect active tasks with `dot ls --status active --json`
2. For each active task, fetch children with `dot tree <parent-id>`
3. Present child tasks prominently (after current work, before general ready tasks)
4. When user selects child, normal workflow applies

**Example:**
```bash
# User invokes: /work

# Get active tasks
ACTIVE_TASKS=$(dot ls --status active --json)
# Shows: myproject-user-auth-parent-abc123

# Get children
dot tree myproject-user-auth-parent-abc123 --json
# Shows:
#   myproject-validate-email-child1-def456 [open]
#   myproject-hash-password-child2-ghi789 [open]

# Present options:
# "Active work:
#  Parent: myproject-user-auth-parent-abc123 - User authentication [Active]
#    └─ Child: myproject-validate-email-child1-def456 - Validate email format [Open]
#    └─ Child: myproject-hash-password-child2-ghi789 - Hash passwords securely [Open]
#
# Select a task:
#  1. myproject-validate-email-child1-def456 - Validate email format (child of User authentication)
#  2. myproject-hash-password-child2-ghi789 - Hash passwords securely (child of User authentication)
#  3. myproject-new-feature-jkl012 - New feature [P1]"
```

---

## Integration with Other Skills

**Works well with:**
- **tdd-constraints:** Enforces red-green-domain cycle during implementation
- **github-issues:** Syncs task status with GitHub Issues (if configured)
- **orchestration-protocol:** Delegates file operations to specialized agents
- **memory-protocol:** Stores work context for session continuity
- **git-spice:** Alternative to worktrees for stacked PRs

**Prerequisites:**
- `.claude/sdlc.yaml` must exist (run setup skill first)
- `dot` CLI installed and initialized
- `gh` CLI installed and authenticated
- Git repository with remote configured

---

## Common Pitfalls

### Pitfall 1: Starting Work with Uncommitted Changes

**Problem:** User invokes /work while files are modified but not committed.

**Solution:**
- Check `git status --porcelain` before any branch operations
- If output is non-empty, block with error:
  ```
  ❌ Cannot start new work with uncommitted changes.

  Options:
    git add . && git commit -m "..."  # Commit changes
    git stash                         # Stash for later
    git checkout .                    # Discard changes
  ```

### Pitfall 2: Forgetting to Mark Task as Active

**Problem:** Branch is created but task status remains `open`, causing it to reappear in ready lists.

**Solution:**
- Always run `dot on <task-id>` immediately after task selection
- Verify status change with `dot show <task-id> --json | jq '.status'`

### Pitfall 3: Conflicting Worktree Sessions Without Coordination

**Problem:** Two Claude instances work on same task in different worktrees without coordination.

**Solution:**
- Enable `worktree_coordination: true` in `.claude/sdlc.yaml`
- System will check `.dots/.worktrees/<task-id>/` registry
- Block if heartbeat is recent (<30 min)
- Warn user: "Task already being worked on in another instance"

### Pitfall 4: Mixing Git Workflows

**Problem:** Project config has `git.worktrees: true` but user creates regular branches.

**Solution:**
- Detect workflow mode from config BEFORE creating branch
- If `worktrees: true`, always use `git worktree add`
- If `git-spice: true`, always use `gs branch create`
- If neither, use standard `git checkout -b`
- Don't let user accidentally mix modes

---

## Reference Documentation

See `reference.md` for:
- Detailed step-by-step workflow
- Complete bash command examples
- Error handling scenarios
- Session task tracking setup
- Worktree registry format
- Configuration validation

---

## Verification Checklist

Use this checklist to verify you're applying this skill correctly:

- [ ] `.claude/sdlc.yaml` exists and version checked
- [ ] Git state is clean (`git status --porcelain` is empty)
- [ ] Remote is synced (`git fetch && git pull --ff-only`)
- [ ] Auto memory searched for recent work context
- [ ] Ready tasks fetched with `dot ready --json`
- [ ] Active tasks and their children fetched
- [ ] Task hierarchy presented in priority order
- [ ] User selects task via AskUserQuestion or direct ID
- [ ] Task marked as `active` with `dot on <task-id>`
- [ ] Branch/worktree created using full task ID
- [ ] Worktree registered if coordination enabled
- [ ] Task details displayed with `dot show <task-id>`
- [ ] Work context stored in auto memory
- [ ] Session tracking task created if enabled

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- Task selection hierarchy
- Worktree isolation patterns
- Worktree coordination (v7.0.0 feature)
- Session task tracking integration
- Auto memory context assembly

---

## Metadata

**Extraction Source:** sdlc plugin v8.0.0 /sdlc:work command
**Extraction Date:** 2026-02-05
**Last Updated:** 2026-02-05
**Compatibility:** Claude Code (requires gh CLI, dot CLI, git)
**License:** MIT
