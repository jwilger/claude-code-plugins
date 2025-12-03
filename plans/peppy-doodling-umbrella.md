# Plan: Event Sourcing Process from Dilger's Book

## Context
- User wants a fresh start on event modeling methodology based entirely on Martin Dilger's "Understanding Eventsourcing" book
- Previous attempts at event modeling should be superseded as we encounter conflicts
- Process should be encoded in SYSTEM_PROMPT.md, custom sub-agents, slash commands, and hooks
- Text-based event model format needed (not Miro) - using Markdown with Mermaid in `docs/event_model/`
- Format should evolve incrementally as we learn from each chapter
- User can override process via explicit conversation instruction

## Approach: Iterative Chapter-by-Chapter Learning

### Phase 1: Chapter 1 - Foundation (Current)
Chapter 1 establishes mindset, not mechanics:
- Events store facts that happened, in order
- "Not losing information" is the core principle
- Use business language (events named as business facts)
- Time dimension added to systems

**Deliverables for Chapter 1:**
1. Add "Event Sourcing Development Process" section to SYSTEM_PROMPT.md with:
   - Statement that we follow Dilger's methodology
   - Current chapter progress tracker
   - Core principle: "Not losing information"
   - Instruction to use business language for events
   - Override mechanism acknowledgment (user's explicit instruction)

2. Create memory entity superseding old event modeling approaches:
   - "Event Sourcing Process - Dilger Foundation (Chapter 1)"
   - Mark relationship to old memories as "supersedes"

3. Create minimal `/event-model` slash command stub that:
   - Acknowledges we're building this iteratively
   - Points to current chapter progress

### Phase 2: Continue to Chapter 2+
After Chapter 1 implementation, proceed to Chapter 2 ("Event Sourcing - what is it?") which covers:
- Events, Event Store, Projections (building blocks)
- Real mechanics begin here

This pattern continues chapter by chapter.

## Files to Modify
- `/home/jwilger/.claude/SYSTEM_PROMPT.md` - Add Event Sourcing Process section
- `/home/jwilger/.claude/commands/` - Create event-model.md slash command (optional for Phase 1)

## Questions Before Proceeding
None - user's answers were clear. Ready to implement Chapter 1 foundation.
