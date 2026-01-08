---
description: Create GitHub issues from event model slices - bridges design to implementation
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

**One vertical slice = One story issue.** No exceptions.

## Arguments

`$ARGUMENTS` may contain:
- `<workflow-name>` - Plan a specific workflow
- (no args) - Plan all unplanned workflows

## Prerequisites (ENFORCED)

1. **Configuration**: `.claude/sdlc.yaml` must exist
2. **Architecture**: `docs/ARCHITECTURE.md` must exist
3. **Event Model**: At least one workflow with slices must exist

If prerequisites are not met, inform user and stop:

```
Cannot create issues without completing prior phases.

Missing:
- [If no config]: Run /sdlc:setup first
- [If no architecture]: Run /sdlc:design arch first
- [If no workflows]: Run /sdlc:design workflow <name> first

The planning phase requires:
1. Event model (WHAT we're building - business behavior)
2. Architecture (HOW we'll build it - technical decisions)

Only then can we create actionable work items.
```

## Steps

### 1. Load Configuration

Read `.claude/sdlc.yaml` for:
- GitHub project settings (project number, owner)
- Board status names

### 2. Verify Prerequisites

```bash
# Check config exists
test -f .claude/sdlc.yaml || echo "NO_CONFIG"

# Check architecture exists
test -f docs/ARCHITECTURE.md || echo "NO_ARCHITECTURE"

# Check for workflows with slices
ls docs/event_model/workflows/*/slices/*.md 2>/dev/null | head -1 || echo "NO_SLICES"
```

If any prerequisite is missing, show the error message above and stop.

### 3. Find Workflows to Plan

If workflow name provided in arguments, use that. Otherwise, find all workflows:

```bash
# List all workflows
ls -d docs/event_model/workflows/*/ 2>/dev/null | xargs -I{} basename {}
```

For each workflow, check if epic already exists:
```bash
# Search for existing epic issue
gh issue list --label "event-model,epic" --search "<workflow-name>" --json number,title
```

### 4. Search Memento for Context

```
mcp__memento__semantic_search: "planning session [project-name] [workflow-name]"
```

Check if this workflow was previously planned and if there are notes.

### 5. For Each Workflow - Create Epic

Read the workflow overview:
```bash
cat docs/event_model/workflows/<workflow-name>/overview.md
```

**Create Epic Issue**:

```bash
gh issue create \
  --title "Epic: <Workflow Name>" \
  --label "event-model,epic,<workflow-name>" \
  --body "$(cat <<'EOF'
## Workflow: <name>

### Overview
<from workflow overview.md - user goal, actors involved>

### Vertical Slices
This epic contains the following stories (to be linked):

<placeholder - will be updated with story issue numbers>

### Workflow Diagram
```mermaid
<mermaid diagram from overview.md>
```

### Acceptance
All story issues must be completed for this epic to be done.

---
Generated from: docs/event_model/workflows/<name>/overview.md
EOF
)"
```

Store the epic issue number for later.

### 6. For Each Slice - Create Story Issue

List all slices in the workflow:
```bash
ls docs/event_model/workflows/<workflow-name>/slices/*.md
```

For each slice file:

1. **Check if story already exists**:
```bash
gh issue list --label "event-model,<workflow-name>,<slice-name>" --json number
```

2. **Read the slice document** to extract:
   - Slice name and pattern type (Command/View/Automation/Translation)
   - Description
   - Wireframe (if present)
   - GWT scenarios

3. **Create Story Issue**:

```bash
gh issue create \
  --title "<Slice Name>" \
  --label "event-model,<workflow-name>,<pattern-type>" \
  --body "$(cat <<'EOF'
## Slice: <name>

**Pattern**: <Command|View|Automation|Translation>
**Workflow**: <workflow-name>
**Epic**: #<epic-number>

### Description
<from slice document>

### Wireframe
```
<wireframe from slice document, if present>
```

### Acceptance Criteria

The following scenarios define "done" for this story:

<For each GWT scenario in the slice document>

#### Scenario: <scenario-name>

**Given**
- [ ] <given clause as checklist item>

**When**
- [ ] <when clause as checklist item>

**Then**
- [ ] <then clause as checklist item>

---

<End for each scenario>

### Technical Notes
Refer to docs/ARCHITECTURE.md for implementation guidance.

---
Generated from: docs/event_model/workflows/<workflow>/slices/<slice>.md
EOF
)"
```

