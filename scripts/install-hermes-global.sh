#!/usr/bin/env bash
# Install Sky Feather V3.2 on Hermes Agent (~/.hermes/SOUL.md + skills + personalities).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

LEGACY=0
REPO_ROOT="$(sf_repo_root)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --legacy)
      LEGACY=1
      shift
      ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--legacy] [REPO_ROOT]

Install Sky Feather on Hermes Agent.

  Default (V3.2 Route B): slim SOUL (CORE + branding), sync workflow skills,
                          install the character switch skill under ~/.hermes/skills/sky-feather-characters/character/.
  --legacy:              copy monolithic SOUL.md only (V1-style drop-in).

Existing ~/.hermes/SOUL.md is backed up before overwrite.

Environment:
  HERMES_HOME   Hermes instance home (default: ~/.hermes)
EOF
      exit 0
      ;;
    *)
      REPO_ROOT="$(cd "$1" && pwd)"
      shift
      ;;
  esac
done

HERMES_HOME="$(sf_hermes_home)"
MIRROR="$(sf_hermes_mirror)"
SOUL_PATH="$(sf_hermes_soul_path)"
DEFAULT_CHAR="$(sf_json_default_character)"

echo "Installing Sky Feather on Hermes"
echo "  Repo:        ${REPO_ROOT}"
echo "  HERMES_HOME: ${HERMES_HOME}"
echo "  Mode:        $([[ "${LEGACY}" -eq 1 ]] && echo 'legacy SOUL.md' || echo 'V3.2 Route B (slim SOUL + character skills)')"

sf_backup_hermes_soul

if [[ "${LEGACY}" -eq 1 ]]; then
  cp "${REPO_ROOT}/SOUL.md" "${SOUL_PATH}"
  echo ""
  echo "Installed legacy SOUL.md → ${SOUL_PATH}"
  echo "Restart Hermes to reload identity."
  exit 0
fi

mkdir -p "${MIRROR}"

for item in CORE.md SOUL.md characters skills examples; do
  if [[ -e "${REPO_ROOT}/${item}" ]]; then
    rm -rf "${MIRROR}/${item}"
    cp -R "${REPO_ROOT}/${item}" "${MIRROR}/${item}"
  fi
done

mkdir -p "${MIRROR}/scripts-lib"
cp "${SCRIPT_DIR}/lib/characters.json" "${MIRROR}/scripts-lib/characters.json"
cp "${SCRIPT_DIR}/lib/hermes-paths.json" "${MIRROR}/scripts-lib/hermes-paths.json"

ACTIVE_CHAR="$(sf_sanitize_single_line "${DEFAULT_CHAR}")"
if ! sf_is_valid_character_id "${ACTIVE_CHAR}"; then
  echo "error: invalid default character: ${DEFAULT_CHAR}" >&2
  exit 1
fi

existing="$(sf_json_manifest_active "${MIRROR}/manifest.json")"
if [[ -n "${existing}" ]]; then
  ACTIVE_CHAR="${existing}"
fi

sf_build_hermes_soul_core_file "${REPO_ROOT}" "${SOUL_PATH}"
cp "${SOUL_PATH}" "${MIRROR}/active-soul.md"
sf_write_hermes_manifest "${MIRROR}" "${ACTIVE_CHAR}"

sf_write_hermes_character_skills_index "${MIRROR}"

echo ""
echo "Syncing workflow skills → $(sf_hermes_skills_dir)/"
sf_sync_hermes_skills "${REPO_ROOT}"

echo ""
echo "Installing character skills → $(sf_hermes_character_skills_dir)/"
sf_install_hermes_character_skills "${REPO_ROOT}"

echo ""
echo "Installed:"
echo "  ${SOUL_PATH}"
echo "  ${MIRROR}/"
echo "  $(sf_hermes_skills_dir)/"
echo "  $(sf_hermes_character_skills_dir)/"

sf_print_hermes_next_steps "${ACTIVE_CHAR}"
