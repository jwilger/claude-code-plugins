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
```bash
# Get repository name
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# Configure repository settings
gh api -X PATCH "repos/$REPO" \
  -f delete_branch_on_merge=true \
  -f allow_squash_merge=true \
  -f allow_merge_commit=true \
  -f allow_rebase_merge=true

# Create PR template
mkdir -p .github
cat > .github/pull_request_template.md <<'EOF'
## Summary
<!-- Brief description of changes -->

## Test Plan
<!-- How to verify these changes work -->

## Related Issues
<!-- Link to related issues/tickets -->
EOF

# Note: Branch protection rulesets require GitHub API rulesets endpoint
# and admin permissions on the repository
```

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
  delete_branch_on_merge: true
  allow_squash_merge: true
  allow_merge_commit: true
  allow_rebase_merge: true

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