4. **Link as sub-issue of epic**:
```bash
gh issue-ext sub add <epic-number> <story-number>
```

5. **Collect story number** for updating epic.

### 7. Update Epic with Story Links

After creating all stories, update the epic body with actual issue numbers:

```bash
gh issue edit <epic-number> --body "$(cat <<'EOF'
## Workflow: <name>

### Overview
<from workflow overview.md>

### Vertical Slices
- [ ] #<story-1> - <slice-1-name> [<pattern-type>]
- [ ] #<story-2> - <slice-2-name> [<pattern-type>]
- [ ] #<story-3> - <slice-3-name> [<pattern-type>]
...

### Workflow Diagram
```mermaid
<mermaid diagram>
```

### Acceptance
All linked stories must be completed for this epic to be done.

---
Generated from: docs/event_model/workflows/<name>/overview.md
EOF
)"
```

### 8. Run Three-Perspective Review (Optional)

For complex stories, offer to run the three-perspective review:

Use AskUserQuestion:
```
**Run perspective reviews on created stories?**
- "Yes, review all" - Run business, technical, and UX review on each story
- "Review key stories only" - Select which stories to review
- "Skip reviews" - Add stories to backlog without review
```

If reviewing, for each story:

```
Task tool with subagent_type="sdlc-story":
  Review story #<number> from the business value perspective.
  Check: clear user value, appropriate slice thinness, complete GWT scenarios.

Task tool with subagent_type="sdlc-architect":
  MODE: REVIEW
  Review story #<number> from the technical feasibility perspective.
  Check alignment with docs/ARCHITECTURE.md.

Task tool with subagent_type="sdlc-ux":
  Review story #<number> from the user experience perspective.
  Check journey coherence and accessibility.
```

Add review feedback as a comment on each issue.

### 9. Add to Project Board

If using GitHub Projects (from config):

```bash
# Get project number from config
PROJECT_NUM=$(grep 'project:' .claude/sdlc.yaml | awk '{print $2}')
OWNER=$(grep 'owner:' .claude/sdlc.yaml | awk '{print $2}')

# Add epic to project
gh project-ext add <epic-number>

# Add stories to project with Backlog status
gh project-ext add <story-number>
gh project-ext move <story-number> "Backlog"
```

### 10. Store in Memento

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
    - "Pattern breakdown: <n> Command, <n> View, <n> Automation, <n> Translation"
```

### 11. Display Results

```
Planning Complete: <workflow-name>

Epic Created:
  #<epic-number> - Epic: <Workflow Name>
  URL: <issue-url>

Stories Created: <total-count>

  Command Slices (<count>):
    #<n1> - <slice-name>
    #<n2> - <slice-name>

  View Slices (<count>):
    #<n3> - <slice-name>

  Automation Slices (<count>):
    #<n4> - <slice-name>

  Translation Slices (<count>):
    #<n5> - <slice-name>

Project Board: <project-name>
  All issues added to Backlog

Perspective Reviews:
  - Business: <completed/skipped>
  - Technical: <completed/skipped>
  - UX: <completed/skipped>

Next steps:
  /sdlc:work - Start working on a story
  gh issue view <epic-number> - View the epic

To plan another workflow:
  /sdlc:plan <workflow-name>
```

## Error Handling

- **No config**: Direct to `/sdlc:setup`
- **No architecture**: Direct to `/sdlc:design arch`
- **No workflows**: Direct to `/sdlc:design discover` then `/sdlc:design workflow`
- **Issue creation fails**: Show error, suggest manual creation, continue with remaining
- **Duplicate detection**: Skip already-created stories, note in output
- **Sub-issue linking fails**: Create issue without link, warn user to link manually

## Labels Used

The command creates/uses these labels:
- `event-model` - All issues from event model
- `epic` - Epic issues (workflow level)
- `<workflow-name>` - Workflow identifier
- `command` / `view` / `automation` / `translation` - Pattern type

If labels don't exist, they will be created automatically by `gh issue create`.
