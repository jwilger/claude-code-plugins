# Research: Claude Code Tasks System & Skills Architecture

<session_initialization>
Before beginning research, verify today's date:
!`date +%Y-%m-%d`

Use this date when searching for "current" or "latest" information.
</session_initialization>

<research_objective>
Research Claude Code's tasks system and skills.sh marketplace format to enable redesign of the sdlc plugin.

Purpose: Understand how to integrate Claude Code's TaskCreate/TaskUpdate/TaskGet/TaskList tools into agent workflows, and how to extract reusable skills from the sdlc plugin that can be installed via `npx skills` commands.

Scope:
- Claude Code's tasks API and workflow patterns
- skills.sh marketplace format and installation mechanism
- Current sdlc plugin architecture analysis
- Integration patterns for combining tasks + skills

Output: tasks-skills-research.md with structured findings
</research_objective>

<research_scope>
<include>
## Claude Code Tasks System
- TaskCreate, TaskUpdate, TaskGet, TaskList API specifications
- Task lifecycle (pending → in_progress → completed)
- Task dependencies (blocks/blockedBy)
- Task metadata and ownership model
- Best practices for when agents should use tasks
- activeForm vs subject naming conventions
- When to avoid creating tasks (trivial work)

## skills.sh Marketplace Format
- Skill directory structure and manifest format
- How skills are discovered and installed via npx
- Skill loading mechanisms in agent harnesses
- Frontmatter format for skill definitions
- Relationship between skills and agent subagent_type
- How skills compose and reference each other

## sdlc Plugin Current Architecture
- Existing agent definitions in sdlc/agents/
- Existing command definitions in sdlc/commands/
- Current prompt patterns and workflows
- Output styles (marvin-sdlc)
- Reusable components that could become skills
- Hardcoded dependencies (gh CLI, git-spice, etc.)

## Integration Patterns
- How lightweight agents can auto-load skills
- Mapping agent capabilities to skills
- When to use tasks vs when to just execute
- Skill composition for complex workflows
</include>

<exclude>
- Implementation details (defer to planning phase)
- Specific file modifications (defer to implementation)
- GitHub API integration details (not core to tasks/skills)
- Marvin personality implementation (orthogonal concern)
</exclude>

<sources>
Official Claude Code documentation (use Task tool with claude-code-guide agent):
- Tasks system documentation (TaskCreate, TaskUpdate, TaskGet, TaskList)
- Agent and skill architecture
- Plugin system and manifest formats

skills.sh marketplace:
- Official documentation at skills.sh
- Example skills in marketplace
- Installation and discovery mechanism

Current codebase (use Read tool):
- @sdlc/.claude-plugin/plugin.json
- @sdlc/agents/ (all agent definitions)
- @sdlc/commands/ (all command definitions)
- @.claude-plugin/marketplace.json
- Existing skills: @create-meta-prompts, @find-skills, @keybindings-help

Use WebSearch for:
- "Claude Code tasks system 2026"
- "skills.sh marketplace format 2026"
- "npx skills installation 2026"

Time constraint: Prefer current sources - verify date first.
</sources>
</research_scope>

<verification_checklist>
## Claude Code Tasks System
□ Verify all task-related tools: TaskCreate, TaskUpdate, TaskGet, TaskList
□ Document exact parameter schemas for each tool
□ Confirm task status lifecycle and valid transitions
□ Verify dependency syntax (blocks/blockedBy)
□ Document metadata fields and their purposes
□ Confirm when agents should NOT use tasks (trivial work guidance)

## skills.sh Format
□ Verify skill directory structure requirements
□ Document manifest file format (JSON/frontmatter)
□ Confirm npx skills installation commands
□ Verify skill loading mechanism in agent harnesses
□ Document skill composition patterns

## sdlc Plugin Analysis
□ Enumerate ALL current agents (list each by filename)
□ Enumerate ALL current commands (list each by filename)
□ Identify reusable prompt patterns across agents
□ Document current dependencies and requirements
□ Note any hard-to-extract coupling

## Integration Patterns
□ Document how agents reference skills
□ Verify skill auto-loading mechanisms
□ Confirm task creation timing (when vs when not)
□ Identify patterns for skill + task workflows
</verification_checklist>

<research_quality_assurance>
Before completing research, perform these checks:

<completeness_check>
- [ ] All task tools documented with schemas
- [ ] skills.sh format fully understood with examples
- [ ] Every sdlc agent/command analyzed for extractable components
- [ ] Integration patterns identified with concrete examples
- [ ] Official documentation cited for critical claims
- [ ] Contradictory information resolved or flagged
</completeness_check>

<source_verification>
- [ ] Claude Code docs verified via claude-code-guide agent
- [ ] skills.sh format verified from official sources
- [ ] Version numbers and dates included where relevant
- [ ] Actual URLs/file paths provided (not just "search for X")
- [ ] Distinguish verified facts from assumptions
</source_verification>

<blind_spots_review>
Ask yourself: "What might I have missed?"
- [ ] Are there task tools I didn't investigate?
- [ ] Did I check all skills.sh installation patterns?
- [ ] Did I analyze every agent in sdlc for extraction potential?
- [ ] Did I verify recent changes to Claude Code's tasks system?
- [ ] Did I check for environment-specific variations?
</blind_spots_review>

<critical_claims_audit>
For any statement like "X is not possible" or "Y is the only way":
- [ ] Is this verified by official documentation?
- [ ] Have I checked for recent updates that might change this?
- [ ] Are there alternative approaches I haven't considered?
</critical_claims_audit>
</research_quality_assurance>

<output_structure>
Save to: `.prompts/001-tasks-skills-research/tasks-skills-research.md`

