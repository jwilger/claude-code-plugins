# GitHub Pull Request Management Protocol

## Purpose

Standardized procedures for managing GitHub pull requests, including replying to review comments in threaded fashion.

## Replying to PR Review Comments

### The Problem

GitHub PR review comments require specific API endpoints to create threaded replies. Common mistakes:

**❌ WRONG: General comment (not threaded)**
```bash
gh pr review --comment "Fixed in commit abc123"
```

**❌ WRONG: Non-existent endpoint**
```bash
gh api POST /repos/owner/repo/pulls/comments/123/replies
```

**✅ CORRECT: Threaded reply using in_reply_to parameter**
```bash
gh api -X POST repos/owner/repo/pulls/3/comments \
  -f body="Fixed in commit abc123" \
  -f commit_id="abc123..." \
  -f path="src/file.py" \
  -F line=42 \
  -f side="RIGHT" \
  -F in_reply_to=2403289945
```

### Required Information

To reply to a review comment, you need:

1. **PR number** - The pull request number
2. **Comment ID** - The review comment ID to reply to
3. **Commit SHA** - Full commit hash the comment refers to
4. **File path** - Path to the file being commented on
5. **Line number** - Line number in the file
6. **Reply text** - Your response message

### Getting Comment Details

```bash
# List all review comments on a PR
gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments

# Extract comment ID, file path, line, and commit SHA from output
```

### Using the Helper Script

A helper script is available at `~/.local/bin/gh-reply-to-review-comment`:

```bash
gh-reply-to-review-comment <pr_number> <comment_id> <commit_sha> <file_path> <line_number> <reply_text>
```

**Example:**
```bash
gh-reply-to-review-comment 3 2403289945 "4395adb6ea1c57a6ff796b49030a5b1fa3775597" \
  "tests/test_tool_discovery.py" 24 "Fixed in commit 4395adb - converted to union syntax"
```

## Workflow Integration

### Phase 7 (Story Implementation) - Addressing Review Comments

When Copilot or human reviewers add comments to a PR:

1. **Identify all review comments** requiring response
   ```bash
   gh pr view PR_NUMBER --comments
   ```

2. **For each comment thread:**
   - Fix the issue in code
   - Commit the fix
   - Reply to the comment thread using the helper script or gh API directly

3. **Verify all comments addressed:**
   - Each Copilot suggestion should have a threaded reply
   - General PR comments use `gh pr review --comment`
   - File-specific review comments use `gh-reply-to-review-comment` script

### Phase 8 (Source Control) - PR Creation and Management

When creating or updating PRs:

1. **Create PR with descriptive body:**
   ```bash
   gh pr create --title "Story X: Feature" --body "$(cat <<'EOF'
   ## Summary
   - Bullet point summary

   ## Test Plan
   - [ ] Manual testing steps

   Generated with Claude Code
   EOF
   )"
   ```

2. **Monitor CI checks:**
   ```bash
   gh pr checks
   ```

3. **Address review comments** using protocol above

4. **Request re-review after fixes:**
   ```bash
   gh pr review --approve  # if self-approved allowed
   # OR wait for reviewer
   ```

## Common Patterns

### Pattern 1: Batch Reply to Multiple Comments

```bash
# Get all comments
COMMENTS=$(gh api repos/OWNER/REPO/pulls/PR/comments)

# For each comment, extract details and reply
# (Script automation or manual iteration)
```

### Pattern 2: Reply with Commit Reference

Always reference the specific commit that addresses the comment:

```bash
gh-reply-to-review-comment PR COMMENT_ID COMMIT_SHA FILE LINE \
  "Fixed in commit ${COMMIT_SHA} - <description of fix>"
```

### Pattern 3: Multiple Fixes in One Commit

When one commit fixes multiple review comments:

```bash
COMMIT_SHA="abc123..."
gh-reply-to-review-comment PR COMMENT1_ID "$COMMIT_SHA" file1.py 10 "Fixed in $COMMIT_SHA"
gh-reply-to-review-comment PR COMMENT2_ID "$COMMIT_SHA" file2.py 20 "Fixed in $COMMIT_SHA"
```

## Troubleshooting

### Error: 404 Not Found

**Cause**: Wrong endpoint or incorrect comment ID

**Fix**: Verify comment ID exists:
```bash
gh api repos/OWNER/REPO/pulls/PR/comments | jq '.[] | {id, path, line}'
```

### Error: Validation Failed

**Cause**: Missing required fields (commit_id, path, line, in_reply_to)

**Fix**: Ensure all fields are provided and correctly formatted

### Comments Not Appearing as Threaded

**Cause**: Used `gh pr review --comment` instead of API endpoint

**Fix**: Use `gh-reply-to-review-comment` script or gh API with in_reply_to parameter

## Memory Storage

When addressing PR review comments, store in memory:

- Comment addressing patterns per project
- Common review issues and their fixes
- CI failure patterns and resolutions

**Example Memory:**
```
Entity: "PR Review Comment Protocol"
Observations:
  - "Project: pytest-mcp | Copilot comments require threaded replies via gh API"
  - "Pattern: gh-reply-to-review-comment script encapsulates correct API usage"
  - "Common error: Using gh pr review --comment creates unthreaded comment"
```
