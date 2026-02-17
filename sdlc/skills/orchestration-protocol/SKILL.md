---
name: orchestration-protocol
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Multi-agent orchestration patterns for delegation, coordination, and conflict resolution
tags:
  - orchestration
  - multi-agent
  - coordination
  - delegation
portability: medium
dependencies:
  - user-input-protocol
---

# Orchestration Protocol

**Version:** 1.0.0
**Portability:** Medium

---

## Objective

Defines patterns for orchestrating multiple specialized agents in complex workflows, including delegation strategies, context provision, conflict resolution, and workflow state management.

**Purpose:** Enable coordinated multi-agent systems where a main orchestrator delegates to specialized agents while maintaining workflow integrity and clear responsibility boundaries.

**Scope:**
- **Included:** Delegation patterns, context provision, agent specialization, conflict resolution, workflow coordination
- **Excluded:** Specific agent implementations, tool-specific orchestration APIs

---

## Core Principles

### Principle 1: Orchestrator Delegates, Never Acts Directly

**The Principle:** The main orchestrator coordinates work by delegating to specialized agents but never performs specialized work itself.

**Why this matters:** Mixing orchestration logic with specialized work creates single points of failure and makes systems harder to maintain. Specialization enables focused expertise.

**How to apply:**
- Orchestrator decides WHAT to do and WHO should do it
- Specialized agents decide HOW to do their specific work
- Orchestrator never writes code, edits files, or performs domain-specific tasks
- All specialized work flows through appropriate agents

**Example:**
```
❌ Bad: Orchestrator writes test directly
Orchestrator: (uses Write tool to create test file)

✓ Good: Orchestrator delegates to test-writing agent
Orchestrator: Delegate to TestWriter agent with context:
              "Create test for user authentication"
TestWriter: (writes test using domain knowledge)
```

### Principle 2: Fresh Context Per Agent (Zero Memory Assumption)

**The Principle:** Agents have zero context from the main conversation. Every delegation must include complete context.

**Why this matters:** Agents don't share conversation history. Assuming they know "what we discussed" leads to failures.

