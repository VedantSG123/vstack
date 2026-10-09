# Working on vstack

vstack is a set of portable agent skills, split into packs under `packs/`. Each pack is an installable plugin with its own `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json`. Each directory in a pack's `skills/` is one skill in the open Agent Skills format: a `SKILL.md` with `name` and `description` frontmatter, plus files it links to.

## Packs

- `packs/core` (vstack-core) is the base. It is language-agnostic and depends on no other pack.
- `packs/ts` (vstack-ts) is the TypeScript and JavaScript stack pack. It builds on core.
- A new stack pack goes in `packs/<stack>/`, ships a `<stack>-stack` skill that vstack-mode loads in its orient step, and is listed in both root marketplace files.

## Rules

- Run `npm run validate` after every change. It must pass. It checks frontmatter, links, skill references, pack boundaries, and harness neutrality.
- Put each piece of guidance in the lowest pack where it is true. Anything specific to one language, toolchain, or framework goes in a stack pack. Core must not mention them, and the validator blocks the common ones.
- Links never leave their pack, because packs install separately. Refer to a skill in another pack by name, as "the **<name>** skill". Stack packs may refer to core skills. Core never refers to stack-pack skills by name.
- Keep skill bodies harness-neutral. Do not name one harness's tools, tool parameters, or model ids. Write "if your harness can spawn subagents" instead.
- `name` matches the directory name and is unique across all packs. `description` says what the skill does and when to use it, under 1024 characters.
- Follow `packs/core/skills/vstack-mode/playbooks/authoring-a-skill.md` and write prose per `packs/core/skills/unslop/SKILL.md`.
- Bump `version` in every manifest of a pack together. The validator checks that both manifests of a pack match.
