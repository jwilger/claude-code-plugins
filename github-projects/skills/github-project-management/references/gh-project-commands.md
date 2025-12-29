# Native gh project CLI Commands Reference

This reference documents the built-in `gh project` commands available in GitHub CLI 2.22.0+.

## Project-Level Commands

### gh project list

List projects for a user or organization:

```bash
gh project list --owner jwilger
gh project list --owner myorg --closed    # Include closed projects
gh project list --owner "@me" --limit 50  # Current user's projects
```

**Flags:**
- `--owner <login>` - Project owner (use "@me" for current user)
- `--closed` - Include closed projects
- `-L, --limit <int>` - Max projects (default 30)
- `--format json` - JSON output
- `-w, --web` - Open in browser

### gh project view

View project details:

```bash
gh project view 11 --owner jwilger
gh project view 11 --owner jwilger --format json
gh project view 11 --owner jwilger --web
```

**JSON Output Fields:**
```json
{
  "id": "PVT_kwHNBnbOAS4m7A",
  "number": 11,
  "title": "Project Name",
  "closed": false,
  "url": "https://github.com/users/jwilger/projects/11",
  "owner": {"login": "jwilger", "type": "User"},
  "items": {"totalCount": 243},
  "fields": {"totalCount": 11}
}
```

### gh project create

Create a new project:

```bash
gh project create --owner jwilger --title "New Project"
gh project create --owner myorg --title "Team Board"
```

### gh project edit

Modify project settings:

```bash
gh project edit 11 --owner jwilger --title "New Title"
gh project edit 11 --owner jwilger --visibility PUBLIC
```

### gh project close / delete

```bash
gh project close 11 --owner jwilger
gh project delete 11 --owner jwilger
```

---

## Field Commands

### gh project field-list

List all fields in a project:

```bash
gh project field-list 11 --owner jwilger --format json
```

**Output Structure:**
```json
{
  "fields": [
    {
      "id": "PVTF_xxx",
      "name": "Title",
      "type": "ProjectV2Field"
    },
    {
      "id": "PVTSSF_xxx",
      "name": "Status",
      "type": "ProjectV2SingleSelectField",
      "options": [
        {"id": "abc123", "name": "Backlog"},
        {"id": "def456", "name": "Ready"},
        {"id": "ghi789", "name": "In progress"},
        {"id": "jkl012", "name": "In review"},
        {"id": "mno345", "name": "Done"}
      ]
    },
    {
      "id": "PVTSSF_yyy",
      "name": "Priority",
      "type": "ProjectV2SingleSelectField",
      "options": [
        {"id": "p0id", "name": "P0"},
        {"id": "p1id", "name": "P1"},
        {"id": "p2id", "name": "P2"}
      ]
    }
  ]
}
```

### gh project field-create

Create a new field:

```bash
# Text field
gh project field-create 11 --owner jwilger --name "Notes" --data-type TEXT

# Single select field (like Status or Priority)
gh project field-create 11 --owner jwilger --name "Urgency" \
  --data-type SINGLE_SELECT \
  --single-select-options "Low,Medium,High,Critical"

# Date field
gh project field-create 11 --owner jwilger --name "Due Date" --data-type DATE

# Number field
gh project field-create 11 --owner jwilger --name "Story Points" --data-type NUMBER
```

### gh project field-delete

```bash
gh project field-delete --id PVTF_xxx
```

---

## Item Commands

### gh project item-list

List items in a project:

```bash
gh project item-list 11 --owner jwilger --format json
gh project item-list 11 --owner jwilger --limit 100
```

**Output Structure:**
```json
{
  "items": [
    {
      "id": "PVTI_xxx",
      "title": "Issue Title",
      "status": "Ready",
      "priority": "P1",
      "labels": ["bug", "urgent"],
      "assignees": ["jwilger"],
      "milestone": {"title": "1.0.0"},
      "repository": "https://github.com/owner/repo",
      "content": {
        "type": "Issue",
        "number": 42,
        "title": "Issue Title",
        "body": "Issue description...",
        "url": "https://github.com/owner/repo/issues/42",
        "repository": "owner/repo"
      }
    }
  ]
}
```

