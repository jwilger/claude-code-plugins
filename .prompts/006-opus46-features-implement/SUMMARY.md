# Opus 4.6 Features Implementation Summary

**Implemented 5 phases of SDLC plugin improvements leveraging Opus 4.6 and Claude Code 2.1 capabilities, shipping as v17.0.0.**

## Version
v1

## Key Findings
- **Phase 1 (Agent Memory):** Added `memory: project` to domain, code-reviewer, and architect agents with body text guidance on using persistent memory for cumulative knowledge. Model routing was skipped per user decision.
- **Phase 2 (TDD State Preservation):** Created PreCompact hook that preserves TDD cycle state and dot CLI task info through context compaction. Created SubagentStart hook that injects dynamic context (active tasks, ARCHITECTURE.md existence, TDD phase position) into red/green/domain agents at spawn time. Updated setup.md pre-compact template.
- **Phase 3 (Agent Hook File Enforcement):** Upgraded PreToolUse hooks on all 5 enforcement agents (red, green, domain, file-updater, architect) from `type: prompt` to `type: agent` for content-based file verification. Agent hooks can now read files and inspect content to verify file types, rather than relying on path patterns alone. PostToolUse and Stop hooks remain `type: prompt` (unchanged).
- **Phase 4 (Dynamic Skill Context):** Added `!`command`` blocks to 3 skills: task-management (injects current active tasks from dot CLI), tdd-constraints (detects project language and test runner), and memory-protocol (shows memory directory status). All static skill content preserved.
- **Phase 5 (Experimental Parallel Review):** Completed spike research documenting agent teams feasibility (Go recommendation). Added experimental parallel review mode to PR command's Step 3, gated behind `SDLC_EXPERIMENTAL_PARALLEL_REVIEW=1` environment variable. Default behavior is unchanged (sequential review). Added LSP plugin recommendation to setup.md Step 13.
- **Version bumped to v17.0.0** across all 3 files (plugin.json, marketplace.json, setup.md with 16 version references updated).

## Files Created/Modified
- `.claude-plugin/marketplace.json` - Version bump 16.0.0 -> 17.0.0
- `sdlc/.claude-plugin/plugin.json` - Version bump 16.0.0 -> 17.0.0
- `sdlc/.claude-plugin/hooks.json` - Added PreCompact and SubagentStart hook entries
- `sdlc/.claude-plugin/hooks/pre-compact.sh` - NEW: TDD state preservation through compaction
- `sdlc/.claude-plugin/hooks/subagent-start-context.sh` - NEW: Dynamic context injection for TDD agents
- `sdlc/agents/domain.md` - Added `memory: project`, persistent memory section, upgraded PreToolUse to agent hooks
- `sdlc/agents/code-reviewer.md` - Added `memory: project`, persistent memory section
- `sdlc/agents/architect.md` - Added `memory: project`, persistent memory section, upgraded PreToolUse to agent hooks
- `sdlc/agents/red.md` - Upgraded PreToolUse hooks from prompt to agent type
- `sdlc/agents/green.md` - Upgraded PreToolUse hooks from prompt to agent type
- `sdlc/agents/file-updater.md` - Upgraded PreToolUse hooks from prompt to agent type
- `sdlc/commands/setup.md` - Updated pre-compact template, added LSP recommendation (Step 13), version bump
- `sdlc/commands/pr.md` - Added experimental parallel review option (gated behind env var)
- `sdlc/skills/task-management/SKILL.md` - Added dynamic context injection for active tasks
- `sdlc/skills/tdd-constraints/SKILL.md` - Added dynamic context injection for detected test runner
- `sdlc/skills/memory-protocol/SKILL.md` - Added dynamic context injection for memory directory status
- `sdlc/docs/agent-teams-spike.md` - NEW: Agent teams spike research documentation

## Decisions Needed
None

## Blockers
None

## Next Step
Review changes, test, and commit.

---
*Confidence: High*
*Iterations: 1*
