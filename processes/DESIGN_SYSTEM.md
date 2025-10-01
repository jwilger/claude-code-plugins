# Design System Creation Process

**Phase 5: Design System**

**Agent**: ux-ui-design-expert
**Input**: EVENT_MODEL.md and ARCHITECTURE.md
**Output**: docs/STYLE_GUIDE.md (using Atomic Design methodology)
**Gate**: Complete design system with interaction patterns

## Purpose

The design system establishes:
- Visual design language
- Interaction patterns
- Component hierarchy
- User experience guidelines
- Accessibility requirements

## Atomic Design Methodology

The design system follows Brad Frost's Atomic Design methodology:

### Hierarchy Levels

1. **Atoms**: Basic building blocks
   - Buttons, input fields, labels, icons
   - Typography, color palettes, spacing units
   - Cannot be broken down further while retaining meaning

2. **Molecules**: Simple component groups
   - Form fields (label + input + error message)
   - Search box (input + button)
   - Navigation item (icon + label)

3. **Organisms**: Complex component assemblies
   - Navigation bar, header, footer
   - Form sections, data tables
   - Card layouts with multiple elements

4. **Templates**: Page-level structure
   - Layout grids, content regions
   - Placeholder content showing structure
   - Define responsive breakpoints

5. **Pages**: Specific instances
   - Real content examples
   - Complete user interfaces
   - Demonstrate actual usage

## STYLE_GUIDE.md Expected Structure

### Visual Design Language

- **Color Palette**: Primary, secondary, accent, semantic colors (success, warning, error)
- **Typography**: Font families, sizes, weights, line heights, hierarchy
- **Spacing System**: Consistent spacing units and grid system
- **Iconography**: Icon style, sizing, usage guidelines
- **Elevation/Depth**: Shadow system for layering

### Component Library

For each component level (Atoms → Pages):
- **Purpose**: What problem does this component solve?
- **Visual Specification**: Size, color, spacing, typography
- **States**: Default, hover, focus, active, disabled, error
- **Variants**: Different versions (primary/secondary button, large/small, etc.)
- **ASCII Wireframes**: Show component structure visually
- **Usage Guidelines**: When to use, when not to use

### Interaction Patterns

- **Navigation**: How users move through the application
- **Data Input**: How users provide information
- **Feedback**: How system responds to user actions
- **Error Handling**: How errors are presented and resolved
- **Loading States**: How system communicates processing
- **Empty States**: What users see when no data available

### User Journey Flows

- **Complete workflows**: Step-by-step user journeys
- **Screen transitions**: How users move between views
- **Context preservation**: What state is maintained across transitions
- **Decision points**: Where users make choices that affect flow

### Accessibility Requirements

- **Keyboard Navigation**: All interactions accessible via keyboard
- **Screen Reader Support**: Proper semantic markup and ARIA labels
- **Color Contrast**: WCAG 2.1 Level AA minimum
- **Focus Indicators**: Clear visual focus states
- **Error Identification**: Errors clearly identified and described
- **Resize/Zoom**: Content usable at 200% zoom

## Design Patterns NOT Implementation Code Focus

**CRITICAL**: STYLE_GUIDE.md focuses on DESIGN and USER EXPERIENCE, not implementation details.

### What to Include

- **Visual specifications**: Colors, fonts, sizes, spacing
- **Interaction behavior**: What happens when user takes action
- **User experience flows**: How user accomplishes goals
- **Accessibility patterns**: How to make interactions inclusive
- **Design rationale**: WHY design choices were made

### What NOT to Include

- **Implementation code**: No Rust, HTML, CSS, or framework code
- **Technical architecture**: Leave to ARCHITECTURE.md and ADRs
- **Data structures**: Leave to domain modeling agents
- **API specifications**: Leave to technical documentation

### Design Rationale (WHY Choices Made)

For each design decision, document:
- **User need**: What user problem does this solve?
- **Design alternatives**: What other approaches were considered?
- **Trade-offs**: What are pros and cons of this choice?
- **Consistency**: How does this align with overall design language?
- **Accessibility impact**: How does this affect users with disabilities?

## Integration with Event Model

The STYLE_GUIDE.md should:
- Reference vertical slices from EVENT_MODEL.md
- Show UI wireframes for user interactions
- Demonstrate how design supports user workflows
- Maintain consistency with event-driven architecture

## Example Structure

```markdown
# Style Guide

## Visual Design Language

### Color Palette
- Primary: #007AFF (Interactive elements)
- Secondary: #5856D6 (Accent elements)
- Success: #34C759, Warning: #FF9500, Error: #FF3B30
- Rationale: High contrast, accessible, follows system conventions

### Typography
- Primary Font: SF Pro (system font)
- Display: 28pt Bold, Body: 14pt Regular, Caption: 11pt Regular
- Rationale: Readable at various sizes, system integration

## Component Library

### Atoms

#### Button
- Purpose: Trigger actions
- Variants: Primary (filled), Secondary (outlined)
- States: Default, Hover, Active, Disabled
- Size: 44pt minimum tap target (accessibility)
- Rationale: Follows Apple HIG for consistency

[ASCII wireframe showing button variants]

### Molecules

#### Search Input
- Purpose: Allow users to filter or find content
- Components: Text input + Search icon + Clear button
- States: Empty, Focused, Filled, Error

[ASCII wireframe showing search input]

## Interaction Patterns

### Navigation
- Users navigate via tab/arrow keys or mouse
- Current location always visible
- Breadcrumbs for deep hierarchies
- Rationale: Supports both keyboard and mouse users

## User Journey Flows

### Send Message Workflow
1. User types message in input area
2. User presses Enter or clicks Send
3. Message appears in conversation history
4. System shows "thinking" indicator
5. Response appears incrementally

[ASCII wireframe showing each step]

## Accessibility Requirements

- Minimum contrast ratio: 4.5:1 for normal text
- All interactive elements keyboard accessible
- Screen reader announces state changes
- Focus indicators: 2px solid outline
- Rationale: WCAG 2.1 Level AA compliance
```

## Collaboration with Other Agents

The ux-ui-design-expert collaborates with:
- **product-manager**: Ensure design supports user requirements
- **technical-architect**: Ensure design is technically feasible
- **All agents**: Review EVENT_MODEL.md for UI wireframe alignment

## Deliverable Checklist

Before considering Phase 5 complete:
- [ ] Visual design language fully defined
- [ ] All Atomic Design levels documented (Atoms → Pages)
- [ ] Interaction patterns specified for all user workflows
- [ ] User journey flows documented with wireframes
- [ ] Accessibility requirements specified
- [ ] Design rationale provided for key decisions
- [ ] References to EVENT_MODEL.md vertical slices
- [ ] No implementation code or technical architecture details
