# Setup Skill Reference

## Multi-Stage Setup Process

The setup skill uses progressive disclosure to reduce cognitive load during initial configuration.

### Stage 1: Essential Setup (30 seconds)

**Goal:** Get the minimum working configuration

**Checks:**
1. Git installed and configured (`git --version`, `git config user.name/email`)
2. GitHub CLI installed (`gh --version`)
3. GitHub CLI authenticated (`gh auth status`)
4. Create `.claude` directory if needed

**Actions:**
- Install gh CLI if missing (platform-specific)
- Run `gh auth login` if not authenticated
- Create `.claude/sdlc.yaml` with minimal config

**Output:**
```yaml
# .claude/sdlc.yaml (Stage 1)
version: 1.0.0
plugin_version: "10.0.0"
mode: unconfigured  # Will be set in Stage 2
```

### Stage 2: Workflow Selection (1 minute)

**Goal:** Choose between Event Modeling and Traditional workflows

**Question:**
"Which workflow approach fits your project?"

**Options:**

#### Option 1: Event Modeling (Recommended for complex domains)
**Best for:**
- Event-sourced systems
- Complex business logic
- Domain-driven design
- Multiple bounded contexts

**Workflow:**
1. Domain Discovery (`/sdlc:design discover`)
2. Workflow Design (`/sdlc:design workflow`)
3. GWT Scenarios (`/sdlc:design gwt`)
4. Create Tasks (`/sdlc:plan`)
5. TDD Implementation (`/sdlc:work`)
6. PR with Review (`/sdlc:pr`)

**Time investment:** 2-4 hours upfront design, faster implementation

#### Option 2: Traditional (Recommended for CRUD/simple features)
**Best for:**
- CRUD applications
- Simple feature work
- Well-understood domains
- Microservices with clear boundaries

**Workflow:**
1. Create GitHub issues manually
2. Start Work (`/sdlc:work`)
3. TDD Implementation
4. PR with Review (`/sdlc:pr`)

**Time investment:** Minimal upfront, may need refactoring later

**Actions:**
- Update `.claude/sdlc.yaml` with chosen mode
- Create appropriate directory structure

**Output for Event Modeling:**
```yaml
mode: event-modeling
enforce_tdd: true
require_domain_review: true
```

Creates:
```
docs/
  event_model/
    domain-overview.md (template)
    workflows/ (empty, ready for workflows)
```

**Output for Traditional:**
```yaml
mode: traditional
enforce_tdd: true
require_domain_review: true
```

### Stage 3: Advanced Options (1 minute, optional)

**Goal:** Configure advanced features

#### Question 1: Worktrees
"Do you want to use git worktrees for task isolation?"

**Option 1: Yes (Recommended for parallel work)**
- Each task gets its own directory
- Switch between tasks without stashing
- Clean separation of work
- Requires: `git worktree` support (Git 2.5+)

**Option 2: No (Standard branch workflow)**
- Work in single repository directory
- Use `git checkout` to switch branches
- Simpler mental model
- Standard git workflow

**Implementation (if Yes):**
```bash
# Create worktrees directory
mkdir -p .worktrees

# Add to .gitignore
echo ".worktrees/" >> .gitignore
```

**Config:**
```yaml
git:
  worktrees: true  # or false
  worktree_parent: .worktrees  # if true
```

#### Question 2: Git-Spice
"Do you want stacked PR support with git-spice?"

**Option 1: Yes (Recommended for incremental changes)**
- Break large features into reviewable slices
- Each slice is a separate PR
- Manage PR dependencies automatically
- Requires: git-spice installed (CLI command: `gs`)

**Option 2: No (Single PR per feature)**
- One PR per complete feature
- Simpler review process
- Standard GitHub workflow

**Config:**
```yaml
git:
  stacked_prs: true  # or false
  spice_branch_prefix: slice/  # if true
```

#### Question 3: GitHub Repository Setup
"Would you like to configure GitHub repository settings?"

