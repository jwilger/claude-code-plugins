---
user-invocable: false
name: atomic-design
version: 1.0.0
author: jwilger
repository: jwilger/claude-code-plugins
description: Brad Frost's Atomic Design methodology for building UI component hierarchies
tags:
  - ui
  - design-system
  - components
  - composition
portability: universal
dependencies: []
---

# Atomic Design

**Version:** 1.0.0
**Portability:** Universal

---

## Objective

Teaches Brad Frost's Atomic Design methodology for building scalable, maintainable UI component systems through compositional hierarchy.

**Purpose:** Create consistent, reusable UI components organized from simple to complex, enabling efficient development and maintenance of user interfaces.

**Scope:**
- **Included:** Component hierarchy (atoms/molecules/organisms/templates), composition patterns, design tokens, component organization
- **Excluded:** Specific framework implementations, visual design choices, styling approaches

---

## Core Principles

### Principle 1: Hierarchical Composition (Atoms → Molecules → Organisms → Templates)

**The Principle:** Build UI components in layers of increasing complexity, where each layer is composed of elements from the layer below.

**Why this matters:** Bottom-up composition creates consistency and reusability. Changing an atom cascades improvements through all molecules and organisms that use it.

**The Four Levels:**
1. **Atoms:** Basic building blocks (buttons, inputs, labels, icons)
2. **Molecules:** Simple combinations of atoms (form fields, cards, search bars)
3. **Organisms:** Complex components (navigation bars, data tables, complete forms)
4. **Templates:** Page-level layouts (dashboard, list view, detail view)

