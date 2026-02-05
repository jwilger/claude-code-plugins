---
name: setup
version: 3.1.1
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

**Version:** 3.1.1
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

After remote is confirmed, configure repository settings interactively:

**Step 1: Get current repository settings**
```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# Get current settings
CURRENT=$(gh api "repos/$REPO" --jq '{
  delete_branch_on_merge,
  allow_squash_merge,
  allow_merge_commit,
  allow_rebase_merge,
  web_commit_signoff_required,
  squash_merge_commit_title,
  squash_merge_commit_message,
  merge_commit_title,
  merge_commit_message
}')
```

**Step 2: Discover available options via GraphQL**
```bash
# Get enum options for merge settings
SQUASH_TITLE_OPTIONS=$(gh api graphql -f query='query { __type(name: "SquashMergeCommitTitle") { enumValues { name description } } }' --jq '.data.__type.enumValues')
SQUASH_MSG_OPTIONS=$(gh api graphql -f query='query { __type(name: "SquashMergeCommitMessage") { enumValues { name description } } }' --jq '.data.__type.enumValues')
MERGE_TITLE_OPTIONS=$(gh api graphql -f query='query { __type(name: "MergeCommitTitle") { enumValues { name description } } }' --jq '.data.__type.enumValues')
MERGE_MSG_OPTIONS=$(gh api graphql -f query='query { __type(name: "MergeCommitMessage") { enumValues { name description } } }' --jq '.data.__type.enumValues')
```

**Step 3: Present configuration questions to user**

Use AskUserQuestion with multiSelect for boolean options:
```javascript
{
  "questions": [{
    "question": "Which repository features would you like to enable?",
    "header": "Features",
    "multiSelect": true,
    "options": [
      {
        "label": "Auto-delete branches after merge",
        "description": "Automatically delete head branches when PRs are merged (delete_branch_on_merge)"
      },
      {
        "label": "Require commit sign-off",
        "description": "Require 'Signed-off-by' line in commit messages (web_commit_signoff_required)"
      }
    ]
  }]
}
```

Use AskUserQuestion for merge type selection:
```javascript
{
  "questions": [{
    "question": "Which merge types should be allowed?",
    "header": "Merge Types",
    "multiSelect": true,
    "options": [
      {
        "label": "Squash merging",
        "description": "Combine all commits into one (allow_squash_merge). Current: [current_value]"
      },
      {
        "label": "Merge commits",
        "description": "Standard merge with merge commit (allow_merge_commit). Current: [current_value]"
      },
      {
        "label": "Rebase merging",
        "description": "Rebase and merge commits (allow_rebase_merge). Current: [current_value]"
      }
    ]
  }]
}
```

Use AskUserQuestion for squash merge defaults (if squash merge enabled):
```javascript
{
  "questions": [
    {
      "question": "Default title for squash merge commits?",
      "header": "Squash Title",
      "multiSelect": false,
      "options": [
        /* Dynamically generated from SQUASH_TITLE_OPTIONS */
        {"label": "PR_TITLE", "description": "Use pull request's title"},
        {"label": "COMMIT_OR_PR_TITLE", "description": "Use commit title (single commit) or PR title (multiple)"}
      ]
    },
    {
      "question": "Default message for squash merge commits?",
      "header": "Squash Message",
      "multiSelect": false,
      "options": [
        /* Dynamically generated from SQUASH_MSG_OPTIONS */
        {"label": "PR_BODY", "description": "Use pull request's body"},
        {"label": "COMMIT_MESSAGES", "description": "Use branch's commit messages"},
        {"label": "BLANK", "description": "Use blank commit message"}
      ]
    }
  ]
}
```

Use AskUserQuestion for merge commit defaults (if merge commits enabled):
```javascript
{
  "questions": [
    {
      "question": "Default title for merge commits?",
      "header": "Merge Title",
      "multiSelect": false,
      "options": [
        /* Dynamically generated from MERGE_TITLE_OPTIONS */
        {"label": "PR_TITLE", "description": "Use pull request's title"},
        {"label": "MERGE_MESSAGE", "description": "Use classic merge message format"}
      ]
    },
    {
      "question": "Default message for merge commits?",
      "header": "Merge Message",
      "multiSelect": false,
      "options": [
        /* Dynamically generated from MERGE_MSG_OPTIONS */
        {"label": "PR_TITLE", "description": "Use pull request's title"},
        {"label": "PR_BODY", "description": "Use pull request's body"},
        {"label": "BLANK", "description": "Use blank commit message"}
      ]
    }
  ]
}
```

