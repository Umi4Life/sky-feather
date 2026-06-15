#!/usr/bin/env bash
# Switch active global Claude Code character profile.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if [[ $# -lt 1 ]]; then
  echo "usage: $(basename "$0") <character-id-or-alias>" >&2
  echo "Valid IDs:" >&2
  sf_list_character_ids | sed 's/^/  /' >&2
  exit 1
fi

CHAR_ID="$(sf_resolve_character_id "$1")"
MIRROR="$(sf_claude_mirror)"
BUNDLES_DIR="${MIRROR}/bundles"
BUNDLE="${BUNDLES_DIR}/${CHAR_ID}.md"

if [[ ! -f "${BUNDLE}" ]]; then
  echo "error: bundle not found: ${BUNDLE}" >&2
  echo "Run ./scripts/install-claude-global.sh first." >&2
  exit 1
fi

cp "${BUNDLE}" "${MIRROR}/active-bundle.md"
sf_write_manifest "${MIRROR}" "${CHAR_ID}"
sf_write_claude_file "${MIRROR}/active-bundle.md" "${MIRROR}/claude-drops/${CHAR_ID}.md"

NAME="$(sf_get_character_field "${CHAR_ID}" name)"
echo "Switched active character to: ${NAME} (${CHAR_ID})"
echo "  $(sf_claude_md_path)"
echo ""
echo "Start a new Claude Code session for reliable application."
