---
user-invocable: false
name: debugging-protocol
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Systematic 4-phase debugging methodology for finding and fixing root causes
tags:
  - debugging
  - root-cause-analysis
  - investigation
  - bug-fixing
portability: universal
dependencies: []
---

# Debugging Protocol

**Version:** 1.0.0
**Portability:** Universal

---

## Objective

Defines a systematic 4-phase investigation process for debugging any bug, test failure, or unexpected behavior. Enforces root cause analysis before attempting fixes.

**Purpose:** Prevent symptom fixes (which hide bugs) and ensure deep understanding of problems before implementing solutions.

**Scope:**
- **Included:** Investigation methodology, hypothesis testing, pattern analysis, verification steps
- **Excluded:** Language-specific debugging tools (framework-agnostic principles)

---

## Core Principles

### Principle 1: No Fixes Without Investigation (The Iron Law)

**The Iron Law:** Never attempt a fix until you complete root cause investigation.

**Why this matters:** Symptom fixes hide bugs rather than solving them. They create technical debt, mask deeper issues, and often cause new bugs elsewhere.

**How to apply:**
- When you see a bug, resist the urge to "just fix it"
- Complete all 4 phases before changing code
- If you're tempted to skip investigation, that's a red flag

**Example:**
```
❌ Bad: "Error says null pointer. Let me add a null check."
✓ Good: "Error says null pointer. Why is this null? (investigate)"

Result:
- Bad approach: Symptom fixed, root cause remains, bug appears elsewhere
- Good approach: Found initialization bug, fixed at source, entire class prevented
```

### Principle 2: Four-Phase Investigation Process

**The Principle:** Follow a structured investigation: Root Cause → Pattern Analysis → Hypothesis Testing → Implementation.

**Why this matters:** Structured investigation prevents random debugging and ensures you understand the problem completely before attempting solutions.

**The Four Phases:**
1. **Root Cause Investigation:** Understand WHAT is happening
2. **Pattern Analysis:** Find working examples to compare against
3. **Hypothesis Testing:** Form and test a single theory
4. **Implementation:** Fix with confidence

**How to apply:** Complete each phase before moving to the next. Document your findings at each phase.

### Principle 3: One Hypothesis at a Time

**The Principle:** Test a single hypothesis with minimal changes. If it fails, undo and try a different theory.

**Why this matters:** Changing multiple things simultaneously makes it impossible to know which change had which effect. This wastes time and compounds confusion.

**How to apply:**
1. State your hypothesis explicitly: "I believe the bug is caused by [X]"
2. Make ONE change to test it
3. Observe the result
4. If wrong, UNDO the change
5. Form a new hypothesis with new information

**Example:**
```
❌ Bad: "Let me change the import, add a null check, and update the type signature"
✓ Good:
  - Hypothesis 1: "The import is wrong" → Test → Refuted → Undo
  - Hypothesis 2: "The type is incorrect" → Test → Confirmed → Fix

Result: Clear understanding of what actually solved the problem
```

### Principle 4: Escalation After Three Failures

**The Principle:** If three fix attempts fail, stop trying fixes. The problem is deeper than you think.

**Why this matters:** Repeated failures signal architectural problems or domain modeling issues, not simple bugs. Continuing to try fixes wastes time.

**How to apply:**
- Track your fix attempts
- After 3 failures, STOP
- Return to Phase 1 with a new question: "Why do my fixes keep failing?"
- Consider whether this is a design problem, not a bug

**Example:**
```
Attempt 1: Add validation → Still fails
Attempt 2: Change order → Still fails
Attempt 3: Different algorithm → Still fails

STOP. Question the architecture:
- Are we solving the wrong problem?
- Is the domain model incorrect?
- Is this a fundamental design issue?
```

---

## Constraints and Boundaries

### DO:
- Complete root cause investigation before attempting any fix
- Read error messages fully (not just the first line)
- Reproduce bugs consistently before debugging
- Compare against working examples
- Test one hypothesis at a time
- Create failing tests before fixes
- Stop after 3 failed attempts and reconsider

