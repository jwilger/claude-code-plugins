---
name: arch
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Architecture change workflow with ADR-formatted commit messages
tags:
  - architecture
  - adr
  - decision-records
  - git-workflow
portability: universal
dependencies:
  - user-input-protocol
---

# Architecture Change Workflow (arch)

**Version:** 1.0.0
**Portability:** Universal

---

## Objective

Guides architecture changes through a disciplined workflow: gathering decision context through conversation, editing ARCHITECTURE.md to reflect new architecture, then committing with an ADR-formatted message that captures the decision rationale.

This skill serves dual purposes:
1. **As a command:** Invocable as `/arch` (any environment) or `/sdlc:arch` (Claude Code)
2. **As agent instructions:** Loaded by `sdlc:architect` agent for architecture review work

**Purpose:** Ensure architecture changes are well-documented, isolated from implementation work, and preserve decision rationale in git history.

**Scope:**
- **Included:** Decision gathering process, architecture editing workflow, ADR commit format, git isolation patterns, PR creation
- **Excluded:** Initial ARCHITECTURE.md creation (use design-facilitator), implementation details, testing

---

## Core Principles

### Principle 1: Architecture as Living Document

**The Principle:** ARCHITECTURE.md is the single source of truth for current architecture. It's edited directly, not generated from ADR files.

**Why this matters:** LLM coding harnesses should reference current state (ARCHITECTURE.md), not historical context (ADR files). Decision history is preserved in git commit messages, not in separate files.

**How to apply:**
- Edit ARCHITECTURE.md to reflect the NEW architecture state
- Capture the WHY (decision context) in the commit message body
- Use ADR format (MADR template) in commit message body
- Don't create separate ADR files

**Example:**
```
BEFORE (old ADR workflow):
1. Create docs/adr/0005-adopt-event-sourcing.md
2. Update ARCHITECTURE.md separately
3. Reference "see ADR-0005" in code/docs

AFTER (commit-based ADR workflow):
1. Edit ARCHITECTURE.md to reflect event sourcing architecture
2. Commit with ADR-formatted message body
3. Reference ARCHITECTURE.md exclusively in code/docs
4. Use `git log --grep="Context and Problem"` to find decision rationale
```

### Principle 2: Commit Isolation

**The Principle:** Architecture commits must only touch ARCHITECTURE.md. Implementation commits must not touch ARCHITECTURE.md.

**Why this matters:** Mixing architecture and implementation makes PRs hard to review, obscures the decision being made, and prevents clean architecture-only branches.

**How to apply:**
- Create separate branches for architecture vs implementation changes
- If you need to change architecture AND implement, use two branches
- Architecture PRs skip code review and mutation testing
- Implementation PRs reference the current ARCHITECTURE.md

**Example:**
```bash
# GOOD: Architecture-only branch
git checkout -b arch/adopt-event-sourcing
# Edit ARCHITECTURE.md only
git add docs/ARCHITECTURE.md
git commit -m "feat(arch): adopt event sourcing" --message="<ADR body>"
git push

# GOOD: Implementation branch (references ARCHITECTURE.md)
git checkout -b feat/implement-event-store
# Edit implementation files only (no ARCHITECTURE.md)
git add src/event_store.rs
git commit -m "feat: implement event store per ARCHITECTURE.md"
git push

# BAD: Mixed architecture + implementation
git checkout -b feat/event-sourcing
# Edit ARCHITECTURE.md + implementation files
git add docs/ARCHITECTURE.md src/event_store.rs
git commit  # ❌ BLOCKED by pre-commit hook
```

### Principle 3: ADR-Formatted Commit Messages

**The Principle:** Architecture commits use conventional commits with `(arch)` scope and MADR-formatted body.

**Why this matters:** Git history becomes a searchable decision log. Future maintainers can use `git log --grep` to find decision context without navigating separate ADR files.

