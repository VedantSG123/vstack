# Migrate Callers Then Delete Legacy APIs

When we decide a new API is the right design, migrate callers and remove the old API in the same refactor wave instead of preserving compatibility layers.

**Rule:**
- Do not keep legacy API paths only because internal callers still exist
- Inventory callers, migrate them, and delete the old API immediately
- Treat temporary adapters as exceptional and time-boxed, not default architecture
- Update tests to assert the new contract, and delete tests that only protect pre-refactor implementation details

**When this applies:**
- No external users depend on backward compatibility
- The project can absorb coordinated breaking changes
- The new API is part of a simplification or refactor initiative

Keeping both old and new APIs creates dual-path complexity, slows cleanup, and makes the codebase feel append-only.

**Converge on the end state.** In a planned rewrite or migration, optimize for the verified end state, not for keeping every intermediate step perfectly stable. Intermediate breakage is fine when it is planned, scoped to declared phases, and reversible. Keep high-signal checks on the areas you are touching, and require the full type check, test suite, and a run of the real app at the end.

**Exception: published packages.** When the code is a library or CLI that other people install, its exported API, flags, and output format are a public contract. Deprecate first, ship the replacement, and remove the old path only in a major version.
