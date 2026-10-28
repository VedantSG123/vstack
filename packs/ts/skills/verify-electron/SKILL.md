---
name: verify-electron
description: Prove an Electron app change works by launching the real app (dev or packaged), driving its windows with Playwright's Electron support, and checking main-process and renderer logs. Use after changing an Electron app's UI, IPC, preload, main process, menus, or packaging, or to reproduce a desktop bug.
---

# Verify an Electron app

An Electron change can break in three processes and in packaging. Launch the real app, drive it, and watch both sides. Expect getting the app to launch in isolation to be most of the work.

## 1. Know the layout first

Find these before driving anything, from `package.json`, the build config (`electron-vite`, `electron-forge`, `electron-builder`, or a custom webpack or esbuild setup), and the main-process entry:

- The main-process entry, the preload script, and the renderer entry.
- How the dev command builds them, the output directory the app actually loads, and the flags it passes to Electron (for example `--no-sandbox`).
- **What the window loads in dev.** A dev-server URL from an env var, a hard-coded port, or a file. Also look for anything else bound to that origin, such as a CORS allowlist on a bundled backend. If the app only works on one port, use that port. If the user's own server holds it, ask before stopping or reusing it.
- **Every place the app writes data.** `app.getPath('userData')` is only one of them. Grep for `env-paths`, `os.homedir`, `XDG_`, `APPDATA`, and `app.getPath(` in the main process and in any child process it spawns, such as a bundled backend with its own database.
- **The child processes the main process spawns** (a backend, a worker, a language runtime), and how the app knows each one is ready.
- How to build the packaged app for the current platform, and where the output lands (for example `dist/linux-unpacked/`, `out/<name>-linux-x64/`, `dist/mac/<Name>.app`).

## 2. Isolate the run

