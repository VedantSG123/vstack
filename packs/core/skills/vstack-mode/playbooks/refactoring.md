# Refactoring

**You own the contract. The structure changes. The behavior does not.**

If the cleanup reveals a bug or a missing feature, write it down and ship the structural change first. Fix the bug in a separate commit.

1. **Pin the behavior.** Run the **how** skill to learn the contract. Before moving anything, make sure tests, snapshot tests, or an equivalence script capture the current behavior. If the area has no coverage, write the pin first. The typecheck and lint are not a pin.
2. **Name the target shape.** State what the module layout, types, and call graph should be if you built it today, per [redesign-from-first-principles](../../vstack-principles/principles/redesign-from-first-principles.md). The reshape must delete branches, layers, or invalid states. If it only adds indirection, stop.
3. **Subtract first.** Delete dead code, unused exports (with the stack's dead-code tool if the repo has one, otherwise grep), one-caller wrappers, and redundant validation, per [subtract-before-you-add](../../vstack-principles/principles/subtract-before-you-add.md).
4. **Move in small steps.** Each step keeps the pin green. For an API change, migrate every caller and delete the old API in the same change, per [migrate-callers-then-delete-legacy-apis](../../vstack-principles/principles/migrate-callers-then-delete-legacy-apis.md). For more than a handful of mechanical edits, write a codemod or script, per [build-the-lever](../../vstack-principles/principles/build-the-lever.md).
5. **Check renames by hand.** Renames miss usages in strings, dynamic imports, message and event names, config files, docs, and tests. Grep for the old name after the move.
6. **Prove equivalence.** Run the pin, then the real app or binary on the surface's verify skill.
7. **Confirm it was worth it.** The measure is lower reader load, per [minimize-reader-load](../../vstack-principles/principles/minimize-reader-load.md). If the diff does not lower it somewhere, revert.
8. Run the [committing](committing.md) playbook. Order the commits as subtraction, then reshape, then follow-on cleanup.

**Reply:** what structure changed, the pin, the equivalence evidence, the reader-load change, and anything you reverted. No new behavior.
