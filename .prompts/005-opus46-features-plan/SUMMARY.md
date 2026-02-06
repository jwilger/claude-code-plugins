# Opus 4.6 Features Implementation Plan Summary

**Five-phase improvement plan prioritized by impact-to-effort ratio: persistent agent memory and model routing first, then TDD state preservation hooks, content-based file enforcement, dynamic skill context, and experimental parallel review -- all preserving the inviolable RED->DOMAIN->GREEN->DOMAIN cycle.**

## Version
v1

## Key Findings
- **Phase 1 (Agent Memory + Model Routing):** Add `memory: project` to domain/code-reviewer/architect agents and optimize model routing (opus for reasoning agents, sonnet for file-updater). Frontmatter-only changes, zero workflow risk. 4 tasks.
- **Phase 2 (TDD State Preservation Hooks):** Add PreCompact hook to preserve TDD cycle state through compaction and SubagentStart hook for TDD agent context injection. Addresses the two most painful workflow failure modes. 3 tasks.
- **Phase 3 (Agent Hook File Enforcement):** Upgrade red/green/domain/file-updater/architect PreToolUse hooks from `type: prompt` to `type: agent` for content-based verification instead of path-pattern checks. 5 tasks.
- **Phase 4 (Dynamic Skill Context):** Add `!`command`` injection to task-management, tdd-constraints, and memory-protocol skills for runtime project state awareness. 3 tasks.
- **Phase 5 (Experimental Parallel Review):** Spike agent teams for parallel code review (gated behind env var), plus LSP plugin recommendation in setup. 3 tasks.
- **Total: 18 tasks across 5 phases**, each phase independently testable and revertible.

## Decisions Needed
1. **Approve model routing strategy:** Domain/code-reviewer/architect -> opus, file-updater -> sonnet, all others -> inherit. Or should more agents use sonnet?
2. **Confirm Phase 5 priority:** Agent teams are experimental. Should Phase 5 be deferred entirely, or proceed with just the spike task?
3. **Version strategy:** Ship phases individually (v17.0.0 through v18.0.0) or batch into a single v17.0.0 release?

## Blockers
- Open question: Whether agent hooks (type: "agent") work inside plugin agent frontmatter hooks (Phase 3 dependency). Can be resolved by testing on a single agent first.
- Open question: Whether persistent memory works with plugin-defined agents (Phase 1 dependency). Graceful degradation if it doesn't work.

## Next Step
Execute Phase 1 tasks using .prompts/006-opus46-features-implement/

---
*Confidence: High*
*Iterations: 1*
*Full output: opus46-features-plan.md*
