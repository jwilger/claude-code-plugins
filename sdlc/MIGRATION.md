# Migrating from sdlc v4.x to v5.0.0

## Overview

sdlc v5.0.0 replaces GitHub Issues/Projects with local dot CLI for task management.

### What Changed

| Component | v4.x | v5.0.0 |
|-----------|------|--------|
| Task Storage | GitHub Issues | Local `.dots/` files |
| Task IDs | Issue numbers (#123) | Full task IDs (myproject-add-login-abc123) |
| Task Status | GitHub Project board | dot CLI (`open`/`active`/`closed`) |
| Required Tools | `gh-issue-ext`, `gh-project-ext` | `dot` CLI |
| PR Closure | Automatic (via "Closes #123") | Manual (`/sdlc:complete`) |

### Why the Change

**Benefits:**
- Local-first (offline capable, no API limits)
- Fast (file-based, instant responses)
- Greppable (tasks are markdown files)
- Version-controlled (commit `.dots/` to git)

**Trade-offs:**
- No web UI
- Single-developer focus
- Manual task completion

---

## Prerequisites

### Install dot CLI

```bash
cargo install dot-cli
dot --version  # Verify >= 0.6.4
```

### Backup GitHub Issues (Optional)

```bash
gh issue list --limit 1000 --json number,title,body,state > issues-backup.json
```

---

## Migration Steps

### 1. Update Plugin

```bash
/plugin  # Force marketplace update
```

### 2. Run Setup

```bash
/sdlc:setup
```

Setup will:
- Detect v4.x → v5.0.0 upgrade
- Preserve existing settings (mode, git workflow, languages)
- Initialize dot CLI
- Prompt for task prefix
- Update configuration

**Choose task prefix**: Short identifier (1-2 words, lowercase)
- Example: `myapp` → `myapp-add-login-abc123`

### 3. Recreate Active Tasks

**Option A: Manual (Recommended for Active Work)**

```bash
# For each active GitHub issue
gh issue view 123

# Create dot task
dot add "<title>" -p 2 -d "<body from issue>"
```

**Option B: Fresh Start (Event Modeling)**

```bash
# Recreate from slices
/sdlc:plan
```

### 4. Update Branch Naming

| Old | New |
|-----|-----|
| `feature/123-add-login` | `feature/myproject-add-login-abc123` |

**Options:**
1. Finish current branches with old naming, use new naming for new work
2. Rename: `git branch -m old-name new-name`

### 5. Learn New Workflow

**Old (v4.x):**
```bash
/sdlc:work          # Pick issue #123
# ... work ...
/sdlc:pr            # PR with "Closes #123"
# PR merges → Issue auto-closes
```

**New (v5.0.0):**
```bash
/sdlc:work          # Pick task
# ... work ...
/sdlc:pr            # PR references task
# PR merges → Manual completion:
/sdlc:complete      # Close task
```

---

## Configuration Changes

### Old (v4.x)
```yaml
sdlc_version: "4.0.0"
github:
  project: 11
  owner: jwilger
board:
  statuses: [Backlog, Ready, In Progress, Review, Done]
```

### New (v5.0.0)
```yaml
sdlc_version: "5.0.0"
tasks:
  prefix: myproject
github:
  owner: jwilger
  repository: myrepo
# board removed (dot manages statuses)
```

---

## Command Reference

| Task | v4.x | v5.0.0 |
|------|------|--------|
| List tasks | `gh issue list` | `dot ls` |
| Ready tasks | `gh project-ext ready` | `dot ready` |
| Create task | `gh issue create` | `dot add "<title>"` |
| Start work | (auto-assign + move) | `dot on <task-id>` |
| View task | `gh issue view <num>` | `dot show <task-id>` |
| View hierarchy | `gh issue-ext sub list` | `dot tree <task-id>` |
| Complete task | (auto via "Closes #123") | `/sdlc:complete` |

**Unchanged:** `/sdlc:work`, `/sdlc:pr`, `/sdlc:review`, `/sdlc:specify`, `/sdlc:plan`

---

## Workflow Examples

### Starting Work

```bash
# v5.0.0
/sdlc:work
# Shows: dot tasks (unblocked, open)
# Select: myproject-add-login-abc123
# Branch: feature/myproject-add-login-abc123
# Status: active
```

### Creating PR

```bash
# v5.0.0
/sdlc:pr
# Extracts task ID from branch
# PR body: "Task: myproject-add-login-abc123"
# Task stays active
```

### Completing Work

```bash
# v5.0.0
# After PR merges:
/sdlc:complete
# Verifies PR merged
# Closes task: "Completed via PR #125"
# Prompts to close parent if all children done
```

---

## Troubleshooting

### "dot: command not found"
```bash
cargo install dot-cli
```

### ".dots/ doesn't exist"
```bash
/sdlc:setup  # Runs dot init
```

### "Can't find old issues"
GitHub issues still exist, just not used for task management:
```bash
gh issue list  # View
gh issue list --json number,title > backup.json  # Export
```

### "How to check blocked tasks?"
```bash
dot ready  # Shows only unblocked tasks
```

### "Parent won't close"
```bash
/sdlc:complete <last-child-id>
# Will prompt to close parent
```

---

## FAQ

**Q: What happens to my GitHub Issues?**
A: They remain unchanged. Keep as reference or close manually.

**Q: Can I still use GitHub Projects?**
A: No longer integrated. Use dot for tasks, GitHub for PRs only.

**Q: Must I migrate all issues?**
A: No. Migrate only active work. Use `/sdlc:plan` for new work from slices.

**Q: Can I switch back to v4.x?**
A: Yes, but you'll lose dot tasks. Pin v4.x in plugin settings.

**Q: Why manual task completion?**
A: Gives control: verify PR merged, close parent epics, better audit trail.

**Q: Can teams use dot CLI?**
A: dot is single-developer. For teams:
- Each dev has own `.dots/` (not committed)
- Use GitHub PRs for collaboration
- Or stay on v4.x for team task management

---

## Getting Help

- **Issues**: https://github.com/jwilger/claude-code-plugins/issues (tag: `sdlc`, `migration`)
- **Docs**: `sdlc/README.md`, `sdlc/skills/task-management/SKILL.md`
- **dot CLI**: https://github.com/ajeetdsouza/dot
