# Skill Extraction Guide

**Phase:** 4 (Skill Extraction)
**Timeline:** 5-7 days (0.5-1 day per skill)
**Order:** Simplest → Most Complex

---

## Extraction Order

Based on complexity analysis from skill-extraction-plan.md:

1. **user-input-protocol** (Simplest - 1-2 hours)
2. **debugging-protocol** (Simple - 2-3 hours)
3. **atomic-design** (Simple - 2-3 hours)
4. **tdd-constraints** (Core - 4-6 hours)
5. **git-spice** (Medium - 3-4 hours)
6. **github-issues** (Medium - 3-4 hours)
7. **memory-protocol** (Medium - 3-4 hours)
8. **event-modeling** (Complex - 5-6 hours)
9. **orchestration-protocol** (Most Complex - 6-8 hours)

---

## Extraction Process (Per Skill)

### Step 1: Locate Source Material

```bash
# Find the current protocol in sdlc plugin
ls sdlc/commands/shared/

# Example: Find tdd-constraints references
grep -r "tdd-constraints" sdlc/
```

**Source locations:**
- `sdlc/commands/shared/*.md` - Protocol definitions
- `sdlc/agents/*.md` - Usage examples in agents

### Step 2: Create Skill Directory

```bash
# Create skill directory
mkdir -p skills/skill-name

# Copy template
cp skills/.templates/SKILL.md skills/skill-name/SKILL.md
```

### Step 3: Extract Content

**Read source protocol:**
```bash
# View current protocol
cat sdlc/commands/shared/protocol-name.md
```

**Transform for portability:**
1. Remove sdlc-specific references
2. Remove Claude Code-specific tool calls
3. Generalize examples for any agent framework
4. Focus on principles ("what and why") not implementation ("how")
5. Add verification checklist

**Template mapping:**
| Source Section | Template Section |
|----------------|------------------|
| Protocol objective | Objective |
| Rules/constraints | Core Principles + Constraints |
| Examples | Usage Patterns + Examples |
| Integration notes | Integration with Other Skills |
| Common mistakes | Common Pitfalls |

### Step 4: Fill Frontmatter

```yaml
---
name: skill-name                          # Lowercase-with-hyphens
version: 1.0.0                            # Initial version
author: jwilger                            # Your name
repository: jwilger/claude-code-plugins   # This repo
description: One-line description         # Clear and concise
tags:
  - relevant-tag-1                        # For discoverability
  - relevant-tag-2
portability: universal | high | medium | tool-specific | mcp-specific
dependencies: []                          # Other skills needed
---
```

**Portability assessment:**
- **Universal:** No tool dependencies, pure principles
- **High:** Framework-agnostic, minimal adaptation (e.g., file-based patterns)
- **Medium:** Requires some context-specific setup
- **Tool-Specific:** Requires specific CLI tool (git-spice, gh)

### Step 5: Write Core Content

**Focus on teaching, not dictating:**

❌ **Bad (Implementation-focused):**
```markdown
## Process
1. Run `cargo test`
2. If it passes, STOP
3. If it fails, proceed to step 4
```

✅ **Good (Principle-focused):**
```markdown
## Core Principle: Test-First Development

**Principle:** Write the test before the implementation.

**Why this matters:** Tests written after code often test what the code does, not what it should do. Writing tests first ensures you're testing requirements, not implementation.

**How to apply:**
- Define expected behavior first
- Write a test that verifies that behavior
- See the test fail (confirms test is valid)
- Then write minimal code to make it pass

**Example (Language-agnostic):**
```
# Test (written first)
assert user_can_authenticate_with_email_and_password()

# Implementation (written second)
def authenticate(email, password):
    # Minimal code to make test pass
```
```

### Step 6: Add Examples

**Multiple contexts:**
- Different programming languages (Rust, TypeScript, Python)
- Different frameworks (web, CLI, mobile)
- Different scales (single function, module, system)

**Real-world scenarios:**
```markdown
### Example 1: Web Authentication

**Context:** Adding login to a web application

**Application:**
[Show how skill applies in this specific context]

**Outcome:** [What was achieved]
```

### Step 7: Document Integration

**With other skills:**
```markdown
## Integration with Other Skills

**Works well with:**
- **debugging-protocol:** When tests fail, use systematic debugging
- **user-input-protocol:** Pause at checkpoints to ask user questions

**Prerequisites:**
- Basic understanding of test frameworks
- Access to test runner in your environment
```

### Step 8: Test Portability

**Verification questions:**
1. Can this be understood without Claude Code context? ✓/✗
2. Can this be applied in Cursor/Windsurf/Cline? ✓/✗
3. Are examples framework-agnostic? ✓/✗
4. Are principles clear without implementation? ✓/✗
5. Is portability level accurate? ✓/✗

**If any ✗, revise before continuing.**

### Step 9: Create README (Optional but Recommended)

```bash
# Create user-facing README
cat > skills/skill-name/README.md << 'EOF'
# Skill Name

[Quick start guide for users]

## Installation
[How to use this skill]

## Quick Reference
[Key principles summary]

## Examples
[Links to example files]
EOF
```

### Step 10: Validate Against Template

```bash
# Check frontmatter validity
head -20 skills/skill-name/SKILL.md | grep "^---"

# Check required sections exist
grep "^## " skills/skill-name/SKILL.md
```

**Required sections:**
- [ ] Objective
- [ ] Core Principles
- [ ] Constraints and Boundaries
- [ ] Usage Patterns
- [ ] Integration with Other Skills
- [ ] Common Pitfalls
- [ ] Examples
- [ ] Verification Checklist

---

## Extraction Checklist (Per Skill)

**Before extraction:**
- [ ] Read source protocol completely
- [ ] Identify portability level
- [ ] Note dependencies on other skills
- [ ] Understand current usage in agents

