---
user-invocable: false
name: event-modeling
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Event Modeling facilitation methodology for event-sourced system design
tags:
  - event-modeling
  - event-sourcing
  - domain-driven-design
  - facilitation
  - requirements
portability: high
dependencies: []
---

# Event Modeling

**Version:** 1.0.0
**Portability:** High

---

## Objective

Teaches Event Modeling facilitation based on Martin Dilger's "Understanding Eventsourcing" methodology, enabling systematic discovery of business domains and design of event-sourced systems through structured conversation.

**Purpose:** Reveal hidden domain knowledge, create shared understanding, and design systems that "don't lose information" through immutable event streams.

**Scope:**
- **Included:** Two-phase process (discovery → workflow), seven-step workflow design, four event patterns, vertical slicing, facilitation techniques
- **Excluded:** Implementation details, database schemas, technology choices, API design

---

## Core Principles

### Principle 1: Not Losing Information (Prime Directive)

**The Principle:** Store what happened (events), not just current state. Events are immutable facts that can be replayed, analyzed, and projected.

**Why this matters:** State-only systems lose the "why" behind current state. Event streams preserve full history, enabling audit trails, temporal queries, and business intelligence impossible with CRUD.

**How to apply:**
- Capture events when things happen
- Never delete or modify events (append-only)
- Build read models by projecting from event streams
- Every state change leaves an event trail

**Example:**
```
# ❌ State-only (information lost)
User { balance: $50 }
# Can't answer: How did they get $50? What transactions occurred?

# ✓ Event stream (complete history)
UserRegistered { userId: 123, initialBalance: $0 }
MoneyDeposited { userId: 123, amount: $100, timestamp: T1 }
MoneyWithdrawn { userId: 123, amount: $30, timestamp: T2 }
MoneyWithdrawn { userId: 123, amount: $20, timestamp: T3 }

# Can answer: How? When? Why? What sequence?
# Current state: Project events → balance = $50
```

### Principle 2: Event Modeling Reveals Understanding (Process Over Documentation)

**The Principle:** Event modeling is a structured conversation that surfaces hidden assumptions and creates shared understanding. You cannot skip steps because you think you understand.

**Why this matters:** Domain experts have tacit knowledge they don't know they have. The systematic process of event modeling extracts this knowledge through probing questions.

**How to apply:**
- Follow all seven steps (no shortcuts)
- Ask "And then what happens?" relentlessly
- Challenge assumptions (even obvious ones)
- Use business language, not technical jargon
- Facilitate conversation, don't dictate solutions

**Example of revelation:**
```
Facilitator: "What happens after the order is placed?"
Expert: "We fulfill it."
Facilitator: "And then what happens?"
Expert: "Well, first we check inventory..."
Facilitator: "And then?"
Expert: "If items are in stock, we reserve them."
Facilitator: "What if items aren't in stock?"
Expert: "Oh! We backorder them. I guess we need BackorderCreated event..."
# ↑ Hidden complexity revealed through questioning
```

### Principle 3: Events Are Past-Tense Facts in Business Language

**The Principle:** Events are immutable facts that happened, named in past tense using domain language that business experts understand.

**Why this matters:** Events form the foundation of system behavior and audit logs. Clear, business-aligned names make the system comprehensible to non-technical stakeholders.

**Event naming rules:**
- Past tense (UserRegistered, not RegisterUser)
- Business language (OrderPlaced, not CreateOrderCommand)
- Specific (ItemAddedToCart, not CartUpdated)
- Immutable facts (never change event names or delete events)

**How to apply:**
```
❌ Bad (technical, present tense):
- ProcessPayment
- UpdateUser
- DeleteItem

✓ Good (business, past tense):
- PaymentReceived
- EmailAddressChanged
- ItemRemovedFromCart
```

### Principle 4: Two-Phase Process (Discovery Then Design)

**The Principle:** Start with broad domain discovery before diving deep into any single workflow.

**Why this matters:** Jumping into detailed workflow design without understanding the broader domain leads to siloed thinking and missing connections between workflows.

**The Two Phases:**
1. **Domain Discovery:** What does the business do? Who are the actors? What are the major processes?
2. **Workflow Design:** For each workflow, follow seven steps to design events, commands, read models, automations.

