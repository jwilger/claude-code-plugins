# Sub-Issues (Parent/Child Relationships)

Sub-issues allow hierarchical organization of GitHub issues, enabling structures like:
- Epics containing Stories
- Stories containing Tasks
- Any parent-child relationship

## Commands Reference

### gh issue-ext sub add

Add an existing issue as a sub-issue of a parent.

```bash
gh issue-ext sub add <parent> <child>
```

**Arguments:**
- `<parent>` - Issue number of the parent (e.g., 10)
- `<child>` - Issue number to add as sub-issue (e.g., 42)

**Example:**
```bash
# Add issue #42 as a sub-issue of #10
gh issue-ext sub add 10 42
```

**Output:**
```
Adding sub-issue relationship...
Added #42 (Implement login form) as sub-issue of #10 (User Authentication Epic)
```

---

### gh issue-ext sub remove

Remove a parent-child relationship.

```bash
gh issue-ext sub remove <parent> <child>
```

**Arguments:**
- `<parent>` - Parent issue number
- `<child>` - Child issue number to remove

**Example:**
```bash
# Remove #42 from parent #10
gh issue-ext sub remove 10 42
```

**Note:** This only removes the relationship. Both issues continue to exist.

---

### gh issue-ext sub list

List all sub-issues of a parent issue.

```bash
gh issue-ext sub list <issue> [--json]
```

**Arguments:**
- `<issue>` - Parent issue number
- `--json` - Output in JSON format

**Example:**
```bash
gh issue-ext sub list 10
```

**Output:**
```
Sub-issues of #10: User Authentication Epic
Total: 3

  #42 [OPEN] Implement login form
  #43 [OPEN] Add OAuth2 integration
  #44 [CLOSED] Create user model
```

**JSON Output:**
```bash
gh issue-ext sub list 10 --json
```
```json
{
  "title": "User Authentication Epic",
  "number": 10,
  "subIssues": {
    "totalCount": 3,
    "nodes": [
      {"number": 42, "title": "Implement login form", "state": "OPEN"},
      {"number": 43, "title": "Add OAuth2 integration", "state": "OPEN"},
      {"number": 44, "title": "Create user model", "state": "CLOSED"}
    ]
  }
}
```

---

### gh issue-ext sub reorder

Change the position of a sub-issue within its parent's list.

```bash
gh issue-ext sub reorder <parent> <child> --after <sibling>
gh issue-ext sub reorder <parent> <child> --before <sibling>
```

**Arguments:**
- `<parent>` - Parent issue number
- `<child>` - Sub-issue to move
- `--after <sibling>` - Place after this sibling
- `--before <sibling>` - Place before this sibling

**Examples:**
```bash
# Move #44 to appear after #42 in parent #10
gh issue-ext sub reorder 10 44 --after 42

# Move #42 to appear before #43 in parent #10
gh issue-ext sub reorder 10 42 --before 43
```

---

## Common Patterns

### Creating an Epic with Stories

```bash
# Step 1: Create the epic
gh issue create --title "Payment System Epic" --label "epic"
# Created issue #100

# Step 2: Create stories
gh issue create --title "Credit Card Processing"
# Created issue #101

gh issue create --title "Invoice Generation"
# Created issue #102

gh issue create --title "Payment History"
# Created issue #103

# Step 3: Link stories to epic
gh issue-ext sub add 100 101
gh issue-ext sub add 100 102
gh issue-ext sub add 100 103

# Step 4: Verify structure
gh issue-ext sub list 100
```

### Three-Level Hierarchy (Epic > Story > Task)

```bash
# Epic
gh issue create --title "User Onboarding" --label "epic"
# #200

# Story
gh issue create --title "Email Verification Flow" --label "story"
# #201
gh issue-ext sub add 200 201

# Tasks under story
gh issue create --title "Design verification email template" --label "task"
# #202
gh issue-ext sub add 201 202

gh issue create --title "Implement email sending service" --label "task"
# #203
gh issue-ext sub add 201 203

gh issue create --title "Add verification endpoint" --label "task"
# #204
gh issue-ext sub add 201 204
```

### Finding an Issue's Parent

```bash
# Using the show command
gh issue-ext show 42
# Output includes: "Parent: #10 - User Authentication Epic"

# JSON extraction
gh issue-ext show 42 --json | jq '.parent'
# {"number": 10, "title": "User Authentication Epic", "state": "OPEN"}
```

### Batch Operations

```bash
# Add multiple sub-issues to a parent
for issue in 101 102 103 104 105; do
  gh issue-ext sub add 100 $issue
done

# List and process sub-issues
gh issue-ext sub list 100 --json | jq -r '.subIssues.nodes[] | select(.state == "OPEN") | .number'
```

---

## Limitations

1. **Maximum depth**: 8 levels of nesting
2. **Maximum sub-issues**: 50 per parent
3. **Single parent**: An issue can only have one parent
4. **Same repository**: Parent and child must be in the same repo

---

## GraphQL Details

The extension uses these GraphQL operations:

**addSubIssue mutation:**
```graphql
mutation($parentId: ID!, $childId: ID!) {
  addSubIssue(input: { issueId: $parentId, subIssueId: $childId }) {
    issue { title number }
    subIssue { title number }
  }
}
```

**Requires header:** `GraphQL-Features: sub_issues`

**Query sub-issues:**
```graphql
query($issueId: ID!) {
  node(id: $issueId) {
    ... on Issue {
      subIssues(first: 50) {
        nodes { number title state }
      }
      parent { number title }
    }
  }
}
```
