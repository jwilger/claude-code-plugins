# Subagent Question Protocol

Due to a Claude Code limitation, subagents cannot use `AskUserQuestion` directly. This protocol enables subagents to request user input through the main agent using file-based state persistence for continuations.

> **Why File-Based State?** Claude Code's `resume` parameter has a known bug ([Issue #13619](https://github.com/anthropics/claude-code/issues/13619)) that causes 400 errors when resuming agents that have used tools. This protocol avoids `resume` entirely by persisting state to files.

## For Subagents: Requesting User Input

When you need user input, you must:
1. **Save your progress** to a state file
2. **Output the AWAITING_USER_INPUT marker** with state file reference
3. **STOP** and wait for continuation

### Step 1: Create State File

Before outputting AWAITING_USER_INPUT, save your current state to a file in the auto memory directory:

```bash
# Determine memory path
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
MEMORY_PATH="$HOME/.claude/projects/$(basename "$PROJECT_ROOT")/memory"
mkdir -p "$MEMORY_PATH/checkpoints"

# Create checkpoint file
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STATE_FILE="$MEMORY_PATH/checkpoints/${AGENT_TYPE}-${TIMESTAMP}.md"

cat > "$STATE_FILE" << EOF
# ${AGENT_TYPE} Checkpoint

**Timestamp:** ${TIMESTAMP}
**Task:** What you were asked to do
**Agent:** ${AGENT_TYPE}

## Progress Summary

What you've accomplished so far.

## Files Created

- path/to/file1.md
- path/to/file2.md

## Files Read

- Key files you've examined
- path/to/important-file.rs

## Next Step

What you were about to do when you needed input.

## Pending Decision

What you need the user to decide.

## Context for Continuation

Any additional context needed to resume work.
EOF
```

### Step 2: Output AWAITING_USER_INPUT

Output this exact format and **STOP**:

```
AWAITING_USER_INPUT
{
  "context": "Brief description of what you're doing",
  "stateFile": "/home/user/.claude/projects/my-project/memory/checkpoints/sdlc-discovery-2026-01-08T14:32:00Z.md",
  "questions": [
    {
      "id": "q1",
      "question": "The full question text?",
      "header": "ShortLabel",
      "options": [
        {"label": "Option 1", "description": "What this means"},
        {"label": "Option 2", "description": "What this means"}
      ],
      "multiSelect": false
    }
  ]
}
```

### Format Rules

| Field | Description | Example |
|-------|-------------|---------|
| `context` | What you're working on (helps user understand) | "Designing database architecture" |
| `stateFile` | Absolute path to the checkpoint file you just created | "/home/user/.claude/projects/my-project/memory/checkpoints/sdlc-discovery-2026-01-08T14:32:00Z.md" |
| `id` | Unique ID for each question | "q1", "q2", "db_choice" |
| `question` | Full question text ending with ? | "Which database fits your needs?" |
| `header` | Short label (max 12 chars) | "Database", "Auth", "Framework" |
| `options` | 2-4 choices with label and description | See below |
| `multiSelect` | `true` if multiple selections allowed | `false` |

### Option Format

```json
{
  "label": "PostgreSQL",
  "description": "Relational database with strong ACID compliance"
}
```

### Multiple Questions

You can ask up to 4 questions at once:

```
AWAITING_USER_INPUT
{
  "context": "Setting up the technology stack",
  "stateFile": "/home/user/.claude/projects/my-project/memory/checkpoints/sdlc-discovery-2026-01-08T14:32:00Z.md",
  "questions": [
    {
      "id": "database",
      "question": "Which database should we use?",
      "header": "Database",
      "options": [
        {"label": "PostgreSQL", "description": "Relational, ACID"},
        {"label": "MongoDB", "description": "Document store"}
      ],
      "multiSelect": false
    },
    {
      "id": "framework",
      "question": "Which web framework?",
      "header": "Framework",
      "options": [
        {"label": "Axum", "description": "Rust async framework"},
        {"label": "Actix", "description": "Rust actor framework"}
      ],
      "multiSelect": false
    }
  ]
}
```

## For Subagents: Continuing After User Response

When the main agent launches a new task with the user's answers, you'll receive:

```
USER_INPUT_RESPONSE
{"q1": "Option 1", "q2": "Option 2"}

Continue from state file: /path/to/checkpoint.md
```