**During extraction:**
- [ ] Create skill directory
- [ ] Copy and fill template
- [ ] Complete frontmatter with accurate metadata
- [ ] Write objective (clear purpose)
- [ ] Extract and generalize principles
- [ ] Document constraints with rationale
- [ ] Create usage patterns
- [ ] Add concrete examples (multiple contexts)
- [ ] Document integration with other skills
- [ ] List common pitfalls
- [ ] Create verification checklist

**After extraction:**
- [ ] Test portability (can non-Claude Code users understand it?)
- [ ] Verify all template sections complete
- [ ] Check for sdlc/Claude Code-specific references
- [ ] Ensure examples are framework-agnostic
- [ ] Validate frontmatter YAML
- [ ] Create README if complex skill
- [ ] Test skill by loading in test agent
- [ ] Document in skills/README.md

---

## Common Extraction Pitfalls

### Pitfall 1: Too Implementation-Specific

**Problem:** Skill tells you HOW to do something in specific tool
**Solution:** Focus on WHAT and WHY, let agent choose HOW

**Example:**
❌ "Run `cargo test --test auth_test`"
✅ "Verify test fails before writing implementation (confirms test validity)"

### Pitfall 2: sdlc-Specific Context

**Problem:** References to sdlc plugin internals (orchestrator, gates, etc.)
**Solution:** Generalize to any agent workflow

**Example:**
❌ "Wait for orchestrator to provide RED_CONTEXT"
✅ "Ensure you have clear acceptance criteria before writing tests"

### Pitfall 3: Missing "Why"

**Problem:** States rules without explaining rationale
**Solution:** Every constraint should have "Why this matters"

**Example:**
❌ "One assertion per test"
✅ "One assertion per test - Makes test failures immediately obvious. Multiple assertions hide which expectation failed."

### Pitfall 4: Tool-Locked Examples

**Problem:** All examples use same language/framework
**Solution:** Show variety - Rust, TypeScript, Python, etc.

### Pitfall 5: Inaccurate Portability

**Problem:** Claims "Universal" but requires specific tools or setup
**Solution:** Honestly assess portability level

**Example:**
❌ memory-protocol marked "Universal" (requires auto memory directory setup)
✅ memory-protocol marked "High" (file-based, minimal setup)

---

## Testing Extracted Skills

### Manual Test

```yaml
# Create test agent
---
name: skill-test
description: Tests extracted skill
skills:
  - skill-name  # Skill being tested
tools:
  - Read
---

# Skill Test Agent

You are testing the [skill-name] skill.

## Verification

Can you:
1. Explain the core principle in your own words?
2. Apply it to a novel scenario (not in examples)?
3. Identify when NOT to use this skill?

If yes to all three, skill is well-extracted.
```

### Portability Test

Load skill in different contexts:
1. **Claude Code:** Load in test agent
2. **Cursor:** Check skill loads without errors
3. **Raw markdown:** Read as human - is it clear?

### Integration Test

```yaml
# Test with dependencies
skills:
  - skill-name
  - dependency-1
  - dependency-2
```

Verify:
- [ ] No conflicts between skills
- [ ] Dependencies enhance main skill
- [ ] Cross-references make sense

---

## Extraction Metrics

Track these per skill:

| Metric | Target | Actual |
|--------|--------|--------|
| Time to extract | 0.5-1 day | ___ |
| Portability level | Accurate | ___ |
| Template completeness | 100% | ___ |
| Example variety | 3+ contexts | ___ |
| Dependencies documented | All | ___ |
| Principle/implementation ratio | 80/20 | ___ |

**Principle/implementation ratio:** 80% teaching principles, 20% showing examples

---

## After All Extractions

### Update Marketplace

```json
// .claude-plugin/marketplace.json
{
  "name": "jwilger-claude-plugins",
  "plugins": [...],
  "skills": [
    {
      "name": "tdd-constraints",
      "path": "skills/tdd-constraints",
      "version": "1.0.0",
      "description": "..."
    },
    // ... all 10 skills
  ]
}
```

### Update sdlc Agents

```yaml
# Before
skills:
  - sdlc:shared/tdd-constraints

# After
skills:
  - tdd-constraints
```

### Test Installation

```bash
# Test npx skills installation
npx skills add jwilger/claude-code-plugins
npx skills list
# Should show all 10 skills
```

---

## Timeline Management

**Per-skill time estimates:**
- Simple (user-input, debugging, atomic-design): 2-3 hours
- Core (tdd-constraints): 4-6 hours
- Medium (git-spice, github-issues, memory-protocol): 3-4 hours
- Complex (event-modeling): 5-6 hours
- Most complex (orchestration-protocol): 6-8 hours

**Total:** ~34-44 hours (5-6 days at 7 hours/day)

**Daily target:** 1-2 skills extracted

**Recommended pace:**
- Day 1: user-input, debugging (4-6 hours)
- Day 2: atomic-design, tdd-constraints (6-9 hours)
- Day 3: git-spice, github-issues (6-8 hours)
- Day 4: memory-protocol, event-modeling (8-10 hours)
- Day 5: orchestration-protocol (6-8 hours)
- Day 6: Testing, documentation, polish (variable)

---

## Success Criteria

Phase 4 complete when:
- [ ] All 9 skills extracted to skills/ directory
- [ ] Each skill follows template structure
- [ ] Frontmatter valid and complete
- [ ] Portability levels accurate
- [ ] Examples span multiple contexts
- [ ] Integration documented
- [ ] skills/README.md updated
- [ ] Installation tested (npx skills)
- [ ] At least 1 skill tested in external framework (Cursor/Windsurf)

---

**Ready to begin extraction:** Start with user-input-protocol (simplest)
