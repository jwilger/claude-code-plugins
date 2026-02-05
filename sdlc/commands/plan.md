---
description: INVOKE when event model slices are ready. Creates dot tasks from slices
argument-hint: [workflow-name]
allowed-tools:
  - Bash
  - Read
  - Glob
  - Write
  - Task
  - AskUserQuestion
  - mcp__memento__semantic_search
  - mcp__memento__create_entities
hooks:
  PreToolUse:
    - matcher: Read
      once: true
      hooks:
        - type: prompt
          prompt: |
            SDLC PLAN PREREQUISITES CHECK

            Before creating issues, verify:
            1. .claude/sdlc.yaml exists
            2. docs/ARCHITECTURE.md exists
            3. At least one workflow with slices exists

            If ARCHITECTURE.md is missing, stop and direct user to:
              /sdlc:design arch

            Respond with: {"ok": true}
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Store planning session results in memento:
            - Issues created (epic and story numbers)
            - Workflow planned
            - Any deferred items or concerns

            Output ONLY: {"ok": true}
---

# SDLC Plan

Create dot tasks from event model slices. This command bridges the design phase (event model + architecture) to actionable work items.

## The Mapping (NON-NEGOTIABLE)

| Event Model Concept | dot Task Equivalent |
|---------------------|---------------------|
| Workflow | Epic (parent task) |
| Vertical Slice | Story Task (1:1, child of epic) |
| GWT Scenarios | Acceptance Criteria (in task description) |
| Pattern Type | Metadata tag |

## Arguments

`$ARGUMENTS` may contain:
- `<workflow-name>` - Plan a specific workflow
- (no args) - Plan all unplanned workflows

## Steps

### 1. Load and Verify Prerequisites

Read `.claude/sdlc.yaml` for task management settings (dot prefix).

```bash
# Verify all prerequisites exist
test -f .claude/sdlc.yaml || { echo "Missing config. Run /sdlc:setup"; exit 1; }
test -d .dots || { echo "Missing .dots directory. Run /sdlc:setup to initialize dot"; exit 1; }
test -f docs/ARCHITECTURE.md || { echo "Missing architecture. Run /sdlc:design arch"; exit 1; }
ls docs/event_model/workflows/*/slices/*.md 2>/dev/null | head -1 || { echo "No slices. Run /sdlc:design workflow <name>"; exit 1; }
```

### 2. Find Workflows to Plan

If workflow name provided in arguments, use that. Otherwise, find all workflows:

```bash
ls -d docs/event_model/workflows/*/ 2>/dev/null | xargs -I{} basename {}

# Check which workflows already have tasks created
for workflow in $(ls -d docs/event_model/workflows/*/ | xargs -I{} basename {}); do
  dot ls --json | jq -r --arg w "Epic: $workflow" '.[] | select(.title == $w) | .id'
done
```

### 3. Search Memento for Context

```
mcp__memento__semantic_search: "planning session [project-name] [workflow-name]"
```

### 4. For Each Workflow - Create Epic Task

Read `docs/event_model/workflows/<workflow-name>/overview.md` and create:

```bash
# Create epic task with priority 1 (high)
EPIC_ID=$(dot add "Epic: <Workflow Name>" \
  -p 1 \
  -d "$(cat <<'EOF'
## Workflow: <name>

### Overview
<from workflow overview.md - user goal, actors involved>

### Vertical Slices
<placeholder - will be updated with story task IDs>

### Workflow Diagram
```mermaid
<mermaid diagram from overview.md>
```

---
Generated from: docs/event_model/workflows/<name>/overview.md
EOF
)" | grep -oP 'Created task: \K[^\s]+')

echo "Created epic: $EPIC_ID"
```

### 5. For Each Slice - Create Story Task

```bash
ls docs/event_model/workflows/<workflow-name>/slices/*.md

# Check for existing tasks for this slice
for slice_file in docs/event_model/workflows/<workflow-name>/slices/*.md; do
  slice_name=$(basename "$slice_file" .md)
  dot ls --json | jq -r --arg s "$slice_name" '.[] | select(.title == $s) | .id'
done
```

