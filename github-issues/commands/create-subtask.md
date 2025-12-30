---
name: create-subtask
description: Create a new GitHub issue and link it as a sub-issue of a parent in one atomic operation
allowed-tools:
  - Bash
  - AskUserQuestion
argument-hint: <parent-issue-number> "<title>"
---

# Create Sub-Issue

Create a new GitHub issue and automatically link it as a sub-issue of the specified parent. This ensures proper parent-child relationships are always established.

## Why This Command Exists

When creating follow-up issues or breaking down epics, it's easy to:
1. Create an issue with `gh issue create`
2. Mention "Parent: #NNN" in the body
3. **Forget** to actually link it with `gh issue-ext sub add`

This command does both steps atomically, preventing orphaned "sub-issues" that aren't properly linked.

## Arguments

```
/create-subtask <parent-issue-number> "<title>"
```

- `parent-issue-number`: The issue number to add the new issue under (e.g., `237`)
- `title`: The title for the new issue (in quotes if it contains spaces)

## Steps to Perform

1. **Parse arguments**
   - Extract parent issue number
   - Extract title (handle quoted strings)
   - If arguments are missing, use AskUserQuestion to gather them

2. **Verify parent issue exists**
   ```bash
   gh issue view <parent> --json number,title,state
   ```
   If not found, inform user and abort.

3. **Get parent issue context**
   Extract the parent's title and any labels that should be inherited (like epic labels).

4. **Ask for issue body** (if not provided)
   Use AskUserQuestion to get:
   - Issue description/body
   - Any additional labels to apply

5. **Create the new issue**
   ```bash
   gh issue create --title "<title>" --body "<body with parent reference>"
   ```
   Capture the new issue number from output.

6. **Link as sub-issue**
   ```bash
   gh issue-ext sub add <parent> <new-issue-number>
   ```

7. **Verify the relationship**
   ```bash
   gh issue-ext show <new-issue-number>
   ```

## Output to User

```
Created issue #<new> and linked to parent #<parent>

  Parent: #<parent> - <parent-title>
  Child:  #<new> - <title>

View: https://github.com/<owner>/<repo>/issues/<new>
```

## Error Handling

- **Parent not found**: "Issue #NNN not found. Please verify the issue number."
- **gh-issue-ext not installed**: "The gh-issue-ext extension is required. Run /github-issues:setup to install it."
- **Create failed**: Show the error from `gh issue create`
- **Link failed**: Show the error, but note the issue was created (manual linking needed)

## Examples

```bash
# Create a subtask under epic #237
/create-subtask 237 "Integrate coordinator into ProjectionRunner"

# With a longer title
/create-subtask 100 "Add OAuth2 authentication flow"
```
