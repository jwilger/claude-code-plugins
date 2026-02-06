<session_initialization>
Before beginning research, verify today's date:
!`date +%Y-%m-%d`

Use this date when searching for "current" or "latest" information.
</session_initialization>

<research_objective>
Research the capabilities of Claude Opus 4.6, Claude Code's latest features (as of early 2026), and identify opportunities to improve the SDLC plugin's effectiveness — without breaking or degrading the existing SDLC workflow.

Purpose: Identify specific, actionable improvements to the SDLC plugin that leverage new model and tooling capabilities
Scope: Opus 4.6 model capabilities, Claude Code CLI features, hook system, agent framework, tool improvements
Output: opus46-features-research.md with structured findings
</research_objective>

<critical_constraint>
The SDLC plugin has a well-established workflow that MUST be preserved:

```
Setup → Design (discover → workflow → GWT → arch) → Plan → Work (TDD cycles) → PR → Review → Complete
```

The TDD cycle is mechanically enforced:
```
RED → DOMAIN (after red) → GREEN → DOMAIN (after green) → repeat
```

Key workflow characteristics that MUST NOT be degraded:
1. **Mechanical enforcement** via hooks and task dependencies
2. **Agent specialization** — 15 agents with file-type restrictions
3. **Fresh context protocol** — agents have zero memory, require complete context
4. **Domain-first design** — mandatory domain review after RED and GREEN
5. **Orchestrator-delegates pattern** — main orchestrator never writes code directly
6. **Event Modeling integration** — full support for event-sourced architecture design
7. **Task-based workflow** — dot CLI for local task management

Any proposed improvement must enhance these characteristics, not weaken them.
</critical_constraint>

<research_scope>
<include>
## 1. Opus 4.6 Model Capabilities
- What's new in Opus 4.6 vs previous models (Sonnet 4.5, earlier Opus)?
- Extended thinking / reasoning improvements
- Context window size and effective utilization
- Tool use improvements (parallel tool calling, reliability)
- Code generation quality improvements
- Multi-step reasoning improvements
- Any new capabilities unique to Opus 4.6

## 2. Claude Code CLI Features (2025-2026)
- Latest hook system capabilities (event types, return formats, prompt-based vs command-based)
- Agent/subagent framework improvements
- New tool types or tool improvements
- Background task execution capabilities
- Task management integration (TaskCreate, TaskUpdate, TaskList, TaskGet)
- Permission system improvements
- MCP server integration improvements
- Settings and configuration changes
- Any new features added in late 2025 / early 2026

## 3. Plugin System Capabilities
- Latest plugin.json schema and capabilities
- Skill system (skills.sh) features and patterns
- Output style system capabilities
- Command and agent frontmatter options
- Auto-discovery and loading mechanisms

## 4. Opportunities for SDLC Improvement
Based on findings from 1-3, identify:
- Where current SDLC agents could be smarter/more effective
- Where hook enforcement could be tighter or more nuanced
- Where the TDD cycle could benefit from better tooling
- Where context passing between agents could improve
- Where the orchestration protocol could leverage new features
- Where event modeling could benefit from new capabilities
- Where task management could be more automated
- Where code review and mutation testing could improve
</include>

<exclude>
- Changes that would break the existing TDD RED→DOMAIN→GREEN→DOMAIN cycle
- Changes that would remove mechanical enforcement of workflow gates
- Changes that would allow the orchestrator to write code directly
- Changes that would skip domain review
- Changes to the fundamental event modeling methodology
- Changes that require external paid services not already used
- Pricing or billing details for Claude API
</exclude>

<sources>
Official documentation (use WebFetch):
- https://docs.anthropic.com/en/docs/about-claude/models - Model capabilities
- https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking - Extended thinking
- https://docs.anthropic.com/en/docs/build-with-claude/tool-use - Tool use
- https://code.claude.com/docs - Claude Code documentation (primary source)

