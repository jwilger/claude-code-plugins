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

The current plugin version is **5.0.0**. Compare what you found in the config:

**If the config shows `sdlc_version: "5.0.0"` (versions match):**
```
SDLC is already configured and up to date (v5.0.0).

No action needed. Use:
- /sdlc:start - Begin or continue work
- /sdlc:work - Start working on an issue
- /sdlc:design - Event modeling and architecture
```

STOP here - no further setup needed.

**If the config shows any other version, or sdlc_version field is missing (versions differ):**

Show update prompt:
```
📦 SDLC UPDATE AVAILABLE

Current version: <version from config or "unknown">
Latest version: 5.0.0

Updates may include:
- Fixed hooks configuration (hooks now properly integrated into settings.json)
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

**Then proceed with UPDATE mode:**

1. Skip Steps 1-4 (prerequisites already validated in original setup)
2. Skip all questions for settings that exist in the current config (reuse stored values)
3. Ask ONLY new questions added in versions newer than the user's current version
4. Regenerate `.claude/settings.json` with hooks embedded and new templates
5. Remove legacy `.claude/hooks.json` file if it exists (hooks are now in settings.json)
6. Update `sdlc_version` in `.claude/sdlc.yaml` to **5.0.0**
7. Show a summary of what was updated

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

### 4. Check/Install Required Tools

#### dot CLI

Check if dot is installed:

```bash
command -v dot || echo "NOT_INSTALLED"
```

If not installed, direct user to install from https://github.com/ajeetdsouza/dot

After installation, verify version (minimum 0.6.4 required):
```bash
dot --version
```

#### GitHub CLI Extension

Check and install required extension:

```bash
# gh-pr-review for PR review comment handling (reply, resolve threads)
gh extension list | grep -q "gh-pr-review" || gh extension install agynio/gh-pr-review
```

If extension is already installed, offer to upgrade:
```bash
gh extension upgrade agynio/gh-pr-review
```

**Note**: Previous versions used `gh-issue-ext` and `gh-project-ext` for GitHub Issues/Projects integration. These are no longer needed as v5.0.0 uses `dot` CLI for local task management.

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

**Question 3: dot Task Management Setup**

Initialize dot for this project:

```bash
# Check if .dots/ already exists
test -d .dots && echo "ALREADY_INITIALIZED" || echo "NEEDS_INIT"
```

If NEEDS_INIT, prompt for task prefix:

**Question 3a: Task prefix for this project?**

Default to repository name:
```bash
basename "$(pwd)"
```

Explain: The prefix will be used in task IDs (e.g., `myproject-add-login-abc123`). It should be short (1-2 words), lowercase with no spaces.

Initialize dot with the chosen prefix:

```bash
# Initialize .dots directory
dot init

# Configure the prefix in .dots/config
# The dot CLI should handle this through interactive prompts or config file
```

**Note on GitHub Integration**: Previous versions (v4.x) used GitHub Issues and Projects for task management. Version 5.0.0 uses local `dot` CLI for faster, offline-capable task management. GitHub integration is now limited to pull requests and code review only.

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
sdlc_version: "5.0.0"

mode: event-modeling  # or: traditional

# Task management (dot CLI)
tasks:
  prefix: myproject  # Task ID prefix (e.g., myproject-add-login-abc123)

git:
  workflow: git-spice  # or: standard
  worktrees: true      # Enable isolated worktrees for parallel development
  require_clean: true

# GitHub configuration (PR/review only, not task management)
github:
  owner: jwilger      # Repository owner (for PR creation)
  repository: myrepo  # Repository name

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

# TDD workflow state (managed by hooks)
tdd_state:
  current_phase: null  # null | "red" | "domain_after_red" | "green" | "domain_after_green"
  domain_review_required: false
  last_agent: null
  current_test: null
  test_file: null
  test_status: null  # null | "failing" | "passing"
  last_updated: null

# Event modeling workflow state (only used in event-modeling mode)
event_modeling_state:
  stage: null  # null | "discovery" | "workflows" | "slices" | "architecture"
  discovery_complete: false
  workflows_count: 0
  ready_for_architecture: false
```

