# Skill Extraction Plan: 10 Portable Skills from sdlc Plugin

**Date:** 2026-02-04
**Version:** 1.0
**Purpose:** Document exactly which skills would be extracted, why, and how

---

## Overview

This document identifies 10 skill extraction candidates from the sdlc plugin's shared protocols, provides rationale for each extraction, and describes the transformation from plugin-specific command to portable skill.

**Extraction Principle:** Skills document portable knowledge (WHAT and WHY), while plugin-specific features (hooks, tool restrictions, Claude Code integrations) remain in the plugin.

---

## Skill Extraction Candidates

### 1. tdd-constraints

**Current Location:** `sdlc/commands/shared/tdd-constraints.md`

**Current Size:** ~200 lines

**Purpose:** Document TDD phase boundaries and responsibilities for red/green/domain workflow

**Why Extract:**
- **Most self-contained** - No dependencies on other protocols
- **Core to sdlc value proposition** - TDD discipline is the foundation
- **Universally applicable** - TDD principles work across all programming languages and frameworks
- **High portability** - Other agents can benefit (Cursor, Windsurf doing TDD)

**Extraction Complexity:** LOW
- No external tool dependencies
- No references to other protocols
- Pure methodology documentation
- Clear boundaries (red phase, green phase, domain phase)

**Portability Considerations:**
- **Claude Code-specific:** Hooks that enforce constraints (PreToolUse, PostToolUse)
- **Portable:** Phase responsibilities, workflow order, anti-patterns
- **Integration notes:** Document that Claude Code uses hooks, other agents rely on prompt discipline

**Transformed SKILL.md Structure:**

```yaml
---
name: tdd-constraints
description: TDD phase boundaries and responsibilities for red/green/domain workflow
version: 1.0.0
author:
  name: John Wilger
  email: john@johnwilger.com
keywords: [tdd, test-driven-development, domain-modeling, red-green-refactor]
metadata:
  internal: false
  compatibility: ["claude-code", "cursor", "windsurf", "cline", "copilot"]
---

# TDD Constraints

## Purpose
Enforce disciplined TDD workflow where red writes ONE failing test, domain reviews and creates types, green implements minimally, and domain reviews implementation.

## Phase Responsibilities

### Red Phase
- Write ONE failing test at a time
- Use ONE assertion per test
- Reference types that should exist (let compiler fail)
- Test code ONLY - no type definitions or implementations
- Run test and paste FULL output showing failure

[Content from current tdd-constraints.md...]

## Integration

### Claude Code
Agents enforce via hooks:
- red agent: PreToolUse hooks block non-test file edits
- domain agent: PreToolUse hooks block non-type file edits
- green agent: PreToolUse hooks block test file edits

### Other Agents
Rely on prompt discipline and code review.
```

**Files Affected:**
- Create: `skills/tdd-constraints/SKILL.md`
- Modify: All agents that reference `sdlc:shared/tdd-constraints`
- Deprecate (v5.0.0): `sdlc/commands/shared/tdd-constraints.md`

---

### 2. user-input-protocol

**Current Location:** `sdlc/commands/shared/user-input-protocol.md`

**Current Size:** ~100 lines

**Purpose:** Define checkpoint and question format for user interaction

**Why Extract:**
- **Universally needed** - All agents benefit from consistent user interaction patterns
- **No dependencies** - Standalone interaction protocol
- **Small and focused** - Easy to extract and maintain
- **High value** - Prevents agents from getting stuck without user input

**Extraction Complexity:** LOW
- No tool dependencies
- No protocol cross-references
- Simple format specification
- Clear use cases

**Portability Considerations:**
- **Portable:** Checkpoint format (AWAITING_USER_INPUT:), question format
- **Claude Code-specific:** None - this is universal pattern
- **Integration notes:** Works across all agent frameworks

**Transformed SKILL.md Structure:**

