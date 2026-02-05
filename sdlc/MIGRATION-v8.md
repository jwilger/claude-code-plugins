# Migration Guide: SDLC Plugin v7.x → v8.0.0

## Overview

Version 8.0.0 introduces a fundamental change to how Architecture Decision Records (ADRs) are managed:

**Before (v7.x):** ADRs stored as files in `docs/adr/`, separate from ARCHITECTURE.md
**After (v8.0.0):** ADRs stored in git commit messages, ARCHITECTURE.md is the living document

---

## Breaking Changes

### 1. File-Based ADRs Removed

**What changed:**
- No more `docs/adr/*.md` files
- No more `/sdlc:adr` command for creating ADR files
- No more `sdlc:adr` agent

**Why:**
- LLM coding harnesses should reference current architecture (ARCHITECTURE.md), not historical ADR files
- Decision context preserved in git history via commit messages
- Simpler workflow: one file to maintain (ARCHITECTURE.md)

**Impact:**
- Existing ADR files are archived to `docs/adr-archive/`
- Code/docs referencing ADR files need updating
- Workflows that create ADR files need changing

### 2. New Architecture Change Workflow

**What changed:**
- Use `/arch` or `/sdlc:arch` for architecture changes
- Edit ARCHITECTURE.md directly (not generated from ADRs)
- Commit message body contains ADR in MADR format
- Git hooks enforce architecture commit isolation

**Why:**
- Architecture as living document (not synthesized from parts)
- Decision rationale searchable via `git log --grep`
- Mechanical enforcement prevents mixed commits

**Impact:**
- Must re-run `/sdlc:setup` to install pre-commit hooks
- Architecture commits require ADR-formatted messages
- Architecture changes must be in separate commits/branches

### 3. Git Hooks Required

**What changed:**
- pre-commit framework required for hook management
- Three new hooks: architecture-isolation, adr-format, branch-consistency

**Why:**
- Mechanical enforcement of architecture isolation
- Prevents mixing architecture and implementation
- Validates ADR format in commit messages

**Impact:**
- Must install pre-commit framework (`pip install pre-commit`)
- Hooks installed via `/sdlc:setup`
- Can't bypass hooks without `--no-verify` (not recommended)

---

## Migration Steps

### Step 1: Archive Existing ADRs

Run the migration script:

```bash
./sdlc/scripts/migrate-to-v8.sh
```

This will:
- Move `docs/adr/*.md` files to `docs/adr-archive/`
- Preserve docs/adr/ directory (empty)
- Provide migration summary

**Manual alternative:**
```bash
mkdir -p docs/adr-archive
mv docs/adr/*.md docs/adr-archive/
```

### Step 2: Update References to ADR Files

Search for code/documentation referencing ADR files:

```bash
# Find references to ADR files
git grep -i "adr-" | grep -v "adr-archive"
git grep "docs/adr/"
```

Update to reference ARCHITECTURE.md instead:

```diff
- See ADR-0005 for rationale
+ See docs/ARCHITECTURE.md (Event Sourcing section)
```

### Step 3: Re-run Setup

Install pre-commit hooks:

```bash
/sdlc:setup
```

This will:
- Install pre-commit framework (if needed)
- Copy `.pre-commit-config.yaml` to project root
- Copy hook scripts to `sdlc/hooks/`
- Run `pre-commit install`
- Optionally install CI workflow

### Step 4: Verify ARCHITECTURE.md

Review your ARCHITECTURE.md:

```bash
cat docs/ARCHITECTURE.md
```

Ensure it:
- Reflects current architecture (not outdated)
- Is complete enough for implementation guidance
- Has clear sections for technology, patterns, integrations

If ARCHITECTURE.md doesn't exist or is outdated:
```bash
/sdlc:design arch
```

### Step 5: Test Architecture Change Workflow

Make a test architecture change:

```bash
git checkout -b arch/test-migration
/arch "test architecture change workflow"
```

This will:
- Guide you through ADR questions
- Edit ARCHITECTURE.md
- Create commit with ADR-formatted message
- Verify hooks are working

---

## Old vs New Workflow Comparison

### Creating an Architecture Decision

**Old (v7.x):**
```bash
/sdlc:adr decide "adopt event sourcing"
# Creates docs/adr/0001-adopt-event-sourcing.md
# Separately updates ARCHITECTURE.md
```

**New (v8.0.0):**
```bash
git checkout -b arch/adopt-event-sourcing
/arch "adopt event sourcing for core domain"
# Edits ARCHITECTURE.md
# Creates commit with ADR in message body
git push
```

### Finding Decision Context

**Old (v7.x):**
```bash
ls docs/adr/
cat docs/adr/0005-use-postgresql.md
```

**New (v8.0.0):**
```bash
git log --all --grep="postgresql" docs/ARCHITECTURE.md
git show <commit-sha>  # View full ADR in commit message
```

### Referencing Architecture

**Old (v7.x):**
```python
# See ADR-0005 for database choice rationale
db = connect_postgresql()
```

