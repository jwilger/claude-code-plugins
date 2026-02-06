---
name: memory-protocol
version: 2.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Knowledge accumulation and retrieval patterns for file-based agent memory
tags:
  - memory
  - file-based
  - learning
  - context
  - grep
portability: high
dependencies: []
allowed-tools: Bash(grep *), Bash(find *), Bash(ls *), Bash(cat *), Bash(mkdir *)
---

# Memory Protocol

**Version:** 2.0.0
**Portability:** High

---

## Memory Directory

Memory is stored in `~/.claude/projects/<project-path>/memory/` and persists across sessions. Claude Code's auto memory feature manages this directory automatically.

## Objective

Defines patterns for systematic knowledge accumulation and retrieval in agent workflows, enabling agents to learn from past experiences and avoid repeating work.

**Purpose:** Build institutional knowledge over time, recall solutions to previously-solved problems, and avoid context loss between sessions.

**Scope:**
- **Included:** Recall-before-act pattern, storage patterns, search strategies, knowledge organization
- **Excluded:** Specific memory system implementations, storage backends, MCP server details

---

## Core Principles

### Principle 1: Recall Before Act (Search First)

**The Principle:** Before starting any task or debugging any problem, search accumulated knowledge for relevant past experiences.

**Why this matters:** The most wasteful work is work you've already done. Searching memory first prevents repeating solutions, rediscovering conventions, and re-debugging known issues.

**How to apply:**
1. Before starting a task, search for similar past work
2. Before debugging an error, search for that error message
3. Before making architectural decisions, search for past decisions
4. Use search results to inform current work

**Example:**
```
# Bad workflow
User: "Fix the login bug"
Agent: Immediately starts debugging from scratch
        (Wastes 30 minutes rediscovering root cause)

# Good workflow
User: "Fix the login bug"
Agent: Search memory: "login bug authentication error"
       Found: "Login fails when session expires - solution: refresh token"
       Apply known solution
       (Fixes in 2 minutes)
```

**Search triggers:**
- Starting any new task
- Encountering an error
- Making design decisions
- Unsure about conventions
- Before asking user questions (maybe already answered)

### Principle 2: Remember After Discovery (Capture Insights)

**The Principle:** After solving non-obvious problems, learning conventions, or making decisions, immediately store that knowledge.

**Why this matters:** Knowledge not captured is knowledge lost. Future you (or other agents) will encounter the same problems and waste time if solutions aren't stored.

**What to remember:**
- **Solutions:** How you fixed non-obvious problems
- **Conventions:** Project-specific patterns discovered
- **Decisions:** Why you chose approach A over B
- **User preferences:** Workflows, tools, style choices the user prefers
- **Tool quirks:** Unexpected behaviors of libraries, APIs, CLIs
- **Root causes:** Deep understanding from debugging sessions

**What NOT to remember:**
- Obvious information (standard library usage)
- One-time facts (file paths, temporary values)
- Information already well-documented elsewhere
- Noise (every small step taken)

**How to apply:**
```
# After solving a problem
Agent: Discovered that API requires OAuth2 token in X-Custom-Auth header (not standard Authorization header)
Action: Store memory: "API authentication quirk: Use X-Custom-Auth header for OAuth2 tokens"

# After learning convention
Agent: Noticed all test files use suffix _test.py (not test_*.py)
Action: Store memory: "Project convention: Test files named <module>_test.py"

# After architectural decision
Agent: Chose event sourcing over CRUD for audit requirements
Action: Store memory: "Architecture: Using event sourcing. Rationale: Audit log requirement needs full history"
```

### Principle 3: Knowledge Graph Structure (Connect Related Information)

**The Principle:** Memories should be connected to related memories, forming a knowledge graph rather than isolated facts.

**Why this matters:** Connected knowledge is more discoverable and provides richer context. Finding one memory can lead to discovering related knowledge.

**How to apply:**
- Link solutions to the problems they solve
- Connect architectural decisions to the requirements that drove them
- Relate conventions to the codebase areas where they apply
- Associate user preferences with the features they affect

**Example (Conceptual):**
```
Memory 1: "Authentication uses JWT tokens"
  └─ Related to: Memory 2 "JWT secret stored in environment variable JWT_SECRET"
      └─ Related to: Memory 3 "Environment variables loaded from .env file"

Query: "How does authentication work?"
Result: Finds all 3 related memories (complete picture)
```

