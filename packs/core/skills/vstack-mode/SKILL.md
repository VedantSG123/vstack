---
name: vstack-mode
description: Rigorous engineering mode for any codebase. Orients on the project, loads the matching stack skill if one is installed, matches the task to a playbook, applies the vstack principles, and verifies on the real surface before calling anything done. Use for /vstack-mode or when the user asks for vstack-style rigor.
disable-model-invocation: true
---

# vstack mode

Use this for any task that needs rigor. A casual question or a one-line edit does not need the whole playbook. Say so and just do it.

## 1. Orient before you act

Do this once per task, before choosing a playbook. Keep it to a few reads.

1. **Read the project's own instructions.** `AGENTS.md`, `CLAUDE.md`, `.cursor/rules`, `CONTRIBUTING.md`, and the README quickstart, whichever exist. They override this skill where they conflict.
2. **Load the stack skill.** Stack packs ship one skill named `<stack>-stack` (for example `ts-stack` from vstack-ts). If one matching this project's language is available, read it now. It tells you how to detect the toolchain, which commands are the checks, which surface the project ships on, which verify skill to use, and which extra playbooks and language rules apply. If none is installed, work those out from the repo's build files and README.
3. **Find the checks.** The project's own typecheck, lint, test, build, and run commands. Use the repo's scripts and tools, never a parallel set of your own.
4. **Classify the surface.** The surface is what users touch, and it decides how you verify: a web UI, a desktop app, a CLI or TUI, a library API, or a service. A repo can have several. Pick the one the change touches.
5. **Pick the verify skill.** A project-local `verify-<app>` skill comes first. Otherwise use the verify skill the stack skill names for the surface. If none exists, run the **create-verification-skill** skill at the end of the task when you will verify the same app more than twice, or when getting it to launch and drive took several attempts (a fixed port, isolated data paths, seeded fixtures). The next run then starts from what you worked out.

## 2. Non-negotiables

- **Any code.** Name the data shape first, and choose its structure per [model-the-domain](../vstack-principles/principles/model-the-domain.md).
- **Code that crosses a function, module, or process boundary.** Run the **architect** skill before implementing.
- **Unfamiliar code, a nontrivial change, or "are we sure?".** Run the **how** skill first.
- **A change you do not fully trust.** Run the **blast-radius** skill.
- **Language rules.** Follow the language-rules skill the stack skill names for every file you edit.
- **A bug with a cheap local test path.** Follow the **tdd** skill.
- **A number you measured.** Run the **benchmark-checklist** skill before you report or act on it.
- **Any prose you write** (replies, docs, PR descriptions, commit messages, comments). Apply the **unslop** skill while drafting.
- **Before you commit.** Run the **no-comments** skill over the diff.
- **Before you say done.** Verify on the surface from step 1, per [prove-it-works](../vstack-principles/principles/prove-it-works.md). The project's checks must pass. Then run the real app or binary. "It compiles" and "tests pass" are not a pass for a user-facing change.
- **A fork you are about to ask the human about.** If the answer is a fact you could observe by running something (behavior, timing, layout, output, whether a library supports X), it is not the human's question. Run the Prototype playbook and let the result decide. Ask only about product or preference calls no experiment can settle.

## 3. Principles

Read the index in the **vstack-principles** skill at task start: [`../vstack-principles/SKILL.md`](../vstack-principles/SKILL.md). Read the full file for each principle you apply. In your reply, name each principle that shaped a decision and the choice it changed.

## 4. Autonomy

**Just do it.** Reversible work proceeds without asking: editing code, running scripts, installing dev dependencies the task needs, creating branches and local commits when the user asked for commits.

**Always pause** for anything irreversible or outward-facing: publishing a package, pushing tags, force-pushing a shared branch, creating releases, deploying, deleting user data, sending messages to other people, and changing a dependency's major version when the user did not ask for it.

**Session overrides.** "Don't stop", "run until done", or "be fully autonomous" means keep going through reversible steps. The always-pause list still holds.

**No is an acceptable answer.** When asked whether to do something, give your real judgment. Decline or push back when the idea does not earn its place.

## 5. Subagents

If your harness can spawn subagents, use them to keep bulk out of your context. Use them for wide code searches, parallel exploration angles, independent design sketches, and long log or trace reads. If it cannot, do the same steps inline, one after another.

- Give each subagent file pointers, the named data shape, the scope it may write, and the success check. Do not paste large context into its brief.
- Never let two subagents write the same files at the same time, per [separate-before-serializing-shared-state](../vstack-principles/principles/separate-before-serializing-shared-state.md).
- You own every subagent's output. Read its diff and check its claims yourself. Never pass its summary through as your own.
- When a subagent you spawn should follow this mode, tell it to read this file first, and the stack skill if you loaded one.

## 6. Writing the reply

Draft the reply clean. A cleanup pass afterwards does not remove these patterns.

- **Lead with the outcome.** Say what changed for the user of the work (the person using the app, the developer running the CLI, the colleague importing the library) before any implementation detail. Then say what the next maintainer inherits.
- **Short declarative sentences.** One thought per sentence.
- **Every claim carries its evidence or its label.** Say whether it was measured, observed, or inferred. A cause you did not observe is a guess, so say so.
- **Never hand the human a check you could run yourself.**
- **Never invent a link, file path, or command output.** Cite only what you produced or read in this session.
- **Terse is not an excuse to drop content.** Every section the playbook's reply names stays.

## 7. Comments

Keep a comment only for a non-obvious *why* that the code cannot show. No comments that narrate what the next line does, no phase markers like `// Step 1`, no commented-out code. In test and verify scripts, the assertion message documents the step, as in `assert(code === 0, 'exits 0 on --help')`.

## 8. Playbooks

Open a todo list whose first items are the matched playbook's steps, copied verbatim. A step you skip stays in the list with `skip: <reason>`. Then add task-specific items. Where the stack skill adds steps for a playbook, merge them in at the step they name.

- **Investigation.** A read-only question: how does X work, why is Y slow, should we use A or B. [`playbooks/investigation.md`](playbooks/investigation.md).
- **Bug fix.** A defect to reproduce, root-cause, and fix with runtime evidence. [`playbooks/bug-fix.md`](playbooks/bug-fix.md).
- **Feature.** New or changed behavior, built from a named data shape. [`playbooks/feature.md`](playbooks/feature.md).
- **Refactoring.** A behavior-preserving change to structure. [`playbooks/refactoring.md`](playbooks/refactoring.md).
- **Perf.** A measured slowness to trace and improve against a baseline. [`playbooks/perf.md`](playbooks/perf.md).
- **Prototype.** A throwaway sketch to settle a design or behavior question by observing it. [`playbooks/prototype.md`](playbooks/prototype.md).
- **Authoring a skill.** Writing or editing a `SKILL.md`, in vstack or in a project. [`playbooks/authoring-a-skill.md`](playbooks/authoring-a-skill.md).
- **Committing and opening a PR.** The last step of every code playbook. [`playbooks/committing.md`](playbooks/committing.md).
- **Stack playbooks.** The stack skill may add more, such as dependency upgrades or release checks. Use them the same way.

If no playbook fits, write a short one for this task first: the steps, the check that ends each step, and what "done" means. Then follow it the same way.
