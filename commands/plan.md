---
description: Story planning with three-perspective review (business/tech/UX)
argument-hint: [action] [slice-name]
---

# Plan Command

You are facilitating story planning with three-perspective review aligned with the event model.

**Arguments provided:** $ARGUMENTS

## Critical Mapping

| Event Model | Work Tracking (Beads) |
|-------------|----------------------|
| Vertical Slice | Story (1:1) |
| GWT Scenarios | Acceptance Criteria |
| Chapter/Theme | Epic |

**This is NON-NEGOTIABLE.** Each slice becomes exactly one story.

## Determine the Action

| If args contain... | Action |
|-------------------|--------|
| `slice <name>` | Plan a single slice as story |
| `review <name>` | Three-perspective review |
| `create <name>` | Create beads issue for slice |
| `epic <name>` | Create epic for chapter/theme |
| `ready` | Show stories ready to implement |
| (no args or `help`) | Show help |

## Execute the Action

### For Slice Planning (`slice <name>`)

1. Read the workflow at `docs/event_model/workflows/<name>.md`
2. Read GWT scenarios at `docs/event_model/scenarios/<name>/`
3. Present the slice as a story:
   - Title (from slice goal)
   - Acceptance criteria (GWT scenarios)
   - Related events/commands
4. Ask if user wants three-perspective review

### For Three-Perspective Review (`review <name>`)

Run all three reviewers in parallel using Task tool:

**Business Perspective:**
```
subagent_type="story-planner"
Prompt: Review the slice at docs/event_model/workflows/<name>.md from business perspective. Check value delivery, slice thinness, and acceptance clarity.
```

**Technical Perspective:**
```
subagent_type="story-architect"
Prompt: Review the slice at docs/event_model/workflows/<name>.md from technical perspective. Assess complexity, risks, and architectural alignment.
```

**UX Perspective:**
```
subagent_type="ux-consultant"
Prompt: Review the slice at docs/event_model/workflows/<name>.md from UX perspective. Check journey coherence, accessibility, and user mental model.
```

After all three return:
1. Summarize each perspective's findings
2. Highlight any conflicts between perspectives
3. Ask user to resolve conflicts before proceeding
4. If all clear, offer to create beads issue

### For Create Story (`create <name>`)

Using beads CLI:

```bash
bd create "<Story title from slice>" -t feature -p 2 --json
```

Add acceptance criteria as a comment or in the description.

### For Create Epic (`epic <name>`)

For chapters/themes:

```bash
bd create "<Epic title from chapter>" -t epic -p 2 --json
```

### For Ready (`ready`)

```bash
bd ready --json
```

Show unblocked stories ready for implementation.

### For Help (no args)

Display:

```
/plan - Story Planning Facilitator

Actions:
  /plan slice <name>   - Plan a slice as story
  /plan review <name>  - Three-perspective review
  /plan create <name>  - Create beads issue
  /plan epic <name>    - Create epic from chapter
  /plan ready          - Show ready stories

The Mapping:
  Vertical Slice = Story (1:1)
  GWT Scenarios  = Acceptance Criteria
  Chapter/Theme  = Epic

Three Perspectives:
  Business (story-planner)  - Value, slice thinness
  Technical (story-architect) - Complexity, risks, alignment
  UX (ux-consultant)        - Journey, accessibility

Workflow:
  1. /event-model design <workflow>  - Design the workflow
  2. /event-model gwt <workflow>     - Generate scenarios (acceptance criteria)
  3. /plan slice <name>              - Review as story
  4. /plan review <name>             - Three-perspective review
  5. /plan create <name>             - Create beads issue

Agents: story-planner, story-architect, ux-consultant
```

## Conflict Resolution

If perspectives conflict (e.g., UX wants more, tech says too complex):
1. Present both viewpoints clearly
2. Ask user to decide priority
3. Document decision in the story
4. Consider splitting into multiple slices if needed
