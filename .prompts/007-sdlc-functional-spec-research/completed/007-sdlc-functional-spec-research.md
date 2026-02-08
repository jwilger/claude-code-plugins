<research_objective>
Exhaustively research the sdlc plugin under `sdlc/` and produce `REPORT.md` at the project root — a complete functional specification of the SDLC process behavior.

Purpose: Enable someone to recreate the exact behavioral system on any agent harness without access to the plugin source code
Scope: Every behavioral aspect — workflows, rules, constraints, agent roles, phase transitions, enforcement mechanisms, personality modes, task management, design methodologies, code review, PR creation
Output: `REPORT.md` at project root (human-readable markdown, NOT XML)
</research_objective>

<critical_framing>
**IMPORTANT**: The output REPORT.md must describe BEHAVIOR, not implementation.

DO NOT use any of these terms:
- hooks, plugins, skills, commands, slash commands
- frontmatter, YAML metadata
- Claude Code, Claude, AI assistant
- subagent, agent (use "specialist role" or "specialized worker" instead)
- output-style (use "personality mode" or "operational profile")
- MCP, tool schemas

DO use terms like:
- "the system", "the orchestrator", "the process"
- "specialist role", "specialized worker", "dedicated process"
- "workflow phase", "operational mode"
- "enforcement rule", "constraint", "behavioral guard"
- "personality mode", "interaction style"

Write as if documenting a process that HUMANS or ANY automation could follow.
The document should read like a comprehensive process manual / functional specification.
</critical_framing>

<research_scope>
<include>
Thoroughly analyze EVERY file in these directories and document the behavioral specification:

1. **Orchestration rules** — `sdlc/output-styles/.templates/orchestration-rules.md`
   - Phase cascade protocol
   - Command routing
   - TDD enforcement rules
   - Task management integration
   - All behavioral constraints

2. **Personality modes** — `sdlc/output-styles/.templates/personality-marvin.md` and `personality-rules.md`
   - What personality options exist
   - How they affect interaction style
   - What stays the same regardless of personality

3. **All specialist roles (agents)** — every `.md` file in `sdlc/agents/`
   - What each role does
   - What constraints it operates under
   - What files/areas it can and cannot touch
   - How it interacts with other roles
   - Its specific behavioral rules

4. **All user-initiated workflows (commands)** — every `.md` file in `sdlc/commands/`
   - What each workflow does step by step
   - What inputs it requires
   - What outputs it produces
   - What orchestration rules apply

5. **All portable skills** — every `SKILL.md` in `sdlc/skills/*/`
   - What behavioral knowledge each encodes
   - Constraints and protocols
   - How they modify system behavior

6. **Documentation** — everything in `sdlc/docs/`
   - TDD workflow details
   - Event Modeling methodology
   - Task management workflow
   - dot CLI usage
   - GitHub CLI extensions

7. **Enforcement mechanisms** — `sdlc/.claude-plugin/hooks/` and `sdlc/hooks/`
   - What behavioral guards exist
   - What they prevent
   - What they enforce
   - When they trigger

8. **Setup and initialization** — how the system bootstraps itself in a new project

9. **Inter-role dependencies** — how specialist roles hand off to each other, what sequences are mandatory

10. **Memory and recall** — how the system remembers and retrieves project-specific knowledge
</include>

<exclude>
- Implementation details of how files are loaded/parsed
- Claude Code-specific configuration syntax
- Plugin marketplace mechanics
- Version management scripts
- Build/generation tooling for output styles
</exclude>
</research_scope>

<verification_checklist>
Before completing, verify:
□ Every agent file in sdlc/agents/ has been read and documented
□ Every command file in sdlc/commands/ has been read and documented
□ Every skill in sdlc/skills/ has been read and documented
□ The orchestration rules template has been fully analyzed
□ Both personality modes have been documented
□ All hook scripts have been read and their behavioral effects documented
□ The TDD workflow document has been incorporated
□ The Event Modeling methodology has been incorporated
□ The task management workflow has been incorporated
□ The dot CLI integration has been documented
□ The GitHub CLI extensions have been documented
□ All cross-references between roles have been mapped
□ The phase cascade protocol is fully described
□ All enforcement mechanisms are catalogued
□ The setup/initialization process is documented
□ The memory/recall system is documented
□ The shared orchestration rules (commands/shared/) are incorporated
□ The design-facilitator workflow is fully documented
□ The ADR process is fully documented
□ The PR creation and review processes are fully documented
</verification_checklist>

