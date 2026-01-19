---
description: INVOKE when event model slices are ready. Creates GitHub issues from slices
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

Create GitHub issues from event model slices. This command bridges the design phase (event model + architecture) to actionable work items.

## The Mapping (NON-NEGOTIABLE)

| Event Model Concept | GitHub Issue Equivalent |
|---------------------|-------------------------|
| Workflow | Epic (parent issue) |
| Vertical Slice | Story Issue (1:1) |
| GWT Scenarios | Acceptance Criteria |
| Pattern Type | Label |

## Arguments

`$ARGUMENTS` may contain:
- `<workflow-name>` - Plan a specific workflow
- (no args) - Plan all unplanned workflows

## Steps

### 1. Load and Verify Prerequisites

Read `.claude/sdlc.yaml` for GitHub project settings (project number, owner, board status names).

```bash
# Verify all prerequisites exist
test -f .claude/sdlc.yaml || { echo "Missing config. Run /sdlc:setup"; exit 1; }
test -f docs/ARCHITECTURE.md || { echo "Missing architecture. Run /sdlc:design arch"; exit 1; }
ls docs/event_model/workflows/*/slices/*.md 2>/dev/null | head -1 || { echo "No slices. Run /sdlc:design workflow <name>"; exit 1; }
```

### 2. Find Workflows to Plan

If workflow name provided in arguments, use that. Otherwise, find all workflows:

```bash
ls -d docs/event_model/workflows/*/ 2>/dev/null | xargs -I{} basename {}
gh issue list --label "event-model,epic" --search "<workflow-name>" --json number,title
```

### 3. Search Memento for Context

```
mcp__memento__semantic_search: "planning session [project-name] [workflow-name]"
```

### 4. For Each Workflow - Create Epic

Read `docs/event_model/workflows/<workflow-name>/overview.md` and create:

```bash
gh issue create \
  --title "Epic: <Workflow Name>" \
  --label "event-model,epic,<workflow-name>" \
  --body "$(cat <<'EOF'
## Workflow: <name>

### Overview
<from workflow overview.md - user goal, actors involved>

### Vertical Slices
<placeholder - will be updated with story issue numbers>

### Workflow Diagram
```mermaid
<mermaid diagram from overview.md>
```

---
Generated from: docs/event_model/workflows/<name>/overview.md
EOF
)"
```

### 5. For Each Slice - Create Story Issue

```bash
ls docs/event_model/workflows/<workflow-name>/slices/*.md
gh issue list --label "event-model,<workflow-name>,<slice-name>" --json number  # Check existing
```

For each slice, read the document and create:

> **CRITICAL: Sub-issues require TWO commands**
>
> GitHub has no `--parent` flag for `gh issue create`. You must:
> 1. Create the issue with `gh issue create`
> 2. Link it using `gh issue-ext sub add <epic> <story>`

```bash
# Step 1: Create the story issue
gh issue create \
  --title "<Slice Name>" \
  --label "event-model,<workflow-name>,<pattern-type>" \
  --body "$(cat <<'EOF'
## Slice: <name>
**Pattern**: <Command|View|Automation|Translation> | **Epic**: #<epic-number>

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
)"

# Step 2: Link as sub-issue (REQUIRED - there is no --parent flag!)
gh issue-ext sub add <epic-number> <story-number>
```

### 6. Update Epic with Story Links

```bash
gh issue edit <epic-number> --body "$(cat <<'EOF'
## Workflow: <name>

### Overview
<from workflow overview.md>

### Vertical Slices
- [ ] #<story-1> - <slice-1-name> [<pattern-type>]
- [ ] #<story-2> - <slice-2-name> [<pattern-type>]
...

### Workflow Diagram
```mermaid
<mermaid diagram>
```

---
Generated from: docs/event_model/workflows/<name>/overview.md
EOF
)"
```

### 7. Add to Project Board

```bash
owner=$(yq '.github.owner' .claude/sdlc.yaml)
project=$(yq '.github.project' .claude/sdlc.yaml)

if [ -n "$project" ] && [ "$project" != "null" ]; then
  gh project-ext add <epic-number> --owner "$owner" --project "$project"
  for story_number in <story-numbers>; do
    gh project-ext move "$story_number" "Backlog" --owner "$owner" --project "$project"
  done
fi
```

### 8. Store in Memento

```
mcp__memento__create_entities:
  name: "<Workflow> Planning Session [date]"
  entityType: "planning_session"
  observations:
    - "Project: <name> | Path: <path> | Scope: PROJECT_SPECIFIC"
    - "Workflow: <workflow-name>"
    - "Epic: #<epic-number>"
    - "Stories created: <count>"
    - "Story numbers: #<n1>, #<n2>, #<n3>..."
```

### 9. Display Results

```
Planning Complete: <workflow-name>

Epic: #<epic-number> - Epic: <Workflow Name>

Stories Created: <total-count>
  Command: #<n1>, #<n2>
  View: #<n3>
  Automation: #<n4>
  Translation: #<n5>

Next: /sdlc:work to start a story
```

## Optional Enhancement: Three-Perspective Review

For complex stories, offer perspective reviews:

```
Task tool with subagent_type="sdlc:story":
  Review story #<number> from business value perspective.
  Check: clear user value, appropriate slice thinness, complete GWT scenarios.

Task tool with subagent_type="sdlc:architect":
  MODE: REVIEW
  Review story #<number> from technical feasibility perspective.
  Check alignment with docs/ARCHITECTURE.md.

Task tool with subagent_type="sdlc:ux":
  Review story #<number> from user experience perspective.
  Check journey coherence and accessibility.
```

Add review feedback as a comment on each issue.

## Error Handling

- **No config**: Direct to `/sdlc:setup`
- **No architecture**: Direct to `/sdlc:design arch`
- **No workflows**: Direct to `/sdlc:design discover` then `/sdlc:design workflow`
- **Issue creation fails**: Show error, suggest manual creation, continue with remaining
- **Duplicate detection**: Skip already-created stories, note in output

## Labels Used

- `event-model` - All issues from event model
- `epic` - Epic issues (workflow level)
- `<workflow-name>` - Workflow identifier
- `command` / `view` / `automation` / `translation` - Pattern type
