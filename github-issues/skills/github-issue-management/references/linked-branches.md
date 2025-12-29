# Linked Development Branches

Link development branches to issues for better tracking and workflow integration.

## Commands Reference

### gh issue-ext branch create

Create a new branch linked to an issue.

```bash
gh issue-ext branch create <issue> [--name <branch-name>]
```

**Arguments:**
- `<issue>` - Issue number to link
- `--name <branch-name>` - Custom branch name (optional, auto-generated if omitted)

**Examples:**
```bash
# Auto-generated name (based on issue number)
gh issue-ext branch create 42

# Custom name
gh issue-ext branch create 42 --name feature/user-authentication
```

**Output:**
```
Creating linked branch...
Created branch 'feature/user-authentication' linked to issue #42

To check out the branch locally:
  git fetch origin && git checkout feature/user-authentication
```

---

### gh issue-ext branch list

List branches linked to an issue.

```bash
gh issue-ext branch list <issue> [--json]
```

**Arguments:**
- `<issue>` - Issue number
- `--json` - Output in JSON format

**Example:**
```bash
gh issue-ext branch list 42
```

**Output:**
```
Linked branches for #42: Implement user authentication
Total: 2

  feature/user-authentication (a1b2c3d)
  fix/auth-timeout (e4f5g6h)
```

**JSON Output:**
```bash
gh issue-ext branch list 42 --json
```
```json
{
  "title": "Implement user authentication",
  "number": 42,
  "linkedBranches": {
    "totalCount": 2,
    "nodes": [
      {
        "id": "LB_xyz123",
        "ref": {
          "name": "feature/user-authentication",
          "target": {"oid": "a1b2c3d4e5f6"}
        }
      },
      {
        "id": "LB_abc789",
        "ref": {
          "name": "fix/auth-timeout",
          "target": {"oid": "e4f5g6h7i8j9"}
        }
      }
    ]
  }
}
```

---

### gh issue-ext branch delete

Unlink a branch from an issue (does NOT delete the branch).

```bash
gh issue-ext branch delete <issue> <branch-name>
```

**Arguments:**
- `<issue>` - Issue number
- `<branch-name>` - Name of branch to unlink

**Example:**
```bash
gh issue-ext branch delete 42 feature/user-authentication
```

**Output:**
```
Unlinking branch...
Unlinked branch 'feature/user-authentication' from issue

Note: The branch still exists on the remote. To delete it:
  git push origin --delete feature/user-authentication
```

---

## Alternative: gh issue develop

The built-in `gh issue develop` command provides similar functionality with some additional features.

### Creating Branches

```bash
# Create and checkout
gh issue develop 42 --checkout

# With custom name
gh issue develop 42 --name feature/auth --checkout

# From specific base branch
gh issue develop 42 --base develop --checkout

# Without checkout (just create)
gh issue develop 42 --name feature/auth
```

### Listing Branches

```bash
# List linked branches
gh issue develop --list 42
```

### Key Differences

| Feature | gh issue-ext branch | gh issue develop |
|---------|--------------------|--------------------|
| Create branch | Yes | Yes |
| Custom name | --name flag | --name flag |
| Auto checkout | No (manual step) | --checkout flag |
| Base branch | Uses default | --base flag |
| Delete/unlink | Yes | No |
| JSON output | Yes | No |

---

## Common Patterns

### Feature Branch Workflow

```bash
# 1. Create issue
gh issue create --title "Add password reset" --label "feature"
# Created #50

# 2. Create linked branch
gh issue-ext branch create 50 --name feature/password-reset

# 3. Checkout and work
git fetch origin
git checkout feature/password-reset

# 4. Make changes, commit, push
git add .
git commit -m "Implement password reset flow"
git push origin feature/password-reset

# 5. Create PR (links automatically via branch)
gh pr create --title "Add password reset" --body "Closes #50"
```

### Quick Development Start

Using `gh issue develop` for faster workflow:

```bash
# Create and checkout in one command
gh issue develop 50 --name feature/password-reset --checkout

# Now you're on the branch, ready to code
```

### Multiple Branches per Issue

Sometimes you need multiple branches for one issue:

```bash
# Main feature branch
gh issue-ext branch create 42 --name feature/auth

# Separate branch for a specific approach
gh issue-ext branch create 42 --name feature/auth-oauth

# Bug fix discovered during development
gh issue-ext branch create 42 --name fix/auth-race-condition

# Check all branches
gh issue-ext branch list 42
```

### Branch Naming Conventions

Recommended prefixes:
- `feature/` - New functionality
- `fix/` - Bug fixes
- `refactor/` - Code restructuring
- `docs/` - Documentation
- `test/` - Test additions
- `chore/` - Maintenance tasks

Example with issue number:
```bash
gh issue-ext branch create 42 --name feature/42-user-authentication
```

---

## Pull Request Integration

### Automatic Issue Linking

When you create a PR from a linked branch, GitHub may auto-link the issue. You can also use keywords:

```bash
# PR body closes the issue when merged
gh pr create --title "Add auth" --body "Closes #42"

# Or just references without closing
gh pr create --title "Add auth" --body "Related to #42"
```

### Querying Linked PRs

```bash
# Show PRs that would close an issue
gh issue-ext show 42 --json | jq '.closedByPullRequestsReferences'
```

---

## Cleanup Workflow

After merging a PR:

```bash
# 1. Unlink the branch from issue
gh issue-ext branch delete 42 feature/user-authentication

# 2. Delete the remote branch
git push origin --delete feature/user-authentication

# 3. Delete local branch
git branch -d feature/user-authentication

# 4. Close the issue (if not auto-closed)
gh issue close 42 --comment "Completed in PR #100"
```

Or let GitHub handle it:
- Enable "Automatically delete head branches" in repo settings
- Use "Closes #42" in PR body for auto-close

---

## Limitations

1. **Same repository**: Branch must be in the same repo as issue
2. **Branch must exist**: Cannot link non-existent branches
3. **No cross-repo linking**: Cannot link branch in fork to upstream issue

---

## GraphQL Details

**createLinkedBranch mutation:**
```graphql
mutation($issueId: ID!, $oid: GitObjectID!, $name: String) {
  createLinkedBranch(input: {
    issueId: $issueId,
    oid: $oid,
    name: $name
  }) {
    linkedBranch {
      ref { name }
    }
    issue { title number }
  }
}
```

**deleteLinkedBranch mutation:**
```graphql
mutation($branchId: ID!) {
  deleteLinkedBranch(input: { linkedBranchId: $branchId }) {
    issue { title number }
  }
}
```

**Query linked branches:**
```graphql
query($issueId: ID!) {
  node(id: $issueId) {
    ... on Issue {
      linkedBranches(first: 50) {
        nodes {
          id
          ref {
            name
            target { oid }
          }
        }
      }
    }
  }
}
```
