# Authoring a skill

**You own the skill's voice.**

1. **Decide where it lives.** A skill for every project goes in vstack's `skills/`. A skill for one repo goes in that repo, in the directory its harness reads (for example `.claude/skills/`, `.cursor/skills/`, or `.agents/skills/`).
2. **Write portable frontmatter.** `name` matches the directory name, lowercase with hyphens. `description` says what the skill does and when to use it, in under 1024 characters. The description is all the agent sees when deciding to load it, so name the trigger phrases.
3. **Keep the body harness-neutral.** Do not name one harness's tools or model ids. Say "if your harness can spawn subagents" instead of naming a tool. Link other files by relative path.
4. **Cut.** Keep only prose that changes a decision. Tell the agent what to do. Explain only when the rule is confusing without a reason. Point at structural sources (types, scripts, config) instead of restating them, per [encode-lessons-in-structure](../../vstack-principles/principles/encode-lessons-in-structure.md).
5. **Validate.** In vstack, run `scripts/validate.mjs`. Elsewhere, check that the frontmatter parses and every linked file exists.
6. **Try it.** Run the skill once on a real task and fix what it got wrong.

**Reply:** what the skill does, its key design decisions, and the validation result.
