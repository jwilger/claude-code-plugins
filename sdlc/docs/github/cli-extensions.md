# GitHub CLI Extensions Reference

The SDLC plugin depends on three custom GitHub CLI extensions that provide enhanced functionality beyond the native `gh` commands. **Always prefer these extensions over `gh api` calls when possible.**

## Installation

All extensions are installed automatically by `/sdlc:setup`:

```bash
gh extension install jwilger/gh-issue-ext
gh extension install jwilger/gh-project-ext
gh extension install agynio/gh-pr-review
```

## Extension Preference Hierarchy

When working with GitHub, prefer tools in this order:

1. **Extension commands** (most abstracted, purpose-built)
2. **Native gh commands** (e.g., `gh issue`, `gh pr`, `gh project`)
3. **`gh api` calls** (only when no CLI alternative exists)

### When `gh api` Is Acceptable

Use `gh api` only for operations without CLI support:
- Repository settings (merge methods, delete branch on merge)
- Branch rulesets configuration
- Other repository-level configuration

## gh-issue-ext (jwilger/gh-issue-ext)

Advanced GitHub issue management for sub-issues, blocking relationships, and linked branches.

### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `sub add <parent> <child>` | Add existing issue as sub-issue | `gh issue-ext sub add 10 42` |
| `sub remove <parent> <child>` | Remove sub-issue relationship | `gh issue-ext sub remove 10 42` |
| `sub list <issue>` | List all sub-issues | `gh issue-ext sub list 10` |
| `sub reorder <parent> <child> --after/--before <sibling>` | Reorder sub-issues | `gh issue-ext sub reorder 10 42 --after 41` |
| `blocking add <blocked> <blocker>` | Mark issue as blocked | `gh issue-ext blocking add 15 14` |
| `blocking remove <blocked> <blocker>` | Remove blocking relationship | `gh issue-ext blocking remove 15 14` |
| `blocking list <issue>` | Show blocking relationships | `gh issue-ext blocking list 15` |
| `branch create <issue> [--name <name>]` | Create and link development branch | `gh issue-ext branch create 42 --name feature/auth` |
| `branch delete <issue> <branch>` | Unlink/delete branch | `gh issue-ext branch delete 42 feature/auth` |
| `branch list <issue>` | List linked branches | `gh issue-ext branch list 42` |
| `show <issue>` | Display all relationships | `gh issue-ext show 10` |

### Use Cases in SDLC

- **`/sdlc:work`**: Lists sub-issues of In Progress items with `sub list`
- **`/sdlc:work`**: Can create linked branches with `branch create`
- **Epic/Story management**: Managing parent/child relationships

### Output Formats

Add `--json` flag for JSON output (useful for parsing in scripts).

## gh-project-ext (jwilger/gh-project-ext)

GitHub Projects V2 Kanban board management with Status columns and Priority swimlanes.

### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `setup` | Interactive project configuration | `gh project-ext setup` |
| `ready` | List Ready items sorted by priority | `gh project-ext ready` |
| `board` | Show Kanban board overview | `gh project-ext board` |
| `move <issue> <status>` | Move item to new status | `gh project-ext move 42 "In Progress"` |
| `claim <issue>` | Assign to me + move to In Progress | `gh project-ext claim 42` |
| `show` | Display project structure and fields | `gh project-ext show` |

### Global Flags

| Flag | Description |
|------|-------------|
| `--owner <owner>` | Project owner (user/org) |
| `--project <number>` | Project number |
| `--all` | Include sub-issues (default: top-level only) |
| `--all-repos` | Include all repositories |
| `--json` | Output as JSON |

### Configuration

Create `.github-project` in repo root or `~/.config/gh-project-ext/config`:

```yaml
owner: jwilger
project: 11
```

### Use Cases in SDLC

- **`/sdlc:work`**: Shows ready items with `ready`, moves with `move`
- **Claiming work**: `claim` handles assignment + status update together

### Native `gh project` Fallback

For operations not covered by the extension (like getting In Progress items):

```bash
gh project item-list <project-number> --owner <owner> --format json
```

## gh-pr-review (agynio/gh-pr-review)

Pull request review thread management - viewing, replying, and resolving.

### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `review view` | View structured review summary | `gh pr-review review view -R owner/repo --pr 123` |
| `review --start` | Open a pending review | `gh pr-review review --start --pr 123` |
| `review --add-comment` | Add inline comment to pending review | `gh pr-review review --add-comment --path file.rs --line 42 --body "..."` |
| `review --submit` | Submit pending review | `gh pr-review review --submit --event APPROVE` |
| `comments reply` | Reply to a review thread | `gh pr-review comments reply --thread-id <id> --body "..."` |
| `threads list` | List review threads | `gh pr-review threads list --pr 123` |
| `threads resolve` | Resolve a thread | `gh pr-review threads resolve --thread-id <id>` |
| `threads unresolve` | Reopen a thread | `gh pr-review threads unresolve --thread-id <id>` |

### Review View Flags

| Flag | Description |
|------|-------------|
| `--unresolved` | Show only unresolved threads |
| `--reviewer <username>` | Filter by reviewer |
| `--states <state>` | Filter by review state (CHANGES_REQUESTED, APPROVED, etc.) |

### Review Submission Events

- `APPROVE` - Approve the PR
- `COMMENT` - Comment without approval/rejection
- `REQUEST_CHANGES` - Request changes

### Use Cases in SDLC

- **`/sdlc:review`**: Fetches comments with `review view --unresolved`
- **`/sdlc:review`**: Replies in-thread with `comments reply`
- **`/sdlc:review`**: Can resolve threads with `threads resolve`

## Auto-Approval Patterns

Add these to your Claude Code settings for seamless usage:

```
Bash(gh issue:*)
Bash(gh issue-ext:*)
Bash(gh project:*)
Bash(gh project-ext:*)
Bash(gh pr:*)
Bash(gh pr-review:*)
```

## Comparison: Extension vs Native vs API

| Operation | Extension | Native gh | gh api |
|-----------|-----------|-----------|--------|
| List sub-issues | `gh issue-ext sub list` | - | GraphQL |
| Move on board | `gh project-ext move` | `gh project item-edit` | GraphQL |
| Reply to thread | `gh pr-review comments reply` | - | GraphQL |
| Add reviewer | - | `gh pr edit --add-reviewer` | REST |
| Repo merge settings | - | - | `gh api PATCH /repos` |
| Branch rulesets | - | - | `gh api POST /repos/.../rulesets` |

**Rule of thumb**: If there's an extension command, use it. If there's a native command, use that. Only fall back to `gh api` when there's no alternative.
