# Dependency upgrade

**You own the compatibility story.** An upgrade is done when the app runs the same on the new version, not when the install succeeds.

1. **Inventory.** Run the package manager's outdated command (`npm outdated`, `pnpm outdated`, `yarn outdated`, `bun outdated`) and its audit command if security is the reason. Record the current and target versions.
2. **Read the migration guide and changelog** for every major version you cross. List each breaking change and grep the repo for the APIs it affects. This list is your checklist.
3. **Check peer constraints.** Frameworks move in groups: React with react-dom and @types/react, Electron with its Node and Chromium versions and any native modules, Vite with its plugins, TypeScript with typescript-eslint, ESLint with its config format. Upgrade a group together.
4. **One group per commit.** Upgrade one group, run the typecheck, lint, tests, and build, and fix what breaks before the next group, per the sequence-verifiable-units principle in the **vstack-principles** skill. Use the upstream codemod when one exists.
5. **Surface-specific checks:**
   - Electron: rebuild native modules (`electron-rebuild` or the builder's install-app-deps), launch the app, check the main-process console for deprecation warnings, and check that `contextIsolation`, `sandbox`, and `nodeIntegration` defaults did not change under you.
   - CLI: check the `engines.node` field against the new dependencies' minimum Node version.
   - Frontend: run the production build and load it, not just the dev server.
   - Library: check that the public types still compile for a consumer on the oldest TypeScript version you support.
6. **Verify on the real surface** with the verify skill. Drive the features the changelog's breaking changes touch.
7. **Never mix lockfiles.** Commit the lockfile change with the `package.json` change.
8. Run the committing playbook from the **vstack-mode** skill.

A major upgrade the user did not ask for needs their approval first (see Autonomy in the **vstack-mode** skill).

**Reply:** the versions before and after, each breaking change and how you handled it, what you verified on the real surface, and anything you deferred.
