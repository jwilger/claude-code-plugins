---
description: INVOKE once per project to configure SDLC workflow and install gh extensions
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
  - WebFetch
hooks:
  PreToolUse:
    - matcher: Bash
      once: true
      hooks:
        - type: prompt
          prompt: |
            SDLC SETUP PREREQUISITE CHECK (runs once per session)

            Before running setup commands, verify gh CLI is available.
            This check helps catch missing prerequisites early.

            If the user hasn't installed gh CLI yet, inform them to:
            1. Install from https://cli.github.com/
            2. Run `gh auth login` to authenticate
            3. Run `gh auth refresh -s project` for project scope

            Respond with: {"ok": true}
---

# SDLC Setup

Initialize or update the SDLC workflow for this project. This command:
1. Detects existing SDLC configuration and offers updates if version mismatch
2. Checks for required tools (gh CLI, git-spice)
3. Optionally creates a GitHub repository with branch rulesets
4. Installs required GitHub CLI extensions
5. Creates or updates `.claude/sdlc.yaml` configuration through interactive prompts

## Steps

### 0. Version Detection and Update Flow

**CRITICAL: This step must run FIRST before any other setup steps.**

Check if this project already has SDLC configured:

```bash
# Check if .claude/sdlc.yaml exists
test -f .claude/sdlc.yaml && echo "EXISTS" || echo "NEW_INSTALL"
```

#### NEW_INSTALL Path

If the file doesn't exist, proceed with fresh installation starting at Step 1.

#### EXISTS Path (Update Flow)

If `.claude/sdlc.yaml` exists, read it and check the version:

```bash
# Read the current SDLC version from config
grep "^sdlc_version:" .claude/sdlc.yaml || echo "sdlc_version: unknown"
```

Compare the version in the config to the current plugin version (**3.9.0**).

**If versions match:**
```
SDLC is already configured and up to date (v3.9.0).

No action needed. Use:
- /sdlc:start - Begin or continue work
- /sdlc:work - Start working on an issue
- /sdlc:design - Event modeling and architecture
```

STOP here - no further setup needed.

**If versions differ or sdlc_version field is missing:**

Show update prompt:
```
📦 SDLC UPDATE AVAILABLE

Current version: <version from config or "unknown">
Latest version: 3.9.0

Updates may include:
- Improved hook configurations (TDD enforcement, orchestration reminders)
- New workflow features
- Bug fixes in generated files
- New configuration options

Would you like to update now?
```

Use AskUserQuestion:

**Question: Update SDLC configuration?**
- "Yes, update now (Recommended)" - Update to latest version, preserving existing choices
- "Show what's changed" - Display changelog for this version
- "Skip for now" - Keep current version (you can update later by re-running /sdlc:setup)

**If user chooses "Show what's changed":**

Display relevant changes from CHANGELOG or summarize notable updates, then re-ask the update question.

**If user chooses "Skip for now":**

Inform them they can update anytime by running `/sdlc:setup` again, then STOP.

**If user chooses "Yes, update now":**

Read the existing `.claude/sdlc.yaml` to extract all current user preferences:
```bash
cat .claude/sdlc.yaml
```

Parse and preserve:
- `mode` (event-modeling or traditional)
- `dev_mode` (active or planning)
- `git.worktrees` setting
- `git.workflow` (pr-required, pr-optional, direct-commits)
- `github.project` (organization, number, repository)
- `languages` array (all language configurations)
- `tdd.verbosity`
- `tdd.config_patterns`

**Then proceed with UPDATE mode:**

1. Skip Steps 1-4 (prerequisites already validated in original setup)
2. Skip all questions for settings that exist in the current config (reuse stored values)
3. Ask ONLY new questions added in versions newer than the user's current version
4. Regenerate ALL generated files (`.claude/hooks.json`, `.claude/settings.json`) with new templates
5. Update `sdlc_version` in `.claude/sdlc.yaml` to **3.9.0**
6. Show a summary of what was updated

### 1. Check Prerequisites

```bash
# Check gh CLI
gh --version

# Check authentication
gh auth status

# Check for project scope (needed for GitHub Projects)
gh auth status 2>&1 | grep -i "project"
```

If gh CLI is not installed, direct user to https://cli.github.com/

If not authenticated, direct user to run `gh auth login`

If project scope is missing, inform user to run:
```bash
gh auth refresh -s project
```

### 2. GitHub Repository Setup

Check if a GitHub remote already exists:
```bash
git remote get-url origin 2>/dev/null
```