### DON'T:
- Jump straight to a fix without investigation (symptom fixing)
- Skim error messages or stack traces
- Try "a few things" to see what works (random debugging)
- Change multiple things simultaneously
- Assume "it worked before, must be environment" without evidence
- Continue after 3 failed fixes (escalate instead)
- Add checks that prevent errors without understanding why they occur

**Rationale:** Disciplined investigation finds root causes. Random debugging wastes time and hides problems.

---

## Usage Patterns

### Pattern 1: Test Failure Investigation

**Scenario:** Test that passed before now fails after code changes.

**Approach:**

**Phase 1: Root Cause Investigation**
1. Read full error message and stack trace
2. Reproduce consistently (does it fail every time?)
3. Check recent changes:
   ```bash
   git diff HEAD~5  # What changed?
   git log --oneline -10  # Recent commits
   ```
4. Note exact file:line where failure occurs

**Phase 2: Pattern Analysis**
1. Find similar tests that pass
2. Compare test setup, assertions, data
3. Identify differences (imports, state, configuration)

**Phase 3: Hypothesis Testing**
1. Hypothesis: "The bug was introduced in commit X"
2. Test: Checkout commit before X, run test
3. Result: Test passes → Hypothesis confirmed
4. Review changes in commit X to find root cause

**Phase 4: Implementation**
1. Create minimal test reproducing the bug
2. Fix the root cause identified in commit X
3. Verify: New test passes, all other tests pass

### Pattern 2: Multi-Component System Debugging

**Scenario:** Error occurs in distributed system (frontend → API → database).

**Approach:**

**Phase 1: Root Cause Investigation**
1. Add diagnostic logging at component boundaries
2. Trace data flow through the system
3. Identify WHERE the bug first manifests (which component?)
4. Trace data backward from error to origin

**Phase 2: Pattern Analysis**
1. Find working requests/transactions
2. Compare successful vs failing data flow
3. Identify differences in data shape, timing, state

**Phase 3: Hypothesis Testing**
1. Hypothesis: "The API is receiving malformed data from frontend"
2. Test: Log API inputs, compare to expected schema
3. Result: Confirmed - frontend sending string where number expected

**Phase 4: Implementation**
1. Add validation at API entry point (defense)
2. Fix frontend to send correct type (root cause)
3. Add integration test covering this data flow

### Pattern 3: Escalation to Architecture Review

**Scenario:** Three fix attempts have failed.

**Approach:**

**After 3rd failure:**
1. STOP attempting fixes
2. Document what you've tried and why each failed
3. Ask architectural questions:
   - Is this the wrong abstraction?
   - Is the domain model accurate?
   - Are we solving the wrong problem?
4. Seek broader review (team discussion, pair debugging, domain expert)

**Example:**
```
Problem: "User authentication fails intermittently"

Attempt 1: Add retry logic → Still fails
Attempt 2: Increase timeout → Still fails
Attempt 3: Better error handling → Still fails

STOP. Architectural questions:
- Is session management the right approach?
- Should this be stateless with tokens instead?
- Is the database schema correct?

Result: Discovered fundamental session model flaw, redesigned auth flow
```

---

## Integration with Other Skills

**Works well with:**
- **tdd-constraints:** When test fails, use debugging protocol to investigate before modifying code
- **user-input-protocol:** When debugging hits ambiguous decision point, pause and ask user
- **domain-modeling:** If 3+ fixes fail, escalate to domain agent for modeling review

**Prerequisites:**
- Source control (git) for checking recent changes
- Test suite for verification
- Ability to reproduce bugs consistently

---

## Common Pitfalls

### Pitfall 1: Jumping to a Fix

**Problem:** "I know what this is, let me just fix it" (skipping investigation)

**Solution:** Resist the urge. Do Phase 1 investigation FIRST, even if you think you know the answer. You're often wrong.

