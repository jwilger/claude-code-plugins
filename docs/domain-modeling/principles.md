# Domain Modeling Principles

Universal principles for type-driven development across all languages.

## 1. Parse, Don't Validate

**Validation** checks data and returns boolean/error, but the data stays the same type.

**Parsing** transforms data into a type that proves validity.

### The Problem with Validation

```
function processEmail(email: string) {
    if (!isValidEmail(email)) {
        throw new Error("Invalid email");
    }
    // email is still just a string
    // someone could call this with invalid email from elsewhere
    sendEmail(email);
}
```

The function *hopes* callers validated, but can't enforce it.

### The Solution: Parse

```
function processEmail(email: Email) {
    // Email type guarantees validity
    // Impossible to call with invalid email
    sendEmail(email);
}

// Parsing happens at the boundary
const email = Email.parse(userInput); // Returns Email | Error
```

### Key Insight

Move validation to type construction. After construction, validity is guaranteed by the type system.

## 2. Nominal Types Over Primitives

**Primitive obsession**: Using `string`, `int`, `boolean` where domain types should exist.

### The Problem

```
function transfer(from: string, to: string, amount: number) { ... }

// Easy to make mistakes:
transfer(toAccount, fromAccount, amount);  // Swapped!
transfer(fromAccount, toAccount, fee);     // Wrong amount!
```

### The Solution

```
function transfer(from: AccountId, to: AccountId, amount: Money) { ... }

// Compiler catches mistakes:
transfer(to, from, amount);  // Type error!
transfer(from, to, fee);     // Type error if fee is Fee, not Money
```

### What Should Be a Type?

- IDs: `UserId`, `OrderId`, `ProductId`
- Quantities: `Money`, `Weight`, `Distance`
- Constrained strings: `Email`, `PhoneNumber`, `Slug`
- Bounded numbers: `Percentage`, `Rating`, `Age`
- Domain concepts: `OrderStatus`, `PaymentMethod`

## 3. Make Illegal States Unrepresentable

Design types so invalid states cannot exist.

### The Problem

```
struct Order {
    status: string,           // "pending", "shipped", "delivered"
    shipped_at: Option<Date>, // Only valid if shipped
    delivered_at: Option<Date>, // Only valid if delivered
}

// This is valid according to types but nonsense:
Order {
    status: "pending",
    shipped_at: Some(date),    // Pending but shipped?
    delivered_at: Some(date),  // Pending but delivered?
}
```

### The Solution

```
enum Order {
    Pending { items: Vec<Item> },
    Shipped { items: Vec<Item>, shipped_at: Date },
    Delivered { items: Vec<Item>, shipped_at: Date, delivered_at: Date },
}

// Impossible to have delivered_at without shipped_at
// Impossible to have shipped_at when pending
```

### Patterns for This

- **Sum types/enums** for mutually exclusive states
- **Type states** for valid progressions
- **Builder patterns** for complex construction
- **Non-empty collections** when empty is invalid

## 4. Total Functions

A function is **total** if it returns a valid result for ALL inputs of its declared type.

### Partial Function (Bad)

```
function divide(a: number, b: number): number {
    return a / b;  // Crashes when b = 0!
}
```

### Total Function (Good)

```
function divide(a: number, b: NonZeroNumber): number {
    return a / b.value;  // NonZeroNumber guarantees b ≠ 0
}

// Or return Optional
function divide(a: number, b: number): Option<number> {
    if (b === 0) return None;
    return Some(a / b);
}
```

### Where Totality Matters

- Public APIs (library boundaries)
- Domain operations
- Anywhere a crash would be surprising

## 5. Encode Business Rules in Types

If a business rule exists, try to encode it in the type system.

### Example: Order Limits

**Business rule**: Orders must have 1-10 items.

```
// Bad: Runtime validation
function createOrder(items: Item[]): Order {
    if (items.length < 1 || items.length > 10) {
        throw new Error("Invalid item count");
    }
    return new Order(items);
}

// Good: Type encodes the rule
function createOrder(items: NonEmptyBoundedList<Item, 10>): Order {
    return new Order(items);  // Bounds guaranteed by type
}
```

### What Can Be Encoded

- Non-empty collections
- Bounded ranges
- Required combinations (this AND that)
- Exclusive options (this OR that)
- State machines (valid transitions only)
- Format constraints (email, UUID, etc.)

## Language-Specific Application

These principles apply universally, but implementation varies:

| Language | Parse Pattern | Nominal Types | Sum Types |
|----------|--------------|---------------|-----------|
| Rust | `TryFrom`, constructors | newtype pattern | `enum` |
| TypeScript | Factory functions | branded types | discriminated unions |
| Python | `@classmethod`, Pydantic | `NewType`, classes | `Union` with Literal |
| Go | Constructor functions | type aliases + methods | interfaces with type field |
| Elixir | Structs with validation | structs | tagged tuples |

See language-specific docs for idioms.