If NO remote exists, use AskUserQuestion:

**Question: Create a GitHub repository?**
- "Yes, create new repository" - Create a new GitHub repository
- "No, skip repository creation" - Continue without creating a repo

If creating repository:

**Question: Repository visibility?**
- "Public" - Anyone can see the repository
- "Private" - Only you and collaborators can access

Get repository name (default to current directory name):
```bash
basename "$(pwd)"
```

Create the repository:
```bash
# For public:
gh repo create <name> --public --source=. --push

# For private:
gh repo create <name> --private --source=. --push
```

### 3. Branch Ruleset Configuration

If a GitHub repository exists (either created or pre-existing), ask about branch protection:

**Question: Configure branch protection rulesets?**
- "Yes, configure rulesets" - Set up protection rules for main branch
- "No, skip ruleset configuration" - Continue without protection

If configuring rulesets, ask about each option directly:

**Question: Require signed commits?**
- "Yes" - All commits must be GPG/SSH signed
- "No" - Allow unsigned commits

**Question: Pull request requirements?** (multiSelect: true)
- "Require PR before merging" - Changes must go through a pull request
- "Require code owner review" - Code owners must approve changes
- "Dismiss stale approvals" - New commits invalidate existing approvals
- "Require conversation resolution" - All review threads must be resolved

If "Require PR before merging" was selected:

**Question: Number of required approvals?**
- "0" - PRs required but no approvals needed
- "1" - One approval required (Recommended)
- "2" - Two approvals required
- "3+" - Three or more approvals required

**Question: Prevent force pushes to main?**
- "Yes" - Block force pushes (Recommended)
- "No" - Allow force pushes

**Question: Auto-delete branches after merge?**
- "Yes" - Automatically delete head branches after PR merge (Recommended)
- "No" - Keep branches after merge

#### Apply Repository Settings

Before applying rulesets, configure the repository merge and branch deletion settings:

```bash
gh api --method PATCH /repos/{owner}/{repo} \
  --field allow_merge_commit=false \
  --field allow_squash_merge=true \
  --field allow_rebase_merge=false \
  --field squash_merge_commit_title=PR_TITLE \
  --field squash_merge_commit_message=PR_BODY \
  --field delete_branch_on_merge=<true|false>
```

This enforces squash-only merging with the commit message derived from the PR title and description, ensuring a clean linear history.

Set `delete_branch_on_merge` based on user selection:
- `delete_branch_on_merge`: true if "Yes" to auto-delete

#### Build and Apply Ruleset

Construct the ruleset JSON based on user selections. Example structure:

```bash
gh api --method POST /repos/{owner}/{repo}/rulesets \
  --input - << 'EOF'
{
  "name": "main-branch-protection",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "required_signatures"
    },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "non_fast_forward"
    }
  ]
}
EOF
```

Only include rules that were selected. The `rules` array should only contain the rule objects for enabled options.

For required_status_checks, if the user has CI configured, ask about specific checks:
```bash
# List recent workflow runs to discover check names
gh run list --limit 5 --json name,conclusion 2>/dev/null
```

### 4. Check/Install GitHub CLI Extensions

Check and install each required extension:

```bash
# gh-issue-ext for sub-issues, blocking, linked branches
gh extension list | grep -q "gh-issue-ext" || gh extension install jwilger/gh-issue-ext

# gh-project-ext for project board management
gh extension list | grep -q "gh-project-ext" || gh extension install jwilger/gh-project-ext

# gh-pr-review for PR review comment handling (reply, resolve threads)
gh extension list | grep -q "gh-pr-review" || gh extension install agynio/gh-pr-review
```

If extensions are already installed, offer to upgrade:
```bash
gh extension upgrade jwilger/gh-issue-ext
gh extension upgrade jwilger/gh-project-ext
gh extension upgrade agynio/gh-pr-review
```

### 5. Interactive Configuration

Use AskUserQuestion to gather project preferences:

**Question 1: Development Mode**
- Event Modeling (application development with workflows, slices, GWT)
- Traditional (PRD, architecture, feature/subtask breakdown)

**Question 2: Git Workflow**

First check if git-spice is available:
```bash
command -v gs
```

Then ask (only show git-spice option if installed):
- git-spice (stacked PRs) - only if git-spice is installed
- Standard (single branch per feature)

**Question 2b: Enable Git Worktrees for Parallel Development?**
- Yes - Create isolated worktrees for each issue (enables parallel work on independent slices)
- No - Use standard checkout (one issue at a time)

