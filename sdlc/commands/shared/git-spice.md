---
description: Git-spice stacked PR workflow guidance
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

# View stack status
gs stack
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
