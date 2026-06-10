#!/usr/bin/env bash
# Install Sky Feather V3 global Cursor personality (macOS, Linux, Git Bash).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

REPO_ROOT="$(sf_repo_root)"
if [[ -n "${1:-}" ]]; then
  REPO_ROOT="$(cd "$1" && pwd)"
fi

MIRROR="$(sf_sky_feather_mirror)"
SKILL_DIR="$(sf_skill_character_dir)"
COMMANDS_DIR="$(sf_commands_dir)"
BUNDLES_DIR="${MIRROR}/bundles"
DEFAULT_CHAR="$(sf_json_default_character)"

echo "Installing Sky Feather V3.2 global Cursor setup"
echo "  Repo:   ${REPO_ROOT}"
echo "  Mirror: ${MIRROR}"
echo "  Skill:  ${SKILL_DIR}"

# Remove legacy V1 skill if present
if [[ -d "$(sf_legacy_skill_dir)" ]]; then
  echo "Removing legacy skill: $(sf_legacy_skill_dir)"
  rm -rf "$(sf_legacy_skill_dir)"
fi

mkdir -p "${MIRROR}" "${SKILL_DIR}" "${COMMANDS_DIR}"

# Sync source mirror (preserve bundles dir separately)
for item in CORE.md SOUL.md characters skills examples; do
  if [[ -e "${REPO_ROOT}/${item}" ]]; then
    rm -rf "${MIRROR}/${item}"
    cp -R "${REPO_ROOT}/${item}" "${MIRROR}/${item}"
  fi
done

# Copy scripts lib for offline reference
mkdir -p "${MIRROR}/scripts-lib"
cp "${SCRIPT_DIR}/lib/characters.json" "${MIRROR}/scripts-lib/characters.json"
cp "${SCRIPT_DIR}/lib/cursor-paths.json" "${MIRROR}/scripts-lib/cursor-paths.json"

# Build bundles
sf_build_all_bundles "${REPO_ROOT}" "${BUNDLES_DIR}"

# Active character: preserve from manifest if exists, else default
ACTIVE_CHAR="${DEFAULT_CHAR}"
existing="$(sf_json_manifest_active "${MIRROR}/manifest.json")"
if [[ -n "${existing}" && -f "${BUNDLES_DIR}/${existing}.md" ]]; then
  ACTIVE_CHAR="${existing}"
fi

cp "${BUNDLES_DIR}/${ACTIVE_CHAR}.md" "${MIRROR}/active-bundle.md"
sf_write_manifest "${MIRROR}" "${ACTIVE_CHAR}"
sf_write_skill_file "${ACTIVE_CHAR}" "${MIRROR}/active-bundle.md" "${SKILL_DIR}"

# Install slash command template
cp "${REPO_ROOT}/scripts/templates/character-command.md" "${COMMANDS_DIR}/character.md"

echo ""
echo "Installed V3.2 materials:"
echo "  ${MIRROR}/"
echo "  ${MIRROR}/bundles/"
echo "  ${MIRROR}/active-bundle.md"
echo "  ${SKILL_DIR}/SKILL.md"
echo "  ${COMMANDS_DIR}/character.md"
echo ""
echo "Active character: ${ACTIVE_CHAR}"

sf_print_next_steps
