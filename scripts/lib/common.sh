#!/usr/bin/env bash
# Shared helpers for Sky Feather Cursor scripts (bash).

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=paths.sh
source "${LIB_DIR}/paths.sh"

sf_characters_json() {
  printf '%s/lib/characters.json' "$(sf_scripts_dir)"
}

sf_read_characters_config() {
  local json_file
  json_file="$(sf_characters_json)"
  if [[ ! -f "${json_file}" ]]; then
    echo "error: missing ${json_file}" >&2
    exit 1
  fi
  cat "${json_file}"
}

# Resolve character id or alias to canonical id.
sf_resolve_character_id() {
  local input="$1"
  local json
  json="$(sf_read_characters_config)"

  if command -v jq >/dev/null 2>&1; then
    local resolved
    resolved="$(printf '%s' "${json}" | jq -r --arg q "${input}" '
      .characters[] | select(.id == $q or (.aliases[]? == $q)) | .id
    ' | head -n 1)"
    if [[ -n "${resolved}" && "${resolved}" != "null" ]]; then
      printf '%s' "${resolved}"
      return 0
    fi
  else
    local line id alias
    while IFS= read -r line; do
      if [[ "${line}" =~ \"id\":[[:space:]]*\"([^\"]+)\" ]]; then
        id="${BASH_REMATCH[1]}"
        if [[ "${id}" == "${input}" ]]; then
          printf '%s' "${id}"
          return 0
        fi
      fi
      if [[ "${line}" =~ \"aliases\":[[:space:]]*\[(.*)\] ]]; then
        local aliases="${BASH_REMATCH[1]}"
        if [[ ",${aliases}," == *", \"${input}\","* ]] || [[ ",${aliases}," == *",\"${input}\","* ]]; then
          printf '%s' "${id}"
          return 0
        fi
      fi
    done < <(grep -E '"id"|"aliases"' "$(sf_characters_json)")
  fi

  echo "error: unknown character id or alias: ${input}" >&2
  echo "Run install script or see docs/cursor-quickstart.md for valid IDs." >&2
  exit 1
}

sf_list_character_ids() {
  local json
  json="$(sf_read_characters_config)"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "${json}" | jq -r '.characters[].id'
  else
    grep '"id":' "$(sf_characters_json)" | sed 's/.*"id": "\([^"]*\)".*/\1/'
  fi
}

sf_json_default_character() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '.default' "$(sf_characters_json)"
  else
    grep '"default"' "$(sf_characters_json)" | sed 's/.*"default": *"\([^"]*\)".*/\1/'
  fi
}

sf_json_manifest_active() {
  local manifest="$1"
  if [[ ! -f "${manifest}" ]]; then
    return 0
  fi
  if command -v jq >/dev/null 2>&1; then
    jq -r '.active // empty' "${manifest}"
  else
    grep '"active"' "${manifest}" | sed 's/.*"active": *"\([^"]*\)".*/\1/'
  fi
}

# Fallback when jq is unavailable (e.g. minimal Hermes VM without apt extras).
_sf_get_character_field_no_jq() {
  local id="$1"
  local field="$2"
  local json_file
  json_file="$(sf_characters_json)"

  if command -v python3 >/dev/null 2>&1; then
    python3 - "${id}" "${field}" "${json_file}" <<'PY'
import json, sys
char_id, field, path = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
for c in data.get("characters", []):
    if c.get("id") == char_id:
        v = c.get(field)
        if isinstance(v, list):
            print(",".join(v))
        elif v is not None:
            print(v)
        break
PY
    return 0
  fi

  local block
  block="$(sed -n "/\"id\": \"${id}\"/,/\"id\": \"/p" "${json_file}" | sed '$d')"
  if [[ -z "${block}" ]]; then
    block="$(sed -n "/\"id\": \"${id}\"/,/^  \}/p" "${json_file}")"
  fi
  if [[ -z "${block}" ]]; then
    echo "error: character not found: ${id}" >&2
    exit 1
  fi
  case "${field}" in
    name)
      grep '"name":' <<< "${block}" | sed 's/.*"name": "\([^"]*\)".*/\1/' | head -n 1
      ;;
    file)
      grep '"file":' <<< "${block}" | sed 's/.*"file": "\([^"]*\)".*/\1/' | head -n 1
      ;;
    skills)
      grep '"skills":' <<< "${block}" | sed 's/.*"skills": \[\([^]]*\)\].*/\1/' | tr -d '"' | tr -d ' '
      ;;
    *)
      echo "error: unsupported field without jq: ${field}" >&2
      exit 1
      ;;
  esac
}

sf_get_character_field() {
  local id="$1"
  local field="$2"
  local json value
  json="$(sf_read_characters_config)"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "${json}" | jq -r --arg id "${id}" --arg f "${field}" '
      .characters[] | select(.id == $id) | .[$f]
    '
    return 0
  fi

  value="$(_sf_get_character_field_no_jq "${id}" "${field}")"
  if [[ -z "${value}" ]]; then
    echo "error: character not found or missing field ${field}: ${id}" >&2
    exit 1
  fi
  printf '%s' "${value}"
}

