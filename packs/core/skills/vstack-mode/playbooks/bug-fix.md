# Bug fix

**You own the diagnosis.** Every shipped line traces to runtime evidence. A change that "might help" is a hypothesis, not a fix, and it does not ship. When evidence refutes a hypothesis, revert what it motivated.

1. **Reproduce it yourself on the real surface** with the verify skill for the surface (step 1 of `SKILL.md` names it). Do not ask the user to reproduce unless you can name the specific reason you cannot reach it, and only after driving it as far as it goes. If it will not reproduce, tighten the conditions, synthesize the trigger, or add logging until it fires.
2. **Binary-search the cause.** List the candidate hypotheses. Use the **how** skill on the subsystem and `git log` or `git bisect` for regressions. Each pass, run the check that eliminates the most candidates. When state is unclear, add logging and read it while the code runs. Do not guess. Apply [fix-root-causes](../../vstack-principles/principles/fix-root-causes.md), and check the stack skill's list of common root causes.
3. **Confirm the mechanism** with runtime evidence before you write the fix. State it in one sentence: "X happens because Y, shown by Z".
4. **Write the failing check first.** If the bug has a cheap local test path, follow the **tdd** skill. Otherwise write the smallest script that reproduces it.
5. **Fix at the root.** The smallest change the evidence justifies. If the fix crosses a module boundary, run the **architect** skill first. Grep for the same pattern elsewhere and fix every instance.
6. **Verify on the same surface.** The original repro now passes. A unit test passing shows branch behavior, not that the bug is gone. "Inconclusive" or a different surface is not a pass. Say so.
7. **Remove temporary logging.** Keep only logging that would help the next person debug in production.
8. Run the [committing](committing.md) playbook. The failing test or repro commit lands before the fix.

**Reply:** what was broken, the root cause with its evidence, the fix, and how you verified it. Paste the failing-then-passing output verbatim.
