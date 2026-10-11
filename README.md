# vstack

Agent skills for rigorous engineering, in two packs:

- **vstack-core.** Skills for any project in any language: a playbook-driven work mode, 22 engineering principles, design and blast-radius reviews, TDD, comment cleanup, and plain writing.
- **vstack-ts.** The TypeScript and JavaScript stack pack: project detection, TypeScript rules, typed Electron IPC, and verification recipes for web frontends, Electron apps, and CLIs.

vstack is adapted from [pstack](https://github.com/cursor/plugins/tree/main/pstack). It keeps pstack's core idea: go deep first, write less code, and prove it works before calling it done. It drops the parts tied to Cursor and one team's stack.

The skills use the open Agent Skills format (`SKILL.md` with `name` and `description`). They work in Claude Code, Cursor, Codex, Gemini CLI, and any other harness that reads skills from a directory. Skill bodies name no harness-specific tools or models, and `npm run validate` enforces that.

## How the packs fit together

`vstack-mode` (in core) orients on a project, then loads the stack skill for the project's language if one is installed. Stack skills are named `<stack>-stack`. vstack-ts ships `ts-stack`, which tells the mode:

- the package manager and check commands,
- the surface (web, Electron, CLI, library, or service) and which verify skill proves a change on it,
- extra steps for the core playbooks (test runners, perf tools, codemods), the common JS/TS root causes, and where to validate input,
- two extra playbooks: dependency upgrade and release check.

Core works on its own in any language. vstack-ts needs core. A future pack such as `vstack-py` would add `py-stack` and its own verify skills the same way.

## Install

**Claude Code, as plugins.** Skills are namespaced, for example `/vstack-core:vstack-mode`.

```
/plugin marketplace add ~/work/dev/vstack
/plugin install vstack-core@vstack
/plugin install vstack-ts@vstack
```

**Any harness, as linked skills.** Skills keep plain names, for example `/vstack-mode`. Edits in this repo take effect immediately.

```bash
./install.sh claude cursor                     # every pack into ~/.claude and ~/.cursor
./install.sh --pack core codex                 # core only, into ~/.codex
./install.sh --pack ts gemini                  # ts plus the core it needs, into ~/.gemini
./install.sh --project ~/work/my-app agents    # into one repo's .agents/
./install.sh --uninstall all
```

The script links each skill directory and never overwrites a skill you already have. Pick one install method per harness, or you will see each skill twice.

**Windows, as linked skills.** Use `install.ps1` from PowerShell 5.1 or 7. It links skill directories with junctions, so it needs no admin rights or Developer Mode. It takes the same harnesses and options as `install.sh`.

```powershell
.\install.ps1 claude cursor                       # every pack into ~\.claude and ~\.cursor
.\install.ps1 -Pack core codex                    # core only, into ~\.codex
.\install.ps1 -Pack ts gemini                     # ts plus the core it needs, into ~\.gemini
.\install.ps1 -Project ~\work\my-app agents       # into one repo's .agents\
.\install.ps1 -Uninstall all
```

If script execution is blocked, run `powershell -ExecutionPolicy Bypass -File .\install.ps1 claude`. Under Git Bash, `install.sh` works only with Developer Mode on. Without it, the script stops instead of copying files.

**Cursor, as plugins.** Each pack has a `.cursor-plugin/plugin.json`, and the repo root has a `.cursor-plugin/marketplace.json` listing both.

## Use

Start any task that needs rigor with `vstack-mode`:

```
/vstack-mode the settings window loses its size after restart. repro first, then fix and verify.
/vstack-mode add a --json flag to the export command.
/vstack-mode upgrade electron from 31 to 33 and make sure the packaged app still starts.
/vstack-mode the dashboard takes 3 seconds to become interactive. find out why.
```

The other skills work on their own too:

```
/how does the preload expose the file APIs to the renderer?
/blast-radius of changing the config file format
/tdd the date parser drops the timezone
/verify-cli
/reflect
```

## vstack-core

| Skill | Use it when |
|---|---|
| `vstack-mode` | Default entry point for non-trivial work. Orients, loads the stack skill, routes to a playbook. |
| `vstack-principles` | Index of 22 engineering principles. The mode reads it at task start. |
| `how` | You want to understand a subsystem before changing it. |
| `architect` | A change crosses a module, process, or package boundary. Sketch two designs, pick one, then implement. |
| `blast-radius` | You want to know what a change could break outside its diff, proven by running code. |
| `tdd` | A bug has a cheap local test path. Failing test first. |
| `benchmark-checklist` | Vet a performance number before you report it. |
| `no-comments` | Strip narrating and workaround comments before committing. |
| `unslop` | Remove AI writing tells from prose. |
| `create-verification-skill` | Generate a `verify-<app>` skill specific to one repo. |
| `reflect` | Turn lessons from a session into skill, `AGENTS.md`, or lint edits. |

Core playbooks, picked by `vstack-mode`:

| Playbook | For |
|---|---|
| Investigation | A read-only question. Cited answer, no code change. |
| Bug fix | Reproduce on the real surface, root-cause, failing test first, fix, verify. |
| Feature | Name the data shape, design the boundary, build in verified units. |
| Refactoring | Pin behavior, subtract, reshape, prove equivalence. |
| Perf | Baseline, find the limiter, cheapest fix first, measure again. |
| Prototype | A throwaway sketch to settle a design question by observing it. |
| Authoring a skill | Writing or editing a skill. |
| Committing | Small ordered commits, Conventional Commits titles, short PR briefings. |

## vstack-ts

| Skill | Use it when |
|---|---|
| `ts-stack` | Any task in a repo with a `package.json`. The mode loads it automatically. |
| `typescript-best-practices` | Any `.ts` or `.tsx` edit. Includes typed Electron IPC and CLI argv patterns. |
| `verify-web` | Prove a frontend change in a real browser. |
| `verify-electron` | Prove an Electron change by launching the real app, dev or packaged. |
| `verify-cli` | Prove a CLI change by running the built binary in an isolated environment. |

Extra playbooks in `ts-stack`: **Dependency upgrade** (framework and toolchain bumps, one group per commit) and **Release check** (prove a package, CLI, or desktop build is ready, without publishing it).

## Differences from pstack

- **Harness-neutral.** No Cursor tool names, model routing, or `/setup-pstack`. Subagents are used when the harness has them, and the same steps run inline when it does not.
- **Split by stack.** The general method lives in core. Language and framework knowledge lives in stack packs that core loads by convention.
- **Your surfaces.** Verification skills for web, Electron, and CLI replace pstack's dependency on `cursor-team-kit`.
- **Leaner.** No orchestration, autopilot, babysit, or stacked-PR shipping playbooks. Two principles were folded into others: attack-the-premise into fix-root-causes, and outcome-oriented-execution into migrate-callers-then-delete-legacy-apis.
- **Safer autonomy defaults.** Publishing, tags, releases, and unrequested major upgrades always pause.

## Use it in a project

Add this to a project's `AGENTS.md` or `CLAUDE.md` so agents reach for vstack without being told:

```markdown
For non-trivial changes, follow the vstack-mode skill. Verify changes on the real surface
with the verify skill ts-stack names (verify-web, verify-electron, or verify-cli) before reporting done.
```

## Change it

- Run `/reflect` after a long session to turn corrections into skill edits.
- Run `npm run validate` after editing any skill. See `AGENTS.md` for the rules on which pack a change belongs in.

## License

MIT. Portions adapted from pstack, copyright Lauren Tan, under the MIT License. See `LICENSE`.
