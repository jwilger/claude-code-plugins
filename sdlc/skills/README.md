# Portable Agent Skills

**Repository:** jwilger/claude-code-plugins
**Type:** skills.sh-compatible agent skills
**Source:** Extracted from sdlc plugin v3.12.8

---

## Overview

This directory contains portable agent skills that document best practices, protocols, and patterns for software development workflows. These skills work across Claude Code, Cursor, Windsurf, Cline, and other agent frameworks that support the skills.sh format.

**Skill Philosophy:** Skills teach principles (the "what and why"), not implementation (the "how"). They're documentation-only - no executable code.

---

## Installation

**These skills are bundled with the sdlc plugin.** When you install the sdlc plugin, the skills are automatically available.

### For sdlc Plugin Users

No action needed! Skills auto-load when agents reference them:

```bash
# Install the sdlc plugin
/plugin install sdlc@jwilger-claude-plugins

# Skills are automatically available to all sdlc agents
```

### For Custom Agent Authors

If you're writing your own agents and want to use these skills, install the sdlc plugin and reference skills by name:

```yaml
# In your agent definition
skills:
  - user-input-protocol
  - tdd-constraints
```

The skills will be available as long as the sdlc plugin is installed.

---

## Available Skills

### High Priority (Universal Portability)

| Skill | Description | Portability | Version |
|-------|-------------|-------------|---------|
| **tdd-constraints** | Red/green/domain phase boundaries and TDD workflow discipline | Universal | 1.0.0 |
| **user-input-protocol** | Checkpoint format for pausing work and asking questions | Universal | 1.0.0 |
| **debugging-protocol** | Systematic debugging methodology with verification steps | Universal | 1.0.0 |
| **atomic-design** | UI component hierarchy and composition patterns | Universal | 1.0.0 |

### Medium Priority (Tool-Specific)

| Skill | Description | Portability | Version |
|-------|-------------|-------------|---------|
| **github-issues** | GitHub CLI patterns for issue/PR management | Tool-specific | 1.0.0 |
| **memory-protocol** | Memento MCP integration for semantic memory | MCP-specific | 1.0.0 |
| **event-modeling** | Event Modeling facilitation and diagram generation | High | 1.0.0 |
| **orchestration-protocol** | Agent delegation and coordination rules | Medium | 1.0.0 |

---

## Skill Structure

Each skill follows this directory structure:

```
skills/
├── skill-name/
│   ├── SKILL.md          # Main skill content (YAML frontmatter + markdown)
│   ├── README.md         # User-facing documentation
│   ├── examples/         # Optional: Example applications
│   │   └── example-1.md
│   └── tests/            # Optional: Verification scenarios
│       └── test-1.md
└── .templates/
    └── SKILL.md          # Template for creating new skills
```

---

## Using Skills in Agents

### Claude Code Plugin

```yaml
---
name: my-agent
description: Does something cool
skills:
  - tdd-constraints        # Reference by name
  - user-input-protocol
  - debugging-protocol
tools:
  - Read
  - Write
---

# My Agent

You are [description].

## Shared Protocols

Follow protocols from loaded skills:
- **tdd-constraints**: Red/green/domain phase boundaries
- **user-input-protocol**: Checkpoint format for pausing work
- **debugging-protocol**: Systematic debugging methodology

[Rest of agent prompt...]
```

### Cursor / Windsurf / Cline

Skills are injected into agent context automatically when referenced. Check your framework's documentation for skill loading syntax.

---

## Skill Naming Conventions

**Format:** `lowercase-with-hyphens`

**Examples:**
- ✅ `tdd-constraints`
- ✅ `user-input-protocol`
- ✅ `debugging-protocol`
- ❌ `TDD-Constraints` (uppercase)
- ❌ `tdd_constraints` (underscores)
- ❌ `jwilger-tdd-constraints` (namespaced - unnecessary)

**Rationale:** Generic names for better discoverability. Repository provides namespace.

---

## Portability Levels

