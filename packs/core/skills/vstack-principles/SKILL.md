---
name: vstack-principles
description: Language-agnostic engineering principles. Read the index when designing types or data shapes, debugging, refactoring, sizing a diff, writing tests, measuring performance, or deciding whether something is done. Each entry links to the full rule.
---

# vstack principles

Read the full file for any principle you apply. Each entry names when it applies. When you cite a principle in a reply, name the choice it changed. Cite only principles whose file you read in this session.

## Core

- **Laziness protocol** ([laziness-protocol.md](principles/laziness-protocol.md)). Refactoring, sizing a diff, or tempted to add abstractions, layers, or signal threading. Bias to deletion and the smallest change that solves the problem.
- **Foundational thinking** ([foundational-thinking.md](principles/foundational-thinking.md)). Before writing logic. Core types and data structures first, scaffold before features, ask what concurrent actors share.
- **Redesign from first principles** ([redesign-from-first-principles.md](principles/redesign-from-first-principles.md)). Integrating a new requirement into an existing design. Redesign as if it had been there from day one.
- **Subtract before you add** ([subtract-before-you-add.md](principles/subtract-before-you-add.md)). Sequencing an addition, refactor, or rewrite. Remove dead weight first.
- **Minimize reader load** ([minimize-reader-load.md](principles/minimize-reader-load.md)). Code that is hard to trace. Count layers and hidden state, collapse one-caller wrappers, shrink mutable scope.
- **Experience first** ([experience-first.md](principles/experience-first.md)). Product, UX, or scope tradeoffs. Choose user delight over implementation convenience. The user may be the colleague who imports your library or runs your CLI.
- **Exhaust the design space** ([exhaust-the-design-space.md](principles/exhaust-the-design-space.md)). A novel interaction or architecture with no precedent in the repo. Build two or three competing sketches before committing.
- **Build the lever** ([build-the-lever.md](principles/build-the-lever.md)). Any non-trivial edit, migration, analysis, or check. Write the codemod, script, or generator instead of working by hand.

## Architecture

- **Model the domain** ([model-the-domain.md](principles/model-the-domain.md)). Stateful logic, heavy branching, or a shape assumption repeated across files. Use a state machine, discriminated union, table, or reducer instead of scattered conditionals.
- **Boundary discipline** ([boundary-discipline.md](principles/boundary-discipline.md)). Validation, error handling, process messages, CLI args, network responses. Guard at boundaries, trust internal types, keep logic pure.
- **Type system discipline** ([type-system-discipline.md](principles/type-system-discipline.md)). Designing types or signatures. Make illegal states unrepresentable, brand primitives, parse external data, never lie to the compiler. A stack pack's language-rules skill has the syntax.
- **Make operations idempotent** ([make-operations-idempotent.md](principles/make-operations-idempotent.md)). Commands, startup and shutdown, migrations, anything that can crash halfway and run again.
- **Migrate callers then delete legacy APIs** ([migrate-callers-then-delete-legacy-apis.md](principles/migrate-callers-then-delete-legacy-apis.md)). A new internal API while old callers exist, or a planned migration. Migrate and delete in one wave. Published packages are the exception.
- **Separate before serializing shared state** ([separate-before-serializing-shared-state.md](principles/separate-before-serializing-shared-state.md)). Several actors (windows, workers, processes, threads, async tasks) might write the same file, key, or store. Remove the sharing first.

## Verification

- **Prove it works** ([prove-it-works.md](principles/prove-it-works.md)). Before you say done. Check the real artifact: run the app, read the value, inspect the diff. "It compiles" is not proof.
- **Fix root causes** ([fix-root-causes.md](principles/fix-root-causes.md)). Debugging. Reproduce first, ask why until you reach the cause, no silencing guards. When two fixes fail the same way, attack the shared premise.
- **Sequence verifiable units** ([sequence-verifiable-units.md](principles/sequence-verifiable-units.md)). Multi-step work and commit order. Small units, each ending in a check. Failing test first, fix on top.
- **Test behavior, not implementation** ([test-behavior-not-implementation.md](principles/test-behavior-not-implementation.md)). Writing, changing, or keeping a test. Assert a literal observed result. If the test still passes when every import returns `undefined`, rewrite or delete it.
- **Explain the number** ([explain-the-number.md](principles/explain-the-number.md)). Before you trust or report a measured number. Name the limiter and rule out that it measured something else.

## Working as an agent

- **Guard the context window** ([guard-the-context-window.md](principles/guard-the-context-window.md)). Large outputs, long files, repeated reads. Route bulk to subagents or scripts and keep summaries.
- **Never block on the human** ([never-block-on-the-human.md](principles/never-block-on-the-human.md)). Tempted to ask "should I do X?" on reversible work. Do it, show the result, let the human correct course.
- **Encode lessons in structure** ([encode-lessons-in-structure.md](principles/encode-lessons-in-structure.md)). You catch yourself writing the same instruction twice. Make it a lint rule, a type, a test, or a script instead.
