---
name: test-writing
description: Write or modify unit and integration tests using small test cases, parameterized tests for input variations, and property-based testing when appropriate. Do not use for end-to-end tests.
---

# Test Writing

Use this skill when writing or modifying unit tests or integration tests.

Do not apply this skill to end-to-end tests.

## Rules

### Keep test cases small

- Use at most two assertions per test case.
- Do not combine independent conditions with logical operators such as `&&` or `||` inside an assertion.
- If more assertions are needed, split the behavior into separate test cases.

### Use parameterized tests for input variations

When testing the same behavior with multiple inputs, use the language or test framework's parameterized testing mechanism.

Do not use a `for` loop inside a test case to enumerate test inputs unless parameterized tests cannot reasonably express the case.

### Consider property-based testing

Always consider whether the behavior is better tested with property-based testing (PBT).

Prefer PBT when the expected behavior can be expressed as an invariant or property over a range of inputs.

Examples include:

- round-trip properties
- idempotence
- invariants
- ordering properties
- boundary-heavy input spaces
- behavior that should hold for many arbitrary inputs

If PBT is appropriate:

- implement the test as a property-based test;
- install an appropriate PBT library if necessary.

If concrete examples communicate the behavior more clearly than a general property, use ordinary example-based tests.

## Scope

This skill applies to:

- unit tests
- integration tests

It does not apply to end-to-end tests.
