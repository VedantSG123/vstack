---
name: verify-electron
description: Prove an Electron app change works by launching the real app (dev or packaged), driving its windows with Playwright's Electron support, and checking main-process and renderer logs. Use after changing an Electron app's UI, IPC, preload, main process, menus, or packaging, or to reproduce a desktop bug.
---

# Verify an Electron app

An Electron change can break in three processes and in packaging. Launch the real app, drive it, and watch both sides.

## 1. Know the layout first

Find these before driving anything, from `package.json` and the build config (`electron-vite`, `electron-forge`, `electron-builder`, or a custom webpack or esbuild setup):

- The main-process entry, the preload script, and the renderer entry.
- How the dev command builds them, and the output directory the app actually loads.
- How to build the packaged app for the current platform, and where the output lands (for example `dist/linux-unpacked/`, `out/<name>-linux-x64/`, `dist/mac/<Name>.app`).
- Where the app stores data: `app.getPath('userData')`, and whether it honors `--user-data-dir` or an env var to change it.

## 2. Launch with Playwright

Playwright drives Electron without downloading a browser. Use the repo's Playwright setup if it has one. Otherwise use a scratch directory outside the repo with `npm i -D playwright`.

Build the app first if the dev command does not leave runnable output. Then:

```js
// verify.mjs
import { _electron as electron } from "playwright";
import { mkdtempSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const userData = mkdtempSync(join(tmpdir(), "verify-userdata-"));
const app = await electron.launch({
  args: [process.env.APP_DIR ?? ".", `--user-data-dir=${userData}`],
  // packaged build instead: executablePath: "dist/linux-unpacked/my-app", args: [`--user-data-dir=${userData}`],
  env: { ...process.env, NODE_ENV: "production" },
});
app.process().stdout?.on("data", (d) => process.stdout.write(`[main] ${d}`));
app.process().stderr?.on("data", (d) => process.stderr.write(`[main:err] ${d}`));

const actualUserData = await app.evaluate(({ app }) => app.getPath("userData"));
console.log({ actualUserData, isolated: actualUserData === userData });

const win = await app.firstWindow();
const errors = [];
win.on("console", (m) => m.type() === "error" && errors.push(m.text()));
win.on("pageerror", (e) => errors.push(String(e)));
await win.waitForLoadState("domcontentloaded");
await win.getByRole("button", { name: "Open project" }).click();
await win.screenshot({ path: "after-open.png" });

console.log(JSON.stringify({ errors }, null, 2));
await app.close();
```

- If `isolated` prints `false`, the run is using the user's real profile. Stop, and tell the user, rather than writing to their data.
- `app.evaluate` runs in the main process. Use it to read state (window count, `BrowserWindow.getAllWindows()[0].getBounds()`, menu items) or to call what a native menu or dialog would trigger. Stub native dialogs this way (`dialog.showOpenDialog = async () => ({ canceled: false, filePaths: [path] })`), since Playwright cannot click them.
- On Linux with no display (`echo $DISPLAY` is empty), run under `xvfb-run -a node verify.mjs`.
- If Playwright cannot attach, launch the app with `--remote-debugging-port=9229` and connect with `chromium.connectOverCDP("http://localhost:9229")`, or with a browser tool your harness provides that can attach to a CDP port.

## 3. What to check

- **Both processes' logs.** No new errors from `[main:err]` or the renderer console.
- **IPC end to end.** Drive the UI action that sends the IPC call and observe the result in the UI and, when relevant, on disk or in main-process state. Calling the handler directly does not prove the preload wiring.
- **Security defaults** after touching window creation: `contextIsolation: true`, `sandbox: true` unless the app needs otherwise, `nodeIntegration: false`. Check with `app.evaluate` on `webContents.getLastWebPreferences()`.
- **Lifecycle.** Close and reopen the window, and quit and relaunch with the same `userData`, when the change touches state, windows, or startup. Check that state survives and that listeners do not double up.
- **Packaged build,** when the change touches paths, assets, native modules, the preload, or build config. Build for the current platform and launch the packaged executable. Code that works in dev often fails in the packaged app because of `asar` paths, `__dirname`, or files missing from the build's `files` list.

## 4. Evidence and cleanup

Keep screenshots and logs in the scratch directory and name the path in the reply. `app.close()` the instance you launched. If a run crashes, kill the PID from `app.process().pid`, never by process name, because the user may have the same app open. Delete the temp `userData` directory unless it is evidence.
