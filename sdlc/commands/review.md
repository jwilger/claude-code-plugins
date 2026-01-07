---
description: Handle PR review feedback - fetch comments and respond appropriately
context: fork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Task
hooks:
  Stop:
    - hooks:
        - type: prompt
          prompt: |
            Before completing, store review feedback handling in memento:
            - Comments addressed
            - Changes made in response
            - Any reviewer concerns or patterns noted

            Output ONLY: {"ok": true}
---

# SDLC Review

Handle PR review feedback. This command:
1. Fetches pending review comments from the current branch's PR
2. Shows comments organized by file/location
3. Addresses each comment (make changes AND respond in-thread)
4. Requests re-review when done

## Steps

### 1. Detect Current PR

From current branch, find the associated PR:
```bash
gh pr view --json number,url,reviewDecision,reviews
```

If no PR exists:
```
No PR found for current branch.
Run /sdlc:pr first to create a pull request.
```

### 2. Fetch Review Comments

Use the gh-pr-review extension to get all pending review comments:

```bash
# Get all unresolved review threads
gh pr-review review view -R <owner>/<repo> --pr <number> --unresolved

# Get threads from a specific reviewer
gh pr-review review view -R <owner>/<repo> --pr <number> \
  --reviewer <username> \
  --states CHANGES_REQUESTED
```

This returns a structured view of all inline comments with their thread IDs.

### 3. Organize Comments

Group comments by:
1. **Unresolved threads** - Comments that need response
2. **Resolved threads** - Already addressed
3. **General comments** - Not tied to specific lines

For each unresolved comment, show:
- File path and line number
- Comment author
- Comment text
- Any existing replies in thread

### 4. Present Comments to User

Display formatted summary:

```
PR #<number> has <count> pending review comments:

File: src/auth/login.rs
  Line 42: @reviewer - "Should we validate email format here?"
  Line 89: @reviewer - "Consider using Result instead of Option"

File: src/auth/mod.rs
  Line 15: @reviewer - "Missing documentation for public function"

Would you like me to address these comments?
```

### 5. Address Each Comment

For each comment, the process is:

#### a. Make the code change (if needed)

Use the appropriate agent:
- For test changes: sdlc-red
- For implementation changes: sdlc-green
- For type changes: sdlc-domain

#### b. Reply to the comment IN THE SAME THREAD

This is critical - replies must be in-thread, not as general comments.

Using gh-pr-review extension:
```bash
gh pr-review comments reply \
  --thread-id <thread-id> \
  --body "<response>" \
  -R <owner>/<repo> <pr-number>
```

The response should:
- Acknowledge the feedback
- Explain what change was made (or why no change was made)
- Be professional and concise

Example responses:
- "Good catch! Added email validation using the `validator` crate. See updated code."
- "You're right, `Result` is clearer here. Updated to return `Result<User, AuthError>`."
- "Added rustdoc comment explaining the function's purpose and parameters."

#### c. If no change needed, explain why

Sometimes a review comment doesn't require a code change:
- "This is intentional because [reason]. The [constraint] requires this approach."
- "I considered this, but [tradeoff]. Happy to discuss if you see issues."

### 6. Commit Changes

After addressing comments, commit:
```bash
git add .
git commit -m "Address review feedback

- <summary of changes>
- Responds to comments from @reviewer"
```

### 7. Push and Request Re-Review

```bash
git push
```

Request re-review:
```bash
gh pr edit <number> --add-reviewer <original-reviewer>
```

Or using the review request endpoint:
```bash
gh api repos/{owner}/{repo}/pulls/<number>/requested_reviewers \
  -f reviewers[]="<reviewer>"
```

### 8. Display Summary

```
Review feedback addressed!

Changes made:
  - src/auth/login.rs: Added email validation
  - src/auth/login.rs: Changed Option to Result
  - src/auth/mod.rs: Added documentation

Responses posted: <count>
Re-review requested from: @<reviewer>

PR: <url>
```

## Error Handling

- **No PR**: Direct to /sdlc:pr
- **No pending comments**: "No pending review comments. PR is ready for merge!"
- **API errors**: Suggest manual review via GitHub web interface
- **Comment threading fails**: Fall back to general comment with reference

## gh-pr-review Extension

This command uses the `gh-pr-review` extension (agynio/gh-pr-review) for:
- Viewing review threads: `gh pr-review review view`
- Replying to threads: `gh pr-review comments reply`
- Resolving threads: `gh pr-review threads resolve`

Install with: `gh extension install agynio/gh-pr-review`

Add to auto-approval: `Bash(gh pr-review *)`
