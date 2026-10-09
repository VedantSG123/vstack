---
name: architect
description: Sketch types, signatures, and module boundaries before writing implementation code, compare at least two structurally different designs, then implement against the chosen sketch. Use for /architect, "design this", or any change that crosses a module, process, or package boundary, where jumping to code would lock in the wrong shape.
---

# Architect

Design before implementing. Write the caller's usage first, derive the types from it, and compare whole-shape alternatives before writing logic. If implementation proves the sketch wrong, throw it out.

Open a todo list with the five phases.

## 1. Ground

Run the **how** skill over every system the new code touches. Naming a file is not grounding. Skip only for true greenfield code. If the design changes ownership or layering, read the git history of the current shape so its reasons become constraints, not guesses.

## 2. Sketch

Produce at least two structurally different candidates. Different whole shapes, not variations inside one shape. Typical axes: where state lives (component, store, server cache, URL, another process); which process or layer owns the logic; push versus pull; class versus module of functions versus a reducer; one generic module versus two specific ones.

For each candidate, write in a scratch file:

1. **Usage first.** The code a caller writes to use it. For a CLI, the command line and its output. For a multi-process app, both sides of the message.
2. **Types and signatures**, with `throw new Error('not implemented')` bodies.
3. **Module map.** Which files, what each exports, what each owns.
4. **Failure paths.** What each boundary does with bad input.

If your harness can spawn subagents, have independent subagents sketch the candidates so they do not anchor on each other.

## 3. Screen and choose

Screen each candidate against [references/design-red-flags.md](references/design-red-flags.md). Assume the next contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that compiles. Prefer the design where a change that looks right from one file is right for the whole repo. Prefer the design that hides more behind a smaller interface.

Pick one, or graft the best parts of several. Write down the choice and the rejected alternatives in two or three lines each. Proceed without a human checkpoint unless the user asked for one ("show me before implementing").

## 4. Implement against the sketch

Fill in the bodies. The sketch is the contract. A deviation is a signal: ask whether the sketch was wrong, a requirement was missed, or the implementation is overreaching. Mention deviations in the reply.

## 5. Scrap when the shape is wrong

Throw the sketch out when you see a pattern of friction: the same workaround in unrelated places, edge cases that each need a special branch, casts or `any` needed to compile, a lock for state the sketch said was not shared, or callers that must know the internals. Then re-run **how** on what you built, redesign as if the new constraints were known from day one, make the new sketch smaller than the old one, and return to phase 2.

## Output

The usage sketch, the type and module sketch, a short rationale (chosen design, rejected alternatives, why), and then the implementation.