Ensure `.claude/` directory exists:
```bash
mkdir -p .claude
```

### 7. Create Hook Shell Scripts

**IMPORTANT**: Prompt-based hooks (`type: "prompt"`) are only officially supported for `Stop` and `SubagentStop` hooks. PreToolUse, SessionStart, and PreCompact hooks MUST use `type: "command"` with shell scripts.

Create the `.claude/hooks/` directory and hook scripts:

```bash
mkdir -p .claude/hooks
```

#### 7a. File Edit Authorization Script

Create `.claude/hooks/file-edit-auth.sh`:

```bash
#!/usr/bin/env bash
#
# file-edit-auth.sh - PreToolUse hook for Edit/Write authorization
#
# Simple subagent detection: if transcript_path contains "/subagents/",
# we're in a subagent context and file operations are allowed.
# Otherwise, we're the main orchestrator and must delegate.

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract transcript_path from input
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

if [[ -z "$TRANSCRIPT_PATH" ]]; then
    # Can't determine context without transcript - deny to be safe
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Cannot determine context - transcript_path not available. Delegate file operations to appropriate subagent."
  }
}
EOF
    exit 0
fi

# Simple check: if transcript_path contains "/subagents/", we're in a subagent
if [[ "$TRANSCRIPT_PATH" == *"/subagents/"* ]]; then
    # We're a subagent - allow Edit/Write
    # (Agent instructions handle file type restrictions)
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Subagent context - file operations allowed"
  }
}
EOF
else
    # Main orchestrator - deny and require delegation
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "File modifications must be delegated to subagents. Use Task tool to launch: sdlc:red (tests), sdlc:green (production code), sdlc:domain (type definitions), sdlc:adr (ADRs), sdlc:file-updater (config/docs/scripts), or other appropriate agents."
  }
}
EOF
fi

exit 0
```

Make executable:
```bash
chmod +x .claude/hooks/file-edit-auth.sh
```

#### 7b. Session Start Script

Create `.claude/hooks/session-start.sh`:

```bash
#!/usr/bin/env bash
#
# session-start.sh - SessionStart hook for memory protocol reminder

set -euo pipefail

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "MEMORY PROTOCOL REMINDER: Before diving into work, consider checking memento for relevant context. Memento may have useful information about: Debugging (similar issues solved before?), Architecture (patterns or decisions documented?), Tools (known quirks, workarounds, or configurations?), Conventions (project-specific patterns or preferences?). To search: Use mcp__memento__semantic_search with your task description as the query. This is a gentle reminder - proceed without searching if the work is novel or memento isn't available."
  }
}
EOF
exit 0
```

Make executable:
```bash
chmod +x .claude/hooks/session-start.sh
```

#### 7c. Pre-Compact Script

Create `.claude/hooks/pre-compact.sh`:

```bash
#!/usr/bin/env bash
#
# pre-compact.sh - PreCompact hook to remind about saving discoveries

set -euo pipefail

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreCompact",
    "additionalContext": "CONTEXT COMPACTION IMMINENT: Before this conversation is compacted, save any unsaved discoveries to memento. Review for: debugging insights, project patterns, user preferences, tool discoveries, domain knowledge. Use mcp__memento__create_entities to store new knowledge."
  }
}
EOF
exit 0
```

Make executable:
```bash
chmod +x .claude/hooks/pre-compact.sh
```

### 8. Prepare TDD Hooks Structure

Based on the language configuration gathered in Step 5, prepare the hooks configuration structure that will be embedded in `.claude/settings.json` (Step 9).

The hooks configuration includes multiple enforcement mechanisms:

**PreToolUse hooks** (command-based) - Enforce agent delegation for ALL file operations:
- Only authorized subagents (`sdlc:red`, `sdlc:green`, `sdlc:domain`, `sdlc:adr`, `sdlc:file-updater`) can edit/write files
- Main orchestrator is BLOCKED from direct file operations
- Shell script parses transcript to determine subagent context

