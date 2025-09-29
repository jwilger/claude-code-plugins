# Agent Memory Schema for Research-Only Architecture

This document defines the standardized memory entities and relationships that research-only agents use to store their proposals for main agent execution.

## Core Entity Types

### AgentProposal (Base Entity)
All proposal entities should include these common observations:
- `agent_name`: Name of the agent creating the proposal
- `proposal_type`: Type of proposal (code_change, document, test, etc.)
- `rationale`: Why this proposal is needed
- `priority`: High/Medium/Low priority level
- `dependencies`: What this proposal depends on
- `project_context`: Current project name and path

### CodeChangeProposal
For proposing specific code modifications:
- `file_path`: Absolute path to file to modify
- `operation`: "create", "edit", or "delete"
- `line_start`: Starting line number (for edits)
- `line_end`: Ending line number (for edits)
- `old_content`: Current content to replace (for edits)
- `new_content`: New content to write
- `language`: Programming language
- `validation_command`: Command to verify the change (e.g., "cargo check")

### TestProposal
For proposing test code:
- `test_type`: "unit", "integration", "property", or "mutation"
- `test_file_path`: Path to test file
- `test_code`: Complete test code
- `assertion_count`: Number of assertions (should be 1 for TDD)
- `coverage_target`: Expected coverage increase
- `verification_command`: Command to run tests

### DependencyProposal
For proposing dependency changes:
- `package_name`: Name of package/crate
- `version`: Specific version or version requirement
- `operation`: "add", "update", or "remove"
- `justification`: Why this dependency is needed
- `manifest_file`: Path to Cargo.toml, package.json, etc.
- `verification_command`: Command to verify dependency works

### GitOperationProposal
For proposing git operations:
- `operation_type`: "commit", "push", "branch", "merge"
- `commands`: Array of git commands to execute
- `commit_message`: Commit message (if applicable)
- `branch_name`: Branch name (if applicable)
- `expected_state`: Expected repository state after operation

### DocumentProposal
For proposing documentation content:
- `document_type`: "requirements", "adr", "architecture", "style_guide"
- `file_path`: Path where document should be written
- `content`: Complete document content in Markdown
- `structure`: Document outline/sections
- `compliance_notes`: Markdownlint or formatting requirements

### ArchitecturalDecision
For proposing ADRs:
- `decision_title`: Short title of the decision
- `context`: Background that led to decision
- `decision`: What was decided
- `consequences`: Expected positive and negative outcomes
- `alternatives`: Other options considered
- `status`: "proposed", "accepted", "deprecated", "superseded"

### RequirementProposal
For proposing requirements:
- `requirement_type`: "functional", "non-functional", "constraint"
- `user_story`: As-a/I-want/So-that format
- `acceptance_criteria`: Specific, testable criteria
- `business_value`: Why this requirement matters
- `success_metrics`: How to measure success

## Standard Relations

### Temporal Relations
- `supersedes`: This proposal replaces an older one
- `refines`: This proposal improves/enhances an existing one
- `evolved-from`: This proposal grew out of another proposal

### Dependency Relations
- `depends-on`: This proposal requires another to be completed first
- `blocks`: This proposal prevents another from proceeding
- `enables`: This proposal makes another possible

### Requirements Relations
- `implements`: This proposal implements a requirement
- `supports`: This proposal contributes to a requirement
- `validates`: This proposal tests/verifies a requirement

### Feedback Relations
- `addresses-feedback`: This proposal responds to rejection feedback
- `rejected-by`: Links to rejection feedback entity

## Memory Storage Protocol

### Entity Naming Convention
Use structured names for reliable retrieval:
```
{agent_type}_{proposal_type}_{timestamp}
```

Examples:
- `product_manager_requirements_20250929134500`
- `rust_domain_types_20250929134501`
- `technical_architect_adr_security_20250929134502`

### Creating Proposals
```markdown
1. Load project context using mcp__time__get_current_time
2. Search for existing related proposals using semantic_search
3. Generate structured entity name using naming convention
4. Create new entity with appropriate type and structured name
5. Include ALL required observations for that type
6. Add retrieval markers in observations (e.g., "STATUS: ready_for_review")
7. Create relations to existing entities (requirements, dependencies, etc.)
8. Store with project metadata in observations
9. Return entity NAME to main agent (NOT ID - IDs don't work for retrieval)
```

### Retrieving Proposals
```markdown
1. Main agent uses open_nodes with entity NAMES from research agents
2. Alternative: Use search_nodes with status patterns ("STATUS: ready_for_review")
3. Follow relations to understand dependencies and context
4. Aggregate related proposals into comprehensive plan
5. Present to user via ExitPlanMode
```

### Handling Rejections
```markdown
1. Create RejectionFeedback entity with structured name:
   - Entity name: rejection_feedback_{timestamp}
   - rejected_proposal_names: Names of rejected proposals
   - rejection_reason: User's feedback/concerns
   - requested_changes: Specific modifications needed
2. Re-launch research agent with feedback entity name
3. Agent loads feedback using entity name and refines proposal
4. Create new proposal with "addresses-feedback" relation
```

## Project Context Format

All proposals MUST include project context in this format:
```
Project: {project_name} | Path: {project_path} | Scope: {PROJECT_SPECIFIC|UNIVERSAL|PATTERN}
```

## Quality Standards

### Completeness Requirements
- Every proposal must have enough detail for main agent to execute
- Include file paths, line numbers, complete content
- Specify verification commands to validate changes
- Document rationale and business value

### Consistency Requirements
- Use standardized entity types and relation names
- Follow project naming conventions
- Include temporal information for all decisions
- Link to related requirements and dependencies

### Validation Requirements
- Proposals should be verified with read-only tools before storage
- Include expected outcomes and success criteria
- Document rollback procedures for risky changes
- Specify testing requirements for code changes

## Example Usage

### Code Change Proposal
```markdown
Entity Name: rust_domain_code_change_20250929134500
Entity Type: CodeChangeProposal
Observations:
- agent_name: "rust-domain-model-expert"
- proposal_type: "code_change"
- file_path: "/project/src/domain/user.rs"
- operation: "create"
- new_content: "pub struct User { ... }"
- language: "rust"
- validation_command: "cargo check"
- rationale: "Create domain type to make illegal states unrepresentable"
- project_context: "Project: myapp | Path: /project | Scope: PROJECT_SPECIFIC"
- STATUS: "ready_for_review"
- RETRIEVAL_KEY: "rust_domain_user_type"

Relations:
- implements → RequirementEntity("User Management")
- depends-on → DependencyProposal("serde crate")
```

This schema ensures consistent, complete, and traceable proposals that enable the main agent to execute approved changes reliably.