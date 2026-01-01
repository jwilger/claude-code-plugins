# TDD Workflow

Test-Driven Development following outside-in, black-box principles.

**This document is the authoritative source of truth for TDD workflow.**

## Main Conversation Role: ORCHESTRATOR ONLY

The main conversation **MUST NOT** directly write or edit:
- Test files → delegate to `sdlc-red` agent
- Production implementation code → delegate to `sdlc-green` agent
- Type definitions and domain models → delegate to `sdlc-domain` agent

The main conversation orchestrates TDD work by:
1. Describing what needs to be implemented
2. Launching the appropriate agent via Task tool
3. Reviewing agent results and coordinating the cycle
4. Facilitating debates when agents disagree
5. Escalating to user when consensus cannot be reached

## The Cycle (MANDATORY SEQUENCE)

```
     ┌──────────────────────────────────────────────────────────────────┐
     │                                                                  │
     ▼                                                                  │
┌─────────┐     ┌────────────────┐     ┌─────────┐     ┌────────────────┐     ┌──────────┐
│   RED   │ ──▶ │ DOMAIN REVIEW  │ ──▶ │  GREEN  │ ──▶ │ DOMAIN REVIEW  │ ──▶ │ REFACTOR │
└─────────┘     └────────────────┘     └─────────┘     └────────────────┘     └──────────┘
     │                 │                    │                 │                    │
     ▼                 ▼                    ▼                 ▼                    ▼
  Write ONE      Review test,          Minimal          Review impl,          Clean up
  failing test   create types,      implementation     verify domain        (commit first!)
                 check domain                          integrity
```

**CRITICAL**: Domain review happens TWICE per cycle:
1. **After Red**: Review test implications, create types, evaluate domain alignment
2. **After Green**: Review implementation for domain integrity violations

## Phase Details

### RED Phase (sdlc-red agent)

Write ONE failing test with ONE assertion.

Rules:
- Test files only
- Reference types that don't exist yet
- Let the compiler tell you what's missing
- Name tests descriptively
- Follow GWT (Given/When/Then) structure
- **Be prepared to revise if domain modeler raises concerns**

### DOMAIN REVIEW Phase 1: After Red (sdlc-domain agent)

Review test implications and create type definitions.

Responsibilities:
1. **Review the test for domain violations**:
   - Primitive obsession (using String/int where domain types should exist)
   - Invalid state representability
   - Parse-don't-validate violations

2. **If violations found**: Raise DOMAIN CONCERN and propose alternative
3. **If no violations**: Create minimal type definitions to compile

Rules:
- Type definitions only
- No implementation logic
- Use `unimplemented!()` for function bodies
- Follow domain modeling principles
- Avoid primitive obsession
- **PUSH BACK on bad domain designs - you have VETO POWER**

### GREEN Phase (sdlc-green agent)

Write minimal code to pass the test.

Rules:
- Production code only
- Address ONLY the exact error message
- Make smallest possible change
- Stop when test passes
- Delete dead code
- **Be prepared to revise if domain modeler raises concerns**

### DOMAIN REVIEW Phase 2: After Green (sdlc-domain agent)

Review implementation for domain integrity.

Responsibilities:
1. **Verify implementation respects domain boundaries**
2. **Check for domain violations** that crept in during implementation
3. **If violations found**: Raise DOMAIN CONCERN and propose revision
4. **If no violations**: Approve and signal "ready for next cycle"

Rules:
- Review only, no code changes in this phase
- Same domain principles apply
- **PUSH BACK on implementations that violate domain integrity**

### REFACTOR Phase

Clean up after green.

Rules:
- Commit working state FIRST
- Only then refactor
- Re-run tests after each change
- Commit refactored code

## Agent Debate Protocol

When the domain modeler raises a concern, a debate may ensue.

