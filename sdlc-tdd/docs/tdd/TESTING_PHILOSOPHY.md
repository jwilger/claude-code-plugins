# Testing Philosophy

## Core Principle: Black-Box Testing

Test BEHAVIOR, not IMPLEMENTATION.

Tests should:
- Verify what the system does, not how it does it
- Remain valid even if internals are refactored
- Express business requirements, not technical structure

## No Ad-Hoc Mocking

**BAD: Ad-hoc mocks that couple tests to implementation**
```
// Creates tight coupling to implementation details
mock_db = create_mock()
mock_db.expect("save").to_be_called_once()
```

**GOOD: Interface injection for observability**
```
// Accept any implementation of the interface
function process_order(order, store: OrderStore) {
    // ...
}

// In tests, use an observable implementation
store = InMemoryOrderStore()
result = process_order(order, store)
assert store.saved_orders() == [expected_order]
```

## Interface/Trait Injection Pattern

This pattern applies to all languages - use the appropriate abstraction mechanism:

| Language | Abstraction Mechanism |
|----------|----------------------|
| Rust | `trait` |
| TypeScript/Java | `interface` |
| Python | Protocol or ABC |
| Go | `interface` |
| Elixir | Behaviour |
| Ruby | Duck typing |

### The Pattern

1. **Define interface for external dependency**
```
interface EventStore {
    append(stream_id, events) -> Result
    load(stream_id) -> List<Event>
}
```

2. **Production implementation** connects to real infrastructure

3. **Test implementation** is in-memory and observable
```
class InMemoryEventStore implements EventStore {
    // Observable methods for tests
    stored_events(stream_id) -> List<Event>
    was_called() -> bool
}
```

4. **Accept interface in functions** - enables swapping implementations

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

```
test "transfers money when sender has sufficient balance"
test "rejects transfer when sender has insufficient balance"
test "calculates fees based on transfer amount"
```

Not:
```
test "test transfer"           // Too vague
test "test account service"    // Tests implementation
```

## Test Structure: Given/When/Then

```
test "completes order when all items available" {
    // Given - Set up preconditions
    store = InMemoryInventoryStore()
    store.add_stock("item-1", 10)
    store.add_stock("item-2", 5)

    // When - Execute behavior
    order = Order([
        LineItem("item-1", 2),
        LineItem("item-2", 1),
    ])
    result = complete_order(order, store)

    // Then - Verify outcomes
    assert result.is_ok()
    assert store.stock_level("item-1") == 8
    assert store.stock_level("item-2") == 4
}
```

## Property-Based Testing

Use property tests for domain types where applicable:

```
property "money addition is commutative" {
    for_all(a: Money, b: Money) {
        assert a + b == b + a
    }
}

property "email rejects strings without @" {
    for_all(s: String where not contains(s, "@")) {
        assert Email.parse(s).is_error()
    }
}
```

Property testing libraries exist for most languages:
- **Rust**: proptest, quickcheck
- **TypeScript/JavaScript**: fast-check
- **Python**: hypothesis
- **Elixir**: StreamData
- **Java/Kotlin**: jqwik
