# Visual Workflow Guides

## Complete Workflow Diagram

The `complete-workflow.md` file contains a Mermaid diagram showing the complete SDLC workflow.

The diagram renders automatically in:
- GitHub/GitLab markdown viewers
- Most modern markdown editors
- VS Code (with Mermaid extension)
- Claude Code interface

### Workflow Overview

The diagram shows:

**Entry Points:**
- `/sdlc:start` - Smart workflow detection and routing
- `/sdlc:setup` - First-time project configuration

**Planning Phase:**
- `/sdlc:specify` - Event Modeling facilitation
- `/sdlc:arch` - Architecture decision documentation
- `/sdlc:plan` - Convert event model to GitHub issues

**Implementation Phase:**
- `/sdlc:work` - Start work on a task
- TDD Cycle - RED → DOMAIN → GREEN → DOMAIN (repeating)

**Review Phase:**
- `/sdlc:pr` - Create pull request with code review
- `/sdlc:review` - Address PR feedback
- `/sdlc:complete` - Mark task complete after merge

**Knowledge Management:**
- `/sdlc:recall` - Search memory for patterns (dashed lines)
- `/sdlc:remember` - Store learned patterns (dashed lines)

### Using the Diagram

This diagram helps answer:
- "What skill do I use next?"
- "How does the workflow connect?"
- "When should I use memory commands?"

For interactive decision-making, see:
- [Workflow Selection Decision Tree](../decision-trees/workflow-selection.md)
- [TDD Troubleshooting](../decision-trees/tdd-troubleshooting.md)