**How to apply:**
- Start with atoms (smallest reusable pieces)
- Combine atoms into molecules
- Compose molecules into organisms
- Arrange organisms into templates
- Never skip levels (don't build organisms directly from raw HTML)

**Example:**
```
Atom: Button component
  ↓
Molecule: Search bar (Input atom + Button atom + Icon atom)
  ↓
Organism: Header navigation (Logo atom + Search bar molecule + Navigation menu molecule)
  ↓
Template: Dashboard layout (Header organism + Sidebar organism + Content area)
```

### Principle 2: Single Responsibility per Component

**The Principle:** Each component should do one thing well. Atoms are indivisible, molecules combine for a single purpose, organisms encapsulate a complete feature.

**Why this matters:** Single-responsibility components are easier to test, reuse, and maintain. Over-loaded components become brittle and hard to change.

**How to apply:**
- Atoms: One visual element (a button, not a button with a dropdown)
- Molecules: One interaction pattern (search bar for searching, not search-and-filter-and-sort)
- Organisms: One feature area (navigation, not navigation-and-footer-and-sidebar)

**Example:**
```
❌ Bad: "SuperButton" - Button that can be primary/secondary/icon/dropdown/link
✓ Good: Button (atom), IconButton (molecule), DropdownButton (molecule) - each focused

❌ Bad: "FormControls" - Handles all form logic, validation, submission, layout
✓ Good: Input (atom), FormField (molecule), Form (organism) - clear responsibilities
```

### Principle 3: Design Tokens for Consistency

**The Principle:** Extract design decisions (colors, typography, spacing) into reusable tokens referenced by all components.

**Why this matters:** Centralized design tokens ensure visual consistency and make theme changes simple. Without tokens, design changes require editing hundreds of components.

**How to apply:**
1. Define tokens first (colors, fonts, sizes, spacing)
2. Components reference tokens, never hard-code values
3. Changing a token updates all components that use it

**Example:**
```css
/* Design Tokens */
--color-primary: #0066cc;
--color-danger: #cc0000;
--spacing-sm: 8px;
--spacing-md: 16px;
--font-size-body: 16px;
--font-size-heading: 24px;

/* Atom: Button uses tokens */
.button-primary {
  background-color: var(--color-primary);  /* Not #0066cc */
  padding: var(--spacing-sm);              /* Not 8px */
  font-size: var(--font-size-body);        /* Not 16px */
}

/* Changing --color-primary updates ALL primary buttons */
```

### Principle 4: Composition Over Inheritance

**The Principle:** Build complex components by composing simpler ones, not by inheriting or extending base components.

**Why this matters:** Composition is more flexible than inheritance. You can combine components in novel ways without modifying their source code.

**How to apply:**
- Pass atoms/molecules as props/children to organisms
- Use container/presentational patterns
- Avoid deep component hierarchies (prefer flat composition)

**Example (React):**
```jsx
// ❌ Bad: Inheritance
class FancyButton extends Button {
  render() {
    return <Button className="fancy" {...this.props} />;
  }
}

// ✓ Good: Composition
const FancyButton = ({ children, ...props }) => (
  <Button className="fancy" {...props}>
    <Icon name="star" />
    {children}
  </Button>
);

// ✓ Good: Flexible composition
<Card>
  <CardHeader>
    <Heading level={2}>Title</Heading>
    <Button variant="icon">⋯</Button>
  </CardHeader>
  <CardBody>
    <Text>Content</Text>
  </CardBody>
</Card>
```

---

## Constraints and Boundaries

### DO:
- Start with atoms, build up to templates (bottom-up)
- Extract design decisions into tokens
- Keep components focused (single responsibility)
- Compose complex components from simpler ones
- Document the hierarchy and relationships
- Test components in isolation

### DON'T:
- Skip levels (e.g., build organisms directly from raw markup)
- Hard-code design values (use tokens instead)
- Create "god components" that do everything
- Use inheritance when composition works
- Build templates before you have organisms
- Couple components to specific data fetching logic (keep presentational)

**Rationale:** These constraints ensure maintainable, consistent, reusable component systems.

---

## Usage Patterns

### Pattern 1: Building a Form System

**Scenario:** Creating a consistent form UI across an application.

**Approach:**

**1. Atoms:**
```
- Input (text input element)
- Label (text label element)
- ErrorMessage (error text element)
- Button (submit button)
```

**2. Molecules:**
```
- FormField (Label + Input + ErrorMessage)
- FormActions (Cancel button + Submit button)
```

**3. Organisms:**
```
- Form (Collection of FormFields + FormActions)
- LoginForm (Form with specific email + password fields)
- RegistrationForm (Form with email + password + confirm fields)
```

**4. Templates:**
```
- AuthPage (Page layout with LoginForm or RegistrationForm)
```

**Benefits:**
- Change Input styling → All forms update
- Validation logic in FormField → Consistent everywhere
- Reuse LoginForm in modal, page, sidebar

### Pattern 2: Design Token Extraction

**Scenario:** Existing app with inconsistent styling needs design system.

**Approach:**

**1. Audit existing UI:**
- Find all unique colors: #0066cc, #0055bb, #0044aa, #0033cc (4 blues!)
- Find all unique spacings: 5px, 8px, 10px, 12px, 15px, 16px, 20px
- Find all unique font sizes: 12px, 14px, 15px, 16px, 18px, 20px, 24px

**2. Standardize into tokens:**
```css
/* Colors: Reduce to semantic scale */
--color-primary: #0066cc;
--color-primary-dark: #0044aa;
--color-primary-light: #3388dd;

/* Spacing: Standard scale */
--spacing-xs: 4px;
--spacing-sm: 8px;
--spacing-md: 16px;
--spacing-lg: 24px;
--spacing-xl: 32px;

/* Typography: Modular scale */
--font-size-sm: 14px;
--font-size-base: 16px;
--font-size-lg: 20px;
--font-size-xl: 24px;
```

**3. Refactor components to use tokens:**
- Replace hard-coded values
- Document token usage
- Verify consistency

### Pattern 3: Cross-Platform Design System

**Scenario:** Building for web (React), mobile (React Native), and desktop (Electron).

**Approach:**

**1. Define platform-agnostic hierarchy:**
```
Atoms: Button, Input, Text, Icon
Molecules: SearchBar, Card, MenuItem
Organisms: Navigation, DataTable, Form
Templates: Dashboard, ListPage, DetailPage
```

**2. Implement per platform:**
```
web/atoms/Button.tsx       - Web implementation
mobile/atoms/Button.tsx    - React Native implementation
desktop/atoms/Button.tsx   - Electron implementation
```

**3. Shared design tokens:**
```javascript
// tokens.json (shared across platforms)
{
  "colors": {
    "primary": "#0066cc",
    "danger": "#cc0000"
  },
  "spacing": {
    "sm": 8,
    "md": 16
  }
}

// Each platform translates to native format
// web: CSS variables
// mobile: StyleSheet values
// desktop: CSS variables
```

**Benefits:**
- Consistent hierarchy across platforms
- Platform-optimized implementations
- Shared design language

---

## Integration with Other Skills

**Works well with:**
- **event-modeling:** Wireframes from event modeling inform component needs
- **tdd-constraints:** Test components in isolation (atom tests, molecule tests, etc.)
- **domain-modeling:** Read models define component data requirements

**Prerequisites:**
- UI framework (React, Vue, SwiftUI, etc.)
- Understanding of composition patterns
- Design decisions made (colors, typography, spacing)

---

## Common Pitfalls

### Pitfall 1: Skipping the Atom Layer

**Problem:** Building molecules and organisms directly from raw HTML/markup

**Solution:** Always extract atoms first. Even if an atom is used only once initially, it establishes consistency for future uses.

**Example:**
```jsx
// ❌ Bad: Organism uses raw elements
const Header = () => (
  <header>
    <h1 style={{ color: '#0066cc', fontSize: '24px' }}>Title</h1>
    <button style={{ padding: '8px' }}>Action</button>
  </header>
);

// ✓ Good: Organism composes atoms
const Header = () => (
  <HeaderContainer>
    <Heading level={1}>Title</Heading>
    <Button>Action</Button>
  </HeaderContainer>
);
```

### Pitfall 2: Over-Abstraction Too Early

**Problem:** Creating flexible, configurable "uber-components" before understanding actual needs

**Solution:** Start with specific components. Extract atoms when you see duplication (DRY principle). Don't prematurely abstract.

**Example:**
```jsx
// ❌ Bad: Over-engineered too early
<FlexibleButton
  variant="primary"
  size="large"
  leftIcon="check"
  rightIcon="arrow"
  loading={false}
  disabled={false}
  hoverEffect="fade"
  // 20 more props...
/>

// ✓ Good: Start simple, extract patterns as needed
<Button>Save</Button>
<Button disabled>Save</Button>
<IconButton icon="check">Save</IconButton>
```

### Pitfall 3: Coupling to Data Logic

**Problem:** Components that fetch data, handle business logic, and render UI

**Solution:** Keep components presentational. Pass data as props. Separate container (data) from presentation (UI).

**Example:**
```jsx
// ❌ Bad: Organism handles data fetching
const UserProfile = () => {
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetch('/api/user').then(r => r.json()).then(setUser);
  }, []);

  return <div>{user?.name}</div>;
};

// ✓ Good: Separate container from presentation
const UserProfile = ({ user }) => (
  <Card>
    <Avatar src={user.avatar} />
    <Heading>{user.name}</Heading>
    <Text>{user.email}</Text>
  </Card>
);

const UserProfileContainer = () => {
  const user = useUser();  // Data fetching logic elsewhere
  return <UserProfile user={user} />;
};
```

### Pitfall 4: Hard-Coding Design Values

**Problem:** Spacing, colors, fonts embedded directly in components

**Solution:** Extract into design tokens, reference tokens in components

---

## Examples

### Example 1: E-commerce Product Card (React)

**Atoms:**
```jsx
// atoms/Image.tsx
const Image = ({ src, alt }) => (
  <img src={src} alt={alt} className="image" />
);

// atoms/Text.tsx
const Text = ({ children, size = 'base' }) => (
  <p className={`text text-${size}`}>{children}</p>
);

// atoms/Button.tsx
const Button = ({ children, variant = 'primary' }) => (
  <button className={`button button-${variant}`}>{children}</button>
);
```

**Molecules:**
```jsx
// molecules/ProductPrice.tsx
const ProductPrice = ({ price, currency = 'USD' }) => (
  <div className="product-price">
    <Text size="lg" weight="bold">${price}</Text>
    <Text size="sm" color="muted">{currency}</Text>
  </div>
);

// molecules/Rating.tsx
const Rating = ({ rating, maxRating = 5 }) => (
  <div className="rating">
    {Array.from({ length: maxRating }, (_, i) => (
      <Icon key={i} name={i < rating ? 'star-filled' : 'star-empty'} />
    ))}
  </div>
);
```

**Organisms:**
```jsx
// organisms/ProductCard.tsx
const ProductCard = ({ product }) => (
  <Card>
    <Image src={product.image} alt={product.name} />
    <CardBody>
      <Heading level={3}>{product.name}</Heading>
      <Text>{product.description}</Text>
      <ProductPrice price={product.price} />
      <Rating rating={product.rating} />
      <Button onClick={() => addToCart(product)}>Add to Cart</Button>
    </CardBody>
  </Card>
);
```

**Templates:**
```jsx
// templates/ProductListPage.tsx
const ProductListPage = ({ products }) => (
  <PageLayout>
    <Header>
      <Heading level={1}>Products</Heading>
      <SearchBar />
    </Header>
    <ProductGrid>
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </ProductGrid>
  </PageLayout>
);
```

### Example 2: Mobile Form (Swift UI)

**Atoms:**
```swift
// Atoms/TextField.swift
struct AppTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.roundedBorder)
            .padding(Spacing.sm)
    }
}

// Atoms/Button.swift
struct AppButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .padding(Spacing.md)
                .background(Color.primary)
                .cornerRadius(8)
        }
    }
}
```

**Molecules:**
```swift
// Molecules/FormField.swift
struct FormField: View {
    let label: String
    @Binding var text: String
    let error: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
            AppTextField(placeholder: label, text: $text)
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}
```

**Organisms:**
```swift
// Organisms/LoginForm.swift
struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""
    let onSubmit: (String, String) -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            FormField(label: "Email", text: $email, error: nil)
            FormField(label: "Password", text: $password, error: nil)
            AppButton(title: "Log In") {
                onSubmit(email, password)
            }
        }
        .padding()
    }
}
```

### Example 3: Design Tokens (CSS + JavaScript)

**tokens.css:**
```css
:root {
  /* Colors */
  --color-primary: #0066cc;
  --color-success: #00cc66;
  --color-danger: #cc0000;
  --color-text: #333333;
  --color-background: #ffffff;

  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;

  /* Typography */
  --font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  --font-size-sm: 14px;
  --font-size-base: 16px;
  --font-size-lg: 20px;
  --font-size-xl: 24px;
  --font-size-2xl: 32px;

  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.15);
}
```

**tokens.js (for use in JavaScript):**
```javascript
export const tokens = {
  colors: {
    primary: '#0066cc',
    success: '#00cc66',
    danger: '#cc0000',
    text: '#333333',
    background: '#ffffff'
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32
  },
  typography: {
    sizes: {
      sm: 14,
      base: 16,
      lg: 20,
      xl: 24,
      '2xl': 32
    }
  }
};
```

---

## Verification Checklist

Use this checklist to verify you're applying Atomic Design correctly:

- [ ] Atoms defined (basic UI elements)
- [ ] Molecules combine atoms for single purposes
- [ ] Organisms compose molecules into features
- [ ] Templates arrange organisms into page layouts
- [ ] Design tokens extracted (colors, spacing, typography)
- [ ] Components reference tokens (no hard-coded values)
- [ ] Each component has single responsibility
- [ ] Components composed, not inherited
- [ ] Components are presentational (data passed as props)
- [ ] Hierarchy documented and enforced

---

## References

**Source Documentation:**
- sdlc plugin: commands/shared/atomic-design.md
- Brad Frost: Atomic Design (atomicdesign.bradfrost.com)

**Related Skills:**
- event-modeling - Wireframes inform component needs
- domain-modeling - Read models define component data

**External Resources:**
- Atomic Design by Brad Frost
- Design Systems Handbook by InVision
- Component-Driven Development

---

## Version History

### v1.0.0 (2026-02-04)
- Initial extraction from sdlc plugin
- Framework-agnostic principles
- Examples in React, Swift UI
- Design token patterns
- Core insight: Hierarchical composition (atoms → templates)

---

## Metadata

**Extraction Source:** sdlc/commands/shared/atomic-design.md
**Extraction Date:** 2026-02-04
**Last Updated:** 2026-02-04
**Compatibility:** Universal (all UI frameworks)
**License:** MIT
