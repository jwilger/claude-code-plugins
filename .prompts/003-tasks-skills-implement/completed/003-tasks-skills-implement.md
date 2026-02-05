# Implement: sdlc Plugin Redesign with Tasks & Skills

<objective>
Execute the sdlc plugin redesign to integrate Claude Code's tasks system and extract reusable skills for the skills.sh marketplace.

Purpose: Transform sdlc plugin into a lightweight, composable system where agents load skills and leverage tasks for workflow coordination.

Output:
- Extracted skills in top-level skills/ directory
- Restructured sdlc agents as skill loaders
- Updated marketplace configuration
- Migration documentation
</objective>

<context>
Research findings: @.prompts/001-tasks-skills-research/tasks-skills-research.md
Implementation plan: @.prompts/002-tasks-skills-plan/tasks-skills-plan.md

Current codebase:
- @sdlc/.claude-plugin/plugin.json
- @sdlc/agents/
- @sdlc/commands/
- @.claude-plugin/marketplace.json
</context>

<requirements>
## Functional Requirements
- Extract reusable capabilities from sdlc agents into standalone skills
- Restructure sdlc agents to be lightweight skill loaders (~200 lines each)
- Integrate TaskCreate/TaskUpdate/TaskList into multi-step workflows
- Publish skills to top-level skills/ directory installable via npx
- Maintain backward compatibility with existing /sdlc:* commands
- Version all changes according to CLAUDE.md guidelines

## Quality Requirements
- Skills must work in any skills-compatible agent harness
- Agents must clearly document which skills they require
- Tasks used appropriately (multi-step workflows, not trivial operations)
- Clean separation between skill logic and agent orchestration
- Comprehensive documentation for migration

