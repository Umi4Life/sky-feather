#!/usr/bin/env bash
# Shared helpers for Sky Feather Cursor scripts (bash).

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=paths.sh
source "${LIB_DIR}/paths.sh"

sf_characters_json() {
  local hermes_json cursor_json claude_json
  hermes_json="$(sf_hermes_mirror)/scripts-lib/characters.json"
  if [[ -f "${hermes_json}" ]]; then
    printf '%s' "${hermes_json}"
    return
  fi
  cursor_json="$(sf_sky_feather_mirror)/scripts-lib/characters.json"
  if [[ -f "${cursor_json}" ]]; then
    printf '%s' "${cursor_json}"
    return
  fi
  claude_json="$(sf_claude_mirror)/scripts-lib/characters.json"
  if [[ -f "${claude_json}" ]]; then
    printf '%s' "${claude_json}"
    return
  fi
  printf '%s/lib/characters.json' "$(sf_scripts_dir)"
}

sf_sync_global_bin() {
  local repo_scripts_dir="$1"
  local bin_dir
  bin_dir="$(sf_global_bin_dir)"
  mkdir -p "${bin_dir}"

  for name in switch-character.sh switch-character.ps1 switch-character.cmd switch-character-lite.cmd; do
    if [[ -f "${repo_scripts_dir}/${name}" ]]; then
      cp "${repo_scripts_dir}/${name}" "${bin_dir}/${name}"
    fi
  done

  rm -rf "${bin_dir}/lib"
  cp -R "${repo_scripts_dir}/lib" "${bin_dir}/lib"
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

sf_sanitize_single_line() {
  printf '%s' "$1" | head -n 1 | tr -d '\r'
}

sf_is_valid_character_id() {
  local id="$1" valid
  id="$(sf_sanitize_single_line "${id}")"
  [[ -z "${id}" ]] && return 1
  while IFS= read -r valid; do
    [[ "${id}" == "${valid}" ]] && return 0
  done < <(sf_list_character_ids)
  return 1
}

sf_json_default_character() {
  local value
  if command -v jq >/dev/null 2>&1; then
    value="$(jq -r '.default' "$(sf_characters_json)")"
  elif command -v python3 >/dev/null 2>&1; then
    value="$(python3 - "$(sf_characters_json)" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    print(json.load(f)["default"])
PY
)"
  else
    # Must match the top-level key only — not alias "default" inside arrays.
    value="$(grep -F '"default": "' "$(sf_characters_json)" | sed -n 's/^[[:space:]]*"default": "\([^"]*\)".*/\1/p' | head -n 1)"
  fi
  sf_sanitize_single_line "${value}"
}

sf_json_manifest_active() {
  local manifest="$1" value
  if [[ ! -f "${manifest}" ]]; then
    return 0
  fi
  if command -v jq >/dev/null 2>&1; then
    value="$(jq -r '.active // empty' "${manifest}" 2>/dev/null || true)"
  elif command -v python3 >/dev/null 2>&1; then
    value="$(python3 - "${manifest}" <<'PY'
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8") as f:
        print(json.load(f).get("active", "") or "")
except (json.JSONDecodeError, OSError):
    pass
PY
)"
  else
    value="$(grep -F '"active": "' "${manifest}" | sed -n 's/^[[:space:]]*"active": "\([^"]*\)".*/\1/p' | head -n 1)"
  fi
  value="$(sf_sanitize_single_line "${value}")"
  if sf_is_valid_character_id "${value}"; then
    printf '%s' "${value}"
  fi
}