```yaml
---
name: user-input-protocol
description: Checkpoint and question format for pausing work to request user input
version: 1.0.0
keywords: [user-interaction, checkpoints, questions, workflow]
metadata:
  compatibility: ["claude-code", "cursor", "windsurf", "cline", "copilot", "aider"]
---

# User Input Protocol

## Purpose
Prevent agents from getting stuck by defining clear patterns for checkpoints (pausing work) and questions (requesting clarification).

## Checkpoint Format

When you need to pause work and wait for user direction:

```
AWAITING_USER_INPUT:
<description of decision point>

OPTIONS:
1. <first option>
2. <second option>
3. <third option>

RECOMMENDATION: <which option you suggest and why>
```

[Content from current user-input-protocol.md...]
```

**Files Affected:**
- Create: `skills/user-input-protocol/SKILL.md`
- Modify: 12+ agents that reference this protocol
- Deprecate (v5.0.0): `sdlc/commands/shared/user-input-protocol.md`

---

### 3. debugging-protocol

**Current Location:** `sdlc/commands/shared/debugging-protocol.md`

**Current Size:** ~150 lines

**Purpose:** Systematic debugging methodology for agents

**Why Extract:**
- **Standalone methodology** - No dependencies on sdlc specifics
- **Broadly useful** - All agents benefit from systematic debugging
- **Portable** - Methodology works across contexts
- **High value** - Prevents random guess-and-check debugging

**Extraction Complexity:** LOW
- No tool dependencies
- No protocol cross-references
- Pure methodology
- Clear steps

**Portability Considerations:**
- **Portable:** Entire debugging methodology
- **Claude Code-specific:** None
- **Integration notes:** Marvin personality references can be removed or noted as optional

**Transformed SKILL.md Structure:**

```yaml
---
name: debugging-protocol
description: Systematic debugging methodology for agents investigating failures
version: 1.0.0
keywords: [debugging, troubleshooting, investigation, methodology]
metadata:
  compatibility: ["claude-code", "cursor", "windsurf", "cline", "copilot"]
---

# Debugging Protocol

## Purpose
Replace random guess-and-check with systematic investigation.

## The Process

### Step 1: Gather Evidence
[Content from current debugging-protocol.md...]

### Step 2: Form Hypothesis
...

### Step 3: Test Hypothesis
...

### Step 4: Iterate or Conclude
...

## Anti-Patterns
- "Let me try this" without hypothesis
- Changing multiple things at once
- Not verifying assumptions
```

**Files Affected:**
- Create: `skills/debugging-protocol/SKILL.md`
- Modify: Agents that reference debugging protocol
- Deprecate (v5.0.0): `sdlc/commands/shared/debugging-protocol.md`

---

### 4. atomic-design

**Current Location:** `sdlc/commands/shared/atomic-design.md`

**Current Size:** ~120 lines

**Purpose:** UI component hierarchy and composition patterns

**Why Extract:**
- **Standalone design system** - No sdlc-specific dependencies
- **Portable** - UI design principles work across frameworks
- **Focused** - Clear component hierarchy (atoms, molecules, organisms, templates, pages)
- **Reusable** - Other agents building UIs benefit

**Extraction Complexity:** LOW
- No tool dependencies
- No protocol cross-references
- Design pattern documentation
- Clear examples

**Portability Considerations:**
- **Portable:** Entire atomic design hierarchy
- **Claude Code-specific:** None
- **Integration notes:** Works with any UI framework (React, Vue, Svelte, etc.)

**Transformed SKILL.md Structure:**

```yaml
---
name: atomic-design
description: UI component hierarchy using atomic design principles (atoms, molecules, organisms, templates, pages)
version: 1.0.0
keywords: [ui, design-system, components, atomic-design, frontend]
metadata:
  compatibility: ["claude-code", "cursor", "windsurf", "cline", "copilot"]
---

# Atomic Design

## Purpose
Structure UI components using atomic design methodology for consistency and reusability.

## Component Hierarchy

### Atoms
Smallest building blocks (buttons, inputs, labels)

### Molecules
Simple combinations of atoms (search form, card header)

### Organisms
Complex combinations (navigation bar, product grid)

[Content from current atomic-design.md...]
```

