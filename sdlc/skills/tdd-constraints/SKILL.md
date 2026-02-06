---
name: tdd-constraints
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Red-green-domain TDD cycle with strict phase boundaries and domain modeling review
tags:
  - tdd
  - test-driven-development
  - domain-modeling
  - workflow
portability: universal
dependencies:
  - debugging-protocol
---

# TDD Constraints

**Version:** 1.0.0
**Portability:** Universal

---

## Objective

Defines a disciplined TDD workflow with three distinct phases (Red, Green, Domain) and strict boundaries between them. Enforces domain modeling review at natural checkpoints to prevent primitive obsession and invalid state representation.

**Purpose:** Ensure tests drive design, maintain clear separation of concerns, and build domain-rich implementations from the start.

**Scope:**
- **Included:** RED/GREEN/DOMAIN phases, file ownership patterns, phase transitions, domain modeling principles, rationalization red flags
- **Excluded:** Specific test frameworks, language-specific syntax, tool-specific workflows

---

## Core Principles

### Principle 1: Three-Phase Cycle (Red → Domain → Green → Domain)

**The Cycle:** Every feature is built through alternating phases with domain review at natural checkpoints.

**Why this matters:** Traditional TDD (red → green → refactor) often skips domain modeling, leading to primitive obsession and anemic models. Adding domain review phases catches these issues early.

**The Four Steps:**
1. **RED:** Write one failing test
2. **DOMAIN (after red):** Review test, create type definitions
3. **GREEN:** Implement minimal code to pass test
4. **DOMAIN (after green):** Review implementation for domain violations

**How to apply:**
- Complete each phase fully before moving to the next
- Don't skip domain reviews ("we'll model it later")
- Each phase has a single, focused responsibility
- Repeat cycle for each acceptance criterion

**Example Cycle:**
```
RED: Write test for User.authenticate(email, password)
  ↓
DOMAIN: Review test, create Email type (not String), Password type, AuthError enum
  ↓
GREEN: Implement User.authenticate() using domain types
  ↓
DOMAIN: Review implementation, check for primitive obsession
  ↓
CYCLE COMPLETE (move to next test)
```

### Principle 2: Strict Phase Boundaries (File Ownership)

**The Principle:** Each phase can only edit specific file types. This creates mechanical enforcement of separation of concerns.

**Why this matters:** Without boundaries, developers drift into "test and implement simultaneously" which defeats TDD's design benefits. Mechanical boundaries prevent drift.

**Phase Ownership:**

**RED Phase - Test Files Only**
- CAN edit: Test files (`*_test.*`, `*.test.*`, `tests/`, `spec/`)
- CANNOT edit: Production code, type definitions, configuration

**DOMAIN Phase - Type Definitions Only**
- CAN edit: Type definitions (structs, enums, interfaces, traits)
- CAN create: Stubs with `unimplemented!()`, `todo!()`, `raise NotImplementedError`
- CANNOT edit: Test logic, implementation bodies

**GREEN Phase - Implementation Bodies Only**
- CAN edit: Function/method implementations, filling in stubs
- CANNOT edit: Test files, type definitions (signatures)

**How to apply:**
- Enforce mechanically (hooks, pre-commit checks, linters)
- If blocked by boundary, STOP and return to workflow coordinator
- Never circumvent boundaries ("just this once")

**Example:**
```rust
// RED phase writes test (test file only)
#[test]
fn user_can_authenticate_with_valid_credentials() {
    let user = User::new(Email::from("user@example.com"), Password::from("secret"));
    let result = user.authenticate("secret");
    assert!(result.is_ok());
}

// DOMAIN phase creates types (type definition files only)
struct User { email: Email, password_hash: PasswordHash }
struct Email(String);  // Newtype
struct Password(String); // Newtype
enum AuthError { InvalidPassword, UserNotFound }

impl User {
    fn new(email: Email, password: Password) -> Self {
        unimplemented!("GREEN phase will implement")
    }

    fn authenticate(&self, password: &str) -> Result<(), AuthError> {
        unimplemented!("GREEN phase will implement")
    }
}

// GREEN phase implements bodies (implementation only)
impl User {
    fn new(email: Email, password: Password) -> Self {
        User {
            email,
            password_hash: PasswordHash::from(password)
        }
    }

    fn authenticate(&self, password: &str) -> Result<(), AuthError> {
        if self.password_hash.verify(password) {
            Ok(())
        } else {
            Err(AuthError::InvalidPassword)
        }
    }
}

// DOMAIN phase reviews: ✓ No primitive obsession, types are meaningful
```

