---
name: reflect
description: Review the current session for durable lessons (corrections the user made, mistakes repeated, steps that took too long) and turn each into a concrete edit to a vstack skill, the project's AGENTS.md, or a lint rule, test, or script. Use when the user says reflect, or after a long task to capture what was learned.
---

# Reflect

Mine this session for lessons that should change how future agents work, then route each one to the place that will enforce it.

Skip it when the session was trivial or everything went to plan. One-offs are not lessons.

## 1. Collect candidates

Review the conversation and list:

- Every time the user corrected you, redirected you, or rejected a tool call or change.
- Mistakes you made more than once, or that a skill should have prevented.
- Steps that took much longer than they should have, and why (a missing command, a wrong assumption about the repo, a flaky check).
- Facts about the repo you had to discover the hard way: the real test command, a required env var, a build quirk.

If your harness can spawn subagents, have two independent reviewers read the session (one for judgment and process mistakes, one for tooling and repo facts) and merge their lists. Otherwise do one careful pass yourself.

## 2. Route each lesson

For each candidate, pick the strongest place it can live, per [encode-lessons-in-structure](../vstack-principles/principles/encode-lessons-in-structure.md):

1. **Structure in the project.** A type, a lint rule, a test, or a project script that makes the mistake impossible or fail loudly.
2. **The project's `AGENTS.md`** (or `CLAUDE.md`), for repo facts and conventions that apply to this repo only.
3. **A vstack skill edit**, for lessons that apply across projects. Name the skill and the exact line to add or change.
4. **Drop it**, if it is a one-off. Say why.

## 3. Present and wait

Show the list as a table: lesson, evidence from the session, where it goes, and the proposed edit. Skill and instruction edits affect every future session, so wait for the user to approve which ones to apply.

## 4. Apply

Apply the approved edits. For vstack skill edits, follow the authoring playbook in **vstack-mode** and run `scripts/validate.mjs` in the vstack repo.

**Reply:** edits applied (path and one line each), structural fixes added, and lessons dropped with the reason.
