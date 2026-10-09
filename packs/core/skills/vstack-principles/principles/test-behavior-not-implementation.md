# Test Behavior, Not Implementation

A test calls the code the way its users do and asserts the result they observe against a literal expected value. A test that asserts which calls the code made, or restates a constant the code contains, does neither.

The check: before you keep a test, ask whether it would still pass if every function it imports returned an empty value. If yes, it observes no behavior and cannot fail for a defect. Rewrite the assertion or delete the test.

**Why:** A test that cannot fail for a defect costs CI time and review attention and catches nothing. A constant pin also fails when someone edits the constant or the prompt it restates, so it prevents that edit.

**Five shapes that still pass when every imported function returns an empty value:**

- **Weak or no assertion.** No assertion at all, or only asserts defined-ness, truthiness, no-throw, instance-of, or greater-than.
- **Mock or absence only.** Only asserts the mock was (or was not) called, the result was empty or absent, or the value was merely not one wrong value.
- **Self-referential.** The expected value comes from the code under test: asserting `f(a)` equals `f(a)`, or a parsed URL equals the builder's own output for the same input.
- **Constant pin.** The assertion restates a hand-maintained constant, config default, table row, or prompt string: a limits constant equals its literal, a prompt contains a stock phrase.
- **Fixture asserts fixture.** The assertion reads data the test built or a value computed in setup, and the subject never runs inside the body.

**The fix:** call the subject inside the test body with one concrete input and assert the literal output or the observable effect, such as calling a slug function with a mixed-case string and asserting the exact slug. For an absence, assert the presence on the other input in the same test. For a constant, test the mechanism that reads it with one input instead of restating the value. For a mock, assert the payload it received or the state after the call, not that it was called. When no such assertion exists, delete the test.

**Keep** a test of a relation across a table's rows (a key present in two tables, a parent that exists), and a compile-time type check.