Search queries for WebSearch:
- "Claude Opus 4.6 capabilities 2026"
- "Claude Code features 2026"
- "Claude Code hooks system 2026"
- "Claude Code plugin development 2026"
- "Claude Code agent framework improvements 2026"
- "Claude Code background tasks 2026"
- "Claude Code MCP integration 2026"
- "Anthropic Claude 4.6 release notes"
</sources>
</research_scope>

<verification_checklist>
□ Verify Opus 4.6 specific capabilities (not just general Claude features)
□ Confirm Claude Code CLI version and latest features
□ Check hook system event types against official docs
□ Verify agent/subagent capabilities (tools available, context passing)
□ Confirm TaskCreate/TaskUpdate/TaskList/TaskGet tool schemas
□ Check plugin.json schema for any new fields
□ Verify skill system (skills.sh) current capabilities
□ Document which features are stable vs experimental
□ Confirm all findings against official Anthropic documentation
□ Cross-reference with the current SDLC plugin implementation to identify gaps
</verification_checklist>

<current_plugin_context>
The SDLC plugin (v16.0.0) currently uses:

**Agents (15):**
- TDD: red, green, domain (with file-type restrictions via hooks)
- Event Modeling: discovery, workflow-designer, gwt, model-checker
- Architecture: architect, design-facilitator, adr
- Review: code-reviewer, mutation
- Planning: story, ux
- Utility: file-updater

**Hooks:**
- PreToolUse (command-based): file-edit-auth.sh — blocks orchestrator from editing files
- SubagentStop (prompt-based): enforces domain review after RED and GREEN
- Stop (prompt-based): checks for unsaved memories, uncommitted work
- SessionStart (command-based): reminds to check auto memory
- PreCompact (command-based): reminds to save discoveries

**Commands (12):**
setup, start, work, pr, review, complete, design, plan, adr, remember, recall, domain-audit

**Skills (9):**
tdd-constraints, user-input-protocol, debugging-protocol, atomic-design, git-spice, orchestration-protocol, memory-protocol, event-modeling, task-management

**Task Management:** dot CLI (local, file-based)
**Git Workflow:** Standard or git-spice for stacked PRs
**Memory:** File-based auto memory in ~/.claude/projects/
</current_plugin_context>

<research_quality_assurance>
Before completing research, perform these checks:

<completeness_check>
- [ ] All 4 research areas covered (model, CLI, plugin system, opportunities)
- [ ] Each finding evaluated against the critical constraint
- [ ] Official documentation cited for Opus 4.6 claims
- [ ] Official documentation cited for Claude Code feature claims
- [ ] Current SDLC plugin implementation cross-referenced
</completeness_check>

<source_verification>
- [ ] Primary claims backed by official Anthropic documentation
- [ ] Version numbers and dates included where relevant
- [ ] Actual URLs provided for documentation references
- [ ] Distinguish verified facts from assumptions
</source_verification>

<blind_spots_review>
- [ ] Are there Claude Code features I didn't investigate?
- [ ] Did I check for improvements to the hook system specifically?
- [ ] Did I verify claims about Opus 4.6 vs just general Claude improvements?
- [ ] Did I consider plugin system improvements that could help?
- [ ] Did I look at improvements to MCP server integration?
</blind_spots_review>

<critical_claims_audit>
For any statement like "Opus 4.6 can now do X" or "Claude Code now supports Y":
- [ ] Is this verified by official documentation?
- [ ] Have I checked the actual release date?
- [ ] Could this be confused with a different model or version?
</critical_claims_audit>
</research_quality_assurance>

<output_structure>
Save to: `.prompts/004-opus46-features-research/opus46-features-research.md`

Write findings incrementally to the output file as you discover them:

1. Create the file with this initial structure:
```xml
<research>
  <summary>[Will complete at end]</summary>
  <findings></findings>
  <recommendations></recommendations>
  <code_examples></code_examples>
  <metadata></metadata>
</research>
```

2. As you research each area, immediately append findings:
   - Discover Opus 4.6 capability → Write finding
   - Find Claude Code feature → Write finding
   - Identify improvement opportunity → Write finding
   - Find code example → Append to code_examples

