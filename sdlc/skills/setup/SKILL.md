---
name: setup
version: 2.2.1
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

**Version:** 2.2.1
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

#### Question 3: GitHub Repository Setup?

**Yes (Recommended for team workflows):**
- Configure repository rulesets (branch protection)
- Set up automatic PR branch deletion
- Configure default PR title/message templates
- Set allowed merge types (squash/merge/rebase)

**No (Skip repository configuration):**
- Use default GitHub settings
- Configure manually later

#### Question 4: Output Style?

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
GitHub setup? → Yes
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
  GitHub: configured
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
        "description": "Break features into reviewable slices. Requires git-spice installed (CLI command: `gs`)."
      }
    ]
  }]
}
```

GitHub repository setup question:
```javascript
{
  "questions": [{
    "question": "Would you like to configure GitHub repository settings?",
    "header": "GitHub",
    "multiSelect": false,
    "options": [
      {
        "label": "Yes (Recommended for team workflows)",
        "description": "Configure rulesets, PR branch deletion, default PR templates, and allowed merge types."
      },
      {
        "label": "No (Skip for now)",
        "description": "Use default GitHub settings. You can configure manually later."
      }
    ]
  }]
}
```

If user selects "Yes", first check for GitHub remote:
```bash
# Check if repository has a GitHub remote
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "⚠️  No GitHub remote found"
  # Ask user to create or associate repository
fi
```

If no remote exists, ask user:
```javascript
{
  "questions": [{
    "question": "No GitHub remote found. What would you like to do?",
    "header": "Remote",
    "multiSelect": false,
    "options": [
      {
        "label": "Create new GitHub repository",
        "description": "Create a new repository on GitHub and set it as remote. Uses gh CLI."
      },
      {
        "label": "Associate with existing repository",
        "description": "Add an existing GitHub repository as remote. You'll need the repo URL."
      },
      {
        "label": "Skip GitHub configuration",
        "description": "Continue without GitHub remote. You can configure this later."
      }
    ]
  }]
}
```

**If "Create new GitHub repository" selected:**

First, ask for repository name:
```javascript
{
  "questions": [{
    "question": "What should the GitHub repository be named? (Suggested: [directory-name])",
    "header": "Repo Name",
    "multiSelect": false,
    "options": [
      {
        "label": "[directory-name] (Recommended)",
        "description": "Use the current directory name as the repository name."
      },
      {
        "label": "Different name",
        "description": "Specify a custom repository name."
      }
    ]
  }]
}
```

If "Different name" selected, prompt for custom name using AskUserQuestion with text input.

Then create repository:
```bash
# Get the chosen name (either directory name or custom)
REPO_NAME="[chosen-name]"

# Ask about visibility
# Use AskUserQuestion to choose between public/private

# Create repository
if gh repo create "$REPO_NAME" --source=. --remote=origin --public; then
  echo "✓ Repository created and remote added"
else
  # Creation failed - likely name already exists
  echo "⚠️  Repository creation failed"
fi
```

**If repository creation fails (name exists):**

Ask user what to do next:
```javascript
{
  "questions": [{
    "question": "Repository name already exists. What would you like to do?",
    "header": "Conflict",
    "multiSelect": false,
    "options": [
      {
        "label": "Associate with existing repository",
        "description": "Connect this project to the existing [repo-name] repository."
      },
      {
        "label": "Try a different name",
        "description": "Choose a different repository name and create a new one."
      },
      {
        "label": "Skip GitHub configuration",
        "description": "Continue without configuring GitHub remote."
      }
    ]
  }]
}
```

- If "Associate with existing": Use the associate flow (add remote, verify)
- If "Try a different name": Loop back to name selection
- If "Skip": Exit GitHub configuration

**If "Associate with existing repository" selected:**
```bash
# Ask for repository URL or owner/name
echo "Enter GitHub repository (format: owner/repo or full URL):"
read REPO_INPUT

# Add remote
git remote add origin "https://github.com/$REPO_INPUT.git" 2>/dev/null || \
  git remote add origin "$REPO_INPUT"

# Verify remote
if gh repo view >/dev/null 2>&1; then
  echo "✓ Remote added successfully"
else
  echo "❌ Failed to verify remote. Check the repository URL."
  exit 1
fi
```

**If "Skip" selected:** Exit GitHub configuration, continue with rest of setup.

After remote is confirmed, configure repository settings:
```bash
# Get repository name
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# Configure repository settings
gh api -X PATCH "repos/$REPO" \
  -f delete_branch_on_merge=true \
  -f allow_squash_merge=true \
  -f allow_merge_commit=true \
  -f allow_rebase_merge=true

# Set default PR title/body templates (create .github/pull_request_template.md if needed)
mkdir -p .github
cat > .github/pull_request_template.md <<'EOF'
## Summary
<!-- Brief description of changes -->

## Test Plan
<!-- How to verify these changes work -->

## Related Issues
<!-- Link to related issues/tickets -->
EOF

# Create branch protection ruleset (requires rulesets API)
# Note: User needs admin access to configure rulesets
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

If worktrees are selected, create directory and gitignore:
```bash
mkdir -p .worktrees
echo ".worktrees/" >> .gitignore
```

Update config with selections:
```yaml
git:
  worktrees: true  # if selected
  worktree_parent: .worktrees
  stacked_prs: true  # if selected

github:
  repository_configured: true  # if GitHub setup was selected
  delete_branch_on_merge: true
  allow_squash_merge: true
  allow_merge_commit: true
  allow_rebase_merge: true

output_style: sdlc-rules  # or sdlc-marvin

configured_at: "2026-02-05T10:00:00Z"
configured_by: claude-sonnet-4-5
```

#### 4.5. Tool Detection (Advanced Stage)

When git-spice is selected in advanced options, verify installation:

```bash
# Check if gs command exists
if command -v gs >/dev/null 2>&1; then
  echo "✓ git-spice (gs) installed"
else
  echo "⚠️  git-spice not found"
  echo "Installation: https://abhinav.github.io/git-spice/"
  echo "Note: The CLI command is 'gs', not 'git-spice'"
fi
```

**Important:** Check for the `gs` command, NOT `git-spice`.

#### 5. Completion Message

```
✅ SDLC Setup Complete!

Configuration:
  Mode: event-modeling
  Worktrees: enabled (.worktrees/ directory created)
  Stacked PRs: disabled
  GitHub: configured (branch deletion, PR templates, merge types)
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

**Version:** 2.2.1 (2026-02-05):
- Fix: Ask for repository name instead of assuming directory name
- Fix: Ask before associating with existing repo when name conflicts
- Add visibility choice (public/private) for new repositories

**Version:** 2.2.0 (2026-02-05):
- Add GitHub remote creation/association when no remote exists
- Offer to create new repo via `gh repo create` or associate with existing repo

**Version:** 2.1.0 (2026-02-05):
- Fix worktrees directory location: now uses `.worktrees/` (gitignored) instead of `../worktrees`
- Add GitHub repository configuration option (rulesets, PR settings, branch deletion, merge types)

**Version:** 2.0.1 (2026-02-05): Fix git-spice command detection (use `gs` not `git-spice`)

**Dependencies:** None
**Portability:** Tool-specific (gh, git required)
