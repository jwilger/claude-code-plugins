---
description: Load Technical Increment Planning methodology for infrastructure/library projects
disable-model-invocation: false
---

# Technical Increment Planning Process

**Phase 6: Technical Increment Planning**

**Agents**: technical-increment-planner ↔ story-architect
**Process**: Collaborative creation until consensus
**Output**: docs/PLANNING.md with prioritized technical increments
**Gate**: Both agents agree increments are well-defined and properly ordered

## Core Principles

1. **Smallest Working Units**: Each increment delivers testable, releasable technical capability
2. **Dependency-Ordered**: Increments ordered by technical dependencies, not business value
3. **Fully Functional**: All error paths handled, no "TODO" implementations
4. **Testable**: Clear Gherkin acceptance criteria for technical behaviors
5. **Documented**: Usage examples showing how consumers use the capability

## Increment Characteristics

**Each increment MUST:**
- Be independently deployable/releasable (could ship it alone if needed)
- Have all error paths handled appropriately
- Have clear acceptance criteria as Gherkin scenarios
- Have usage examples demonstrating the capability
- Build on prior increments logically (dependency order)

**Each increment MUST NOT:**
- Require future increments to be functional
- Leave partial implementations or TODOs
- Skip error handling or edge cases
- Lack integration examples

## Planning Process

1. **Map Requirements to Components**: Identify architectural components needed
2. **Identify Dependency Chains**: What depends on what?
3. **Define Smallest Units**: Break components into independently deliverable increments
4. **Order by Dependencies**: Foundational increments first
5. **Validate with Architect**: Confirm technical feasibility and order
6. **Iterate Until Consensus**: Refine until both agents agree

## Increment Format

```markdown
## Increment N: [Technical Capability]

**Priority:** N
**Status:** Not Started | In Progress | Complete
**Dependencies:** [Prior increment numbers]

**Technical Objective**: [One-sentence capability description]

**Capabilities Delivered**:
- [Specific capability 1]
- [Specific capability 2]

**Acceptance Criteria** (Gherkin):

Scenario: [Technical behavior]
Given [technical preconditions]
When [API called]
Then [observable outcome]

**Integration Point**:
- Public API: [Function signature]
- CLI: [Command] (if applicable)

**Testing Strategy**:
- Unit tests: [Coverage]
- Integration tests: [What verified]
- Examples: [Path to examples]

**References**:
- REQUIREMENTS_ANALYSIS.md § [section]
- ADR-NNN: [Title]
- ARCHITECTURE.md § [section]
```

## Example Increment

```markdown
## Increment 1: Core HTTP Request/Response Cycle

**Priority:** 1
**Status:** Not Started
**Dependencies:** None

**Technical Objective**: Enable basic HTTP request handling and response generation

**Capabilities Delivered**:
- Parse HTTP/1.1 requests (method, path, headers, body)
- Route to handlers based on path matching
- Generate well-formed HTTP responses

**Acceptance Criteria** (Gherkin):

Scenario: Parse and route GET request
Given configured server on port 8080
When GET /health with valid headers
Then request parsed and routed
And 200 OK returned with {"status": "healthy"}

Scenario: Handle malformed requests
Given configured server
When invalid HTTP syntax
Then 400 Bad Request with error description
And server remains operational

**Integration Point**:
- Public API: `Server::handle_request(req: Request) -> Response`

**Testing Strategy**:
- Unit: Parser, router, response builder
- Integration: Socket → handler → socket
- Examples: examples/basic_server.rs

**References**:
- REQUIREMENTS_ANALYSIS.md § FR-1
- ADR-003: Request Routing
- ARCHITECTURE.md § Request Pipeline
```

## Gherkin for Technical Behaviors

**Focus on observable technical behavior**, not internal implementation:

✅ **Good** (observable behavior):
```gherkin
Given a configured server
When GET request at /health
Then 200 OK response
And JSON: {"status": "healthy"}
```

❌ **Bad** (internal implementation):
```gherkin
Given RequestHandler initialized
When handle() called
Then Response::Ok constructed
And JSON serialized
```

## Dependency Management

**Linear Dependencies:**
```
Increment 1: Foundation
  ↓
Increment 2: Builds on 1
  ↓
Increment 3: Builds on 2
```

**Parallel Opportunities:**
```
Increment 1: Foundation
  ├→ Increment 2: Feature A (uses 1)
  └→ Increment 3: Feature B (uses 1)
```

**Circular Dependencies (Split Required):**
```
❌ Bad: Increment A needs B, B needs A
✅ Good: Split into A1 (foundation), A2 (uses B), B (uses A1)
```

## Story-Architect Collaboration

**technical-increment-planner proposes:**
- Initial increment list
- Proposed dependency order
- Technical capabilities

**story-architect validates:**
- Technical feasibility
- Dependency correctness
- Architectural constraints
- Risk identification

**Iterate until consensus:**
- Both agents must approve
- Final increment list and order agreed

## Integration Requirements

**Every increment MUST specify:**
1. **Integration Point**: Where consumers access the feature
   - Public API function/method
   - CLI command (if applicable)
   - Configuration option (if applicable)

2. **User Access Method**: How consumers invoke the feature
   - Function call: `use mylib::feature;`
   - CLI: `mytool command --flag`
   - Config: `config.toml: [section]`

3. **Usage Examples**: Working code demonstrating usage
   - Path: `examples/feature_name.rs`
   - Must actually run and work
   - Should be simple and focused

## Quality Checks

Before finalizing plan:
- ✅ Each increment is smallest working unit?
- ✅ Dependencies correctly identified?
- ✅ Ordered by dependencies, not arbitrary?
- ✅ All increments have integration points?
- ✅ All increments have usage examples?
- ✅ Acceptance criteria testable?
- ✅ No implementation details?
- ✅ Architect approved?

## Handoff to Phase 7

After consensus reached:
- docs/PLANNING.md complete
- All increments well-defined
- Dependency order validated
- Ready for Phase 7: Increment-by-Increment Implementation

Remember: Good increment planning sets up successful implementation. Take time to get it right before coding begins.