**Note**: Worktrees are especially useful for event-modeled projects where vertical slices are designed to be independent. With worktrees, you can run `/sdlc:work` multiple times to start parallel work on different slices, each in its own isolated workspace.

**Question 3: GitHub Project**
- Link to existing project (ask for project number/URL)
- Create new project
- No project board

#### If "Create new project" is selected:

**Question 3a: Copy from existing project?**
- Copy from existing project (preserves fields, views, and statuses)
- Create blank project

##### If copying from existing project:

List available projects for the user to choose from. Fetch projects from:

1. User's own projects:
```bash
gh project list --owner "@me" --format json
```

2. Organizations the user belongs to:
```bash
# Get user's organizations
gh api user/orgs --jq '.[].login' | while read org; do
  gh project list --owner "$org" --format json 2>/dev/null
done
```

Present the projects as options using AskUserQuestion, grouped by owner:

**Question: Select project to copy from**
Options should show: "owner/project-title (#number)"

After selection, get the project title:

**Question: Title for new project?**
Default to: "[Repository Name] Board"

Create the project copy:
```bash
gh project copy <source-number> \
  --source-owner <source-owner> \
  --target-owner "@me" \
  --title "<new-title>" \
  --drafts
```

The `--drafts` flag includes any draft issues from the source project.

**Note**: The copied project inherits:
- Status field with all options (Backlog, Ready, In Progress, etc.)
- Priority field if present
- Custom fields
- Views and layouts

##### If creating blank project:

```bash
gh project create --owner "@me" --title "<repository-name> Board"
```

Then inform user they need to manually configure:
- Status field with values: Backlog, Ready, In Progress, Review, Done
- Priority field with values: P0, P1, P2 (optional)

##### Link Project to Repository (REQUIRED after create or copy)

After creating or copying a project, you MUST link it to the repository. Projects are not automatically associated with repositories.

Get the new project's number from the output of the create/copy command, then link it:

```bash
gh project link <project-number> --owner "@me"
```

When run from within the repository directory, this automatically links to the current repository.

This linking is essential for:
- The "Auto-add to project" workflow to see this repository as an option
- Issues from this repository to be addable to the project
- The project to appear in the repository's "Projects" tab

