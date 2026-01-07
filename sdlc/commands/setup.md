---
description: Initialize SDLC project configuration and install required GitHub CLI extensions
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

Initialize the SDLC workflow for this project. This command:
1. Checks for required tools (gh CLI, git-spice)
2. Optionally creates a GitHub repository with branch rulesets
3. Installs required GitHub CLI extensions
4. Creates `.claude/sdlc.yaml` configuration through interactive prompts

## Steps

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

If configuring rulesets, dynamically discover and present rule options.

#### Dynamic Rule Discovery

Fetch the current available rule types from GitHub's API documentation to ensure you're presenting the latest options. The main categories are:

1. **Commit Requirements**
   - `required_signatures` - Require signed commits
   - `required_linear_history` - Prevent merge commits (linear history only)

2. **Pull Request Rules** (`pull_request` type with parameters)
   - `required_approving_review_count` - Number of required approvals (0-10)
   - `dismiss_stale_reviews_on_push` - Dismiss approvals when new commits are pushed
   - `require_code_owner_review` - Require review from code owners
   - `require_last_push_approval` - Most recent pusher cannot self-approve
   - `required_review_thread_resolution` - All conversations must be resolved
   - `allowed_merge_methods` - Which merge strategies are allowed (merge, squash, rebase)

3. **Status Checks** (`required_status_checks` type)
   - `strict_required_status_checks_policy` - Require branch to be up-to-date
   - `required_status_checks` - List of required CI checks (context names)

4. **Push Restrictions**
   - `non_fast_forward` - Prevent force pushes
   - `deletion` - Prevent branch deletion
   - `creation` - Restrict who can create matching refs

5. **File Restrictions**
   - `file_path_restriction` - Block specific file paths
   - `max_file_size` - Maximum file size in MB

Use AskUserQuestion to ask about each relevant category. Present them in logical groupings:

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

**Question: Require linear history?**
- "Yes" - Only allow squash or rebase merges (no merge commits)
- "No" - Allow merge commits

**Question: Allowed merge methods?** (multiSelect: true)
- "Merge commits" - Allow standard merge commits (creates merge commit in history)
- "Squash merging" - Allow squashing commits into one (Recommended for cleaner history)
- "Rebase merging" - Allow rebasing commits onto base branch

Note: At least one merge method must be selected. If the user selects "Require linear history" above, inform them that merge commits will be disabled regardless.

**Question: Auto-delete branches after merge?**
- "Yes" - Automatically delete head branches after PR merge (Recommended)
- "No" - Keep branches after merge

#### Apply Repository Settings

Before applying rulesets, configure the repository merge and branch deletion settings:

```bash
gh api --method PATCH /repos/{owner}/{repo} \
  --field allow_merge_commit=<true|false> \
  --field allow_squash_merge=<true|false> \
  --field allow_rebase_merge=<true|false> \
  --field delete_branch_on_merge=<true|false>
```

Set each field based on user selections:
- `allow_merge_commit`: true if "Merge commits" was selected
- `allow_squash_merge`: true if "Squash merging" was selected
- `allow_rebase_merge`: true if "Rebase merging" was selected
- `delete_branch_on_merge`: true if "Yes" to auto-delete

If "Require linear history" was selected, set `allow_merge_commit=false` regardless of the merge methods selection.

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

### 5. Check for git-spice (optional)

```bash
command -v gs
```

If git-spice is available, note it for the config options.

### 6. Interactive Configuration

Use AskUserQuestion to gather project preferences:

**Question 1: Development Mode**
- Event Modeling (application development with workflows, slices, GWT)
- Traditional (PRD, architecture, feature/subtask breakdown)

**Question 2: Git Workflow**
- git-spice (stacked PRs) - only if git-spice is installed
- Standard (single branch per feature)

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

