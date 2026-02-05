# Work Skill - Constraints and Boundaries

## DO:

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

## DON'T:

- Skip version check against `.claude/sdlc.yaml`
- Create branches without checking remote sync
- Allow work on tasks with unresolved blockers
- Mix branch modes (git-spice vs standard vs worktrees)
- Skip worktree coordination when enabled
- Forget to update task status to `active`

## Integration Points

### With Other Skills

**Requires:**
- `/sdlc:setup` - Must run first to create config
- `/sdlc:plan` - Creates tasks to work on

**Works with:**
- `/sdlc:pr` - Create PR after work complete
- `/sdlc:review` - Address PR feedback
- `/sdlc:complete` - Mark task done after merge

**Delegates to:**
- TDD agents (red/green/domain) - Implementation work
- Memory system - Context storage/retrieval

### With External Tools

**Required:**
- `gh` CLI - GitHub integration
- `dot` CLI - Task management
- `git` - Version control

**Optional:**
- git-spice (`gs` command) - Stacked PR workflow
- Worktree support - Parallel work

## Configuration Dependencies

```yaml
# .claude/sdlc.yaml
sdlc_version: "9.0.0"  # Must match plugin version

git:
  branch_prefix: "feature/"  # Default prefix for branches
  worktrees: false  # Enable worktree mode
  worktree_coordination: false  # Prevent conflicts

session_task_tracking: false  # Create session-level tasks

mode: "event-modeling"  # or "traditional"
```

## Error Handling

### Missing Config

```bash
if [ ! -f .claude/sdlc.yaml ]; then
  echo "❌ SDLC not configured. Run: /sdlc:setup"
  exit 1
fi
```

### Dirty Git State

```bash
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Uncommitted changes detected."
  echo "Options:"
  echo "  1. Commit: git add -A && git commit -m 'WIP'"
  echo "  2. Stash: git stash"
  echo "  3. Discard: git reset --hard"
  exit 1
fi
```

### No Ready Tasks

```bash
READY=$(dot ready --json)
if [ "$READY" = "[]" ]; then
  echo "No ready tasks. Options:"
  echo "  - Run /sdlc:plan to create tasks"
  echo "  - Check for blocked tasks: dot ls --blocked"
  exit 0
fi
```

### Worktree Already Exists

```bash
if [ -d "../worktrees/$TASK_ID" ]; then
  echo "⚠️ Worktree already exists"
  echo "Switch to it: cd ../worktrees/$TASK_ID"
  exit 1
fi
```