**Commit Message Structure:**
```
<type>(arch): <short description>

---
status: accepted
date: YYYY-MM-DD
decision-makers: <names>
---

# <Title>

## Context and Problem Statement

<Why are we making this decision? What problem are we solving?>

## Decision Drivers

* <Factor 1>
* <Factor 2>
* <Factor 3>

## Considered Options

* <Option 1>
* <Option 2>
* <Option 3>

## Decision Outcome

Chosen option: "<option>", because <rationale>.

### Consequences

* Good, because <benefit>
* Good, because <benefit>
* Bad, because <tradeoff>
* Bad, because <tradeoff>

## Pros and Cons of the Options

### <Option 1>

* Good, because <benefit>
* Bad, because <drawback>

### <Option 2>

* Good, because <benefit>
* Bad, because <drawback>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Conventional Commit Types:**
- `feat(arch):` - New architectural pattern or component
- `fix(arch):` - Correction to existing architecture
- `refactor(arch):` - Restructuring without changing behavior
- `docs(arch):` - Clarification or documentation update

**How to apply:**
- Use MADR template from `~/Downloads/adr-template.md`
- Include all required sections (Context, Decision Drivers, Options, Outcome)
- Be specific about alternatives and tradeoffs
- Always include `status`, `date`, and `decision-makers` frontmatter

---

## Constraints and Boundaries

### DO:
- Edit ARCHITECTURE.md to reflect the NEW architecture state
- Use conventional commits with `(arch)` scope for architecture changes
- Include full ADR structure in commit message body
- Create architecture-only branches (single file: ARCHITECTURE.md)
- Push to separate PR for architecture review
- Search git history (`git log --grep="Context and Problem"`) to find decision context
- Reference ARCHITECTURE.md in all code and documentation

### DON'T:
- Create separate ADR files in `docs/adr/` (obsolete pattern)
- Mix architecture and implementation in same commit
- Mix architecture and implementation in same branch
- Skip ADR format in architecture commit messages
- Reference ADR files in code or documentation
- Use generic commit messages like "update architecture"
- Bypass pre-commit hooks with `--no-verify` (defeats purpose)

**Rationale:** These boundaries ensure architecture changes are isolated, well-documented, and searchable. Git history becomes the decision log.

---

## Usage Patterns

### Pattern 1: Making an Architecture Change

**Scenario:** You need to adopt a new architectural pattern, technology, or approach.

**Approach:**
1. Create architecture branch: `git checkout -b arch/<decision-slug>`
2. Invoke arch skill: `/arch "adopt event sourcing"` (or `/sdlc:arch` in Claude Code)
3. Skill launches architect agent (in Claude Code) or provides instructions (other environments)
4. Architect asks about context, alternatives, consequences
5. Edit ARCHITECTURE.md to reflect NEW architecture
6. Create commit with ADR-formatted message
7. Push branch: `git push -u origin arch/<decision-slug>`
8. Create PR: `/sdlc:pr` (in Claude Code) or `gh pr create` (manual)
9. PR is labeled `architecture` and skips code review/mutation testing

**Example:**
```bash
# Start architecture change
git checkout -b arch/adopt-event-sourcing
/arch "adopt event sourcing for core domain"

# Architect agent guides you through:
# - Context: Why event sourcing?
# - Alternatives: CRUD, hybrid approach
# - Consequences: Benefits and tradeoffs
# - Edits ARCHITECTURE.md
# - Creates commit with ADR body

# Push and create PR
git push -u origin arch/adopt-event-sourcing
/sdlc:pr  # Auto-detects architecture PR, adds label, uses commit message
```

### Pattern 2: Updating an Existing Architecture Decision

**Scenario:** You need to revise or supersede a previous architectural decision.

**Approach:**
1. Search for original decision: `git log --all --grep="<search term>" docs/ARCHITECTURE.md`
2. Review original context (commit message body)
3. Create new architecture branch
4. Invoke arch skill with context about what's changing
5. Edit ARCHITECTURE.md to reflect updated architecture
6. Commit message should reference superseded decision (commit SHA)
7. Push and create PR

**Example:**
```bash
# Find original decision
git log --all --grep="event sourcing" docs/ARCHITECTURE.md
# Shows commit abc123: "feat(arch): adopt event sourcing"

# Create update branch
git checkout -b arch/hybrid-event-sourcing
/arch "adopt hybrid approach: event sourcing for core, CRUD for periphery"

# In commit message, reference original:
# "This supersedes the decision in abc123 to use event sourcing everywhere..."

git push -u origin arch/hybrid-event-sourcing
/sdlc:pr
```

### Pattern 3: Searching for Decision Context

**Scenario:** You're implementing a feature and need to understand WHY an architectural decision was made.

**Approach:**
1. Read ARCHITECTURE.md to understand WHAT the current architecture is
2. If you need WHY context, search git history
3. Use `git log --all --grep="Context and Problem" docs/ARCHITECTURE.md`
4. Use `git show <commit-sha>` to read full ADR in commit message
5. If decision needs to change, use Pattern 2 (update)

**Example:**
```bash
# You're implementing authentication and see ARCHITECTURE.md mentions JWT
# You want to understand WHY JWT was chosen over sessions

# Search for authentication decisions
git log --all --grep="authentication" docs/ARCHITECTURE.md

# Shows commit def456: "feat(arch): adopt JWT authentication"
git show def456

# Commit message body contains full ADR with:
# - Context: Stateless auth for microservices
# - Alternatives: Sessions, OAuth
# - Decision: JWT with refresh tokens
# - Consequences: Revocation complexity, stateless benefits