For each slice, read the document and create as a child of the epic:

```bash
# Create story task as child of epic with priority 2
STORY_ID=$(dot add "<Slice Name>" \
  -P "$EPIC_ID" \
  -p 2 \
  -d "$(cat <<'EOF'
## Slice: <name>
**Pattern**: <Command|View|Automation|Translation> | **Epic**: <epic-id>

### Description
<from slice document>

### Wireframe
<if present in slice document>

### Acceptance Criteria
<For each GWT scenario>
#### Scenario: <name>
- [ ] **Given**: <clause>
- [ ] **When**: <clause>
- [ ] **Then**: <clause>

---
Generated from: docs/event_model/workflows/<workflow>/slices/<slice>.md
EOF
)" | grep -oP 'Created task: \K[^\s]+')

echo "Created story: $STORY_ID (child of $EPIC_ID)"
```

**Note**: The `-P` flag automatically creates the parent-child relationship. No second command needed like with GitHub Issues.

### 6. Update Epic with Story Links

Use `dot tree` to verify the hierarchy was created correctly:

```bash
dot tree "$EPIC_ID"
```

The epic's description can be updated to include story task IDs:

```bash
# Get all child task IDs
STORY_IDS=$(dot tree "$EPIC_ID" --json | jq -r '.children[].id')

# Update epic description with story links
# Note: dot CLI doesn't have a direct update command for descriptions yet
# Consider creating a script or manually editing .dots/<epic-id>.md
```

**Note**: dot task descriptions are stored as markdown files in `.dots/`. To update programmatically, you can directly edit `.dots/<task-id>.md`.

### 7. Store in Memento

```
mcp__memento__create_entities:
  name: "<Workflow> Planning Session [date]"
  entityType: "planning_session"
  observations:
    - "Project: <name> | Path: <path> | Scope: PROJECT_SPECIFIC"
    - "Workflow: <workflow-name>"
    - "Epic: <epic-id>"
    - "Stories created: <count>"
    - "Story task IDs: <id1>, <id2>, <id3>..."
```

### 8. Display Results

```
Planning Complete: <workflow-name>

Epic: <epic-id> - Epic: <Workflow Name>

Stories Created: <total-count>
  Command: <id1>, <id2>
  View: <id3>
  Automation: <id4>
  Translation: <id5>

Verify hierarchy:
  dot tree <epic-id>

Next: /sdlc:work to start a story
```

## Optional Enhancement: Three-Perspective Review

For complex stories, offer perspective reviews:

```
Task tool with subagent_type="sdlc:story":
  Review story <task-id> from business value perspective.
  Check: clear user value, appropriate slice thinness, complete GWT scenarios.

Task tool with subagent_type="sdlc:architect":
  MODE: REVIEW
  Review story <task-id> from technical feasibility perspective.
  Check alignment with docs/ARCHITECTURE.md.

Task tool with subagent_type="sdlc:ux":
  Review story <task-id> from user experience perspective.
  Check journey coherence and accessibility.
```

Add review feedback by updating the task description in `.dots/<task-id>.md`.

## Error Handling

- **No config**: Direct to `/sdlc:setup`
- **No .dots/ directory**: Direct to `/sdlc:setup` to initialize dot
- **No architecture**: Direct to `/sdlc:design arch`
- **No workflows**: Direct to `/sdlc:design discover` then `/sdlc:design workflow`
- **Task creation fails**: Show error from dot CLI, suggest manual creation with `dot add`, continue with remaining
- **Duplicate detection**: Skip already-created stories (check with `dot ls`), note in output

## Metadata Tags Used

Pattern types are stored as metadata on tasks and can be queried/filtered:
- `command` - Command pattern slices
- `view` - View pattern slices
- `automation` - Automation pattern slices
- `translation` - Translation pattern slices
