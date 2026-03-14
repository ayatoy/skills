#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest_root="${1:-$HOME/.agents/skills}"

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is required but was not found in PATH." >&2
  exit 1
fi

mkdir -p "$dest_root"

shopt -s nullglob
skill_mds=("$repo_root"/*/SKILL.md)
shopt -u nullglob

if [ "${#skill_mds[@]}" -eq 0 ]; then
  echo "No skills found under $repo_root." >&2
  exit 1
fi

for skill_md in "${skill_mds[@]}"; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"

  echo "Installing $skill_name"
  rsync -a --delete \
    --exclude='.git/' \
    --exclude='.DS_Store' \
    "$skill_dir/" \
    "$dest_root/$skill_name/"
done

echo "Installed ${#skill_mds[@]} skill(s) into $dest_root"