### Debate Flow

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  1. Domain raises concern                                   │
│     ↓                                                       │
│  2. Affected agent (red/green) explains reasoning           │
│     ↓                                                       │
│  3. Orchestrator (main conversation) facilitates            │
│     ↓                                                       │
│  4. Seek consensus                                          │
│     ↓                                                       │
│  [If consensus] → Proceed with agreed approach              │
│  [If no consensus after 2 rounds] → Escalate to user        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Debate Rules

1. **Domain modeler has veto power** over:
   - Primitive obsession
   - Invalid state representability
   - Parse-don't-validate violations
   - Domain boundary violations

2. **Other agents must respond substantively**, not just dismiss

3. **Orchestrator should**:
   - Ask clarifying questions
   - Propose compromises
   - Summarize positions
   - Decide when to escalate

4. **Escalation**: If no consensus after 2 rounds, ask the user

### Example Debate

```
sdlc-red: I wrote a test using `fn create_user(email: String) -> User`

sdlc-domain: DOMAIN CONCERN - Primitive obsession. Email should be
a validated type, not a raw String. Propose: `Email::parse(&str)`

sdlc-red: The test is focused on the happy path. We can add Email
type later when we test validation.

sdlc-domain: Disagree. "Later" never comes, and primitives leak.
If we start with String, everything will depend on it. The cost
of changing later is high. Email should be a type from day one.

Orchestrator: Domain modeler's point about cost of change is valid.
sdlc-red, can you update the test to use Email::parse()?

sdlc-red: Agreed, will update.

[CONSENSUS REACHED]
```

## Outside-In Testing

Start with integration/acceptance tests, drill down as needed.

```
┌─────────────────────────────────────┐
│ Acceptance Test (user scenario)    │
│  ┌─────────────────────────────┐   │
│  │ Integration Test (system)   │   │
│  │  ┌─────────────────────┐    │   │
│  │  │ Unit Test (detail)  │    │   │
│  │  └─────────────────────┘    │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### When to Drill Down

If a test fails with unclear error:
1. Mark current test as ignored
2. Write more focused lower-level test
3. Continue until error is clear
4. Work back up, removing ignores

Skip Protocol:
```rust
#[ignore = "working on: test_balance_calculation"]
#[test]
fn high_level_test() { ... }

// New, more focused test
#[test]
fn test_balance_calculation() { ... }
```

## Black-Box Testing

Test BEHAVIOR, not IMPLEMENTATION.

### Good (Black-Box)
```rust
#[test]
fn account_reflects_deposit() {
    let account = Account::new();
    account.deposit(Money::new(100));
    assert_eq!(account.balance(), Money::new(100));
}
```

### Bad (White-Box)
```rust
#[test]
fn deposit_adds_to_internal_list() {
    let account = Account::new();
    account.deposit(Money::new(100));
    // Testing internal state, not behavior
    assert_eq!(account.transactions.len(), 1);
}
```

## Trait Injection

Use dependency injection for observable behavior. No ad-hoc mocking.

### Good (Trait Injection)
```rust
trait EventStore {
    fn append(&self, events: Vec<Event>) -> Result<(), Error>;
    fn load(&self, id: &AggregateId) -> Vec<Event>;
}

fn execute<S: EventStore>(cmd: Command, store: &S) -> Result<(), Error> {
    // Uses trait, can be tested with in-memory impl
}

#[test]
fn test_with_real_behavior() {
    let store = InMemoryEventStore::new();
    let result = execute(cmd, &store);
    // Test against observable behavior
    assert_eq!(store.load(&id), expected_events);
}
```

### Bad (Ad-hoc Mocking)
```rust
#[test]
fn test_with_mock() {
    let mock = MockEventStore::new();
    mock.expect_append().times(1).return_ok();
    // Tests interaction, not behavior
}
```

## Commit Points

Commit at these points:
- After each red→green transition
- After each successful refactor
- Before starting a new test

Small, frequent commits preserve progress and make rollback easy.

## Quality Gate

Before creating a PR:
- All tests must pass
- Mutation testing score must be 100%
- No dead code warnings
