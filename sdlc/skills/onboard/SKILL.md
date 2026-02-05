---
name: onboard
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: 5-minute interactive TDD tutorial with live demo project. Auto-invokes on first setup.
tags:
  - onboarding
  - tutorial
  - tdd
  - learning
portability: high
dependencies: []
allowed-tools: Bash, Write, Read, AskUserQuestion, Edit
---

# Interactive Onboarding

**Version:** 1.0.0
**Duration:** 5 minutes

Welcome to the SDLC plugin! This interactive tutorial walks you through a complete TDD cycle.

## Tutorial Flow

### Step 1: Introduction (30 seconds)

You'll learn:
- RED phase: Write failing tests
- GREEN phase: Implement minimal code
- DOMAIN phase: Review types and domain modeling
- How hooks enforce discipline

### Step 2: Demo Project Setup (30 seconds)

We'll create a simple calculator with TDD:
- Add two numbers
- One test, one implementation
- See the full cycle

### Step 3: RED Phase Demo (1 minute)

Watch as we:
1. Write a failing test
2. Run it (see it fail)
3. Hook enforces test-first discipline

### Step 4: GREEN Phase Demo (1 minute)

Implement minimal code to:
1. Make the test pass
2. No gold-plating
3. Just enough to go green

### Step 5: DOMAIN Phase Demo (1 minute)

Review types:
1. Check for primitive obsession
2. Consider domain types
3. Approve or suggest improvements

### Step 6: Complete Cycle (1 minute)

See how:
1. All phases work together
2. Hooks enforce boundaries
3. You can create a PR

### Step 7: Next Steps (30 seconds)

Choose:
1. Continue with demo (add more features)
2. Start your real project
3. Review documentation

## Progress Tracking

Your progress is saved in `.claude/sdlc.yaml`:
```yaml
onboarding:
  completed: true
  date: 2026-02-05
  demo_project: calculator
```

## Demo Project: Calculator

Simple but complete TDD example:

**Feature:** Add two numbers

**Test (RED):**
```rust
#[test]
fn adds_two_numbers() {
    let calc = Calculator::new();
    assert_eq!(calc.add(2, 3), 5);
}
```

**Implementation (GREEN):**
```rust
struct Calculator;

impl Calculator {
    fn new() -> Self { Self }
    fn add(&self, a: i32, b: i32) -> i32 {
        a + b
    }
}
```

**Domain Review:**
- ✓ No primitive obsession (simple domain)
- ✓ Pure function (no side effects)
- ✓ Type safety maintained

## Skip Tutorial

If you're experienced with TDD:
```yaml
# In .claude/sdlc.yaml
onboarding:
  skip: true
```

## Full Documentation

After tutorial, explore:
- TDD workflow: `/sdlc:work`
- Event Modeling: `/sdlc:design`
- Architecture: `/sdlc:arch`
