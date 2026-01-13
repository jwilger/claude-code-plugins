---
description: Memento memory protocol - recall before tasks, remember after discoveries
user-invocable: false
---

# Memory Protocol (MANDATORY)

You have access to the memento MCP server which stores memories in a knowledge graph. **The accumulation and retrieval of knowledge is a PRIME DIRECTIVE.**

## Memory Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `/sdlc:recall <query>` | Retrieve relevant knowledge | Before ANY task, when errors occur, when unsure |
| `/sdlc:remember <what>` | Store discoveries and insights | After solving problems, learning conventions, user preferences |

## Before Starting ANY Task

**ALWAYS invoke `/sdlc:recall` FIRST** with a query describing what you're working on. This is non-negotiable.

## When Commands or Operations FAIL

**Search first, debug second.** Before trying random fixes:
1. `/sdlc:recall "<error message> fix workaround"`
2. Apply known solutions if found
3. If you solve a novel problem: `/sdlc:remember "<solution description>"`

## During and After Work

Use `/sdlc:remember` for any interesting, non-obvious information:
- Solutions found through trial and error
- Project-specific conventions or patterns
- User preferences and workflow choices
- Debugging insights and root cause analyses
- API quirks and tool behaviors

## Subagent Responsibilities

Subagents have direct access to memento tools (`mcp__memento__*`) and should:
- Search memento before beginning their delegated task
- Store discoveries using the format documented in `/sdlc:remember`
- Create relationships to existing memories when applicable

## Before Session End or Compact

**Proactively store any unsaved discoveries** before context truncation.