### gh project item-add

Add an existing issue or PR to a project:

```bash
gh project item-add 11 --owner jwilger \
  --url https://github.com/owner/repo/issues/42
```

### gh project item-create

Create a draft issue directly in the project:

```bash
gh project item-create 11 --owner jwilger --title "Draft item"
```

### gh project item-edit

Update a project item's field values:

```bash
# Update text field
gh project item-edit \
  --id PVTI_itemid \
  --project-id PVT_projectid \
  --field-id PVTF_fieldid \
  --text "New value"

# Update single select field (like Status)
gh project item-edit \
  --id PVTI_itemid \
  --project-id PVT_projectid \
  --field-id PVTSSF_statusfieldid \
  --single-select-option-id abc123

# Update date field
gh project item-edit \
  --id PVTI_itemid \
  --project-id PVT_projectid \
  --field-id PVTF_datefieldid \
  --date 2025-01-15

# Update number field
gh project item-edit \
  --id PVTI_itemid \
  --project-id PVT_projectid \
  --field-id PVTF_numberfieldid \
  --number 5

# Clear a field value
gh project item-edit \
  --id PVTI_itemid \
  --project-id PVT_projectid \
  --field-id PVTF_fieldid \
  --clear
```

**Important:** The native `item-edit` requires node IDs for all entities (item, project, field, option). Use `gh-project-ext` for friendlier status updates.

### gh project item-archive / item-delete

```bash
gh project item-archive --id PVTI_xxx --project-id PVT_yyy
gh project item-delete --id PVTI_xxx --project-id PVT_yyy
```

---

## Linking Commands

### gh project link / unlink

Associate a project with a repository:

```bash
gh project link 11 --owner jwilger --repo owner/repo
gh project unlink 11 --owner jwilger --repo owner/repo
```

---

## JSON Output Processing

### Filter Ready Items with jq

```bash
gh project item-list 11 --owner jwilger --format json | \
  jq '.items[] | select(.status == "Ready")'
```

### Get Status Field Options

```bash
gh project field-list 11 --owner jwilger --format json | \
  jq '.fields[] | select(.name == "Status") | .options'
```

### Find Item by Issue Number

```bash
gh project item-list 11 --owner jwilger --format json | \
  jq '.items[] | select(.content.number == 42)'
```

### Group by Status

```bash
gh project item-list 11 --owner jwilger --format json | \
  jq 'group_by(.status) | map({status: .[0].status, count: length})'
```

---

## GraphQL API

For operations not covered by CLI, use GraphQL directly:

### Get Project Node ID

```bash
gh api graphql -f query='
  query {
    user(login: "jwilger") {
      projectV2(number: 11) {
        id
      }
    }
  }
' --jq '.data.user.projectV2.id'
```

### Update Item Field Value

```bash
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: "PVT_xxx"
      itemId: "PVTI_yyy"
      fieldId: "PVTSSF_zzz"
      value: {singleSelectOptionId: "abc123"}
    }) {
      projectV2Item {
        id
      }
    }
  }
'
```

### Add Item to Project

```bash
gh api graphql -f query='
  mutation {
    addProjectV2ItemById(input: {
      projectId: "PVT_xxx"
      contentId: "I_abc123"
    }) {
      item {
        id
      }
    }
  }
'
```

---

## Common Patterns

### Get All IDs for an Update

To update an item's status, collect these IDs:

1. **Project ID**: `gh project view 11 --owner jwilger --format json | jq -r '.id'`
2. **Item ID**: From `item-list` output
3. **Field ID**: From `field-list` output (find Status field)
4. **Option ID**: From `field-list` Status field options

The `gh-project-ext` extension automates this ID resolution.

### Batch Operations

For bulk updates, use shell loops:

```bash
# Move all Ready items to In Progress
gh project item-list 11 --owner jwilger --format json | \
  jq -r '.items[] | select(.status == "Ready") | .id' | \
  while read id; do
    gh project item-edit --id "$id" \
      --project-id PVT_xxx \
      --field-id PVTSSF_yyy \
      --single-select-option-id "inprogress_id"
  done
```
