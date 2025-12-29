# Workflow Patterns for GitHub Projects

Common workflow patterns for managing work with GitHub Projects V2 Kanban boards.

## Daily Standup Workflow

### Morning Check-In

Start each day by reviewing the board state:

```bash
# See what's in progress (should match yesterday's work)
gh project-ext board

# Check ready queue for new work
gh project-ext ready
```

### Picking Up Work

Select work based on priority:

```bash
# View ready items sorted by priority
gh project-ext ready

# Claim the highest priority item
gh project-ext claim 42
```

The claim command:
1. Moves to "In progress"
2. Assigns to you
3. Optionally creates a linked branch

### End of Day

Move items to appropriate status:

```bash
# PR ready for review
gh project-ext move 42 "In review"

# Work continues tomorrow - leave in "In progress"
# (no action needed)

# Completed and merged
gh project-ext move 42 "Done"
```

---

## Feature Development Workflow

### 1. Triage to Ready

When a new issue is created, it starts in Backlog. After planning/grooming:

```bash
gh project-ext move 42 "Ready"
```

### 2. Start Development

```bash
# Claim the issue
gh project-ext claim 42

# Accept branch creation prompt
# Creates: feature/42-issue-title or similar
```

### 3. Development Cycle

```bash
# Work on the branch
git checkout feature/42-issue-title
# ... make changes ...
git commit -m "feat: implement feature"
git push
```

### 4. Create PR

```bash
# Create pull request
gh pr create --title "feat: implement feature" --body "Closes #42"
```

The PR body "Closes #42" links the PR to the issue.

### 5. Request Review

```bash
gh project-ext move 42 "In review"
```

### 6. Complete

After PR merge:

```bash
gh project-ext move 42 "Done"
```

---

## Epic and Sub-Issue Workflow

### Working with Hierarchies

When using sub-issues (via github-issues plugin):

```bash
# View only top-level items (epics/stories)
gh project-ext ready

# View all items including sub-issues
gh project-ext ready --all
```

### Epic Progress Tracking

The board shows top-level items by default. Check epic progress via:

```bash
# View sub-issues of an epic
gh issue-ext sub list 100

# Check project board for the epic
gh issue view 100 --json projectItems
```

### Sub-Issue Workflow

Sub-issues follow the same workflow but may not appear on the default board:

```bash
# Work on sub-issue
gh project-ext claim 101 --all  # May need --all flag

# Or use github-issues directly
gh issue edit 101 --add-assignee "@me"
gh project-ext move 101 "In progress"
```

---

## Multi-Repository Workflow

### Cross-Repo Project View

Projects can span multiple repositories:

```bash
# See all repos (not just current)
gh project-ext board --all-repos
gh project-ext ready --all-repos
```

### Working Across Repos

When claiming an issue from another repo:

```bash
# The claim command works, but branch creation targets current repo
gh project-ext claim 42

# For branch in the correct repo, use gh issue develop
gh issue develop 42 -R owner/other-repo --checkout
```

---

## Priority Management

### Priority Queue

Items are sorted by priority:
- **P0**: Critical/urgent - work on immediately
- **P1**: High priority - complete soon
- **P2**: Normal priority - work after P0/P1

### Viewing by Priority

```bash
# Ready items are auto-sorted by priority
gh project-ext ready

# Output groups by priority:
# === P0 ===
#   #42: Critical security fix
# === P1 ===
#   #45: Important feature
# === P2 ===
#   #50: Nice to have
```

### Changing Priority

Priority is a project field. To update:

```bash
# Use native gh project command
# First, get field and option IDs
gh project field-list 11 --owner jwilger --format json | \
  jq '.fields[] | select(.name == "Priority")'

# Then update (complex, prefer GitHub UI for priority changes)
gh project item-edit --id PVTI_xxx --project-id PVT_xxx \
  --field-id PVTSSF_priorityfieldid \
  --single-select-option-id p0optionid
```

For frequent priority changes, consider extending gh-project-ext.

---

## Status Transitions

### Valid Transitions

```
Backlog → Ready         (Groomed, ready for work)
Ready → In progress     (Work started)
In progress → In review (PR created)
In review → Done        (PR merged)

# Backward transitions (if needed)
In review → In progress (PR needs changes)
In progress → Ready     (Work paused/blocked)
```

### Moving Items

```bash
gh project-ext move <issue> <status>

# Examples
gh project-ext move 42 "Ready"
gh project-ext move 42 "In progress"
gh project-ext move 42 "In review"
gh project-ext move 42 "Done"
```

---

## Blocked Work Pattern

### When Work is Blocked

If an issue becomes blocked:

```bash
# Add blocking relationship (via github-issues)
gh issue-ext blocking add 42 41  # 42 blocked by 41

# Move back to Ready or leave in progress with a comment
gh issue comment 42 --body "Blocked by #41"
```

### Finding Blocked Work

```bash
# Check blocking relationships
gh issue-ext blocking list 42

# See what blocks an issue
gh issue-ext show 42
```

---

## Sprint/Iteration Workflow

### Setting Up Iterations

If your project uses Iteration fields:

```bash
# Create iteration field
gh project field-create 11 --owner jwilger \
  --name "Sprint" --data-type ITERATION
```

### Filtering by Sprint

```bash
# Use jq to filter by iteration
gh project item-list 11 --owner jwilger --format json | \
  jq '.items[] | select(.sprint == "Sprint 1")'
```

---

## Automation Patterns

### Shell Script: Morning Report

```bash
#!/bin/bash
# morning-report.sh

echo "=== Ready Work ==="
gh project-ext ready

echo ""
echo "=== My In Progress ==="
gh project item-list 11 --owner jwilger --format json | \
  jq -r '.items[] | select(.status == "In progress" and (.assignees | index("jwilger"))) | "#\(.content.number): \(.title)"'
```

### Shell Script: End-of-Day Summary

```bash
#!/bin/bash
# eod-summary.sh

echo "=== Completed Today ==="
gh project item-list 11 --owner jwilger --format json | \
  jq -r '.items[] | select(.status == "Done") | "#\(.content.number): \(.title)"' | head -10

echo ""
echo "=== Still In Progress ==="
gh project item-list 11 --owner jwilger --format json | \
  jq -r '.items[] | select(.status == "In progress") | "#\(.content.number): \(.title)"'
```

---

## Integration with CI/CD

### Auto-Move on PR Events

GitHub Actions can automatically move items:

```yaml
# .github/workflows/project-automation.yml
name: Project Automation

on:
  pull_request:
    types: [opened, closed]

jobs:
  update-project:
    runs-on: ubuntu-latest
    steps:
      - name: Move to In Review on PR open
        if: github.event.action == 'opened'
        run: |
          # Extract issue number from branch or PR body
          # Move to "In review"

      - name: Move to Done on PR merge
        if: github.event.action == 'closed' && github.event.pull_request.merged
        run: |
          # Move linked issues to "Done"
```

### Using Built-in Workflows

GitHub Projects has built-in automation:
- Auto-add items when issues/PRs are created
- Auto-move when PRs are merged
- Auto-archive when issues are closed

Configure via Project → Settings → Workflows.

---

## Best Practices Summary

1. **Check ready queue first** - Start with `gh project-ext ready`
2. **Claim before coding** - Use `claim` to signal work started
3. **Update status promptly** - Move items as work progresses
4. **Use branches** - Accept branch creation for traceability
5. **Link PRs to issues** - Use "Closes #X" in PR descriptions
6. **Review board regularly** - Use `board` for project health
7. **Filter appropriately** - Use `--all` and `--all-repos` as needed
8. **Automate where possible** - Use GitHub Actions for repetitive updates