**Step 4: Optional - PR Template**
```javascript
{
  "questions": [{
    "question": "Would you like to create a pull request template?",
    "header": "PR Template",
    "multiSelect": false,
    "options": [
      {
        "label": "Yes",
        "description": "Create .github/pull_request_template.md with standard sections"
      },
      {
        "label": "No",
        "description": "Skip PR template creation"
      }
    ]
  }]
}
```

**Step 5: Optional - Branch Protection Rulesets**

Ask if user wants branch protection:
```javascript
{
  "questions": [{
    "question": "Would you like to configure branch protection?",
    "header": "Protection",
    "multiSelect": false,
    "options": [
      {
        "label": "Yes - Configure rulesets",
        "description": "Set up comprehensive branch protection rules (recommended)"
      },
      {
        "label": "No - Skip for now",
        "description": "Skip branch protection (can configure later via GitHub)"
      }
    ]
  }]
}
```

**If "Yes", ask comprehensive ruleset questions:**

**5a. Signed Commits (Repository-wide)**
```javascript
{
  "questions": [{
    "question": "Require signed commits on all branches?",
    "header": "Signed Commits",
    "multiSelect": false,
    "options": [
      {
        "label": "Yes - Require signatures",
        "description": "Require GPG/SSH signed commits on all branches (recommended for security)"
      },
      {
        "label": "No",
        "description": "Allow unsigned commits"
      }
    ]
  }]
}
```

**5b. Pull Request Requirements**
```javascript
{
  "questions": [{
    "question": "How many approving reviews should be required for PRs to main?",
    "header": "Reviews",
    "multiSelect": false,
    "options": [
      {
        "label": "0 - No reviews required",
        "description": "Allow merging without approval (solo projects)"
      },
      {
        "label": "1 - Require 1 approval",
        "description": "At least one approving review (recommended for teams)"
      },
      {
        "label": "2 - Require 2 approvals",
        "description": "Two approving reviews (high-stakes projects)"
      }
    ]
  }]
}
```

**5c. Review Settings**
```javascript
{
  "questions": [{
    "question": "Which review settings would you like to enable?",
    "header": "Review Rules",
    "multiSelect": true,
    "options": [
      {
        "label": "Dismiss stale reviews on new commits",
        "description": "Re-request approval when PR is updated (recommended)"
      },
      {
        "label": "Require review from code owners",
        "description": "Require approval from CODEOWNERS (if file exists)"
      },
      {
        "label": "Require last push approval",
        "description": "Require approval after the most recent push"
      }
    ]
  }]
}
```

**5d. Branch Update Requirements**
```javascript
{
  "questions": [{
    "question": "Require branches to be up to date before merging?",
    "header": "Branch Updates",
    "multiSelect": false,
    "options": [
      {
        "label": "Yes - Require up to date",
        "description": "Force branch updates before merge (prevents integration issues, recommended)"
      },
      {
        "label": "No - Allow outdated branches",
        "description": "Allow merging without updating (faster but riskier)"
      }
    ]
  }]
}
```

**5e. Status Checks (CI/CD)**
```javascript
{
  "questions": [{
    "question": "Require status checks (CI/CD) to pass before merging?",
    "header": "CI Checks",
    "multiSelect": false,
    "options": [
      {
        "label": "Yes - Require CI to pass",
        "description": "Block merging if CI fails (recommended)"
      },
      {
        "label": "No - Skip CI requirement",
        "description": "Allow merging without CI checks"
      }
    ]
  }]
}
```

**If CI required, ask about creating placeholder workflow:**
```javascript
{
  "questions": [{
    "question": "Would you like to create a placeholder CI workflow?",
    "header": "CI Workflow",
    "multiSelect": false,
    "options": [
      {
        "label": "Yes - Create placeholder",
        "description": "Create .github/workflows/ci.yml (passes by default, customize later)"
      },
      {
        "label": "No - I'll create it myself",
        "description": "Skip workflow creation"
      }
    ]
  }]
}
```

