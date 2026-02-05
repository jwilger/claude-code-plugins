# Plan: sdlc Plugin Redesign with Tasks & Skills

<objective>
Create implementation roadmap for redesigning the sdlc plugin to maximize use of Claude Code's tasks system and extract reusable skills for the skills.sh marketplace.

Purpose: Guide phased redesign that maintains backward compatibility where possible while restructuring agents to be lightweight skill loaders.

Input: Research findings from tasks-skills-research.md
Output: tasks-skills-plan.md with implementation phases
</objective>

<context>
Research findings: @.prompts/001-tasks-skills-research/tasks-skills-research.md

Current sdlc plugin structure:
- @sdlc/.claude-plugin/plugin.json
- @sdlc/agents/ (all agent definitions)
- @sdlc/commands/ (all command definitions)
- @sdlc/output-styles/
- @sdlc/docs/

Existing marketplace:
- @.claude-plugin/marketplace.json
</context>

<planning_requirements>
## Must Address
1. **Tasks integration**: How each agent should use TaskCreate/TaskUpdate/TaskList
2. **Skill extraction**: Which agent capabilities become standalone skills
3. **Agent restructuring**: How agents become lightweight skill loaders
4. **Backward compatibility**: Migration path for existing users
5. **Skill publishing**: Structure for top-level skills/ directory
6. **Installation workflow**: How users install extracted skills via npx

## Constraints
- Clean slate acceptable BUT must analyze existing prompts for reusable components
- Don't throw away working patterns without understanding them
- Skills must work in any skills-compatible agent harness, not just Claude Code
- Maintain sdlc plugin's existing commands and output styles
- Version all changes according to semver

## Success Criteria
- Tasks used for multi-step workflows (not trivial operations)
- Agents are lightweight (<200 lines) and primarily load skills
- Skills are published at top level and installable via npx
- Clear migration guide for existing sdlc plugin users
- Phased implementation allows incremental progress
</planning_requirements>

<output_structure>
Save to: `.prompts/002-tasks-skills-plan/tasks-skills-plan.md`

Structure the plan using this XML format:

```xml
<plan>
  <summary>
    {One paragraph overview of the redesign approach}
  </summary>

  <phases>
    <phase number="1" name="analysis-and-extraction">
      <objective>{What this phase accomplishes}</objective>
      <tasks>
        <task priority="high">{Specific actionable task}</task>
        <task priority="medium">{Another task}</task>
      </tasks>
      <deliverables>
        <deliverable>{What's produced}</deliverable>
      </deliverables>
      <dependencies>{What must exist before this phase}</dependencies>
      <verification>{How to confirm phase completion}</verification>
    </phase>

    <phase number="2" name="skill-structure-design">
      <objective>{Design skill directory structure and manifests}</objective>
      <tasks>
        <task priority="high">{Task}</task>
      </tasks>
      <deliverables>
        <deliverable>{What's produced}</deliverable>
      </deliverables>
      <dependencies>{Phase 1 completion}</dependencies>
      <verification>{How to confirm}</verification>
    </phase>

    <phase number="3" name="task-integration-pattern">
      <objective>{Define how agents use tasks}</objective>
      <tasks>
        <task priority="high">{Task}</task>
      </tasks>
      <deliverables>
        <deliverable>{What's produced}</deliverable>
      </deliverables>
      <dependencies>{Phase 1, 2 completion}</dependencies>
      <verification>{How to confirm}</verification>
    </phase>

    <phase number="4" name="skill-extraction">
      <objective>{Extract reusable components to skills}</objective>
      <tasks>
        <task priority="high">{Task}</task>
      </tasks>
      <deliverables>
        <deliverable>{What's produced}</deliverable>
      </deliverables>
      <dependencies>{Phase 2, 3 completion}</dependencies>
      <verification>{How to confirm}</verification>
      <execution_notes>
        {Guidance for implementation: which agents to tackle first, extraction patterns}
      </execution_notes>
    </phase>

    <phase number="5" name="agent-restructuring">
      <objective>{Rewrite agents as lightweight skill loaders}</objective>
      <tasks>
        <task priority="high">{Task}</task>
      </tasks>
      <deliverables>
        <deliverable>{What's produced}</deliverable>
      </deliverables>
      <dependencies>{Phase 4 completion}</dependencies>
      <verification>{How to confirm}</verification>
      <execution_notes>
        {How to maintain backward compatibility, what to preserve}
      </execution_notes>
    </phase>

    <phase number="6" name="marketplace-integration">
      <objective>{Publish skills to top-level and configure marketplace}</objective>
      <tasks>
        <task priority="high">{Task}</task>
      </tasks>
      <deliverables>
        <deliverable>{What's produced}</deliverable>
      </deliverables>
      <dependencies>{Phase 4, 5 completion}</dependencies>
      <verification>{How to confirm npx installation works}</verification>
    </phase>

    <phase number="7" name="documentation-and-migration">
      <objective>{Create migration guide and updated documentation}</objective>
      <tasks>
        <task priority="high">{Task}</task>
      </tasks>
      <deliverables>
        <deliverable>{What's produced}</deliverable>
      </deliverables>
      <dependencies>{Phase 5, 6 completion}</dependencies>
      <verification>{How to confirm docs are complete}</verification>
    </phase>
  </phases>

  <metadata>
    <confidence level="{high|medium|low}">
      {Why this confidence level based on research findings}
    </confidence>
    <dependencies>
      {External dependencies: gh CLI, git-spice, skills.sh tooling, etc.}
    </dependencies>
    <open_questions>
      {Uncertainties that may affect execution}
      - How to handle sdlc-specific GitHub integration in extracted skills?
      - Should Marvin output style remain plugin-specific or become a skill?
      - Version migration strategy if existing users have customizations?
    </open_questions>
    <assumptions>
      {What was assumed in creating this plan}
      - Research findings about tasks system are accurate
      - skills.sh format supports nested skill dependencies
      - Existing sdlc plugin users are OK with breaking changes if migration path exists
    </assumptions>
  </metadata>
</plan>
```
</output_structure>

