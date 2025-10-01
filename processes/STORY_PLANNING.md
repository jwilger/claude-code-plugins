# Story Planning Process

**Phase 6: Story Planning**

**Agents**: product-manager ↔ technical-architect ↔ ux-ui-design-expert
**Process**: Collaborative creation until consensus
**Output**: docs/PLANNING.md with prioritized user stories
**Gate**: All three agents agree stories are complete, well-defined, and properly prioritized

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

## Story Format

- **Title**: Clear, user-focused description
  - Written from user's perspective
  - Action-oriented and specific
  - Example: "Send chat message to conversation" not "Implement message sending"

- **Description**: What user capability this enables and why it matters
  - Explain the user value being delivered
  - Provide context about why this capability is important
  - Connect to business or user goals

- **Acceptance Criteria**: Gherkin-format scenarios (Given/When/Then)
  - Format: Given [initial context], When [user action], Then [expected outcome]
  - Multiple scenarios covering happy path and edge cases
  - Focus on user-observable behavior
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

## Prioritization Protocol

1. **Product manager creates initial prioritized todo list (business risk vs. value)**
   - Evaluate each story's business value
   - Assess risk of NOT implementing each story
   - Consider user impact and urgency
   - Create initial priority ordering

2. **Technical architect and ux-ui-design-expert consent to implementation order**
   - Technical architect reviews for implementation dependencies
   - UX/UI expert reviews for design coherence and user journey flow
   - Both agents must consent to the proposed order

3. **Agents may suggest reprioritization based on technical dependencies or design constraints**
   - Technical dependencies may require reordering (e.g., authentication before user profiles)
   - Design constraints may suggest different groupings (e.g., complete one user journey before starting another)
   - All three agents discuss and reach consensus on any changes

4. **Final priority order must make sense for both business and implementation**
   - Final ordering must satisfy business priorities
   - Must be technically feasible in the proposed order
   - Must maintain design coherence and good UX progression
   - All three agents must reach consensus before proceeding
