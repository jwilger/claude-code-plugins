# Worktree Coordination (v7.0.0)

## Overview

Worktree coordination prevents conflicts when multiple Claude Code instances work on different tasks in parallel worktrees. It tracks which tasks are being worked on, warns about conflicts, and automatically cleans up stale registrations.

## How It Works

### Registration

When you run `/sdlc:work` with worktree coordination enabled:

1. **Check for conflicts** - Verifies the task isn't already being worked on
2. **Check blockers** - Warns if a blocker task is in progress elsewhere
3. **Create worktree** - Sets up the isolated workspace
4. **Register** - Records the worktree location and session info in `.dots/.worktrees/<task-id>/`
5. **Heartbeat** - Updates `last_heartbeat` timestamp on session end

### Coordination State

Each task's coordination state is stored in `.dots/.worktrees/<task-id>/`:

```
.dots/.worktrees/myproject-add-login-abc123/
├── location          # Worktree path
├── session_id        # Claude Code session ID
├── started_at        # Unix timestamp when work started
├── last_heartbeat    # Unix timestamp of last activity
└── task_list_id      # TaskTools list ID for session resumability
```

### Liveness Tracking

- **Active**: `last_heartbeat` updated within last 30 minutes
- **Stale**: `last_heartbeat` older than 30 minutes (can be reclaimed)
- **Dead**: `last_heartbeat` older than 2 hours (automatically cleaned up)

The `last_heartbeat` is updated by a Stop hook whenever a Claude Code session ends.

## Conflict Prevention

### Same Task Conflict

If you try to start work on a task that's already active elsewhere:

```
⚠️  Task myproject-add-login-abc123 is already being worked on

Worktree: ../myproject-worktrees/myproject-add-login-abc123
Session:  claude-xyz789
Last activity: 5 minutes ago

This task is active in another Claude instance. To avoid conflicts:
  - Work on a different task, or
  - Close the other Claude instance first
```

### Blocker Conflict

If you try to start work on a task while its blocker is in progress elsewhere:

```
⚠️  Blocker task is being worked on in parallel

Task:     myproject-create-user-def456
Title:    Create user entity
Activity: 10 minutes ago

This blocker is active in another Claude instance.
Wait for it to complete or coordinate with the other instance.
```

### Stale Reclaim

If a task has a stale registration (> 30 min inactive):

```
⚠️  Task myproject-add-login-abc123 has a stale worktree registration
Last activity: 45 minutes ago

The previous session may have crashed or been abandoned.
Would you like to reclaim this task?
```

## Session Resumability

Coordination supports resuming work after interruptions:

1. **Task list ID stored** - When creating a worktree, the `CLAUDE_CODE_TASK_LIST_ID` is saved in `.claude-task-list-id` within the worktree
2. **Automatic restore** - When opening Claude Code in a worktree, the task list ID is automatically restored
3. **State preserved** - TDD cycle tasks and progress are visible when you resume

Example workflow:
```bash
# Start work
/sdlc:work myproject-add-login-abc123
# → Creates worktree at ../myproject-worktrees/myproject-add-login-abc123
# → Sets CLAUDE_CODE_TASK_LIST_ID=sdlc-myproject-add-login-abc123-1234567890

# Work for a while, then close Claude

# Later: Resume work
cd ../myproject-worktrees/myproject-add-login-abc123
claude
# → Automatically restores CLAUDE_CODE_TASK_LIST_ID
# → TaskList shows previous TDD cycle state
```

## Cleanup

### Automatic Cleanup

The system automatically cleans up:
- **On work start**: Removes registrations > 2 hours old
- **On task complete**: Removes the task's registration via `/sdlc:complete`

### Manual Cleanup

If you need to manually clean up orphaned registrations:

```bash
# Remove a specific task's registration
rm -rf .dots/.worktrees/<task-id>

# Remove all stale registrations (> 2 hours old)
find .dots/.worktrees -maxdepth 1 -type d -name "*-*-*" | while read dir; do
  if [ -f "$dir/last_heartbeat" ]; then
    age=$(( $(date +%s) - $(cat "$dir/last_heartbeat") ))
    if [ $age -gt 7200 ]; then
      echo "Removing stale: $(basename $dir)"
      rm -rf "$dir"
    fi
  fi
done
```

