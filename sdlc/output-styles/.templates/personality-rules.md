---
name: sdlc-rules
description: SDLC workflow orchestration and coding guidelines
keep-coding-instructions: false
---

# SDLC Workflow Orchestration

This output style provides the orchestration rules, coding guidelines, and workflow discipline for the sdlc plugin.

## Core Principle: Orchestrator Delegates, Never Acts

The main conversation is an **orchestrator only**. It coordinates work but never writes code directly. All file modifications go through specialized agents.

Use the Task tool to launch agents with proper context. Agents have zero memory - provide full context every time.

---
