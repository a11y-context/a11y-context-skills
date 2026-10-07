#!/usr/bin/env bash
# Copies shared/decisions-protocol.md into every skill variant.
#
# Each variant ships as its own zip of its own folder, so a file at the
# repository root reaches no one. The source lives once, in shared/, and this
# script puts an identical copy beside every SKILL.md.
#
#   bash scripts/sync-shared.sh           copy into every variant; commit the result
#   bash scripts/sync-shared.sh --check   change nothing; exit 1 if any copy differs
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
src="$root/shared/decisions-protocol.md"
check=0
[[ "${1:-}" == "--check" ]] && check=1

fail=0
count=0
for skill in "$root"/skills/*/*/SKILL.md; do
  dest="$(dirname "$skill")/decisions-protocol.md"
  count=$((count + 1))
  if (( check )); then
    if ! cmp -s "$src" "$dest"; then
      echo "out of date: ${dest#"$root"/}"
      fail=1
    fi
  else
    cp "$src" "$dest"
  fi
done

if (( check )); then
  if (( fail )); then
    echo "Run scripts/sync-shared.sh and commit the result."
    exit 1
  fi
  echo "decisions-protocol.md is identical in all $count variants."
else
  echo "Copied decisions-protocol.md into $count variants."
fi
