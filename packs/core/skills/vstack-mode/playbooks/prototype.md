# Prototype

**You own the decision, not the code.** The prototype is a throwaway instrument. The real build follows the Feature playbook.

This is the one playbook where code quality does not matter. Speed matters. The rigor is in choosing well. Propose variations the user did not ask for.

1. **Name the decision** the prototype exists to make: which layout, which interaction, which library, which approach is fast enough. No decision means no prototype.
2. **Build in a scratch directory**, outside the production source. For a visual question, a single HTML file or the lightest dev server is enough. For a behavior or timing question, the smallest script that exercises it. No tests, no abstractions.
3. **Put alternatives behind one switch** (buttons, a keypress, or a CLI flag), each labeled, per [exhaust-the-design-space](../../vstack-principles/principles/exhaust-the-design-space.md).
4. **Observe each variant.** Screenshot visual variants with the web verify skill or a browser tool. Log the timing or print the output for behavioral ones. The observation is the test.
5. **Recommend.** Present the variants, the evidence, the tradeoffs, and your pick.

**Reply:** the variants, the evidence, the tradeoffs, your recommendation, and the scratch path. Say plainly that the prototype is throwaway.
