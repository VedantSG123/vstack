# Feature

**You own the design.**

1. **Ground.** Run the **how** skill over the code the feature touches. Find the nearest existing feature of the same kind and note its pattern.
2. **Name the data shape.** Write the core types before any logic, per [foundational-thinking](../../vstack-principles/principles/foundational-thinking.md) and [model-the-domain](../../vstack-principles/principles/model-the-domain.md). Choose the structure: a discriminated union over flag bags, a state machine over scattered booleans, a table over a growing `if` chain.
3. **Design the boundary.** If the feature crosses a module, process, or package boundary, run the **architect** skill. Write the caller's usage first. Surface-specific boundaries to settle now:
   - Desktop or multi-process app: which process owns the logic, the messages between processes, and their payload schemas.
   - CLI: the command, flags, defaults, exit codes, and what goes to stdout versus stderr.
   - Frontend: where the state lives (local, lifted, store, URL, server cache), and the loading, empty, and error states.
   - Library: the exported signature and whether it is a breaking change.
4. **Plan the work.** Write a short checkpoint in the todo list:
   - Blocking first steps (types, schema, shared module).
   - Independent pieces that could run in parallel, and which files each touches.
   - Shared state that two pieces would both write. Split it, or do those pieces in sequence.
5. **Implement in small units.** Each unit ends with the typecheck and the relevant tests green, per [sequence-verifiable-units](../../vstack-principles/principles/sequence-verifiable-units.md). Write tests per [test-behavior-not-implementation](../../vstack-principles/principles/test-behavior-not-implementation.md). If you delegate to a subagent, give it the file paths, the named data shape, and the success check.
6. **Verify on the real surface** with the verify skill. Drive the feature the way a user would, including the error path. For a library, build and install the package the way a consumer would, in a temp directory, and call the new API from a scratch consumer.
7. **Simplify.** Reread the diff per [laziness-protocol](../../vstack-principles/principles/laziness-protocol.md). Delete anything the feature does not need.
8. Run the [committing](committing.md) playbook.

**Reply:** what you built and who it is for, the data shape and why you chose it, the verification evidence, and open decisions. Use a table for design alternatives you considered.
