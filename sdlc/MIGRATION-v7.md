# Migration Guide: v6.0.0 → v7.0.0

## Overview

Version 7.0.0 adds two opt-in features to improve parallel development and workflow clarity:

1. **Worktree Coordination** - Prevents conflicts between parallel Claude instances
2. **Session Task Tracking** - Provides "what's next?" visibility using TaskTools

Both features are **backward compatible** - existing workflows continue to work unchanged.

## Breaking Changes

**None.** This is a non-breaking release.

## New Features

### 1. Worktree Coordination

Tracks which tasks are being worked on in which worktrees to prevent conflicts.

**Benefits:**
- Prevents two Claude instances from working on the same task
- Warns if starting a task while its blocker is in progress elsewhere
- Automatically cleans up stale registrations

**Requirements:**
- `git.worktrees: true` must be enabled
- File system with atomic `mkdir` (works on Linux, macOS, Windows, NFS)

**Configuration:**
```yaml
features:
  worktree_coordination: true
```

**See:** [Worktree Coordination Documentation](docs/task-management/worktree-coordination.md)

### 2. Session Task Tracking

Uses Claude Code's TaskTools to track TDD cycle progress and display "what's next?".

**Benefits:**
- Clear visual indicator of current TDD phase
- Shows what remains in current cycle
- Session-resumable (can close and reopen Claude)

**Requirements:**
- None (works with or without worktrees)

**Configuration:**
```yaml
features:
  session_task_tracking: true
```

**How It Works:**
- `/sdlc:work` creates a story-level task when starting work
- TDD cycle tasks (Red → Domain → Green → Domain) created on-demand
- After each phase, orchestrator displays session state via TaskList

**See:** [Workflow Documentation](docs/task-management/workflow.md)

## Migration Steps

### Automatic Migration

Run `/sdlc:setup` to automatically migrate:

```bash
/sdlc:setup
```

The setup command will:
1. Detect your current version (6.0.0)
2. Show what's new in v7.0.0
3. Ask if you want to enable new features
4. Update `.claude/sdlc.yaml` with feature flags
5. Create `.dots/.worktrees/` directory if coordination enabled
6. Update `sdlc_version` to "7.0.0"

### Manual Migration

If you prefer to edit configuration directly:

1. **Update version number** in `.claude/sdlc.yaml`:
   ```yaml
   sdlc_version: "7.0.0"
   ```

2. **Add feature flags** (optional):
   ```yaml
   features:
     worktree_coordination: true    # Only if git.worktrees: true
     session_task_tracking: true
   ```

3. **Create coordination directory** (if worktree_coordination enabled):
   ```bash
   mkdir -p .dots/.worktrees
   ```

4. **No other changes needed** - all existing configurations work as-is

## Feature Flag Defaults

If feature flags are not present in config, the default behavior is:

```yaml
features:
  worktree_coordination: false  # Disabled (backward compatible)
  session_task_tracking: false  # Disabled (backward compatible)
```

This preserves v6.0.0 behavior exactly.

## Recommended Settings

### For Parallel Development

If you use worktrees to work on multiple slices simultaneously:

```yaml
git:
  worktrees: true

features:
  worktree_coordination: true    # Prevents conflicts
  session_task_tracking: true    # Shows progress in each worktree
```

### For Solo Development

If you work on one task at a time:

```yaml
git:
  worktrees: false  # Or true if you want isolation

features:
  worktree_coordination: false   # Not needed for solo work
  session_task_tracking: true    # Still useful for "what's next?"
```

### For Traditional Git Workflow

If you don't use worktrees:

```yaml
git:
  worktrees: false

features:
  worktree_coordination: false   # N/A without worktrees
  session_task_tracking: true    # Optional (works without worktrees)
```

## Testing the Migration

After migrating, verify the features work:

### Test Worktree Coordination

1. **Start work on a task:**
   ```bash
   /sdlc:work myproject-test-one-abc123
   ```

2. **In a separate terminal, try to start the same task:**
   ```bash
   cd ../myproject-worktrees/myproject-test-one-abc123
   claude
   /sdlc:work myproject-test-one-abc123
   ```

