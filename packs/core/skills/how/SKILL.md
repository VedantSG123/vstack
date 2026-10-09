---
name: how
description: Explain how a part of the codebase works before changing it. Use for "how does X work", walkthroughs, onboarding onto a subsystem, and placement questions like "where should this live" or "which module owns this". Produces an architectural explanation with file citations, not annotated source.
---

# How

Answer "how does X work?" at the level a senior engineer needs to start working in the code: enough for a real mental model, not a line-by-line tour.

## 1. Size the question

- **Simple** (one module, one function, a narrow question). Explore and explain in one pass yourself.
- **Complex** (a subsystem across many files or packages, a cross-cutting flow, a whole-app overview). Split it into two to four exploration angles, each a distinct slice. Good angles: the entry point and wiring, the data model and state, the I/O boundary (network, IPC, filesystem, argv), and the build and runtime config. If your harness can spawn subagents, give each angle to a read-only subagent and have it return findings with `file:line` citations. Otherwise explore the angles yourself, one after another.

If the scope is ambiguous, state your reading of it and proceed. When in doubt, treat it as simple.

## 2. Trace, don't skim

- Start from the entry the user touches: a route, a component, a CLI command, a message handler, an exported function. Follow the call path to the effect.
- Read the code, not just names. A function called `validate` might also write to disk.
- Note where state lives and who writes it.
- In a multi-process app, label each step with the process or thread it runs in.
- Check the build config (path aliases, module resolution, package entry points) when imports do not resolve the way they look.

## 3. Write the explanation

Use these sections and drop any that do not apply:

- **Overview.** One or two paragraphs. What it is, what it does, why it exists.
- **Key concepts.** The types, modules, and abstractions the reader needs, briefly defined.
- **How it works.** The longest section. Walk the flow: what triggers it, what happens step by step, where data goes, where the decisions are. Use prose and cite files and functions. Add a mermaid diagram only when several components talk to each other or data changes shape through stages.
- **Where things live.** A short file map of the places someone would start.
- **Gotchas.** Surprising behavior, traps, history. Skip it if there is nothing.

Write concretely. Say "`useSession` calls `refreshToken()` in `src/auth/client.ts:42`", not "the hook delegates to the client". Never invent a file, function, or caller. If something is unclear after reading, say so.
