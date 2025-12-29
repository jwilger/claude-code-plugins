---
name: setup
description: Install gh-project-ext extension and configure default project
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# GitHub Projects Setup

Install and configure the `gh-project-ext` extension for GitHub Projects V2 Kanban board management.

## Steps to Perform

1. **Check if gh CLI is installed**
   ```bash
   gh --version
   ```
   If not installed, inform the user they need to install GitHub CLI first from https://cli.github.com/

2. **Check if gh is authenticated**
   ```bash
   gh auth status
   ```
   If not authenticated, inform the user to run `gh auth login` first.

3. **Check for project scope**
   ```bash
   gh auth status 2>&1 | grep -i "project"
   ```
   If project scope is missing, inform user to run:
   ```bash
   gh auth refresh -s project
   ```

4. **Check if gh-project-ext is already installed**
   ```bash
   gh extension list | grep -q "gh-project-ext"
   ```

5. **Install or upgrade gh-project-ext**
   If not installed:
   ```bash
   gh extension install jwilger/gh-project-ext
   ```

   If already installed, ask if user wants to upgrade:
   ```bash
   gh extension upgrade jwilger/gh-project-ext
   ```

6. **Run interactive setup**
   ```bash
   gh project-ext setup
   ```
   This will:
   - List user's available projects
   - Let user select or specify project
   - Create `.github-project` config file

7. **Verify installation**
   ```bash
   gh project-ext show
   ```

8. **Display success message with next steps**

## Output to User

After successful setup, inform the user:

```
GitHub Projects extension installed successfully!

To enable auto-approval of project management commands in Claude Code, add these
permission patterns to your settings:

  Bash(gh project:*)
  Bash(gh project-ext:*)

Quick command reference:
  gh project-ext ready                  # Show items ready to work on
  gh project-ext board                  # Show Kanban board view
  gh project-ext move <issue> <status>  # Move item to new status
  gh project-ext claim <issue>          # Assign to me and start work
  gh project-ext show                   # Show project structure

For full documentation, ask: "How do I manage my GitHub project board?"
```

## Error Handling

- If gh CLI is not installed: Direct user to https://cli.github.com/
- If not authenticated: Direct user to run `gh auth login`
- If project scope missing: Direct user to run `gh auth refresh -s project`
- If installation fails: Show the error and suggest checking network/permissions
