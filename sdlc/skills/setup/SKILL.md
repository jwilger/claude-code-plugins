---
name: setup
version: 2.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Interactive multi-stage SDLC configuration with progressive disclosure. Run this first before using any other skills.
tags:
  - workflow
  - setup
  - configuration
  - wizard
portability: tool-specific
dependencies: []
allowed-tools: Bash, Write, AskUserQuestion, Read
---

# Setup Skill

**Version:** 2.0.0
**Portability:** Tool-specific

---

## Quick Start

Interactive setup in 2-3 minutes with progressive disclosure.

### What This Does
Guides you through 3 stages: Essential setup → Workflow choice → Advanced options (optional).

### Fastest Path
```bash
/sdlc:setup
# Or with template:
/sdlc:setup --template=api-development

# Stage 1 (30 seconds): Essential Setup
#   ✓ Check git, gh CLI
#   ✓ Authenticate GitHub
#   ✓ Create .claude directory

# Stage 2 (1 minute): Workflow Selection
#   Choose: Event Modeling OR Traditional
#   Creates appropriate directory structure

# Stage 3 (1 minute, optional): Advanced Options
#   • Worktrees? (parallel work isolation)
#   • git-spice? (stacked PRs)
#   • Output style? (sdlc-rules or sdlc-marvin)
```

**Total time:** 2-3 minutes (vs 10-15 minutes with old approach)

---

## Multi-Stage Wizard

### Stage 1: Essential Setup (30 seconds)

**Automatic checks:**
- ✓ Git installed and configured
- ✓ GitHub CLI (gh) installed
- ✓ GitHub authentication active

**What you'll do:**
- Install missing tools (if needed)
- Authenticate with GitHub (if needed)
- Confirm project directory

**Output:** Basic `.claude/sdlc.yaml` created

---

### Stage 2: Workflow Selection (1 minute)

**Question:** "Which workflow approach fits your project?"

#### Option 1: Event Modeling (Recommended for complex domains)

**Best for:**
- Event-sourced systems
- Complex business logic with multiple bounded contexts
- Domain-driven design approach
- Teams that benefit from upfront domain modeling

**Workflow:**
Discovery → Design → GWT → Tasks → TDD → PR

**Time investment:** 2-4 hours upfront design, faster implementation

#### Option 2: Traditional (Recommended for CRUD/simple features)

**Best for:**
- CRUD applications
- Simple feature work
- Well-understood domains
- Microservices with clear boundaries

**Workflow:**
Issues → TDD → PR

**Time investment:** Minimal upfront, may need refactoring later

**Output:**
- Mode saved to config
- Directory structure created (if Event Modeling)

---

### Stage 3: Advanced Options (1 minute, optional)

**You can skip this stage** - defaults work great for most projects.

#### Question 1: Git Worktrees?

**Yes (Recommended for parallel work):**
- Each task gets isolated directory
- Switch tasks without stashing
- Clean separation, no conflicts

**No (Standard branch workflow):**
- Work in single repo directory
- Use `git checkout` to switch
- Simpler mental model

#### Question 2: Stacked PRs (git-spice)?

**Yes (Recommended for incremental changes):**
- Break large features into reviewable slices
- Each slice = separate PR
- Automatic dependency management

**No (One PR per feature):**
- Standard GitHub workflow
- Simpler review process

#### Question 3: Output Style?

**sdlc-rules (Professional):**
- Clear, directive guidance
- Focus on efficiency

**sdlc-marvin (Marvin the Paranoid Android):**
- Same rules, depressed robot personality
- "I suppose I'll check the tests..."

**Output:** Complete `.claude/sdlc.yaml` with all preferences

---

## Reconfiguration

Already set up? Want to change settings?

```bash
/sdlc:setup --reconfigure

# Shows current settings
# Choose what to change:
#   1. Workflow mode
#   2. Advanced options
#   3. Everything
```

**Preserves:** Custom settings you added manually

---

## Common Examples

### Example 1: First Time (Event Modeling)
```
User: /sdlc:setup

Stage 1:
✓ git found
✓ gh CLI found
✓ Authenticated as john@example.com
✓ Created .claude/sdlc.yaml

Stage 2:
Select: Event Modeling
✓ Created docs/event_model/
✓ Mode: event-modeling

Stage 3:
Worktrees? → Yes
Stacked PRs? → No (skip git-spice)
Output style? → sdlc-rules

✅ Setup complete! Run /sdlc:start to begin.
```

### Example 2: First Time (Traditional, Fast)
```
User: /sdlc:setup

Stage 1:
✓ All checks passed

Stage 2:
Select: Traditional
✓ Mode: traditional

Stage 3:
Skip? → Yes (use defaults)

✅ Setup complete! Run /sdlc:work to begin.
```

