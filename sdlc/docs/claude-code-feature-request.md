# Claude Code Feature Request: `is_subagent` Field in Hook Inputs

**Status:** Pending submission to Claude Code team

**Priority:** Medium

**Category:** Hook API Enhancement

---

## Summary

Add an `is_subagent: boolean` field to hook input JSON, allowing hooks to distinguish between orchestrator context and subagent context.

---

## Motivation

### Current Limitation

Claude Code currently provides identical `transcript_path` values to hooks regardless of whether they're executing in the main orchestrator context or within a subagent (launched via Task tool). This makes it impossible for hooks to enforce architectural patterns that require orchestrator/specialist separation.

### Use Case: SDLC Plugin

The SDLC plugin implements an orchestration pattern where:
- **Orchestrator** coordinates workflow and delegates to specialists
- **Specialist agents** (RED, GREEN, DOMAIN) have deep focus on specific file types

**Desired enforcement:**
- Orchestrator should delegate to specialists (EDUCATIONAL enforcement)
- Detection requires knowing if we're in orchestrator vs subagent context

**Current workaround:**
- PostToolUse heuristic: Search transcript for Task tool usage
- Unreliable: False positives when orchestrator reads transcripts
- Cannot use PreToolUse (blocks before action, no Task tool evidence yet)

### Why This Matters

Enabling context-aware enforcement supports:
1. **Separation of concerns** - Orchestrator coordinates, specialists implement
2. **Cognitive load management** - Specialists start fresh with explicit context
3. **Quality assurance** - File-type-specific validation by specialists
4. **Architectural discipline** - Mechanical enforcement of design patterns

---

## Proposed Solution

### Hook Input Enhancement

Add `is_subagent` field to hook inputs:

```json
{
  "tool": "Edit",
  "file_path": "/path/to/file.rs",
  "transcript_path": "/path/to/transcript.jsonl",
  "is_subagent": false,  // NEW: true if executing in subagent context
  // ... other fields
}
```

### Field Semantics

- `is_subagent: false` - Hook executing in main orchestrator context
- `is_subagent: true` - Hook executing within subagent launched by Task tool
- Field present in all hook types (PreToolUse, PostToolUse, Stop, SubagentStop, etc.)

### Implementation Notes

Claude Code already tracks subagent context internally (for transcript management, tool availability, etc.). This feature simply exposes existing state to hooks.

---

## Example Usage

### PreToolUse Hook (Proactive Enforcement)

```bash
#!/usr/bin/env bash
# orchestrator-delegation-check.sh - PreToolUse for Edit/Write

INPUT=$(cat)
IS_SUBAGENT=$(echo "$INPUT" | jq -r '.is_subagent // false')

if [ "$IS_SUBAGENT" = "false" ]; then
  # Orchestrator editing directly - warn (EDUCATIONAL)
  echo '{
    "ok": true,
    "additionalContext": "⚠️ Consider delegating to specialist agents for better separation of concerns."
  }'
else
  # Subagent editing - allow silently
  echo '{"ok": true}'
fi
```

### PostToolUse Hook (Current Workaround)

```bash
#!/usr/bin/env bash
# Current heuristic approach (unreliable)

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
RECENT_CONTEXT=$(tail -n 50 "$TRANSCRIPT_PATH")

# Heuristic: Look for Task tool usage (false positives possible)
if echo "$RECENT_CONTEXT" | grep -q '"name":\s*"Task"'; then
  # Probably orchestrator...
fi
```

With `is_subagent`, this becomes deterministic and reliable.

---

## Benefits

### For Plugin Developers

1. **Deterministic context detection** - No heuristics needed
2. **PreToolUse enforcement possible** - Block before action (proactive)
3. **Clearer architectural boundaries** - Mechanical enforcement of patterns
4. **Better error messages** - Context-aware guidance

### For Claude Code Users

1. **Better plugin quality** - Architectural patterns enforceable
2. **Educational feedback** - Learn best practices through hooks
3. **Consistency** - Plugins can enforce conventions reliably

### For Claude Code Platform

1. **Minimal implementation** - Expose existing internal state
2. **No breaking changes** - Additive field (backward compatible)
3. **Enables architectural innovation** - New plugin patterns possible
4. **No security implications** - Transparency, not access control

---

## Alternative Approaches Considered

### 1. Separate Transcript Paths

**Idea:** Use different `transcript_path` values for orchestrator vs subagent

**Rejected because:**
- Breaks existing assumptions about transcript structure
- Higher implementation complexity
- More invasive change to core architecture

### 2. Hook-Specific Context Fields

**Idea:** Add context to specific hook types only

**Rejected because:**
- Inconsistent API surface
- Plugin developers need to handle multiple patterns
- Harder to document and reason about

### 3. Do Nothing (Status Quo)

**Rejected because:**
- Architectural patterns remain unenforceable
- Plugins forced to use unreliable heuristics
- Limits ecosystem innovation

---

## Migration Path

### Backward Compatibility

- Field is additive (no breaking changes)
- Existing hooks without `is_subagent` checks work unchanged
- Plugins can adopt incrementally

### Adoption Timeline

1. **v1 (Immediate):** Add field, document in hook API
2. **v2 (Plugins adopt):** Plugins update to use `is_subagent`
3. **v3 (Maturity):** Best practices emerge, documented in plugin guide

---

## Open Questions

### Q1: Should this apply to all hook types?

**Answer:** Yes. All hook types benefit from context awareness:
- PreToolUse: Proactive enforcement
- PostToolUse: Reactive guidance
- Stop: Context-aware cleanup
- SubagentStop: Orchestrator vs subagent different handling

### Q2: What about nested subagents?

**Answer:** Start simple with boolean. If nested subagents become common, can extend to:
```json
{
  "subagent_depth": 0,  // 0 = orchestrator, 1 = first subagent, 2 = nested, etc.
  "is_subagent": true    // Backward compatible
}
```

### Q3: Performance impact?

**Answer:** Negligible. Field is already tracked internally, just needs serialization.

---

## References

### SDLC Plugin Implementation

- **Current workaround:** `sdlc/.claude-plugin/hooks/orchestrator-edit-detection.sh`
- **Enforcement philosophy:** `sdlc/docs/enforcement-philosophy.md`
- **Use case:** Educational enforcement of orchestrator delegation pattern

### Similar Features in Other Tools

- **LSP (Language Server Protocol):** Context fields distinguish client/server
- **GitHub Actions:** `github.event_name` distinguishes workflow contexts
- **Kubernetes Admission Controllers:** Distinguish resource types and operations

---

## Success Metrics

### Plugin Ecosystem

- 5+ plugins adopt `is_subagent` within 6 months
- Architectural pattern plugins emerge (orchestration, separation of concerns)

### User Feedback

- Reduction in "how do I enforce X" support questions
- Positive feedback on educational enforcement UX

### Technical

- Zero backward compatibility issues reported
- Hook API documentation clarity score improvement

---

## Submission Details

**Target:** Claude Code GitHub repository / feedback channel

**Submitter:** SDLC plugin maintainer (jwilger)

**Contact:** john@johnwilger.com

**Related PRs:** (None yet - awaiting feedback)

---

## Appendix: Full Hook Input Schema (Proposed)

```typescript
interface HookInput {
  // Tool being used
  tool: string;

  // Tool-specific parameters
  file_path?: string;
  command?: string;
  // ... other tool params

  // Context
  transcript_path: string;
  is_subagent: boolean;  // NEW

  // Metadata
  timestamp?: number;
  session_id?: string;
}
```

---

**Last Updated:** 2026-02-05

**Status:** Ready for submission
