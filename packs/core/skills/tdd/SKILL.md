---
name: tdd
description: Write a failing regression test before fixing a bug, then make it pass. Use when the user asks for TDD, a failing test, or a regression test, or when a bug has an obvious, cheap local test path. Skip when the only test would be expensive, flaky, or mostly mocks.
---

# TDD bug fix

Make the broken behavior executable before changing production code. The goal is one focused test that fails before the fix and passes after it.

Do not force a test when it would be impractical. If the only test needs broad harness setup, brittle mocks, a slow end-to-end run for a small fix, or production-only state, use the closest executable check instead.

## Find the test setup

Use what the repo already uses. The stack skill says where to look. Put the test next to the existing tests for that code and copy their style. Run one file or one test name, not the whole suite.

## Workflow

1. **Understand the bug.** The intended behavior, the current behavior, and the smallest observable reproduction.
2. **Pick the narrowest check.** A unit test for a pure function, a component test for UI logic, a test that spawns the built CLI for argument or output bugs, an end-to-end test for a flow that only breaks in the running app.
3. **Write the failing test.** Call the code the way users do and assert a literal expected value, per the [test-behavior-not-implementation](../vstack-principles/principles/test-behavior-not-implementation.md) principle.
4. **Run it and watch it fail for the right reason.** If it passes, or fails for an unrelated reason (import error, missing fixture), fix the test before touching the implementation.
5. **Fix the bug** with the smallest production change.
6. **Run the test again** and confirm it passes. Run the neighboring tests too.

## If a failing test is impractical

Use a targeted script, a command that reproduces it, a browser or desktop-app automation run, or a log assertion. Prefer no new test over a bad one. A bad test mostly tests mocks, pins implementation details, depends on timing, or would be deleted right after the fix.

## Guardrails

- Do not change a test to match a wrong implementation.
- Do not weaken existing assertions unless the intended behavior changed, and say why.
- For a timing bug, use the test framework's fake timers or an injected clock rather than real sleeps.

## Report

Name the test, the failure it produced before the fix, and the passing run after. If you could not show a failure first, say why and name the check you used instead.