**Option 1: Yes (Recommended for team workflows)**
- Configure repository rulesets (branch protection)
- Set up automatic PR branch deletion
- Configure default PR title/message templates
- Set allowed merge types (squash/merge/rebase)
- Requires: Admin access to repository

**Option 2: No (Skip repository configuration)**
- Use default GitHub settings
- Configure manually later via GitHub UI

**Implementation:**

**Step 1: Check for GitHub remote**
```bash
# Check if repository has a GitHub remote
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "⚠️  No GitHub remote found"
  # Prompt user for action (see below)
fi
```

**Step 2: Handle missing remote (if needed)**

If no remote exists, present three options:

1. **Create new GitHub repository:**

**Step 1: Ask for repository name**
Present options:
- Use directory name (default/recommended)
- Specify custom name

If custom name chosen, prompt for text input.

**Step 2: Ask for visibility**
Present options:
- Public repository
- Private repository

**Step 3: Create repository**
```bash
# Use chosen name and visibility
gh repo create "$REPO_NAME" --source=. --remote=origin --public  # or --private

# Check result
if [ $? -eq 0 ]; then
  echo "✓ Repository created and remote added"
else
  # Creation failed - handle conflict
fi
```

**Step 4: Handle creation failure (name conflict)**
If creation fails (typically "name already exists"), ask user:
- **Associate with existing repository**: Connect to the existing repo with that name
- **Try a different name**: Loop back to Step 1 with different name
- **Skip GitHub configuration**: Exit without configuring remote

Do NOT automatically assume the user wants to associate with existing repo.

2. **Associate with existing repository:**
```bash
# Prompt for repository (owner/repo format or URL)
echo "Enter GitHub repository (owner/repo or URL):"
read REPO_INPUT

# Add remote
git remote add origin "https://github.com/$REPO_INPUT.git" 2>/dev/null || \
  git remote add origin "$REPO_INPUT"

# Verify remote
gh repo view >/dev/null 2>&1 && echo "✓ Remote added"
```

3. **Skip GitHub configuration:** Exit this step, continue with rest of setup.

**Step 3: Configure repository settings (after remote confirmed)**

This step uses dynamic API discovery to present current options to the user.

**3a. Discover current settings and available options:**
```bash
# Get repository name
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# Get current settings
gh api "repos/$REPO" --jq '{
  delete_branch_on_merge,
  allow_squash_merge,
  allow_merge_commit,
  allow_rebase_merge,
  web_commit_signoff_required,
  squash_merge_commit_title,
  squash_merge_commit_message,
  merge_commit_title,
  merge_commit_message
}'

# Discover available enum values via GraphQL introspection
gh api graphql -f query='query { __type(name: "SquashMergeCommitTitle") { enumValues { name description } } }'
gh api graphql -f query='query { __type(name: "SquashMergeCommitMessage") { enumValues { name description } } }'
gh api graphql -f query='query { __type(name: "MergeCommitTitle") { enumValues { name description } } }'
gh api graphql -f query='query { __type(name: "MergeCommitMessage") { enumValues { name description } } }'
```

**3b. Present configuration options to user:**

Use AskUserQuestion to gather preferences:

1. **Repository features** (multiSelect):
   - Auto-delete branches after merge
   - Require commit sign-off

2. **Allowed merge types** (multiSelect):
   - Squash merging
   - Merge commits
   - Rebase merging

3. **Squash merge defaults** (if enabled):
   - Default title: Options from GraphQL enum
   - Default message: Options from GraphQL enum

4. **Merge commit defaults** (if enabled):
   - Default title: Options from GraphQL enum
   - Default message: Options from GraphQL enum

5. **PR template** (optional):
   - Create template: Yes/No

6. **Branch protection** (optional):
   - Require PRs
   - Require reviews
   - Skip

**3c. Apply user's selections:**