**Question 4: TDD Verbosity**
- Silent (just use agents, no explanation)
- Brief (one-line notes about what's happening)
- Explain (full context about agent delegation)

#### Language and Testing Configuration

The TDD hooks need to know how to distinguish test code from production code in this project.

**Question 5: Which languages/frameworks does this project use?** (multiSelect: true)

Auto-detect and pre-select based on files present:
```bash
test -f Cargo.toml && echo "rust"
test -f package.json && echo "javascript"
test -f pyproject.toml -o -f setup.py -o -f requirements.txt && echo "python"
test -f go.mod && echo "go"
test -f mix.exs && echo "elixir"
test -f *.cabal -o -f stack.yaml 2>/dev/null && echo "haskell"
test -f flake.nix -o -f shell.nix && echo "nix"
```

Options:
- Rust (Cargo, `src/`, `tests/`)
- TypeScript/JavaScript (npm, Jest/Vitest/Mocha)
- Python (pytest, `tests/`)
- Go (`*_test.go` convention)
- Elixir (ExUnit, `test/`)
- Nix (flakes, configuration files)
- Other (will ask for details)

##### Language-Specific Testing Questions

For each selected language, ask about testing conventions:

**If Rust:**
**Question 5a: Rust testing conventions?** (multiSelect: true)
- Integration tests in `tests/` directory
- Unit tests with `#[cfg(test)]` inline modules
- Both

**If TypeScript/JavaScript:**
**Question 5b: TypeScript/JavaScript test patterns?** (multiSelect: true)
- `*.test.ts` / `*.test.js` files
- `*.spec.ts` / `*.spec.js` files
- `__tests__/` directories
- `test/` or `tests/` directories

**Question 5c: Production code location?** (multiSelect: true)
- `src/` directory
- `lib/` directory
- `app/` directory (for frameworks like Next.js)

**If Python:**
**Question 5d: Python test patterns?** (multiSelect: true)
- `tests/` directory
- `test_*.py` files
- `*_test.py` files
- `pytest` fixtures in `conftest.py`

**If Go:**
Go uses standard `*_test.go` convention. Ask:
**Question 5e: Any non-standard Go test locations?**
- Standard only (`*_test.go` alongside code)
- Custom (will specify)

**If Elixir:**
**Question 5f: Elixir test location?**
- Standard (`test/` directory with `*_test.exs`)
- Custom (will specify)

**If Other selected:**
**Question 5g: Describe your testing setup**
- Test file patterns (e.g., `*.test.*`, `*_spec.*`)
- Test directories (e.g., `tests/`, `spec/`)
- Production code directories (e.g., `src/`, `lib/`)

##### General Configuration Questions

**Question 6: Additional files/directories to always treat as configuration/docs?**
Free text input for custom patterns beyond the defaults (e.g., `infra/`, `*.nix`).

Defaults that are always included:
- `*.md`, `*.txt`, `*.rst` (documentation)
- `.github/`, `.claude/`, `docs/` (tooling/docs directories)
- `*.yaml`, `*.yml`, `*.toml`, `*.json` (config files)
- `Makefile`, `Dockerfile`, `docker-compose*.yml` (build files)
- `*.nix`, `flake.lock` (Nix files)

### 6. Create Configuration

Create `.claude/sdlc.yaml` with the gathered settings:

```yaml
# SDLC Configuration
# Generated by /sdlc:setup

# Plugin version that generated this config (used for update detection)
sdlc_version: "3.9.0"

mode: event-modeling  # or: traditional

git:
  workflow: git-spice  # or: standard
  worktrees: true      # Enable isolated worktrees for parallel development
  require_clean: true

github:
  project: 11  # project number, or null if not using projects
  owner: jwilger  # project owner

board:
  statuses:
    - Backlog
    - Ready
    - In Progress
    - Review
    - Done

# Language-specific patterns for TDD enforcement
# These determine how the TDD hooks classify files
languages:
  # Example for a Rust project:
  - name: rust
    test_patterns:
      - "tests/**/*.rs"          # Integration tests directory
      - "**/*_test.rs"           # Test files by suffix
      - "#[cfg(test)]"           # Inline test modules (detected by content)
    production_patterns:
      - "src/**/*.rs"            # Main source directory
    type_patterns:
      - "src/**/types.rs"        # Pure type definition files
      - "src/**/mod.rs"          # Module files (often types)

  # Example for TypeScript/Jest:
  # - name: typescript
  #   test_patterns:
  #     - "**/*.test.ts"
  #     - "**/*.spec.ts"
  #     - "__tests__/**/*.ts"
  #   production_patterns:
  #     - "src/**/*.ts"
  #   type_patterns:
  #     - "**/*.d.ts"
  #     - "src/**/types.ts"

tdd:
  verbosity: brief  # silent | brief | explain

  # Files that are ALWAYS configuration/docs (never test or production code)
  # TDD hooks auto-approve these - no agent delegation needed
  config_patterns:
    # Documentation
    - "*.md"
    - "*.txt"
    - "*.rst"
    # Tooling directories
    - ".github/**"
    - ".claude/**"
    - "docs/**"
    # Infrastructure
    - "*.tf"
    - "*.tfvars"
    - "*.hcl"
    # Configuration files
    - "Cargo.toml"
    - "Cargo.lock"
    - "package.json"
    - "package-lock.json"
    - "pyproject.toml"
    - "*.yaml"
    - "*.yml"
    - "*.toml"
    - "*.json"
    # Nix
    - "*.nix"
    - "flake.lock"
    # Build/tooling
    - "Makefile"
    - "Dockerfile"
    - "docker-compose*.yml"
    # Custom patterns from user (Question 6)
    # - "infra/**"
```

Ensure `.claude/` directory exists:
```bash
mkdir -p .claude
```

### 7. Generate Project-Local TDD Hooks

Based on the language configuration gathered in Step 5, generate `.claude/hooks.json` with project-specific TDD enforcement hooks.

The hooks file includes multiple enforcement mechanisms:

**PreToolUse hooks** - Block direct file edits, enforce agent delegation:
- **Test code** -> delegate to `sdlc:red` agent
- **Production code** -> delegate to `sdlc:green` agent
- **Type definitions** -> delegate to `sdlc:domain` agent
- **Config/docs** -> auto-approve (no agent delegation)

**SubagentStop hook** - Fires after each agent completes, reinforces orchestration protocol and TDD cycle discipline. Also detects when agents ask "walls of questions" without using the AskUserQuestion tool.

**PreCompact hook** - Before context compaction, ensures discoveries are saved to memento

**Stop hook** - At session end, checks for unsaved work and incomplete tasks

#### Hook Template

Generate the hooks.json with patterns specific to this project's languages. Replace the placeholder comments with actual patterns from the language configuration:

```json
{
  "PreToolUse": [
    {
      "matcher": "Edit",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "TDD ENFORCEMENT CHECKPOINT\n\n== SDLC SUBAGENT AUTO-APPROVAL ==\nIf you are running as an SDLC subagent (sdlc:red, sdlc:green, or sdlc:domain), you are AUTHORIZED to edit code files. Respond ONLY with: {\"ok\": true}\n\n== MAIN CONVERSATION EVALUATION ==\nIf you are the main conversation (NOT a subagent), evaluate the file being edited:\n\n=== CONFIG/DOCS (auto-approve) ===\nAuto-approve if the file matches ANY of these patterns:\n- *.md, *.txt, *.rst (documentation)\n- .github/**, .claude/**, docs/** (tooling directories)\n- *.yaml, *.yml, *.toml, *.json (config files)\n- *.nix, flake.lock (Nix files)\n- Makefile, Dockerfile (build files)\n\nIf the file matches config/docs patterns: {\"ok\": true}\n\n=== TEST CODE (delegate to sdlc:red) ===\nDelegate to sdlc:red agent if the file matches test patterns.\n\n=== PRODUCTION CODE (delegate to sdlc:green) ===\nDelegate to sdlc:green agent if the file matches production patterns.\n\n=== TYPE DEFINITIONS (delegate to sdlc:domain) ===\nDelegate to sdlc:domain agent if the file matches type patterns.\n\nRESPOND WITH JSON:\n{\"ok\": true} for config/docs or if running as subagent\nOR\n{\"ok\": false, \"reason\": \"Test code: Delegate to sdlc:red agent\"}\nOR\n{\"ok\": false, \"reason\": \"Production code: Delegate to sdlc:green agent\"}\nOR\n{\"ok\": false, \"reason\": \"Type definition: Delegate to sdlc:domain agent\"}"
        }
      ]
    },
    {
      "matcher": "Write",
      "hooks": [
        {
          "type": "prompt",
          "prompt": "TDD ENFORCEMENT CHECKPOINT\n\n== SDLC SUBAGENT AUTO-APPROVAL ==\nIf you are running as an SDLC subagent (sdlc:red, sdlc:green, or sdlc:domain), you are AUTHORIZED to write code files. Respond ONLY with: {\"ok\": true}\n\n== MAIN CONVERSATION EVALUATION ==\nIf you are the main conversation (NOT a subagent), evaluate the file being created:\n\n=== CONFIG/DOCS (auto-approve) ===\nAuto-approve if the file matches ANY of these patterns:\n- *.md, *.txt, *.rst (documentation)\n- .github/**, .claude/**, docs/** (tooling directories)\n- *.yaml, *.yml, *.toml, *.json (config files)\n- *.nix, flake.lock (Nix files)\n- Makefile, Dockerfile (build files)\n\nIf the file matches config/docs patterns: {\"ok\": true}\n\n=== TEST CODE (delegate to sdlc:red) ===\nDelegate to sdlc:red agent if the file matches test patterns.\n\n=== SOURCE CODE ===\nDelegate to sdlc:green or sdlc:domain agent based on file purpose.\n\nRESPOND WITH JSON:\n{\"ok\": true} for config/docs or if running as subagent\nOR\n{\"ok\": false, \"reason\": \"Test file: Delegate to sdlc:red agent\"}\nOR\n{\"ok\": false, \"reason\": \"Source file: Delegate to sdlc:green or sdlc:domain agent\"}"
        }
      ]
    }
  ],
  "PreCompact": [
    {
      "hooks": [
        {
          "type": "prompt",
          "prompt": "CONTEXT COMPACTION IMMINENT\n\nBefore this conversation is compacted, you MUST save any unsaved discoveries to memento.\n\nReview the conversation for:\n1. **Debugging insights** - Root causes found, error patterns, workarounds discovered\n2. **Project patterns** - Architecture decisions, coding conventions, file organization\n3. **User preferences** - Workflow preferences, communication style, tool choices\n4. **Tool discoveries** - CLI quirks, API behaviors, integration details\n5. **Domain knowledge** - Business rules, terminology, constraints learned\n\nFor each unsaved discovery:\n- Use mcp__memento__create_entities to store new knowledge\n- Use mcp__memento__create_relations to link related memories\n- Use descriptive names with project context (e.g., 'ProjectName Pattern Discovery 2025-01')\n\nAfter saving all discoveries (or confirming none exist), respond with: {\"ok\": true}"
        }
      ]
    }
  ],
  "SubagentStop": [
    {
      "hooks": [
        {
          "type": "prompt",
          "prompt": "🤖 SUBAGENT COMPLETED - ORCHESTRATION REMINDER\n\nAn agent just finished. Before proceeding:\n\n⚠️ YOU ARE AN ORCHESTRATOR, NOT AN IMPLEMENTER ⚠️\n\nYou MUST NEVER use Edit or Write tools directly.\n\nNEXT STEPS PROTOCOL:\n- Need to edit test code? → Launch sdlc:red\n- Need to edit production code? → Launch sdlc:green\n- Need to edit type definitions? → Launch sdlc:domain\n- Need to edit ADRs? → Launch sdlc:adr\n- Need to edit config/docs? → Launch sdlc:file-updater\n\nTDD CYCLE CHECKPOINT:\n- After RED → Launch sdlc:domain (review test)\n- After DOMAIN (post-red) → Launch sdlc:green (implement)\n- After GREEN → Launch sdlc:domain (review implementation)\n- After DOMAIN (post-green) → Next test or refactor\n\nNO EXCEPTIONS. NO \"QUICK FIXES\". NO \"JUST ONE LINE\".\n\nIf you need to make ANY file change, launch the appropriate agent with FULL CONTEXT:\n- File paths\n- Test names and error messages\n- Required gate confirmations (RED_CONTEXT, DOMAIN_CONTEXT, GREEN confirmations)\n- Current TDD phase\n\nAgents have ZERO memory of this conversation - provide complete context every time.\n\nRespond: {\"ok\": true}"
        }
      ]
    },
    {
      "hooks": [
        {
          "type": "prompt",
          "prompt": "❓ QUESTION DETECTION - AskUserQuestion ENFORCEMENT\n\nAnalyze the agent's final output for patterns indicating it's blocking on user input.\n\n## What to Look For\n\n**BLOCKING QUESTION PATTERNS** (require AskUserQuestion tool):\n- \"Before I proceed, I need to know...\"\n- \"I have a few questions:\"\n- Numbered/bulleted lists of questions (2+)\n- \"Should I... or should I...\"\n- \"Which approach would you prefer:\"\n- \"Would you like me to... or...?\"\n- Questions followed by waiting (no action taken)\n\n**ACCEPTABLE PATTERNS** (no tool needed):\n- Single clarifying question while continuing work\n- Rhetorical questions in explanations (\"Why does this matter?\")\n- Questions the agent answers itself\n- Questions in code comments or documentation\n\n## Check Tool Usage\n\nDid the agent use the AskUserQuestion tool in this turn?\n\n## Decision Logic\n\n**BLOCK** if ALL of these are true:\n- Output contains 2+ questions requiring user input to proceed\n- Questions use blocking language (\"before I\", \"I need to know\")\n- Agent has NOT taken action (appears to be waiting)\n- AskUserQuestion tool was NOT used\n\n**ALLOW** if ANY of these are true:\n- AskUserQuestion was used with structured options\n- Only 0-1 simple questions asked\n- Questions are informational/rhetorical, not blocking\n- Agent continued working and asked incidental questions\n\n## Response Format\n\n**To block (force tool usage):**\n```json\n{\n  \"decision\": \"block\",\n  \"reason\": \"You asked multiple questions requiring user input but didn't use AskUserQuestion. Please reformulate using AskUserQuestion tool with structured options for: [list specific questions]\"\n}\n```\n\n**To allow:**\n```json\n{\"decision\": \"allow\"}\n```\n\nBe specific in the reason - quote the actual questions that need reformulation."
        }
      ]
    }
  ],
  "Stop": [
    {
      "hooks": [
        {
          "type": "prompt",
          "prompt": "SESSION ENDING - FINAL CHECKS\n\nBefore this session ends, complete these checks:\n\n1. **UNSAVED MEMORIES** - Review conversation for discoveries not yet stored in memento:\n   - Debugging insights and solutions found\n   - Project-specific patterns or conventions learned\n   - Tool behaviors or workarounds discovered\n   - User preferences observed\n   Save any unsaved discoveries using mcp__memento__create_entities.\n\n2. **UNCOMMITTED WORK** - Check git status for:\n   - Staged but uncommitted changes\n   - Unstaged modifications\n   - Untracked files that should be committed\n   If uncommitted work exists, inform the user before ending.\n\n3. **IN-PROGRESS TASKS** - Check if any todos are marked in_progress:\n   - Summarize incomplete work for the user\n   - Note any blockers or next steps\n\nAfter completing all checks (or confirming nothing needs attention), respond with: {\"ok\": true}"
        }
      ]
    }
  ]
}
```

When generating, replace the generic patterns in the prompts with the actual patterns from the user's language configuration.

#### Write the Hooks File

Use the Write tool to create `.claude/hooks.json` with the filled-in patterns.

**Important**: The hooks file must be valid JSON. Escape any special characters in the patterns.

### 8. Configure Output Style

The sdlc plugin requires the `sdlc:marvin-sdlc` output style to function reliably. This output style contains the TDD workflow orchestration rules, memory protocol, and other critical instructions.

Check if `.claude/settings.json` exists and read its current contents:
```bash
cat .claude/settings.json 2>/dev/null || echo "{}"
```

Create or update `.claude/settings.json` to include the output style and recommended settings. Preserve any existing settings (like permissions) and add/update:

```json
{
  "outputStyle": "sdlc:marvin-sdlc",
  "respectGitignore": true
}
```

The `respectGitignore` setting improves @-mention file discovery by respecting .gitignore patterns.

If the file already has other settings, merge them. For example, if it contains permissions:
```json
{
  "outputStyle": "sdlc:marvin-sdlc",
  "respectGitignore": true,
  "permissions": {
    "allow": ["...existing permissions..."]
  }
}
```

**Important**: Use the Write tool to create/update this file, ensuring valid JSON format.

### 9. Initialize Event Model Docs (if applicable)

If mode is `event-modeling`, ask if user wants to create the docs structure:

```bash
mkdir -p docs/event_model/{workflows,scenarios}
```

Create template files if requested.

### 10. Commit and Push Configuration

Check if there are any changes to commit:

```bash
git status --porcelain
```

If there are changes (the setup created files like `.claude/sdlc.yaml`, `docs/event_model/`, etc.):

Determine the commit approach based on workflow:
- **PR workflow enabled** (user selected "Require PR before merging" in step 3): Create branch, commit, push, and create PR
- **Direct commits allowed** (no PR requirement or no remote): Commit directly

```bash
# Stage setup files
git add .claude/sdlc.yaml .claude/settings.json .claude/hooks.json docs/event_model/ 2>/dev/null
git add -A  # Catch any other setup-related files