**Files Affected:**
- Create: `skills/atomic-design/SKILL.md`
- Modify: ux agent (loads this skill)
- Deprecate (v5.0.0): `sdlc/commands/shared/atomic-design.md`

---

### 5. git-spice

**Current Location:** `sdlc/commands/shared/git-spice.md`

**Current Size:** ~250 lines

**Purpose:** Stacked PR workflow patterns using git-spice CLI

**Why Extract:**
- **Tool-specific patterns** - Not sdlc-exclusive, any project using git-spice benefits
- **Valuable workflow** - Stacked PRs improve development velocity
- **Portable** - Works across agent frameworks
- **Decision tree** - Clear when to use git-spice vs standard git

**Extraction Complexity:** MEDIUM
- Depends on git-spice CLI (external tool)
- Integration with GitHub workflows
- Complex recovery scenarios
- References orchestration protocol (for git operation rules)

**Portability Considerations:**
- **Portable:** Git-spice patterns, stacked PR workflow, recovery procedures
- **Claude Code-specific:** Integration with orchestration.md (reference, don't duplicate)
- **Prerequisites:** git-spice CLI installed (`command -v gs`)

**Transformed SKILL.md Structure:**

```yaml
---
name: git-spice
description: Stacked PR workflow patterns using git-spice CLI for managing dependent branches
version: 1.0.0
keywords: [git, stacked-prs, git-spice, workflow, branching]
metadata:
  compatibility: ["claude-code", "cursor", "windsurf", "cline"]
  prerequisites:
    - description: "git-spice CLI installed (https://abhinav.github.io/git-spice/)"
      required: true
      check_command: "command -v gs"
---

# git-spice Workflow

## Purpose
Manage stacked pull requests where changes build on each other sequentially.

## Prerequisites
- git-spice installed: `brew install git-spice` or `go install go.abhg.dev/git-spice@latest`
- GitHub repository
- Understanding of git branching

## Decision Tree

### When to Use git-spice
[Content from current git-spice.md...]

### Critical Operations
- After PR merges: `gs repo sync`
- View stack: `gs log short`
- Recovery: `gs upstack onto <correct-base>`

[Full content...]
```

**Files Affected:**
- Create: `skills/git-spice/SKILL.md`
- Modify: orchestration.md references (or keep in plugin)
- Deprecate (v5.0.0): `sdlc/commands/shared/git-spice.md`

---

### 6. github-issues

**Current Location:** `sdlc/commands/shared/github-issues.md`

**Current Size:** ~200 lines

**Purpose:** GitHub CLI patterns for issue management and project automation

**Why Extract:**
- **Tool-specific patterns** - Not sdlc-exclusive, any GH project benefits
- **Valuable workflow** - Issue management is universal need
- **Portable** - Works across agent frameworks
- **Automation patterns** - Scripting GH operations

**Extraction Complexity:** MEDIUM
- Depends on gh CLI + extensions
- Multiple extension requirements
- Integration with GitHub Projects
- References orchestration protocol

**Portability Considerations:**
- **Portable:** gh CLI patterns, issue workflows, sub-issue creation
- **Claude Code-specific:** None (gh CLI is universal)
- **Prerequisites:** gh CLI + extensions (gh-issue-ext, gh-project-ext)

**Transformed SKILL.md Structure:**

```yaml
---
name: github-issues
description: GitHub CLI patterns for issue management, sub-issues, and project automation
version: 1.0.0
keywords: [github, gh-cli, issues, project-management, automation]
metadata:
  compatibility: ["claude-code", "cursor", "windsurf", "cline"]
  prerequisites:
    - description: "GitHub CLI installed (https://cli.github.com/)"
      required: true
      check_command: "command -v gh"
    - description: "gh-issue-ext extension (gh extension install github/gh-issue-ext)"
      required: true
    - description: "gh-project-ext extension (gh extension install github/gh-project-ext)"
      required: true
---

# GitHub Issues Workflow

## Purpose
Manage GitHub issues, create sub-issues, and automate project board updates using gh CLI.

## Prerequisites
```bash
# Install gh CLI
brew install gh  # or equivalent

# Install extensions
gh extension install github/gh-issue-ext
gh extension install github/gh-project-ext
```

## Common Patterns

### Create Issue
[Content from current github-issues.md...]
```

**Files Affected:**
- Create: `skills/github-issues/SKILL.md`
- Modify: story agent, work command (use this skill)
- Deprecate (v5.0.0): `sdlc/commands/shared/github-issues.md`

---

### 7. memory-protocol

**Current Location:** `sdlc/commands/shared/memory-protocol.md`

**Current Size:** ~180 lines

**Purpose:** Memento MCP integration patterns for persistent memory

**Why Extract:**
- **MCP integration pattern** - Useful for any agent using Memento
- **Portable** - Memento works across agent frameworks
- **Valuable** - Memory persistence improves agent effectiveness
- **Pattern documentation** - When to search, when to store, what to store

**Extraction Complexity:** MEDIUM
- Depends on Memento MCP server (external)
- MCP tool naming conventions
- Integration with agent workflows
- Storage pattern decisions

**Portability Considerations:**
- **Portable:** Memory patterns, search strategies, storage decisions
- **Claude Code-specific:** MCP tool naming (mcp__memento__*) - note in docs
- **Prerequisites:** Memento MCP server configured

**Transformed SKILL.md Structure:**

```yaml
---
name: memory-protocol
description: Memento MCP integration patterns for persistent memory across sessions
version: 1.0.0
keywords: [memory, mcp, memento, persistence, knowledge-graph]
metadata:
  compatibility: ["claude-code", "cursor-with-mcp", "windsurf-with-mcp"]
  prerequisites:
    - description: "Memento MCP server (https://github.com/skydeckai/mcp-memento)"
      required: true
      check: "MCP tools available: semantic_search, create_entities, etc."
---

# Memory Protocol

## Purpose
Store and retrieve knowledge across sessions using Memento MCP for persistent memory.

## Prerequisites
- Memento MCP server configured
- MCP tools available: semantic_search, create_entities, open_nodes, create_relations

## When to Use Memory

### Store in Memento
- Domain modeling decisions (why types were chosen)
- Test patterns discovered (effective test structures)
- Project conventions (team-specific patterns)
- Lessons learned (what approaches work/fail)

### Do NOT Store
- Workflow state (use tasks metadata)
- Temporary context (use conversation)
- File contents (use Read tool)

[Content from current memory-protocol.md...]
```

**Files Affected:**
- Create: `skills/memory-protocol/SKILL.md`
- Modify: All agents that use Memento (~12 agents)
- Deprecate (v5.0.0): `sdlc/commands/shared/memory-protocol.md`

---

### 8. event-modeling

**Current Location:** `sdlc/commands/shared/event-modeling.md`

**Current Size:** ~300 lines

**Purpose:** Event Modeling patterns for workflow and UI design

**Why Extract:**
- **Standalone methodology** - Event Modeling is framework-agnostic
- **Valuable pattern** - Widely applicable design approach
- **Portable** - Works across agent frameworks
- **Rich content** - Diagram patterns, validation rules

**Extraction Complexity:** MEDIUM
- References multiple agents (workflow-designer, model-checker)
- Mermaid diagram syntax
- Validation rules
- Integration with UI design (atomic-design)

**Portability Considerations:**
- **Portable:** Event Modeling principles, diagram patterns, validation
- **Claude Code-specific:** References to workflow-designer, model-checker agents
- **Integration notes:** Works with any diagramming tool supporting Mermaid

**Transformed SKILL.md Structure:**

```yaml
---
name: event-modeling
description: Event Modeling patterns for designing workflows and UIs using events, commands, and views
version: 1.0.0
keywords: [event-modeling, event-storming, workflow-design, ui-design, mermaid]
metadata:
  compatibility: ["claude-code", "cursor", "windsurf", "cline"]
  prerequisites:
    - description: "Mermaid diagram support (for visualization)"
      required: false
---

# Event Modeling

## Purpose
Design workflows and UIs by modeling domain events, commands, and views in a visual timeline.

## Core Concepts

### Events (Orange)
Things that happened in the past (UserRegistered, OrderPlaced)

### Commands (Blue)
Actions users take (RegisterUser, PlaceOrder)

### Views (Green)
Information needed to make decisions (UserProfileView, OrderSummaryView)

[Content from current event-modeling.md...]

## Integration

### Claude Code
Use workflow-designer and model-checker agents for facilitated Event Modeling sessions.

### Other Agents
Generate Mermaid diagrams directly or use whiteboard tools.
```

**Files Affected:**
- Create: `skills/event-modeling/SKILL.md`
- Modify: workflow-designer, model-checker, design-facilitator agents
- Deprecate (v5.0.0): `sdlc/commands/shared/event-modeling.md`

---

### 9. orchestration-protocol

**Current Location:** `sdlc/commands/shared/orchestration.md`

**Current Size:** ~400 lines (LARGEST)

**Purpose:** Agent delegation rules, workflow coordination, file operation hierarchy

**Why Extract:**
- **Core coordination pattern** - Valuable for any multi-agent system
- **Delegation rules** - Prevents agents from doing each other's work
- **Workflow state management** - Critical for complex workflows
- **High value** - Enables effective agent collaboration

**Extraction Complexity:** HIGH
- References ALL other protocols
- Claude Code-specific patterns (agent invocation)
- Complex decision trees
- Integration with TDD workflow
- Git operation protocols

**Portability Considerations:**
- **Portable:** Delegation principles, workflow patterns, decision trees
- **Claude Code-specific:** Agent naming (sdlc:red, sdlc:green), Task tool usage
- **Integration notes:** Adapt agent names and invocation patterns for other frameworks
- **References:** tdd-constraints, git-spice, github-issues

**Transformed SKILL.md Structure:**

```yaml
---
name: orchestration-protocol
description: Agent delegation rules and workflow coordination patterns for multi-agent systems
version: 1.0.0
keywords: [orchestration, delegation, workflow, coordination, multi-agent]
metadata:
  compatibility: ["claude-code", "cursor", "windsurf-with-adaptation"]
  related_skills: [tdd-constraints, git-spice, github-issues]
  prerequisites:
    - description: "Understanding of TDD workflow (see tdd-constraints skill)"
      required: false
---

# Orchestration Protocol

## Purpose
Coordinate multiple specialized agents by defining clear delegation rules and workflow patterns.

## Core Principle
The orchestrator NEVER writes code directly. All file modifications go through specialized agents.

## Agent Selection Hierarchy

| File Type | Agent Role | Notes |
|-----------|------------|-------|
| Test files | Test specialist | All test code, assertions, fixtures |
| Implementation | Implementation specialist | Production code |
| Domain types | Domain modeler | Type definitions only |
| Config/docs | File updater | Everything else |

[Content from current orchestration.md...]

## Integration

### Claude Code
Use sdlc agents: red (tests), green (impl), domain (types), file-updater (misc)

### Other Frameworks
Adapt to available agents or create specialized agents following these patterns.

## Related Skills
- tdd-constraints: TDD workflow this orchestration supports
- git-spice: Git operation rules for stacked PRs
- github-issues: Issue management patterns
```

**Files Affected:**
- Create: `skills/orchestration-protocol/SKILL.md`
- Modify: All commands that invoke agents (work, review, design, etc.)
- Deprecate (v5.0.0): `sdlc/commands/shared/orchestration.md`

**Extraction Notes:**
- Extract LAST (references all other skills)
- Separate Claude Code-specific examples from general principles
- Provide adaptation guide for other frameworks
- Reference related skills clearly

---

### 10. skill-enforcement (OPTIONAL - MAY DEPRECATE)

**Current Location:** `sdlc/commands/shared/skill-enforcement.md`

**Current Size:** ~150 lines

**Purpose:** Invocation discipline and self-improvement patterns (1% rule)

**Why Extract (IF keeping):**
- **Meta-pattern** - Teaches when to invoke skills
- **Self-discipline** - Prevents skipping important steps
- **Broadly useful** - Any agent system benefits from invocation discipline

**Why DEPRECATE (Alternative):**
- **Task dependencies replace gates** - Mechanical enforcement vs prompt discipline
- **Less relevant in task-based world** - Tasks enforce structure, skills teach content
- **Overlaps with orchestration** - Delegation rules already cover invocation discipline

**Extraction Complexity:** MEDIUM
- Self-referential (skill about using skills)
- References invocation gates (being deprecated)
- May be obsolete in task-based workflow

**Decision:** DEPRECATE in v4.0.0, don't extract as standalone skill

**Rationale:**
- Task dependencies mechanically enforce workflow order (better than prompt-based gates)
- Orchestration-protocol skill covers delegation rules
- 1% rule ("when in doubt, invoke the skill") becomes "when in doubt, create a task for specialist agent"

**Alternative Approach:**
- Document invocation discipline in skills/README.md (meta-guidance)
- Include examples in orchestration-protocol skill
- Remove invocation gates from agents (replaced by task blockedBy)

---

## Extraction Summary Table

| Skill | Priority | Complexity | Size | Dependencies | Portability |
|-------|----------|------------|------|--------------|-------------|
| user-input-protocol | HIGH | LOW | Small | None | Universal |
| debugging-protocol | HIGH | LOW | Medium | None | Universal |
| atomic-design | HIGH | LOW | Small | None | Universal |
| tdd-constraints | HIGH | LOW | Medium | None | High |
| git-spice | MEDIUM | MEDIUM | Large | git-spice CLI | High |
| github-issues | MEDIUM | MEDIUM | Medium | gh CLI + ext | High |
| memory-protocol | MEDIUM | MEDIUM | Medium | Memento MCP | Medium |
| event-modeling | MEDIUM | MEDIUM | Large | Mermaid | High |
| orchestration-protocol | MEDIUM | HIGH | Large | All above | Medium |
| skill-enforcement | LOW | MEDIUM | Medium | Invocation gates | DEPRECATED |

**Extraction Order (Recommended):**
1. user-input-protocol (simplest, no dependencies)
2. debugging-protocol (simple, standalone)
3. atomic-design (simple, UI-specific)
4. tdd-constraints (core value, no dependencies)
5. git-spice (tool-specific, no protocol deps)
6. github-issues (tool-specific, no protocol deps)
7. memory-protocol (MCP integration, some complexity)
8. event-modeling (references agents, more complex)
9. orchestration-protocol (references all others, most complex)
10. skill-enforcement (deprecate, don't extract)

---

## Portability Matrix

### Highly Portable (Work Across All Agents)
- user-input-protocol
- debugging-protocol
- atomic-design
- tdd-constraints (with adaptation notes)

### Moderately Portable (Require Tool Prerequisites)
- git-spice (requires git-spice CLI)
- github-issues (requires gh CLI)
- memory-protocol (requires Memento MCP or equivalent)

### Framework-Specific (Need Adaptation)
- event-modeling (Mermaid support helpful)
- orchestration-protocol (agent naming, invocation patterns)

### Not Portable (Deprecating)
- skill-enforcement (replaced by task system)

---

## Extraction Validation Checklist

For each extracted skill, verify:

### Content Quality
- [ ] SKILL.md frontmatter valid YAML
- [ ] name field lowercase-with-hyphens
- [ ] description concise (< 100 chars)
- [ ] version follows semver
- [ ] keywords appropriate for discovery
- [ ] author information complete

### Portability
- [ ] No hardcoded sdlc plugin paths
- [ ] No broken internal links
- [ ] Claude Code-specific features clearly marked
- [ ] Portable principles separated from tool-specific
- [ ] Examples use generic paths
- [ ] Prerequisites documented

### Integration
- [ ] Related skills mentioned
- [ ] Integration notes for Claude Code
- [ ] Adaptation notes for other frameworks
- [ ] Tool dependencies listed
- [ ] Compatibility metadata accurate

### Testing
- [ ] Skill content renders correctly
- [ ] No broken cross-references
- [ ] Examples are complete
- [ ] Anti-patterns documented
- [ ] Usage scenarios clear

---

## Post-Extraction Agent Updates

### Agents Requiring Skill Reference Updates

| Agent | Current Skills | New Skill References | Notes |
|-------|---------------|---------------------|-------|
| red | sdlc:shared/user-input, memory, tdd-constraints | user-input-protocol, memory-protocol, tdd-constraints | Remove sdlc:shared/ prefix |
| domain | sdlc:shared/user-input, memory, tdd-constraints | user-input-protocol, memory-protocol, tdd-constraints | Remove sdlc:shared/ prefix |
| green | sdlc:shared/user-input, memory, tdd-constraints | user-input-protocol, memory-protocol, tdd-constraints | Remove sdlc:shared/ prefix |
| mutation | sdlc:shared/memory, user-input | memory-protocol, user-input-protocol | Remove sdlc:shared/ prefix |
| code-reviewer | sdlc:shared/memory, user-input | memory-protocol, user-input-protocol | Remove sdlc:shared/ prefix |
| workflow-designer | sdlc:shared/memory, event-modeling | memory-protocol, event-modeling | Remove sdlc:shared/ prefix |
| model-checker | sdlc:shared/event-modeling | event-modeling | Remove sdlc:shared/ prefix |
| design-facilitator | sdlc:shared/user-input, memory | user-input-protocol, memory-protocol | Remove sdlc:shared/ prefix |
| ux | sdlc:shared/memory, user-input | memory-protocol, user-input-protocol, atomic-design | Add atomic-design |
| architect | sdlc:shared/memory, user-input | memory-protocol, user-input-protocol | Remove sdlc:shared/ prefix |
| discovery | sdlc:shared/memory, user-input | memory-protocol, user-input-protocol | Remove sdlc:shared/ prefix |
| story | (none listed) | orchestration-protocol, github-issues | Add skills |
| gwt | (none listed) | tdd-constraints | Add TDD context |
| adr | (none listed) | (none) | No skills needed |
| file-updater | (none listed) | (none) | No skills needed |

### Commands Requiring Updates

| Command | References to Update | New Skills Referenced |
|---------|---------------------|---------------------|
| work.md | orchestration.md | orchestration-protocol, github-issues |
| review.md | orchestration.md, debugging.md | orchestration-protocol, debugging-protocol |
| design.md | event-modeling.md | event-modeling |
| pr.md | orchestration.md | orchestration-protocol |

---

## Skills Repository Structure

**Recommended structure after extraction:**

```
claude-code-plugins/
├── skills/
│   ├── README.md                           # Installation guide, skill index
│   ├── tdd-constraints/
│   │   └── SKILL.md                        # Core TDD workflow
│   ├── user-input-protocol/
│   │   └── SKILL.md                        # Checkpoint format
│   ├── debugging-protocol/
│   │   └── SKILL.md                        # Systematic debugging
│   ├── atomic-design/
│   │   └── SKILL.md                        # UI component patterns
│   ├── git-spice/
│   │   └── SKILL.md                        # Stacked PR workflow
│   ├── github-issues/
│   │   └── SKILL.md                        # GH CLI patterns
│   ├── memory-protocol/
│   │   └── SKILL.md                        # Memento integration
│   ├── event-modeling/
│   │   └── SKILL.md                        # Event Modeling patterns
│   ├── orchestration-protocol/
│   │   └── SKILL.md                        # Agent delegation
│   └── examples/
│       ├── tdd-cycle-example.md            # Example TDD cycle
│       ├── event-modeling-example.md       # Example Event Modeling session
│       └── github-workflow-example.md      # Example GH workflow
```

---

## Next Steps

1. **Start with simplest skills** (user-input-protocol, debugging-protocol)
2. **Test extraction process** with one skill end-to-end
3. **Validate npx skills installation** works correctly
4. **Extract remaining skills** in recommended order
5. **Update agent references** systematically
6. **Deprecate (don't delete) original shared protocols** for backward compat
7. **Test agent functionality** after skill reference updates
8. **Submit to skills.sh marketplace** when all skills extracted

**Readiness:** HIGH - Clear extraction candidates, low-risk transformation, well-defined process.
