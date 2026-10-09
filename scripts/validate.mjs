#!/usr/bin/env node
import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join, dirname, resolve, relative, sep } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const packsDir = join(root, "packs");
const BASE_PACK = "core";
const errors = [];
const fail = (file, msg) => errors.push(`${relative(root, file)}: ${msg}`);

const ALLOWED_KEYS = new Set([
  "name", "description", "license", "compatibility", "metadata", "allowed-tools", "disable-model-invocation",
]);
const HARNESS_SPECIFIC = [
  [/\bsubagent_type\b/, "names a harness-specific subagent parameter"],
  [/`Task`|\bTask\(/, "names a harness-specific tool"],
  [/\breadonly:\s*true\b/, "names a harness-specific tool option"],
  [/\bmcp__\w+/, "names a harness-specific MCP tool"],
  [/\b(grok|gpt)-\d|claude-(opus|sonnet|haiku)-\d/i, "pins a model id"],
  [/cursor-team-kit|pstack-models|\.cursor-plugin/, "depends on another plugin's files"],
];
// The base pack stays language-agnostic. Stack-specific detail belongs in a stack pack.
const STACK_LEAKS = /\b(package\.json|tsconfig|npm|pnpm|yarn|vitest|jest|electron|playwright|react|vite|zod|node_modules|typescript|javascript)\b/i;

const isDir = (p) => existsSync(p) && statSync(p).isDirectory();
const walk = (dir) => (isDir(dir) ? readdirSync(dir).flatMap((n) => (isDir(join(dir, n)) ? walk(join(dir, n)) : [join(dir, n)])) : []);
const readJSON = (file) => { try { return JSON.parse(readFileSync(file, "utf8")); } catch (e) { fail(file, `invalid JSON: ${e.message}`); return null; } };

function frontmatter(file) {
  const m = readFileSync(file, "utf8").match(/^---\n([\s\S]*?)\n---\n/);
  if (!m) return null;
  const fields = {};
  for (const line of m[1].split("\n")) {
    const kv = line.match(/^([A-Za-z][\w-]*):\s*(.*)$/);
    if (kv) fields[kv[1]] = kv[2].replace(/^["']|["']$/g, "");
  }
  return fields;
}

const packs = readdirSync(packsDir).filter((n) => isDir(join(packsDir, n)));
if (!packs.includes(BASE_PACK)) fail(packsDir, `missing base pack "${BASE_PACK}"`);
const skillsByPack = Object.fromEntries(
  packs.map((p) => [p, new Set(readdirSync(join(packsDir, p, "skills")).filter((n) => isDir(join(packsDir, p, "skills", n))))]),
);

const owner = new Map();
for (const [pack, skills] of Object.entries(skillsByPack)) {
  for (const s of skills) {
    if (owner.has(s)) fail(join(packsDir, pack, "skills", s), `skill name also used in pack "${owner.get(s)}"`);
    owner.set(s, pack);
  }
}

const marketplace = readJSON(join(root, ".claude-plugin", "marketplace.json"));
const listed = new Map((marketplace?.plugins ?? []).map((p) => [resolve(root, p.source), p.name]));
let totalMd = 0;

for (const pack of packs) {
  const packDir = join(packsDir, pack);
  const skillsDir = join(packDir, "skills");
  const visible = new Set([...skillsByPack[pack], ...(pack === BASE_PACK ? [] : skillsByPack[BASE_PACK] ?? [])]);

  const claude = readJSON(join(packDir, ".claude-plugin", "plugin.json"));
  const cursor = readJSON(join(packDir, ".cursor-plugin", "plugin.json"));
  if (claude && cursor) {
    if (claude.name !== cursor.name) fail(packDir, `plugin names differ: ${claude.name} vs ${cursor.name}`);
    if (claude.version !== cursor.version) fail(packDir, `plugin versions differ: ${claude.version} vs ${cursor.version}`);
    if (listed.get(packDir) !== claude.name) fail(join(root, ".claude-plugin", "marketplace.json"), `does not list pack "${pack}" as ${claude.name}`);
  }

  for (const name of skillsByPack[pack]) {
    const file = join(skillsDir, name, "SKILL.md");
    if (!existsSync(file)) { fail(join(skillsDir, name), "missing SKILL.md"); continue; }
    const fields = frontmatter(file);
    if (!fields) { fail(file, "missing YAML frontmatter"); continue; }
    if (fields.name !== name) fail(file, `name "${fields.name}" must match directory "${name}"`);
    if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(name) || name.length > 64) fail(file, "name must be lowercase-hyphenated, at most 64 chars");
    if (!fields.description) fail(file, "missing description");
    else if (fields.description.length > 1024) fail(file, `description is ${fields.description.length} chars, max 1024`);
    for (const key of Object.keys(fields)) if (!ALLOWED_KEYS.has(key)) fail(file, `non-portable frontmatter key "${key}"`);
  }

  for (const file of walk(join(packDir, "agents")).filter((f) => f.endsWith(".md"))) {
    const fields = frontmatter(file);
    if (!fields?.name || !fields?.description) fail(file, "agent needs name and description frontmatter");
  }

  const mdFiles = [...walk(skillsDir), ...walk(join(packDir, "agents"))].filter((f) => f.endsWith(".md"));
  totalMd += mdFiles.length;
  for (const file of mdFiles) {
    const text = readFileSync(file, "utf8");
    const prose = text.replace(/```[\s\S]*?```/g, "");
    for (const [, target] of prose.matchAll(/\]\(([^)\s]+)\)/g)) {
      if (/^(https?:|mailto:|#)/.test(target)) continue;
      const path = resolve(dirname(file), target.split("#")[0]);
      if (!path.startsWith(packDir + sep)) fail(file, `link ${target} leaves pack "${pack}"; refer to other packs' skills by name`);
      else if (!existsSync(path)) fail(file, `broken link ${target}`);
    }
    for (const [, ref] of prose.matchAll(/\*\*([a-z0-9]+(?:-[a-z0-9]+)*)\*\* skill/g)) {
      if (visible.has(ref)) continue;
      fail(file, owner.has(ref)
        ? `references "${ref}" from pack "${owner.get(ref)}", which pack "${pack}" cannot depend on`
        : `references unknown skill "${ref}"`);
    }
    for (const [re, why] of HARNESS_SPECIFIC) {
      const hit = text.match(re);
      if (hit) fail(file, `${why}: "${hit[0]}"`);
    }
    if (pack === BASE_PACK && !file.includes(`${sep}unslop${sep}`)) {
      const hit = text.match(STACK_LEAKS);
      if (hit) fail(file, `stack-specific term "${hit[0]}" in the base pack; move it to a stack pack`);
    }
  }
}

const skillCount = Object.values(skillsByPack).reduce((n, s) => n + s.size, 0);
if (errors.length) {
  console.error(errors.join("\n"));
  console.error(`\n${errors.length} problem(s)`);
  process.exit(1);
}
console.log(`ok: ${packs.length} packs (${packs.map((p) => `${p}: ${skillsByPack[p].size}`).join(", ")}), ${skillCount} skills, ${totalMd} markdown files`);