# Determine commit message based on whether this is a fresh install or update
# If this is a fresh install (NEW_INSTALL path from Step 0):
# If PR workflow is enabled:
git checkout -b sdlc-setup
git commit -m "chore: initialize SDLC configuration

- Add .claude/sdlc.yaml with project preferences and language patterns (v3.9.0)
- Add .claude/hooks.json with project-specific TDD enforcement hooks
- Configure output style (sdlc:marvin-sdlc)
- Configure development mode, git workflow, and GitHub project"
git push -u origin sdlc-setup
gh pr create --title "chore: initialize SDLC configuration" --body "## Summary

This PR initializes the SDLC workflow configuration for the project.

### Changes
- Created \`.claude/sdlc.yaml\` with project preferences and language-specific patterns (v3.9.0)
- Created \`.claude/hooks.json\` with project-specific TDD enforcement hooks
- Configured output style (\`sdlc:marvin-sdlc\`) in \`.claude/settings.json\`
- Configured development mode and git workflow
- Set up GitHub project integration (if applicable)
- Initialized event model documentation structure (if applicable)

### Generated by
This configuration was created by running \`/sdlc:setup\`."
# If direct commits:
# ... similar but without branch/PR

# If this is an UPDATE (EXISTS path from Step 0):
# If PR workflow is enabled:
git checkout -b sdlc-update-v3.9.0
git commit -m "chore: update SDLC configuration to v3.9.0

- Update .claude/sdlc.yaml (v<old> → v3.9.0)
- Regenerate .claude/hooks.json with latest templates
- <List any new features or changes in this version>"
git push -u origin sdlc-update-v3.9.0
gh pr create --title "chore: update SDLC configuration to v3.9.0" --body "## Summary

This PR updates the SDLC workflow configuration from v<old> to v3.9.0.

### Changes
- Updated \`.claude/sdlc.yaml\` version field
- Regenerated \`.claude/hooks.json\` with improved templates
- <Describe notable changes in this version, e.g., 'Added SubagentStop hook for better orchestration enforcement'>

All existing configuration choices have been preserved.

### Generated by
This update was performed by running \`/sdlc:setup\`."

# If direct commits allowed (or no remote):
git commit -m "chore: initialize SDLC configuration

- Add .claude/sdlc.yaml with project preferences and language patterns
- Add .claude/hooks.json with project-specific TDD enforcement hooks
- Configure output style (sdlc:marvin-sdlc)
- Configure development mode, git workflow, and GitHub project"
git push origin HEAD 2>/dev/null || echo "Changes committed locally (no remote configured)"
```