- Pass `--user-data-dir` to a fresh temp directory. This also keeps a `requestSingleInstanceLock` app from handing off to an instance the user already has open, since the lock is held per user-data directory.
- Redirect every other data path you found. On Linux set `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, and `XDG_STATE_HOME` to temp directories. On macOS and Windows the libraries read `HOME` or `APPDATA` and `LOCALAPPDATA`, so redirect those.
- When the app depends on something slow to install under those paths (a managed language runtime, downloaded models), symlink the user's existing copy into the temp tree and only read it. Never let the run install over or repair the user's copy.
- Check isolation after launch, as the script below does. If any path still points at the user's real data, stop and tell the user rather than writing to it.

## 3. Launch with Playwright

Playwright drives Electron without downloading a browser. Use the repo's Playwright setup if it has one. Otherwise use a scratch directory outside the repo with `npm i -D playwright`.

Build the main process and preload first if the dev command does not leave runnable output. Then:

```js
// harness.mjs
import { _electron as electron } from "playwright";
import { mkdtempSync, mkdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const root = mkdtempSync(join(tmpdir(), "verify-"));
const xdg = Object.fromEntries(
  ["DATA", "CONFIG", "CACHE", "STATE"].map((k) => [`XDG_${k}_HOME`, join(root, k.toLowerCase())]),
);
for (const dir of Object.values(xdg)) mkdirSync(dir, { recursive: true });
const userData = join(root, "userData");

const app = await electron.launch({
  executablePath: "node_modules/.bin/electron", // the workspace's own Electron
  args: ["dist/main.js", "--no-sandbox", `--user-data-dir=${userData}`], // the dev script's entry and flags
  env: { ...process.env, ...xdg },
});
const pid = app.process().pid;
const watchdog = setTimeout(() => { try { process.kill(pid, "SIGKILL"); } catch {} process.exit(2); }, 240_000);
watchdog.unref();
app.process().stdout?.on("data", (d) => process.stdout.write(`[main] ${d}`));
app.process().stderr?.on("data", (d) => process.stderr.write(`[main:err] ${d}`));

const actualUserData = await app.evaluate(({ app }) => app.getPath("userData"));
if (actualUserData !== userData) throw new Error(`not isolated: ${actualUserData}`);

// In dev the app may open DevTools as its own window, so firstWindow() can return it.
let win;
while (!(win = app.windows().find((w) => w.url().startsWith("http://localhost:5173")))) await new Promise((r) => setTimeout(r, 200));
win.setDefaultTimeout(4000);
const errors = [];
win.on("console", (m) => m.type() === "error" && errors.push(m.text()));
win.on("pageerror", (e) => errors.push(String(e)));
await win.waitForLoadState("domcontentloaded");
```

- Wait for each child process the app spawns to be ready (poll its health URL or wait for its log line) before driving the UI.
- Keep waits short. Set a default timeout of a few seconds, cap every "wait until built" loop, and keep the watchdog. A stuck run should fail in seconds, not sit for minutes on one locator.
- `app.evaluate` runs in the main process. Use it to read state (window count, `BrowserWindow.getAllWindows()[0].getBounds()`, menu items) or to call what a native menu or dialog would trigger. Stub native dialogs this way (`dialog.showOpenDialog = async () => ({ canceled: false, filePaths: [path] })`), since Playwright cannot click them.
- Seed fixtures the way the app would make them: its own HTTP API or IPC, called from the test script. Then navigate the renderer to the screen under test.
- On Linux with no display (`echo $DISPLAY` is empty), run under `xvfb-run -a node verify.mjs`.
- If Playwright cannot attach, launch the app with `--remote-debugging-port=9229` and connect with `chromium.connectOverCDP("http://localhost:9229")`, or with a browser tool your harness provides that can attach to a CDP port.

## 4. Probe, then script the scenarios

- **Probe first.** Launch once, open the screen under test, take a screenshot, and print `await win.locator("body").ariaSnapshot()`. Write selectors from what that shows. Guessed selectors fail in bulk: one wrong click that navigates away makes every later step fail for an unrelated reason.
- **Run scenarios as named steps.** Each step asserts its own outcome, screenshots on failure, and records pass or fail. Stop and close the app after two failures in a row, because later steps usually fail as a side effect.
- **Sort every failure before you report it.** Open its screenshot and decide whether the test script or the app is wrong. Fix the script and rerun until every remaining failure is the app's.

## 5. What to check

- **Both processes' logs.** No new errors from `[main:err]` or the renderer console. Name each expected one in the reply, such as a cancellation the app logs as an error.
- **IPC end to end.** Drive the UI action that sends the IPC call and observe the result in the UI and, when relevant, on disk or in main-process state. Calling the handler directly does not prove the preload wiring.
- **Child processes**, when the change starts, replaces, or cancels work in one. The UI cannot show that a superseded run was killed. List the descendants of `app.process().pid` and check the right ones exist before and after the action:

  ```js
  import { execSync } from "node:child_process";
  function descendants(pid) {
    const rows = execSync("ps -eo pid=,ppid=,args=").toString().trim().split("\n")
      .map((l) => l.trim().match(/^(\d+)\s+(\d+)\s+(.*)$/)).filter(Boolean)
      .map(([, p, pp, args]) => ({ pid: +p, ppid: +pp, args }));
    const tree = new Set([pid]);
    for (let grew = true; grew; ) {
      grew = false;
      for (const r of rows) if (tree.has(r.ppid) && !tree.has(r.pid)) { tree.add(r.pid); grew = true; }
    }
    return rows.filter((r) => r.pid !== pid && tree.has(r.pid));
  }
  ```

  On Windows, read the same parent and child pairs from `Get-CimInstance Win32_Process`.
- **Renderer state the UI does not show**, such as a store's contents after a file is renamed. Under a Vite dev server, `win.evaluate(() => import("/src/path/to/store.ts"))` returns the same module instance the app uses. Use it only to read state. Drive every action through the UI.
- **Files changed outside the app**, when the app watches the disk. Write, rename, and delete files from the test script and check the UI follows. Include the case where the file also has unsaved edits in the app.
- **Security defaults** after touching window creation: `contextIsolation: true`, `sandbox: true` unless the app needs otherwise, `nodeIntegration: false`. Check with `app.evaluate` on `webContents.getLastWebPreferences()`.
- **Lifecycle.** Close and reopen the window, navigate away from and back to the screen, and quit and relaunch with the same `userData`, when the change touches state, windows, background work, or startup. Check that state survives, that work belonging to the old screen stops, and that listeners do not double up.
- **Packaged build,** when the change touches paths, assets, native modules, the preload, or build config. Build for the current platform and launch the packaged executable. Code that works in dev often fails in the packaged app because of `asar` paths, `__dirname`, or files missing from the build's `files` list.

The **verify-web** skill's notes on rich text editors and modal dialogs apply to the renderer too.

## 6. Evidence and cleanup

Keep the scripts, screenshots, and logs in the scratch directory and name the path in the reply, with the command that reruns them. `app.close()` the instance you launched. If a run crashes, kill the PID from `app.process().pid`, never by process name, because the user may have the same app open. Stop any dev server you started by its PID. Delete the temp data directories unless they are evidence.

If setting up the launch took real effort (a fixed port, data redirects, seeded fixtures, symlinked installs), run the **create-verification-skill** skill so the next run starts from that setup.
