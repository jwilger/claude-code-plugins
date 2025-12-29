# Domain Modeling in TypeScript

TypeScript-specific patterns for type-driven development.

## Branded Types

TypeScript's structural typing means two identical structures are interchangeable.
Branded types add a unique "brand" to distinguish them:

```typescript
// Brand symbol
declare const brand: unique symbol;

// Branded type helper
type Brand<T, B> = T & { [brand]: B };

// Domain types
type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;
type Email = Brand<string, 'Email'>;
type Money = Brand<number, 'Money'>;  // Cents

// Constructor functions
function createUserId(value: string): UserId {
    // Validation here
    return value as UserId;
}

function createEmail(value: string): Email | null {
    if (!value.includes('@')) return null;
    return value as Email;
}

// Now these are NOT interchangeable
function getUser(id: UserId): User { ... }
getUser(orderId);  // Type error!
```

## Zod for Runtime Validation

Zod provides runtime validation with TypeScript type inference:

```typescript
import { z } from 'zod';

// Define schema
const EmailSchema = z.string().email();
const UserIdSchema = z.string().uuid();
const MoneySchema = z.number().int().nonnegative();

const UserSchema = z.object({
    id: UserIdSchema,
    email: EmailSchema,
    balance: MoneySchema,
});

// Infer TypeScript types
type Email = z.infer<typeof EmailSchema>;
type UserId = z.infer<typeof UserIdSchema>;
type User = z.infer<typeof UserSchema>;

// Parse (returns typed result or throws)
const email = EmailSchema.parse(userInput);  // Email type

// Safe parse (returns Result-like object)
const result = EmailSchema.safeParse(userInput);
if (result.success) {
    const email: Email = result.data;
}
```

### Zod with Brands

Combine Zod validation with branded types:

```typescript
const EmailSchema = z.string().email().brand<'Email'>();
type Email = z.infer<typeof EmailSchema>;  // string & { __brand: 'Email' }
```

## Discriminated Unions

TypeScript's discriminated unions for sum types:

```typescript
type PaymentMethod =
    | { type: 'credit_card'; number: CardNumber; expiry: Expiry; cvv: Cvv }
    | { type: 'bank_transfer'; iban: Iban; bic: Bic }
    | { type: 'paypal'; email: Email };

type OrderStatus =
    | { status: 'pending' }
    | { status: 'confirmed'; confirmedAt: Date }
    | { status: 'shipped'; shippedAt: Date; tracking: TrackingNumber }
    | { status: 'delivered'; deliveredAt: Date }
    | { status: 'cancelled'; reason: string };

// Exhaustive handling
function handleOrder(order: OrderStatus): string {
    switch (order.status) {
        case 'pending': return 'Waiting...';
        case 'confirmed': return `Confirmed at ${order.confirmedAt}`;
        case 'shipped': return `Track: ${order.tracking}`;
        case 'delivered': return 'Done!';
        case 'cancelled': return `Cancelled: ${order.reason}`;
        // TypeScript ensures all cases handled
    }
}
```

## Type State Pattern

```typescript
// State markers (never instantiated)
interface Draft { readonly _state: 'draft' }
interface Submitted { readonly _state: 'submitted' }
interface Approved { readonly _state: 'approved' }

// Document with state
interface Document<S> {
    content: string;
    _phantom?: S;  // For type inference
}

// State-specific functions
function createDocument(content: string): Document<Draft> {
    return { content };
}

function submit(doc: Document<Draft>): Document<Submitted> {
    return { content: doc.content };
}

function approve(doc: Document<Submitted>): Document<Approved> {
    return { content: doc.content };
}

function publish(doc: Document<Approved>): void {
    // Only callable with approved docs
}

// Usage
const draft = createDocument('hello');
// publish(draft);  // Type error!
const submitted = submit(draft);
const approved = approve(submitted);
publish(approved);  // OK
```

## Non-Empty Arrays

```typescript
type NonEmptyArray<T> = [T, ...T[]];

function first<T>(arr: NonEmptyArray<T>): T {
    return arr[0];  // Always safe!
}

function fromArray<T>(arr: T[]): NonEmptyArray<T> | null {
    if (arr.length === 0) return null;
    return arr as NonEmptyArray<T>;
}

// With Zod
const NonEmptyStringArray = z.array(z.string()).min(1);
```

## Result Type (No Exceptions)

```typescript
type Result<T, E> =
    | { ok: true; value: T }
    | { ok: false; error: E };

function ok<T>(value: T): Result<T, never> {
    return { ok: true, value };
}

function err<E>(error: E): Result<never, E> {
    return { ok: false, error };
}

// Usage
function divide(a: number, b: number): Result<number, 'division_by_zero'> {
    if (b === 0) return err('division_by_zero');
    return ok(a / b);
}

const result = divide(10, 2);
if (result.ok) {
    console.log(result.value);  // number
} else {
    console.log(result.error);  // 'division_by_zero'
}
```

Or use libraries like `neverthrow` or `fp-ts`.

## Class-Based Domain Types

When you need methods on domain types:

```typescript
class Money {
    private constructor(private readonly cents: number) {}

    static fromCents(cents: number): Money {
        if (!Number.isInteger(cents) || cents < 0) {
            throw new Error('Invalid money amount');
        }
        return new Money(cents);
    }

    static fromDollars(dollars: number): Money {
        return Money.fromCents(Math.round(dollars * 100));
    }

    add(other: Money): Money {
        return new Money(this.cents + other.cents);
    }

    subtract(other: Money): Money | null {
        if (other.cents > this.cents) return null;
        return new Money(this.cents - other.cents);
    }

    toCents(): number {
        return this.cents;
    }

    toDollars(): number {
        return this.cents / 100;
    }
}
```

## Recommended Libraries

| Library | Purpose |
|---------|---------|
| `zod` | Schema validation with type inference |
| `neverthrow` | Result type for error handling |
| `fp-ts` | Functional programming utilities |
| `ts-pattern` | Pattern matching |
| `tiny-invariant` | Runtime assertions |
