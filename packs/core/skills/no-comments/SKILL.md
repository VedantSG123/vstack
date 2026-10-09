---
name: no-comments
description: Review the comments in a diff and delete the ones that narrate, apologize, or hide a workaround, then fix the code the worst ones were covering for. Use before committing or opening a PR, or for "clean up comments".
---

# No comments

Comments that explain *what* the code does go stale and hide unclear code. Comments that justify a workaround are a confession. Remove both.

## Scope

The files or diff the caller names. Otherwise the current diff against the base branch (`git diff main...HEAD` plus the working tree).

## Keep only these

- License or legal headers.
- Behavior forced by something outside our control (a browser bug, a platform quirk, an upstream library bug, a protocol), with a link to the issue when one exists.
- Doc comments that define a public API contract: exported functions of a library, a CLI's command help.
- `// prettier-ignore`, and lint suppressions for rules that are style-only.
- Links to an issue or design doc that explains a constraint the code cannot express.

If you are not sure a comment fits a keep rule, delete it.

## Delete

- Narration (`// loop over users`), section banners, and phase markers.
- Commented-out code. Git has it.
- `TODO` without an owner or issue link. Either do it, file it, or delete it.
- Justifications of our own surprising code. Delete the comment and fix the code instead: rename the symbol, extract a well-named function, tighten a type, or restructure so the behavior is obvious. If that fix is too big for the current change, delete the comment and list the symbol as open work in the reply.

## Suppressions

Type-checker and linter suppressions (`@ts-ignore`, `eslint-disable`, `# type: ignore`, `# noqa`, `#[allow(...)]`, and the like) need a look at the rule they silence. If the rule catches real bugs (type errors, unhandled promises or errors, unsafe dynamic types), remove the suppression and fix the code. When one must stay, prefer the form that fails once the error goes away (such as `@ts-expect-error`), with a reason.

## Constraint comments

`do not remove`, `IMPORTANT`, `do not change this wording`. Read the surrounding code and check whether the claim is still true. If it is true and about something we cannot change, keep it. If it is about our own code, offer the cheapest enforcement instead (a type, a test, a lint rule) and delete the comment once that exists.

## Report

Files touched, comments deleted, comments kept and why, suppressions removed, and code you fixed or listed as open work.
