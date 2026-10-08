#!/usr/bin/env bash
# Fails if a shipped SKILL.md builds a path on ${CLAUDE_SKILL_DIR}.
#
# Claude Code expands that variable; Cursor, Codex, and Copilot do not, so a
# path built on it is a path those tools cannot open. Each SKILL.md names it
# exactly once, in the line under Purpose that says where the skill's own files
# are, and refers to those files by paths relative to the SKILL.md everywhere
# else.
#
#   bash scripts/check-portable-paths.sh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
definition='This skill'"'"'s own files, such as `decisions-protocol.md`, are in the folder that contains this `SKILL.md`, and every path to one of them below is relative to that folder. In Claude Code, that folder is `${CLAUDE_SKILL_DIR}`.'

fail=0
count=0
for skill in "$root"/skills/*/*/SKILL.md; do
  rel="${skill#"$root"/}"
  count=$((count + 1))
  if ! grep -qxF -- "$definition" "$skill"; then
    echo "missing the line that says where the skill's files are: $rel"
    fail=1
  fi
  while IFS= read -r hit; do
    [[ "${hit#*:}" == "$definition" ]] && continue
    echo "path built on \${CLAUDE_SKILL_DIR}: $rel line ${hit%%:*}"
    fail=1
  done < <(grep -nF -- '${CLAUDE_SKILL_DIR}' "$skill" || true)
done

if (( fail )); then
  echo "Refer to the skill's own files by paths relative to its SKILL.md. See CONTRIBUTING.md, 'Paths inside a skill'."
  exit 1
fi
echo "All $count skills use paths that work in every tool."