### Your First Actions on Continuation

1. **Read the checkpoint file** to restore your context:
   ```bash
   cat /path/to/checkpoint.md
   # Parse progress, files created, next steps
   ```

2. **Re-read any files you created** (listed in checkpoint):
   ```bash
   # Files listed in checkpoint "Files Created" section
   cat path/to/file1.md
   cat path/to/file2.md
   ```

3. **Search memory for related context** (if needed):
   ```bash
   MEMORY_PATH="$HOME/.claude/projects/$(basename $PROJECT_ROOT)/memory"
   grep -r "relevant keywords" "$MEMORY_PATH" --include="*.md"
   ```

4. **Continue your work** with the user's answers and restored context

For multi-select questions, the value is an array:

```
USER_INPUT_RESPONSE
{"languages": ["Rust", "TypeScript"]}

Continue from state file: /home/user/.claude/projects/my-project/memory/checkpoints/sdlc-discovery-2026-01-08T14:32:00Z.md
```

## For Main Agent: Proxy Protocol

See `sdlc/output-styles/sdlc-rules.md` for the full proxy protocol instructions.

Quick reference:
1. Detect `AWAITING_USER_INPUT` in task result
2. Parse the JSON, extract `stateFile` and `questions`
3. Call `AskUserQuestion` with the provided questions array
4. Launch a **NEW task** (same agent type) with `USER_INPUT_RESPONSE` and state file reference

**IMPORTANT**: Do NOT use the Task tool's `resume` parameter. Launch a fresh task instead.