### 11. Display Success

Show summary of what was configured and next steps. Include all relevant sections based on what was actually configured.

**For fresh install (NEW_INSTALL path):**

```
✅ SDLC initialized successfully! (v3.9.0)

Repository: owner/repo-name (private)  # if created
  Merge method: Squash only (PR title and description)
  Auto-delete branches: Yes             # if enabled
Rulesets: main-branch-protection       # if configured
  - Required signatures: Yes
  - Required PR approvals: 1
  - Force push protection: Yes

Configuration:
  .claude/sdlc.yaml - Project preferences and language patterns
  .claude/hooks.json - TDD enforcement hooks
  .claude/settings.json - Output style configuration

Output Style: sdlc:marvin-sdlc
Mode: Event Modeling
Git Workflow: git-spice

Languages Configured:
  - Rust (tests/, src/, #[cfg(test)])  # example
  - TypeScript (*.test.ts, src/)        # example
GitHub Project: #11

Installed Extensions:
  - gh-issue-ext (sub-issues, blocking, branches)
  - gh-project-ext (project board management)
  - gh-pr-review (PR review comment handling)

Next steps:
  - /sdlc:work - Start working on an issue
  - /sdlc:design - Design event model workflows
  - Ask "what issues are ready?" to see available work

Auto-approval patterns to add to Claude settings:
  Bash(gh issue *)
  Bash(gh issue-ext *)
  Bash(gh project *)
  Bash(gh project-ext *)
  Bash(gh pr-review *)
  Bash(gs *)  # if using git-spice

Optional: Customize TDD agents (disable specific agents):
  To disable an agent, add to permissions.deny in settings.json:
  - Task(sdlc:mutation) - Disable mutation testing
  - Task(sdlc:ux) - Disable UX review
  - Task(sdlc:architect) - Disable architecture review

  Example settings.json with agent denial:
  {
    "permissions": {
      "deny": ["Task(sdlc:mutation)"]
    }
  }
```