**If creating placeholder CI workflow:**
```bash
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Placeholder CI
        run: echo "CI check passed - customize this workflow for your needs"
EOF
```

**5f. Force Push and Deletion**
```javascript
{
  "questions": [{
    "question": "Which restrictions should apply to the main branch?",
    "header": "Restrictions",
    "multiSelect": true,
    "options": [
      {
        "label": "Block force pushes (Recommended)",
        "description": "Prevent git push --force to main branch"
      },
      {
        "label": "Block branch deletion (Recommended)",
        "description": "Prevent main branch from being deleted"
      },
      {
        "label": "Require linear history",
        "description": "Prevent merge commits (only allow squash/rebase)"
      }
    ]
  }]
}
```

**Step 6: Apply selected configuration**

**6a. Apply repository settings:**
```bash
# Build PATCH request with user's selections
gh api -X PATCH "repos/$REPO" \
  -f delete_branch_on_merge=$DELETE_BRANCH \
  -f allow_squash_merge=$ALLOW_SQUASH \
  -f allow_merge_commit=$ALLOW_MERGE \
  -f allow_rebase_merge=$ALLOW_REBASE \
  -f web_commit_signoff_required=$REQUIRE_SIGNOFF \
  -f squash_merge_commit_title=$SQUASH_TITLE \
  -f squash_merge_commit_message=$SQUASH_MESSAGE \
  -f merge_commit_title=$MERGE_TITLE \
  -f merge_commit_message=$MERGE_MESSAGE
```

**6b. Create PR template (if requested):**
```bash
if [ "$CREATE_PR_TEMPLATE" = "yes" ]; then
  mkdir -p .github
  cat > .github/pull_request_template.md <<'EOF'
## Summary
<!-- Brief description of changes -->

## Test Plan
<!-- How to verify these changes work -->

## Related Issues
<!-- Link to related issues/tickets -->
EOF
fi
```

**6c. Create CI workflow (if requested):**
```bash
if [ "$CREATE_CI_WORKFLOW" = "yes" ]; then
  mkdir -p .github/workflows
  cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Placeholder CI
        run: echo "CI check passed - customize this workflow for your needs"
EOF
fi
```

**6d. Create comprehensive ruleset (if branch protection enabled):**

**CRITICAL: Check if main branch exists first**
```bash
if [ "$CONFIGURE_PROTECTION" = "yes" ]; then
  # Check if main branch exists on remote
  if ! git ls-remote origin main 2>/dev/null | grep -q 'refs/heads/main'; then
    echo "⚠️  Bootstrap Issue: Main branch doesn't exist on remote yet"
    echo ""
    # Ask user what to do
  fi
fi
```

**If main doesn't exist, ask user:**
```javascript
{
  "questions": [{
    "question": "Main branch doesn't exist yet. How should we proceed?",
    "header": "Bootstrap",
    "multiSelect": false,
    "options": [
      {
        "label": "Push initial commit now (Recommended)",
        "description": "Push .claude/sdlc.yaml and any created files to main, then set up protection"
      },
      {
        "label": "Defer branch protection",
        "description": "Save config and set up protection later (run /sdlc:setup --reconfigure after first push)"
      },
      {
        "label": "Skip branch protection for now",
        "description": "Don't configure branch protection at this time"
      }
    ]
  }]
}
```

**If "Push initial commit now" selected:**
```bash
# Stage setup files
git add .claude/sdlc.yaml
[ -f .github/workflows/ci.yml ] && git add .github/workflows/ci.yml
[ -f .github/pull_request_template.md ] && git add .github/pull_request_template.md
[ -f .worktrees/.gitignore ] && git add .worktrees/.gitignore

# Commit
git commit -m "chore: configure SDLC workflow

- Add SDLC plugin configuration
- Configure GitHub repository settings
- Set up branch protection (pending)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Push to main
git push -u origin main

# Now create rulesets since main exists
echo "✓ Main branch created, setting up protection..."
CONFIGURE_PROTECTION="yes"
```

