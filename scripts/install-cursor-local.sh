#!/usr/bin/env bash
# Copy Sky Feather V3 files from this repo into ~/.cursor/ (personal global install).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -n "${1:-}" ]]; then
  REPO_ROOT="$(cd "$1" && pwd)"
fi

DEST="${HOME}/.cursor/sky-feather"
SKILL_DEST="${HOME}/.cursor/skills/sky-feather-soul"

mkdir -p "${DEST}" "${SKILL_DEST}"

cp "${REPO_ROOT}/CORE.md" "${DEST}/CORE.md"
cp "${REPO_ROOT}/SOUL.md" "${DEST}/SOUL.md"

rm -rf "${DEST}/characters" "${DEST}/skills" "${DEST}/examples"
cp -R "${REPO_ROOT}/characters" "${DEST}/characters"
cp -R "${REPO_ROOT}/skills" "${DEST}/skills"
cp -R "${REPO_ROOT}/examples" "${DEST}/examples"

# Legacy Cursor skill mirror for older SOUL.md workflows.
cp "${REPO_ROOT}/examples/cursor/sky-feather-soul.mdc" "${DEST}/sky-feather-soul.mdc"
cp "${REPO_ROOT}/examples/cursor/SKILL.md" "${SKILL_DEST}/SKILL.md"
cp "${REPO_ROOT}/SOUL.md" "${SKILL_DEST}/SOUL.md"

cat <<EOF
Installed V3 materials:
  ${DEST}/CORE.md
  ${DEST}/SOUL.md
  ${DEST}/characters/
  ${DEST}/skills/
  ${DEST}/examples/

Installed legacy SOUL.md mirror:
  ${DEST}/sky-feather-soul.mdc
  ${SKILL_DEST}/SKILL.md
  ${SKILL_DEST}/SOUL.md

Next: paste or reference the desired composition in Cursor Settings → Rules → User Rules.
EOF
