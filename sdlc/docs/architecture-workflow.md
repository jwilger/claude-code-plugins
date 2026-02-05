# Architecture Workflow Guide

**Version:** 8.0.0
**Plugin:** SDLC

---

## Overview

Version 8.0.0 introduces a commit-based architecture decision workflow. Architecture changes are made by:

1. Editing ARCHITECTURE.md to reflect the NEW architecture
2. Creating a commit with ADR-formatted message body (MADR template)
3. Keeping architecture commits isolated from implementation

**Key Principle:** ARCHITECTURE.md is the living document. Decision rationale is preserved in git commit messages, searchable via `git log`.

---

## Quick Reference

```bash
# Make an architecture change
git checkout -b arch/adopt-event-sourcing
/arch "adopt event sourcing for core domain"
# (Follow prompts, edit ARCHITECTURE.md, create commit)
git push

# Find decision context
git log --all --grep="event sourcing" docs/ARCHITECTURE.md
git show <commit-sha>  # View full ADR

# Create PR
/sdlc:pr  # Auto-detects architecture PR, adds label
```

---

## The `/arch` Skill

The `/arch` skill (also available as `/sdlc:arch` in Claude Code) guides you through architecture changes:

1. **Gather context**: Asks about problem, constraints, alternatives
2. **Explore options**: Presents tradeoffs for 2-4 alternatives
3. **Edit ARCHITECTURE.md**: Updates to reflect NEW architecture
4. **Create ADR commit**: Commit message body has full decision context
5. **Verify isolation**: Ensures only ARCHITECTURE.md changed

**Portability:** This skill works in Claude Code, Cursor, Windsurf, Cline, and other AI coding assistants.

---

## Architecture Change Workflow

### Step 1: Create Architecture Branch

```bash
git checkout -b arch/<decision-slug>
```

**Branch naming convention:**
- `arch/adopt-event-sourcing`
- `arch/switch-to-postgresql`
- `arch/introduce-cqrs`

### Step 2: Invoke `/arch` Skill

```bash
/arch "adopt event sourcing for core domain"
```

**In Claude Code:**
- Launches `sdlc:architect` agent
- Agent loads `arch` skill for guidance
- Interactive conversation about decision

**In other environments (Cursor, Windsurf, Cline):**
- Skill provides direct instructions
- Follow prompts for context gathering

### Step 3: Provide Context

The skill asks:

1. **Problem**: What are you solving?
2. **Constraints**: Team skills, budget, timeline?
3. **Alternatives**: What have you considered?
4. **Optimizing for**: Simplicity, capability, cost, speed?

**Example:**

```
Skill: What problem are you solving with event sourcing?

You: We need complete audit history for compliance and ability to
     rebuild state at any point in time for debugging.

Skill: What constraints exist?

You: Team is new to event sourcing. Budget for PostgreSQL event store.
     Timeline is 3 months for MVP.

Skill: What alternatives have you considered?

You: CRUD with audit tables, or hybrid (events for core, CRUD for periphery).

Skill: What are you optimizing for?

You: Audit capability and temporal queries, willing to accept some complexity.
```

### Step 4: Review Options and Tradeoffs

Skill presents alternatives with honest tradeoffs:

```markdown
### Option 1: Event Sourcing with Dedicated Event Store
**Benefits:**
- Complete audit history inherent to pattern
- Temporal queries via event replay
- Aligns with event modeling approach

**Tradeoffs:**
- Infrastructure complexity (event store, projections)
- Team learning curve
- Eventual consistency in read models

**Best for:** Compliance-heavy domains, temporal queries required

### Option 2: CRUD with Audit Tables
**Benefits:**
- Familiar to team
- Simpler infrastructure
- Immediate consistency

**Tradeoffs:**
- Audit logging is manual and error-prone
- Temporal queries require complex joins
- Audit tables grow indefinitely

**Best for:** Simple domains without temporal query needs

### Option 3: Hybrid Approach
...
```

### Step 5: Edit ARCHITECTURE.md

Once you decide, the skill edits ARCHITECTURE.md:

**Before:**
```markdown
## Data Persistence

We use MongoDB for all data storage.
```

**After:**
```markdown
## Data Persistence

### Event Store (Core Domain)
All core domain operations use event sourcing with PostgreSQL event store.

**Schema:**
- Table: `domain_events` (stream_id, version, event_type, data, metadata)
- Optimistic concurrency: `stream_id + version` unique constraint

**Aggregates:**
- User, Order, Inventory (see src/domain/ for implementations)

### Read Models (Projections)
Projections built from event streams:
- UserSummary: User lists and search
- OrderHistory: Order queries and reporting
- InventoryLevel: Stock availability

**Technology:** PostgreSQL with materialized views

### Peripheral Services
Non-core services use MongoDB:
- Logging and analytics
- Temporary session data

**Decision Context:** See commit abc123 for event sourcing rationale.
```

### Step 6: Create ADR-Formatted Commit

The skill creates a commit with ADR in the message body:

