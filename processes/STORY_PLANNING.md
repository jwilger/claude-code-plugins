# Story Planning Process

**Phase 6: Story Planning**

**Agents**: story-planner ↔ story-architect ↔ ux-consultant
**Process**: Collaborative creation until consensus
**Output**: Beads issues with prioritized user stories. docs/PLANNING.md contains SDLC process guidance only.
**Gate**: All three agents agree beads issues are complete, well-defined, and properly prioritized

**CRITICAL WORKFLOW NOTE**: User stories are DERIVED from EVENT_MODEL.md (Phase 2), NOT from REQUIREMENTS_ANALYSIS.md (Phase 1). Requirements define WHAT/WHY at a high level. Event modeling defines HOW the system responds to events. Stories decompose event model vertical slices into implementable increments. This is why stories come in Phase 6, AFTER event modeling, architecture decisions, and design system definition.

## Story Requirements

1. **Thin Vertical Slices**: Each story provides user-observable value
   - Stories must deliver functionality that users can directly experience and interact with
   - No "technical foundation" stories that don't enable user actions
   - Each story should be the smallest possible increment that provides real value

2. **Event Model Alignment**: Stories align with vertical slices in EVENT_MODEL.md
   - Reference specific vertical slices from the Event Model
   - Ensure story scope matches the event-driven architecture
   - Maintain traceability between requirements and implementation architecture

3. **Gherkin Acceptance Criteria**: BDD-style Given/When/Then focused on user experience
   - Use Behavior-Driven Development format for all acceptance criteria
   - Focus on observable user outcomes, not implementation details
   - Criteria should be testable and unambiguous

4. **Documentation References**: Reference relevant sections from requirements, ADRs, architecture, style guide
   - Link to specific sections in REQUIREMENTS_ANALYSIS.md
   - Reference applicable ADRs from docs/adr/ directory
   - Point to relevant architecture patterns in ARCHITECTURE.md
   - Reference design patterns from STYLE_GUIDE.md

5. **Cohesive Completeness**: Smallest possible change enabling user to perform function without crashes or incomplete-implementation errors
   - Story must be fully functional when complete
   - No partial implementations that require future stories to work
   - Users should never encounter "not yet implemented" messages
   - All error paths must be handled appropriately

6. **Integration Requirements**: Every story MUST specify how users access the feature
   - **Integration Point**: Where feature connects to user interface (main.rs, HTTP route, GUI element, public API)
   - **User Access Method**: How users invoke the feature (CLI command, HTTP request, button click, library import)
   - **Manual Testing**: Step-by-step instructions for humans to verify feature works
   - Stories without clear integration points are INCOMPLETE
   - "Works in tests" is NECESSARY but NOT SUFFICIENT for story completion
   - See INTEGRATION_VALIDATION.md for complete protocol

## Story Tracking with Beads

**IMPORTANT**: Stories are tracked as beads issues, NOT in docs/PLANNING.md. The PLANNING.md document contains SDLC process guidance only.

### Beads Commands for Story Management

- **Create story**: `/beads:create` or `mcp__plugin_beads_beads__create`
- **Update story**: `/beads:update <issue-id>` or `mcp__plugin_beads_beads__update`
- **List stories**: `/beads:list` or `mcp__plugin_beads_beads__list`
- **Show details**: `/beads:show <issue-id>` or `mcp__plugin_beads_beads__show`
- **Find ready work**: `/beads:ready` or `mcp__plugin_beads_beads__ready`
- **Check blockers**: `/beads:blocked` or `mcp__plugin_beads_beads__blocked`
- **Set dependencies**: `/beads:dep <from-id> <to-id>` or `mcp__plugin_beads_beads__dep`
- **Close story**: `/beads:close <issue-id>` or `mcp__plugin_beads_beads__close`
- **Project stats**: `/beads:stats` or `mcp__plugin_beads_beads__stats`

### Beads Issue Fields (Story Content)

Stories are tracked as beads issues with these fields:

- **title**: User-focused story title
- **description**: WHAT user capability and WHY it matters (NO HOW)
- **issue_type**: feature, bug, task, epic, or chore
- **priority**: 1 (highest), 2 (medium), 3 (lowest)
- **status**: open, in_progress, blocked, closed
- **acceptance**: Gherkin acceptance criteria (inline or reference to docs)
- **design**: Design notes, architectural decisions, ADR references, integration points
- **deps**: Array of issue IDs this story depends on
- **assignee**: Who's working on it (optional)

## Story Format (Content for Beads Fields)

- **Title**: Clear, user-focused description
  - Written from user's perspective
  - Action-oriented and specific
  - Example: "Send chat message to conversation" not "Implement message sending"

- **Description**: What user capability this enables and why it matters
  - Explain the user value being delivered
  - Provide context about why this capability is important
  - Connect to business or user goals

- **Acceptance Criteria**: Gherkin-format scenarios (Given/When/Then) focusing on user-observable behavior
  - Format: Given [initial context], When [user action], Then [expected outcome]
  - **When story includes commands from event model**: Reference command documentation instead of repeating command decision criteria
    - Use format: "See acceptance criteria in [CommandName](../event_model/commands/CommandName.md)"
    - This avoids duplication and maintains single source of truth for command decision logic
  - **Add user experience scenarios**: Include Given/When/Then scenarios for user-observable aspects not covered by command criteria
    - UI feedback and visual responses
    - Error handling presentation to the user
    - Workflow completion confirmation
    - Next actions available after command completion
  - Multiple scenarios covering happy path and edge cases
  - Focus on user-observable behavior, not implementation details
  - Command criteria cover technical decision-making; story criteria cover complete user experience
  - Example:
    ```gherkin
    Given I have an active chat session
    When I type a message and press Enter
    Then the message appears in the conversation history
    And the assistant begins generating a response
    ```