### Principle 3: One Assertion Per Test (Red Phase Constraint)

**The Principle:** Each test verifies exactly one behavior with one assertion.

**Why this matters:** Multiple assertions hide which expectation failed. When a test with 5 assertions fails, you don't know which of the 5 expectations is wrong without investigating.

**How to apply:**
- Write one test with one `assert`
- If you need multiple verifications, write multiple tests
- If setup is complex, extract helper functions

**Example:**
```python
# ❌ Bad: Multiple assertions (which one fails?)
def test_user_registration():
    user = register_user("alice", "alice@example.com", "password123")
    assert user.name == "alice"
    assert user.email == "alice@example.com"
    assert user.password is not None
    assert user.is_active == True
    assert user.created_at is not None

# ✓ Good: One assertion per test (failure is obvious)
def test_user_registration_sets_name():
    user = register_user("alice", "alice@example.com", "password123")
    assert user.name == "alice"

def test_user_registration_sets_email():
    user = register_user("alice", "alice@example.com", "password123")
    assert user.email == "alice@example.com"

def test_user_registration_hashes_password():
    user = register_user("alice", "alice@example.com", "password123")
    assert user.password_hash is not None

def test_user_registration_activates_by_default():
    user = register_user("alice", "alice@example.com", "password123")
    assert user.is_active == True
```

### Principle 4: Minimal Implementation (Green Phase Constraint)

**The Principle:** Write the simplest code that makes the test pass. No more, no less.

**Why this matters:** Over-engineering during green phase adds complexity that isn't tested. YAGNI (You Aren't Gonna Need It) prevents speculative complexity.

**How to apply:**
- Read the failing test
- Write just enough code to make it pass
- Don't add features "while you're here"
- Don't add error handling not required by tests
- Don't add flexibility for future use cases

**Example:**
```typescript
// Test (RED phase)
test('user can register with email', () => {
  const user = registerUser('alice@example.com');
  expect(user.email).toBe('alice@example.com');
});

// ❌ Bad: Over-engineered (not tested)
function registerUser(email: string, options?: {
  role?: 'admin' | 'user',
  metadata?: Record<string, any>,
  sendWelcomeEmail?: boolean
}): User {
  const user = new User(email);
  user.role = options?.role ?? 'user';
  user.metadata = options?.metadata ?? {};

  if (options?.sendWelcomeEmail !== false) {
    sendEmail(user.email, 'Welcome!');
  }

  return user;
}

// ✓ Good: Minimal (exactly what test requires)
function registerUser(email: string): User {
  return new User(email);
}
```

### Principle 5: Domain Modeling Review at Checkpoints

**The Principle:** After RED and after GREEN, pause for domain modeling review before continuing.

**Why this matters:** Traditional TDD often produces anemic models with primitive obsession. Systematic domain review catches these issues at natural breakpoints.

**What Domain Review Checks:**

**After RED (reviewing test):**
- Primitive obsession (using `String` where `Email` should exist)
- Invalid states representable (can test create impossible situations?)
- Parse-don't-validate violations (validation in wrong place)
- Missing domain concepts (implicit knowledge not captured in types)

**After GREEN (reviewing implementation):**
- All the above, plus:
- Domain logic leaking into application layer
- Anemic models (data structures without behavior)
- Missing invariants (rules that should be enforced by types)

**How to apply:**
1. After writing test, pause
2. Review test for domain violations
3. Create/refine type definitions
4. After implementing, pause again
5. Review implementation for violations
6. Refactor if needed

**Example (Primitive Obsession):**
```ruby
# RED phase writes test
def test_user_email_must_be_valid
  user = User.new(email: "invalid-email")
  expect(user).to_not be_valid
end

# DOMAIN review flags: "email" is a String, should be Email type
# DOMAIN creates Email type with validation

class Email
  def initialize(value)
    raise ArgumentError unless value.match?(EMAIL_REGEX)
    @value = value
  end

  def to_s = @value
end

class User
  def initialize(email:)
    @email = email  # Now expects Email object, not String
  end
end

# GREEN implements validation in Email constructor
# DOMAIN reviews: ✓ Parse-don't-validate principle applied
```

