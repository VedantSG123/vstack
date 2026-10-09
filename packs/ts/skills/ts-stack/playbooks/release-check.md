# Release check

**You own the proof that the artifact works. You do not publish.** Publishing, tagging, and uploading are on the always-pause list. Stop after the check and hand the user the exact command to run.

1. **Clean build from scratch.** Remove build output and run the build script as CI would. Run the typecheck, lint, and tests.
2. **Check the package contents** (npm packages and CLIs). Run `npm pack --dry-run` (or `pnpm pack`). Confirm the tarball contains the built files and nothing private (no `.env`, no source maps you did not intend to ship, no test fixtures). Check `files`, `exports`, `main`, `types`, `bin`, and `engines` in `package.json`.
3. **Install the tarball like a user.** In a fresh temp directory, install the packed tarball, then:
   - CLI: run the installed binary with `--help`, `--version`, and one real command. Check the shebang and that it runs on the minimum Node version in `engines` if you can.
   - Library: import it from both ESM and CommonJS if both are declared, and compile a small TypeScript file against its types.
4. **Desktop build** (Electron). Run the packaging command for the current platform. Launch the packaged app, not the dev build, with the **verify-electron** skill. Check that it starts, that the main window loads, that assets and native modules resolve from inside the archive, and that the auto-updater and code signing config point at the right place.
5. **Version and changelog.** Check that the version bump matches the change (breaking means major), and that the changelog or release notes describe what users will notice.
6. **Report and stop.**

**Reply:** what you built, what you installed or launched and what you observed, any problems found, and the exact publish or release command for the user to run.