## Constraints
- Must analyze existing sdlc prompts for reusable components (don't discard without review)
- Follow version management rules from CLAUDE.md (update plugin.json, marketplace.json, setup.md)
- Preserve Marvin output style and existing command structure
- Test extracted skills standalone before restructuring agents
</requirements>

<implementation>
Follow the phased approach from tasks-skills-plan.md. Execute phases sequentially:

## Phase 1: Analysis & Extraction Strategy
Thoroughly analyze existing sdlc agents to identify:
- Common patterns used across multiple agents
- Self-contained capabilities (Event Modeling, TDD workflows, GitHub integration)
- Reusable prompt templates (GWT tests, ADRs, etc.)
- Task-appropriate workflows (multi-step processes in /work, /pr, /design commands)

Create inventory document mapping capabilities to extractable skills.

## Phase 2: Skill Structure Design
Design the top-level skills/ directory structure:
```
skills/
├── event-modeling/
│   ├── skill.json (manifest)
│   ├── README.md
│   └── templates/
├── tdd-workflow/
│   ├── skill.json
│   └── ...
├── gwt-test-gen/
└── ...
```

Define skill manifest format compatible with skills.sh and document loading mechanism.

## Phase 3: Task Integration Pattern
Define patterns for when agents should create tasks:
- TaskCreate for /work command's research → plan → implement workflow
- TaskCreate for /design command's Event Modeling phases
- TaskUpdate to mark progress through phases
- TaskList to show user overall workflow progress
- Avoid tasks for simple commands like /review

Document task naming conventions (subject, activeForm) and metadata usage.

## Phase 4: Skill Extraction
Extract skills one at a time, starting with simplest:
1. Extract GWT test generation (likely simplest)
2. Extract Event Modeling templates
3. Extract TDD workflow patterns
4. Extract GitHub integration patterns
5. Continue for all identifiable skills

Test each skill standalone before proceeding to next.

## Phase 5: Agent Restructuring
Rewrite sdlc agents as lightweight skill loaders:
- Reduce agent prompt size to ~200 lines
- Replace embedded logic with skill references
- Maintain existing command interfaces
- Test backward compatibility

Start with one agent, validate approach, then continue.

## Phase 6: Marketplace Integration
- Publish extracted skills to top-level skills/ directory
- Update .claude-plugin/marketplace.json to list new skills
- Configure skills for npx installation
- Test installation workflow: `npx skills add <skill-name>`

## Phase 7: Documentation & Migration
- Create MIGRATION.md guide for existing sdlc users
- Update CLAUDE.md with new architecture notes
- Write README.md for each skill
- Update version numbers (plugin.json, marketplace.json, setup.md)
- Generate changelog

Follow phases from plan, creating subtasks as needed for complex phases.

## What to Preserve
- Existing command definitions (setup, work, pr, review, design, adr, plan, start)
- Marvin output style personality
- GitHub CLI integration patterns
- git-spice stacked PR workflows
- Event Modeling diagram generation logic
- TDD/GWT test generation patterns
- Domain analysis workflows

## What to Transform
- Agent prompt files: extract reusable logic to skills
- Task integration: add TaskCreate/Update to multi-step commands
- Skill loading: replace monolithic prompts with skill references
- Directory structure: publish skills to top-level
</implementation>

<output>
## Files to Create
Top-level skills directory:
- `./skills/<skill-name>/skill.json` - Skill manifests
- `./skills/<skill-name>/README.md` - Skill documentation
- `./skills/<skill-name>/**` - Skill implementation files

## Files to Modify
- `./sdlc/agents/**/*.md` - Restructure as lightweight skill loaders
- `./sdlc/.claude-plugin/plugin.json` - Update version, add skill dependencies
- `./.claude-plugin/marketplace.json` - Add skill entries
- `./sdlc/commands/setup.md` - Update version references throughout
- `./CLAUDE.md` - Document new architecture

## Files to Create (Documentation)
- `./MIGRATION.md` - Guide for existing sdlc users
- `./skills/README.md` - Overview of extracted skills
- `./CHANGELOG.md` - Document changes (or update existing)
</output>

<verification>
Before declaring complete:

## Per-Phase Verification
After each phase completes:
- [ ] Phase deliverables match plan specifications
- [ ] Documentation updated for changes
- [ ] No regressions in existing functionality

## Skill Extraction Verification
For each extracted skill:
- [ ] Skill has valid manifest (skill.json)
- [ ] Skill works standalone (not dependent on sdlc plugin)
- [ ] Skill documentation (README.md) explains usage
- [ ] Skill can be discovered via skills.sh mechanisms

## Agent Restructuring Verification
For each restructured agent:
- [ ] Agent loads skills correctly
- [ ] Agent is <250 lines (significantly lighter than before)
- [ ] Agent maintains backward compatibility
- [ ] Existing commands still work (/sdlc:work, /sdlc:design, etc.)

## Tasks Integration Verification
- [ ] Tasks created for multi-step workflows (not trivial operations)
- [ ] Task activeForm uses present continuous ("Analyzing domain")
- [ ] Task dependencies (blockedBy) used where appropriate
- [ ] Tasks marked completed when work finishes

## Marketplace Integration Verification
- [ ] Skills published to top-level skills/ directory
- [ ] Skills listed in marketplace.json
- [ ] `npx skills list` shows extracted skills
- [ ] `npx skills add <skill>` successfully installs

## Version Management Verification
- [ ] sdlc/.claude-plugin/plugin.json version bumped
- [ ] .claude-plugin/marketplace.json versions updated
- [ ] sdlc/commands/setup.md version strings updated
- [ ] Semver bump is appropriate (likely 4.0.0 for breaking restructure)

## Documentation Verification
- [ ] MIGRATION.md exists and explains upgrade path
- [ ] CLAUDE.md updated with new architecture notes
- [ ] Each skill has README.md
- [ ] CHANGELOG.md documents all changes
</verification>

<execution_strategy>
## Incremental Approach
This is a large refactoring. Execute in phases:

1. Start with Phase 1 (analysis) - understand what exists
2. Design skill structure (Phase 2) - get architecture right
3. Extract ONE skill as proof of concept (partial Phase 4)
4. Restructure ONE agent to use that skill (partial Phase 5)
5. Validate approach works before proceeding to remaining skills/agents
6. Complete remaining extractions and restructuring
7. Finish with marketplace integration and documentation

## Risk Mitigation
- Commit after each phase completion
- Test backward compatibility early
- Keep original agent files as backups until migration validated
- Version bump clearly indicates breaking changes

## User Collaboration Points
May need to ask user:
- Which agent to start with for restructuring (pick simplest first?)
- Whether to preserve deprecated patterns for compatibility
- Semver bump strategy (4.0.0 breaking vs 3.13.0 additive)
- Migration timeline expectations
</execution_strategy>

<summary_requirements>
Create `.prompts/003-tasks-skills-implement/SUMMARY.md` as work progresses:

```markdown
# sdlc Plugin Redesign Implementation

**[One substantive sentence describing implementation status]**

## Version
v1

## Files Created
- `./skills/<skill-name>/skill.json` - [description]
- `./skills/<skill-name>/README.md` - [description]
- [Continue for all created files]

## Files Modified
- `./sdlc/agents/<agent>.md` - [what changed]
- [Continue for all modified files]

## Test Status
- [ ] Phase 1 complete (analysis)
- [ ] Phase 2 complete (skill structure)
- [ ] Phase 3 complete (task patterns)
- [ ] Phase 4 complete (skill extraction)
- [ ] Phase 5 complete (agent restructuring)
- [ ] Phase 6 complete (marketplace integration)
- [ ] Phase 7 complete (documentation)

## Decisions Needed
- [Any architectural choices requiring user input during implementation]

## Blockers
None | [Issues encountered]

## Next Step
[What's next - continue to next phase, test extracted skills, update documentation, etc.]
```

Update SUMMARY.md as implementation progresses through phases.
</summary_requirements>

<success_criteria>
Implementation is complete when:
- [ ] All reusable sdlc capabilities extracted to standalone skills
- [ ] Skills published to top-level skills/ directory with manifests
- [ ] sdlc agents restructured as lightweight skill loaders (~200 lines each)
- [ ] Tasks integrated into multi-step workflows (not trivial operations)
- [ ] All existing /sdlc:* commands still work (backward compatibility maintained)
- [ ] Skills installable via `npx skills add <skill-name>`
- [ ] Version numbers updated in all three locations (plugin.json, marketplace.json, setup.md)
- [ ] MIGRATION.md created for existing users
- [ ] CLAUDE.md updated with architecture notes
- [ ] Each skill has documentation (README.md)
- [ ] SUMMARY.md updated with implementation status
- [ ] All verification criteria pass
- [ ] Changes committed with appropriate commit messages
</success_criteria>