Structure findings using XML format with these sections:

```xml
<research>
  <summary>
    {2-3 paragraph executive summary of key findings}
  </summary>

  <findings>
    <finding category="tasks-system">
      <title>{Finding about Claude Code tasks}</title>
      <detail>{Detailed explanation}</detail>
      <source>{Official docs reference}</source>
      <relevance>{Why this matters for sdlc redesign}</relevance>
    </finding>

    <finding category="skills-format">
      <title>{Finding about skills.sh}</title>
      <detail>{Detailed explanation}</detail>
      <source>{skills.sh docs or examples}</source>
      <relevance>{Why this matters for extraction}</relevance>
    </finding>

    <finding category="sdlc-analysis">
      <title>{Finding about current sdlc plugin}</title>
      <detail>{What's extractable, what's coupled}</detail>
      <source>{File paths in codebase}</source>
      <relevance>{Extraction strategy implications}</relevance>
    </finding>

    <finding category="integration-patterns">
      <title>{Pattern for combining tasks + skills}</title>
      <detail>{How this works in practice}</detail>
      <source>{Documentation or examples}</source>
      <relevance>{How sdlc agents will use this}</relevance>
    </finding>
  </findings>

  <recommendations>
    <recommendation priority="high">
      <action>{Specific approach for sdlc redesign}</action>
      <rationale>{Why this approach based on research}</rationale>
    </recommendation>
  </recommendations>

  <code_examples>
    {Task tool usage examples}
    {Skill manifest examples}
    {Agent definition patterns}
  </code_examples>

  <metadata>
    <confidence level="{high|medium|low}">
      {Why this confidence level}
    </confidence>
    <dependencies>
      {What's needed to act on this research}
    </dependencies>
    <open_questions>
      {What couldn't be determined}
    </open_questions>
    <assumptions>
      {What was assumed}
    </assumptions>

    <quality_report>
      <sources_consulted>
        {List URLs/file paths of official documentation}
      </sources_consulted>
      <claims_verified>
        {Key findings verified with official sources}
      </claims_verified>
      <claims_assumed>
        {Findings based on inference}
      </claims_assumed>
      <contradictions_encountered>
        {Any conflicts and how resolved}
      </contradictions_encountered>
      <confidence_by_finding>
        {Individual confidence levels}
      </confidence_by_finding>
    </quality_report>
  </metadata>
</research>
```
</output_structure>

<incremental_output>
**CRITICAL: Write findings incrementally to prevent token limit failures**

Workflow:
1. Create tasks-skills-research.md with XML skeleton
2. As you research Claude Code tasks → immediately append <finding category="tasks-system">
3. As you research skills.sh → immediately append <finding category="skills-format">
4. As you analyze sdlc agents → immediately append <finding category="sdlc-analysis">
5. As you discover patterns → immediately append <finding category="integration-patterns">
6. Append code examples as you find them
7. After all research complete → write summary, recommendations, metadata

This ensures zero lost work if token limits are hit.
</incremental_output>

<research_execution>
Suggested order:
1. Use Task tool with claude-code-guide agent to fetch official Claude Code tasks documentation
2. Use WebSearch/WebFetch for skills.sh format documentation
3. Use Read tool to analyze sdlc plugin structure (start with plugin.json, then agents/, then commands/)
4. Use Glob to find all .md files in sdlc/agents/ and sdlc/commands/
5. Synthesize integration patterns from both systems
6. Write findings incrementally as each area completes
</research_execution>

<pre_submission_checklist>
Before submitting your research report, confirm:

**Scope Coverage**
- [ ] All task tools enumerated and documented
- [ ] skills.sh format fully understood
- [ ] Every sdlc agent/command analyzed
- [ ] Official documentation cited for tasks system

**Claim Verification**
- [ ] Each "tasks should be used for X" claim verified
- [ ] skills.sh installation verified from official docs
- [ ] sdlc analysis grounded in actual file reads
- [ ] Version numbers specified where relevant

**Quality Controls**
- [ ] Blind spots review completed
- [ ] Quality report filled out honestly
- [ ] Confidence levels assigned with justification
- [ ] Assumptions distinguished from verified facts

**Output Completeness**
- [ ] All required XML sections present
- [ ] SUMMARY.md created with substantive one-liner
- [ ] Sources consulted listed with URLs/paths
- [ ] Next steps clearly identified (planning phase)
</pre_submission_checklist>

<summary_requirements>
Create `.prompts/001-tasks-skills-research/SUMMARY.md` using this structure:

```markdown
# Tasks & Skills Integration Research

**[One substantive sentence summarizing key recommendation]**

## Version
v1

## Key Findings
- [Actionable finding about tasks system]
- [Actionable finding about skills.sh format]
- [Actionable finding about sdlc extraction strategy]
- [Actionable finding about integration patterns]

## Decisions Needed
- [Any architectural choices requiring user input]

## Blockers
None | [External dependencies if any]

## Next Step
Create planning prompt (tasks-skills-plan.md) to design the sdlc plugin redesign based on these findings.
```
</summary_requirements>

<success_criteria>
- All task tools (TaskCreate, TaskUpdate, TaskGet, TaskList) fully documented with schemas
- skills.sh marketplace format understood with installation mechanism
- Every sdlc agent and command analyzed for extractable components
- Integration patterns identified for combining tasks + skills in lightweight agents
- Sources are current (2026) and authoritative
- Findings are actionable for planning phase
- Metadata captures gaps honestly
- Quality report distinguishes verified from assumed
- SUMMARY.md created with substantive one-liner
- Ready for planning prompt to consume
</success_criteria>
