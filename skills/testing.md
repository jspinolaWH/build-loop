---
name: testing
description: Testing conventions and coverage rules for WasteHero platform. Loaded by bl-design when a requirement includes tests in its skills list.
---

# Testing Conventions

> **For the team:** Fill in each section with your actual testing standards. The build agent reads this file when writing tests. Be explicit — the agent will follow exactly what is written here.

---

## What Must Always Be Tested

<!--
Example:
- Every new service method must have at least one unit test
- Every new API endpoint must have at least one integration test
- Every new React component with user interaction must have a component test
- Business rule enforcement must have a test for both the passing and failing case
-->

[FILL IN]

---

## Backend Unit Tests

<!--
Example:
- Framework: JUnit 5 + Mockito
- Test class naming: XxxServiceTest, XxxRepositoryTest
- Location: src/test/java/[same package as class under test]
- Mock all dependencies — never call a real database in a unit test
- Test method naming: should_[expected result]_when_[condition]
- Arrange-Act-Assert pattern, one assertion concept per test
-->

[FILL IN]

---

## Backend Integration Tests

<!--
Example:
- Framework: Spring Boot Test + Testcontainers (PostgreSQL)
- Test class naming: XxxControllerIT
- Location: src/test/java/integration/
- Use @SpringBootTest(webEnvironment = RANDOM_PORT)
- Always test: 200 success case, 400 bad input, 401 unauthorized, 404 not found
- Clean up test data after each test using @Transactional or explicit delete
-->

[FILL IN]

---

## Frontend Component Tests

<!--
Example:
- Framework: Vitest + React Testing Library
- Test file naming: ComponentName.test.tsx, co-located with the component
- Test what the user sees and does, not implementation details
- Always test: renders without crashing, user interactions, loading states, error states
- Mock API calls with msw or vi.mock
- Never test CSS classes or internal state directly
-->

[FILL IN]

---

## Frontend E2E Tests

<!--
Example:
- Framework: Playwright
- Location: e2e/
- Only for critical user journeys (not every feature)
- Use data-testid attributes for selectors, never CSS classes or text that might change
-->

[FILL IN]

---

## Coverage Thresholds

<!--
Example:
- New service classes: minimum 80% line coverage
- New controller endpoints: 100% of HTTP status cases covered
- New React components: minimum 70% line coverage
- No coverage requirement for DTOs, enums, or pure config classes
-->

[FILL IN]

---

## What NOT to Test

<!--
Example:
- Generated code (Lombok getters/setters, JPA-generated queries)
- Framework boilerplate (Spring configuration beans)
- Pure data classes / DTOs with no logic
- Third-party library internals
-->

[FILL IN]