**Question 4: TDD Verbosity**
- Silent (just use agents, no explanation)
- Brief (one-line notes about what's happening)
- Explain (full context about agent delegation)

### 7. Create Configuration

Create `.claude/sdlc.yaml` with the gathered settings:

```yaml
# SDLC Configuration
# Generated by /sdlc:setup

mode: event-modeling  # or: traditional

git:
  workflow: git-spice  # or: standard
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

tdd:
  verbosity: brief  # silent | brief | explain
  bypass_patterns:
    # Documentation
    - "*.md"
    - "*.txt"
    - "*.rst"
    # Infrastructure
    - ".github/**"
    - "*.tf"
    - "*.tfvars"
    - "*.hcl"
    # Configuration
    - "Cargo.toml"
    - "package.json"
    - "pyproject.toml"
    - "*.yaml"
    - "*.yml"
    - "*.toml"
    - "*.json"
    # Build/tooling
    - "Makefile"
    - "Dockerfile"
    - "docker-compose*.yml"
```

Ensure `.claude/` directory exists:
```bash
mkdir -p .claude
```

### 8. Configure Output Style

The sdlc plugin requires the `marvin-output-style:marvin-sdlc` output style to function reliably. This output style contains the TDD workflow orchestration rules, memory protocol, and other critical instructions.

Check if `.claude/settings.json` exists and read its current contents:
```bash
cat .claude/settings.json 2>/dev/null || echo "{}"
```

Create or update `.claude/settings.json` to include the output style and recommended settings. Preserve any existing settings (like permissions) and add/update:

```json
{
  "outputStyle": "marvin-output-style:marvin-sdlc",
  "respectGitignore": true
}
```

The `respectGitignore` setting improves @-mention file discovery by respecting .gitignore patterns.

If the file already has other settings, merge them. For example, if it contains permissions:
```json
{
  "outputStyle": "marvin-output-style:marvin-sdlc",
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

#### Determine Workflow Mode

Check if PR workflow was enabled during ruleset configuration. This is true if:
- A GitHub repository exists (remote origin is set)
- AND the user selected "Require PR before merging" in step 3

**If PR workflow is enabled:**

1. Create a feature branch:
```bash
git checkout -b sdlc-setup
```

2. Stage and commit the changes:
```bash
git add .claude/sdlc.yaml .claude/settings.json docs/event_model/ 2>/dev/null
git add -A  # Catch any other setup-related files
git commit -m "chore: initialize SDLC configuration

- Add .claude/sdlc.yaml with project preferences
- Configure output style (marvin-output-style:marvin-sdlc)
- Configure development mode, git workflow, and GitHub project
- Set up TDD verbosity and bypass patterns"
```

3. Push the branch:
```bash
git push -u origin sdlc-setup
```

4. Create a pull request:
```bash
gh pr create --title "chore: initialize SDLC configuration" --body "## Summary

This PR initializes the SDLC workflow configuration for the project.

### Changes
- Created \`.claude/sdlc.yaml\` with project preferences
- Configured output style (\`marvin-output-style:marvin-sdlc\`) in \`.claude/settings.json\`
- Configured development mode and git workflow
- Set up GitHub project integration (if applicable)
- Initialized event model documentation structure (if applicable)

### Generated by
This configuration was created by running \`/sdlc:setup\`."
```

5. Inform the user:
```
PR created: <PR_URL>

The SDLC configuration changes are ready for review.
Once merged, the project will be fully configured for the SDLC workflow.
```

**If NOT using PR workflow (direct commits allowed):**

1. Stage and commit directly to the current branch:
```bash
git add .claude/sdlc.yaml .claude/settings.json docs/event_model/ 2>/dev/null
git add -A  # Catch any other setup-related files
git commit -m "chore: initialize SDLC configuration

- Add .claude/sdlc.yaml with project preferences
- Configure output style (marvin-output-style:marvin-sdlc)
- Configure development mode, git workflow, and GitHub project
- Set up TDD verbosity and bypass patterns"
```

2. Push to the remote (if a remote exists):
```bash
git push origin HEAD
```

**If no GitHub remote exists:**

Just commit locally without pushing:
```bash
git add .claude/sdlc.yaml .claude/settings.json docs/event_model/ 2>/dev/null
git add -A
git commit -m "chore: initialize SDLC configuration

- Add .claude/sdlc.yaml with project preferences
- Configure output style (marvin-output-style:marvin-sdlc)
- Configure development mode, git workflow, and GitHub project
- Set up TDD verbosity and bypass patterns"
```

Inform the user that changes are committed locally and will be pushed when a remote is configured.

### 11. Display Success

Show summary of what was configured and next steps. Include all relevant sections based on what was actually configured:

```
SDLC initialized successfully!

Repository: owner/repo-name (private)  # if created
  Merge methods: squash, rebase         # based on selections
  Auto-delete branches: Yes             # if enabled
Rulesets: main-branch-protection       # if configured
  - Required signatures: Yes
  - Required PR approvals: 1
  - Force push protection: Yes

Output Style: marvin-output-style:marvin-sdlc
Configuration: .claude/sdlc.yaml
Mode: Event Modeling
Git Workflow: git-spice
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
  - Task(sdlc-mutation) - Disable mutation testing
  - Task(sdlc-ux) - Disable UX review
  - Task(sdlc-architect) - Disable architecture review

  Example settings.json with agent denial:
  {
    "permissions": {
      "deny": ["Task(sdlc-mutation)"]
    }
  }
```

Omit sections that weren't configured (e.g., don't show Repository section if no repo was created).

### 12. Workflow Automation Setup (If Using GitHub Project)

If a GitHub Project was configured, inform the user about setting up automatic issue-to-project linking:

```
📋 RECOMMENDED: Auto-Add Issues to Project

To automatically add new issues to your project board, create a GitHub Actions workflow.

Create file: .github/workflows/add-to-project.yml

With the following content:
```

Then display this workflow content:

```yaml
name: Add issues to project

on:
  issues:
    types: [opened]

jobs:
  add-to-project:
    name: Add issue to project
    runs-on: ubuntu-latest
    steps:
      - uses: actions/add-to-project@v1.0.2
        with:
          project-url: https://github.com/users/<owner>/projects/<number>
          github-token: ${{ secrets.ADD_TO_PROJECT_PAT }}
```

**Important setup instructions to display:**

```
⚠️  REQUIRED: Create a Personal Access Token (PAT)

GitHub Actions cannot use the default GITHUB_TOKEN for project operations.
You need to create a PAT with the following scopes:

1. Go to: https://github.com/settings/tokens?type=beta
2. Click "Generate new token"
3. Name: "Add to Project - <repo-name>"
4. Repository access: Select your repository
5. Permissions:
   - Repository permissions:
     - Issues: Read and write
     - Metadata: Read-only
   - Organization permissions (if org project):
     - Projects: Read and write
6. Generate and copy the token

Then add it as a repository secret:
1. Go to: https://github.com/<owner>/<repo>/settings/secrets/actions
2. Click "New repository secret"
3. Name: ADD_TO_PROJECT_PAT
4. Value: <paste your token>
5. Click "Add secret"

After setup, all new issues will automatically appear in your project board's Backlog.
```

Replace `<owner>` and `<number>` in the workflow file with the actual project owner and number from the configuration.
