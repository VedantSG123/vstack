---
name: blast-radius
description: Find what a change could break outside its own diff, and prove the one fact it is safe because of by running real code. Use for "blast radius of X", "what could this break", or reviewing a small diff you do not trust yet.
---

# Blast radius

Find what a change breaks somewhere else, before it ships. Listing callers is not the job, since grep does that in a second. The job is the breakage grep will not show.

## Do not trust your own writeup

A writeup that sounds right reads as convincing whether or not it is true. Find the one or two facts the change's safety depends on and prove them by running code. For each fact, get it as far down this list as is cheap, and say where it stopped:

1. You said so. Worthless on its own.
2. You pointed at the line: a real `file:line`, or the library's own installed source.
3. You walked the failure case step by step and showed it cannot happen.
4. You ran it: a script or test that calls the real code and fails loudly if you are wrong.
5. You reproduced it in the running app.

## Steps

1. **Read the change.** The diff, the symbols it adds, changes, and removes, and what now behaves differently, including what the diff does not spell out.
2. **Find the one fact it is safe because of.** Most risky-looking changes are safe because of a single fact, like "this only runs after the window has loaded". If that holds, most risks are cleared at once. Spend your time here.
3. **Look where grep stops.** Check each of these, plus the stack skill's list for this language:
   - Dynamic access: names built from strings (message channels, event names, routes, reflection), dynamic imports.
   - Serialized shapes: data an older version wrote to disk, a cache, or local storage, API responses, and output that other programs parse.
   - Timing: startup and shutdown order, teardown, callbacks that fire after the caller moved on, retries.
   - Packaging: code that works in development but resolves paths or assets differently once built, bundled, or installed.
   - Public contract: exported types and functions, CLI flags, exit codes, and output formats other people depend on.
   - The library you call: read its source at the installed version, including any local patch.
4. **Rate each risk honestly.** A real chance and a real cost. Keep confirmed risks. List checked-and-cleared ones separately. Cite real lines. A search that finds nothing is still an answer. Never invent a caller.
5. **Prove the one fact.** Write the script or test, run it, and paste what happened.

## Hand back

- **What it does.** Including the part that is not obvious.
- **The fact it is safe because of.** Which level you reached, and the proof. If unproven, say unproven.
- **Risks.** How each breaks, `file:line`, likelihood and cost, how to check.
- **Cleared.** What you checked and why it is fine.
- **Before you merge.** The cheapest test or repro that would catch the real bug.