**If "Defer" or "Skip", mark in config:**
```yaml
github:
  # ... other settings ...
  branch_protection:
    main:
      status: deferred  # or: skipped
      # ... saved settings for later ...
```

if [ "$CONFIGURE_PROTECTION" = "yes" ]; then
  # Build ruleset JSON based on user selections
  cat > /tmp/ruleset.json <<EOF
{
  "name": "Main Branch Protection",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": $REQUIRED_REVIEWS,
        "dismiss_stale_reviews_on_push": $DISMISS_STALE,
        "require_code_owner_review": $REQUIRE_CODE_OWNERS,
        "require_last_push_approval": $REQUIRE_LAST_PUSH,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [
          $(if [ "$REQUIRE_CI" = "yes" ]; then echo '{"context": "CI"}'; fi)
        ],
        "strict_required_status_checks_policy": $REQUIRE_UP_TO_DATE
      }
    },
    {
      "type": "non_fast_forward",
      "parameters": {}
    }
  ]
}
EOF

  # Add signed commits rule if enabled (applies to all branches)
  if [ "$REQUIRE_SIGNED" = "yes" ]; then
    # Add to ruleset rules
    jq '.rules += [{"type": "required_signatures", "parameters": {}}]' /tmp/ruleset.json > /tmp/ruleset-updated.json
    mv /tmp/ruleset-updated.json /tmp/ruleset.json
  fi

  # Add deletion protection if enabled
  if [ "$BLOCK_DELETION" = "yes" ]; then
    jq '.rules += [{"type": "deletion", "parameters": {}}]' /tmp/ruleset.json > /tmp/ruleset-updated.json
    mv /tmp/ruleset-updated.json /tmp/ruleset.json
  fi

  # Add linear history if enabled
  if [ "$REQUIRE_LINEAR" = "yes" ]; then
    jq '.rules += [{"type": "required_linear_history", "parameters": {}}]' /tmp/ruleset.json > /tmp/ruleset-updated.json
    mv /tmp/ruleset-updated.json /tmp/ruleset.json
  fi

  # Create ruleset via API
  gh api -X POST "repos/$REPO/rulesets" --input /tmp/ruleset.json

  # Clean up
  rm /tmp/ruleset.json
fi
```

**Note:** Rulesets API requires admin access to the repository.

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

**Version:** 3.1.1 (2026-02-05) - Fix bootstrap issue
- **CRITICAL FIX**: Check if main branch exists before creating rulesets
- Prevent "branch protection on non-existent branch" bootstrap problem
- When main doesn't exist, offer three options:
  1. **Push initial commit now** (recommended) - commit setup files, push to main, then create protection
  2. **Defer protection** - save config, set up after first push via --reconfigure
  3. **Skip protection** - don't configure at this time
- Mark deferred/skipped protection status in .claude/sdlc.yaml
- Fixes issue where new repos couldn't push to protected non-existent main

**Version:** 3.1.0 (2026-02-05) - Comprehensive branch protection
- Add comprehensive ruleset configuration questions:
  - Signed commits on all branches (repository-wide)
  - Number of required approving reviews (0, 1, or 2)
  - Review settings (dismiss stale, code owners, last push approval)
  - Require branch up-to-date before merge
  - CI/status check requirements
  - Placeholder CI workflow creation (.github/workflows/ci.yml)
  - Force push and deletion restrictions
  - Linear history requirement
- Create complete rulesets via GitHub Rulesets API
- Save all settings to .claude/sdlc.yaml for reference

**Version:** 3.0.0 (2026-02-05) - BREAKING: Interactive GitHub configuration
- **BREAKING**: GitHub config now fully interactive via AskUserQuestion (no auto-apply)
- Use dynamic API discovery via GraphQL introspection for enum options
- Ask user for all configuration choices:
  - Merge types (squash/merge/rebase)
  - Default merge titles and messages (discovered via GraphQL)
  - Branch deletion, commit sign-off
  - PR template (optional, not automatic)
  - Branch protection rulesets (optional)
- Reduces maintenance burden - auto-discovers GitHub API options
- Shows current values in option descriptions

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