**How to apply:**
```
# Phase 1: Domain Discovery (broad)
- Business: E-commerce platform
- Actors: Customers, Sellers, Admins
- Major processes: Product browsing, ordering, payment, fulfillment, returns
- External systems: Stripe (payment), ShipStation (shipping)
- Workflows to model: Order placement, Returns, Inventory management
- Start with: Order placement (most critical)

# Phase 2: Workflow Design (deep, one at a time)
- Order placement workflow: User goal → Events → Commands → Read Models → Automations
- Returns workflow: (separate branch, after order placement)
- Inventory management: (separate branch, after returns)
```

---

## Constraints and Boundaries

### DO (Facilitation):
- Follow all seven steps in workflow design (no shortcuts)
- Ask "And then what happens?" after every event
- Use business language (not technical jargon)
- Challenge assumptions (even obvious ones)
- Ensure information completeness (every read model field traces to events)
- Design one workflow at a time (don't jump between)
- Focus on behavior and business rules

### DON'T (Facilitation):
- Skip steps because you think you know enough
- Make architecture decisions during event modeling
- Discuss technical implementation (databases, APIs, frameworks)
- Rush to documentation
- Assume you understand domain better than expert
- Design workflows simultaneously (do one at a time)

### DO (Event Design):
- Name events in past tense (OrderPlaced, UserRegistered)
- Use business language domain experts understand
- Make events immutable facts
- Include relevant data in events (what, when, who)
- Find right granularity (not too coarse, not too fine)

### DON'T (Event Design):
- Use present tense (ProcessPayment → PaymentProcessed)
- Use technical language (CreateOrderDTO → OrderCreated)
- Modify or delete events (append-only)
- Include implementation details in event names
- Make events too broad (DataUpdated) or too narrow (FieldXChanged)

**Rationale:** Event modeling is a facilitation technique for revealing domain knowledge, not a technical design exercise. Keep it focused on business behavior.

---

## Usage Patterns

### Pattern 1: Complete Event Modeling Process

**Scenario:** Starting a new project or major feature.

**Phase 1: Domain Discovery**

**Questions to ask:**
1. What does this business/system do?
2. Who are the actors (roles, goals)?
3. What are the major processes?
4. What external systems exist?
5. What workflows should we model?
6. Which workflow should we start with? (and why)

**Example (E-commerce):**
```
1. Business: Online marketplace connecting sellers and buyers
2. Actors:
   - Customers (buy products)
   - Sellers (list products, fulfill orders)
   - Admins (moderate, handle disputes)
3. Major processes:
   - Product catalog management
   - Order placement and fulfillment
   - Payment processing
   - Returns and refunds
   - Shipping and tracking
4. External systems:
   - Stripe (payments)
   - ShipStation (shipping)
   - Sendgrid (email)
5. Workflows to model:
   - Order placement (critical path)
   - Product listing
   - Returns processing
6. Start with: Order placement (generates revenue, most complex)
```

**Output:** `docs/event_model/domain/overview.md`

**Phase 2: Workflow Design (per workflow)**

**The Seven Steps:**

**Step 1: Identify User Goal**
```
Question: "What is the user trying to accomplish?"

Answer: "Customer wants to purchase products"

Goal: Complete a purchase from cart to payment
```

**Step 2: Brainstorm Events** (sticky-note style)
```
Question: "What facts need recording?"

Events (no order yet):
- OrderPlaced
- PaymentReceived
- InventoryReserved
- OrderConfirmationSent
- ShippingAddressValidated
- TaxCalculated
- ...
```

**Step 3: Order Events Chronologically**
```
Timeline (left to right):
1. ShippingAddressValidated
2. TaxCalculated
3. OrderPlaced
4. PaymentReceived
5. InventoryReserved
6. OrderConfirmationSent
```

**Step 4: Identify Commands**
```
For each event, what triggered it?

ShippingAddressValidated ← ValidateShippingAddress
TaxCalculated ← CalculateTax
OrderPlaced ← PlaceOrder
PaymentReceived ← (external: Stripe webhook)
InventoryReserved ← ReserveInventory (automation)
OrderConfirmationSent ← SendOrderConfirmation (automation)
```

**Step 5: Design Read Models**
```
Question: "What does each actor need to see?"

Customer needs:
- OrderSummary (items, total, status)
- ShippingAddress
- PaymentStatus

Seller needs:
- OrdersToFulfill (list)
- InventoryLevels

Admin needs:
- AllOrders (dashboard)
- PaymentIssues (monitoring)
```

**Step 6: Find Automations**
```
Event → Process → Command → Event

OrderPlaced → CheckInventory → ReserveInventory → InventoryReserved
PaymentReceived → SendConfirmation → SendOrderConfirmation → OrderConfirmationSent
```

**Step 7: Map External Integrations**
```
External System → Translation → Internal Event

Stripe webhook → process payment data → PaymentReceived
ShipStation API → track shipment → ShipmentDispatched
```

**Output:** `docs/event_model/workflows/order-placement.md`

### Pattern 2: The Four Event Patterns

**Pattern 1: State Change**
```
Command → Event (only way to modify state)

PlaceOrder → OrderPlaced
CancelOrder → OrderCancelled
AddItemToCart → ItemAddedToCart
```

**Pattern 2: State View**
```
Events → Read Model (query stored events)

[OrderPlaced, ItemAdded, ItemAdded, ItemRemoved] → ShoppingCart
[UserRegistered, EmailChanged, PasswordReset] → UserProfile
```

**Pattern 3: Automation**
```
Event → Process → Command → Event

OrderPlaced → CheckInventory → ReserveInventory → InventoryReserved
PaymentReceived → ValidateOrder → ConfirmOrder → OrderConfirmed
InventoryLow → CheckThreshold → ReorderStock → StockReordered
```

**Pattern 4: Translation**
```
External Data → Internal Event (anti-corruption layer)

StripeWebhook{charge.succeeded} → PaymentReceived
PayPalIPN{payment_status: completed} → PaymentReceived
ShipStationWebhook{shipped} → ShipmentDispatched
```

### Pattern 3: Vertical Slicing

**Good Vertical Slice:**
```
Name: "Customer can place an order"

Flow:
[View Cart] → PlaceOrder → OrderPlaced → [Show Confirmation]

Complete:
- UI component (cart page, checkout button)
- Command handler (PlaceOrder)
- Event (OrderPlaced)
- Read model update (OrderSummary)
- UI update (confirmation page)

Value: Customer can complete purchase
Testable: End-to-end in isolation
```

**Bad Slices (avoid):**
```
❌ "Set up order database" - Technical, no user value
❌ "Implement order system" - Too broad, not independently testable
❌ "Create Order table" - Implementation detail, not behavior
```

**Slice characteristics:**
- Complete user interaction (UI → event → UI)
- Independently valuable (delivers user value)
- Testable in isolation (no dependencies on other slices)
- Small enough to complete in 1-2 days

### Pattern 4: Information Completeness Check

**Principle:** Every read model attribute must trace back to an event.

**Example:**
```
Read Model: OrderSummary
- orderId ← OrderPlaced.orderId
- customerId ← OrderPlaced.customerId
- items ← ItemAdded, ItemRemoved events
- totalAmount ← OrderPlaced.totalAmount
- shippingAddress ← ShippingAddressValidated.address
- status ← OrderPlaced, PaymentReceived, OrderShipped, OrderDelivered

✓ All fields trace to events (information complete)
```

**Missing data example:**
```
Read Model: OrderSummary
- estimatedDelivery ← ??? (no event provides this)

Problem: Need ShippingEstimateCalculated event
or
Solution: Calculate from ShippingAddressValidated + ShippingMethod
```

---

## Integration with Other Skills

**Works well with:**
- **tdd-constraints:** Each vertical slice → one TDD cycle
- **domain-modeling:** Events reveal domain types (Email, Money, OrderStatus)
- **github-issues:** Each workflow → epic, each slice → sub-issue
- **atomic-design:** Read models inform UI component needs

**Prerequisites:**
- Domain expert access (business stakeholder who knows the processes)
- Whiteboard or collaborative tool (physical or digital)
- Time for thorough facilitation (don't rush)

---

## Common Pitfalls

### Pitfall 1: Jumping to Implementation

**Problem:** Discussing databases, APIs, frameworks during event modeling

**Solution:** Stop. Event modeling is about behavior, not implementation. Architecture decisions come later.

**Example:**
```
❌ Bad:
"We'll store orders in PostgreSQL with a relational schema..."

✓ Good:
"OrderPlaced event contains order data. Read models built from events."
```

### Pitfall 2: Skipping Steps

**Problem:** "I understand the domain, let's skip brainstorming events"

**Solution:** Follow all seven steps. The process reveals hidden knowledge.

### Pitfall 3: Using Technical Language

**Problem:** Events named CreateOrderDTO, ProcessPaymentTransaction

**Solution:** Use business language: OrderPlaced, PaymentReceived

### Pitfall 4: Missing "And Then What Happens?"

**Problem:** Stopping too early, missing edge cases and automations

**Solution:** Keep asking. After every event, every answer, keep probing.

**Example:**
```
"Order is placed"
→ "And then what happens?"
"Payment is processed"
→ "And then what happens?"
"Inventory is reserved"
→ "And then what happens?"
"Confirmation email is sent"
→ "And then what happens?"
"Order appears in seller dashboard"
→ "And then what happens?" (continue until workflow complete)
```

### Pitfall 5: Designing Multiple Workflows Simultaneously

**Problem:** Jumping between workflows during design

**Solution:** Complete one workflow fully (all seven steps) before starting next. Use separate branches/PRs.

---

## Examples

### Example 1: User Registration Workflow

**User Goal:** Create an account to access the platform

**Step 2: Brainstorm Events**
```
- UserRegistered
- EmailVerificationSent
- EmailVerified
- WelcomeEmailSent
- ProfileCreated
```

**Step 3: Order Chronologically**
```
1. UserRegistered (user submits form)
2. EmailVerificationSent (system sends email)
3. EmailVerified (user clicks link)
4. ProfileCreated (system creates profile)
5. WelcomeEmailSent (system sends welcome)
```

**Step 4: Identify Commands**
```
RegisterUser → UserRegistered
(automatic) → EmailVerificationSent
VerifyEmail → EmailVerified
(automatic) → ProfileCreated
(automatic) → WelcomeEmailSent
```

**Step 5: Design Read Models**
```
User sees:
- RegistrationStatus (pending, verified)

System needs:
- UnverifiedUsers (admin monitoring)
- UserProfile (for authenticated users)
```

**Step 6: Find Automations**
```
UserRegistered → GenerateVerificationToken → SendVerificationEmail → EmailVerificationSent

EmailVerified → CreateDefaultProfile → CreateProfile → ProfileCreated

ProfileCreated → SendWelcome → SendWelcomeEmail → WelcomeEmailSent
```

**Step 7: Map External Integrations**
```
SendGrid API → email sent status → EmailDelivered (optional tracking)
```

**Vertical Slice:**
```
"User can register and verify email"

UI: Registration form → Submit
Command: RegisterUser
Events: UserRegistered, EmailVerificationSent
UI: "Check your email" message

UI: Email link → Click
Command: VerifyEmail
Events: EmailVerified, ProfileCreated
UI: "Account verified" redirect to dashboard
```

### Example 2: Order Placement with Edge Cases

**User Goal:** Purchase items from cart

**Initial Brainstorm:**
```
- OrderPlaced
- PaymentReceived
- InventoryReserved
```

**Facilitation reveals edge cases:**
```
Facilitator: "What if payment fails?"
Expert: "We retry 3 times, then mark order as failed"

Added events:
- PaymentFailed
- PaymentRetried
- OrderFailed
```

```
Facilitator: "What if inventory isn't available?"
Expert: "We backorder and notify customer"

Added events:
- InventoryUnavailable
- BackorderCreated
- BackorderNotificationSent
```

**Complete Event Timeline:**
```
Happy path:
1. OrderPlaced
2. PaymentReceived
3. InventoryReserved
4. OrderConfirmationSent

Payment failure path:
1. OrderPlaced
2. PaymentFailed
3. PaymentRetried
4. PaymentFailed
5. PaymentRetried
6. PaymentReceived (or OrderFailed after 3 retries)

Inventory unavailable path:
1. OrderPlaced
2. PaymentReceived
3. InventoryUnavailable
4. BackorderCreated
5. BackorderNotificationSent
```

**Automations:**
```
PaymentFailed → WaitAndRetry → RetryPayment → (PaymentReceived or PaymentFailed)

InventoryUnavailable → CheckBackorder → CreateBackorder → BackorderCreated
```

### Example 3: Four Patterns in Context

**State Change (explicit):**
```
User clicks "Place Order" button
→ PlaceOrder command
→ OrderPlaced event
→ Order aggregate state changes to "Pending"
```

**State View (projection):**
```
Events:
- ItemAddedToCart{productId: 1, quantity: 2}
- ItemAddedToCart{productId: 2, quantity: 1}
- ItemRemovedFromCart{productId: 1, quantity: 1}

Read Model (ShoppingCart):
- items: [
    {productId: 1, quantity: 1},  # 2 added - 1 removed
    {productId: 2, quantity: 1}
  ]
- totalItems: 2
```

**Automation (workflow):**
```
OrderPlaced event published
  ↓
InventoryService listens
  ↓
Checks available inventory
  ↓
Publishes ReserveInventory command
  ↓
InventoryReserved event published
```

**Translation (anti-corruption):**
```
Stripe webhook payload:
{
  "event": "charge.succeeded",
  "data": {
    "id": "ch_123",
    "amount": 5000,
    "currency": "usd"
  }
}

↓ Translation layer

Internal event:
PaymentReceived {
  paymentId: "ch_123",
  orderId: "<our-order-id>",
  amount: Money(50.00, USD),
  timestamp: "2026-02-04T10:30:00Z",
  source: "Stripe"
}
```

---

## Facilitation Questions Reference

Use these questions to drive event modeling sessions:

**Domain Discovery:**
- "What does this business do?"
- "Who are the main actors? What are their goals?"
- "What are the major processes?"
- "What external systems do you integrate with?"
- "Which workflow is most critical? Why?"

**User Goal:**
- "What is the user trying to accomplish?"
- "What's the successful outcome?"
- "What would make this fail?"

**Events:**
- "What are the important facts we need to record?"
- "What happened here?" (past tense)
- "Would the business need to know this happened?"

**Timeline:**
- "What happens first?"
- "And then what happens?"
- "What triggers this event?"
- "Can these happen in parallel or must they be sequential?"

**Commands:**
- "Who/what initiates this?"
- "Is this user-triggered or automatic?"
- "What intent does this represent?"

**Read Models:**
- "What does [actor] need to see?"
- "How is this information displayed?"
- "What queries do users run?"

**Automations:**
- "Does anything happen automatically after this event?"
- "What business rules apply here?"
- "Does this trigger other processes?"

**Edge Cases:**
- "What if this fails?"
- "What if the user cancels midway?"
- "What if external system is down?"
- "What's the error handling path?"

---

## Verification Checklist

Use this checklist to verify event modeling quality:

**Domain Discovery:**
- [ ] Business purpose clearly stated
- [ ] All actors and their goals identified
- [ ] Major processes listed
- [ ] External systems noted (names only, no technical details)
- [ ] Workflow priorities established

**Per Workflow:**
- [ ] User goal clearly stated
- [ ] All events brainstormed (sticky-note style)
- [ ] Events ordered chronologically
- [ ] Commands identified for each event
- [ ] Read models designed for each actor
- [ ] Automations discovered
- [ ] External integrations mapped
- [ ] "And then what happens?" asked exhaustively

**Event Quality:**
- [ ] Events in past tense
- [ ] Business language (not technical)
- [ ] Specific (not vague like "DataUpdated")
- [ ] Immutable facts
- [ ] Right granularity (not too broad or narrow)

**Information Completeness:**
- [ ] Every read model field traces to events
- [ ] No missing data in read models
- [ ] Event streams complete (no gaps)

---

## References

**Source Documentation:**
- sdlc plugin: commands/shared/event-modeling.md, docs/event-modeling/methodology.md
- Martin Dilger: "Understanding Eventsourcing"
- EventModeling.org

**Related Skills:**
- domain-modeling - Events reveal domain types
- tdd-constraints - Each slice → one TDD cycle
- github-issues - Workflows → epics, slices → issues

**External Resources:**
- Event Modeling: https://eventmodeling.org/
- Event Storming by Alberto Brandolini
- Domain-Driven Design by Eric Evans

---

## Version History

### v1.0.0 (2026-02-04)
- Initial extraction from sdlc plugin
- Two-phase process (discovery → workflow)
- Seven-step workflow design
- Four event patterns
- Facilitation techniques
- Vertical slicing
- Information completeness checking
- High portability (framework-agnostic methodology)

---

## Metadata

**Extraction Source:** sdlc plugin (event-modeling.md, docs/event-modeling/methodology.md)
**Extraction Date:** 2026-02-04
**Last Updated:** 2026-02-04
**Compatibility:** High portability (universal methodology, any tech stack)
**License:** MIT
