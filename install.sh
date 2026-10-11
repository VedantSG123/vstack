#!/usr/bin/env bash
# Symlink vstack packs' skills (and agents, where the harness supports them) into one or more agent harnesses.
set -euo pipefail

usage() {
  cat <<USAGE
Usage: ./install.sh [--pack PACK]... [--project DIR] [--uninstall] HARNESS...

Harnesses: claude  cursor  codex  gemini  agents  all
Packs:     core  ts  (default: every pack; any stack pack also installs core)

  --pack PACK     Install only this pack. Repeat for several.
  --project DIR   Install into DIR/.<harness>/ instead of your home directory.
  --uninstall     Remove the links this script created.

Examples:
  ./install.sh claude cursor
  ./install.sh --pack core codex
  ./install.sh --project ~/work/my-electron-app agents
  ./install.sh --uninstall all
USAGE
}

# Git Bash and Cygwin copy instead of linking unless told otherwise, which breaks live edits and --uninstall.
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) export MSYS=winsymlinks:nativestrict CYGWIN=winsymlinks:nativestrict ;; esac

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base="$HOME"
uninstall=0
harnesses=()
packs=()

while (($#)); do
  case "$1" in
    --project) base="$(cd "$2" && pwd)"; shift 2 ;;
    --uninstall) uninstall=1; shift ;;
    --pack)
      [[ -d "$src/packs/$2" ]] || { echo "unknown pack: $2" >&2; exit 2; }
      packs+=("$2"); shift 2 ;;
    -h|--help) usage; exit 0 ;;
    all) harnesses+=(claude cursor codex gemini agents); shift ;;
    claude|cursor|codex|gemini|agents) harnesses+=("$1"); shift ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done
((${#harnesses[@]})) || { usage >&2; exit 2; }
if ((${#packs[@]} == 0)); then
  for p in "$src"/packs/*/; do p="${p%/}"; packs+=("${p##*/}"); done
elif [[ ! " ${packs[*]} " =~ " core " ]] && ((! uninstall)); then
  packs=(core "${packs[@]}")
fi

link() {
  local from="$1" to="$2"
  if [[ -L "$to" ]]; then
    local current; current="$(readlink "$to")"
    if [[ "$current" == "$from" ]]; then
      ((uninstall)) && rm "$to" && echo "  removed $to"
      return 0
    fi
    echo "  skip $to (links to $current, not vstack)" >&2; return 0
  fi
  ((uninstall)) && return 0
  if [[ -e "$to" ]]; then echo "  skip $to (already exists)" >&2; return 0; fi
  mkdir -p "$(dirname "$to")"
  ln -s "$from" "$to" 2>/dev/null || {
    echo "cannot create a symlink at $to. On Windows, enable Developer Mode or run install.ps1 instead." >&2
    exit 1
  }
  echo "  linked $to"
}

for h in "${harnesses[@]}"; do
  dir="$base/.$h"
  echo "$h -> $dir"
  for pack in "${packs[@]}"; do
    for skill in "$src/packs/$pack"/skills/*/; do
      skill="${skill%/}"
      link "$skill" "$dir/skills/$(basename "$skill")"
    done
    case "$h" in
      claude|cursor)
        for agent in "$src/packs/$pack"/agents/*.md; do
          [[ -e "$agent" ]] && link "$agent" "$dir/agents/$(basename "$agent")"
        done ;;
    esac
  done
done