**Repository settings:**
```bash
# Update repository settings based on user input
gh api -X PATCH "repos/$REPO" \
  -f delete_branch_on_merge=$USER_DELETE_BRANCH \
  -f allow_squash_merge=$USER_ALLOW_SQUASH \
  -f allow_merge_commit=$USER_ALLOW_MERGE \
  -f allow_rebase_merge=$USER_ALLOW_REBASE \
  -f web_commit_signoff_required=$USER_REQUIRE_SIGNOFF \
  -f squash_merge_commit_title=$USER_SQUASH_TITLE \
  -f squash_merge_commit_message=$USER_SQUASH_MESSAGE \
  -f merge_commit_title=$USER_MERGE_TITLE \
  -f merge_commit_message=$USER_MERGE_MESSAGE
```

**PR template (optional):**
```bash
if [ "$USER_CREATE_PR_TEMPLATE" = "yes" ]; then
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

**CI workflow (optional):**
```bash
if [ "$USER_CREATE_CI" = "yes" ]; then
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

**Comprehensive branch protection rulesets:**
```bash
if [ "$USER_CONFIGURE_PROTECTION" = "yes" ]; then
  # Build comprehensive ruleset JSON
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
        "required_approving_review_count": $REVIEWS,
        "dismiss_stale_reviews_on_push": $DISMISS_STALE,
        "require_code_owner_review": $CODE_OWNERS,
        "require_last_push_approval": $LAST_PUSH,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [$CI_CHECKS],
        "strict_required_status_checks_policy": $UP_TO_DATE
      }
    },
    {
      "type": "non_fast_forward",
      "parameters": {}
    }
  ]
}
EOF

  # Add optional rules based on user selections
  # - required_signatures (if signed commits enabled)
  # - deletion (if block deletion enabled)
  # - required_linear_history (if linear history enabled)

  # Create ruleset
  gh api -X POST "repos/$REPO/rulesets" --input /tmp/ruleset.json
  rm /tmp/ruleset.json
fi
```

**Ruleset features based on user selections:**
- **Signed commits** (all branches): `required_signatures` rule
- **Pull request requirements**: Number of reviews, dismiss stale, code owners
- **Branch updates**: Require up-to-date before merge
- **CI/status checks**: Required checks to pass
- **Force push protection**: `non_fast_forward` rule
- **Deletion protection**: `deletion` rule
- **Linear history**: `required_linear_history` rule

Note: Rulesets API requires admin permissions on repository

**Key Benefits of Dynamic Discovery:**
- No hardcoded configuration options
- Automatically supports new GitHub features
- Lower maintenance burden
- Always current with GitHub API

**Config:**
```yaml
github:
  repository_configured: true  # or false
  delete_branch_on_merge: true
  allow_squash_merge: true
  allow_merge_commit: true
  allow_rebase_merge: true
```

#### Question 4: Output Style
"Which output style do you prefer?"

**Option 1: sdlc-rules (Professional)**
- Clear, directive guidance
- Focus on efficiency
- Professional tone

**Option 2: sdlc-marvin (Marvin the Paranoid Android)**
- Same orchestration rules
- Depressed robot personality
- Humorous commentary
- "I suppose I'll check the tests, though they'll probably fail anyway"

**Config:**
```yaml
output_style: sdlc-rules  # or sdlc-marvin
```

### Stage 4: Tool Installation (automatic)

**Checks and installs:**
1. `gh` extensions:
   - `gh-pr-review` (for PR review workflow)
2. Optional: `dot` CLI (for task management)
3. Optional: git-spice (check with `command -v gs`) (if stacked PRs enabled)

**Platform-specific installation commands provided**

### Reconfiguration

**Command:** `/sdlc:setup --reconfigure`

**Behavior:**
- Read existing `.claude/sdlc.yaml`
- Show current settings
- Ask which stage to reconfigure (Workflow / Advanced Options / All)
- Update only changed values
- Preserve custom settings

**Example:**
```
Current configuration:
  Mode: event-modeling
  Worktrees: enabled
  Stacked PRs: disabled
  Output style: sdlc-rules

What would you like to change?
1. Workflow mode (event-modeling → traditional)
2. Advanced options (worktrees, stacked PRs, output style)
3. Reconfigure everything
4. Cancel
```