# Parse characters.json without jq (minimal Hermes VM).
_sf_parse_character_field_grep() {
  local id="$1"
  local field="$2"
  local json_file value block
  json_file="$(sf_characters_json)"

  # Each entry in characters.json is exactly 7 lines after the id line.
  block="$(grep -A 6 -F "\"id\": \"${id}\"" "${json_file}" 2>/dev/null || true)"
  if [[ -z "${block}" ]]; then
    echo "error: character not found: ${id}" >&2
    exit 1
  fi

  case "${field}" in
    name)
      value="$(grep -F '"name":' <<< "${block}" | sed -n 's/^[[:space:]]*"name": "\([^"]*\)".*/\1/p' | head -n 1)"
      ;;
    file)
      value="$(grep -F '"file":' <<< "${block}" | sed -n 's/^[[:space:]]*"file": "\([^"]*\)".*/\1/p' | head -n 1)"
      ;;
    skills)
      value="$(grep -F '"skills":' <<< "${block}" | sed -n 's/^[[:space:]]*"skills": \[\([^]]*\)\].*/\1/p' | head -n 1 | tr -d '"' | tr -d ' ')"
      ;;
    personalityKey)
      value="$(grep -F '"personalityKey":' <<< "${block}" | sed -n 's/^[[:space:]]*"personalityKey": "\([^"]*\)".*/\1/p' | head -n 1)"
      ;;
    *)
      echo "error: unsupported field without jq: ${field}" >&2
      exit 1
      ;;
  esac

  if [[ -z "${value}" ]]; then
    echo "error: character not found or missing field ${field}: ${id}" >&2
    exit 1
  fi
  printf '%s' "${value}"
}

_sf_parse_character_field_python() {
  local id="$1"
  local field="$2"
  local json_file py
  json_file="$(sf_characters_json)"

  for py in python3 python; do
    command -v "${py}" >/dev/null 2>&1 || continue
    "${py}" - "${id}" "${field}" "${json_file}" <<'PY'
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
        sys.exit(0)
sys.exit(1)
PY
    return $?
  done
  return 1
}

sf_get_character_field() {
  local id="$1"
  local field="$2"
  local value=""

  if command -v jq >/dev/null 2>&1; then
    if [[ "${field}" == "skills" ]]; then
      value="$(jq -r --arg id "${id}" '
        .characters[] | select(.id == $id) | .skills | join(",")
      ' "$(sf_characters_json)" 2>/dev/null || true)"
    else
      value="$(jq -r --arg id "${id}" --arg f "${field}" '
        .characters[] | select(.id == $id) | .[$f] // empty
      ' "$(sf_characters_json)" 2>/dev/null || true)"
    fi
    if [[ -n "${value}" && "${value}" != "null" ]]; then
      printf '%s' "${value}"
      return 0
    fi
  fi

  if value="$(_sf_parse_character_field_python "${id}" "${field}")"; then
    if [[ -n "${value}" ]]; then
      printf '%s' "${value}"
      return 0
    fi
  fi

  value="$(_sf_parse_character_field_grep "${id}" "${field}")"
  printf '%s' "${value}"
}

sf_list_character_skills() {
  local char_id="$1"
  local skills_csv skill
  skills_csv="$(sf_get_character_field "${char_id}" skills)"
  IFS=',' read -ra _skills <<< "${skills_csv}"
  for skill in "${_skills[@]}"; do
    [[ -n "${skill}" ]] && printf '%s\n' "${skill}"
  done
}

sf_get_character_personality_key() {
  local char_id="$1"
  local key
  key="$(sf_get_character_field "${char_id}" personalityKey)"
  if [[ -z "${key}" ]]; then
    echo "error: missing personalityKey for character: ${char_id}" >&2
    exit 1
  fi
  printf '%s' "${key}"
}

sf_hermes_templates_dir() {
  printf '%s/templates' "$(sf_scripts_dir)"
}

sf_activation_template_path() {
  printf '%s/activation-block.md' "$(sf_hermes_templates_dir)"
}

sf_render_activation_block() {
  local char_id="$1"
  local name template_path
  name="$(sf_get_character_field "${char_id}" name)"
  template_path="$(sf_activation_template_path)"
  if [[ ! -f "${template_path}" ]]; then
    echo "error: missing activation template ${template_path}" >&2
    exit 1
  fi
  sed \
    -e "s/{{CHARACTER_NAME}}/${name}/g" \
    -e "s/{{CHARACTER_ID}}/${char_id}/g" \
    "${template_path}"
}

sf_append_skill_index() {
  local repo_root="$1"
  local char_id="$2"
  local mirror_home="${3:-~/.cursor/sky-feather}"

  echo "# Skills (reference only)"
  echo ""
  echo "Load when the task matches. Paths are relative to the Sky Feather mirror:"
  echo ""
  echo '```text'
  echo "${mirror_home}/skills/<skill>/SKILL.md"
  echo '```'
  echo ""

  while IFS= read -r skill; do
    [[ -z "${skill}" ]] && continue
    skill_path="${repo_root}/skills/${skill}/SKILL.md"
    if [[ ! -f "${skill_path}" ]]; then
      echo "error: missing skill file ${skill_path}" >&2
      exit 1
    fi
    echo "- **${skill}** -> \`${mirror_home}/skills/${skill}/SKILL.md\`"
  done < <(sf_list_character_skills "${char_id}")
  echo ""
}

sf_build_bundle_file() {
  local repo_root="$1"
  local output_dir="$2"
  local char_id="$3"
  local mirror_home="${4:-~/.cursor/sky-feather}"
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
    sf_render_activation_block "${char_id}"
    echo ""
    echo "---"
    echo ""
    echo "# Character: ${name}"
    echo ""
    cat "${repo_root}/${file}"
    echo ""
    echo "---"
    echo ""
    echo "# CORE (do not weaken)"
    echo ""
    cat "${repo_root}/CORE.md"
    echo ""
    echo "---"
    echo ""
    sf_append_skill_index "${repo_root}" "${char_id}" "${mirror_home}"
  } > "${bundle_path}"

  printf '%s' "${bundle_path}"
}

