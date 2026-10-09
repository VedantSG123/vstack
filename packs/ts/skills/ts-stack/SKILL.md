---
name: ts-stack
description: TypeScript and JavaScript stack knowledge for vstack (web frontends, Electron desktop apps, Node CLIs, libraries, Node services). Detects the package manager, checks, and surface, names the verify skill to use, and adds JS/TS-specific steps, root causes, and boundaries to the core playbooks. Read at the start of any task in a repo with a package.json.
---

# TypeScript and JavaScript stack

The stack skill for vstack-ts. The **vstack-mode** skill reads this in its orient step. It also stands alone: read it before working in any repo that has a `package.json`.

## Orient

1. **Package manager.** Detect it from the lockfile and use only that one. `pnpm-lock.yaml` means pnpm, `yarn.lock` means yarn, `bun.lock` or `bun.lockb` means bun, `package-lock.json` means npm. Never create a second lockfile. Commit lockfile changes with the `package.json` change.
2. **Checks.** Read `package.json` scripts and use the repo's own `typecheck`, `lint`, `test`, `build`, and `dev`. If no typecheck script exists, run `tsc --noEmit -p <tsconfig>`. In a monorepo, find the workspace that owns the change and run its scripts.
3. **Surface and verify skill.** A repo can have more than one surface. Pick the one the change touches.

| Signal | Surface | Verify with |
|---|---|---|
| `electron` in dependencies, an `electron-builder`, `electron-forge`, or `electron-vite` config | Electron app | **verify-electron** skill |
| `bin` in `package.json`, or a CLI framework (commander, yargs, citty, clipanion, oclif, cac, ink) | CLI or TUI | **verify-cli** skill |
| vite, next, remix, react-router, astro, sveltekit, nuxt, webpack dev server, or an `index.html` entry | Web frontend | **verify-web** skill |
| `exports` or `main` with no app entry and no `bin` | Library | Tests plus a consumer check (see Feature below) |
| An HTTP framework (express, fastify, hono, koa) | Node service | Start it and call the real endpoints with `curl` |

4. **Language rules.** Follow the **typescript-best-practices** skill for every `.ts`, `.tsx`, `.mts`, or `.cts` edit. In plain JavaScript files, follow the same rules where they do not need type syntax, and respect any JSDoc types and `// @ts-check` already there.

## Additions to the core playbooks

Merge these into the matching vstack-mode playbook at the step named.

- **Bug fix, step 2.** Check the root causes listed below early.
- **Bug fix and TDD, test setup.** Look for `vitest.config.*`, `jest.config.*`, `playwright.config.*`, `cypress.config.*`, `node --test` in a script, or `bun test`. Run one test: `vitest run <path> -t <name>`, `jest <path> -t <name>`, `node --test <path>`, `playwright test <path> -g <name>`. Use `vi.useFakeTimers()` or `jest.useFakeTimers()` for timing bugs.
- **Feature, step 3.** For Electron, settle which process owns the logic, the IPC channel names and payload schemas, and what the preload exposes, before writing logic. Use the typed IPC pattern in the **typescript-best-practices** skill.
- **Feature, step 6, libraries.** Run `npm pack` (or `pnpm pack`), install the tarball in a temp directory, and import it from a scratch consumer. Check both ESM and CommonJS if `exports` declares both.
- **Refactoring, step 3.** Find unused exports and files with `knip` if the repo has it. Otherwise grep, and remember that grep misses re-exports through `index.ts` barrels.
- **Refactoring, step 4.** For codemods, use `ts-morph` when the edit needs types, `jscodeshift` for syntax-only edits, or a plain script for text edits.
- **Perf, step 1.** Pick the measurement that matches the complaint:
  - Web: a Chrome performance trace or Lighthouse run of the production build, React Profiler for render cost, and the build output plus a bundle analyzer (`rollup-plugin-visualizer`, `source-map-explorer`) for bundle size.
  - Electron: time from launch to the first window's `ready-to-show`, `node --cpu-prof` on the main process, a DevTools trace in the renderer, and process memory from `app.getAppMetrics()`.
  - CLI: `hyperfine` over the built binary with realistic arguments, and `node --cpu-prof` for where time goes. Measure startup separately with `--version`.
  - Library: `tinybench` or `vitest bench` on realistic inputs.

## Extra playbooks

- **Dependency upgrade.** Bumping a framework, toolchain, or runtime (React, Electron, Vite, TypeScript, Node), or clearing outdated or vulnerable packages. [`playbooks/dependency-upgrade.md`](playbooks/dependency-upgrade.md).
- **Release check.** Proving an npm package, CLI, or Electron build is ready to publish, without publishing it. [`playbooks/release-check.md`](playbooks/release-check.md).

## Common root causes

Check these early when debugging JS/TS:

- An unawaited promise or a floating `.then()` that lets work finish after the caller moved on.
- A stale closure in a React effect, callback, or event listener that captured an old value.
- Two copies of one package in `node_modules` (check with `npm ls <pkg>` or `pnpm why <pkg>`). Singletons, `instanceof`, and React context break silently.
- ESM and CommonJS interop: a default export that arrives as `{ default: ... }`.
- A build-time value (`import.meta.env`, `process.env` inlined by the bundler) that differs from the runtime value.
- In Electron, code that runs in the wrong process, or a renderer reload that leaves main-process listeners registered twice.

## Boundaries

Where the boundary-discipline principle (in the **vstack-principles** skill) puts validation, for each kind of project:

| Project | Boundaries to guard |
|---|---|
| Frontend | `fetch` responses, URL and search params, `localStorage` and `sessionStorage`, `postMessage`, form input, third-party script globals. |
| Electron | Every IPC channel in both directions, the `contextBridge` API the preload exposes, files read from disk, data an older app version wrote under `userData`, deep links and protocol handlers, command-line switches. The main process treats the renderer as untrusted. |
| CLI | `argv`, environment variables, config files, stdin, the filesystem, the terminal (TTY or pipe), network responses. |
| Library | The exported functions. Validate what callers pass only when the type system cannot (runtime JS callers, untyped JSON). |

Parse each boundary with one schema (zod, valibot, or whatever the repo already uses) and infer the TypeScript type from it.

## Where grep stops

Extra places to look when running the **blast-radius** skill on JS/TS code:

- String-built IPC channel names, `obj[key]` access, dynamic `import()`, CSS class names built at runtime.
- JSON in `localStorage`, files under Electron's `userData`, and cache entries written by an older version.
- React effect cleanup and unmount order, and window close and app quit order in Electron.
- Paths that resolve differently in a packaged Electron app or an installed CLI: `__dirname`, `import.meta.url`, and files inside `asar`.
- The installed library's source in `node_modules`, at the exact version, plus any `patch-package` patch.