**SubagentStop hook** (prompt-based) - Fires after each agent completes, reinforces orchestration protocol and TDD cycle discipline. Also detects when agents ask "walls of questions" without using the AskUserQuestion tool.

**SessionStart hook** (command-based) - Reminds to check memento for relevant context

**PreCompact hook** (command-based) - Before context compaction, reminds to save discoveries

**Stop hook** (prompt-based) - At session end, checks for unsaved work and incomplete tasks

#### Hook Structure Template

```json
{
  "PreToolUse": [
    {
      "matcher": "Edit(*)",
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/file-edit-auth.sh"
        }
      ]
    },
    {
      "matcher": "Write(*)",
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/file-edit-auth.sh"
        }
      ]
    }
  ],
  "SessionStart": [
    {
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/session-start.sh"
        }
      ]
    }
  ],
  "PreCompact": [
    {
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/pre-compact.sh"
        }
      ]
    }
  ],
  "SubagentStop": [
    {
      "hooks": [
        {
          "type": "prompt",
          "prompt": "🔷 DOMAIN REVIEW CHECKPOINT (MANDATORY)\n\nDetect which agent just completed and enforce domain review requirements.\n\n## Check Agent Identity\n\nExamine the conversation to determine which agent just finished. Look for:\n- Agent invocation patterns (Task tool with subagent_type)\n- Agent self-identification in output\n- File modifications patterns (test files = red, production = green)\n\n## Enforcement Rules\n\n**If sdlc:red just completed:**\n- A failing test was just written\n- Domain review is MANDATORY before proceeding\n- Next action MUST be: Launch sdlc:domain with DOMAIN_CONTEXT: AFTER_RED\n- Block if orchestrator tries to skip directly to GREEN\n\n**If sdlc:green just completed:**\n- Production code was just implemented\n- Domain review is MANDATORY before proceeding  \n- Next action MUST be: Launch sdlc:domain with DOMAIN_CONTEXT: AFTER_GREEN\n- Block if orchestrator tries to write another test without review\n\n**If sdlc:domain just completed:**\n- Domain review passed, workflow may continue\n- Allow orchestrator to proceed to next phase\n\n**If any other agent completed:**\n- Allow (domain review not required)\n\n## Response Format\n\n**After RED or GREEN (domain review required):**\n```json\n{\n  \"ok\": false,\n  \"reason\": \"Domain review is MANDATORY after {agent} phase. You must launch sdlc:domain with appropriate DOMAIN_CONTEXT before proceeding. This is NOT optional - there are NO valid reasons to skip domain review.\"\n}\n```\n\n**After DOMAIN or other agents:**\n```json\n{\"ok\": true}\n```\n\nThis enforces the TDD cycle discipline: RED → DOMAIN → GREEN → DOMAIN."
        }
      ]
    },
    {
      "hooks": [
        {
          "type": "prompt",
          "prompt": "🤖 SUBAGENT COMPLETED - ORCHESTRATION REMINDER\n\nAn agent just finished. Before proceeding:\n\n⚠️ YOU ARE AN ORCHESTRATOR, NOT AN IMPLEMENTER ⚠️\n\nYou MUST NEVER use Edit or Write tools directly.\n\nNEXT STEPS PROTOCOL:\n- Need to edit test code? → Launch sdlc:red\n- Need to edit production code? → Launch sdlc:green\n- Need to edit type definitions? → Launch sdlc:domain\n- Need to edit ADRs/ARCHITECTURE.md? → Launch sdlc:adr or sdlc:design-facilitator\n- Need to edit event model docs? → Launch sdlc:gwt, sdlc:workflow-designer, sdlc:model-checker, or sdlc:discovery\n- Need to edit config/docs/scripts? → Launch sdlc:file-updater\n\nTDD CYCLE CHECKPOINT:\n- After RED → Launch sdlc:domain (review test)\n- After DOMAIN (post-red) → Launch sdlc:green (implement)\n- After GREEN → Launch sdlc:domain (review implementation)\n- After DOMAIN (post-green) → Next test or refactor\n\nNO EXCEPTIONS. NO \"QUICK FIXES\". NO \"JUST ONE LINE\".\n\nIf you need to make ANY file change, launch the appropriate agent with FULL CONTEXT:\n- File paths\n- Test names and error messages\n- Required gate confirmations (RED_CONTEXT, DOMAIN_CONTEXT, GREEN confirmations)\n- Current TDD phase\n\nAgents have ZERO memory of this conversation - provide complete context every time.\n\nRespond with JSON only: {\"ok\": true}"
        }
      ]
    },
    {
      "hooks": [
        {
          "type": "prompt",
          "prompt": "❓ QUESTION DETECTION - AskUserQuestion ENFORCEMENT\n\nAnalyze the agent's final output for patterns indicating it's blocking on user input.\n\n## What to Look For\n\n**BLOCKING QUESTION PATTERNS** (require AskUserQuestion tool):\n- \"Before I proceed, I need to know...\"\n- \"I have a few questions:\"\n- Numbered/bulleted lists of questions (2+)\n- \"Should I... or should I...\"\n- \"Which approach would you prefer:\"\n- \"Would you like me to... or...?\"\n- Questions followed by waiting (no action taken)\n\n**ACCEPTABLE PATTERNS** (no tool needed):\n- Single clarifying question while continuing work\n- Rhetorical questions in explanations (\"Why does this matter?\")\n- Questions the agent answers itself\n- Questions in code comments or documentation\n\n## Check Tool Usage\n\nDid the agent use the AskUserQuestion tool in this turn?\n\n## Decision Logic\n\n**BLOCK** if ALL of these are true:\n- Output contains 2+ questions requiring user input to proceed\n- Questions use blocking language (\"before I\", \"I need to know\")\n- Agent has NOT taken action (appears to be waiting)\n- AskUserQuestion tool was NOT used\n\n**ALLOW** if ANY of these are true:\n- AskUserQuestion was used with structured options\n- Only 0-1 simple questions asked\n- Questions are informational/rhetorical, not blocking\n- Agent continued working and asked incidental questions\n\n## Response Format\n\n**To block (force tool usage):**\n```json\n{\n  \"ok\": false,\n  \"reason\": \"You asked multiple questions requiring user input but didn't use AskUserQuestion. Please reformulate using AskUserQuestion tool with structured options for: [list specific questions]\"\n}\n```\n\n**To allow:**\n```json\n{\"ok\": true}\n```\n\nBe specific in the reason - quote the actual questions that need reformulation."
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

**Important**: Do NOT write this as a separate file. This structure will be embedded into `.claude/settings.json` in Step 9 below. Prepare this structure in memory or as a variable for merging in the next step.

### 9. Configure Settings with Embedded Hooks

The sdlc plugin requires the `sdlc:marvin-sdlc` output style to function reliably. This output style contains the TDD workflow orchestration rules, memory protocol, and other critical instructions.

Check if `.claude/settings.json` exists and read its current contents:
```bash
cat .claude/settings.json 2>/dev/null || echo "{}"
```

Create or update `.claude/settings.json` to include the output style, hooks configuration (from Step 8), and recommended settings. Preserve any existing settings (like permissions) and add/update:

```json
{
  "outputStyle": "sdlc:marvin-sdlc",
  "respectGitignore": true,
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [/* hook from Step 8 */]
      },
      {
        "matcher": "Write",
        "hooks": [/* hook from Step 8 */]
      }
    ],
    "SessionStart": [/* hook from Step 8 */],
    "SubagentStop": [/* hooks from Step 8 */],
    "PreCompact": [/* hook from Step 8 */],
    "Stop": [/* hook from Step 8 */]
  }
}
```

The `respectGitignore` setting improves @-mention file discovery by respecting .gitignore patterns.

**CRITICAL**: Hooks MUST be embedded in settings.json under the `hooks` key. Claude Code does NOT read separate `.claude/hooks.json` files at the project level - only plugin-level hooks are read from separate files.

If the file already has other settings, merge them. For example, if it contains permissions:
```json
{
  "outputStyle": "sdlc:marvin-sdlc",
  "respectGitignore": true,
  "permissions": {
    "allow": ["...existing permissions..."]
  },
  "hooks": {
    /* ...hooks configuration from Step 8... */
  }
}
```

**Important**:
1. Use the Write tool to create/update this file, ensuring valid JSON format
2. Embed the complete hooks structure from Step 8 under the `hooks` key
3. If updating an existing project, remove any legacy `.claude/hooks.json` file:
   ```bash
   rm -f .claude/hooks.json
   ```

### 10. Initialize Event Model Docs (if applicable)

If mode is `event-modeling`, ask if user wants to create the docs structure:

```bash
mkdir -p docs/event_model/{workflows,scenarios}
```

Create template files if requested.

### 11. Commit and Push Configuration

Check if there are any changes to commit:

```bash
git status --porcelain
```

If there are changes (the setup created files like `.claude/sdlc.yaml`, `.claude/hooks/`, `docs/event_model/`, etc.):

Determine the commit approach based on workflow:
- **PR workflow enabled** (user selected "Require PR before merging" in step 3): Create branch, commit, push, and create PR
- **Direct commits allowed** (no PR requirement or no remote): Commit directly

```bash
# Stage setup files
git add .claude/sdlc.yaml .claude/settings.json .claude/hooks/ docs/event_model/ 2>/dev/null
git add -A  # Catch any other setup-related files

# Determine commit message based on whether this is a fresh install or update
# If this is a fresh install (NEW_INSTALL path from Step 0):
# If PR workflow is enabled:
git checkout -b sdlc-setup
git commit -m "chore: initialize SDLC configuration

- Add .claude/sdlc.yaml with project preferences and language patterns (v4.0.0)
- Add .claude/settings.json with hooks and output style configuration
- Add .claude/hooks/ with command-based hook scripts
- Configure development mode, git workflow, and GitHub project"
git push -u origin sdlc-setup
gh pr create --title "chore: initialize SDLC configuration" --body "## Summary

This PR initializes the SDLC workflow configuration for the project.

### Changes
- Created \`.claude/sdlc.yaml\` with project preferences and language-specific patterns (v4.0.0)
- Created \`.claude/settings.json\` with embedded TDD enforcement hooks and output style (\`sdlc:marvin-sdlc\`)
- Created \`.claude/hooks/\` with command-based hook shell scripts
- Configured development mode and git workflow
- Set up GitHub project integration (if applicable)
- Initialized event model documentation structure (if applicable)

### Generated by
This configuration was created by running \`/sdlc:setup\`."
# If direct commits:
# ... similar but without branch/PR

# If this is an UPDATE (EXISTS path from Step 0):
# If PR workflow is enabled:
git checkout -b sdlc-update-v5.0.0
git commit -m "chore: update SDLC configuration to v5.0.0

- Update .claude/sdlc.yaml (v<old> → v5.0.0)
- Add .claude/hooks/ with command-based hook scripts (CRITICAL FIX)
- Update hooks in .claude/settings.json to use command-based scripts
- Remove legacy .claude/hooks.json file
- <List any new features or changes in this version>"
git push -u origin sdlc-update-v5.0.0
gh pr create --title "chore: update SDLC configuration to v5.0.0" --body "## Summary

This PR updates the SDLC workflow configuration from v<old> to v5.0.0.

### Changes
- Updated \`.claude/sdlc.yaml\` version field
- **CRITICAL FIX**: Added \`.claude/hooks/\` with command-based hook scripts
  - Prompt-based hooks are only officially supported for Stop and SubagentStop
  - PreToolUse, SessionStart, PreCompact now use command-based shell scripts
- Updated \`.claude/settings.json\` to reference new hook scripts
- Removed legacy \`.claude/hooks.json\` file
- <Describe other changes in this version>

All existing configuration choices have been preserved.

### Generated by
This update was performed by running \`/sdlc:setup\`."

# If direct commits allowed (or no remote):
git commit -m "chore: initialize SDLC configuration

- Add .claude/sdlc.yaml with project preferences and language patterns
- Add .claude/settings.json with hooks and output style configuration
- Configure development mode, git workflow, and GitHub project"
git push origin HEAD 2>/dev/null || echo "Changes committed locally (no remote configured)"
```

### 12. Display Success

Show summary of what was configured and next steps. Include all relevant sections based on what was actually configured.

**For fresh install (NEW_INSTALL path):**

```
✅ SDLC initialized successfully! (v5.0.0)

Repository: owner/repo-name (private)  # if created
  Merge method: Squash only (PR title and description)
  Auto-delete branches: Yes             # if enabled
Rulesets: main-branch-protection       # if configured
  - Required signatures: Yes
  - Required PR approvals: 1
  - Force push protection: Yes

Configuration:
  .claude/sdlc.yaml - Project preferences and language patterns
  .claude/settings.json - Output style, hooks, and permissions
  .claude/hooks/ - Command-based hook scripts

Output Style: sdlc:marvin-sdlc
Mode: Event Modeling
Git Workflow: git-spice

Languages Configured:
  - Rust (tests/, src/, #[cfg(test)])  # example
  - TypeScript (*.test.ts, src/)        # example

Task Management:
  dot CLI prefix: myproject
  Task directory: .dots/

Installed Extensions:
  - gh-pr-review (PR review comment handling)

⚠️  IMPORTANT: Restart your Claude session for changes to take effect
   The new output style and hooks require a fresh session to load properly.

Next steps:
  - Restart Claude (exit and start a new conversation)
  - /sdlc:work - Start working on a task
  - /sdlc:design - Design event model workflows
  - Use "dot ls" to see all tasks or "dot ready" for unblocked tasks

Auto-approval patterns to add to Claude settings:
  Bash(dot *)
  Bash(gh pr *)
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
✅ SDLC updated successfully! (v<old> → v5.0.0)

### What Changed

- **BREAKING CHANGE**: Migrated from GitHub Issues/Projects to dot CLI
  - Task management is now local and file-based (.dots/ directory)
  - Tasks use dot commands: `dot add`, `dot ls`, `dot ready`, `dot on`, `dot off`
  - GitHub integration limited to PRs and code review only
  - Removed dependencies on gh-issue-ext and gh-project-ext
- Added `tasks.prefix` configuration for task ID generation
- Updated GitHub configuration (now only owner/repository for PR workflows)
- Removed `github.project` and `board.statuses` (no longer needed)
- Branch naming now uses full task IDs (e.g., feature/myproject-add-login-abc123)

### Migration Required

If upgrading from v4.x with existing GitHub issues:
1. Review MIGRATION.md for export/import instructions
2. Tasks from GitHub Issues must be manually recreated in dot
3. Update any automation that relied on gh-issue-ext or gh-project-ext commands

### Preserved

These configuration choices were preserved:
- Mode: <event-modeling or traditional>
- Git workflow: <preference>
- Language patterns: <list>
- TDD verbosity: <setting>

### Next Steps

⚠️  IMPORTANT: Restart your Claude session for changes to take effect
   Updated hooks and configuration require a fresh session to load properly.

Your workflow continues with dot CLI:
  - Restart Claude (exit and start a new conversation)
  - /sdlc:work - Start working on a task
  - /sdlc:design - Design event model workflows
  - /sdlc:start - Auto-detect current phase and route
  - dot ls - List all tasks
  - dot ready - Show unblocked tasks ready to work on
```

Omit sections that weren't configured (e.g., don't show Repository section if no repo was created).
