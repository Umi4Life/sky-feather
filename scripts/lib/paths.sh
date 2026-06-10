#!/usr/bin/env bash
# Resolve Cursor global paths (macOS, Linux, Git Bash on Windows).

sf_cursor_home() {
  if [[ -n "${CURSOR_HOME:-}" ]]; then
    printf '%s' "${CURSOR_HOME}"
    return
  fi
  printf '%s/.cursor' "${HOME}"
}

sf_repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${script_dir}/../.." && pwd
}

sf_scripts_dir() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${script_dir}/.." && pwd
}

sf_sky_feather_mirror() {
  printf '%s/sky-feather' "$(sf_cursor_home)"
}

sf_global_bin_dir() {
  printf '%s/bin' "$(sf_sky_feather_mirror)"
}

sf_global_switch_script_sh() {
  printf '%s/switch-character.sh' "$(sf_global_bin_dir)"
}

sf_skill_character_dir() {
  printf '%s/skills/sky-feather-character' "$(sf_cursor_home)"
}

sf_legacy_skill_dir() {
  printf '%s/skills/sky-feather-soul' "$(sf_cursor_home)"
}

sf_commands_dir() {
  printf '%s/commands' "$(sf_cursor_home)"
}

sf_hermes_home() {
  if [[ -n "${HERMES_HOME:-}" ]]; then
    printf '%s' "${HERMES_HOME}"
    return
  fi
  printf '%s/.hermes' "${HOME}"
}

sf_hermes_mirror() {
  printf '%s/sky-feather' "$(sf_hermes_home)"
}

sf_hermes_soul_path() {
  printf '%s/SOUL.md' "$(sf_hermes_home)"
}

sf_hermes_skills_dir() {
  printf '%s/skills' "$(sf_hermes_home)"
}

sf_hermes_backups_dir() {
  printf '%s/backups' "$(sf_hermes_home)"
}
