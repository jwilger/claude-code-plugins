# Agent Teams Spike: Parallel Code Review

**Date:** 2026-02-05
**Status:** Go (with caveats)
**Feature:** Experimental parallel code review using Claude Code agent teams

## Research Questions

### 1. Can agent teams be spawned from within a plugin command?

**Finding:** Agent teams are spawned via natural language instruction to the lead session (the main Claude Code instance). They cannot be programmatically spawned from a shell script or hook -- the lead session must decide to create a team based on the user's request or its own assessment.

**Implication for SDLC plugin:** The review command can instruct the orchestrator to create an agent team when the `SDLC_EXPERIMENTAL_PARALLEL_REVIEW=1` environment variable is set. The command text describes the team structure; the orchestrator (as lead) spawns the teammates.

### 2. How do teammates share findings?

**Finding:** Teammates communicate via a mailbox system. Messages are delivered automatically to recipients. The lead can also broadcast to all teammates. All agents see a shared task list with status tracking.

**Implication:** Each review stage (spec compliance, code quality, domain integrity) can report findings back to the lead via messaging. The lead synthesizes the three reports into a unified review.

### 3. What happens when a teammate fails?

**Finding:** Teammates may stop after encountering errors. The lead can spawn replacement teammates. There is no automatic retry mechanism. Task status can lag -- teammates sometimes fail to mark tasks as completed.

**Implication:** The review command should include fallback instructions: if a teammate fails or times out, the lead should fall back to sequential review for that stage. The overall review should not fail if one teammate has issues.

### 4. How does task coordination work?

**Finding:** Shared task list with three states (pending, in-progress, completed). Tasks support dependencies. File locking prevents race conditions during task claiming. The lead creates tasks and teammates self-claim or are assigned.

**Implication:** The three review stages are independent (no dependencies between them), making them ideal for parallel execution. Each teammate reviews the same PR from a different perspective.

## Compatibility Assessment

| Aspect | Status | Notes |
|--------|--------|-------|
| Plugin command integration | Compatible | Command text instructs orchestrator to create team |
| Teammate context | Compatible | Teammates load CLAUDE.md, skills, MCP servers automatically |
| File conflicts | Not a risk | All three reviewers are read-only (no file edits during review) |
| TDD cycle impact | No impact | Agent teams are scoped to review only; TDD cycle uses subagents |
| Token cost | Higher | 3x token usage vs sequential (each teammate is a separate instance) |
| Stability | Experimental | Known limitations around session resumption and task status lag |

## Go/No-Go Recommendation

**Recommendation: GO** -- with the following caveats:

1. **Gate behind environment variable** (`SDLC_EXPERIMENTAL_PARALLEL_REVIEW=1`) so it is opt-in only
2. **Default behavior must remain sequential** -- unchanged from current review workflow
3. **Include fallback to sequential** if agent teams are not available or a teammate fails
4. **Scope exclusively to code review** -- never use agent teams for TDD cycle
5. **Document the token cost tradeoff** -- parallel review uses significantly more tokens

## Rationale

Code review is the strongest use case for agent teams because:
- All three review stages are independent and read-only
- No file conflicts possible (reviewers do not edit code)
- Each reviewer applies a different lens (spec, quality, domain) -- exactly the pattern recommended in the docs
- Review is the most time-consuming single operation in the SDLC workflow
- The official docs specifically list "run a parallel code review" as a primary use case example

## Implementation Notes

- The review command should check for the environment variable first
- If enabled, instruct the orchestrator to spawn 3 teammates with distinct review focuses
- Each teammate reports findings in the standard stage output format
- The lead synthesizes into the unified CODE REVIEW SUMMARY format
- If agent teams feature is not available (older Claude Code), fall back gracefully to sequential
- The TDD cycle (RED/DOMAIN/GREEN/DOMAIN) remains strictly sequential via subagents -- completely unaffected

## Limitations Acknowledged

- Agent teams are experimental and may have stability issues
- No session resumption for in-process teammates
- Task status can lag
- Higher token cost (approximately 3x for the review phase)
- Cannot nest teams -- if the review is already running in a team context, fall back to sequential
