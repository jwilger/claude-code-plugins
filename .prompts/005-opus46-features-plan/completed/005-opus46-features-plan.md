<objective>
Create an implementation plan for improving the SDLC plugin to leverage Opus 4.6 and latest Claude Code features.

Purpose: Provide a phased, actionable roadmap for enhancing the plugin while preserving the core SDLC workflow
Input: Research findings from opus46-features-research.md
Output: opus46-features-plan.md with prioritized, phased implementation approach
</objective>

<context>
Research findings: @.prompts/004-opus46-features-research/opus46-features-research.md

Current SDLC plugin structure:
- Plugin root: sdlc/
- Agents: sdlc/agents/ (15 agents)
- Commands: sdlc/commands/ (12 commands)
- Skills: sdlc/skills/ (9 skills)
- Output styles: sdlc/output-styles/ (2 styles, auto-generated from templates)
- Hooks: configured via sdlc/commands/setup.md
- Plugin manifest: sdlc/.claude-plugin/plugin.json
- Marketplace: .claude-plugin/marketplace.json
</context>

<critical_constraint>
The core SDLC workflow MUST be preserved:

```
Setup → Design (discover → workflow → GWT → arch) → Plan → Work (TDD cycles) → PR → Review → Complete
```

The TDD cycle MUST remain mechanically enforced:
```
RED → DOMAIN (after red) → GREEN → DOMAIN (after green) → repeat
```

Inviolable principles:
1. Mechanical enforcement via hooks and task dependencies
2. Agent specialization with file-type restrictions
3. Fresh context protocol — agents require complete context
4. Mandatory domain review after RED and GREEN phases
5. Orchestrator-delegates pattern — never writes code directly
6. Event Modeling integration preserved
7. Local-first task management

Any phase or task in this plan that would violate these principles MUST be flagged and rejected.
</critical_constraint>

<planning_requirements>
Based on the research findings, create a phased plan that:

1. **Prioritizes by impact-to-effort ratio** — High-impact, low-effort improvements first
2. **Groups related changes** — Changes to the same component go in the same phase
3. **Maintains backward compatibility** — Each phase leaves the plugin functional
4. **Includes rollback points** — Each phase can be reverted independently
5. **Specifies affected files** — Exact paths for each change
6. **Respects version management** — Accounts for the 3-file version update requirement (plugin.json, marketplace.json, setup.md)
7. **Considers output style synchronization** — Changes to orchestration rules go through templates
8. **Preserves the core workflow** — Every task includes a constraint_check field

Plan structure requirements:
- Each phase should be completable in one working session
- Each phase should be independently testable
- Phases should be ordered so the most valuable improvements come first
- Include specific acceptance criteria for each task
- Include a "constraint verification" step at the end of each phase

Categories to consider for each recommendation from research:
- **Agent improvements** — Better prompts, smarter delegation, new capabilities
- **Hook enhancements** — Tighter enforcement, new event types, better error messages
- **Skill additions/updates** — New portable skills or improvements to existing ones
- **Command improvements** — Better UX, smarter auto-detection, new options
- **Output style updates** — Orchestration rule improvements (via templates only!)
- **Task management** — Better integration with TaskCreate/TaskUpdate/TaskList
- **Memory improvements** — Better knowledge accumulation patterns
- **Performance** — Faster agent execution, better parallel tool use
</planning_requirements>

<output_structure>
Save to: `.prompts/005-opus46-features-plan/opus46-features-plan.md`

Structure the plan using this XML format:

```xml
<plan>
  <summary>
    {One paragraph overview of the improvement approach, emphasizing
    workflow preservation and key enhancements}
  </summary>

  <constraint_verification_protocol>
    {Define the specific checks that will be run after each phase
    to verify the core SDLC workflow is intact:
    - TDD cycle still enforced (RED→DOMAIN→GREEN→DOMAIN)
    - Hooks still block unauthorized file edits
    - Domain review still mandatory
    - Orchestrator still delegates
    - Event modeling workflow intact
    - All 12 commands still functional}
  </constraint_verification_protocol>

  <phases>
    <phase number="1" name="{phase-name}">
      <objective>{What this phase accomplishes}</objective>
      <rationale>{Why this phase comes first — impact/effort justification}</rationale>
      <tasks>
        <task priority="{high|medium|low}">
          <description>{Specific actionable task}</description>
          <affected_files>
            - {exact/path/to/file.md}
          </affected_files>
          <acceptance_criteria>
            - {How to verify this task is done correctly}
          </acceptance_criteria>
          <constraint_check>{Which core workflow principles this touches and how they're preserved}</constraint_check>
        </task>
      </tasks>
      <deliverables>
        <deliverable>{What's produced}</deliverable>
      </deliverables>
      <dependencies>{What must exist before this phase}</dependencies>
      <rollback>{How to revert this phase if needed}</rollback>
      <constraint_verification>
        {Specific steps to verify core workflow is intact after this phase:
        - Run which commands to test?
        - Check which hooks?
        - Verify which agent behaviors?}
      </constraint_verification>
    </phase>
    <!-- Additional phases -->
  </phases>

  <version_management>
    {Plan for version bumps:
    - Which phases warrant a version bump?
    - Suggested version numbers (semver)
    - Files to update: plugin.json, marketplace.json, setup.md}
  </version_management>

  <risk_assessment>
    <risk severity="{high|medium|low}">
      <description>{What could go wrong}</description>
      <mitigation>{How to prevent or handle it}</mitigation>
      <detection>{How to know if it happened}</detection>
    </risk>
  </risk_assessment>

  <metadata>
    <confidence level="{high|medium|low}">
      {Why this confidence level}
    </confidence>
    <dependencies>
      {External dependencies needed}
    </dependencies>
    <open_questions>
      {Uncertainties that may affect execution}
    </open_questions>
    <assumptions>
      {What was assumed in creating this plan}
    </assumptions>
  </metadata>
</plan>
```
</output_structure>

<summary_requirements>
Create `.prompts/005-opus46-features-plan/SUMMARY.md`

```markdown
# Opus 4.6 Features Implementation Plan Summary

**{Substantive one-liner describing the plan approach}**

## Version
v1

## Key Findings
- {Phase 1 objective and scope}
- {Phase 2 objective and scope}
- {Phase 3 objective and scope}
- {Total number of tasks across all phases}

## Decisions Needed
{Specific decisions requiring user input — e.g., "Approve adding new agent X", "Confirm deprecating hook Y"}

## Blockers
{External impediments, or "None"}

## Next Step
Execute Phase 1 tasks using .prompts/006-opus46-features-implement/

---
*Confidence: {High|Medium|Low}*
*Iterations: 1*
*Full output: opus46-features-plan.md*
```
</summary_requirements>

<success_criteria>
- Plan addresses all high-priority recommendations from research
- Every phase preserves the core SDLC workflow
- Every task includes constraint_check verification
- Phases are ordered by impact-to-effort ratio
- Each phase is independently testable and revertible
- Affected files are specified with exact paths
- Version management strategy is clear
- Risk assessment covers workflow-breaking scenarios
- SUMMARY.md created with phase overview
- Ready for implementation prompts to consume
</success_criteria>
