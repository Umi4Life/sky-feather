#!/usr/bin/env bash
# Switch active Sky Feather character on Hermes.
# Primary switch: /skill character <key> in Discord (no restart needed).
# Legacy ops path: rewrites ~/.hermes/SOUL.md server-wide (requires restart).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

SKILL_KEY_ONLY=0
CHAR_INPUT=""
REPO_ROOT="$(sf_repo_root)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill-key)
      SKILL_KEY_ONLY=1
      shift
      ;;
    -h|--help)
      cat <<EOF
Usage: $0 <character-id-or-alias> [--skill-key] [REPO_ROOT]

Primary Discord switch (no restart required):
  /skill character <key>
  Example: /skill character setsuna

Options:
  --skill-key   Print the /skill character key for Discord without writing SOUL.md

Legacy server-wide SOUL switch (requires gateway restart):
  $0 setsuna
  sudo systemctl restart hermes-gateway

Examples:
  $0 setsuna --skill-key
  $0 kaede
EOF
      exit 0
      ;;
    *)
      if [[ -z "${CHAR_INPUT}" ]]; then
        CHAR_INPUT="$1"
      else
        REPO_ROOT="$(cd "$1" && pwd)"
      fi
      shift
      ;;
  esac
done

if [[ -z "${CHAR_INPUT}" ]]; then
  echo "error: character id or alias required" >&2
  exit 1
fi

CHAR_ID="$(sf_resolve_character_id "${CHAR_INPUT}")"
MIRROR="$(sf_hermes_mirror)"
SOUL_PATH="$(sf_hermes_soul_path)"
SKILL_KEY="$(sf_get_character_personality_key "${CHAR_ID}")"
DISCORD_LABEL="$(sf_hermes_discord_label "${CHAR_ID}")"

if [[ ! -d "${MIRROR}" ]]; then
  echo "error: Hermes mirror not found at ${MIRROR}" >&2
  echo "Run bash scripts/install-hermes-global.sh first." >&2
  exit 1
fi

if [[ "${SKILL_KEY_ONLY}" -eq 1 ]]; then
  echo "Use /skill character ${SKILL_KEY} in Discord"
  echo "  Label: ${DISCORD_LABEL}"
  echo "  Character id: ${CHAR_ID}"
  exit 0
fi

sf_build_hermes_soul_file "${REPO_ROOT}" "${SOUL_PATH}" "${CHAR_ID}"
cp "${SOUL_PATH}" "${MIRROR}/active-soul.md"
sf_write_hermes_manifest "${MIRROR}" "${CHAR_ID}"

echo "Active character: ${CHAR_ID} (${DISCORD_LABEL})"
echo "Updated: ${SOUL_PATH}"
echo ""
echo "Legacy server-wide SOUL switch — restart Hermes:"
echo "  sudo systemctl restart hermes-gateway"
echo ""
echo "Preferred: /skill character ${SKILL_KEY} in Discord (no restart required)"
