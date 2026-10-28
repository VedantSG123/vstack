---
name: verify-web
description: Prove a web frontend change works by running the app and driving it in a real browser, capturing screenshots, console errors, and failed requests as evidence. Use after changing UI in a Vite, Next, Remix, Astro, SvelteKit, or similar app, to reproduce a UI bug, or to compare visual variants.
---

# Verify a web frontend

A passing typecheck says nothing about what the user sees. Run the app, drive the real path, and keep the evidence.

## 1. Launch

- Use the repo's own `dev` script. For a perf, bundle, or "works in dev, broken in prod" question, use the production build and its preview command instead (`vite preview`, `next start`, or serve the build output).
- Start it on a port the user is not using (pass `--port` or set `PORT`), in the background, and record its PID so you can stop exactly what you started. First check whether anything is bound to the default origin, such as a backend's CORS allowlist or a hard-coded URL in an Electron main process. If so, the app only works on that port: use it, and ask the user if their own server holds it.
- Wait until it is ready: poll the URL until it returns 200, or watch for the "ready" log line. Do not sleep for a fixed time.
- If a dev server is already running for the user, do not kill or reuse it without saying so.

## 2. Drive

Pick the first option that exists:

1. The repo's own end-to-end setup (`playwright.config.*`, `cypress.config.*`). Write or run a spec there.
2. A browser-automation tool your harness provides. Use it to navigate, click, type, and screenshot.
3. A Playwright script in a scratch directory outside the repo:

```bash
mkdir -p "$SCRATCH/verify" && cd "$SCRATCH/verify" && npm init -y >/dev/null && npm i -D playwright && npx playwright install chromium
```

```js
// verify.mjs
import { chromium } from "playwright";
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
const errors = [];
page.on("console", (m) => m.type() === "error" && errors.push(m.text()));
page.on("pageerror", (e) => errors.push(String(e)));
page.on("requestfailed", (r) => errors.push(`${r.failure()?.errorText} ${r.url()}`));
await page.goto(process.env.URL ?? "http://localhost:5199/");
await page.getByRole("button", { name: "Save" }).click();
await page.getByText("Saved").waitFor();
await page.screenshot({ path: "after-save.png", fullPage: true });
console.log(JSON.stringify({ errors }, null, 2));
await browser.close();
```

Use stable handles: roles and accessible names (`getByRole`, `getByLabel`), `data-testid`, and URLs. Avoid CSS paths and coordinates.

- **Code and rich text editors** (Monaco, CodeMirror, ProseMirror) keep their real input in a hidden element, and focusing it often does not stick. Click the visible content area (`.monaco-editor .view-lines`, `.cm-content`), then press `Control+A` and call `keyboard.insertText`. If focus missed, `Control+A` selects the whole page instead. Auto-closing brackets and quotes still apply to inserted text, so `x = (` arrives as `x = ()`. Pick inputs whose meaning survives that, and read the editor's content back before asserting on what it produced.
- **Modal dialogs** the app opens on its own, such as an "edited elsewhere" conflict prompt, block every later click until dismissed, and Escape does not always close them. After any step that can raise one, assert that it appeared and dismiss it with its own button.

## 3. What to check

- **The real user path.** Click and type like a user. Do not call internal setters or test-only routes.
- **Before and after state.** Screenshot the state before the action and after it, not only the final screen.
- **Console and network.** Zero new console errors and zero failed requests, or explain each one.
- **The unhappy paths.** Loading, empty, and error states. Force an error with `page.route()` to fail the request.
- **Persistence.** Reload and confirm state that should survive does survive.
- **Viewports.** Check a phone width (390 by 844) as well as desktop when layout changed.
- **Accessibility, when UI changed.** Tab through the new controls and confirm focus is visible and the order makes sense. If `@axe-core/playwright` is available, run it on the page.
- **Dark mode**, when the app supports it: `browser.newPage({ colorScheme: "dark" })`.

## 4. Evidence and cleanup

Keep screenshots and the script's output in the scratch directory and name their path in your reply. Stop the server by the PID you recorded. Never kill by process name.
