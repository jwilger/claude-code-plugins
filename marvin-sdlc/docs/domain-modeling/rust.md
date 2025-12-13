# Domain Modeling in Rust

Rust-specific patterns for type-driven development.

## Newtype Pattern

Wrap primitives in single-field tuple structs:

```rust
pub struct UserId(String);
pub struct Email(String);
pub struct Money(i64);  // Cents
```

### With Validation (Constructor)

```rust
pub struct Email(String);

impl Email {
    pub fn new(value: &str) -> Result<Self, ValidationError> {
        if value.contains('@') && value.len() > 3 {
            Ok(Self(value.to_string()))
        } else {
            Err(ValidationError::InvalidEmail)
        }
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}
```

## nutype Crate (Recommended)

The `nutype` crate automates newtype creation with validation:

```rust
use nutype::nutype;

#[nutype(
    validate(not_empty, len_char_max = 100),
    derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)
)]
pub struct Username(String);

#[nutype(
    validate(greater = 0),
    derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)
)]
pub struct PositiveAmount(i64);

#[nutype(
    sanitize(trim, lowercase),
    validate(regex = r"^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$"),
    derive(Debug, Clone, PartialEq, Eq, Hash)
)]
pub struct Email(String);
```

### nutype Benefits

- Automatic `new()` that returns `Result`
- Sanitization before validation
- Derive macros work through the wrapper
- Serde support built-in

### Adding nutype

```bash
cargo add nutype
```

## Type State Pattern

Encode valid state transitions in the type system:

```rust
// States as zero-sized types
pub struct Draft;
pub struct Submitted;
pub struct Approved;

pub struct Document<State> {
    content: String,
    _state: std::marker::PhantomData<State>,
}

impl Document<Draft> {
    pub fn new(content: String) -> Self {
        Self { content, _state: PhantomData }
    }

    pub fn submit(self) -> Document<Submitted> {
        Document { content: self.content, _state: PhantomData }
    }
}

impl Document<Submitted> {
    pub fn approve(self) -> Document<Approved> {
        Document { content: self.content, _state: PhantomData }
    }

    pub fn reject(self) -> Document<Draft> {
        Document { content: self.content, _state: PhantomData }
    }
}

impl Document<Approved> {
    pub fn publish(&self) -> PublishedDocument { ... }
}

// Usage: compiler enforces valid transitions
let doc = Document::new("content".into());
// doc.approve(); // ERROR: no method `approve` on Document<Draft>
let submitted = doc.submit();
let approved = submitted.approve();
approved.publish();
```

## Sum Types with Enums

Rust enums are perfect for "one of" scenarios:

```rust
pub enum PaymentMethod {
    CreditCard { number: CardNumber, expiry: Expiry, cvv: Cvv },
    BankTransfer { iban: Iban, bic: Bic },
    PayPal { email: Email },
}

pub enum OrderStatus {
    Pending,
    Confirmed { confirmed_at: DateTime<Utc> },
    Shipped { shipped_at: DateTime<Utc>, tracking: TrackingNumber },
    Delivered { delivered_at: DateTime<Utc> },
    Cancelled { reason: CancellationReason },
}
```

## Non-Empty Collections

```rust
pub struct NonEmptyVec<T> {
    head: T,
    tail: Vec<T>,
}

impl<T> NonEmptyVec<T> {
    pub fn new(head: T) -> Self {
        Self { head, tail: Vec::new() }
    }

    pub fn from_vec(vec: Vec<T>) -> Option<Self> {
        let mut iter = vec.into_iter();
        iter.next().map(|head| Self {
            head,
            tail: iter.collect(),
        })
    }

    pub fn first(&self) -> &T {
        &self.head  // Always succeeds!
    }

    pub fn len(&self) -> usize {
        1 + self.tail.len()  // Always >= 1
    }
}
```

Or use the `nonempty` crate:
```bash
cargo add nonempty
```

## Builder Pattern for Complex Types

```rust
pub struct OrderBuilder {
    items: Vec<Item>,
    shipping: Option<Address>,
    billing: Option<Address>,
}

impl OrderBuilder {
    pub fn new() -> Self {
        Self { items: vec![], shipping: None, billing: None }
    }

    pub fn add_item(mut self, item: Item) -> Self {
        self.items.push(item);
        self
    }

    pub fn shipping(mut self, address: Address) -> Self {
        self.shipping = Some(address);
        self
    }

    pub fn billing(mut self, address: Address) -> Self {
        self.billing = Some(address);
        self
    }

    pub fn build(self) -> Result<Order, OrderError> {
        let items = NonEmptyVec::from_vec(self.items)
            .ok_or(OrderError::NoItems)?;
        let shipping = self.shipping.ok_or(OrderError::NoShipping)?;

        Ok(Order {
            items,
            shipping,
            billing: self.billing.unwrap_or_else(|| shipping.clone()),
        })
    }
}
```

## Error Types

Use enums for domain errors:

```rust
#[derive(Debug, thiserror::Error)]
pub enum TransferError {
    #[error("insufficient funds: needed {needed}, available {available}")]
    InsufficientFunds { needed: Money, available: Money },

    #[error("account not found: {0}")]
    AccountNotFound(AccountId),

    #[error("cannot transfer to same account")]
    SameAccount,

    #[error("amount must be positive")]
    InvalidAmount,
}
```

## Recommended Crates

| Crate | Purpose |
|-------|---------|
| `nutype` | Validated newtypes |
| `thiserror` | Error derive macros |
| `derive_more` | Additional derives (Display, From, etc.) |
| `nonempty` | Non-empty collections |
| `rust_decimal` | Precise decimal arithmetic (money) |
| `chrono` | Date/time types |
| `uuid` | UUID type |
