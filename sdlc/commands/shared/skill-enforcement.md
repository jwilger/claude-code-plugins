---
description: INVOKE before ANY task. 1% rule - if skill might apply, invoke it. Rationalization prevention.
user-invocable: false
---

# Skill Invocation Enforcement (MANDATORY)

Skills and protocols exist for a reason. Invoke them proactively, not reactively.

## The 1% Rule

**If there is even a 1% chance a skill applies to your current task, you MUST invoke it.**

This is not a suggestion. This is how you prevent errors that seem obvious in hindsight.

### Mandatory Invocations

| Before... | ALWAYS invoke... | Even if... |
|-----------|-----------------|------------|
| ANY task | `/sdlc:recall` | "It's a simple change" |
| Writing ANY test | `sdlc:red` agent | "Just one small test" |
| Writing ANY production code | `sdlc:green` agent | "It's a one-liner" |
| Creating ANY type | `sdlc:domain` agent | "It's just a struct" |
| Solving ANY error | `/sdlc:recall` | "I know what the problem is" |
| Finishing ANY task | `/sdlc:remember` | "It wasn't interesting" |
| After RED phase | `sdlc:domain` agent | "It's obviously not a domain concern" |
| After GREEN phase | `sdlc:domain` agent | "It's just a rendering/UI fix" |

## Rationalization Red Flags

Watch for these thoughts - they are ALWAYS wrong:

| If you're thinking... | The truth is... | Correct action |
|-----------------------|-----------------|----------------|
| "This is just a simple question" | Simple questions often have complex answers in memento | `/sdlc:recall` first |
| "I already know what this skill says" | Memory is fallible. Skills have nuances | Invoke the skill anyway |
| "It's overkill for this task" | "Overkill" is how you avoid bugs | Follow the process |
| "Let me just do this one thing first" | This is how shortcuts start | STOP. Invoke the skill |
| "I'll check memento after" | "After" means "never" | Search BEFORE you act |
| "The skill doesn't perfectly apply" | 1% relevance = 100% invocation | Invoke it anyway |
| "It will slow me down" | Bugs slow you down more | Take the time |
| "The user seems in a hurry" | Hurried work = buggy work | Follow the process |
| "This is obviously not a domain concern" | That's exactly when domain issues sneak in | Invoke `sdlc:domain` |
| "It's just a rendering/UI fix" | UI can leak domain concepts | Invoke `sdlc:domain` |
| "Domain would just rubber-stamp it" | The ritual matters as much as the outcome | Invoke `sdlc:domain` |
| "We're in bug-fix mode, not TDD mode" | Bug fixes need TDD MORE, not less | Full cycle required |

## Skill Priority Order

When multiple skills might apply, process them in this order:

1. **Memory first**: `/sdlc:recall` before anything else
2. **Process skills**: TDD workflow, debugging protocol
3. **Implementation skills**: Agent delegation (red/green/domain)
4. **Documentation skills**: ADRs, GWT scenarios

## The Non-Negotiables

These are NEVER optional:

1. **Memory recall before tasks** - Always search memento first
2. **TDD agent delegation** - Never write code directly in orchestrator
3. **Domain modeler review** - Always get domain sign-off
4. **Verification before completion** - Always run tests and paste output
5. **Memory storage after discoveries** - Always store what you learned

## Self-Check Questions

Before proceeding with any action, ask:

- [ ] Did I search memento for relevant context?
- [ ] Am I delegating to the right agent?
- [ ] Is there a skill that might help here?
- [ ] Am I about to rationalize skipping a step?
- [ ] Would I regret not following the process if this fails?

If you answered "no" or "maybe" to any of these, STOP and invoke the appropriate skill.
