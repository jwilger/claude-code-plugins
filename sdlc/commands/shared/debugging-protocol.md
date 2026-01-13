---
description: INVOKE when ANY bug, test failure, or unexpected behavior occurs. 4-phase investigation required.
user-invocable: false
---

# Debugging Protocol (MANDATORY)

When encountering ANY bug, test failure, or unexpected behavior, follow this 4-phase investigation protocol. **NO fixes until you complete investigation.**

## The Iron Law

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

Symptom fixes are failure. They hide bugs, don't solve them.

## Before Debugging: Search Memento

**ALWAYS search memento first:**
```
mcp__memento__semantic_search({ "query": "<error message> fix solution" })
```

If a known solution exists, apply it. If you solve a novel problem, store the solution.

## Phase 1: Root Cause Investigation

**Goal**: Understand WHAT is happening, not guess at solutions.

### Actions (Do ALL of these)

1. **Read error messages carefully**
   - Read the FULL error, not just the first line
   - Note the exact file:line and error type
   - Don't skim past stack traces

2. **Reproduce consistently**
   - Can you make the error happen every time?
   - What exact steps trigger it?
   - Does it happen in isolation (single test) or only with others?

3. **Check recent changes**
   ```bash
   git diff HEAD~5  # What changed recently?
   git log --oneline -10  # What was committed?
   ```
   - Did this work before?
   - What changed between "working" and "broken"?

4. **Gather evidence in multi-component systems**
   - If error crosses boundaries (API, DB, external service):
   - Add diagnostic logging at boundaries
   - Trace data flow through the system
   - Identify WHERE the bug first manifests

5. **Trace data flow backward**
   - Start at the error location
   - Follow the data backward through the call stack
   - Find where the "bad" value originated

### Phase 1 Output

Before proceeding to Phase 2, you MUST be able to state:
- "The error is: [exact message]"
- "It happens when: [exact reproduction steps]"
- "The data flow is: [A -> B -> C -> error]"
- "Recent changes that might be relevant: [list]"

## Phase 2: Pattern Analysis

**Goal**: Find working examples to compare against.

### Actions

1. **Find working examples in the codebase**
   - Is there similar code that works?
   - What's different about your case?
   ```bash
   # Find similar patterns
   grep -r "similar_function" --include="*.rs" src/
   ```

2. **Read reference implementation COMPLETELY**
   - Don't skim the working example
   - Understand WHY it works
   - Note all the pieces that make it work

3. **Identify differences (however small)**
   - Compare your code line-by-line with working code
   - Small differences cause big bugs
   - Check: imports, types, error handling, edge cases

4. **Understand dependencies**
   - What does the working code depend on?
   - Configuration, environment, state?
   - Are those same conditions present in your case?

### Phase 2 Output

Before proceeding to Phase 3, you MUST be able to state:
- "Working example: [file:line]"
- "Key differences: [list]"
- "Dependencies: [what working code relies on]"

## Phase 3: Hypothesis and Testing

**Goal**: Form and test a SINGLE theory.

### Actions

1. **Form a single hypothesis**
   - Write it down: "I believe the bug is caused by [X]"
   - Only ONE hypothesis at a time
   - If multiple candidates, pick the most likely

2. **Test minimally**
   - Make ONE change to test your hypothesis
   - Don't fix multiple things at once
   - If it doesn't work, UNDO and try a different hypothesis

3. **Verify before continuing**
   - Did the change confirm or refute your hypothesis?
   - If confirmed: proceed to fix
   - If refuted: return to Phase 1 with new information

### Phase 3 Output

Before proceeding to Phase 4, you MUST be able to state:
- "Hypothesis: [specific theory]"
- "Test: [what I changed to test it]"
- "Result: [confirmed/refuted]"

## Phase 4: Implementation

**Goal**: Fix with confidence.

### Actions

1. **Create a failing test case** (if one doesn't exist)
   - The test should fail BEFORE your fix
   - The test should pass AFTER your fix
   - This proves your fix actually addresses the bug

2. **Implement a single fix**
   - ONE change that addresses the root cause
   - Not a workaround, not a hack
   - The fix should be at the SOURCE, not the symptom

3. **Verify the fix**
   - Run the failing test - does it pass?
   - Run the full test suite - any regressions?
   - Run the original reproduction steps - fixed?

### Escalation Rule

**If 3+ fixes have failed**: STOP trying fixes. Question the architecture.

After 3 failed attempts:
- The problem is likely deeper than you think
- The architecture may be wrong
- Return to Phase 1 with "why do my fixes keep failing?" as the question
- Consider: Is this a domain modeling issue? (escalate to `sdlc:domain`)

## Rationalization Red Flags

Watch for these thoughts - they are ALWAYS wrong:

| If you're thinking... | The truth is... | Correct action |
|-----------------------|-----------------|----------------|
| "I know what this is, let me just fix it" | You're skipping investigation | Do Phase 1 first |
| "Quick fix, then I'll investigate if it doesn't work" | You'll never investigate after the "fix" | Do Phase 1 FIRST |
| "Let me try a few things" | Random changes hide bugs | ONE hypothesis at a time |
| "This worked before, must be environment" | Assumptions cause bugs | Verify with evidence |
| "I'll just add this check to prevent the error" | Symptom fix, not root cause | Find WHY it happens |
| "Fourth time's the charm" | 3+ failures = architecture problem | Stop. Reconsider approach |

## Integration with Memory Protocol

### Before Debugging
```
/sdlc:recall "<error message> root cause fix"
```

### After Solving Novel Bug
```
/sdlc:remember "Debugging insight: <error> caused by <root cause>. Solution: <fix>."
```

## Defense in Depth (After Fix)

Once you fix a bug, consider adding validation at multiple layers:

| Layer | Purpose | Example |
|-------|---------|---------|
| Entry | Validate inputs early | Type constructors, parse-don't-validate |
| Business | Verify invariants | Assertions, preconditions |
| Environment | Check runtime assumptions | Config validation, feature flags |
| Debug | Forensics for future | Structured logging, error context |

The goal: Make this class of bug **structurally impossible**, not just fixed this once.