**What to provide:**
- File paths being modified
- Current state (what's passing/failing)
- Requirements (what "done" looks like)
- Domain constraints (types to use, patterns to follow)
- Error messages (exact text, not summaries)

**How to apply:**
```
❌ Bad: Vague delegation
"Continue where we left off"
"Fix the issue we discussed"
"You know what to do"

✓ Good: Complete context
"The test at `tests/auth_test.rs:45` fails with error: 'Email type not found'.
Create the Email type in `src/domain/types.rs` using newtype pattern.
Test expects: `Email::new(string) -> Result<Email, ValidationError>`"
```

**Template:**
```
WORKING_DIRECTORY: [Absolute path to project root]
TASK: [What to accomplish]
FILES: [Specific paths]
CURRENT STATE: [What exists, what's failing]
REQUIREMENTS: [Success criteria]
CONSTRAINTS: [Patterns to follow, types to use]
ERROR: [Exact error message if applicable]
```

### Principle 3: Workflow Gates Enforce Discipline

**The Principle:** Agents require explicit context confirmations before proceeding, preventing workflow step skipping.

**Why this matters:** Complex workflows have dependencies. Skipping steps (like domain review) leads to incomplete or incorrect work.

**Gate pattern:**
```
Agent checks for required context marker.
If missing → Reject with "GATE FAILED: Missing [context]"
If present → Proceed with work
```

**Example gates:**
```
Test-writing agent requires:
- Confirmation of acceptance criteria
- OR confirmation previous cycle completed

Implementation agent requires:
- Confirmation test exists and fails
- Confirmation domain review passed

Domain review agent requires:
- Confirmation of which phase is being reviewed (after test or after implementation)
```

**Benefits:**
- Prevents "quick fix" shortcuts
- Forces conscious workflow state tracking
- Makes workflow violations immediately visible
- Documents that required steps occurred

### Principle 4: Domain Expert Has Veto Power

**The Principle:** In multi-agent systems with domain modeling, the domain expert agent has veto authority over design decisions that violate domain principles.

**Why this matters:** Domain integrity is foundational. Compromising it for expediency creates technical debt that compounds.

**Domain veto authority covers:**
- Primitive obsession (String where Email type should exist)
- Invalid states representable (type allows impossible situations)
- Parse-don't-validate violations
- Domain boundary violations

**Resolution protocol:**
1. Domain raises concern
2. Affected agent responds with rationale
3. Orchestrator facilitates discussion
4. Seek compromise
5. If no consensus after 2 rounds → Escalate to user

**Example:**
```
TestWriter: Creates test using `String` for email parameter
  ↓
DomainReviewer: VETO - Primitive obsession. Use Email type.
  ↓
TestWriter: "Email type doesn't exist yet, using String for now"
  ↓
DomainReviewer: "That's why I review BEFORE implementation - so I can create Email type"
  ↓
Orchestrator: "DomainReviewer will create Email type, TestWriter will revise test to use it"
  ↓
TestWriter: Revises test with Email type
  ↓
DomainReviewer: Creates Email type
  ↓
Consensus reached, proceed
```

---

## Constraints and Boundaries

### DO (Orchestrator):
- Decide which agent handles which task
- Provide complete context to every agent
- Enforce workflow gates
- Facilitate agent conflicts
- Track workflow state
- Monitor for agent pause signals (questions, blockers)
- Ensure required confirmations before proceeding

### DON'T (Orchestrator):
- Perform specialized work (write code, edit files)
- Skip workflow steps ("just this once")
- Assume agents have context ("as we discussed")
- Override domain veto without user consultation
- Let agent debates drag (escalate after 2 rounds)
- Bypass gates ("I know this step isn't needed")

### DO (Specialized Agents):
- Focus on your specialty
- Validate input gates
- Provide clear output
- Signal when user input needed
- Raise concerns when design violates principles
- Document your decisions

### DON'T (Specialized Agents):
- Work outside your specialty
- Assume context from main conversation
- Proceed when gate validation fails
- Silently accept violations of your principles

**Rationale:** Clear boundaries prevent responsibility diffusion and maintain workflow integrity.

---

## Usage Patterns

### Pattern 1: Agent Specialization Hierarchy

**Scenario:** Multi-agent system needs clear responsibility boundaries.

**Specialization by concern:**
```
Orchestrator (coordinates)
├─ TestWriter (test files only)
├─ Implementer (production code only)
├─ DomainModeler (type definitions only)
├─ Reviewer (read-only analysis)
└─ ConfigManager (configuration files only)
```

**Delegation rules:**
- File pattern match → Appropriate agent
- Never multiple agents editing same file simultaneously
- Each agent has exclusive domain
- Orchestrator never bypasses agents

**Example:**
```
User request: "Add user authentication"

Orchestrator analysis:
- Needs: Test (TestWriter) + Types (DomainModeler) + Implementation (Implementer)

Orchestrator workflow:
1. Delegate to TestWriter: "Create failing test for authentication"
2. Wait for TestWriter completion
3. Delegate to DomainModeler: "Review test, create types"
4. Wait for DomainModeler completion
5. Delegate to Implementer: "Implement to pass test"
6. Wait for Implementer completion
7. Delegate to DomainModeler: "Review implementation"
8. Complete when DomainModeler approves
```

### Pattern 2: Workflow State Tracking

**Scenario:** Complex multi-step workflow needs state management.

**State markers:**
```
Workflow phases:
- Test: Not started | In progress | Failing (expected) | Passing | Approved
- Types: Not started | In progress | Created | Approved
- Implementation: Not started | In progress | Test passing | Approved

Current state determines next valid action.
```

**Gate enforcement:**
```python
def can_proceed_to_implementation(state):
    return (
        state.test == "Failing (expected)" and
        state.types == "Created" and
        state.domain_review_after_test == "Approved"
    )

if not can_proceed_to_implementation(state):
    return "GATE FAILED: Prerequisites not met"
```

### Pattern 3: Agent Pause and Resume

**Scenario:** Long-running agent needs user input mid-task.

**Pause signal:**
```json
{
  "status": "PAUSED",
  "reason": "USER_INPUT_NEEDED",
  "question": "Found 3 validation approaches. Which should I use?",
  "options": ["Strict RFC compliance", "Lenient", "Custom rules"],
  "state_checkpoint": "agent-123-checkpoint-456"
}
```

**Orchestrator response:**
1. Detect pause signal
2. Ask user via AskUserQuestion
3. Resume agent with answer and checkpoint reference

**Resume:**
```json
{
  "status": "RESUMING",
  "checkpoint": "agent-123-checkpoint-456",
  "user_answer": "Strict RFC compliance",
  "instruction": "Continue with user's choice"
}
```

### Pattern 4: Conflict Resolution

**Scenario:** Two agents disagree on approach.

**Debate protocol:**
```
Round 1:
  Agent A: States position
  Agent B: States counter-position
  Orchestrator: Summarizes both positions clearly

Round 2:
  Agent A: Responds to B's points
  Agent B: Responds to A's points
  Orchestrator: Proposes compromise

If consensus:
  Proceed with agreed approach

If no consensus after Round 2:
  Orchestrator: Escalate to user
  User: Makes decision
  Agents: Implement user's decision
```

**Example:**
```
TestWriter: "Test should use String for email (simpler)"
DomainModeler: "Email type required (prevents invalid emails)"
Orchestrator: "TestWriter values simplicity, DomainModeler values safety"

Round 2:
TestWriter: "Email type adds complexity without immediate benefit"
DomainModeler: "Complexity is minimal, benefit is compile-time validation"
Orchestrator: "Compromise: Use Email type now (DomainModeler creates it), keep it simple"

Consensus: Use Email type (DomainModeler wins on principle)
```

---

## Integration with Other Skills

**Works well with:**
- **user-input-protocol:** Agents use pause/resume for questions
- **tdd-constraints:** Orchestrator enforces TDD phase sequence
- **domain-modeling:** DomainModeler agent applies domain principles
- **debugging-protocol:** When agents fail, orchestrator applies systematic debugging

**Prerequisites:**
- Agent framework with delegation capabilities
- Multiple specialized agents
- Context passing mechanism
- Workflow state tracking

---

## Common Pitfalls

### Pitfall 1: Orchestrator Doing Specialized Work

**Problem:** "Quick fix" - orchestrator edits file directly

**Solution:** Always delegate. No exceptions.

### Pitfall 2: Vague Context to Agents

**Problem:** "Fix the bug" without specifying which bug, which file, what error

**Solution:** Use context template. Be exhaustively specific.

### Pitfall 3: Skipping Gates

**Problem:** "I know domain review isn't needed here"

**Solution:** Gates exist for discipline. If agent rejects, you skipped something.

### Pitfall 4: Letting Debates Drag

**Problem:** Agents debate for 5+ rounds without resolution

**Solution:** Escalate after round 2. User breaks tie.

### Pitfall 5: Assuming Agent Memory

**Problem:** "Continue where you left off" to resumed agent

**Solution:** Provide full context, even on resume. Agents don't remember.

---

## Examples

### Example 1: Complete TDD Cycle with Orchestration

```
User: "Add email validation to User model"

Orchestrator:
  State: Starting new feature
  Next: Write failing test

Orchestrator → TestWriter:
  CONTEXT: FIRST_TEST
  TASK: Create failing test for email validation
  FILE: tests/user_test.rs
  REQUIREMENTS:
    - Test User::new() with invalid email
    - Expect validation error
  CONSTRAINTS:
    - Use domain types (Email, not String)
    - One assertion per test

TestWriter: (creates test)
  Result: test_user_rejects_invalid_email FAILS
    Error: "Email type not found"

Orchestrator:
  State: Test written, domain review needed

Orchestrator → DomainModeler:
  CONTEXT: AFTER_RED
  RED_COMPLETE:
    - Test: test_user_rejects_invalid_email
    - Error: "Email type not found"
  TASK: Review test, create Email type
  FILE: src/domain/types.rs

DomainModeler: (reviews test, creates Email type)
  Output: Email type created with validation
  Result: APPROVE - No domain concerns

Orchestrator:
  State: Types created, ready for implementation

Orchestrator → Implementer:
  CONTEXT: IMPLEMENTATION
  RED_COMPLETE:
    - Test: test_user_rejects_invalid_email
    - Error: "unimplemented"
  DOMAIN_REVIEW: PASSED
    - Email type created in src/domain/types.rs
  TASK: Implement User::new() to validate email
  FILES:
    - src/domain/user.rs (implementation)
    - src/domain/types.rs (use Email type)

Implementer: (implements validation)
  Result: test_user_rejects_invalid_email PASSES

Orchestrator:
  State: Implementation complete, domain review needed

Orchestrator → DomainModeler:
  CONTEXT: AFTER_GREEN
  GREEN_COMPLETE:
    - Test: test_user_rejects_invalid_email PASSES
    - Files: src/domain/user.rs, src/domain/types.rs
  TASK: Review implementation for domain integrity

DomainModeler: (reviews implementation)
  Output: APPROVE - Email newtype used correctly, validation at construction

Orchestrator:
  State: Cycle complete, feature implemented
  Report: Email validation added with domain-rich types
```

### Example 2: Agent Conflict Resolution

```
Orchestrator → TestWriter: "Create test for order total calculation"

TestWriter: (creates test using float for money)
```
test_order_calculates_total() {
  order.add_item(10.99, 2);
  assert_eq!(order.total(), 21.98);
}
```

Orchestrator → DomainModeler: "Review test"

DomainModeler: CONCERN - Primitive obsession
  Money should be Money type, not float
  Floats have precision issues (0.1 + 0.2 != 0.3)

Orchestrator facilitates:
  TestWriter: Why float?
  DomainModeler: Why Money type?

Round 1:
TestWriter: "Float is simpler, everyone understands money as numbers"
DomainModeler: "Money type prevents precision errors and enforces currency"

Orchestrator: "TestWriter values simplicity, DomainModeler values correctness"

Round 2:
TestWriter: "Can we use Decimal instead of custom Money type?"
DomainModeler: "Acceptable compromise - Decimal fixes precision, maintains simplicity"

Consensus: Use Decimal type (compromise)

Orchestrator → TestWriter: "Revise test with Decimal"
TestWriter: (revises)

Orchestrator → DomainModeler: "Re-review"
DomainModeler: APPROVE
```

### Example 3: Agent Pause for User Input

```
Orchestrator → Implementer: "Implement payment processing"

Implementer: (starts work, encounters decision point)

Implementer output:
AWAITING_USER_INPUT
{
  "context": "Payment processing needs retry strategy",
  "checkpoint": "impl-payment-checkpoint-1",
  "questions": [{
    "question": "How should we handle payment failures?",
    "options": [
      "Immediate failure (no retries)",
      "Retry 3 times with exponential backoff",
      "Retry indefinitely until success"
    ]
  }]
}

Orchestrator: (detects pause)
  1. Asks user via AskUserQuestion
  2. User chooses: "Retry 3 times with exponential backoff"

Orchestrator → Implementer: (resume)
  USER_INPUT_RESPONSE: "Retry 3 times with exponential backoff"
  CHECKPOINT: "impl-payment-checkpoint-1"
  INSTRUCTION: "Continue implementation with user's retry strategy"

Implementer: (resumes with context, completes work)
  Result: Payment processing implemented with 3-retry strategy
```

---

## Verification Checklist

- [ ] Orchestrator never performs specialized work
- [ ] Every agent delegation includes complete context
- [ ] Workflow gates enforced (agents check confirmations)
- [ ] Domain expert veto authority respected
- [ ] Agent conflicts resolved within 2 rounds or escalated
- [ ] Agent pause signals detected and handled
- [ ] Workflow state tracked and visible
- [ ] Fresh context provided on every agent invocation
- [ ] No assumptions about agent memory

---

## References

**Source Documentation:**
- sdlc plugin: commands/shared/orchestration.md

**Related Skills:**
- user-input-protocol - Agent pause/resume pattern
- tdd-constraints - Workflow orchestrator enforces
- domain-modeling - Domain expert role in orchestration

**External Resources:**
- Multi-Agent Systems by Wooldridge
- Microservices Patterns by Richardson (orchestration vs choreography)

---

## Version History

### v1.0.0 (2026-02-04)
- Initial extraction from sdlc plugin
- Delegation patterns
- Context provision
- Workflow gates
- Conflict resolution
- Agent specialization
- Medium portability (requires agent delegation framework)

---

## Metadata

**Extraction Source:** sdlc/commands/shared/orchestration.md
**Extraction Date:** 2026-02-04
**Last Updated:** 2026-02-04
**Compatibility:** Medium portability (requires multi-agent framework)
**License:** MIT