### Example 3: Reconfigure Output Style
```
User: /sdlc:setup --reconfigure

Current:
  Mode: event-modeling
  Worktrees: yes
  Output: sdlc-rules

Change? → Output style only
New style: sdlc-marvin

✅ Updated to Marvin personality!
```

---

## When to Use

**Use when:**
- First time using SDLC in project
- `.claude/sdlc.yaml` doesn't exist
- User asks to "set up" or "configure"
- Want to change workflow settings (use `--reconfigure`)

**Run this first:** Required before all other skills

---

## Auto-Invocation

Claude automatically invokes this skill when you say:
- "Set up the SDLC workflow"
- "Configure the project"
- "Initialize SDLC"
- "I need to set up the plugin"
- "Let's configure the workflow"
- "Change my workflow settings" (triggers --reconfigure)

You don't need to type `/sdlc:setup` explicitly - Claude will detect these requests and invoke the skill for you.

---

## Implementation Guide

### For Claude: Multi-Stage Flow

When invoked, follow this sequence:

#### 1. Check for Existing Config

```bash
if [[ -f ".claude/sdlc.yaml" ]]; then
  # Check if --reconfigure flag present
  if [[ "$*" == *"--reconfigure"* ]]; then
    # Show current config, ask what to change
  else
    echo "Already configured. Use --reconfigure to change settings."
    exit 0
  fi
fi
```

#### 2. Stage 1: Essential Setup

```bash
# Check prerequisites
git --version >/dev/null 2>&1 || echo "❌ Git not found"
gh --version >/dev/null 2>&1 || echo "❌ gh CLI not found"
gh auth status >/dev/null 2>&1 || echo "⚠️  GitHub auth required: gh auth login"

# Create directory
mkdir -p .claude

# Write minimal config
cat > .claude/sdlc.yaml <<EOF
version: 1.0.0
plugin_version: "10.0.0"
mode: unconfigured
EOF
```

#### 3. Stage 2: Workflow Selection

Use AskUserQuestion:

```javascript
{
  "questions": [{
    "question": "Which workflow approach fits your project?",
    "header": "Workflow",
    "multiSelect": false,
    "options": [
      {
        "label": "Event Modeling (Recommended for complex domains)",
        "description": "Domain-first with Event Modeling. Best for event-sourced systems, complex business logic. 2-4h upfront design, faster implementation."
      },
      {
        "label": "Traditional (Recommended for CRUD/simple features)",
        "description": "Direct issue → work → PR. Best for CRUD, simple features, well-understood domains. Minimal upfront time."
      }
    ]
  }]
}
```

Based on answer:
- Event Modeling: Create `docs/event_model/` directory structure
- Traditional: No additional directories

Update config:
```yaml
mode: event-modeling  # or traditional
enforce_tdd: true
require_domain_review: true
```

#### 4. Stage 3: Advanced Options

Use AskUserQuestion with multiSelect for optional features:

```javascript
{
  "questions": [{
    "question": "Which advanced features would you like to enable? (Optional - you can skip all)",
    "header": "Advanced",
    "multiSelect": true,
    "options": [
      {
        "label": "Git Worktrees (parallel work isolation)",
        "description": "Each task in separate directory. Switch tasks without stashing. Requires Git 2.5+."
      },
      {
        "label": "Stacked PRs with git-spice",
        "description": "Break features into reviewable slices. Requires git-spice installed."
      }
    ]
  }]
}
```

Separate question for output style (always choose one):
```javascript
{
  "questions": [{
    "question": "Which output style do you prefer?",
    "header": "Style",
    "multiSelect": false,
    "options": [
      {
        "label": "sdlc-rules (Professional)",
        "description": "Clear, directive guidance focused on efficiency."
      },
      {
        "label": "sdlc-marvin (Marvin the Paranoid Android)",
        "description": "Same rules with depressed robot personality. Humorous commentary."
      }
    ]
  }]
}
```

Update config with selections:
```yaml
git:
  worktrees: true  # if selected
  worktree_parent: ../worktrees
  stacked_prs: true  # if selected

output_style: sdlc-rules  # or sdlc-marvin

configured_at: "2026-02-05T10:00:00Z"
configured_by: claude-sonnet-4-5
```

#### 5. Completion Message

```
✅ SDLC Setup Complete!

Configuration:
  Mode: event-modeling
  Worktrees: enabled
  Stacked PRs: disabled
  Output style: sdlc-rules

Next steps:
  • Run /sdlc:start to begin working
  • Run /sdlc:status to see project state
  • Run /sdlc:setup --reconfigure to change settings

📖 For detailed workflow info: /sdlc:recall "workflow"
```

---

## Reference

For complete implementation details, configuration schema, and error handling:
- [Complete Reference](./reference.md) - Multi-stage process, configuration schema, error handling

---

## Metadata

**Version:** 2.0.0 (2026-02-05): Interactive multi-stage wizard with progressive disclosure
**Dependencies:** None
**Portability:** Tool-specific (gh, git required)
