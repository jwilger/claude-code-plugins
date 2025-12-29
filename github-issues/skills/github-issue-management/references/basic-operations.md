# Basic GitHub Issue Operations

## gh issue create

Create a new issue in the current repository.

### Syntax
```bash
gh issue create [flags]
```

### Common Flags
| Flag | Description |
|------|-------------|
| `--title`, `-t` | Issue title (required unless interactive) |
| `--body`, `-b` | Issue body/description |
| `--label`, `-l` | Add label (can repeat for multiple) |
| `--assignee`, `-a` | Assign to user (@me for self) |
| `--milestone`, `-m` | Add to milestone |
| `--project`, `-p` | Add to project |
| `--web`, `-w` | Open browser to create |

### Examples

```bash
# Minimal creation
gh issue create -t "Fix login timeout"

# With description
gh issue create -t "Add dark mode" -b "Implement system preference detection and manual toggle"

# With metadata
gh issue create -t "API rate limiting" -l "enhancement" -l "backend" -a "@me"

# From file
gh issue create -t "Release notes" -b "$(cat CHANGELOG.md)"
```

---

## gh issue view

View issue details.

### Syntax
```bash
gh issue view <number> [flags]
```

### Common Flags
| Flag | Description |
|------|-------------|
| `--json` | Output specific fields as JSON |
| `--jq` | Filter JSON output |
| `--web`, `-w` | Open in browser |
| `--comments` | Show comments |

### Available JSON Fields
- `number`, `title`, `body`, `state`, `url`
- `author`, `assignees`, `labels`, `milestone`
- `createdAt`, `updatedAt`, `closedAt`
- `comments`, `reactionGroups`
- `id` (node ID for GraphQL)

### Examples

```bash
# Basic view
gh issue view 42

# Get specific fields
gh issue view 42 --json number,title,state

# Get node ID for GraphQL operations
gh issue view 42 --json id -q '.id'

# Check if issue is open
gh issue view 42 --json state -q '.state == "OPEN"'
```

---

## gh issue list

List issues in the repository.

### Syntax
```bash
gh issue list [flags]
```

### Common Flags
| Flag | Description |
|------|-------------|
| `--state`, `-s` | Filter by state: open, closed, all |
| `--label`, `-l` | Filter by label |
| `--assignee`, `-a` | Filter by assignee |
| `--author`, `-A` | Filter by author |
| `--milestone`, `-m` | Filter by milestone |
| `--search`, `-S` | Search query |
| `--limit`, `-L` | Max results (default 30) |
| `--json` | JSON output |

### Examples

```bash
# All open issues
gh issue list

# Closed bugs
gh issue list -s closed -l bug

# My assigned issues
gh issue list -a "@me"

# Search
gh issue list -S "auth in:title"

# JSON for processing
gh issue list --json number,title,labels -L 100
```

---

## gh issue edit

Modify an existing issue.

### Syntax
```bash
gh issue edit <number> [flags]
```

### Common Flags
| Flag | Description |
|------|-------------|
| `--title` | Update title |
| `--body` | Update body |
| `--add-label` | Add label |
| `--remove-label` | Remove label |
| `--add-assignee` | Add assignee |
| `--remove-assignee` | Remove assignee |
| `--milestone` | Set milestone |

### Examples

```bash
# Update title
gh issue edit 42 --title "Updated: Fix login timeout"

# Add labels
gh issue edit 42 --add-label "in-progress" --add-label "P1"

# Remove and add
gh issue edit 42 --remove-label "needs-triage" --add-label "ready"

# Assign to someone
gh issue edit 42 --add-assignee "username"
```

---

## gh issue close / reopen

Change issue state.

### Syntax
```bash
gh issue close <number> [flags]
gh issue reopen <number>
```

### Close Flags
| Flag | Description |
|------|-------------|
| `--comment`, `-c` | Add closing comment |
| `--reason`, `-r` | Reason: completed, not_planned |

### Examples

```bash
# Simple close
gh issue close 42

# Close with comment
gh issue close 42 -c "Fixed in #50"

# Close as not planned
gh issue close 42 -r not_planned -c "Won't implement - out of scope"

# Reopen
gh issue reopen 42
```

---

## gh issue comment

Add comments to issues.

### Syntax
```bash
gh issue comment <number> [flags]
```

### Flags
| Flag | Description |
|------|-------------|
| `--body`, `-b` | Comment text |
| `--edit-last` | Edit your last comment |
| `--web`, `-w` | Open browser |

### Examples

```bash
# Add comment
gh issue comment 42 -b "Working on this now"

# From file
gh issue comment 42 -b "$(cat status-update.md)"
```

---

## gh issue transfer

Move issue to another repository.

### Syntax
```bash
gh issue transfer <number> <destination-repo>
```

### Example
```bash
gh issue transfer 42 other-org/other-repo
```

---

## gh issue pin / unpin

Pin important issues.

### Syntax
```bash
gh issue pin <number>
gh issue unpin <number>
```

### Example
```bash
# Pin a roadmap issue
gh issue pin 1

# Unpin when complete
gh issue unpin 1
```

---

## gh issue lock / unlock

Restrict conversation on issues.

### Syntax
```bash
gh issue lock <number> [--reason <reason>]
gh issue unlock <number>
```

### Lock Reasons
- `off_topic`
- `resolved`
- `spam`
- `too_heated`

### Example
```bash
gh issue lock 42 --reason resolved
```
