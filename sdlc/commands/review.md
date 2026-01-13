---
description: INVOKE when PR has review comments to address. Fetches and responds to feedback
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

### 2. Fetch and Organize Comments

Use gh-pr-review to get unresolved review threads:
```bash
gh pr-review review view -R <owner>/<repo> --pr <number> --unresolved
```

Display formatted summary grouping by file:
```
PR #<number> has <count> pending review comments:

File: src/auth/login.rs
  Line 42: @reviewer - "Should we validate email format here?"
  Line 89: @reviewer - "Consider using Result instead of Option"

File: src/auth/mod.rs
  Line 15: @reviewer - "Missing documentation for public function"

Would you like me to address these comments?
```

### 3. Address Each Comment

For each comment:

#### a. Make the code change (if needed)

Use the appropriate agent:
- Test changes: sdlc:red
- Implementation changes: sdlc:green
- Type changes: sdlc:domain

#### b. Reply in-thread

Replies must be in-thread using gh-pr-review:
```bash
gh pr-review comments reply \
  --thread-id <thread-id> \
  --body "<response>" \
  -R <owner>/<repo> <pr-number>
```

Response decision tree:
- IF change made THEN acknowledge feedback and explain the change made
- IF no change needed THEN explain why with reasoning and offer to discuss
- IF question or clarification THEN answer directly and ask if more detail needed

Example responses:
- "Good catch! Added email validation using the `validator` crate."
- "Updated to return `Result<User, AuthError>` as suggested."
- "This is intentional because [reason]. Happy to discuss if you see issues."

### 4. Commit and Push

```bash
git add .
git commit -m "Address review feedback

- <summary of changes>
- Responds to comments from @reviewer"
git push
```

### 5. Request Re-Review

```bash
gh api repos/{owner}/{repo}/pulls/<number>/requested_reviewers \
  -f reviewers[]="<reviewer>"
```

### 6. Display Summary

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

Install: `gh extension install agynio/gh-pr-review`
Auto-approval: `Bash(gh pr-review *)`