## Example Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ Main Agent                                                       │
│                                                                  │
│ 1. Task(subagent_type="sdlc-discovery",                         │
│         prompt="Facilitate domain discovery for TaskFlow...")   │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ Subagent (First Invocation)                                      │
│                                                                  │
│ "I need to understand the tech stack..."                        │
│                                                                  │
│ Creates checkpoint file:                                         │
│   /home/user/.claude/projects/taskflow/memory/checkpoints/      │
│   sdlc-discovery-2026-01-08T14:32:00Z.md                        │
│                                                                  │
│   Content:                                                       │
│   - Agent: sdlc-discovery                                        │
│   - Task: Domain discovery for TaskFlow                         │
│   - Progress: Identified 3 actors, learned core business        │
│   - Files created: docs/event_model/domain/overview.md          │
│   - Next step: Identify workflows                               │
│   - Pending decision: notification preferences                  │
│                                                                  │
│ AWAITING_USER_INPUT                                              │
│ {"context": "...", "stateFile": "/home/user/.claude/...",      │
│  "questions": [...]}                                            │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ Main Agent                                                       │
│                                                                  │
│ 2. Detects AWAITING_USER_INPUT                                  │
│ 3. AskUserQuestion(questions from JSON)                         │
│                                                                  │
│ User selects: "PostgreSQL"                                       │
│                                                                  │
│ 4. Task(subagent_type="sdlc-discovery",    ◄── NEW task, not    │
│         prompt="USER_INPUT_RESPONSE...         resume!          │
│                Continue from state file: ...")                   │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ Subagent (Second Invocation - Fresh Agent)                       │
│                                                                  │
│ Receives: USER_INPUT_RESPONSE {"database": "PostgreSQL"}        │
│           Continue from state file: /home/user/.claude/...      │
│                                                                  │
│ 1. Reads checkpoint file                                        │
│ 2. Reads files listed in checkpoint (overview.md)               │
│ 3. Has full context restored!                                   │
│                                                                  │
│ Continues work with the answer...                               │
│                                                                  │
│ (May create another checkpoint + AWAITING_USER_INPUT)           │
└─────────────────────────────────────────────────────────────────┘
```

## Checkpoint Best Practices

### What to Include in Checkpoint Files

| Section | Content | Example |
|---------|---------|---------|
| Header | Agent type, timestamp, task | `# sdlc-discovery Checkpoint` |
| Progress Summary | What you've accomplished | "Completed actor mapping, identified 5 workflows" |
| Files Created | Artifacts you've written | `- docs/event_model/domain/overview.md` |
| Files Read | Context files examined | `- README.md, Cargo.toml, existing docs/` |
| Next Step | What you were about to do | "Detail the User Registration workflow" |
| Pending Decision | What you need user to decide | "Notification delivery method" |
| Context for Continuation | Additional context needed | "User wants event sourcing for audit compliance" |

### Checkpoint File Structure

Use markdown format for easy reading and grep-based search:

```markdown
# <agent-type> Checkpoint

**Timestamp:** <ISO-8601-timestamp>
**Task:** <what you were asked to do>
**Agent:** <agent-type>

## Progress Summary

<summary of what you've accomplished>

## Files Created

- path/to/file1.md
- path/to/file2.md

## Files Read

- path/to/important-file.rs
- path/to/config.yaml

## Next Step

<what you were about to do when you needed input>

## Pending Decision

<what you need the user to decide>

## Context for Continuation

<any additional context needed to resume work>

## Related Memory

Links to related memory files (optional):
- [Architecture Decision: Event Sourcing](../architecture/event-sourcing.md)
- [Domain Concepts](../domain/taskflow-concepts.md)
```

### Checkpoint Naming Convention

Use: `<agent-type>-<ISO-8601-timestamp>.md`

Examples:
- `sdlc-discovery-2026-01-08T14:32:00Z.md`
- `sdlc-workflow-designer-2026-01-08T15:45:30Z.md`
- `sdlc-red-2026-01-08T16:00:00Z.md`

The timestamp ensures uniqueness and provides temporal context.

### Checkpoint Storage Location

Store checkpoints in the auto memory directory:

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
MEMORY_PATH="$HOME/.claude/projects/$(basename "$PROJECT_ROOT")/memory"
CHECKPOINT_DIR="$MEMORY_PATH/checkpoints"
mkdir -p "$CHECKPOINT_DIR"
```

### Checkpoint Cleanup

Periodically clean up old checkpoints (optional):

```bash
# Remove checkpoints older than 30 days
find "$CHECKPOINT_DIR" -name "*.md" -mtime +30 -delete
```

## Common Patterns

### Pattern 1: Simple Single Question

```bash
# Create checkpoint
STATE_FILE="$MEMORY_PATH/checkpoints/sdlc-red-2026-01-08T10:00:00Z.md"
cat > "$STATE_FILE" << 'EOF'
# sdlc-red Checkpoint

**Timestamp:** 2026-01-08T10:00:00Z
**Task:** Write failing test for user registration
**Agent:** sdlc-red

## Progress Summary

Started writing test, need to know which validation library to use.

## Files Created

- tests/user_registration_test.rs (partial)

## Next Step

Complete test implementation with chosen validation library.

## Pending Decision

Which validation library to use?
EOF

# Output AWAITING_USER_INPUT
echo "AWAITING_USER_INPUT"
cat << 'EOF'
{
  "context": "Writing failing test for user registration",
  "stateFile": "/home/user/.claude/projects/myapp/memory/checkpoints/sdlc-red-2026-01-08T10:00:00Z.md",
  "questions": [
    {
      "id": "validation_lib",
      "question": "Which validation library should we use?",
      "header": "Validation",
      "options": [
        {"label": "validator", "description": "Popular crate with derive macros"},
        {"label": "garde", "description": "Newer crate with better error messages"}
      ],
      "multiSelect": false
    }
  ]
}
EOF
```

### Pattern 2: Multiple Related Questions

```bash
# Create checkpoint with multiple pending decisions
STATE_FILE="$MEMORY_PATH/checkpoints/sdlc-discovery-2026-01-08T14:00:00Z.md"
cat > "$STATE_FILE" << 'EOF'
# sdlc-discovery Checkpoint

**Timestamp:** 2026-01-08T14:00:00Z
**Task:** Design system architecture
**Agent:** sdlc-discovery

## Progress Summary

Identified actors and initial workflows. Need technology stack decisions.

## Files Created

- docs/event_model/domain/overview.md
- docs/event_model/actors.md

## Next Step

Create detailed workflow diagrams with chosen technologies.

## Pending Decision

Need decisions on database and web framework.
EOF

# Output AWAITING_USER_INPUT with multiple questions
echo "AWAITING_USER_INPUT"
cat << 'EOF'
{
  "context": "Designing system architecture",
  "stateFile": "/home/user/.claude/projects/myapp/memory/checkpoints/sdlc-discovery-2026-01-08T14:00:00Z.md",
  "questions": [
    {
      "id": "database",
      "question": "Which database should we use?",
      "header": "Database",
      "options": [
        {"label": "PostgreSQL", "description": "Relational, ACID, mature"},
        {"label": "MongoDB", "description": "Document store, flexible schema"}
      ],
      "multiSelect": false
    },
    {
      "id": "framework",
      "question": "Which web framework?",
      "header": "Framework",
      "options": [
        {"label": "Axum", "description": "Async, tower-based"},
        {"label": "Actix", "description": "Actor model, mature"}
      ],
      "multiSelect": false
    }
  ]
}
EOF
```

### Pattern 3: Continuing from Checkpoint

```bash
# When continuing from checkpoint
# Read state file
STATE_FILE="/home/user/.claude/projects/myapp/memory/checkpoints/sdlc-red-2026-01-08T10:00:00Z.md"
STATE_CONTENT=$(cat "$STATE_FILE")

# Parse sections (basic grep approach)
PROGRESS=$(echo "$STATE_CONTENT" | sed -n '/## Progress Summary/,/##/p' | tail -n +2 | head -n -1)
FILES_CREATED=$(echo "$STATE_CONTENT" | sed -n '/## Files Created/,/##/p' | tail -n +2 | head -n -1)
NEXT_STEP=$(echo "$STATE_CONTENT" | sed -n '/## Next Step/,/##/p' | tail -n +2 | head -n -1)

# Read files created
for file in $(echo "$FILES_CREATED" | grep -oP '(?<=- ).*'); do
  echo "Reading $file..."
  cat "$file"
done

# Continue work with restored context
echo "Continuing from checkpoint..."
echo "Progress so far: $PROGRESS"
echo "Next step: $NEXT_STEP"
```

## Integration with Memory Protocol

This protocol works seamlessly with the memory-protocol skill:

**Before requesting input:**
- Search memory for similar past decisions (avoid re-asking)
- Store discovered conventions/patterns to memory

**After receiving input:**
- Store user's decision to memory for future reference
- Link decision to relevant domain concepts

**Example:**
```bash
# Before asking about validation library, check memory
grep -r "validation library" "$MEMORY_PATH" --include="*.md"

# If not found, ask user
# After receiving answer, store to memory
cat > "$MEMORY_PATH/architecture/validation-choice.md" << 'EOF'
# Validation Library Choice

**Date:** 2026-01-08
**Decision:** Use validator crate
**Rationale:** Team familiar with derive macros, mature ecosystem

## Usage Pattern

```rust
#[derive(Validate)]
struct User {
    #[validate(email)]
    email: String,
}
```
EOF
```

## Troubleshooting

### Issue: Checkpoint File Not Found on Continuation

**Symptom:** Agent receives state file path but file doesn't exist.

**Causes:**
1. Path constructed incorrectly (typo in PROJECT_ROOT)
2. File not created before AWAITING_USER_INPUT output
3. Different PROJECT_ROOT between invocations (e.g., symlinks)

**Solution:**
- Use absolute paths (not relative)
- Verify file exists immediately after creation
- Test with `ls -l "$STATE_FILE"` before outputting AWAITING_USER_INPUT

### Issue: Context Not Fully Restored

**Symptom:** Agent continues but missing key context from before.

**Causes:**
1. Checkpoint file missing important information
2. Forgot to list all created files
3. Context was in agent's memory, not persisted to files

**Solution:**
- Be comprehensive in checkpoint "Progress Summary"
- List ALL files created (even temporary ones if relevant)
- Store context in checkpoint file, not just in agent's ephemeral memory

### Issue: User Answers Don't Match Checkpoint Context

**Symptom:** Answers don't make sense for the questions in checkpoint.

**Causes:**
1. Main agent sent wrong questions to user
2. Checkpoint `questions` array doesn't match actual needs
3. Question IDs don't match what agent expects

**Solution:**
- Double-check questions array before outputting AWAITING_USER_INPUT
- Use descriptive question IDs that match checkpoint context
- Test the full flow (create checkpoint, output AWAITING_USER_INPUT, parse response)

## References

**Related Documentation:**
- memory-protocol skill - File-based knowledge management
- user-input-protocol skill - General pattern for user input in agents

**External Resources:**
- Claude Code issue #13619: Resume parameter bug
- Auto memory directory: ~/.claude/projects/<project-path>/memory/
