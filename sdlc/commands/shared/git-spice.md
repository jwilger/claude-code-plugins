---
description: INVOKE when using git-spice for stacked PRs. Branch and submit commands
user-invocable: false
---

# Git-Spice Stacked PR Workflow

Git-spice (`gs`) enables stacked pull requests for incremental, reviewable changes.

## When to Use Git-Spice

Use git-spice when:
- Building on existing work in progress
- Creating incremental, dependent changes
- Already on a gs-managed branch

Use regular git when:
- Starting fresh work from main
- Simple, standalone changes
- No stacking needed

## Detection

Check if git-spice is available and if current branch is managed:
```bash
command -v gs && gs branch checkout 2>/dev/null
```

## Common Commands

```bash
# Create a new stacked branch
gs branch create <branch-name>

# Submit stack for review
gs stack submit

# Sync with upstream
gs repo sync

# Navigate stack
gs branch checkout <branch-name>
gs up    # Move up the stack
gs down  # Move down the stack

# View stack status (NOTE: `gs stack` alone does NOT work - use one of these)
gs log short    # Quick overview of stack branches
gs log long     # Detailed view with commits
gs branch checkout  # Shows current gs-managed branch
```

## Decision Tree

1. **Is git-spice installed?**
   - No → Use regular git workflow
   - Yes → Continue

2. **Is current branch managed by gs?**
   - No → Start with `gs branch create` or use regular git
   - Yes → Continue with `gs` commands

3. **Starting new work?**
   - From main → `gs repo sync && gs branch create <name>`
   - From existing gs branch → `gs branch create <name>` (stacks on current)

4. **Ready to submit?**
   - Single branch → `gs stack submit`
   - Full stack → `gs stack submit` from any branch in stack

## Error Handling

If gs commands fail:
1. Check if on gs-managed branch: `gs branch checkout`
2. Try syncing: `gs repo sync`
3. Fall back to regular git if gs is problematic

## Post-Sync Verification (MANDATORY)

**After `gs repo sync`, ALWAYS verify your branch state.** Sync can move branches unexpectedly when upstream PRs merge.

### Verification Steps

After every `gs repo sync`:

1. **Check base branch:**
   ```bash
   git log --oneline -3   # What commits are we based on?
   ```

2. **Verify expected files exist:**
   ```bash
   # For Rust projects:
   test -f Cargo.toml && echo "OK" || echo "MISSING!"

   # For Node projects:
   test -f package.json && echo "OK" || echo "MISSING!"

   # For Python projects:
   test -f pyproject.toml || test -f setup.py && echo "OK" || echo "MISSING!"
   ```

3. **Check the sync output carefully:**
   - Look for: `moved upstack onto <branch-name>`
   - If it moved onto an unexpected branch, you need recovery

### What Can Go Wrong

When a PR merges, `gs repo sync`:
- Deletes the merged branch locally
- Rebases dependent branches onto what IT THINKS is the correct base
- **This can be wrong** if the branch structure was complex

Example of a bad sync:
```
INF 16-implement-sqlite-event-store: moved upstack onto 7-add-task  # WRONG!
```
When it should have moved onto `main`.

## Recovery from Bad Sync

If `gs repo sync` moved your branch incorrectly:

1. **Don't panic** - Your commits aren't lost

2. **Check where you ARE:**
   ```bash
   git log --oneline -5        # See recent commit history
   git log main --oneline -5   # Compare with main
   ```

3. **Explicitly move to correct base:**
   ```bash
   gs upstack onto main   # Move this branch (and children) onto main
   ```

4. **Verify recovery:**
   ```bash
   git log --oneline -5   # Confirm commits are there
   ls -la                 # Confirm files exist
   git diff main --stat   # Confirm expected changes
   ```

5. **If upstack fails**, use regular git:
   ```bash
   git rebase --onto main <wrong-base> <your-branch>
   ```

### Prevention Tips

- **Submit PRs one at a time** when possible
- **Wait for CI to pass** before syncing after a merge
- **Immediately verify** file presence after any sync
- **Use `gs log short`** to visualize stack state before and after sync