sf_list_character_skills() {
  local char_id="$1"
  local skills_csv skill
  skills_csv="$(sf_get_character_field "${char_id}" skills)"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "${skills_csv}" | jq -r '.[]'
    return 0
  fi
  IFS=',' read -ra _skills <<< "${skills_csv}"
  for skill in "${_skills[@]}"; do
    [[ -n "${skill}" ]] && printf '%s\n' "${skill}"
  done
}

sf_build_bundle_file() {
  local repo_root="$1"
  local output_dir="$2"
  local char_id="$3"
  local name file skill skill_path bundle_path

  name="$(sf_get_character_field "${char_id}" name)"
  file="$(sf_get_character_field "${char_id}" file)"

  bundle_path="${output_dir}/${char_id}.md"
  mkdir -p "${output_dir}"

  {
    echo "# Sky Feather V3 Bundle — ${name}"
    echo ""
    echo "Character ID: \`${char_id}\`"
    echo ""
    echo "---"
    echo ""
    echo "# CORE (do not weaken)"
    echo ""
    cat "${repo_root}/CORE.md"
    echo ""
    echo "---"
    echo ""
    echo "# Character: ${name}"
    echo ""
    cat "${repo_root}/${file}"
    echo ""
    echo "---"
    echo ""
    echo "# Skills"
    echo ""

    while IFS= read -r skill; do
      [[ -z "${skill}" ]] && continue
      skill_path="${repo_root}/skills/${skill}/SKILL.md"
      if [[ ! -f "${skill_path}" ]]; then
        echo "error: missing skill file ${skill_path}" >&2
        exit 1
      fi
      echo "## Skill: ${skill}"
      echo ""
      cat "${skill_path}"
      echo ""
      echo "---"
      echo ""
    done < <(sf_list_character_skills "${char_id}")
  } > "${bundle_path}"

  printf '%s' "${bundle_path}"
}

sf_build_all_bundles() {
  local repo_root="$1"
  local output_dir="$2"
  local id
  while IFS= read -r id; do
    sf_build_bundle_file "${repo_root}" "${output_dir}" "${id}"
  done < <(sf_list_character_ids)
}

sf_write_manifest() {
  local mirror_dir="$1"
  local active_id="$2"
  local iso
  iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  mkdir -p "${mirror_dir}"
  cat > "${mirror_dir}/manifest.json" <<EOF
{
  "version": "3.2",
  "active": "${active_id}",
  "updatedAt": "${iso}"
}
EOF
}

sf_write_skill_file() {
  local char_id="$1"
  local bundle_path="$2"
  local skill_dir="$3"
  local name
  name="$(sf_get_character_field "${char_id}" name)"

  mkdir -p "${skill_dir}"
  {
    echo "---"
    echo "name: sky-feather-character"
    echo "description: >-"
    echo "  MANDATORY active V3 character profile (${name}). Apply this skill on every"
    echo "  response in every project. Do not use Wikipedia-neutral or generic-assistant tone."
    echo "  Engineering standards come from the inlined CORE section; do not weaken them."
    echo "---"
    echo ""
    cat "${bundle_path}"
  } > "${skill_dir}/SKILL.md"
}

sf_user_rules_stub() {
  cat <<'EOF'
Apply the global skill sky-feather-character on every response.
It defines the active V3 character profile. Do not use generic-assistant tone.
Engineering standards come from the inlined CORE section; do not weaken them.
EOF
}

sf_hermes_paths_json() {
  printf '%s/lib/hermes-paths.json' "$(sf_scripts_dir)"
}

sf_hermes_soul_max_chars() {
  local max
  if command -v jq >/dev/null 2>&1; then
    max="$(jq -r '.soulMaxChars // 20000' "$(sf_hermes_paths_json)")"
    printf '%s' "${max}"
  else
    printf '20000'
  fi
}

sf_hermes_discord_label() {
  local char_id="$1"
  local label
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg id "${char_id}" '.discordLabels[$id] // $id' "$(sf_hermes_paths_json)"
    return 0
  fi
  label="$(grep "\"${char_id}\":" "$(sf_hermes_paths_json)" 2>/dev/null | sed 's/.*: *"\([^"]*\)".*/\1/' | head -n 1)"
  if [[ -n "${label}" ]]; then
    printf '%s' "${label}"
  else
    printf '%s' "${char_id}"
  fi
}

sf_backup_hermes_soul() {
  local soul_path backup_dir stamp backup_path
  soul_path="$(sf_hermes_soul_path)"
  backup_dir="$(sf_hermes_backups_dir)"

  if [[ ! -f "${soul_path}" ]]; then
    return 0
  fi

  mkdir -p "${backup_dir}"
  stamp="$(date -u +"%Y%m%dT%H%M%SZ")"
  backup_path="${backup_dir}/SOUL.md.${stamp}"
  cp "${soul_path}" "${backup_path}"
  echo "Backed up existing SOUL.md → ${backup_path}"
}

