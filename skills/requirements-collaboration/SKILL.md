---
name: requirements-collaboration
description: Guides collaborative requirements capture with user during Phase 1. Facilitates pair-programming on REQUIREMENTS_ANALYSIS.md using IDE diff modification flow and QUESTION: comments. Use when working on requirements analysis phase.
allowed-tools: [Read, Glob, Grep, WebSearch, WebFetch, mcp__memento__create_entities, mcp__memento__create_relations, mcp__memento__add_observations, mcp__memento__semantic_search, mcp__memento__open_nodes, mcp__time__get_current_time, AskUserQuestion]
---

# Requirements Collaboration Skill

Guides main conversation on how to collaborate with user during Phase 1: Requirements Analysis.

## Core Principle

**User is co-creator of requirements, not reviewer of AI-generated requirements.**

## Collaboration Protocol

### 1. Advisory Agent Consultation

When user requests requirements analysis:

1. Call requirements-analyst agent for research/recommendations
2. Agent returns requirements recommendations (NO file editing)
3. Main conversation receives recommendations

### 2. Collaborative Refinement Loop

**DO NOT** write requirements files autonomously. Instead:

1. **Propose one section at a time**:
   - Present recommendation for specific requirement section
   - Use IDE diff modification so user can edit directly
   - User reviews, modifies, approves via IDE

2. **Acknowledge user modifications**:
   - "I see you changed X to Y. That clarifies..."
   - "I understand you prefer X. Consider that Y because..."
   - Engage in dialogue, don't just accept silently

3. **Answer QUESTION: comments**:
   - User adds `QUESTION: Should we include X?` inline
   - Main conversation answers directly in file
   - Remove QUESTION: prefix after answering

4. **Iterate until correct**:
   - Continue refining section with user
   - Move to next section only when current section approved
   - User has final say on all requirement decisions

### 3. Memento Integration

**Record decisions in knowledge graph:**

```json
{
  "entities": [{
    "name": "Requirement Decision: [Topic]",
    "entityType": "requirement_decision",
    "observations": [
      "Project: [project] | Scope: PROJECT_SPECIFIC",
      "Decision: [what was decided]",
      "Rationale: [why user chose this approach]",
      "Date: [timestamp]"
    ]
  }]
}
```

### 4. Phase Completion

Before moving to Phase 2 (Event Modeling):

- ✅ All requirement sections collaboratively defined
- ✅ User has approved final REQUIREMENTS_ANALYSIS.md
- ✅ All QUESTION: comments resolved
- ✅ Key decisions stored in memento
- ✅ Requirements focus on WHAT/WHY, not HOW

## QUESTION: Comment Examples

```markdown
## Functional Requirements

### FR-1: User Authentication

Users must be able to authenticate using email and password.

QUESTION: Should we also support OAuth providers (Google, GitHub)?

### FR-2: Session Management
...
```

Main conversation answers inline:

```markdown
QUESTION: Should we also support OAuth providers (Google, GitHub)?
ANSWER: Yes, OAuth is common for modern apps and improves UX. I recommend adding FR-1.1 for OAuth support. What providers do you want to support?
```

After user confirms, remove QUESTION:/ANSWER: and update requirement accordingly.

## Collaboration Anti-Patterns

❌ **Don't**: Write entire REQUIREMENTS_ANALYSIS.md and ask for approval
✅ **Do**: Propose one section, collaborate iteratively

❌ **Don't**: Silently accept all user changes
✅ **Do**: Acknowledge changes with rationale or counterarguments

❌ **Don't**: Ignore user questions in comments
✅ **Do**: Answer QUESTION: comments promptly and thoroughly

❌ **Don't**: Make implementation decisions in requirements
✅ **Do**: Focus on WHAT/WHY, defer HOW to later phases

## Success Criteria

Requirements collaboration is successful when:

- User feels ownership of requirements (co-created, not reviewed)
- Requirements clearly state WHAT and WHY without HOW
- All stakeholder needs captured
- Acceptance criteria are testable
- Key decisions documented in memento
- User approved final document through iterative refinement
