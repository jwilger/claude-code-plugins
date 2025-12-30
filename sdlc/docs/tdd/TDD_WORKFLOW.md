# TDD Workflow

Test-Driven Development following outside-in, black-box principles.

## The Cycle

```
   ┌─────────────────────────────────────────┐
   │                                         │
   ▼                                         │
┌─────┐     ┌────────┐     ┌───────┐     ┌──────────┐
│ RED │ ──▶ │ DOMAIN │ ──▶ │ GREEN │ ──▶ │ REFACTOR │
└─────┘     └────────┘     └───────┘     └──────────┘
   │             │              │              │
   │             │              │              │
   ▼             ▼              ▼              ▼
Write ONE    Create types   Minimal code   Clean up
failing test  if compile    to pass test   (commit first!)
             errors
```

## Phase Details

### RED Phase (sdlc-red agent)

Write ONE failing test with ONE assertion.

Rules:
- Test files only
- Reference types that don't exist yet
- Let the compiler tell you what's missing
- Name tests descriptively
- Follow GWT (Given/When/Then) structure

### DOMAIN Phase (sdlc-domain agent)

Create type definitions to make tests compile.

Rules:
- Type definitions only
- No implementation logic
- Use `unimplemented!()` for function bodies
- Follow domain modeling principles
- Avoid primitive obsession

### GREEN Phase (sdlc-green agent)

Write minimal code to pass the test.

Rules:
- Production code only
- Address ONLY the exact error message
- Make smallest possible change
- Stop when test passes
- Delete dead code

### REFACTOR Phase

Clean up after green.

Rules:
- Commit working state FIRST
- Only then refactor
- Re-run tests after each change
- Commit refactored code

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
