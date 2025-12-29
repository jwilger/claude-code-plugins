# Blocking Relationships (Issue Dependencies)

Blocking relationships track dependencies between issues:
- **Blocked by**: This issue cannot proceed until another issue is complete
- **Blocking**: This issue is preventing another issue from proceeding

## Commands Reference

### gh issue-ext blocking add

Mark an issue as blocked by another issue.

```bash
gh issue-ext blocking add <blocked> <blocker>
```

**Arguments:**
- `<blocked>` - Issue number that IS BLOCKED (the dependent issue)
- `<blocker>` - Issue number that IS BLOCKING (the dependency)

**Example:**
```bash
# Issue #15 is blocked by issue #14
# (Issue #15 cannot be completed until #14 is done)
gh issue-ext blocking add 15 14
```

**Output:**
```
Adding blocking relationship...
#15 (Deploy to production) is now blocked by #14 (Pass QA testing)
```

**Important:** The argument order is `<blocked> <blocker>`:
- First argument: the issue waiting/blocked
- Second argument: the issue causing the block

---

### gh issue-ext blocking remove

Remove a blocking relationship.

```bash
gh issue-ext blocking remove <blocked> <blocker>
```

**Arguments:**
- `<blocked>` - The blocked issue number
- `<blocker>` - The blocking issue number

**Example:**
```bash
# Remove: #15 was blocked by #14
gh issue-ext blocking remove 15 14
```

---

### gh issue-ext blocking list

Show blocking relationships for an issue.

```bash
gh issue-ext blocking list <issue> [--json]
```

**Arguments:**
- `<issue>` - Issue number to check
- `--json` - Output in JSON format

**Example:**
```bash
gh issue-ext blocking list 15
```

**Output:**
```
Blocking relationships for #15: Deploy to production

Blocked by (2):
  #14 [OPEN] Pass QA testing
  #13 [CLOSED] Complete code review

Blocking (1):
  #16 [OPEN] Send release announcement
```

**JSON Output:**
```bash
gh issue-ext blocking list 15 --json
```
```json
{
  "title": "Deploy to production",
  "number": 15,
  "blockedBy": {
    "totalCount": 2,
    "nodes": [
      {"number": 14, "title": "Pass QA testing", "state": "OPEN"},
      {"number": 13, "title": "Complete code review", "state": "CLOSED"}
    ]
  },
  "blocking": {
    "totalCount": 1,
    "nodes": [
      {"number": 16, "title": "Send release announcement", "state": "OPEN"}
    ]
  }
}
```

---

## Common Patterns

### Sequential Dependency Chain

Create a chain of dependent issues:

```bash
# Create the issues
gh issue create --title "Design database schema"      # #10
gh issue create --title "Implement data models"       # #11
gh issue create --title "Create API endpoints"        # #12
gh issue create --title "Build frontend components"   # #13
gh issue create --title "Integration testing"         # #14
gh issue create --title "Deploy to staging"           # #15

# Create the chain: each blocked by the previous
gh issue-ext blocking add 11 10   # Models blocked by Schema
gh issue-ext blocking add 12 11   # API blocked by Models
gh issue-ext blocking add 13 12   # Frontend blocked by API
gh issue-ext blocking add 14 13   # Testing blocked by Frontend
gh issue-ext blocking add 15 14   # Deploy blocked by Testing
```

### Multiple Blockers (Join Pattern)

An issue may be blocked by multiple prerequisites:

```bash
# Issue #20 "Launch Feature" requires multiple things done first
gh issue-ext blocking add 20 17   # Blocked by: Code complete
gh issue-ext blocking add 20 18   # Blocked by: Documentation done
gh issue-ext blocking add 20 19   # Blocked by: QA approved

# Check what's blocking #20
gh issue-ext blocking list 20
```

### Multiple Blocked (Fork Pattern)

One issue may block several others:

```bash
# Issue #25 "API redesign" blocks multiple downstream issues
gh issue-ext blocking add 26 25   # Frontend update blocked by API
gh issue-ext blocking add 27 25   # Mobile app blocked by API
gh issue-ext blocking add 28 25   # SDK update blocked by API

# Check what #25 is blocking
gh issue-ext blocking list 25
```

### Combined with Sub-Issues

Use both hierarchies and dependencies:

```bash
# Epic #100: "Payment System"
# Story #101: "Credit card processing" (sub-issue of #100)
# Story #102: "Invoice generation" (sub-issue of #100)
# Story #103: "Payment history" (sub-issue of #100)

# Sub-issue structure
gh issue-ext sub add 100 101
gh issue-ext sub add 100 102
gh issue-ext sub add 100 103

# Dependencies between stories
gh issue-ext blocking add 102 101   # Invoice needs CC processing first
gh issue-ext blocking add 103 102   # History needs Invoice first
```

---

## Finding Blocked Work

### List All Blocked Issues

```bash
# Find issues with "blocked" label (if you use that convention)
gh issue list --label "blocked"

# Or check each issue's blocking status
for issue in $(gh issue list --json number -q '.[].number'); do
  blocked=$(gh issue-ext blocking list $issue --json | jq '.blockedBy.totalCount')
  if [ "$blocked" -gt 0 ]; then
    echo "Issue #$issue has $blocked blockers"
  fi
done
```

### Find Ready Work (Nothing Blocking)

```bash
# Find open issues not blocked by anything
gh issue list --json number,title -q '.[]' | while read -r line; do
  num=$(echo "$line" | jq -r '.number')
  blocked=$(gh issue-ext blocking list $num --json | jq '.blockedBy.totalCount')
  if [ "$blocked" -eq 0 ]; then
    echo "$line"
  fi
done
```

---

## Relationship Semantics

### Blocked By vs Blocking

| Perspective | Relationship | Meaning |
|-------------|--------------|---------|
| Issue A | blocked by B | A cannot proceed until B is done |
| Issue B | blocking A | B must be completed for A to proceed |

### When Blocker is Closed

Closing a blocking issue doesn't automatically remove the relationship. The blocked issue remains "blocked by" a closed issue until:
1. You explicitly remove the relationship
2. GitHub's UI may show it differently (closed blockers)

Best practice: Remove blocking relationships when the blocker is resolved:
```bash
# After closing #14, update the relationship
gh issue close 14
gh issue-ext blocking remove 15 14
```

---

## Limitations

1. **Maximum relationships**: 50 "blocked by" and 50 "blocking" per issue
2. **Same repository**: Both issues must be in the same repository
3. **No circular dependencies**: GitHub may not enforce this, but avoid A blocks B blocks A

---

## GraphQL Details

**addBlockedBy mutation:**
```graphql
mutation($blockedId: ID!, $blockerId: ID!) {
  addBlockedBy(input: {
    issueId: $blockedId,
    blockingIssueId: $blockerId
  }) {
    blockingIssue { title number }
    issue { title number }
  }
}
```

**Query blocking relationships:**
```graphql
query($issueId: ID!) {
  node(id: $issueId) {
    ... on Issue {
      blockedBy(first: 50) {
        nodes { number title state }
      }
      blocking(first: 50) {
        nodes { number title state }
      }
    }
  }
}
```
