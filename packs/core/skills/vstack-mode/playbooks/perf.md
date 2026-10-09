# Perf

**You own the measurement.** Every fix ties to a number. Do not read source instead of measuring.

1. **Capture a baseline** on the real surface. Pick the measurement that matches the complaint: startup time, a CPU profile of the slow path, render or frame cost, artifact or bundle size, or a benchmark of one function. The stack skill names the tools for each.
   Vet the baseline with the **benchmark-checklist** skill.
2. **Find the limiter.** Profile, then map the hot spot to source. Do not claim a ceiling you have not measured.
3. **Pick the cheapest fix first.** In order: don't do it at all, do it once and cache it, do less of it, do it later (lazy import, defer until idle), do it off the critical path (worker, background), do it concurrently, do it faster. Stop when an earlier step meets the target.
4. **Change one thing at a time.** Measure after each change, per [sequence-verifiable-units](../../vstack-principles/principles/sequence-verifiable-units.md). Revert changes that do not move the number.
5. **Measure again** under the same conditions and vet the result with the **benchmark-checklist** skill. "Inconclusive" is an honest result. Report it as one.
6. Run the [committing](committing.md) playbook with the before and after number in the description.

**Reply:** baseline, result, delta with units and run count, the limiter, and the path to the raw measurements.
