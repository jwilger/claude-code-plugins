<objective>
Implement ALL phases of improvements to the SDLC plugin based on the research findings and implementation plan, shipping as a single v17.0.0 release.

Purpose: Execute all improvements while preserving the core SDLC workflow
Output: Modified plugin files with improvements applied and verified
</objective>

<user_decisions>
CRITICAL: The user has made the following decisions that OVERRIDE the plan:

1. **NO MODEL ROUTING**: Skip all model routing tasks. Do NOT add `model:` fields to any agents. All agents inherit the session model. Remove any tasks related to model routing.

2. **INCLUDE FULL PHASE 5**: Include both the spike research AND the implementation of parallel review (if the spike is positive). Agent teams for parallel code review are desired.

3. **SINGLE RELEASE**: Ship everything as v17.0.0. Do NOT do per-phase version bumps. Update version from 16.0.0 to 17.0.0 at the end, in all 3 files.
</user_decisions>

<context>
Research findings: @.prompts/004-opus46-features-research/opus46-features-research.md
Implementation plan: @.prompts/005-opus46-features-plan/opus46-features-plan.md

Current plugin structure:
- Plugin root: /home/jwilger/projects/claude-code-plugins/sdlc/
- Agents: sdlc/agents/ (15 specialized agents)
- Commands: sdlc/commands/ (12 slash commands)
- Skills: sdlc/skills/ (9 portable skills)
- Output style templates: sdlc/output-styles/.templates/
- Output style build script: sdlc/output-styles/.build-output-styles.sh
- Plugin manifest: sdlc/.claude-plugin/plugin.json
- Marketplace: .claude-plugin/marketplace.json
</context>

<critical_constraint>
BEFORE implementing ANY change, verify it does not break:

1. **TDD Cycle**: RED → DOMAIN (after red) → GREEN → DOMAIN (after green)
2. **Hook Enforcement**: PreToolUse blocks orchestrator file edits; SubagentStop enforces domain review
3. **Agent Specialization**: Each agent restricted to its file types
4. **Fresh Context Protocol**: Agents require complete context every invocation
5. **Orchestrator Delegation**: Main orchestrator never writes code
6. **Event Modeling**: Full design workflow preserved
7. **Local Task Management**: dot CLI integration preserved

If ANY change would violate these, STOP and flag it. Do not proceed.
</critical_constraint>

<requirements>
Read the implementation plan at @.prompts/005-opus46-features-plan/opus46-features-plan.md

Execute tasks from ALL phases (1 through 5) with these modifications:

**Phase 1 modifications:**
- SKIP all model routing tasks (user decision: no model routing)
- DO implement persistent agent memory tasks (add `memory: project` to domain, code-reviewer, architect)

**Phases 2-4:** Execute as planned

**Phase 5:** Execute fully — do the spike research first, then implement parallel review if feasible

For each task:
1. **Read the current file** before modifying it
2. **Understand the existing content** and its role in the workflow
3. **Make the specific change** described in the task
4. **Verify the constraint_check** passes for that task
5. **Move to the next task** only after verification

Special rules for specific file types:
- **Output style templates** (sdlc/output-styles/.templates/): Edit the template files, NOT the generated output files. The build script will regenerate them.
- **Agent files** (sdlc/agents/): Preserve the existing tools list and file-type restrictions. Only improve prompts/instructions.
- **Command files** (sdlc/commands/): Preserve the existing frontmatter fields. Only improve content.
- **Skill files** (sdlc/skills/*/SKILL.md): Preserve YAML frontmatter structure. Only improve content.
- **Hook configurations**: Changes to hooks go through the setup.md command template AND/OR hooks.json — read both before modifying.

Version management:
- After completing ALL phases, update version from 16.0.0 to 17.0.0 in ALL THREE locations:
  1. sdlc/.claude-plugin/plugin.json
  2. .claude-plugin/marketplace.json
  3. sdlc/commands/setup.md (search for "16.0.0", replace all instances with "17.0.0")
</requirements>

<implementation>
Execute phases sequentially. For each task in each phase:

1. Read the affected file(s) listed in the task
2. Apply the change described
3. If the file is an output style template:
   - Edit the file in sdlc/output-styles/.templates/
   - Run: `cd sdlc/output-styles && ./.build-output-styles.sh`
   - Verify the generated files look correct
4. After each task, verify:
   - The change matches the acceptance criteria
   - The constraint_check passes
   - No unintended side effects

After ALL phases complete:
1. Run the constraint verification protocol from the plan
2. Verify all commands are still referenced correctly
3. Verify all 15 agents are still properly defined
4. Verify all 9 skills still exist
5. Update version numbers in all 3 files (16.0.0 → 17.0.0)
6. Build output styles if any templates were modified
</implementation>

<verification>
After all phases implemented:

1. **Output style verification**: If templates were modified:
   ```bash
   cd sdlc/output-styles && ./.build-output-styles.sh
   ```

2. **Agent verification**: All 15 agents still have correct frontmatter:
   ```bash
   ls sdlc/agents/*.md | wc -l  # Should be 15
   ```

3. **Command verification**: All commands still exist:
   ```bash
   ls sdlc/commands/*.md | wc -l
   ```

4. **Skill verification**: All 9 skills still exist:
   ```bash
   ls sdlc/skills/*/SKILL.md | wc -l  # Should be >= 9
   ```

5. **Version consistency**: All three files have version 17.0.0:
   ```bash
   grep '"version"' sdlc/.claude-plugin/plugin.json
   grep -A2 '"sdlc"' .claude-plugin/marketplace.json | grep version
   grep '17.0.0' sdlc/commands/setup.md | head -5
   ```

6. **Constraint verification protocol**: Run ALL constraint checks from the plan
</verification>

<summary_requirements>
Create `.prompts/006-opus46-features-implement/SUMMARY.md`

```markdown
# Opus 4.6 Features Implementation Summary

**{Substantive one-liner describing what was implemented across all phases}**

## Version
v1

## Key Findings
- {Phase 1 implementation summary}
- {Phase 2 implementation summary}
- {Phase 3 implementation summary}
- {Phase 4 implementation summary}
- {Phase 5 implementation summary}
- Version bumped to v17.0.0

## Files Created/Modified
- `path/to/file` - Description of change

## Decisions Needed
{Any decisions that came up during implementation, or "None"}

## Blockers
{Any issues encountered, or "None"}

## Next Step
{Review changes, test, and commit}

---
*Confidence: {High|Medium|Low}*
*Iterations: 1*
```
</summary_requirements>

<success_criteria>
- All tasks from all 5 phases completed (minus model routing, per user decision)
- Every constraint_check passes
- Constraint verification protocol passes for each phase
- All 15 agents intact and functional
- All commands intact and functional
- All 9 skills intact and functional
- Output styles regenerated if templates modified
- Version updated to 17.0.0 in all 3 files
- No degradation of core SDLC workflow
- SUMMARY.md created with complete files list
</success_criteria>
