# Investigation

**You own the answer.** Investigations are read-only. They produce a cited explanation or a recommendation, not a code change.

1. Run the **how** skill over the subsystem in question.
2. For "why was this built this way", read the history: `git log -L` or `git log -S<symbol>` on the relevant lines, the commit messages, and any linked PR or issue.
3. For "should we use A or B", check the facts you can check by running them (does the library support X, how big is the bundle, how fast is it). Do not answer from memory when a one-minute script would settle it.
4. Write the answer in the **how** output shape (Overview, Key concepts, How it works, Where things live, Gotchas), or as a recommendation with a tradeoffs table when the question is a choice.
5. Apply the **unslop** skill.

No code change and no commit. If the investigation turns into a change, finish the answer, then route to Bug fix or Feature.

**Reply:** the investigation output, with `file:line` citations. For "are we sure?" questions, give your real judgment with reasons. Push back if the premise is wrong.