3. **Expected result:**
   ```
   ⚠️  Task myproject-test-one-abc123 is already being worked on

   This task is active in another Claude instance. To avoid conflicts:
     - Work on a different task, or
     - Close the other Claude instance first
   ```

### Test Session Task Tracking

1. **Start work with tracking enabled:**
   ```bash
   /sdlc:work myproject-test-two-def456
   ```

2. **Begin TDD cycle:**
   ```
   "Let's implement the user validation feature"
   ```

3. **Expected result:**
   - Story-level task created and marked in_progress
   - TDD cycle tasks created (Red → Domain → Green → Domain)
   - Session state displayed after each phase

4. **Close and reopen Claude in the worktree:**
   ```bash
   cd ../myproject-worktrees/myproject-test-two-def456
   claude
   ```

5. **Expected result:**
   - TaskList shows previous TDD cycle state
   - "What's next?" guidance appears

## Rollback

To revert to v6.0.0 behavior:

1. **Disable features in `.claude/sdlc.yaml`:**
   ```yaml
   features:
     worktree_coordination: false
     session_task_tracking: false
   ```

2. **Or remove the features section entirely** (defaults to disabled)

3. **Clean up coordination directory** (optional):
   ```bash
   rm -rf .dots/.worktrees
   ```

No other changes needed - all v6.0.0 functionality remains intact.

## Common Questions

### Q: Do I have to enable these features?

**A:** No. Both are opt-in. Without the feature flags, v7.0.0 behaves identically to v6.0.0.

### Q: Can I enable session tracking without worktree coordination?

**A:** Yes. Session task tracking works with or without worktrees and doesn't require coordination.

### Q: Can I enable worktree coordination without session tracking?

**A:** Yes. Coordination works independently and doesn't require TaskTools tracking.

### Q: What happens to existing worktrees?

**A:** Existing worktrees continue to work. Coordination only tracks NEW worktrees created after enabling the feature.

### Q: Do the new features require external dependencies?

**A:** No. Both features use only built-in Claude Code capabilities (TaskTools) and file system operations.

### Q: Will this break my existing workflows?

**A:** No. All v6.0.0 workflows, commands, and configurations work unchanged in v7.0.0.

### Q: What if I have multiple projects?

**A:** Run `/sdlc:setup` in each project independently. Each project can have different feature flag settings.

### Q: Can I try the features and disable them later?

**A:** Yes. Simply set the feature flags to `false` or remove them from the config. No data loss or state corruption.

## Troubleshooting

### "Failed to acquire coordination lock"

**Cause:** Another instance is registering/unregistering a worktree, or lock file is stale.

**Fix:**
```bash
# Check lock age
ls -la .dots/.worktrees/lock

# If stale (> 30 seconds old), remove it
rmdir .dots/.worktrees/lock
```

### "Task already in progress" but no other instance

**Cause:** Previous instance crashed without updating heartbeat.

**Fix:** Wait 30 minutes for registration to become stale, or manually remove:
```bash
rm -rf .dots/.worktrees/<task-id>
```

### Session state not displayed

**Cause:** `session_task_tracking` is disabled or orchestration output style not active.

**Fix:**
1. Check feature flag: `grep "session_task_tracking" .claude/sdlc.yaml`
2. Verify output style: Check if `sdlc-rules` or `sdlc-marvin` is active

### TaskList shows empty

**Cause:** `CLAUDE_CODE_TASK_LIST_ID` not set or tasks created in different session.

**Fix:** Tasks are session-scoped. Each worktree has its own task list ID.

## Need Help?

- **Documentation:** See [docs/task-management/](docs/task-management/)
- **Issues:** Report at https://github.com/anthropics/claude-code/issues
- **Community:** Ask in Claude Code Discord

## See Also

- [Worktree Coordination Documentation](docs/task-management/worktree-coordination.md)
- [Workflow Documentation](docs/task-management/workflow.md)
- [CHANGELOG.md](CHANGELOG.md)