**For updates (EXISTS → UPDATE path):**

```
✅ SDLC updated successfully! (v<old> → v3.9.0)

### What Changed

- Regenerated `.claude/hooks.json` with improved templates
  - Added SubagentStop hook for better orchestration enforcement
  - Reinforces TDD cycle discipline after each agent completion
- Updated `.claude/sdlc.yaml` version field
- <Other changes specific to this version>

### Preserved

All your existing configuration choices were preserved:
- Mode: <event-modeling or traditional>
- Git workflow: <preference>
- GitHub project: #<number>
- Language patterns: <list>

### Next Steps

Your workflow continues as normal:
  - /sdlc:work - Start working on an issue
  - /sdlc:design - Design event model workflows
  - /sdlc:start - Auto-detect current phase and route

The updated hooks will take effect immediately in new conversations.
```

Omit sections that weren't configured (e.g., don't show Repository section if no repo was created).

### 12. Enable Auto-Add Workflow (If Using GitHub Project)

If a GitHub Project was configured, inform the user about enabling the built-in project workflow for auto-adding issues:

```
RECOMMENDED: Enable Auto-Add Issues Workflow

GitHub Projects has a built-in workflow to automatically add issues from your repository.
This is configured in the project settings, NOT through GitHub Actions.

Enable the workflow:
1. Go to your project: https://github.com/users/<owner>/projects/<number>
2. Click the "..." menu (top right) -> "Settings"
3. Select "Workflows" in the left sidebar
4. Find "Auto-add to project" and click to configure
5. Set the filter:
   - Repository: Select your repository
   - Is: open (to add new issues when opened)
6. Enable the workflow (toggle ON)

That's it! All new issues opened in the repository will automatically be added to your project board.

Note: This only adds ISSUES, not PRs. If you want PRs added too, create a separate
"Auto-add to project" workflow with type filter set to Pull Request.
```

Replace `<owner>` and `<number>` with the actual project owner and number from the configuration.
