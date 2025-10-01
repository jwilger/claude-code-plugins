# Event Modeling Process

**CRITICAL: Understanding Event Modeling for Client vs Service Applications**

Event Modeling focuses on **persistent state changes**, NOT ephemeral runtime behavior.

## Events = Persistent State Changes

- Events are state changes recorded indefinitely (databases, event stores, files, audit logs)
- Events MUST survive application restart
- Events represent persistent facts about what happened in the system

## What Counts as an Event

- ✅ **Configuration changes** persisted to files
- ✅ **Data written** to databases or event stores
- ✅ **Audit trail entries** for compliance/history
- ✅ **State that survives restart** or requires reconstruction
- ❌ **UI rendering** ("Displayed", "Rendered", "Focused") - ephemeral
- ❌ **Transient interactions** ("Clicked", "Pressed", "Selected") - ephemeral
- ❌ **Runtime-only state** (in-memory data structures, UI state)

## Logging vs Event Storage (CRITICAL DISTINCTION)

- **Application Logging** (DEBUG, INFO, WARN, ERROR, FATAL): Meets debugging and audit needs
- **Do NOT create separate persistent event stores** for debugging or audit trails
- **ONLY create persistent events** for actual domain state changes that require reconstruction
- **Events are for state reconstruction**, NOT debugging history

## Client Applications vs Service Applications

- **Services** typically have MANY events (every business state change persisted)
- **Client applications** typically have FEWER events (most state is ephemeral UI)
- Client applications may have very few actual events if they don't persist much state
- Most client workflows are: Command → Ephemeral State → UI Rendering (NOT Command → Event → Read Model)

## Event Modeling Process

1. **Identify persistent state changes FIRST** - what survives restart?
2. **Distinguish events from UI state** - does this need to be persisted?
3. **Accept minimal events for clients** - client apps may have 5-10 events, not 50+
4. **Focus on workflows that matter** - not every user action creates an event
5. **Most client state is ephemeral** - rendering, focus, selection are NOT events
6. **Debugging/audit = logging** - use application logs, NOT event stores

## Vertical Slice Format (MANDATORY)

Each vertical slice MUST follow this LINEAR, UNIDIRECTIONAL format:
```
(UI or external-service) → Command → Event → Projection → Query → (UI or external-service)
```

## Vertical Slice Rules

1. **Linear Flow**: Each slice flows in ONE direction only (no forking within a single slice)
2. **Separate Slices**: If one event updates multiple projections, create SEPARATE vertical slices
3. **Shared Entities**: Multiple slices can reference shared entity description blocks
4. **Complete Journey**: Show full flow from user/system trigger to displayed/returned result
5. **UI Context**: Include layout context (panes, panels, sections) in wireframes

## UI Wireframes (MANDATORY for ux-ui-design-expert)

The ux-ui-design-expert MUST create ASCII wireframes for workflows involving UI interaction:

### 1. Input Wireframe

Show what user interacts with:
- Form fields, text inputs, buttons
- Layout context (which pane/panel)
- User action trigger (e.g., "Press Enter to Send")

### 2. Output Wireframe

Show what user sees as result:
- Displayed data, updated views
- Layout context (which pane/panel)
- Visual representation of outcome

### 3. Vertical Slice Flow

Show complete command → event → projection → query flow:
- Connect input wireframe to command
- Show event (if persistent state change)
- Show projection and query
- Connect to output wireframe

## Complete Example Vertical Slice with Wireframes

### Vertical Slice: Send Chat Message

```
[UI Wireframe: Input]
┌─────────────────────────────────────────┐
│ Chat Input Pane                         │
│ ┌─────────────────────────────────────┐ │
│ │ What is the capital of France?      │ │
│ └─────────────────────────────────────┘ │
│ [Press Enter to Send]                   │
└─────────────────────────────────────────┘

↓ Command: SendMessage
↓ Event: (none - backend manages state)
↓ Projection: Conversation History (from backend DynamoDB)
↓ Query: GetConversationHistory

[UI Wireframe: Output]
┌─────────────────────────────────────────┐
│ Message History Pane                    │
│ ┌─────────────────────────────────────┐ │
│ │ You: What is the capital of France? │ │
│ │ Assistant: Paris [Citation]         │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Interface Wireframes

- ux-ui-design-expert MUST add interface wireframes to EVENT_MODEL.md
- Format: UI/external-system → command → event → projection → query → UI/external-system
- Each vertical slice is SEPARATE (no forking within a slice)
- If one event updates multiple projections, show as SEPARATE vertical slices referencing shared entity descriptions
- Wireframes show user journey through system, not implementation details

## Example for Chat Client

- ✅ Event: "ConnectionConfigurationSaved" (persisted to config file)
- ✅ Event: "MessageHistoryPersisted" (written to local database)
- ❌ NOT Event: "ChatWindowRendered" (ephemeral UI state)
- ❌ NOT Event: "MessageInputFocused" (ephemeral UI state)
- ❌ NOT Event: "SendButtonClicked" (ephemeral interaction)
- ❌ NOT Event: "DebugMessageLogged" (use application logging instead)

## Key Principle

If it doesn't need to survive a restart or isn't written to persistent storage, it's NOT an event in Event Modeling terms. Debugging and audit are handled through standard application logging.
