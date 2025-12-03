# GWT Scenarios: <Workflow Name>

## Slice: <Slice Name>

### Scenario 1: <Happy Path Description>

**GIVEN:**
- `EventName` with:
  ```json
  { "attribute": "value" }
  ```

**WHEN:**
- `CommandName` with:
  ```json
  { "attribute": "value" }
  ```

**THEN:**
- `ExpectedEvent` with:
  ```json
  { "attribute": "expected value" }
  ```

---

### Scenario 2: <Error Case Description>

**GIVEN:**
- `EventName` with:
  ```json
  { "attribute": "value that triggers error" }
  ```

**WHEN:**
- `CommandName` with:
  ```json
  { "attribute": "value" }
  ```

**THEN:**
- Error: "Description of expected error"

---

## Slice: <Next Slice Name>

### Scenario 1: ...