3. After all research complete:
   - Write summary (synthesize all findings)
   - Write recommendations (prioritized by impact and feasibility)
   - Write metadata (confidence, dependencies, etc.)

Structure findings using this XML format:

```xml
<research>
  <summary>
    {2-3 paragraph executive summary of key findings}
  </summary>

  <findings>
    <finding category="{model|cli|plugin|opportunity}">
      <title>{Finding title}</title>
      <detail>{Detailed explanation}</detail>
      <source>{Where this came from - URL or doc reference}</source>
      <relevance>{Why this matters for SDLC plugin improvement}</relevance>
      <constraint_impact>{How this affects the critical constraints - SAFE/ENHANCES/RISK}</constraint_impact>
    </finding>
  </findings>

  <recommendations>
    <recommendation priority="{high|medium|low}" effort="{small|medium|large}">
      <action>{What to change in the SDLC plugin}</action>
      <rationale>{Why this improvement matters}</rationale>
      <constraint_preservation>{How the core SDLC workflow is preserved}</constraint_preservation>
      <affected_components>{Which agents, hooks, commands, or skills are affected}</affected_components>
    </recommendation>
  </recommendations>

  <code_examples>
    {Relevant code patterns, hook configurations, agent definitions}
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
        {List URLs of official documentation and primary sources}
      </sources_consulted>
      <claims_verified>
        {Key findings verified with official sources}
      </claims_verified>
      <claims_assumed>
        {Findings based on inference or incomplete information}
      </claims_assumed>
      <contradictions_encountered>
        {Any conflicting information found and how resolved}
      </contradictions_encountered>
      <confidence_by_finding>
        {For critical findings, individual confidence levels}
      </confidence_by_finding>
    </quality_report>
  </metadata>
</research>
```
</output_structure>

<summary_requirements>
Create `.prompts/004-opus46-features-research/SUMMARY.md`

```markdown
# Opus 4.6 & Claude Code Features Research Summary

**{Substantive one-liner describing key finding}**

## Version
v1

## Key Findings
- {Most important finding or action}
- {Second key item}
- {Third key item}
- {Fourth key item}

## Decisions Needed
{Specific actionable decisions requiring user input, or "None"}

## Blockers
{External impediments preventing progress, or "None"}

## Next Step
Create planning prompt using these findings (.prompts/005-opus46-features-plan/)

---
*Confidence: {High|Medium|Low}*
*Iterations: 1*
*Full output: opus46-features-research.md*
```
</summary_requirements>

<pre_submission_checklist>
Before submitting your research report, confirm:

**Scope Coverage**
- [ ] Opus 4.6 model capabilities documented
- [ ] Claude Code CLI features documented
- [ ] Plugin system capabilities documented
- [ ] Improvement opportunities identified and evaluated
- [ ] Each opportunity checked against critical constraints

**Claim Verification**
- [ ] Each "Opus 4.6 can do X" claim verified with official docs
- [ ] Each "Claude Code now supports Y" claim verified with official docs
- [ ] URLs to official documentation included for key findings
- [ ] Version numbers specified where relevant

**Quality Controls**
- [ ] Blind spots review completed
- [ ] Quality report section filled out honestly
- [ ] Confidence levels assigned with justification
- [ ] Assumptions clearly distinguished from verified facts

**Output Completeness**
- [ ] All required XML sections present
- [ ] SUMMARY.md created with substantive one-liner
- [ ] Sources consulted listed with URLs
- [ ] Next steps clearly identified
- [ ] constraint_impact field filled for every finding
- [ ] constraint_preservation field filled for every recommendation
</pre_submission_checklist>

<success_criteria>
- All 4 research areas thoroughly covered
- Every finding includes constraint_impact assessment
- Every recommendation includes constraint_preservation explanation
- Sources are current (2025-2026) and authoritative
- Findings are actionable for the SDLC plugin specifically
- Metadata captures gaps honestly
- Quality report distinguishes verified from assumed
- SUMMARY.md created with substantive one-liner
- Ready for planning prompt to consume
</success_criteria>