<output_requirements>
Write `REPORT.md` at the project root with this structure:

```markdown
# SDLC Process Functional Specification

## 1. Overview
Brief description of what the system does and its philosophy

## 2. System Architecture
### 2.1 Operational Profiles
### 2.2 Orchestration Model
### 2.3 Specialist Roles Overview

## 3. Orchestration Rules
### 3.1 Phase Cascade Protocol
### 3.2 Command Routing
### 3.3 Behavioral Constraints
### 3.4 Task Management Integration

## 4. Workflow Specifications
### 4.1 Project Setup
### 4.2 Starting Work (Task Selection)
### 4.3 Development Work (TDD Cycle)
### 4.4 Planning
### 4.5 Design Facilitation
### 4.6 Architecture Decision Records
### 4.7 Pull Request Creation
### 4.8 Code Review
### 4.9 Domain Audit
### 4.10 Memory Management (Remember/Recall)
### 4.11 Task Completion

## 5. Specialist Role Specifications
### 5.1 TDD Roles
#### 5.1.1 Red (Test Writer)
#### 5.1.2 Green (Implementation Writer)
#### 5.1.3 Domain (Domain Review)
### 5.2 Event Modeling Roles
#### 5.2.1 Discovery
#### 5.2.2 Workflow Designer
#### 5.2.3 GWT (Given-When-Then)
#### 5.2.4 Model Checker
### 5.3 Architecture Roles
#### 5.3.1 Architect
#### 5.3.2 Design Facilitator
#### 5.3.3 ADR Writer
### 5.4 Review Roles
#### 5.4.1 Code Reviewer
#### 5.4.2 Mutation Tester
### 5.5 Planning Roles
#### 5.5.1 Story Writer
#### 5.5.2 UX Specialist
### 5.6 Utility Roles
#### 5.6.1 File Updater

## 6. Methodologies
### 6.1 Test-Driven Development Protocol
### 6.2 Event Modeling
### 6.3 Domain-Driven Design Principles
### 6.4 Atomic Design (if applicable)

## 7. Enforcement Mechanisms
### 7.1 File Type Restrictions by Role
### 7.2 TDD Phase Enforcement
### 7.3 Domain Review Requirements
### 7.4 Pre-operation Validations

## 8. Tool Integrations
### 8.1 Task Management (dot CLI)
### 8.2 GitHub CLI
### 8.3 PR Review Extensions

## 9. Cross-Role Interaction Map
How roles hand off to each other, mandatory sequences, dependency chains

## 10. Portable Knowledge Modules
What reusable behavioral knowledge the system carries (skills translated to process knowledge)

## 11. Appendices
### A. Complete Phase Transition Diagram
### B. File Restriction Matrix
### C. Glossary
```

CRITICAL CONSTRAINTS:
- Use NO Claude Code terminology
- Write as a process specification, not a software manual
- Be exhaustive — every rule, every constraint, every behavioral nuance
- Include actual content from rules (quote orchestration rules, constraints, etc.)
- The document should be 3000-6000 lines to capture full detail
- Use concrete examples where the source material provides them

Write findings incrementally to REPORT.md as you research:
1. Create the file with the section skeleton
2. Fill in each section as you research the corresponding source files
3. This ensures no work is lost if token limits are hit
</output_requirements>

<efficiency>
For maximum efficiency, invoke all independent tool operations simultaneously rather than sequentially.

- Read all agent files in parallel
- Read all command files in parallel
- Read all skill files in parallel
- Read all doc files in parallel

Group reads by directory for parallel execution.
</efficiency>

<summary_requirements>
After completing REPORT.md, also create `.prompts/007-sdlc-functional-spec-research/SUMMARY.md` with:
- Substantive one-liner
- Key findings
- Decisions needed
- Blockers
- Next step
- Confidence level
</summary_requirements>

<success_criteria>
- Every source file in sdlc/ has been read and its behavioral content extracted
- REPORT.md is a complete, standalone functional specification
- Someone could recreate the entire SDLC system from REPORT.md alone
- No Claude Code implementation terminology appears in the output
- All specialist roles are fully specified with their constraints
- All workflows are documented step-by-step
- All enforcement mechanisms are catalogued
- Cross-role interactions are mapped
- The document is exhaustive and leaves no behavioral gaps
</success_criteria>