**New (v8.0.0):**
```python
# See docs/ARCHITECTURE.md for database architecture
db = connect_postgresql()
```

---

## Troubleshooting

### Hook Errors

#### "Architecture isolation violation"

**Problem:** Commit includes ARCHITECTURE.md + other files

**Solution:**
```bash
# Option 1: Unstage other files
git reset HEAD <file>...
git commit -m "feat(arch): <description>"

# Option 2: Unstage ARCHITECTURE.md
git reset HEAD docs/ARCHITECTURE.md
git commit -m "<regular commit message>"
# Then commit ARCHITECTURE.md separately
```

#### "Architecture commit format violation"

**Problem:** Commit message missing (arch) scope or ADR structure

**Solution:**
```bash
# Amend commit with correct format
git commit --amend

# Use /arch skill to guide format:
/arch "your architecture change"
```

#### "Branch consistency violation"

**Problem:** Branch has mixed architecture and implementation commits

**Solution:**
```bash
# Create separate branches
git checkout -b arch/my-decision main
git cherry-pick <architecture-commit-sha>

git checkout -b feat/my-feature main
git cherry-pick <implementation-commit-sha>
```

### CI Failures

#### "Architecture validation failed in CI"

**Problem:** CI workflow detected violations

**Solution:**
- Review CI output for specific violation
- Fix locally using hook troubleshooting steps above
- Force push corrected history: `git push --force-with-lease`

---

## FAQ

### Why remove ADR files?

**Short answer:** LLMs should reference current architecture, not historical ADR files.

**Long answer:**
- ARCHITECTURE.md is the single source of truth for current architecture
- ADRs preserve decision context for reconsideration (stored in git history)
- Separate files create duplication and maintenance burden
- Git history is a natural fit for historical context

### Where did my ADRs go?

Archived to `docs/adr-archive/`. They're preserved but not actively referenced.

To find decision context, search git history:
```bash
git log --all --grep="<search term>" docs/ARCHITECTURE.md
```

### Can I still bypass hooks?

Yes, with `git commit --no-verify`, but **not recommended**.

CI workflow (if installed) validates the same rules, so bypassing hooks locally will fail in CI.

### How do I update an old architecture decision?

```bash
# Find original decision
git log --all --grep="event sourcing" docs/ARCHITECTURE.md
git show <commit-sha>  # Read original rationale

# Create update branch
git checkout -b arch/update-event-sourcing
/arch "adopt hybrid event sourcing approach"

# In commit message, reference original:
# "This supersedes the decision in abc123..."
```

### Do I need pre-commit framework?

Yes. It's the industry-standard way to manage git hooks.

Install:
```bash
pip install pre-commit
# OR
brew install pre-commit  # macOS
# OR
See https://pre-commit.com/#install
```

### Can I use this without Claude Code?

Yes! The `/arch` skill works in Cursor, Windsurf, Cline, and other environments.

In non-Claude-Code environments, the skill provides direct instructions instead of launching a subagent.

### What if I have a large ARCHITECTURE.md?

Split it into sections using markdown headers:

```markdown
# Architecture

## Table of Contents
- [Technology Stack](#technology-stack)
- [Domain Model](#domain-model)
- [Integration Patterns](#integration-patterns)
- [Cross-Cutting Concerns](#cross-cutting-concerns)

## Technology Stack
...

## Domain Model
...
```

Link to specific sections in code:
```python
# See docs/ARCHITECTURE.md#integration-patterns
```

### How do I search for decisions?

```bash
# Search by keyword
git log --all --grep="<keyword>" docs/ARCHITECTURE.md

# Search by decision type
git log --all --grep="Context and Problem" docs/ARCHITECTURE.md

# Show full ADR from commit
git show <commit-sha>

# Search in commit messages
git log --all --grep="event sourcing" --oneline
```

---

## Rollback (Emergency)

If you need to rollback to v7.x:

```bash
# 1. Remove v8 hooks
rm .pre-commit-config.yaml
rm -rf sdlc/hooks/

# 2. Restore ADR files from archive
mv docs/adr-archive/* docs/adr/
rmdir docs/adr-archive

# 3. Downgrade plugin
/plugin uninstall sdlc
/plugin install sdlc@7.0.0@jwilger-claude-plugins

# 4. Re-run setup
/sdlc:setup
```

**Note:** This loses any architecture commits made in v8.0.0 format. You'll need to manually recreate them as ADR files.

---

## Support

**Issues:** https://github.com/jwilger/claude-code-plugins/issues
**Discussions:** https://github.com/jwilger/claude-code-plugins/discussions
**Email:** john@johnwilger.com

---

## Version History

**v8.0.0 (2026-02-05):**
- Commit-based ADR workflow
- Architecture isolation enforcement via git hooks
- `/arch` skill for architecture changes
- `sdlc:architect` agent for architecture editing
- Migration script and guide

**v7.0.0 (2026-02-04):**
- Last version with file-based ADRs
- `/sdlc:adr` command for ADR management
- `sdlc:adr` agent for ADR creation
