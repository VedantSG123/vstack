---
name: verify-cli
description: Prove a Node CLI or TUI change works by running the built binary the way users do, in an isolated temp environment, and checking stdout, stderr, exit codes, piped and TTY behavior, and signals. Use after changing a CLI's commands, flags, output, config handling, or interactive prompts, or to reproduce a CLI bug.
---

# Verify a CLI

Users run the built binary with real arguments in a real terminal, or pipe it into other tools. Test it that way.

## 1. Build and locate the binary

- Run the repo's build script. Find the entry from `bin` in `package.json`.
- Run what users run: the built file (`node dist/cli.js`) or a linked binary (`npm link`, or `npm pack` and install the tarball in a temp dir for a release check). Running the TypeScript source with `tsx` is fine for quick iteration, but the final check uses the build.

## 2. Isolate the environment

The CLI may read and write config, caches, and credentials. Never let a verification run touch the user's real ones.

```bash
export VERIFY_DIR="$(mktemp -d)"
export HOME="$VERIFY_DIR/home" XDG_CONFIG_HOME="$VERIFY_DIR/config" XDG_CACHE_HOME="$VERIFY_DIR/cache"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$VERIFY_DIR/work" && cd "$VERIFY_DIR/work"
```

Check the source for other places it reads (a `--config` flag, a project-local dotfile, an env var with the tool's name) and point those at the temp dir too.

## 3. Capture the three channels separately

```bash
node /path/to/dist/cli.js build --out out >stdout.txt 2>stderr.txt; echo "exit=$?"
```

For several cases, write a small harness in the scratch dir:

```js
// verify.mjs
import { spawnSync } from "node:child_process";
import assert from "node:assert/strict";

const run = (args, opts = {}) =>
  spawnSync(process.execPath, [process.env.CLI, ...args], { encoding: "utf8", ...opts });

let r = run(["--help"]);
assert.equal(r.status, 0, "--help exits 0");
assert.match(r.stdout, /Usage/, "--help prints usage to stdout");

r = run(["convert", "missing.json"]);
assert.notEqual(r.status, 0, "missing input exits non-zero");
assert.match(r.stderr, /missing\.json/, "error names the file");
assert.doesNotMatch(r.stderr, /at .*\.js:\d+/, "no stack trace for a user error");

r = run(["convert", "-"], { input: '{"a":1}' });
assert.equal(r.status, 0, "reads stdin when given -");
console.log("all checks passed");
```

## 4. What to check

- **Help and version.** `--help` and `--version` exit 0 and print to stdout.
- **The happy path** with realistic input, and the side effects: files written, their contents, nothing written outside the target.
- **Errors.** Bad flags, missing files, and invalid input exit non-zero, print a message that names the problem to stderr, and do not print a stack trace for a user mistake.
- **Pipes versus TTY.** When stdout is not a TTY (`| cat`), output has no colors, spinners, or progress bars, and machine-readable modes (`--json`) print only JSON to stdout. `NO_COLOR=1` disables color.
- **Stdin**, if the CLI reads it, including empty stdin.
- **Exit on signal.** Start a long command and send SIGINT. It cleans up temp files and exits promptly, conventionally with code 130.
- **Interactive prompts and TUIs.** Drive them in a real pseudo-terminal: `tmux new-session -d -s verify '<cmd>'`, then `tmux send-keys -t verify ...` and `tmux capture-pane -p -t verify` to read the screen. Without tmux, use `node-pty` or `script -q -c '<cmd>' /dev/null`. Also check that the CLI fails clearly, rather than hanging, when a prompt is needed but stdin is not a TTY.
- **Cross-platform hazards** visible in the diff: hard-coded `/` path joins, `~` expansion, shell-specific quoting in `exec` calls, line endings.

## 5. Evidence and cleanup

Paste the commands and their exit codes and relevant output into the reply. Kill any tmux session or process you started by name or PID that you created. Remove `$VERIFY_DIR` unless it holds evidence you cite.
