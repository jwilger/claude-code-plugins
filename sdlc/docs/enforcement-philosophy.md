# Enforcement Philosophy

## Graduated Enforcement Tiers

The sdlc plugin uses three enforcement levels:

**HARD enforcement** - Prevents architectural violations, no override
**SOFT enforcement** - Encourages quality, allows explicit override
**EDUCATIONAL enforcement** - Informs and guides, never blocks

## Hard Enforcement (Inviolable Rules)

These rules are absolute and enforce core architectural discipline:

### 1. Domain Review After RED/GREEN (MANDATORY)

**Rule:** After RED or GREEN agent completes, domain agent MUST review

**Why HARD enforcement:**
- Domain agent has best expertise to determine triviality
- Other agents have track record of inappropriate bypass attempts
- Orchestrator should not second-guess domain expertise

**How it works:**
- SubagentStop hook blocks after RED/GREEN
- Domain agent invoked automatically
- Domain agent performs intelligent triage:
  - Trivial: Quick pass (30 seconds)
  - Simple: Standard review (2 minutes)
  - Complex: Deep review (5+ minutes)

**User experience:**
- No override option at hook level
- Domain agent makes triviality determination
- Fast feedback for simple cases

### 2. Agent File Boundaries

**RED agent** - Can only edit test files
**GREEN agent** - Can only edit production code
**DOMAIN agent** - Can only edit type definitions

**Why HARD:** Prevents TDD discipline violations at mechanical level

### 3. Architecture Isolation

**ARCHITECT agent** - Can only edit ARCHITECTURE.md
**ADR commits** - Must be isolated

**Why HARD:** Separates architectural decisions from implementation

## Soft Enforcement (Explicit Override)

These rules encourage quality but allow override:

### Test Verification

**Override syntax:**
```
skip test verification because [reason]
```

**Valid reasons:**
- Tests running in CI pipeline
- Known test infrastructure issues
- Prototyping without test rigor

### Mutation Testing < 100%

**Override:** User proceeds despite warning

**Valid reasons:**
- Surviving mutants in generated code
- Framework internals being tested
- Acceptable risk for this PR

### Code Review Issues

**Override:** User proceeds with documented warnings

**Valid reasons:**
- Minor style issues
- Acceptable technical debt
- Will fix in follow-up PR

## Educational Enforcement (No Block)

These provide guidance without forcing compliance:

- Orchestrator delegation reminders
- Memory system usage suggestions
- Test pattern recommendations
- Performance optimization hints

## Philosophy Rationale

### Why Three Tiers?

**HARD rules** protect architectural integrity:
- Violations would undermine the entire methodology
- Recovery from violations is expensive
- Expertise lives in specialized agents (domain, architect)

**SOFT rules** encourage best practices:
- Violations create technical debt, not catastrophic failure
- User may have valid context for override
- Balance quality with pragmatism

**EDUCATIONAL rules** build habits:
- No immediate harm from violations
- Long-term benefits from following guidance
- Promotes learning without frustration

### Design Principles

1. **Graduated autonomy** - Hard blocks only for catastrophic errors
2. **Progressive disclosure** - Learn the system gradually
3. **Education over punishment** - Understand why rules exist
4. **Context-aware enforcement** - Prototyping needs different rules than production

### Alignment with User Philosophy

**User's requirement:** "Warn and encourage but not refuse unless EXPLICITLY instructed"

**How we implement this:**
- **Domain review:** EXPLICITLY HARD (user philosophy permits this)
- **Agent boundaries:** EXPLICITLY HARD (architectural discipline)
- **Quality checks:** SOFT (warn and encourage, allow override)
- **Delegation:** EDUCATIONAL (inform, don't block)

**Why domain review stays HARD:**
- User's philosophy allows inviolable rules when explicitly stated
- Domain agent has expertise to determine triviality
- Fast path for trivial changes (30 seconds)
- Prevents primitive obsession and state representation bugs

## Troubleshooting

### Q: Domain review takes too long for trivial changes
**A:** Domain agent should auto-triage (v9.1.0+). If not, file bug - agent needs intelligence improvement.

### Q: I need to bypass a HARD rule
**A:** HARD rules prevent architectural violations. Reconsider your approach. If truly necessary, edit files outside the SDLC workflow and accept the risks.

### Q: Emergency requires breaking rules
**A:** Git hooks can be bypassed with `--no-verify`. Document why in commit message. SDLC workflow is designed to prevent emergencies, but pragmatism wins.

### Q: How do I know which tier a rule belongs to?
**A:**
- **HARD:** Hook blocks with no override option, error says "MANDATORY"
- **SOFT:** Hook suggests but allows override, error mentions "skip [action] because [reason]"
- **EDUCATIONAL:** Warning/reminder, no blocking behavior

## Rule Reference

| Rule | Tier | Bypass Method |
|------|------|---------------|
| Domain review after RED/GREEN | HARD | None (domain agent triages complexity) |
| RED agent file boundaries | HARD | None (use different agent) |
| GREEN agent file boundaries | HARD | None (use different agent) |
| DOMAIN agent file boundaries | HARD | None (use different agent) |
| ARCHITECT agent file boundaries | HARD | None (use different agent) |
| Test verification | SOFT | "skip test verification because [reason]" |
| Mutation testing 100% | SOFT | User proceeds with warning |
| Code review warnings | SOFT | User proceeds with acknowledgment |
| Orchestrator delegation | EDUCATIONAL | No bypass needed (not blocked) |
| Memory system usage | EDUCATIONAL | No bypass needed (not blocked) |

## Evolution of This Philosophy

**v9.0.0 and earlier:** Mostly HARD enforcement, limited flexibility

**v9.1.0:** Graduated enforcement model:
- Domain review stays HARD but becomes intelligent (triages complexity)
- Quality checks become SOFT (warn + allow override)
- Orchestrator delegation becomes EDUCATIONAL (inform, don't block)

**Future:** May add user-configurable enforcement levels per project

## Feedback and Adjustment

If you find:
- A HARD rule that should be SOFT
- A SOFT rule that needs to be HARD
- An EDUCATIONAL rule that's too noisy
- Missing bypass mechanism for valid use case

File an issue at the SDLC plugin repository with:
1. Which rule
2. What happened
3. What you expected
4. Why the current tier is wrong

We continuously refine enforcement based on real-world usage.
