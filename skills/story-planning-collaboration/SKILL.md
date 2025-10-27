---
name: story-planning-collaboration
description: Guides collaborative story breakdown with user during Phase 6. Facilitates pair-programming on beads story creation using QUESTION: comments and iterative refinement. Stories are thin vertical slices derived from event models. Uses beads CLI tool via slash commands.
allowed-tools: [Read, Glob, Grep, WebSearch, WebFetch, mcp__memento__create_entities, mcp__memento__create_relations, mcp__memento__add_observations, mcp__memento__semantic_search, mcp__memento__open_nodes, mcp__time__get_current_time, AskUserQuestion, SlashCommand]
---

# Story Planning Collaboration Skill

Guides main conversation on how to collaborate with user during Phase 6: Story Planning.

## Core Principle

**User is co-creator of stories, not reviewer of AI-generated stories.**

## Collaboration Protocol

### 1. Three-Agent Consultation

Story planning involves three advisory agents working collaboratively:

1. story-planner: Recommends story breakdown and priorities (business perspective)
2. story-architect: Reviews technical feasibility and dependencies
3. ux-consultant: Reviews UX coherence and user journey flow

All three agents return recommendations (NO direct beads edits). Main conversation facilitates user collaboration based on recommendations.

### 2. Collaborative Story Creation Loop

**DO NOT** create all stories autonomously. Instead:

1. **Propose one story at a time**:
   - Present story recommendation (title, description, acceptance criteria)
   - User reviews, can modify each field
   - Use QUESTION: comments for clarifications

2. **Create beads issue collaboratively**:
   - After user approves story content
   - Main conversation creates beads issue via `/beads:create` command with agreed-upon details
   - User can modify beads issue fields directly

3. **Acknowledge user modifications**:
   - "I see you narrowed the scope to X. That's more achievable because..."
   - "I understand you want to include Y. Consider dependency on..."
   - Engage in dialogue about story scope and feasibility

4. **Answer QUESTION: comments**:
   - In story descriptions or acceptance criteria
   - Main conversation provides analysis
   - User decides based on discussion

5. **Iterate until story is well-defined**:
   - Continue refining with user
   - Move to next story only when current approved
   - User has final say on scope, priorities, dependencies

### 3. Story Planning-Specific Patterns

**Derived from Event Models:**

- Stories decompose event model vertical slices
- Reference specific vertical slices from EVENT_MODEL.md
- Each story provides user-observable value

**Thin Vertical Slices:**

- Smallest possible increment with real value
- No "technical foundation" stories without user value
- Complete functionality, not partial implementation

**Integration Requirements:**

- Every story specifies how users access the feature
- Integration point (CLI, HTTP, GUI, library API)
- User access method (exact command/action)
- Manual testing instructions

**Acceptance Criteria:**

- Reference command criteria from event model
- Add user experience scenarios (UI feedback, errors, workflow completion)
- Gherkin format (Given/When/Then)
- Focus on user-observable behavior

### 4. Prioritization Collaboration

**Initial Priority (story-planner):**

- Business risk vs value analysis
- Creates beads issues with priority 1/2/3 via `/beads:create`

**Technical Review (story-architect):**

- May suggest reprioritization based on dependencies
- Sets technical dependencies via `/beads:dep` command

**UX Review (ux-consultant):**

- May suggest priority changes for design coherence
- Ensures good UX progression

**Final Priority:**

- Main conversation facilitates consensus discussion
- User makes final priority decisions
- All three agents must reach agreement

### 5. Memento Integration

**Record story decisions:**

```json
{
  "entities": [{
    "name": "Story Decision: [Topic]",
    "entityType": "story_decision",
    "observations": [
      "Project: [project] | Scope: PROJECT_SPECIFIC",
      "Story: [beads ID or title]",
      "Decision: [what scope/priority was decided]",
      "Rationale: [why user chose this approach]",
      "Date: [timestamp]"
    ]
  }]
}
```

### 6. Phase Completion

Before moving to Phase 7 (Story-by-Story Core Loop):

- ✅ All event model vertical slices have stories
- ✅ story-planner, story-architect, ux-consultant reached consensus
- ✅ User has approved all stories
- ✅ All QUESTION: comments resolved
- ✅ Priorities and dependencies make sense
- ✅ All stories have integration requirements
- ✅ Key decisions stored in memento

## QUESTION: Comment Examples

### In Story Description

```markdown
Story: User sends message to conversation

QUESTION: Should we support message editing in this story or defer to later story?

Description: User can compose and send a message to an active conversation.
```

### In Acceptance Criteria

```markdown
Acceptance Criteria:

See acceptance criteria in SendMessage command documentation.

Additional User Experience Scenarios:

Scenario: User sees message appear in thread
Given I have an active conversation
When I type "Hello" and press Send
QUESTION: Should the message appear immediately (optimistic UI) or wait for server confirmation?
Then the message appears at bottom of conversation
```

### In Integration Requirements

```markdown
Integration Point: CLI command prompt

User Access Method: Type message and press Enter

QUESTION: Should we support multiline messages via Shift+Enter like Discord?

Manual Testing:
1. Start CLI: cargo run
2. Type message and press Enter
3. Verify message appears in conversation history
```

## Collaboration Anti-Patterns

❌ **Don't**: Create all beads stories and ask for batch approval
✅ **Do**: Propose one story, collaborate, create beads, repeat

❌ **Don't**: Ignore technical dependencies or UX flow
✅ **Do**: Facilitate three-way consensus on priorities

❌ **Don't**: Make stories without integration requirements
✅ **Do**: Every story specifies how users access the feature

❌ **Don't**: Create "technical foundation" stories without user value
✅ **Do**: Every story delivers observable user functionality

## Three-Agent Consensus Pattern

**Story-by-story consensus:**

1. story-planner proposes story with business priority
2. story-architect reviews for technical feasibility
   - May suggest dependency additions
   - May suggest priority adjustments
3. ux-consultant reviews for UX coherence
   - May suggest scope changes for better UX
   - May suggest priority changes for design flow
4. Main conversation facilitates discussion if disagreement
5. User makes final call on scope/priority/dependencies

**When agents disagree:**

- Present all perspectives to user
- Explain trade-offs clearly
- User decides based on priorities (business vs technical vs UX)
- Document decision rationale in memento

## Success Criteria

Story planning collaboration is successful when:

- User feels ownership of stories (co-created, not reviewed)
- All stories are thin vertical slices with real user value
- Priorities balance business, technical, and UX concerns
- Dependencies are clear and implementable
- Integration requirements are complete
- User approved all stories through iterative refinement
- Three-agent consensus reached
- Key decisions documented in memento
