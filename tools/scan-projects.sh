#!/usr/bin/env bash
# Emit a starter township registry from the AI projects folder.
# Run on the Mac:  bash tools/scan-projects.sh > projects.json
set -u
ROOT="${1:-$HOME/Documents/_MEXILLICIOUS/AI}"

esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

printf '{\n  "root": "%s",\n  "scanned": "%s",\n  "candidates": [\n' \
  "$(esc "$ROOT")" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

first=1
for dir in "$ROOT"/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  id=$(printf '%s' "$name" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-')

  git_repo=false; remote=""; branch=""; last=""; commits=0
  if [ -d "$dir/.git" ]; then
    git_repo=true
    remote=$(git -C "$dir" remote get-url origin 2>/dev/null || echo "")
    branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    last=$(git -C "$dir" log -1 --format=%cI 2>/dev/null || echo "")
    commits=$(git -C "$dir" rev-list --count HEAD 2>/dev/null || echo 0)
  fi

  # cheap signals for "is this a real project of mine"
  files=$(find "$dir" -type f -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ')
  touched=$(find "$dir" -type f -not -path '*/.git/*' -not -path '*/node_modules/*' -mtime -30 2>/dev/null | wc -l | tr -d ' ')
  vendored=false
  [ -d "$dir/node_modules" ] && vendored=true
  readme=""
  for f in README.md readme.md README; do
    [ -f "$dir$f" ] && { readme=$(head -c 240 "$dir$f" | tr '\n' ' ' | sed 's/  */ /g'); break; }
  done

  [ $first -eq 1 ] || printf ',\n'
  first=0
  printf '    {\n'
  printf '      "id": "%s",\n'          "$(esc "$id")"
  printf '      "name": "%s",\n'        "$(esc "$name")"
  printf '      "path": "%s",\n'        "$(esc "${dir%/}")"
  printf '      "git": %s,\n'           "$git_repo"
  printf '      "remote": "%s",\n'      "$(esc "$remote")"
  printf '      "branch": "%s",\n'      "$(esc "$branch")"
  printf '      "lastCommit": "%s",\n'  "$(esc "$last")"
  printf '      "commits": %s,\n'       "${commits:-0}"
  printf '      "files": %s,\n'         "${files:-0}"
  printf '      "filesTouched30d": %s,\n' "${touched:-0}"
  printf '      "hasNodeModules": %s,\n' "$vendored"
  printf '      "readme": "%s",\n'      "$(esc "$readme")"
  printf '      "township": null,\n'
  printf '      "kit": null,\n'
  printf '      "accent": null\n'
  printf '    }'
done
printf '\n  ]\n}\n'
