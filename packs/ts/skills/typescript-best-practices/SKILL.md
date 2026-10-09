---
name: typescript-best-practices
description: TypeScript rules for modeling types, narrowing, validation at boundaries (fetch, Electron IPC, CLI argv), and avoiding casts. Use when reading or editing any .ts, .tsx, .mts, or .cts file.
---

# TypeScript best practices

These rules apply the type-system-discipline and boundary-discipline principles from the **vstack-principles** skill. The repo's own lint config and `tsconfig` win where they disagree.

| Rule | Summary |
|------|---------|
| Discriminated unions | Model variants with a `kind` literal so impossible states can't exist. No bags of optional fields. |
| Branded types | Brand primitives with `& { readonly __brand: "X" }` so a `UserId` can't be passed as a `ProjectId`. Validate once at the boundary. |
| Constructive modeling | Build the shape so the illegal value can't be constructed. `[T, ...T[]]` for non-empty, `start` plus `duration` for a range. |
| Simplest total type | Keep `T[]` while every operation stays total. Strengthen only where the loose type forces `!`, a cast, or a "should never happen" throw. |
| `unknown` over `any` | External data is `unknown` until parsed. |
| Schemas before guards | Use the repo's schema library (zod, valibot, arktype, typebox) and infer the type from the schema. Don't add a new library for one guard. |
| No `as` casts | Every `as` is a runtime crash waiting. Cast only after validation. `as const` is fine. |
| Narrowing order | Discriminant switch, then `in`, then `typeof`/`instanceof`, then a type guard, then `as`. |
| Honest type guards | A guard must verify its claim. A lying guard is worse than `as`. Name it `isX` or `hasX`. |
| Exhaustiveness | `const _exhaustive: never = x;` in default arms, so a new variant fails the build. |
| `satisfies` over `as` | Checks the value without widening its literal types. |
| Boundary validation | Parse where data crosses in: fetch, IPC, argv, env, files, storage. Trust types inside. |
| Derived types | Reach for `Pick`, `Omit`, `Parameters`, `ReturnType`, `Awaited`, `typeof`, and generated schema types before writing a new interface. |
| Object args | Pass an object when a function takes several same-typed arguments. Skip it on hot paths. |
| Results for expected failures | Throw for bugs. Return a discriminated `Result` when the caller must handle the failure. |
| No floating promises | Await, return, or explicitly `void` every promise. Unhandled rejections hide bugs. |
| Real tests | Don't mock what you can run. Mock only what you can't run locally. |
| No `console.log` in shipped code | Use the project's logger. A CLI writes results to stdout and diagnostics to stderr. |

Examples for each rule, plus typed Electron IPC and CLI argv parsing: [references/patterns.md](references/patterns.md).