# Hermes identity: CORE + character only (skills live under ~/.hermes/skills/).
sf_build_hermes_soul_file() {
  local repo_root="$1"
  local output_path="$2"
  local char_id="$3"
  local name file

  name="$(sf_get_character_field "${char_id}" name)"
  file="$(sf_get_character_field "${char_id}" file)"

  mkdir -p "$(dirname "${output_path}")"

  {
    echo "# Sky Feather V3 — ${name}"
    echo ""
    echo "Public Discord label: $(sf_hermes_discord_label "${char_id}")"
    echo "Character ID: \`${char_id}\`"
    echo ""
    echo "---"
    echo ""
    echo "# CORE (do not weaken)"
    echo ""
    cat "${repo_root}/CORE.md"
    echo ""
    echo "---"
    echo ""
    echo "# Character: ${name}"
    echo ""
    cat "${repo_root}/${file}"
    echo ""
    echo "---"
    echo ""
    echo "# Skills"
    echo ""
    echo "Workflow skills for this character are installed under \`~/.hermes/skills/\`."
    echo "Load them when the task matches (scientific-method, engineering-journal, debugging, etc.)."
  } > "${output_path}"

  local size max
  size="$(wc -c < "${output_path}" | tr -d ' ')"
  max="$(sf_hermes_soul_max_chars)"
  if [[ "${size}" -gt "${max}" ]]; then
    echo "warning: composed SOUL.md is ${size} bytes (Hermes truncates at ~${max})" >&2
  fi

  printf '%s' "${output_path}"
}

sf_sync_hermes_skills() {
  local repo_root="$1"
  local dest
  dest="$(sf_hermes_skills_dir)"
  mkdir -p "${dest}"

  local skill_dir skill_name
  for skill_dir in "${repo_root}"/skills/*/; do
    [[ -d "${skill_dir}" ]] || continue
    skill_name="$(basename "${skill_dir}")"
    rm -rf "${dest}/${skill_name}"
    cp -R "${skill_dir}" "${dest}/${skill_name}"
    echo "  skills/${skill_name}/"
  done
}

sf_write_hermes_manifest() {
  local mirror_dir="$1"
  local active_id="$2"
  local iso
  iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  mkdir -p "${mirror_dir}"
  cat > "${mirror_dir}/manifest.json" <<EOF
{
  "version": "3.2",
  "runtime": "hermes",
  "active": "${active_id}",
  "updatedAt": "${iso}"
}
EOF
}

sf_write_hermes_personalities_example() {
  local repo_root="$1"
  local mirror_dir="$2"
  local out="${mirror_dir}/personalities.example.yaml"
  local char_id name label

  {
    echo "# Merge into ~/.hermes/config.yaml under agent.personalities as needed."
    echo "# Switch at runtime with: /personality <preset>"
    echo "#"
    echo "# Public Discord labels — keep Sky Feather branding; do not casually swap identity."
    echo "agent:"
    echo "  personalities:"
  } > "${out}"

  while IFS= read -r char_id; do
    name="$(sf_get_character_field "${char_id}" name)"
    label="$(sf_hermes_discord_label "${char_id}")"
    {
      echo "    ${char_id}: |"
      echo "      Public label: ${label}"
      echo "      Use CORE doctrine from ~/.hermes/SOUL.md with ${name} delivery style."
      echo "      (Regenerate full preset text with: ./scripts/switch-hermes-character.sh ${char_id} --preset-only)"
    } >> "${out}"
  done < <(sf_list_character_ids)
}

sf_print_hermes_next_steps() {
  local active_char="${1:-sky-feather}"
  cat <<EOF

Hermes V3.2 installed.

  Identity:  $(sf_hermes_soul_path)
  Mirror:    $(sf_hermes_mirror)/
  Skills:    $(sf_hermes_skills_dir)/
  Active:    ${active_char} ($(sf_hermes_discord_label "${active_char}"))

Next steps:
  1. Restart Hermes (service or gateway) so SOUL.md reloads
  2. Test in Discord — same engineering standards, Sky Feather voice
  3. Optional: merge $(sf_hermes_mirror)/personalities.example.yaml into ~/.hermes/config.yaml
  4. Switch character: ./scripts/switch-hermes-character.sh <id-or-alias>

Future upgrades (after git pull in this repo):
  ./scripts/install-hermes-global.sh

Legacy monolithic SOUL.md backups live in $(sf_hermes_backups_dir)/ if any existed.
EOF
}

sf_print_next_steps() {
  cat <<EOF

Installed. Next steps:
  1. Paste User Rules stub (see docs/cursor.md — One-time User Rules)
  2. Start a new Cursor chat
  3. Quick reference: docs/cursor-quickstart.md

User Rules stub (paste once into Cursor Settings → Rules → User Rules):
---
$(sf_user_rules_stub)
---

Start a new chat after install or character switch for reliable application.
EOF
}