<incremental_output>
**CRITICAL: Write plan phases incrementally**

1. Create tasks-skills-plan.md with XML skeleton
2. Write each <phase> as you design it:
   - Design phase 1 (analysis) → Write immediately
   - Design phase 2 (skill structure) → Write immediately
   - Continue for all phases
3. After all phases complete → write summary and metadata

This prevents token limit failures and saves progress.
</incremental_output>

<planning_guidance>
## Key Considerations

### Tasks Integration Strategy
- TaskCreate should be used for multi-step workflows (e.g., /work command's research → plan → implement flow)
- activeForm should describe what's happening ("Analyzing domain requirements", not "Analyze domain")
- Tasks should track dependencies (blockedBy) when work depends on prior completion
- Avoid tasks for trivial operations (reading files, simple searches)

### Skill Extraction Principles
From research findings, identify:
- Common patterns across agents (e.g., TDD workflows, GitHub integration)
- Self-contained capabilities (e.g., Event Modeling diagram generation)
- Reusable prompt templates (e.g., GWT test generation)
- Tool invocation patterns (e.g., gh CLI commands for issue creation)

### Agent Restructuring Pattern
Lightweight agents should:
- Define their purpose and available tools in ~50 lines
- Reference skills via clear loading mechanism
- Compose skills rather than duplicating prompts
- Maintain backward compatibility with existing command interfaces

### Skill Publishing Structure
Top-level skills/ directory should support:
- Standalone installation via npx skills
- Skill manifests with dependencies
- Documentation per skill
- Examples and test fixtures

### Migration Considerations
- Existing /sdlc:setup installations should continue working
- Version bump to 4.0.0 or 3.13.0 depending on breaking changes
- Clear changelog explaining restructuring
- Migration script if needed for user customizations
</planning_guidance>

<phase_breakdown_hints>
Suggested phase breakdown:

1. **Analysis & Extraction Strategy** (research-heavy)
   - Inventory all sdlc agents and their capabilities
   - Map capabilities to extractable skills
   - Identify task-appropriate workflows
   - Document reusable patterns

2. **Skill Structure Design** (architecture)
   - Design top-level skills/ directory structure
   - Define skill manifest format
   - Plan skill dependency mechanism
   - Create skill template

3. **Task Integration Pattern** (design)
   - Define when agents create tasks
   - Design task metadata conventions
   - Plan task lifecycle for sdlc workflows
   - Create task usage guidelines

4. **Skill Extraction** (implementation-ready)
   - Extract first skill (pick simplest, like gwt-test-gen)
   - Extract second skill (moderate complexity)
   - Continue for all identifiable skills
   - Test each skill standalone

5. **Agent Restructuring** (transformation)
   - Rewrite first agent as skill loader
   - Validate backward compatibility
   - Continue for remaining agents
   - Update plugin manifest

6. **Marketplace Integration** (publishing)
   - Publish skills to top-level
   - Update marketplace.json
   - Test npx installation
   - Verify skill discoverability

7. **Documentation & Migration** (finalization)
   - Write migration guide
   - Update CLAUDE.md
   - Create skill documentation
   - Version bump and changelog
</phase_breakdown_hints>

<summary_requirements>
Create `.prompts/002-tasks-skills-plan/SUMMARY.md` using this structure:

```markdown
# sdlc Plugin Redesign Plan

**[One substantive sentence describing the phased approach]**

## Version
v1

## Phase Overview
1. **Analysis & Extraction**: [objective]
2. **Skill Structure Design**: [objective]
3. **Task Integration Pattern**: [objective]
4. **Skill Extraction**: [objective]
5. **Agent Restructuring**: [objective]
6. **Marketplace Integration**: [objective]
7. **Documentation & Migration**: [objective]

## Key Decisions
- [Architectural choice that may need validation]
- [Approach requiring user confirmation]

## Critical Assumptions
- [Assumption about skills.sh capabilities]
- [Assumption about backward compatibility requirements]

## Decisions Needed
- [User input required before implementation]

## Blockers
None | [External dependencies]

## Next Step
Execute phase 1 (analysis and extraction strategy) or create implementation prompt for phase 1.
```
</summary_requirements>

<success_criteria>
- Plan addresses all requirements from research findings
- Phases are sequential and logically ordered
- Each phase has specific, actionable tasks
- Deliverables are concrete and verifiable
- Dependencies between phases are clear
- Execution notes provide guidance for implementation
- Backward compatibility and migration explicitly addressed
- Tasks integration strategy is well-defined
- Skill extraction and publishing plan is detailed
- Metadata captures uncertainties honestly
- SUMMARY.md created with phase overview
- Ready for implementation prompts to consume
</success_criteria>
