# Opus 4.6 & Claude Code Features Research Summary

**Agent hooks, persistent subagent memory, and SubagentStart context injection can strengthen the SDLC plugin's TDD enforcement and domain review quality without any changes to the core RED/DOMAIN/GREEN/DOMAIN workflow.**

## Version
v1

## Key Findings
- **Agent hooks (type: "agent")** can replace prompt-based file-type enforcement on red/green/domain agents with content-aware verification that actually reads files, making TDD cycle enforcement dramatically more reliable
- **Persistent subagent memory** (memory: project) lets the domain agent accumulate project-specific type conventions and domain decisions across sessions, making it increasingly effective as domain guardian
- **SubagentStart hook** can inject TDD cycle state (current phase, dot CLI tasks, ARCHITECTURE.md presence) into agents at spawn time, providing a hook-enforced context baseline that the orchestrator cannot forget
- **PreCompact hook** can preserve TDD cycle state through auto-compaction, preventing the orchestrator from losing track of which phase it's in after context is compressed

## Decisions Needed
1. Should agent hooks replace prompt hooks for file-type enforcement? (increases timeout from 30s to 60s per check, but dramatically improves precision)
2. Which agents should get persistent memory? (domain is the clear first candidate; code-reviewer and architect are also good candidates)
3. Should model routing be implemented? (file-updater to sonnet, domain/architect/code-reviewer to opus explicitly)
4. Should agent teams for parallel code review be explored? (experimental feature, requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)

## Blockers
- The file-edit-auth.sh hook (blocking orchestrator from editing files directly) remains unresolvable with current hook inputs -- PreToolUse still lacks an is_subagent field. Agent hooks may provide a workaround but this needs testing.

## Next Step
Create planning prompt using these findings (.prompts/005-opus46-features-plan/)

---
*Confidence: High*
*Iterations: 1*
*Full output: opus46-features-research.md*
