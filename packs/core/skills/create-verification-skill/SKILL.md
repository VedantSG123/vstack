---
name: create-verification-skill
description: Generate a project-local verify-<app> skill that tells any agent exactly how to launch, drive, and collect evidence from this repo's app (web, desktop, CLI, or service), with a map of its main features. Use for /create-verification-skill, "make a verify skill for this repo", or when the same app needs verifying repeatedly and the generic verify skills keep needing the same project details.
---

# Create a verification skill

A stack pack's generic verify skills (for example the ones in vstack-ts) say how to verify any app of that kind. A project-local skill records the specifics of *this* app, so the next agent does not rediscover them. Write it for an agent that reads it cold, mid-task, having never seen the app.

## 1. Interview the repo, not the user

Answer these from the code. Ask the user only what you cannot observe.

- **Surface.** What do users touch? Pick the primary surface and note any others.
- **Run.** The exact dev and build commands, ports, env vars, seed data, and login.
- **Drive.** Existing harnesses first: end-to-end specs, test helpers that spawn the CLI. Otherwise the recipe from the matching generic verify skill.
- **Observe.** Which evidence is available: screenshots, terminal output, logs, files written, database rows.
- **Isolate.** Can two instances run side by side (ports, data directories, `HOME`, database)? If not, the skill must say so.

If the checkout does not build or start, fix that or report exactly what fails before generating. A skill written against a broken base teaches wrong steps.

## 2. Write the skill

Put it where the repo's agents read skills: `.claude/skills/` if `.claude/` exists, `.cursor/skills/` if `.cursor/` exists, otherwise `.agents/skills/`. Create `verify-<app>/SKILL.md` with frontmatter (`name: verify-<app>` and a `description` naming the app, its surface, and when to use it) and these sections, each filled from what you found, with no placeholders:

- **Launch.** The exact command, how to tell it is ready, and teardown.
- **Doctor.** One read-only check that the instance is worth driving: process up, right build, port owned by this run.
- **Drive.** The harness recipe with this repo's real selectors, commands, and routes. Ship any helper script next to the skill, executable, with its invocation shown.
- **Evidence.** What to capture and where it goes. Exercise the real user path, capture the action and the resulting state, and check side effects, not only the screen.
- **Cleanup.** Stop what this run started, never by process name. Cleanup never deletes the evidence.

## 3. Seed a feature map

Create `verify-<app>/features/README.md` as an index, plus one file for each of the top three to five user-facing features (from routes, commands, menus, or docs). Each file has four sections: what the feature is, how a user reaches it, how to drive it with the harness, and gotchas.

## 4. Prove it

Follow the generated skill end to end once: launch, doctor, drive one mapped feature, capture evidence, clean up. Confirm the evidence still exists after cleanup. Fix whatever failed and repeat. A skill that was never run is a draft.

**Reply:** the skill path, the surface, the features mapped, and the evidence from the proving run.