### Pitfall 2: Random Debugging ("Try a Few Things")

**Problem:** Changing multiple things without hypothesis, hoping something works

**Solution:** Form explicit hypothesis. Test ONE thing. Observe result. Learn from it.

### Pitfall 3: Symptom Fixing

**Problem:** "Let me add this check to prevent the error" without understanding why it occurs

**Solution:** Ask "why is this happening?" not "how do I hide this?" Fix the source, not the symptom.

### Pitfall 4: Ignoring Pattern Analysis

**Problem:** Skipping working examples, trying to fix in isolation

**Solution:** Always find working code. Understanding why something works is as important as understanding why something fails.

### Pitfall 5: Persisting After Failures

**Problem:** "Fourth time's the charm" (continuing after 3+ failed fixes)

**Solution:** 3 failures = architectural problem signal. Stop fixing, start redesigning.

---

## Examples

### Example 1: Null Pointer Investigation (Any Language)

**Phase 1: Root Cause Investigation**
```
Error: "NullPointerException at user_service.rs:42"
File: user_service.rs
Line: 42
Code: let email = user.email.unwrap();

Reproduction: Always fails for user_id = 123, never fails for user_id = 456

Recent changes: Added email validation to registration (3 days ago)

Data flow: Database → UserService.load() → user.email → unwrap()
```

**Phase 2: Pattern Analysis**
```
Working example: User 456 has email in database
Failing example: User 123 has NULL email in database

Difference: User 123 was created BEFORE email validation was added
           (email field nullable in DB for backward compatibility)

Dependencies: Database migration didn't backfill existing users
```

**Phase 3: Hypothesis Testing**
```
Hypothesis: "User 123 has NULL email because created before validation"

Test: Check database directly
  SELECT id, email FROM users WHERE id = 123;
  Result: email = NULL

Result: CONFIRMED - old users have NULL emails
```

**Phase 4: Implementation**
```
1. Create failing test:
   test_user_service_handles_missing_email() {
     user = User { id: 123, email: None };
     result = service.load(user);
     assert!(result.is_ok());  // Should handle gracefully
   }

2. Fix (two parts):
   a. Root cause: Backfill database (migration)
      UPDATE users SET email = 'placeholder@example.com' WHERE email IS NULL;
   b. Defense: Handle None case in code
      let email = user.email.unwrap_or_default();

3. Verify:
   - Test passes
   - All users now have emails
   - No more NullPointerException
```

### Example 2: Integration Test Failure (Web Application)

**Phase 1: Root Cause Investigation**
```
Error: "Expected 200 OK, got 500 Internal Server Error"
Test: test_user_registration

Reproduction: Fails consistently in CI, passes locally

Recent changes: Updated authentication library (yesterday)

Environment difference:
- Local: SQLite in-memory database
- CI: PostgreSQL 14
```

**Phase 2: Pattern Analysis**
```
Working example: Local test with SQLite
Failing example: CI test with PostgreSQL

Difference investigation:
- Read auth library changelog
- Found: Library 2.0 uses PostgreSQL-specific JSON operators
- SQLite doesn't have these operators, but doesn't use them either

Dependencies:
- Auth library assumes PostgreSQL JSON support
- Library works with SQLite by accident (doesn't exercise JSON paths)
```

**Phase 3: Hypothesis Testing**
```
Hypothesis: "Auth library 2.0 uses PostgreSQL JSON operators incompatible with SQLite"

Test: Run local tests with PostgreSQL instead of SQLite
  docker run -p 5432:5432 postgres:14
  DATABASE_URL=postgresql://localhost/test cargo test

Result: CONFIRMED - local tests now fail with same error as CI
```