```bash
git add docs/ARCHITECTURE.md
git commit -m "feat(arch): adopt event sourcing for core domain" --message="
---
status: accepted
date: 2026-02-05
decision-makers: John Wilger, Tech Lead
---

# Adopt Event Sourcing for Core Domain

## Context and Problem Statement

Our core domain requires complete audit history for compliance (SOX, GDPR)
and the ability to rebuild state at any point in time for debugging and
incident analysis. Traditional CRUD doesn't provide this capability without
complex, error-prone audit logging.

## Decision Drivers

* Compliance requirement for complete, tamper-proof audit trail
* Need to rebuild state at any point in time (temporal queries)
* Complex business rules benefit from event-driven patterns
* Event modeling workshop identified clear event boundaries
* Team has 3 months to deliver MVP

## Considered Options

* Event sourcing with dedicated PostgreSQL event store
* Traditional CRUD with audit log tables
* Hybrid approach (events for core, CRUD for periphery)

## Decision Outcome

Chosen option: \"Event sourcing with dedicated event store\", because it
provides complete audit history naturally, supports temporal queries with
simple event replay, and aligns with our event modeling process.

The team accepted the infrastructure complexity and learning curve as
necessary tradeoffs for audit capability.

### Consequences

* Good, because complete audit history comes automatically from events
* Good, because temporal queries are straightforward (replay to point in time)
* Good, because aligns with event modeling workflow (events are first-class)
* Good, because business logic is explicit in command/event handlers
* Bad, because increased infrastructure complexity (event store, projections)
* Bad, because team learning curve for event sourcing patterns
* Bad, because eventual consistency in read models requires careful UX handling
* Neutral, because schema evolution requires event versioning strategy

## Pros and Cons of the Options

### Event sourcing with dedicated event store

* Good, because audit trail is inherent to the pattern
* Good, because temporal queries via event replay
* Good, because aligns with event modeling
* Good, because explicit business logic
* Bad, because infrastructure complexity
* Bad, because learning curve
* Bad, because eventual consistency

### Traditional CRUD with audit log tables

* Good, because familiar to team
* Good, because simpler infrastructure
* Good, because immediate consistency
* Bad, because audit logging is manual and error-prone
* Bad, because temporal queries require complex joins
* Bad, because audit tables grow indefinitely

### Hybrid approach

* Good, because complexity only where needed
* Good, because gradual adoption possible
* Bad, because two persistence patterns to maintain
* Bad, because boundaries between event/CRUD can shift over time

## More Information

- Event Modeling workshop notes: docs/event_model/core-domain.md
- PostgreSQL event store schema: migrations/001_event_store.sql
- Team training plan: docs/training/event-sourcing-onboarding.md

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
"
```

### Step 7: Verify and Push

```bash
# Verify only ARCHITECTURE.md changed
git show --stat
# Should show: docs/ARCHITECTURE.md | 45 +++++++++++++++++++++++++++

# Verify ADR format in commit
git show --format=fuller | grep "## Context and Problem Statement"

# Push branch
git push -u origin arch/adopt-event-sourcing
```

### Step 8: Create PR

```bash
/sdlc:pr
```

**What happens:**
- Detects architecture-only branch
- Creates PR with title/body from latest commit
- Adds `architecture` label
- Skips code review and mutation testing (not applicable)

**PR description automatically includes:**
- Full ADR from commit message
- Decision context
- Considered options
- Consequences

---

## Finding Decision Context

### Search by Keyword

```bash
# Find decisions about a specific topic
git log --all --grep="postgresql" docs/ARCHITECTURE.md
git log --all --grep="authentication" docs/ARCHITECTURE.md
git log --all --grep="event sourcing" docs/ARCHITECTURE.md
```

### View Full ADR

```bash
# Get commit SHA from search
git log --all --grep="event sourcing" docs/ARCHITECTURE.md --oneline

# View full ADR in commit message
git show abc123
```

### List All Architecture Decisions

```bash
# All commits that touch ARCHITECTURE.md
git log --all docs/ARCHITECTURE.md --oneline

# All commits with ADR format
git log --all --grep="## Context and Problem Statement" --oneline
```

---

## Updating Past Decisions

### Step 1: Find Original Decision

```bash
git log --all --grep="event sourcing" docs/ARCHITECTURE.md
git show abc123  # Read original rationale
```

### Step 2: Create Update Branch

```bash
git checkout -b arch/hybrid-event-sourcing
```

### Step 3: Make Change

```bash
/arch "adopt hybrid approach: event sourcing for core, CRUD for periphery"
```

### Step 4: Reference Original

In commit message, reference superseded decision:

```
This supersedes the decision in commit abc123 to use event sourcing
everywhere. Based on 6 months of production experience, we've identified
that peripheral services don't need event sourcing's audit capabilities,
and the operational complexity outweighs benefits for these areas.
```

---

## Git Hook Enforcement

Three hooks enforce architecture isolation:

### 1. Architecture Isolation (pre-commit)

**Rule:** ARCHITECTURE.md changes must be in separate commits from other files.

**Blocked:**
```bash
git add docs/ARCHITECTURE.md src/user.rs
git commit  # ❌ BLOCKED
```