## Configuration Schema

### Complete .claude/sdlc.yaml Example

```yaml
version: 1.0.0
plugin_version: "10.0.0"

# Workflow mode
mode: event-modeling  # or: traditional

# TDD enforcement
enforce_tdd: true
require_domain_review: true

# Git configuration
git:
  worktrees: true
  worktree_parent: .worktrees
  stacked_prs: false

# GitHub repository configuration
github:
  repository_configured: true
  repository: owner/repo-name
  delete_branch_on_merge: true
  allow_squash_merge: true
  allow_merge_commit: false
  allow_rebase_merge: false
  web_commit_signoff_required: false
  squash_merge_commit_title: PR_TITLE
  squash_merge_commit_message: PR_BODY
  branch_protection:
    main:
      require_pull_request: true
      required_approving_review_count: 1
      dismiss_stale_reviews: true
      require_code_owner_review: false
      require_last_push_approval: false
      require_up_to_date: true
      require_ci: true
      block_force_push: true
      block_deletion: true
      require_linear_history: false
      require_signed_commits: true  # Applies to all branches

# Output style
output_style: sdlc-rules  # or: sdlc-marvin

# Tool paths (auto-detected)
tools:
  gh: /usr/local/bin/gh
  git: /usr/bin/git
  dot: /usr/local/bin/dot  # optional

# Metadata
configured_at: "2026-02-05T10:00:00Z"
configured_by: claude-sonnet-4-5
```

## Error Handling

### Missing Prerequisites

If git or gh CLI not found:
```
❌ Prerequisites Missing

📚 Required tools:
- git (for version control)
- gh (GitHub CLI for API access)

🔧 Installation:

macOS:
  brew install git gh

Linux (Ubuntu/Debian):
  sudo apt install git gh

Linux (Fedora):
  sudo dnf install git gh

Windows:
  winget install Git.Git GitHub.cli

📖 After installation, run /sdlc:setup again
```

### Authentication Failure

If `gh auth status` fails:
```
❌ GitHub Authentication Required

📚 Why? The SDLC plugin uses GitHub CLI to:
- Create and manage issues
- Create and update pull requests
- Fetch PR reviews and comments

🔧 To authenticate:
  gh auth login

This will open your browser to authorize the CLI.

📖 After authentication, run /sdlc:setup again
```

## Implementation Notes

### Using AskUserQuestion

Each stage uses AskUserQuestion with structured options:

```javascript
{
  "questions": [
    {
      "question": "Which workflow approach fits your project?",
      "header": "Workflow",
      "multiSelect": false,
      "options": [
        {
          "label": "Event Modeling (Recommended for complex domains)",
          "description": "Domain-first with Event Modeling. Best for event-sourced systems, complex business logic. 2-4h upfront design."
        },
        {
          "label": "Traditional (Recommended for CRUD/simple features)",
          "description": "Direct issue → work → PR. Best for CRUD, simple features, well-understood domains. Minimal upfront time."
        }
      ]
    }
  ]
}
```

### Progressive Disclosure Benefits

1. **Reduced cognitive load:** 3 questions across 3 stages vs 10 questions at once
2. **Faster to first value:** Stage 1 takes 30 seconds, can start working
3. **Skip advanced features:** Users don't need to understand worktrees/git-spice initially
4. **Reconfigure easily:** Change settings later without starting over

### Timing Breakdown

| Stage | Time | Can Skip? | Blocking? |
|-------|------|-----------|-----------|
| Stage 1: Essential | 30s | No | Yes (need gh CLI) |
| Stage 2: Workflow | 1m | No | No (defaults to traditional) |
| Stage 3: Advanced | 1m | Yes | No (defaults to standard workflow) |
| Total | 2.5m | - | - |

**Previous setup time:** ~10-15 minutes (all questions upfront, overwhelming)
**New setup time:** ~2-3 minutes (progressive, can skip advanced)