- **References**: Links to REQUIREMENTS_ANALYSIS.md, ADRs, ARCHITECTURE.md, STYLE_GUIDE.md sections
  - Provide specific section references, not just document names
  - Include rationale for key architectural decisions affecting this story
  - Reference design patterns that inform the UI/UX

- **Integration Point**: Where feature connects to user interface
  - For CLI apps: main.rs command/argument/prompt handling
  - For web apps: HTTP route and method
  - For GUI apps: Menu item or button
  - For libraries: Public API function

- **User Access Method**: How user invokes feature
  - CLI example: `cargo run -- --single-player`
  - Web example: `POST /api/games`
  - GUI example: "Click File → New Game"
  - Library example: `use mylib::start_game;`

- **Manual Testing**: Step-by-step verification instructions
  - Exact commands user runs
  - Expected observable outcomes
  - Success criteria

## Relationship to Event Model Command Criteria

**Event Model (Phase 2) and Story Acceptance Criteria (Phase 6) serve different but complementary purposes:**

- **Event Model Command Documents**: Contain Gherkin acceptance criteria focused on command decision-making and state transitions
  - Define WHAT decisions the system makes when handling a command
  - Specify domain rules and invariants the command must enforce
  - Written from system perspective: "Given [domain state], When [command received], Then [state changes]"
  - Located in: `docs/event_model/commands/[CommandName].md`

- **Story Acceptance Criteria**: Build upon command criteria by adding user-observable scenarios
  - Define HOW users experience the command execution
  - Include UI feedback, visual responses, error presentation, and workflow completion
  - Written from user perspective: "Given [user context], When [user action], Then [user sees/can do]"
  - Stories reference command criteria without full repetition to avoid duplication
  - Additional story scenarios focus on:
    - UI feedback and visual confirmation of successful actions
    - Error handling and error message presentation to users
    - Workflow completion confirmation and state clarity
    - Next actions available after command completes

**Avoiding Duplication:**
- Story acceptance criteria REFERENCE command criteria using: "See acceptance criteria in [CommandName](../event_model/commands/CommandName.md)"
- This maintains a single source of truth for command decision logic
- Stories add additional Given/When/Then scenarios for user experience aspects
- This keeps stories focused and maintainable while ensuring complete documentation

## Example: Command to Story Relationship

**Event Model Command Document** (`docs/event_model/commands/SendMessage.md`):
```gherkin
Acceptance Criteria:

Scenario: Message accepted when conversation exists and is not archived
Given a conversation with ID C1 exists and is active
When SendMessage command is received with valid content and conversation_id=C1
Then message is stored in Event Store
And message_sent event is published
And conversation.updated_at is set to current timestamp

Scenario: Message rejected when conversation is archived
Given a conversation with ID C1 exists and is archived
When SendMessage command is received
Then command is rejected with ConversationArchivedError
And no event is published
```

**Story** (`docs/PLANNING.md` - Story: "User sends message to conversation"):
```
Title: User sends message to conversation

Description: User can compose and send a message to an active conversation,
with clear feedback that the message was delivered and visible in the chat thread.

Acceptance Criteria:

See acceptance criteria in SendMessage command: [SendMessage](../event_model/commands/SendMessage.md)

Additional User Experience Scenarios:

Scenario: User sees message appear immediately in chat thread
Given I have an active conversation open
When I type "Hello" and click Send
Then the message appears at the bottom of the conversation
And the message shows my name and timestamp
And a loading indicator appears below the message

Scenario: User sees confirmation message is delivered
Given I just sent a message that is loading
When the server confirms delivery
Then the loading indicator disappears
And the message appears with a checkmark icon
And the input field is cleared and ready for next message

Scenario: User sees error if conversation becomes archived
Given I am typing in a conversation
When the conversation is archived while I'm composing
Then the Send button is disabled
And an error message appears: "This conversation is archived"
And the unsent message is preserved in the input field
```

## Prioritization Protocol

1. **story-planner creates initial prioritized beads issues (business risk vs. value)**
   - Evaluate each story's business value
   - Assess risk of NOT implementing each story
   - Consider user impact and urgency
   - Create beads issues with initial priority values (1=highest, 2=medium, 3=lowest)

2. **story-architect and ux-consultant consent to implementation order**
   - story-architect reviews for implementation dependencies
   - ux-consultant reviews for design coherence and user journey flow
   - Both agents must consent to the proposed order

3. **Agents may suggest reprioritization based on technical dependencies or design constraints**
   - Technical dependencies set via `/beads:dep` (e.g., authentication blocks user profiles)
   - Design constraints may suggest different priority values
   - All three agents discuss and reach consensus on priorities and dependencies

4. **Final priority and dependency graph must make sense for both business and implementation**
   - Priority values satisfy business priorities
   - Dependencies ensure technically feasible implementation order
   - Design coherence and good UX progression maintained
   - All three agents must reach consensus before proceeding
   - Use `/beads:ready` to verify work can begin on priority stories