**Allowed:**
```bash
git add docs/ARCHITECTURE.md
git commit  # ✅ OK

git add src/user.rs
git commit  # ✅ OK (separate commit)
```

### 2. ADR Format (commit-msg)

**Rule:** Architecture commits must have (arch) scope and ADR body.

**Blocked:**
```bash
git commit -m "update architecture"  # ❌ Missing (arch) scope, no ADR body
```

**Allowed:**
```bash
git commit -m "feat(arch): adopt event sourcing" --message="<ADR body>"  # ✅ OK
```

### 3. Branch Consistency (pre-push)

**Rule:** If branch has ANY architecture commits, ALL commits must be architecture-only.

**Blocked:**
```bash
# Branch with mixed commits
Commit 1: Changes ARCHITECTURE.md + src/user.rs
Commit 2: Changes ARCHITECTURE.md only
git push  # ❌ BLOCKED
```

**Allowed:**
```bash
# Architecture-only branch
Commit 1: Changes ARCHITECTURE.md only
Commit 2: Changes ARCHITECTURE.md only
git push  # ✅ OK
```

---

## Troubleshooting

### "Architecture isolation violation"

**Problem:** Trying to commit ARCHITECTURE.md with other files

**Solution:**
```bash
# Option 1: Unstage other files
git reset HEAD <other-files>
git commit -m "feat(arch): <description>"

# Option 2: Unstage ARCHITECTURE.md
git reset HEAD docs/ARCHITECTURE.md
git commit -m "<regular commit>"
# Then commit ARCHITECTURE.md separately
```

### "Architecture commit format violation"

**Problem:** Missing (arch) scope or ADR structure

**Solution:**
```bash
# Use /arch skill to generate correct format
/arch "your architecture change"

# OR manually fix commit message
git commit --amend
# Add proper format
```

### "Branch consistency violation"

**Problem:** Branch has mixed architecture + implementation commits

**Solution:**
```bash
# Create separate branches
git checkout -b arch/my-decision main
git cherry-pick <architecture-commit-sha>
git push

git checkout -b feat/my-feature main
git cherry-pick <implementation-commit-sha>
git push
```

### Bypassing Hooks (Not Recommended)

```bash
git commit --no-verify  # Skips pre-commit and commit-msg hooks
```

**Warning:** CI workflow (if installed) validates the same rules. Bypassing hooks locally will fail in CI.

---

## CI Workflow (Optional)

The optional GitHub Actions workflow validates:

1. **Architecture isolation**: Each commit touches only ARCHITECTURE.md
2. **ADR format**: Commit messages have required ADR structure
3. **Branch consistency**: No mixed architecture + implementation commits

**Installation:**

During `/sdlc:setup`, choose "Yes" when prompted about CI workflow.

**Manual installation:**

```bash
mkdir -p .github/workflows
cp sdlc/templates/workflows/architecture-validation.yml .github/workflows/
```

---

## Best Practices

### DO:

- **Edit ARCHITECTURE.md directly** - It's the living document
- **Use specific commit subjects** - "feat(arch): adopt event sourcing" not "update arch"
- **Include honest tradeoffs** - Every decision has costs
- **Reference ARCHITECTURE.md in code** - Not old ADR files
- **Search git history for WHY** - `git log --grep` is your friend
- **Create architecture branches** - `arch/<decision-slug>`
- **Update past decisions when needed** - Reference original commit SHA

### DON'T:

- **Don't create ADR files** - Obsolete pattern in v8.0.0+
- **Don't mix architecture and implementation** - Separate branches
- **Don't skip ADR structure** - Decision context is valuable
- **Don't bypass hooks without reason** - They prevent mistakes
- **Don't reference non-existent ADR files** - Use ARCHITECTURE.md
- **Don't append to ARCHITECTURE.md** - Update/replace outdated sections

---

## FAQ

**Q: Where did my ADR files go?**
A: Archived to `docs/adr-archive/`. Use `git log` to find decision context going forward.

**Q: Can I use this without Claude Code?**
A: Yes! The `/arch` skill works in Cursor, Windsurf, Cline, and other AI coding assistants.

**Q: Do I need the pre-commit framework?**
A: Yes. It's the standard way to manage git hooks. Install: `pip install pre-commit`

**Q: What if I have a huge ARCHITECTURE.md?**
A: Split into sections with markdown headers. Link to specific sections in code.

**Q: How do I search for old decisions?**
A: `git log --all --grep="<keyword>" docs/ARCHITECTURE.md`

**Q: Can I skip the hooks?**
A: Use `--no-verify`, but CI will still validate (if installed).

**Q: What's MADR?**
A: Markdown Architecture Decision Records - the template format we use. See https://adr.github.io/madr/

---

## References

- **MADR Template**: https://adr.github.io/madr/
- **Conventional Commits**: https://www.conventionalcommits.org/
- **Pre-Commit Framework**: https://pre-commit.com/
- **Migration Guide**: `sdlc/MIGRATION-v8.md`
- **Arch Skill**: `sdlc/skills/arch/SKILL.md`

---

**Version:** 8.0.0
**Last Updated:** 2026-02-05
**Plugin:** SDLC