---

## Constraints and Boundaries

### DO (Red Phase):
- Write ONE test at a time (not multiple)
- Use ONE assertion per test
- Reference types that don't exist yet (let compilation fail)
- Name tests descriptively (describe behavior being tested)
- Run test and verify it fails for the right reason
- STOP after one test (let cycle continue)

### DON'T (Red Phase):
- Create type definitions (domain's job)
- Fix compilation errors in production code
- Write multiple tests at once
- Write multiple assertions in one test
- "Stub out" implementations while writing tests
- Skip running the test ("I know it will fail")

### DO (Domain Phase after Red):
- Review test for primitive obsession
- Create type definitions (structs, enums, interfaces)
- Use domain language (Email not String, Money not number)
- Create stubs with `unimplemented!()` / `todo!()` / `raise NotImplementedError`
- Veto tests that enable invalid states

### DON'T (Domain Phase after Red):
- Implement method bodies (green's job)
- Change test assertions without discussion
- Skip review because "it's a simple test"
- Use primitives where domain types should exist

### DO (Green Phase):
- Implement minimal code to pass test
- Fill in `unimplemented!()` stubs
- Run test and verify it passes
- STOP when test passes (no "improvements")

### DON'T (Green Phase):
- Edit test files
- Add untested features "while you're here"
- Over-engineer for future use cases
- Skip running tests ("I know it will pass")

### DO (Domain Phase after Green):
- Review implementation for domain violations
- Check for anemic models (data without behavior)
- Ensure invariants are enforced
- Refactor if violations found

### DON'T (Domain Phase after Green):
- Skip review because "it already works"
- Allow primitive obsession to slip through
- Accept "we'll refactor it later"

**Rationale:** These boundaries ensure tests drive design, domain modeling happens systematically, and implementations stay minimal.

---

## Usage Patterns

### Pattern 1: Single Feature Development

**Scenario:** Implementing user authentication.

**Acceptance Criteria:**
1. User can register with email and password
2. User can log in with email and password
3. User login fails with invalid credentials

**Cycle 1 (AC #1 - Registration):**
```
RED:
  Write test_user_can_register_with_email_and_password()
  Test fails: User type doesn't exist
  STOP ← Return control

DOMAIN (after red):
  Review test: Email and Password are strings (primitive obsession!)
  Create: Email type, Password type, User type
  All methods use unimplemented!()
  STOP ← Return control

GREEN:
  Implement User::new(email: Email, password: Password)
  Test now compiles and passes
  STOP ← Return control

DOMAIN (after green):
  Review implementation: ✓ No primitive obsession
  Review implementation: ✓ Password is hashed, not stored plaintext
  No violations found
  STOP ← Cycle complete

Move to Cycle 2 (AC #2)
```

### Pattern 2: Domain Modeling Intervention

**Scenario:** Domain review catches primitive obsession.

**RED writes:**
```typescript
test('order calculates total price', () => {
  const order = new Order();
  order.addItem('Widget', 10.99, 2);
  order.addItem('Gadget', 5.50, 1);
  expect(order.total).toBe(27.48);
});
```

**DOMAIN reviews:**
- ❌ Item is primitive (name: string, price: number, quantity: number)
- ❌ Money is number (should be Money type)
- ❌ Quantity is number (should be Quantity type)

**DOMAIN creates types:**
```typescript
class Money {
  constructor(private readonly amount: number, readonly currency: string = 'USD') {
    if (amount < 0) throw new Error('Money cannot be negative');
  }

  add(other: Money): Money {
    if (this.currency !== other.currency) throw new Error('Currency mismatch');
    return new Money(this.amount + other.amount, this.currency);
  }

  multiply(factor: number): Money {
    return new Money(this.amount * factor, this.currency);
  }
}

class Quantity {
  constructor(private readonly value: number) {
    if (value < 0) throw new Error('Quantity cannot be negative');
    if (!Number.isInteger(value)) throw new Error('Quantity must be whole number');
  }

  getValue(): number { return this.value; }
}

class OrderItem {
  constructor(
    readonly name: string,
    readonly price: Money,
    readonly quantity: Quantity
  ) {}

  subtotal(): Money {
    return this.price.multiply(this.quantity.getValue());
  }
}

class Order {
  private items: OrderItem[] = [];

  addItem(name: string, price: number, quantity: number): void {
    this.items.push(new OrderItem(
      name,
      new Money(price),
      new Quantity(quantity)
    ));
  }

  total(): Money {
    return this.items.reduce(
      (sum, item) => sum.add(item.subtotal()),
      new Money(0)
    );
  }
}
```

**GREEN implements** (already done by domain! Just fills stubs if any).

**DOMAIN reviews GREEN:** ✓ Domain-rich model, invalid states impossible.

### Pattern 3: Drill-Down Testing

**Scenario:** Test reveals complex behavior needing sub-tests.

**Initial test (too broad):**
```rust
#[test]
fn order_validation_catches_all_errors() {
    let order = Order::new();
    let result = order.validate();
    assert!(result.is_err());
}
```

**Realization:** "All errors" is vague. Need specific tests.

**Drill-down approach:**
1. Ignore broad test temporarily (`#[ignore]`)
2. Write focused tests:
   - `test_order_validation_fails_when_empty`
   - `test_order_validation_fails_when_no_shipping_address`
   - `test_order_validation_fails_when_payment_invalid`
3. Each focused test goes through full cycle
4. Remove ignored broad test once all cases covered

---

## Integration with Other Skills

**Works well with:**
- **debugging-protocol:** When test fails unexpectedly, use 4-phase debugging
- **user-input-protocol:** When domain review hits ambiguous business rule, pause and ask
- **atomic-design:** Apply TDD to UI components (test rendering, interactions)

**Prerequisites:**
- Test framework (JUnit, pytest, RSpec, etc.)
- Domain-driven design understanding
- Discipline to follow phase boundaries

---

## Common Pitfalls

### Pitfall 1: Writing Multiple Tests at Once

**Problem:** "Let me write all the tests for this feature"

**Solution:** ONE test, then complete the cycle. Multiple tests = multiple assumptions = unclear failures.

### Pitfall 2: Skipping Domain Review

**Problem:** "This is simple, we don't need to model it"

**Solution:** "Simple" features often have implicit domain concepts. Always review. Primitive obsession starts with "simple" code.

### Pitfall 3: Over-Engineering in Green Phase

**Problem:** Adding error handling, logging, flexibility not required by test

**Solution:** Write ONLY what makes the test pass. Future tests will drive additional features.

### Pitfall 4: Multiple Assertions Per Test

**Problem:** One test verifies 5 different things

**Solution:** Split into 5 tests. Shared setup can be extracted to helper functions.

### Pitfall 5: Drifting Between Phases

**Problem:** "While writing the test, I'll just quickly add this type" (RED doing DOMAIN's job)

**Solution:** STOP. File boundaries prevent drift. If you're blocked, return control to workflow coordinator.

### Pitfall 6: "I Know It Will Fail/Pass" (Skipping Test Runs)

**Problem:** Not actually running tests, assuming outcome

**Solution:** ALWAYS run tests. Assumptions cause bugs. Evidence prevents them.

---

## Examples

### Example 1: Money Type (Preventing Primitive Obsession)

**RED Phase:**
```java
@Test
public void testOrderTotalWithMultipleItems() {
    Order order = new Order();
    order.addItem("Widget", 10.99, 2);
    order.addItem("Gadget", 5.50, 1);
    assertEquals(27.48, order.getTotal(), 0.01);
}
```

**DOMAIN Review (after red):**
```
❌ Price is double (primitive obsession)
❌ Total is double (primitive obsession)
❌ No currency information
❌ Floating point arithmetic for money (precision errors!)

Create Money type instead.
```

**DOMAIN Phase:**
```java
public class Money {
    private final long amountInCents;  // Avoid floating point!
    private final String currency;

    public Money(String amount, String currency) {
        this.amountInCents = new BigDecimal(amount)
            .multiply(new BigDecimal("100"))
            .longValue();
        this.currency = currency;
    }

    public Money add(Money other) {
        if (!this.currency.equals(other.currency)) {
            throw new CurrencyMismatchException();
        }
        long sum = this.amountInCents + other.amountInCents;
        return new Money(sum, this.currency);
    }

    public Money multiply(int quantity) {
        return new Money(this.amountInCents * quantity, this.currency);
    }

    public BigDecimal toDecimal() {
        return new BigDecimal(amountInCents).divide(new BigDecimal("100"));
    }
}

public class Order {
    private List<OrderItem> items = new ArrayList<>();

    public void addItem(String name, String price, int quantity) {
        // Implementation will be added in GREEN phase
        throw new UnsupportedOperationException("Not implemented yet");
    }

    public Money getTotal() {
        throw new UnsupportedOperationException("Not implemented yet");
    }
}
```

**GREEN Phase:**
```java
public class Order {
    private List<OrderItem> items = new ArrayList<>();

    public void addItem(String name, String price, int quantity) {
        Money itemPrice = new Money(price, "USD");
        items.add(new OrderItem(name, itemPrice, quantity));
    }

    public Money getTotal() {
        Money total = new Money("0.00", "USD");
        for (OrderItem item : items) {
            total = total.add(item.getSubtotal());
        }
        return total;
    }
}

class OrderItem {
    private String name;
    private Money price;
    private int quantity;

    public OrderItem(String name, Money price, int quantity) {
        this.name = name;
        this.price = price;
        this.quantity = quantity;
    }

    public Money getSubtotal() {
        return price.multiply(quantity);
    }
}
```

**DOMAIN Review (after green):**
```
✓ Money type prevents floating point errors
✓ Currency is explicit
✓ Invalid states impossible (negative money throws exception)
✓ Domain-rich model (Money has behavior, not just data)

APPROVED
```

### Example 2: Email Validation (Parse-Don't-Validate)

**RED Phase:**
```python
def test_user_registration_rejects_invalid_email():
    with pytest.raises(InvalidEmailError):
        User(email="not-an-email", password="secret123")
```

**DOMAIN Review (after red):**
```
❌ Email is string (primitive obsession)
❌ Validation logic will leak into User class
❌ Need Email type that validates on construction
```

**DOMAIN Phase:**
```python
import re

class Email:
    """Email type that enforces validity at construction."""

    EMAIL_REGEX = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')

    def __init__(self, value: str):
        if not self.EMAIL_REGEX.match(value):
            raise InvalidEmailError(f"Invalid email: {value}")
        self._value = value

    def __str__(self) -> str:
        return self._value

    def __eq__(self, other) -> bool:
        return isinstance(other, Email) and self._value == other._value

class Password:
    """Password type (placeholder for hashing)."""
    def __init__(self, plaintext: str):
        self._hash = self._hash_password(plaintext)

    def _hash_password(self, plaintext: str) -> str:
        raise NotImplementedError("GREEN phase will implement")

    def verify(self, plaintext: str) -> bool:
        raise NotImplementedError("GREEN phase will implement")

class User:
    def __init__(self, email: Email, password: Password):
        raise NotImplementedError("GREEN phase will implement")
```

**GREEN Phase:**
```python
import hashlib

class Password:
    def __init__(self, plaintext: str):
        self._hash = self._hash_password(plaintext)

    def _hash_password(self, plaintext: str) -> str:
        return hashlib.sha256(plaintext.encode()).hexdigest()

    def verify(self, plaintext: str) -> bool:
        return self._hash == self._hash_password(plaintext)

class User:
    def __init__(self, email: Email, password: Password):
        self.email = email
        self.password = password
```

**DOMAIN Review (after green):**
```
✓ Parse-don't-validate: Email validates at boundary
✓ Invalid emails cannot exist in system
✓ User class doesn't need validation logic
✓ Password is hashed, not stored as plaintext

APPROVED
```

### Example 3: Invalid State Made Unrepresentable

**RED Phase:**
```typescript
test('published article has author and content', () => {
  const article = new Article();
  article.status = 'published';
  expect(article.author).not.toBeNull();
  expect(article.content).not.toBeNull();
});
```

**DOMAIN Review (after red):**
```
❌ Status is string (enum of states)
❌ Can create published article without author/content (invalid state!)
❌ Need type-state pattern: Draft vs Published
```

**DOMAIN Phase:**
```typescript
// Use type-state pattern to make invalid states unrepresentable

interface Draft {
  kind: 'draft';
  content?: string;
  // No author required for drafts
}

interface Published {
  kind: 'published';
  content: string;  // Required
  author: string;   // Required
  publishedAt: Date; // Required
}

type Article = Draft | Published;

function createDraft(): Draft {
  return { kind: 'draft' };
}

function publish(draft: Draft, author: string): Published {
  if (!draft.content) {
    throw new Error('Cannot publish draft without content');
  }

  return {
    kind: 'published',
    content: draft.content,
    author,
    publishedAt: new Date()
  };
}
```

**GREEN Phase:** (Already complete - domain created full implementation)

**DOMAIN Review (after green):**
```
✓ Cannot create published article without author/content
✓ Type system enforces invariants
✓ Invalid states are literally impossible
✓ No runtime checks needed (compile-time safety)

APPROVED
```

---

## Rationalization Red Flags

Watch for these thoughts - they indicate you're about to violate TDD discipline:

| If you're thinking... | The truth is... | Correct action |
|-----------------------|-----------------|----------------|
| "Let me write a few tests at once to be efficient" | Multiple tests = multiple assumptions = unclear failures | Write ONE test, verify it fails, STOP |
| "The domain type isn't needed for this test" | Primitive obsession starts small. Using String instead of Email is a slippery slope | Use domain types from the start |
| "I'll test the edge case later" | "Later" means "never" in TDD. Tests drive design NOW | Write the edge case test now |
| "This is a simple test, I don't need to run it" | If you didn't watch it fail, you don't know it tests anything | Run EVERY test and verify failure |
| "I know what the failure will look like" | Assumptions cause bugs. Evidence prevents them | Run the test, observe actual output |
| "The acceptance criteria don't need exact coverage" | Acceptance criteria ARE the requirements. Missing one = incomplete work | Map EVERY criterion to a test |
| "Let me quickly add this implementation to see if the test works" | You're drifting toward "test after" - the cardinal sin | STOP. Complete RED phase first |
| "This is just data, it doesn't need domain modeling" | Anemic models start with "just data". Behavior belongs with data | Review for missing behavior |
| "We can add domain types later when we need them" | Later = never. Refactoring away from primitives is painful | Model the domain NOW |

**When you catch yourself thinking these things, STOP and return to the protocol.**

---

## Verification Checklist

Use this checklist to verify you're following TDD constraints:

**RED Phase:**
- [ ] Wrote exactly ONE test (not multiple)
- [ ] Test has exactly ONE assertion
- [ ] Test uses domain types (not primitives like String, number)
- [ ] Ran test and verified it fails
- [ ] Pasted actual failure output (not "I expect it to fail")
- [ ] Stopped after one test (returned control)

**DOMAIN Phase (after red):**
- [ ] Reviewed test for primitive obsession
- [ ] Created domain types where primitives were used
- [ ] Types use domain language (Email, Money, not String, number)
- [ ] Types have stubs (`unimplemented!()`, `todo!()`)
- [ ] Did not implement method bodies
- [ ] Stopped after domain review (returned control)

**GREEN Phase:**
- [ ] Implemented minimal code to pass test
- [ ] Did not add untested features
- [ ] Ran test and verified it passes
- [ ] Pasted actual success output (not "I expect it to pass")
- [ ] Stopped after test passes (returned control)

**DOMAIN Phase (after green):**
- [ ] Reviewed implementation for domain violations
- [ ] Checked for anemic models (data without behavior)
- [ ] Verified invariants are enforced
- [ ] No primitive obsession slipped through
- [ ] Stopped after domain review (cycle complete)

---

## References

**Source Documentation:**
- sdlc plugin: commands/shared/tdd-constraints.md
- sdlc plugin: agents/red.md, agents/green.md, agents/domain.md

**Related Skills:**
- debugging-protocol - Investigation when tests fail unexpectedly
- user-input-protocol - Pausing when domain rules are ambiguous

**External Resources:**
- Test-Driven Development by Kent Beck
- Domain-Driven Design by Eric Evans
- Parse, Don't Validate by Alexis King
- Making Impossible States Impossible by Richard Feldman
- Growing Object-Oriented Software, Guided by Tests by Freeman & Pryce

---

## Version History

### v1.0.0 (2026-02-04)
- Initial extraction from sdlc plugin
- Three-phase cycle: RED → DOMAIN → GREEN → DOMAIN
- Strict phase boundaries with file ownership patterns
- Domain modeling review at checkpoints
- Rationalization red flags
- Universal principles (framework-agnostic)

---

## Metadata

**Extraction Source:** sdlc plugin (tdd-constraints.md, red.md, green.md, domain.md)
**Extraction Date:** 2026-02-04
**Last Updated:** 2026-02-04
**Compatibility:** Universal (all languages and test frameworks)
**License:** MIT
