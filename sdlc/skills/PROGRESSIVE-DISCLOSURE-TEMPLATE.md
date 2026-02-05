# Progressive Disclosure Template for Skills

**Purpose:** Reduce cognitive load by showing essential information first, detailed reference on-demand.

**Target:** Keep main SKILL.md under 150 lines, move detailed content to reference/ subdirectory.

---

## Structure

```markdown
---
# YAML frontmatter (unchanged)
---

# Skill Name

**Version:** X.X.X
**Portability:** [universal|tool-specific]

---

## Quick Start (30-50 lines)

Minimal viable usage - get started in <2 minutes.

### What This Does
One-sentence description of primary function.

### Fastest Path
3-5 step minimal invocation:
1. Check prerequisites
2. Run command
3. Verify output
4. Next action

### Basic Example
```bash
/sdlc:skill-name [common-args]
# Shows what happens
```

**Output:** What user sees after successful execution.

---

## Common Examples (40 lines)

3-5 real-world scenarios with context.

### Example 1: [Scenario Name]
**When:** Trigger condition
**Approach:** Step-by-step
**Result:** Expected outcome

### Example 2: [Scenario Name]
(repeat pattern)

---

## When to Use (20 lines)

Decision guidance - when this skill adds value.

**Use this skill when:**
- Condition 1
- Condition 2
- Condition 3

**Don't use when:**
- Alternative condition 1 (use /other-skill instead)
- Alternative condition 2

**Related skills:**
- `/skill-a` - For X
- `/skill-b` - For Y

---

## Reference

For detailed information:
- [Principles](./reference/principles.md) - Core concepts and rationale
- [Constraints](./reference/constraints.md) - Boundaries and rules
- [Examples](./reference/examples.md) - Comprehensive examples
- [Troubleshooting](./reference/troubleshooting.md) - Common issues

---

## Metadata

**Version History:** See [reference/changelog.md](./reference/changelog.md)
**Dependencies:** [Listed in frontmatter]
**Portability:** [From frontmatter]
```

---

## Reference Directory Structure

```
skills/skill-name/
├── SKILL.md                    # 100-150 lines (Quick Start + Examples + When to Use)
└── reference/
    ├── principles.md           # Core concepts (load on-demand)
    ├── constraints.md          # Boundaries and rules
    ├── examples.md             # Comprehensive examples
    ├── troubleshooting.md      # Common issues and solutions
    └── changelog.md            # Version history
```

---

## Content Migration Guide

### What Stays in SKILL.md

- Quick Start (minimal viable usage)
- 3-5 common examples with context
- When to Use decision guidance
- Links to reference/

### What Moves to reference/

- **principles.md:**
  - Detailed principle explanations
  - Rationale and trade-offs
  - Deep conceptual content

- **constraints.md:**
  - DO/DON'T lists
  - Boundary conditions
  - Integration rules

- **examples.md:**
  - Edge cases
  - Advanced scenarios
  - Complete walkthroughs

- **troubleshooting.md:**
  - Common errors
  - Debug steps
  - FAQ

---

## Skills to Restructure

Priority order (most commonly used first):

**High Priority:**
1. ✓ start - Router/entry point
2. ☐ work - Primary implementation entry
3. ☐ pr - Code review and PR creation
4. ☐ design - Event Modeling facilitation

**Medium Priority:**
5. ☐ plan - Task creation from event model
6. ☐ review - PR feedback handling
7. ☐ complete - Task completion

**Low Priority (Already Concise):**
8. ☐ setup - One-time configuration
9. ☐ arch - Architecture decisions (already restructured in v8.0.0)
10. ☐ remember - Memory storage
11. ☐ recall - Memory retrieval
12. ☐ domain-audit - On-demand domain review

---

## Example: Start Skill (Restructured)

See `skills/start/SKILL.md` for full implementation of this pattern.

Key changes:
- Quick Start reduced from 200+ lines to ~40 lines
- Core Principles moved to `reference/principles.md`
- Usage Patterns moved to `reference/examples.md`
- Detection logic moved to `reference/detection-algorithm.md`

Result:
- Onboarding time: 5 minutes → 1 minute
- Reference still available for deep understanding
- Progressive disclosure: learn as you need

---

## Verification Checklist

For each restructured skill:

- [ ] SKILL.md under 150 lines
- [ ] Quick Start section (30-50 lines)
- [ ] Common Examples section (3-5 examples, ~40 lines)
- [ ] When to Use section (~20 lines)
- [ ] Reference directory created
- [ ] Links to reference/ working
- [ ] YAML frontmatter preserved
- [ ] Version number incremented (minor bump)

---

## Impact Metrics

**Before:**
- Average skill length: 300-500 lines
- Time to first usage: 5-10 minutes
- Users read <20% of content

**After (Expected):**
- Average skill length: 120-150 lines
- Time to first usage: 1-2 minutes
- Users read 80%+ of main content, reference as needed
- Onboarding time reduced 50%