## Configuration

Enable worktree coordination in `.claude/sdlc.yaml`:

```yaml
git:
  worktrees: true  # Must be enabled first

features:
  worktree_coordination: true  # Enable conflict prevention
```

To enable during setup:
- Run `/sdlc:setup`
- Answer "Yes" to "Enable Git Worktrees?"
- Answer "Yes (Recommended)" to "Enable Worktree Coordination?"

## When to Use

### Good Use Cases

✅ **Parallel development of independent slices**
- Each slice is a separate vertical feature
- Slices share only event schemas (documented contracts)
- No implementation dependencies between slices

✅ **Experimentation in separate worktree**
- Try an alternative approach without affecting main work
- Easy to discard if experiment fails

✅ **Emergency hotfix while feature work is in progress**
- Main worktree has uncommitted feature work
- Hotfix worktree starts from clean main branch

### Bad Use Cases

❌ **Working on the same task in multiple worktrees**
- Coordination will block this (by design)
- If you need to switch machines, close Claude on first machine first

❌ **Working on dependent tasks in parallel**
- Coordination warns about this but doesn't block
- Wait for blocker to complete and merge first

❌ **Shared infrastructure changes**
- If multiple slices need the same infrastructure change, implement it first
- Merge to main before starting dependent slices

## Troubleshooting

### "Failed to acquire coordination lock"

Likely causes:
- Another instance is currently registering/unregistering a worktree
- Lock file left over from crashed process

Fix:
```bash
# Check if lock is stale (> 30 seconds old)
ls -la .dots/.worktrees/lock

# If stale, remove it
rmdir .dots/.worktrees/lock
```

### "Task already in progress" but no other instance running

Likely causes:
- Previous instance crashed without updating heartbeat
- Clock skew between when registration was created and current time

Fix:
- Wait 30 minutes for registration to become stale, then reclaim
- Or manually remove: `rm -rf .dots/.worktrees/<task-id>`

### Worktree exists but no registration

Likely causes:
- Coordination was enabled after worktree was created
- Registration was manually deleted

Fix:
- Work in the worktree is fine (no coordination conflict)
- Or remove worktree: `git worktree remove <path>`

### Multiple tasks show as in progress elsewhere

Likely causes:
- Network file system with clock differences
- Many Claude instances running simultaneously

Fix:
- Check actual worktrees: `git worktree list`
- Clean up registrations that don't match actual worktrees
- Consider disabling coordination if clock sync is unreliable

## Architecture

### Design Decisions

**Why file-based coordination?**
- No external dependencies (database, service)
- Works offline
- Simple to debug (just read the files)
- Git-friendly (can gitignore `.dots/.worktrees/`)

**Why 30-minute staleness threshold?**
- Balance between false positives (session still active) and false negatives (crashed session)
- Typical development session is continuous for > 30 minutes
- Short enough to recover from crashes quickly

**Why heartbeat on Stop hook only?**
- Simpler than periodic heartbeat (no background process)
- Sufficient for detection (sessions end frequently)
- Reduces file I/O overhead

**Why lock file instead of flock?**
- Works on all file systems (including NFS)
- Easy to detect stale locks (age-based)
- No need for process tracking

### Thread Safety

The coordination protocol uses a simple lock:
1. `mkdir .dots/.worktrees/lock` (atomic operation)
2. Perform read-modify-write
3. `rmdir .dots/.worktrees/lock`

This prevents race conditions when:
- Two instances try to start the same task simultaneously
- Registration is cleaned up while another instance checks it

### Performance Impact

Minimal:
- Coordination adds ~50-100ms to `/sdlc:work` startup
- Heartbeat update adds ~10-20ms to session end
- No impact during active development

## See Also

- [Workflow Documentation](workflow.md) - Overall task management workflow
- [Git Worktrees](https://git-scm.com/docs/git-worktree) - Official git-worktree documentation
- [Event Modeling](../event-modeling/) - Designing independent vertical slices