# Now you understand the tradeoffs and can implement accordingly
```

---

## Workflow for Agents

**When used as agent instructions (loaded by sdlc:architect agent):**

### Step 1: Understand the Proposed Change

Ask questions to gather context before making changes:

**Required Questions:**
1. **What problem are you solving?** (current pain point)
2. **What constraints exist?** (team, tech, time, budget)
3. **What have you already considered?** (alternatives explored)
4. **What are you optimizing for?** (simplicity, capability, cost, speed)

**Use user-input-protocol if needed:** If working as subagent without direct user access:

```markdown
## 🚧 CHECKPOINT: Architecture Decision Context Needed

I need to understand the context before proceeding with architecture changes.

### Questions:
1. **Problem**: What specific problem are you solving?
2. **Constraints**: What constraints exist (team skills, budget, timeline)?
3. **Alternatives**: What alternatives have you considered?
4. **Optimizing for**: Simplicity? Capability? Cost? Speed?

### When you're ready:
- Answer the questions above
- I'll proceed with architecture review and editing
```

### Step 2: Explore Alternatives and Tradeoffs

Present 2-4 realistic options with their implications:

```markdown
Based on your context, here are the options:

### Option 1: <Name>
**Description:** <brief explanation>

**Benefits:**
- <benefit 1>
- <benefit 2>

**Tradeoffs:**
- <cost 1>
- <cost 2>

**Best for:** <scenarios where this excels>

### Option 2: <Name>
[same structure]

**My recommendation:** <option>, because <rationale based on constraints>

What resonates with your priorities?
```

### Step 3: Edit ARCHITECTURE.md

1. **Read current ARCHITECTURE.md:** Understand existing structure
2. **Identify affected sections:** What needs updating?
3. **Update content:** Replace outdated sections, add new ones
4. **Ensure consistency:** Check cross-references, terminology
5. **Verify completeness:** Does it answer "how do we..." questions?

**Important:** Update (replace) outdated sections rather than appending. ARCHITECTURE.md shows current state, not historical progression.

### Step 4: Create ADR-Formatted Commit

```bash
git add docs/ARCHITECTURE.md
git commit -m "feat(arch): <short description>" --message="<ADR body>"
```

See "Principle 3: ADR-Formatted Commit Messages" above for complete format.

### Step 5: Verify and Push

```bash
git show --stat  # Should show ONLY docs/ARCHITECTURE.md
git push -u origin arch/<decision-slug>
```

---

## Integration with Other Skills

**Works well with:**
- **user-input-protocol:** Used to gather decision context when needed
- **git-spice:** Can be used for stacked architecture changes
- **github-issues:** Link architecture PRs to issues/projects
- **memory-protocol:** Store architecture patterns for reuse

**Prerequisites:**
- Git repository with commit hooks installed
- ARCHITECTURE.md exists (create with `/sdlc:design arch` if needed)
- pre-commit framework installed (for hook enforcement)

---

## Common Pitfalls

### Pitfall 1: Mixing Architecture and Implementation

**Problem:** Developer changes ARCHITECTURE.md and implementation code in same commit/branch

**Solution:**
- Pre-commit hooks will BLOCK this
- If blocked, split into two branches:
  1. Architecture branch (ARCHITECTURE.md only)
  2. Implementation branch (code only, references ARCHITECTURE.md)

### Pitfall 2: Generic Commit Messages

**Problem:** Commit message says "update architecture" without ADR body

**Solution:**
- commit-msg hook will BLOCK this
- Use full ADR format with Context, Decision Drivers, Options, Outcome
- Include `---` frontmatter with status, date, decision-makers

### Pitfall 3: Referencing ADR Files

**Problem:** Code comments say "see ADR-0005" or documentation references `docs/adr/`

**Solution:**
- Always reference ARCHITECTURE.md, not ADR files
- If you need decision context, search git history: `git log --grep="<term>" docs/ARCHITECTURE.md`
- Update code comments to reference ARCHITECTURE.md

### Pitfall 4: Bypassing Hooks with --no-verify

**Problem:** Developer uses `git commit --no-verify` to skip pre-commit hooks

**Solution:**
- CI workflow validates the same rules (backup enforcement)
- If commit is blocked, understand WHY before bypassing
- Hooks exist to prevent mixing architecture and implementation
- If you genuinely need to bypass, you're likely doing something wrong

---

## Examples

### Example 1: Adopting Event Sourcing

**Context:** Team needs full audit history and temporal queries for core domain

**Application:**
```bash
# Create architecture branch
git checkout -b arch/adopt-event-sourcing

# Invoke arch skill
/arch "adopt event sourcing for core domain"

