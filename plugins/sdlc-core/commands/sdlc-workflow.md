---
description: Activate the full SDLC workflow with all agent coordination rules and sequential phase gates
disable-model-invocation: false
---

# SDLC Workflow Activation

This command activates the complete sequential SDLC workflow system. For the full system prompt with all details, see `plugins/sdlc-core/system-prompt.md`.

## Sequential Development Workflow (8 Phases)

### Phase 1: Requirements Analysis
- **Agent**: requirements-analyst
- **Output**: docs/REQUIREMENTS_ANALYSIS.md
- **Gate**: Complete requirements with user stories and acceptance criteria

### Phase 2: Event Modeling
- **Agents**: event-modeling-step-0 through step-12, event-modeling-pm, event-modeling-architect
- **Output**: Hierarchical event model (docs/EVENT_MODEL.md + component docs)
- **Gate**: All 12 steps complete, business & architectural review approved

### Phase 3: Architectural Decision Records
- **Agent**: adr-writer ↔ User
- **Output**: docs/adr/*.md files
- **Gate**: All architectural decisions documented

### Phase 4: Architecture Synthesis
- **Agent**: architecture-synthesizer
- **Output**: docs/ARCHITECTURE.md
- **Gate**: Cohesive system design reflecting ADRs

### Phase 5: Design System
- **Agent**: design-system-architect
- **Output**: docs/STYLE_GUIDE.md
- **Gate**: Complete design system with interaction patterns

### Phase 6: Story Planning
- **Agents**: story-planner ↔ story-architect ↔ ux-consultant
- **Output**: docs/PLANNING.md with prioritized stories
- **Gate**: All three agents agree on stories and priority

### Phase 7: Story-by-Story Implementation (Core Loop)
- Story selection → Technical review → Architecture updates → UX review → Design updates → Domain modeling → TDD implementation → Consensus
- **Gate**: Story complete with feature accessible and tested

### Phase 8: Acceptance Validation & Documentation QA
- **Agents**: acceptance-validator → technical-documentation-writer → cognitive-load-analyzer → source-control
- **Gate**: Requirements met, docs consistent, quality gates passed

## Critical Rules

- Each phase MUST complete before next begins
- NO jumping ahead without proper documentation
- Domain modeling creates types incrementally per story
- TDD must compile cleanly with all tests passing
- Main agent personally verifies all completion claims
- Auto-commit after each phase completion

## Process Commands Available

Load specific methodology as needed:
- /event-modeling-process
- /tdd-workflow-process
- /domain-modeling-process
- /story-planning-process
- /documentation-philosophy
- /dependency-management-process
- And more...

The complete SDLC workflow with all agent coordination rules, memory protocols, and quality gates is now active.