**Phase 4: Implementation**
```
1. Failing test already exists (test_user_registration)

2. Fix options:
   a. Pin auth library to 1.x (workaround)
   b. Migrate to PostgreSQL everywhere (align environments)
   c. Use database-agnostic JSON library (portable)

   Choice: (b) - Align local and CI environments

3. Implementation:
   - Update local dev setup to use PostgreSQL
   - Document in README
   - Update .env.example

4. Verify:
   - Local tests pass with PostgreSQL
   - CI tests pass
   - No environment discrepancies remain
```

### Example 3: Escalation Example (Three Failures)

**Scenario:** Performance bug (API response time > 5 seconds)

**Attempt 1:** Add caching
```
Hypothesis: "Database queries are slow, need caching"
Implementation: Add Redis cache for user queries
Result: FAILED - Still slow (5.2 seconds)
```

**Attempt 2:** Index database
```
Hypothesis: "Missing database indexes"
Implementation: Add index on users.email
Result: FAILED - Still slow (5.1 seconds, marginal improvement)
```

**Attempt 3:** Optimize query
```
Hypothesis: "N+1 query problem"
Implementation: Add eager loading for relationships
Result: FAILED - Still slow (4.8 seconds, still over limit)
```

**After 3rd failure - STOP AND ESCALATE:**
```
Question: "Why do performance fixes keep failing?"

Deeper investigation:
- Profile API with flamegraph
- Found: 90% of time spent in external service call (not database!)
- Root cause: Synchronous call to email validation API (3rd party)

Architectural problem:
- Wrong assumption: Database was the bottleneck
- Actual problem: Blocking I/O to external service
- Solution: Move email validation to async background job

Result: Response time < 200ms after architectural change
```

---

## Verification Checklist

Use this checklist to verify you're following the debugging protocol:

- [ ] Did Phase 1 root cause investigation before attempting fix
- [ ] Read complete error message and stack trace
- [ ] Reproduced bug consistently
- [ ] Checked recent changes (git log, git diff)
- [ ] Found working examples to compare against
- [ ] Formed explicit, written hypothesis
- [ ] Tested only ONE change at a time
- [ ] Undid failed hypothesis changes before trying new hypothesis
- [ ] Created failing test before implementing fix
- [ ] Verified fix solves root cause (not just symptom)
- [ ] Stopped after 3 failed attempts and escalated/reconsidered

**If you can't check all boxes, you're not following the protocol.**

---

## Rationalization Red Flags

Watch for these thoughts - they indicate you're about to skip the protocol:

| Thought | Reality | Correct Action |
|---------|---------|----------------|
| "I know what this is, let me just fix it" | You're skipping investigation | Do Phase 1 first |
| "Quick fix, then investigate if needed" | You'll never investigate after | Do Phase 1 FIRST |
| "Let me try a few things" | Random debugging hides bugs | ONE hypothesis at a time |
| "This worked before, must be environment" | Assumptions without evidence | Verify with evidence |
| "I'll add a check to prevent the error" | Symptom fix, not root cause | Find WHY it happens |
| "Fourth time's the charm" | 3+ failures = architecture problem | STOP. Escalate. |

**When you catch yourself thinking these things, STOP and return to the protocol.**

---

## References

**Source Documentation:**
- sdlc plugin: commands/shared/debugging-protocol.md

**Related Skills:**
- tdd-constraints - Integration with test-first development
- domain-modeling - Escalation for architectural issues

**External Resources:**
- Debugging: The 9 Indispensable Rules by David Agans
- Why Programs Fail by Andreas Zeller
- The Art of Debugging by Norman Matloff

---

## Version History

### v1.0.0 (2026-02-04)
- Initial extraction from sdlc plugin
- Generalized 4-phase debugging process
- Universal principles (language/framework-agnostic)
- Added multiple language examples (Rust, web, integration)
- Core insight: No fixes without investigation

---

## Metadata

**Extraction Source:** sdlc/commands/shared/debugging-protocol.md
**Extraction Date:** 2026-02-04
**Last Updated:** 2026-02-04
**Compatibility:** Universal (all languages and frameworks)
**License:** MIT
