#!/usr/bin/env bash
# Install Sky Feather V3 global Claude Code personality (macOS, Linux, Git Bash).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

REPO_ROOT="$(sf_repo_root)"
if [[ -n "${1:-}" ]]; then
  REPO_ROOT="$(cd "$1" && pwd)"
fi

MIRROR="$(sf_claude_mirror)"
CLAUDE_MD="$(sf_claude_md_path)"
BUNDLES_DIR="${MIRROR}/bundles"
DEFAULT_CHAR="$(sf_json_default_character)"
MIRROR_HOME="$(sf_claude_mirror_home_display)"

echo "Installing Sky Feather V3.2 global Claude Code setup"
echo "  Repo:      ${REPO_ROOT}"
echo "  Mirror:    ${MIRROR}"
echo "  CLAUDE.md: ${CLAUDE_MD}"

mkdir -p "${MIRROR}"

for item in CORE.md characters skills examples; do
  if [[ -e "${REPO_ROOT}/${item}" ]]; then
    rm -rf "${MIRROR}/${item}"
    cp -R "${REPO_ROOT}/${item}" "${MIRROR}/${item}"
  fi
done

mkdir -p "${MIRROR}/scripts-lib"
cp "${SCRIPT_DIR}/lib/characters.json" "${MIRROR}/scripts-lib/characters.json"
cp "${SCRIPT_DIR}/lib/claude-paths.json" "${MIRROR}/scripts-lib/claude-paths.json"

sf_build_all_bundles "${REPO_ROOT}" "${BUNDLES_DIR}" "${MIRROR_HOME}"

ACTIVE_CHAR="$(sf_sanitize_single_line "${DEFAULT_CHAR}")"
if ! sf_is_valid_character_id "${ACTIVE_CHAR}"; then
  echo "error: invalid default character: ${DEFAULT_CHAR}" >&2
  exit 1
fi

existing="$(sf_json_manifest_active "${MIRROR}/manifest.json")"
if [[ -n "${existing}" && -f "${BUNDLES_DIR}/${existing}.md" ]]; then
  ACTIVE_CHAR="${existing}"
fi

cp "${BUNDLES_DIR}/${ACTIVE_CHAR}.md" "${MIRROR}/active-bundle.md"
sf_write_manifest "${MIRROR}" "${ACTIVE_CHAR}"
sf_write_claude_file "${MIRROR}/active-bundle.md"

sf_install_claude_character_skill "${SCRIPT_DIR}"
sf_sync_claude_global_bin "${SCRIPT_DIR}"

echo ""
echo "Installed V3.2 materials:"
echo "  ${MIRROR}/"
echo "  ${MIRROR}/bundles/"
echo "  ${MIRROR}/active-bundle.md"
echo "  ${CLAUDE_MD}"
echo "  $(sf_claude_character_skill_dir)/SKILL.md"
echo "  $(sf_claude_global_switch_script_sh)"
echo ""
echo "Active character: ${ACTIVE_CHAR}"

sf_print_claude_next_steps
