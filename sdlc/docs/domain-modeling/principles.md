# Domain Modeling Principles

Core principles for creating expressive domain types.

## The Goal

Types should make invalid states unrepresentable and express business concepts clearly.

## Avoid Primitive Obsession

Don't use primitives for domain concepts.

### Problem
```rust
fn create_user(email: String, age: i32, active: bool) -> Result<User, String>
```

What's wrong:
- `String` could be anything, not a valid email
- `i32` could be negative (invalid age)
- `String` error gives no structure
- No compile-time protection

### Solution
```rust
fn create_user(email: Email, age: Age, active: bool) -> Result<User, UserError>
```

Now:
- `Email` validates on construction
- `Age` enforces positive values
- `UserError` is exhaustive and typed
- Compiler catches misuse

## Make Invalid States Unrepresentable

Use the type system to prevent bugs.

### Problem
```rust
struct Order {
    status: OrderStatus,
    shipped_at: Option<DateTime>,
    delivered_at: Option<DateTime>,
}

enum OrderStatus { Pending, Shipped, Delivered }
```

What's wrong:
- Can have `shipped_at = None` with `status = Shipped`
- Can have `delivered_at < shipped_at`
- Runtime checks needed everywhere

### Solution
```rust
enum Order {
    Pending { items: Vec<Item>, created_at: DateTime },
    Shipped { items: Vec<Item>, shipped_at: DateTime },
    Delivered { items: Vec<Item>, shipped_at: DateTime, delivered_at: DateTime },
}
```

Now:
- `Shipped` MUST have `shipped_at`
- `Delivered` MUST have both timestamps
- Invalid combinations impossible

## Parse, Don't Validate

Validate at boundaries, use strong types internally.

### Problem
```rust
fn process_email(email: String) -> Result<(), Error> {
    if !is_valid_email(&email) {
        return Err(Error::InvalidEmail);
    }
    // Now we "know" it's valid... but only at runtime
    send_email(&email)?;
    store_email(&email)?;
    // Every function needs to trust or re-validate
}
```

### Solution
```rust
struct Email(String);

impl Email {
    pub fn parse(s: &str) -> Result<Self, EmailError> {
        if is_valid_email(s) {
            Ok(Email(s.to_string()))
        } else {
            Err(EmailError::Invalid)
        }
    }
}

fn process_email(email: Email) -> Result<(), Error> {
    // email is GUARANTEED valid by type
    send_email(&email)?;
    store_email(&email)?;
    // No validation needed - the type IS the proof
}
```

## Newtypes for IDs

Prevent mixing up different ID types.

### Problem
```rust
fn transfer(from_account: u64, to_account: u64, user: u64) -> Result<(), Error>

// Easy to mix up:
transfer(user_id, account_id, other_user_id);  // Compiles! Bug!
```

### Solution
```rust
struct AccountId(Uuid);
struct UserId(Uuid);

fn transfer(from: AccountId, to: AccountId, user: UserId) -> Result<(), Error>

// Can't mix up:
transfer(user_id, account_id, other_user_id);  // Won't compile!
```

## Types as Documentation

Types should explain the domain.

### Problem
```rust
fn process_order(data: (String, i64, bool, Vec<(String, i64)>)) -> (String, String)
```

What do those mean? No one knows without reading code.

### Solution
```rust
fn process_order(order: Order) -> Result<OrderConfirmation, OrderError>

struct Order {
    customer: CustomerId,
    total: Money,
    expedited: bool,
    items: Vec<LineItem>,
}
```

Now the function signature IS documentation.

## Exhaustive Matching

Use enums to ensure all cases are handled.

### Problem
```rust
fn handle_status(status: &str) -> String {
    match status {
        "pending" => "Waiting",
        "active" => "Running",
        _ => "Unknown",  // Silent catch-all
    }
}
// If someone adds "paused", no compiler warning
```

### Solution
```rust
enum Status { Pending, Active, Paused }

fn handle_status(status: Status) -> String {
    match status {
        Status::Pending => "Waiting",
        Status::Active => "Running",
        // Compiler error: missing Paused!
    }
}
```

## Language-Specific Patterns

### Rust
- Use newtypes: `struct UserId(Uuid);`
- Derive traits: `#[derive(Debug, Clone, PartialEq)]`
- Use `#[must_use]` for important returns
- Implement `From`/`TryFrom` for conversions

### TypeScript
- Use branded types: `type UserId = string & { readonly brand: unique symbol }`
- Prefer `interface` for data structures
- Use discriminated unions for state machines
- Use `readonly` for immutability

### Python
- Use dataclasses: `@dataclass(frozen=True)`
- Use NewType: `UserId = NewType('UserId', str)`
- Use Literal types for enums
- Use Protocol for structural typing

## Summary

1. **Avoid primitives** - Create domain types
2. **Invalid states impossible** - Use enums and variants
3. **Parse, don't validate** - Validate at boundary, trust types internally
4. **Newtypes for IDs** - Prevent mixing up identifiers
5. **Types as docs** - Make code self-documenting
6. **Exhaustive matching** - Let compiler catch missing cases