| Level | Description | Example Use Cases |
|-------|-------------|-------------------|
| **Universal** | Works anywhere, no tool dependencies | TDD principles, design patterns |
| **High** | Minor adaptation needed | Event Modeling (framework-agnostic) |
| **Medium** | Significant context required | Orchestration patterns (agent-specific) |
| **Tool-Specific** | Requires specific tool | GitHub CLI |
| **MCP-Specific** | Requires MCP server | Memento integration |

---

## Creating New Skills

### Extraction Process

1. **Identify candidate:** Find reusable protocol in sdlc plugin
2. **Copy template:** `cp .templates/SKILL.md skill-name/SKILL.md`
3. **Fill in frontmatter:** Update name, description, tags, portability
4. **Extract principles:** Document the "what and why"
5. **Add examples:** Show practical applications
6. **Test portability:** Verify in different agent frameworks
7. **Document integration:** How it works with other skills

### Quality Checklist

- [ ] YAML frontmatter complete and valid
- [ ] Objective clearly states purpose
- [ ] Principles explain "why" not just "what"
- [ ] Constraints include rationale
- [ ] Examples are concrete and realistic
- [ ] Portability level accurate
- [ ] No framework-specific implementation details
- [ ] Version history documented

---

## Skill Dependencies

Some skills reference others:

```yaml
---
name: tdd-constraints
dependencies:
  - user-input-protocol  # Uses checkpoint format
  - debugging-protocol   # Uses debugging when tests fail
---
```

Skills are loaded recursively - dependencies are automatically included.

---

## Integration with sdlc Plugin

The sdlc plugin uses these skills extensively:

**Agents using tdd-constraints:**
- red, green, domain agents

**Agents using user-input-protocol:**
- All agents (checkpoint format is universal)

**Agents using memory-protocol:**
- All agents with Memento MCP access

**Agents using orchestration-protocol:**
- Main conversation (orchestrator logic)

---

## Contributing

### Improving Existing Skills

1. Test skill in different contexts
2. Identify gaps or unclear guidance
3. Submit issue or PR with improvements
4. Increment version number (semver)

### Adding New Skills

1. Verify skill is reusable across contexts
2. Follow template structure
3. Document portability honestly
4. Add examples and verification checklist
5. Submit PR with clear rationale

---

## Skills.sh Marketplace

These skills are published on the skills.sh marketplace:

**Listing:** https://skills.sh/skills/jwilger/claude-code-plugins

**Installation:** `npx skills add jwilger/claude-code-plugins`

**Telemetry:** Usage metrics help prioritize improvements

---

## Version Management

**Skills versioning:** Independent of plugin versioning

**Format:** Semantic versioning (MAJOR.MINOR.PATCH)
- MAJOR: Breaking changes to principles or structure
- MINOR: New principles, examples, or significant additions
- PATCH: Clarifications, typo fixes, minor improvements

**Example:**
- v1.0.0: Initial extraction from sdlc plugin
- v1.1.0: Added new example for async workflows
- v1.1.1: Fixed typo in principle 3
- v2.0.0: Restructured constraints section (breaking)

---

## Support

**Issues:** https://github.com/jwilger/claude-code-plugins/issues
**Discussions:** https://github.com/jwilger/claude-code-plugins/discussions
**Email:** john@johnwilger.com

---

## License

MIT License - See LICENSE file in repository root

---

## Extraction History

**Source:** sdlc plugin v3.12.8
**Extraction Date:** 2026-02-04 (Phase 4 of v4.0.0 redesign)
**Extractor:** Claude Code assistant

**Original sdlc protocols extracted:**
1. tdd-constraints (from shared/tdd-constraints.md)
2. user-input-protocol (from shared/user-input-protocol.md)
3. debugging-protocol (from shared/debugging-protocol.md)
4. atomic-design (from shared/atomic-design.md)
5. github-issues (from shared/github-issues.md)
6. memory-protocol (from shared/memory-protocol.md)
7. event-modeling (from shared/event-modeling.md)
8. orchestration-protocol (from shared/orchestration.md)

---

**Last Updated:** 2026-02-04
**Skills Count:** 8 active skills
**Total Lines:** ~10,000+ lines of protocol documentation