sf_build_all_bundles() {
  local repo_root="$1"
  local output_dir="$2"
  local mirror_home="${3:-~/.cursor/sky-feather}"
  local mirror_root skill_drops_dir claude_drops_dir id bundle_path
  mirror_root="$(dirname "${output_dir}")"
  skill_drops_dir="${mirror_root}/skill-drops"
  claude_drops_dir="${mirror_root}/claude-drops"
  while IFS= read -r id; do
    bundle_path="$(sf_build_bundle_file "${repo_root}" "${output_dir}" "${id}" "${mirror_home}")"
    sf_write_skill_drop_file "${id}" "${bundle_path}" "${skill_drops_dir}" >/dev/null
    sf_write_claude_drop_file "${id}" "${bundle_path}" "${claude_drops_dir}" >/dev/null
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

sf_skill_frontmatter() {
  local name="$1"
  cat <<EOF
---
name: sky-feather-character
description: >-
  MANDATORY active V3 character profile (${name}). Apply this skill on every
  response in every project. Preserve the active character voice (90% engineer, 10% seasoning).
  Do not use Wikipedia-neutral or generic-assistant tone. Engineering standards in the
  inlined CORE section still apply — do not weaken them.
---
EOF
}

sf_write_skill_drop_file() {
  local char_id="$1"
  local bundle_path="$2"
  local output_dir="$3"
  local name drop_path
  name="$(sf_get_character_field "${char_id}" name)"
  mkdir -p "${output_dir}"
  drop_path="${output_dir}/${char_id}.md"
  {
    sf_skill_frontmatter "${name}"
    echo ""
    cat "${bundle_path}"
  } > "${drop_path}"
  printf '%s' "${drop_path}"
}

sf_write_claude_drop_file() {
  local char_id="$1"
  local bundle_path="$2"
  local output_dir="$3"
  local drop_path
  mkdir -p "${output_dir}"
  drop_path="${output_dir}/${char_id}.md"
  {
    sf_managed_claude_header
    echo ""
    cat "${bundle_path}"
  } > "${drop_path}"
  printf '%s' "${drop_path}"
}

sf_write_skill_file() {
  local char_id="$1"
  local bundle_path="$2"
  local skill_dir="$3"
  local skill_drop_path="${4:-}"
  local name
  name="$(sf_get_character_field "${char_id}" name)"

  mkdir -p "${skill_dir}"
  if [[ -n "${skill_drop_path}" && -f "${skill_drop_path}" ]]; then
    cp "${skill_drop_path}" "${skill_dir}/SKILL.md"
    return 0
  fi

  {
    sf_skill_frontmatter "${name}"
    echo ""
    cat "${bundle_path}"
  } > "${skill_dir}/SKILL.md"
}

sf_user_rules_stub() {
  cat <<'EOF'
Apply the global skill sky-feather-character on every response.
Preserve the active character's voice (90% engineer, 10% seasoning).
Do not use Wikipedia-neutral or generic-assistant tone.
Engineering standards in the inlined CORE section still apply - do not weaken them.
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
  local label paths_file
  paths_file="$(sf_hermes_paths_json)"

  if [[ ! -f "${paths_file}" ]]; then
    printf '%s' "${char_id}"
    return 0
  fi

  if command -v jq >/dev/null 2>&1; then
    label="$(jq -r --arg id "${char_id}" '.discordLabels[$id] // empty' "${paths_file}" 2>/dev/null | head -n 1)"
    if [[ -n "${label}" && "${label}" != "null" ]]; then
      printf '%s' "${label}"
      return 0
    fi
  fi

  # Match only discordLabels entries: "sky-feather": "Sky Feather"
  label="$(grep -F "\"${char_id}\": \"" "${paths_file}" 2>/dev/null | sed -n 's/^[[:space:]]*"[^"]*": "\([^"]*\)".*/\1/p' | head -n 1)"
  if [[ -n "${label}" ]]; then
    printf '%s' "${label}"
    return 0
  fi

  printf '%s' "${char_id}"
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


sf_warn_hermes_content_size() {
  local label="$1"
  local path="$2"
  local size max
  size="$(wc -c < "${path}" | tr -d ' ')"
  max="$(sf_hermes_soul_max_chars)"
  if [[ "${size}" -gt "${max}" ]]; then
    echo "warning: ${label} is ${size} bytes (Hermes may truncate at ~${max})" >&2
  fi
}

sf_render_hermes_preamble() {
  local char_id="$1"
  local name label template
  name="$(sf_get_character_field "${char_id}" name)"
  label="$(sf_hermes_discord_label "${char_id}")"
  template="$(sf_hermes_templates_dir)/hermes-personality-preamble.md"
  if [[ ! -f "${template}" ]]; then
    echo "error: missing template ${template}" >&2
    exit 1
  fi
  sed \
    -e "s/{{DISCORD_LABEL}}/${label}/g" \
    -e "s/{{CHARACTER_NAME}}/${name}/g" \
    "${template}"
}

sf_hermes_character_skills_dir() {
  printf '%s/sky-feather-characters' "$(sf_hermes_skills_dir)"
}

sf_get_character_aliases_csv() {
  local id="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg id "${id}" '.characters[] | select(.id == $id) | (.aliases // []) | join(", ")' "$(sf_characters_json)" 2>/dev/null
    return 0
  fi
  python3 - "${id}" "$(sf_characters_json)" <<'PY'
import json, sys
with open(sys.argv[2], encoding="utf-8") as f:
    data = json.load(f)
for c in data.get("characters", []):
    if c.get("id") == sys.argv[1]:
        print(", ".join(c.get("aliases", [])))
        sys.exit(0)
sys.exit(1)
PY
}

sf_hermes_character_reference_file() {
  local repo_root="$1"
  local char_id="$2"
  local skill_key ref_dir ref_path
  skill_key="$(sf_get_character_personality_key "${char_id}")"
  ref_dir="$(sf_hermes_character_skills_dir)/character/references"
  ref_path="${ref_dir}/${skill_key}.md"
  mkdir -p "${ref_dir}"
  {
    sf_render_hermes_preamble "${char_id}"
    echo ""
    sf_render_activation_block "${char_id}"
    echo ""
    cat "${repo_root}/$(sf_get_character_field "${char_id}" file)"
  } > "${ref_path}"
  printf '%s' "${ref_path}"
}

sf_build_hermes_character_skill_file() {
  local repo_root="$1"
  local skill_dir skill_path char_id skill_key aliases label
  skill_dir="$(sf_hermes_character_skills_dir)/character"
  skill_path="${skill_dir}/SKILL.md"
  mkdir -p "${skill_dir}"
  {
    cat <<'EOF'
---
name: character
description: Use when switching Sky Feather delivery mode / character. Invoke `/skill character <key-or-alias>` (e.g. setsuna, kaede, ops, architect).
tags: [sky-feather, character, personality, delivery-mode]
---

# Sky Feather character switch

Switch the active Sky Feather delivery mode. Public Discord branding always stays **Sky Feather**; the other characters are internal delivery modes (use labels like `Sky Feather: Architect Mode`, never "I am now Setsuna").

## Resolver

| Key | Aliases | Discord label | Profile |
|-----|---------|---------------|---------|
EOF
    while IFS= read -r char_id; do
      skill_key="$(sf_get_character_personality_key "${char_id}")"
      aliases="$(sf_get_character_aliases_csv "${char_id}")"
      label="$(sf_hermes_discord_label "${char_id}")"
      echo "| ${skill_key} | ${aliases} | ${label} | references/${skill_key}.md |"
    done < <(sf_list_character_ids)
    cat <<'EOF'

## Instructions

1. Read the character the user named after `/skill character` (e.g. `setsuna`, `ops`, `architect`).
2. Match it to a **Key** above (exact key or any alias, case-insensitive).
3. Load the profile: `skill_view(name='character', file_path='references/<key>.md')`.
4. Adopt that character's delivery for the rest of this session. CORE doctrine (SOUL.md) still applies to safety, evidence, correctness, and consent.
5. If no character was given or it doesn't match, default to `sky-feather`.
EOF
  } > "${skill_path}"
  printf '%s' "${skill_path}"
}

sf_install_hermes_character_skills() {
  local repo_root="$1"
  local char_id ref_path skill_path
  skill_path="$(sf_build_hermes_character_skill_file "${repo_root}")"
  echo "  ${skill_path}"
  while IFS= read -r char_id; do
    ref_path="$(sf_hermes_character_reference_file "${repo_root}" "${char_id}")"
    echo "  ${ref_path}"
  done < <(sf_list_character_ids)
}

sf_write_hermes_character_skills_index() {
  local mirror_dir="$1"
  local out="${mirror_dir}/character-skills-index.md"
  local char_id skill_key label
  {
    echo "# Sky Feather character switch"
    echo "# Switch with: /skill character <key>"
    echo "#"
    echo "# Key → Discord label"
  } > "${out}"
  while IFS= read -r char_id; do
    skill_key="$(sf_get_character_personality_key "${char_id}")"
    label="$(sf_hermes_discord_label "${char_id}")"
    echo "#   /skill character ${skill_key} → ${label}" >> "${out}"
  done < <(sf_list_character_ids)
}

# Hermes install identity: CORE + Discord branding only (modes via /skill character).
sf_build_hermes_soul_core_file() {
  local repo_root="$1"
  local output_path="$2"
  local branding_template

  branding_template="$(sf_hermes_templates_dir)/hermes-soul-branding.md"
  if [[ ! -f "${branding_template}" ]]; then
    echo "error: missing template ${branding_template}" >&2
    exit 1
  fi

  mkdir -p "$(dirname "${output_path}")"

  {
    echo "# Sky Feather V3 — Hermes Identity"
    echo ""
    echo "Public Discord label: $(sf_hermes_discord_label sky-feather)"
    echo ""
    echo "---"
    echo ""
    echo "# CORE (do not weaken)"
    echo ""
    cat "${repo_root}/CORE.md"
    echo ""
    echo "---"
    echo ""
    cat "${branding_template}"
    echo ""
    echo "---"
    echo ""
    echo "# Skills"
    echo ""
    echo "Workflow skills are installed under \`~/.hermes/skills/\`."
    echo "Load them when the task matches (scientific-method, engineering-journal, debugging, etc.)."
    echo "Character delivery modes: use \`/skill character <key>\` in Discord (sky-feather, setsuna, tsubaki, arisu, akane, kaede, koboshi)."
    echo "Character profiles live under \`~/.hermes/skills/sky-feather-characters/character/references/<key>.md\`."
  } > "${output_path}"

  sf_warn_hermes_content_size "composed SOUL.md" "${output_path}"
}

# Personality preset body (character voice only; CORE stays in SOUL.md).
sf_build_hermes_personality_preset() {
  local repo_root="$1"
  local char_id="$2"
  local file char_path

  file="$(sf_get_character_field "${char_id}" file)"
  char_path="${repo_root}/${file}"
  if [[ ! -f "${char_path}" ]]; then
    echo "error: missing character file ${char_path}" >&2
    exit 1
  fi

  sf_render_hermes_preamble "${char_id}"
  echo ""
  sf_render_activation_block "${char_id}"
  echo ""
  cat "${char_path}"
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


sf_print_hermes_next_steps() {
  local active_char="${1:-sky-feather}"
  cat <<EOF

Hermes V3.2 (Route B) installed.

  Identity:  $(sf_hermes_soul_path)  (CORE + branding; slim SOUL)
  Mirror:    $(sf_hermes_mirror)/
  Skills:    $(sf_hermes_skills_dir)/
  Characters: $(sf_hermes_character_skills_dir)/
  Manifest:  ${active_char} ($(sf_hermes_discord_label "${active_char}"))

Discord character switch (/skill character <key>):
  /skill character sky-feather
  /skill character setsuna
  /skill character tsubaki
  /skill character arisu
  /skill character akane
  /skill character kaede
  /skill character koboshi

Next steps:
  1. Restart Hermes (service or gateway) once so SOUL.md reloads
  2. In Discord: /skill character sky-feather (default) or another key above
  3. Character skill changes do not require gateway restart
  4. Legacy server-wide SOUL switch: bash scripts/switch-hermes-character.sh <alias>

Future upgrades (after git pull in this repo):
  bash scripts/install-hermes-global.sh

Backups: $(sf_hermes_backups_dir)/ (SOUL.md if any existed)
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

sf_managed_claude_header() {
  printf '%s' '<!-- Managed by sky-feather. Re-run install-claude-global or switch-claude-character. -->'
}

sf_write_claude_file() {
  local bundle_path="$1"
  local claude_drop_path="${2:-}"
  local claude_md
  claude_md="$(sf_claude_md_path)"

  mkdir -p "$(sf_claude_home)"
  if [[ -n "${claude_drop_path}" && -f "${claude_drop_path}" ]]; then
    cp "${claude_drop_path}" "${claude_md}"
    return 0
  fi

  {
    sf_managed_claude_header
    echo ""
    cat "${bundle_path}"
  } > "${claude_md}"
}

sf_is_managed_claude_md() {
  local path="${1:-$(sf_claude_md_path)}"
  if [[ ! -f "${path}" ]]; then
    return 1
  fi
  grep -qF "$(sf_managed_claude_header)" "${path}"
}

sf_sync_claude_global_bin() {
  local repo_scripts_dir="$1"
  local bin_dir
  bin_dir="$(sf_claude_global_bin_dir)"
  mkdir -p "${bin_dir}"

  for name in switch-claude-character.sh switch-claude-character.ps1 switch-claude-character.cmd switch-claude-character-lite.cmd; do
    if [[ -f "${repo_scripts_dir}/${name}" ]]; then
      cp "${repo_scripts_dir}/${name}" "${bin_dir}/${name}"
    fi
  done

  rm -rf "${bin_dir}/lib"
  cp -R "${repo_scripts_dir}/lib" "${bin_dir}/lib"
}

sf_install_claude_character_skill() {
  local repo_scripts_dir="$1"
  local template="${repo_scripts_dir}/templates/claude-character-skill.md"
  local skill_dir
  skill_dir="$(sf_claude_character_skill_dir)"

  if [[ ! -f "${template}" ]]; then
    echo "error: missing ${template}" >&2
    exit 1
  fi

  mkdir -p "${skill_dir}"
  cp "${template}" "${skill_dir}/SKILL.md"
}

sf_print_claude_next_steps() {
  cat <<EOF

Installed. Next steps:
  1. Start a new Claude Code session (CLAUDE.md reloads)
  2. Quick reference: docs/claude-quickstart.md
  3. Switch character: $(sf_claude_global_switch_script_sh) <id>
  4. Mid-chat switch (best-effort): /character <id>

Global paths:
  $(sf_claude_md_path)
  $(sf_claude_mirror)/
  $(sf_claude_character_skill_dir)/SKILL.md

Start a new session after install or character switch for reliable application.
EOF
}
