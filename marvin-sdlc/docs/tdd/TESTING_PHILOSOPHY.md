# Testing Philosophy

## Core Principle: Black-Box Testing

Test BEHAVIOR, not IMPLEMENTATION.

Tests should:
- Verify what the system does, not how it does it
- Remain valid even if internals are refactored
- Express business requirements, not technical structure

## No Ad-Hoc Mocking

**BAD: Ad-hoc mocks**
```rust
// Creates tight coupling to implementation
let mock_db = MockDatabase::new();
mock_db.expect_save().times(1).returning(|_| Ok(()));
```

**GOOD: Trait injection for observability**
```rust
// Accepts any implementation of the trait
fn process_order<S: OrderStore>(order: Order, store: &S) -> Result<(), Error> {
    // ...
}

// In tests, use an observable implementation
let store = InMemoryOrderStore::new();
let result = process_order(order, &store);
assert_eq!(store.saved_orders(), vec![expected_order]);
```

## Trait Injection Pattern

### 1. Define Trait for External Dependency

```rust
pub trait EventStore {
    fn append(&self, stream: &StreamId, events: Vec<Event>) -> Result<(), StoreError>;
    fn load(&self, stream: &StreamId) -> Result<Vec<Event>, StoreError>;
}
```

### 2. Production Implementation

```rust
pub struct PostgresEventStore { ... }

impl EventStore for PostgresEventStore { ... }
```

### 3. Test Implementation (Observable)

```rust
pub struct InMemoryEventStore {
    events: RefCell<HashMap<StreamId, Vec<Event>>>,
}

impl EventStore for InMemoryEventStore { ... }

impl InMemoryEventStore {
    // Observable methods for tests
    pub fn stored_events(&self, stream: &StreamId) -> Vec<Event> { ... }
    pub fn was_called(&self) -> bool { ... }
}
```

### 4. Accept Trait in Functions

```rust
pub fn execute_command<S: EventStore>(cmd: Command, store: &S) -> Result<Event, Error> {
    // Uses store through trait interface
}
```

## When to Drill Down to Unit Tests

Drill down from integration tests when:

1. **Error message is unclear**
   - "Assertion failed" without helpful context
   - Multiple components could be the cause
   - Need to isolate the failure

2. **Debugging would be faster as unit test**
   - Complex setup in integration test
   - Specific edge case easier to test in isolation

3. **Component behavior needs documentation**
   - Unit test serves as specification
   - Edge cases captured explicitly

## When NOT to Drill Down

Stay at integration level when:

1. **Error is obvious**
   - Clear what code needs to change
   - Single fix will resolve it

2. **Behavior is simple**
   - CRUD operation with no business logic
   - Thin wrapper around library

3. **Already at appropriate level**
   - Integration test IS the right level
   - Unit test would test implementation, not behavior

## Test Naming

Tests should read as specifications:

```rust
#[test]
fn transfers_money_when_sender_has_sufficient_balance() { ... }

#[test]
fn rejects_transfer_when_sender_has_insufficient_balance() { ... }

#[test]
fn calculates_fees_based_on_transfer_amount() { ... }
```

Not:
```rust
#[test]
fn test_transfer() { ... }  // Too vague

#[test]
fn test_account_service_transfer_method() { ... }  // Tests implementation
```

## Test Structure: Given/When/Then

```rust
#[test]
fn completes_order_when_all_items_available() {
    // Given - Set up preconditions
    let store = InMemoryInventoryStore::new();
    store.add_stock("item-1", 10);
    store.add_stock("item-2", 5);

    // When - Execute behavior
    let order = Order::new(vec![
        LineItem::new("item-1", 2),
        LineItem::new("item-2", 1),
    ]);
    let result = complete_order(order, &store);

    // Then - Verify outcomes
    assert!(result.is_ok());
    assert_eq!(store.stock_level("item-1"), 8);
    assert_eq!(store.stock_level("item-2"), 4);
}
```

## Property-Based Testing

Use property tests for domain types:

```rust
#[test]
fn money_addition_is_commutative() {
    proptest!(|(a: i64, b: i64)| {
        let m1 = Money::cents(a);
        let m2 = Money::cents(b);
        assert_eq!(m1 + m2, m2 + m1);
    });
}

#[test]
fn email_rejects_invalid_formats() {
    proptest!(|(s in "[^@]+")| {  // Strings without @
        assert!(Email::parse(&s).is_err());
    });
}
```
