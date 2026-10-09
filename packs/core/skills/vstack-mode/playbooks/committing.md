# Committing and opening a PR

The last step of every code playbook. Commit only when the user asked for commits or the project's instructions say to.

1. **Run the checks** one last time: typecheck, lint, tests, and the surface verification.
2. **Run the no-comments skill** over the diff.
3. **Review your own diff** with `git diff`. Remove debug logging, stray files, unrelated formatting changes, and anything the task did not need.
4. **Commit in small, ordered commits.** Each commit builds and passes on its own and the sequence tells the story: the failing test before the fix, the subtraction before the reshape. Amend when a fix belongs in the commit you just made.
5. **Titles use Conventional Commits.** `type(scope): subject`, with `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, or `build` as the type. Short imperative subject, no trailing period. Use `!` or a `BREAKING CHANGE:` footer for breaking changes to a published package.
6. **PR description** (when opening one). A briefing a reviewer reads in under a minute, written with the **unslop** skill. Use `##` sections in this order and drop any with nothing to say:
   - `## Why`. The problem and approach in one to three sentences.
   - `## What changed`. One to three bullets.
   - `## Scope`. What it covers and what it deliberately leaves out.
   - `## Risk`. Who or what it touches and why that is safe.
   - `## Verification`. One to three bullets, each naming a real run and its outcome. For perf, one `before → after` number with its unit.
   Attach a screenshot or recording when it proves a UI claim.
7. **Open PRs ready for review, not as drafts,** unless the user asks for a draft. Use `gh` if available. Never force-push a shared branch without asking.
