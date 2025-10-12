---
description: Activate the infrastructure/library SDLC workflow with all agent coordination rules and sequential phase gates
disable-model-invocation: false
---

# SDLC Workflow Activation (Infrastructure)

This command activates the complete sequential SDLC workflow system for infrastructure/library development. For the full system prompt with all details, see `plugins/sdlc-infrastructure/system-prompt.md`.

## Sequential Development Workflow (6 Phases)

### Phase 1: Technical Requirements Analysis
- **Agent**: requirements-analyst
- **Output**: docs/REQUIREMENTS_ANALYSIS.md (technical focus)
- **Gate**: Complete technical requirements with acceptance criteria

### Phase 2: SKIPPED
- **Event Modeling is NOT applicable to infrastructure/library projects**

### Phase 3: Architectural Decision Records
- **Agent**: adr-writer ↔ User
- **Output**: docs/adr/*.md files
- **Gate**: All architectural decisions documented

### Phase 4: Architecture Synthesis
- **Agent**: architecture-synthesizer
- **Output**: docs/ARCHITECTURE.md
- **Gate**: Cohesive system design reflecting ADRs

### Phase 5: SKIPPED
- **Design System is NOT applicable to infrastructure/library projects**

### Phase 6: Technical Increment Planning
- **Agents**: technical-increment-planner ↔ story-architect
- **Output**: docs/PLANNING.md with prioritized technical increments
- **Gate**: Both agents agree increments are well-defined and properly ordered

### Phase 7: Increment-by-Increment Implementation
- **Process**: Iterative development, one technical increment at a time
- **Gate**: Increment complete when story-architect approves implementation
- **TDD**: Outside-In TDD with domain modeling and type-first approach

### Phase 8: Acceptance Validation
- **Agents**: acceptance-validator → technical-documentation-writer → cognitive-load-analyzer → source-control
- **Gate**: Requirements met, documentation consistent, quality gates passed

## Key Differences from Application Workflow

**Infrastructure workflow:**
- ✅ Technical requirements (not user-facing features)
- ❌ No Event Modeling (Phase 2 skipped)
- ❌ No Design System (Phase 5 skipped)
- ❌ No UX consultant involvement
- ✅ Technical increments (not user stories)
- ✅ Dependency-based prioritization (not business value)
- ✅ Public API integration points (not UI screens)

**When to use Infrastructure workflow:**
- Libraries and frameworks
- Developer tools and CLIs
- APIs and SDKs
- System utilities
- Projects where consumers are developers

**When to use Application workflow:**
- Web/mobile/desktop applications
- Line-of-business applications
- Projects with end-user interfaces
- Projects where Event Modeling provides value

## Agent Coordination

Main coordinator delegates to:
- Phase 1: requirements-analyst (technical focus)
- Phase 3: adr-writer (architectural decisions)
- Phase 4: architecture-synthesizer (synthesizes ADRs)
- Phase 6: technical-increment-planner + story-architect (increment planning)
- Phase 7: domain-modeling + TDD agents (implementation)
- Phase 8: acceptance-validator + documentation-writer + cognitive-load-analyzer (validation)

## Quality Gates

- **TDD**: Red → Domain → Green cycle with type-first approach
- **Mutation Testing**: ≥80% mutation score for new code
- **Cognitive Load**: ≥70% TRACE score before PR creation
- **Integration**: Features accessible through public API, not just tests
- **Examples**: Every increment includes working usage examples

Remember: Infrastructure workflow is streamlined for technical projects. Focus is on API contracts, technical capabilities, and developer experience, not end-user interfaces or business events.