### Principle 4: Prime Directive (Knowledge Accumulation is Critical)

**The Principle:** Treat knowledge accumulation and retrieval as a primary responsibility, not an optional nice-to-have.

**Why this matters:** Agents without memory repeat mistakes, waste time, and don't improve. Memory is what enables learning and compound productivity gains.

**How to apply:**
- Make recall and remember part of every workflow
- Set reminders at natural checkpoints (task start, error encountered, task complete)
- Proactively store discoveries before context truncation
- Review and refine stored knowledge periodically

**Workflow integration:**
```
Task start → Recall relevant knowledge
  ↓
Work on task
  ↓
Encounter problem → Recall solutions
  ↓
Solve problem → Remember solution
  ↓
Task complete → Remember insights
```

---

## Constraints and Boundaries

### DO:
- Search memory BEFORE starting any non-trivial task
- Search for error messages before debugging
- Store solutions to non-obvious problems
- Store project conventions as discovered
- Store architectural decisions with rationale
- Connect related memories
- Be concise (don't store essays)
- Use clear, searchable language

### DON'T:
- Skip search because "this seems simple" (simple problems have simple solutions you may have seen)
- Store obvious information (language basics, standard library)
- Store one-time facts (temporary values, session-specific data)
- Store without context ("fixed bug" - which bug? how?)
- Wait until "later" to store memories (you'll forget)
- Store duplicate information (search first to check)

**Rationale:** Systematic knowledge management compounds over time. Initial overhead is small compared to long-term productivity gains.

---

## Usage Patterns

### Pattern 1: Task Start Recall

**Scenario:** Starting work on a new feature.

**Approach:**

**Step 1: Query for related work**
```
Task: "Add email notification when order ships"

Search: "email notification" OR "order shipping" OR "email sending"

Results:
- Memory 1: "Email service uses SendGrid, API key in SENDGRID_API_KEY"
- Memory 2: "Email templates in templates/email/"
- Memory 3: "Order model has shipment_date field"
```

**Step 2: Use knowledge to inform work**
- Use SendGrid (don't research email providers)
- Follow existing template structure
- Hook into shipment_date field

**Benefits:**
- Start with context (not from zero)
- Follow established patterns
- Avoid rediscovering tools/conventions

### Pattern 2: Error Resolution Recall

**Scenario:** Encountering an error during development.

**Approach:**

**Step 1: Search for error**
```
Error: "ssl.SSLError: [SSL: CERTIFICATE_VERIFY_FAILED]"

Search: "CERTIFICATE_VERIFY_FAILED"

Result:
- Memory: "macOS SSL error: Install certificates.command after Python install"
```

**Step 2: Apply known solution**
```bash
/Applications/Python 3.x/Install Certificates.command
```

**Step 3: If NOT found, debug and remember**
```
(After solving novel error)

Store: "SSL error on macOS: Python doesn't use system certificates by default. Run Install Certificates.command in Python installation directory to fix."
```

**Benefits:**
- Instant solution to known problems
- Build catalog of fixes over time
- Future errors resolve faster

### Pattern 3: Convention Discovery and Storage

**Scenario:** Working in an unfamiliar codebase.

**Approach:**

**While working, notice patterns:**
```
Observation 1: All API routes start with /api/v1/
Observation 2: Test files named <module>_test.py
Observation 3: Database models in src/models/
Observation 4: Validation uses Pydantic models
```

**Store each convention:**
```
Store: "Project convention: API routes prefixed with /api/v1/"
Store: "Project convention: Test files named <module>_test.py"
Store: "Architecture: Database models in src/models/, ORMs with SQLAlchemy"
Store: "Architecture: Input validation using Pydantic models"
```

**Next time in this codebase:**
```
Search: "API route convention"
Found: "API routes prefixed with /api/v1/"
Action: Follow established pattern automatically
```

**Benefits:**
- Consistency (follow existing patterns)
- Speed (don't rediscover conventions each session)
- Onboarding (new agents find conventions quickly)

### Pattern 4: Architectural Decision Records (Lightweight)

**Scenario:** Making a significant architectural choice.

**Approach:**

**During decision:**
```
Decision: Use event sourcing for order history

Rationale:
- Requirement: Full audit trail of all order changes
- Requirement: Ability to replay state at any point in time
- Alternatives considered: CRUD with changelog table (insufficient)
```

**Store decision:**
```
Store: "Architecture: Order system uses event sourcing. Rationale: Audit requirements need full history and state replay capability. Alternative CRUD+changelog rejected (can't replay state)."
```

**Benefits:**
- Future work understands why architecture exists
- Prevents undoing decisions without understanding tradeoffs
- Helps onboard new team members

---

## Integration with Other Skills

**Works well with:**
- **debugging-protocol:** Search for error fixes before 4-phase investigation
- **user-input-protocol:** Store user's answers to avoid re-asking same questions
- **tdd-constraints:** Store test patterns and domain modeling insights
- **orchestration-protocol:** Orchestrator recalls workflow state and conventions

**Prerequisites:**
- Memory/knowledge system (file-based markdown, database, or similar)
- Consistent search interface (grep, full-text search, etc.)
- Persistent storage (survives session restarts)

---

## Common Pitfalls

### Pitfall 1: Skipping Recall ("This is Simple")

**Problem:** "This looks straightforward, I'll just start"

**Solution:** Search anyway. "Simple" problems often have non-obvious solutions already discovered.

### Pitfall 2: Storing Too Much Detail

**Problem:** Storing verbose explanations, full code snippets, essays

**Solution:** Store concise summaries with keywords. Details can be found in code/docs.

**Example:**
```
❌ Bad: "When I was working on the authentication system, I discovered that the JWT library we're using (jsonwebtoken version 8.5.1) requires the secret to be passed as a Buffer object, not a string, and if you pass a string it will throw a cryptic error message that says 'secret must be a Buffer' which took me 2 hours to figure out because the documentation is unclear..."

✓ Good: "JWT library requires secret as Buffer, not string. Use Buffer.from(secret) to convert."
```

### Pitfall 3: Forgetting to Store Discoveries

**Problem:** Solve problem, move on, forget to store solution

**Solution:** Add "remember" step to workflow checkpoints:
- After solving error
- After making decision
- Before ending task
- Before context truncation

### Pitfall 4: Storing Duplicate Information

**Problem:** Storing same fact multiple times with slight variations

**Solution:** Search before storing. If similar memory exists, update it instead of creating duplicate.

---

## Examples

### Example 1: File-Based Implementation (Primary)

**Tool:** Markdown files in auto memory directory

**Recall pattern:**
```bash
# Search for authentication patterns
MEMORY_PATH="$HOME/.claude/projects/<project-path>/memory"
grep -r -i "jwt token" "$MEMORY_PATH" --include="*.md"

# Read relevant files
cat "$MEMORY_PATH/architecture/jwt-authentication.md"
```

**Remember pattern:**
```bash
# Create new memory file
cat > "$MEMORY_PATH/architecture/jwt-token-refresh.md" << 'EOF'
# JWT Token Refresh Pattern

**Date:** 2026-02-04
**Category:** architecture
**Project:** MyApp

## Problem / Context

JWT tokens expire after 1 hour, causing mid-session auth failures that disrupt user experience.

## Solution / Discovery

Implement proactive token refresh every 15 minutes to prevent expiration during active sessions.

## Details

```javascript
// In App.tsx
useEffect(() => {
  const refreshInterval = setInterval(refreshToken, 15 * 60 * 1000);
  return () => clearInterval(refreshInterval);
}, []);
```

## Related

- See also: [JWT Authentication](jwt-authentication.md)
- Token storage: [Local Storage Patterns](../tools/localstorage-patterns.md)
EOF
```

### Example 2: Legacy Memento MCP Implementation (Deprecated)

**Note:** The sdlc plugin v6.0.0+ no longer uses Memento MCP. This example is kept for reference only.

**Tool:** Memento MCP server (knowledge graph) - **NO LONGER SUPPORTED**

**Recall pattern:**
```bash
# Search for error fix
grep -r "CERTIFICATE_VERIFY_FAILED" .memories/

# Output: .memories/python-ssl.md
# Solution: Install certificates.command
```

**Remember pattern:**
```bash
# Store new discovery
cat >> .memories/python-ssl.md << 'EOF'
## SSL Certificate Error (macOS)

**Problem:** `ssl.SSLError: [SSL: CERTIFICATE_VERIFY_FAILED]`

**Solution:** Python on macOS doesn't use system certificates.
Run: `/Applications/Python 3.x/Install Certificates.command`

**Date:** 2026-02-04
**Context:** Encountered when using requests library
EOF
```

### Example 3: Database Implementation

**Tool:** PostgreSQL or SQLite with full-text search

**Schema:**
```sql
CREATE TABLE memories (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[],
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_memories_content ON memories USING GIN(to_tsvector('english', content));
```

**Recall pattern:**
```sql
-- Search for authentication memories
SELECT title, content
FROM memories
WHERE to_tsvector('english', content) @@ plainto_tsquery('english', 'authentication jwt token')
ORDER BY ts_rank(to_tsvector('english', content), plainto_tsquery('english', 'authentication jwt token')) DESC
LIMIT 5;
```

**Remember pattern:**
```sql
-- Store new memory
INSERT INTO memories (title, content, tags)
VALUES (
  'JWT Token Refresh Pattern',
  'Refresh tokens proactively every 15 minutes to avoid mid-session auth failures. Implemented in App.tsx with setInterval.',
  ARRAY['authentication', 'jwt', 'solution']
);
```

### Example 4: Integration with Task Workflow

**Scenario:** Agent working through TDD cycle.

**Task Start:**
```
Task: "Write failing test for user registration"

Recall:
- Search: "user registration test patterns"
- Found: "Registration tests should verify email uniqueness"
- Found: "Use factory pattern for test users (UserFactory.build)"

Apply:
- Write test using UserFactory
- Include email uniqueness assertion
```

**After RED Phase:**
```
Remember:
- "Project convention: Test factories in tests/factories.py"
- "Domain rule: User emails must be unique (enforced by database constraint)"
```

**After Encountering Error:**
```
Error: "IntegrityError: duplicate key value violates unique constraint"

Recall:
- Search: "IntegrityError duplicate key"
- Found: "This means trying to create duplicate unique value"

Solution: Discovered test wasn't cleaning up between runs

Remember:
- "Test cleanup: Use pytest fixtures with 'autouse=True' to reset database"
```

---

## Verification Checklist

Use this checklist to verify you're following the memory protocol:

- [ ] Searched memory before starting task
- [ ] Searched for error message before debugging
- [ ] Stored solution after solving non-obvious problem
- [ ] Stored conventions as discovered
- [ ] Stored architectural decisions with rationale
- [ ] Connected related memories (if supported by system)
- [ ] Used clear, searchable language in memories
- [ ] Avoided storing obvious or one-time information
- [ ] Proactively stored before context truncation

---

## References

**Source Documentation:**
- sdlc plugin: commands/remember.md and commands/recall.md
- Claude Code auto memory: ~/.claude/projects/<project-path>/memory/

**Related Skills:**
- debugging-protocol - Search for fixes before 4-phase debugging
- user-input-protocol - Store user answers to avoid re-asking

**External Resources:**
- File-based knowledge management
- Grep and text search patterns
- Markdown linking and organization

---

## Version History

### v2.0.0 (2026-02-04)
- **BREAKING:** Migrated from Memento MCP to file-based auto memory
- Updated primary example to use markdown files and grep
- Deprecated Memento MCP examples (kept for reference)
- Simplified prerequisites (no external MCP server required)
- Updated recall pattern to use grep-based search
- Updated remember pattern to use markdown file creation

### v1.0.0 (2026-02-04)
- Initial extraction from sdlc plugin
- Recall-before-act pattern
- Knowledge accumulation strategies
- Implementation examples (Memento MCP, file-based, database)
- High portability (pattern is universal, tools vary)

---

## Metadata

**Extraction Source:** sdlc/commands/remember.md and sdlc/commands/recall.md
**Extraction Date:** 2026-02-04
**Last Updated:** 2026-02-04 (v2.0.0 - migrated to file-based)
**Compatibility:** High portability (pattern is universal, file-based implementation is simple and portable)
**License:** MIT

## Migration Notes (v2.0.0)

**For users upgrading from Memento MCP:**
- Semantic search replaced with keyword-based grep
- Graph relationships replaced with manual markdown links
- Structured entities replaced with markdown files
- No external MCP server required
- Trade-off: Simpler setup, but less sophisticated search

**Advantages of file-based:**
- Zero configuration (built into Claude Code)
- Transparent storage (easy to read/edit manually)
- Version control friendly (can commit memory to git)
- Portable (just markdown files)

**Limitations of file-based:**
- No semantic similarity search (only exact keyword matching)
- No automatic relationship traversal
- Manual organization required
- Slower search on large memory bases
