#!/usr/bin/env bash
# Uninstall / prune Sky Feather global Claude Code artifacts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      echo "usage: $(basename "$0") [--dry-run]"
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

remove_path() {
  local path="$1"
  if [[ -e "${path}" ]]; then
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      echo "would remove: ${path}"
    else
      rm -rf "${path}"
      echo "removed: ${path}"
    fi
  fi
}

remove_path "$(sf_claude_mirror)"
remove_path "$(sf_claude_character_skill_dir)"

if sf_is_managed_claude_md; then
  remove_path "$(sf_claude_md_path)"
else
  echo "skipped (not managed by sky-feather): $(sf_claude_md_path)"
fi

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo ""
  echo "Dry run complete. No files deleted."
else
  echo ""
  echo "Uninstall complete."
fi

cat <<'EOF'

Manual step: if you customized ~/.claude/CLAUDE.md before install, review it after uninstall.
Start a new Claude Code session if you removed managed CLAUDE.md.
EOF
