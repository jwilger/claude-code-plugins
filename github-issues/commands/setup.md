---
name: setup
description: Install and configure the gh-issue-ext extension for advanced GitHub issue management
allowed-tools:
  - Bash
  - Read
---

# GitHub Issues Setup

Install and configure the `gh-issue-ext` extension for advanced GitHub issue management.

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

3. **Check if gh-issue-ext is already installed**
   ```bash
   gh extension list | grep -q "gh-issue-ext"
   ```

4. **Install or upgrade gh-issue-ext**
   If not installed:
   ```bash
   gh extension install jwilger/gh-issue-ext
   ```

   If already installed, ask if user wants to upgrade:
   ```bash
   gh extension upgrade jwilger/gh-issue-ext
   ```

5. **Verify installation**
   ```bash
   gh issue-ext --version
   ```

6. **Display success message with next steps**

## Output to User

After successful setup, inform the user:

```
GitHub Issues extension installed successfully!

To enable auto-approval of issue management commands in Claude Code, add these
permission patterns to your settings:

  Bash(gh issue:*)
  Bash(gh issue-ext:*)

Quick command reference:
  gh issue-ext sub add <parent> <child>     # Add sub-issue
  gh issue-ext blocking add <blocked> <by>  # Add blocking relationship
  gh issue-ext branch create <issue>        # Create linked branch
  gh issue-ext show <issue>                 # Show all relationships

For full documentation, ask: "How do I manage GitHub issues?"
```

## Error Handling

- If gh CLI is not installed: Direct user to https://cli.github.com/
- If not authenticated: Direct user to run `gh auth login`
- If installation fails: Show the error and suggest checking network/permissions