# Architect asks:
# - Why event sourcing? (audit history, temporal queries)
# - What are alternatives? (CRUD with audit tables, hybrid)
# - What are tradeoffs? (complexity vs benefits)

# Edits ARCHITECTURE.md:
# - Adds "Event Sourcing" section
# - Describes event store pattern
# - Documents aggregate boundaries
# - Lists domain events

# Creates commit:
git add docs/ARCHITECTURE.md
git commit -m "feat(arch): adopt event sourcing for core domain" --message="
---
status: accepted
date: 2026-02-05
decision-makers: John Wilger, Team Lead
---

# Adopt Event Sourcing for Core Domain

## Context and Problem Statement

Our core domain requires complete audit history and the ability to rebuild
state from past events. Traditional CRUD doesn't provide this capability
without complex audit logging.

## Decision Drivers

* Need complete audit trail of all domain changes
* Requirements for temporal queries (state at point in time)
* Complex business rules that benefit from event-driven design

## Considered Options

* Event Sourcing with dedicated event store
* Traditional CRUD with audit log tables
* Hybrid approach (events for core, CRUD for periphery)

## Decision Outcome

Chosen option: \"Event Sourcing with dedicated event store\", because it
provides complete audit history, supports temporal queries naturally, and
aligns with our event modeling approach.

### Consequences

* Good, because complete audit history comes for free
* Good, because temporal queries are straightforward
* Good, because aligns with event modeling workflow
* Bad, because increased infrastructure complexity
* Bad, because team learning curve for event sourcing patterns

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
"

# Push and create PR
git push -u origin arch/adopt-event-sourcing
/sdlc:pr  # Auto-labels as "architecture", uses commit message for PR title/body
```

**Outcome:** Architecture is updated, decision context is preserved in git history, team can reference ARCHITECTURE.md for implementation.

### Example 2: Searching for Past Decisions

**Context:** Developer needs to understand why microservices were chosen

**Application:**
```bash
# Search for microservices decision
git log --all --grep="microservices" docs/ARCHITECTURE.md

# Output shows:
# commit a1b2c3d
# feat(arch): adopt microservices architecture
# Date: 2025-11-15

# View full decision context
git show a1b2c3d

# Commit message contains:
# ## Context and Problem Statement
# Monolith scaling issues, team autonomy needs...
#
# ## Considered Options
# - Monolith with modules
# - Microservices
# - Modular monolith
#
# ## Decision Outcome
# Chosen: Microservices because...
#
# ### Consequences
# - Good: Independent scaling
# - Bad: Distributed system complexity

# Now developer understands the tradeoffs and can work within those constraints
```

**Outcome:** Decision context found in 10 seconds without navigating file hierarchies or outdated ADR files.

---

## Verification Checklist

Use this checklist to verify you're applying this skill correctly:

- [ ] ARCHITECTURE.md edited to reflect NEW architecture (not original state)
- [ ] Commit only touches ARCHITECTURE.md (no other files)
- [ ] Commit uses conventional commits format with `(arch)` scope
- [ ] Commit message body includes ADR frontmatter (status, date, decision-makers)
- [ ] Commit message body includes "Context and Problem Statement" section
- [ ] Commit message body includes "Considered Options" section
- [ ] Commit message body includes "Decision Outcome" with rationale
- [ ] Commit message body includes "Consequences" (good/bad)
- [ ] Branch name reflects decision: `arch/<decision-slug>`
- [ ] Pre-commit hooks passed (architecture isolation validated)
- [ ] PR created with `architecture` label (if using Claude Code with `/sdlc:pr`)
- [ ] No code references ADR files (only ARCHITECTURE.md)

---

## References

**Source Documentation:**
- Original pattern: sdlc plugin v7.0.0 ADR agent
- MADR template: https://adr.github.io/madr/
- Conventional commits: https://www.conventionalcommits.org/

**Related Skills:**
- architect - Architecture editing and review guidance
- user-input-protocol - Checkpoint format for gathering decision context
- git-spice - Stacked PRs for incremental architecture changes

**External Resources:**
- Architecture Decision Records (ADR): https://adr.github.io/
- MADR (Markdown ADR): https://adr.github.io/madr/
- pre-commit framework: https://pre-commit.com/

---

## Version History

### v1.0.0 (2026-02-05)
- Initial extraction from sdlc plugin v8.0.0
- Commit-based ADR workflow (replaces file-based ADRs)
- Architecture isolation patterns
- ADR-formatted commit message guidance
- Git history as decision log

---

## Metadata

**Extraction Source:** sdlc plugin v8.0.0 architecture transformation
**Extraction Date:** 2026-02-05
**Last Updated:** 2026-02-05
**Compatibility:** Claude Code, Cursor, Windsurf, Cline
**License:** MIT
