#!/usr/bin/env bash
# Shared helpers for Sky Feather Cursor scripts (bash).

set -euo pipefail

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=paths.sh
source "${LIB_DIR}/paths.sh"

sf_characters_json() {
  local hermes_json cursor_json
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
  printf '%s/lib/characters.json' "$(sf_scripts_dir)"
}

sf_sync_global_bin() {
  local repo_scripts_dir="$1"
  local bin_dir
  bin_dir="$(sf_global_bin_dir)"
  mkdir -p "${bin_dir}"

  for name in switch-character.sh switch-character.ps1 switch-character.cmd; do
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

sf_backup_hermes_config() {
  local config_path backup_dir stamp backup_path
  config_path="$(sf_hermes_config_path)"
  backup_dir="$(sf_hermes_backups_dir)"

  if [[ ! -f "${config_path}" ]]; then
    return 0
  fi

  mkdir -p "${backup_dir}"
  stamp="$(date -u +"%Y%m%dT%H%M%SZ")"
  backup_path="${backup_dir}/config.yaml.${stamp}"
  cp "${config_path}" "${backup_path}"
  echo "Backed up existing config.yaml → ${backup_path}"
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

# Hermes install identity: CORE + Discord branding only (modes via /personality).
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
    echo "Delivery modes: use \`/personality <preset>\` in Discord (sky-feather, setsuna, tsubaki, arisu, akane, kaede, koboshi)."
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
  cat "${char_path}"
}

sf_personalities_marker_start() {
  printf '%s' '# --- sky-feather:personalities:start (generated; do not edit) ---'
}

sf_personalities_marker_end() {
  printf '%s' '# --- sky-feather:personalities:end ---'
}

_sf_indent_yaml_literal_body() {
  sed 's/^/      /'
}

sf_generate_hermes_personalities_yaml() {
  local repo_root="$1"
  local output_path="$2"
  local char_id preset_key preset_tmp size max

  mkdir -p "$(dirname "${output_path}")"
  preset_tmp="$(mktemp)"

  {
    sf_personalities_marker_start
  } > "${output_path}"

  while IFS= read -r char_id; do
    preset_key="$(sf_get_character_personality_key "${char_id}")"
    sf_build_hermes_personality_preset "${repo_root}" "${char_id}" > "${preset_tmp}"
    size="$(wc -c < "${preset_tmp}" | tr -d ' ')"
    max="$(sf_hermes_soul_max_chars)"
    if [[ "${size}" -gt "${max}" ]]; then
      echo "warning: personality preset '${preset_key}' is ${size} bytes (may truncate at ~${max})" >&2
    fi
    {
      echo "    ${preset_key}: |"
      _sf_indent_yaml_literal_body < "${preset_tmp}"
    } >> "${output_path}"
  done < <(sf_list_character_ids)

  echo "$(sf_personalities_marker_end)" >> "${output_path}"
  rm -f "${preset_tmp}"
}

sf_validate_hermes_config_personalities() {
  local config_path="$1"
  local agent_count preset_count

  if [[ ! -f "${config_path}" ]]; then
    echo "warning: missing Hermes config: ${config_path}" >&2
    return 0
  fi

  agent_count="$(grep -c '^agent:[[:space:]]*$' "${config_path}" || true)"
  if [[ "${agent_count}" -ne 1 ]]; then
    echo "warning: expected exactly 1 root 'agent:' in ${config_path}, found ${agent_count}" >&2
    echo "warning: duplicate agent: keys can cause Hermes to ignore Sky Feather /personality presets" >&2
  fi

  preset_count="$(grep -cE '^[[:space:]]{4}(sky-feather|setsuna|tsubaki|arisu|akane|kaede|koboshi):' "${config_path}" || true)"
  if [[ "${preset_count}" -lt 7 ]]; then
    echo "warning: expected 7 Sky Feather personality presets in ${config_path}, found ${preset_count}" >&2
  fi
}

sf_merge_hermes_personalities() {
  local repo_root="$1"
  local dry_run="${2:-0}"
  local generated config_path mirror_dir block_tmp py

  mirror_dir="$(sf_hermes_mirror)"
  generated="${mirror_dir}/personalities.generated.yaml"
  config_path="$(sf_hermes_config_path)"
  block_tmp="$(mktemp)"

  sf_generate_hermes_personalities_yaml "${repo_root}" "${generated}"
  cp "${generated}" "${block_tmp}"

  if [[ "${dry_run}" -eq 1 ]]; then
    echo "Dry-run: would merge personalities into ${config_path}"
    echo "Generated block ($(sf_hermes_mirror)/personalities.generated.yaml):"
    cat "${block_tmp}"
    rm -f "${block_tmp}"
    return 0
  fi

  for py in python3 python; do
    command -v "${py}" >/dev/null 2>&1 || continue
    "${py}" - "${config_path}" "${block_tmp}" <<'PY'
import re
import sys

config_path, block_path = sys.argv[1], sys.argv[2]

START = "# --- sky-feather:personalities:start (generated; do not edit) ---"
END = "# --- sky-feather:personalities:end ---"
LEGACY_WARNING = "# WARNING: sky-feather personalities appended"


def read_text(path: str) -> str:
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except OSError:
        return ""


def strip_agent_wrapper(block: str) -> str:
    lines = []
    for line in block.splitlines():
        stripped = line.strip()
        if stripped in ("agent:", "personalities:"):
            continue
        lines.append(line)
    return "\n".join(lines).strip("\n")


def extract_marker_block(text: str) -> str:
    if START not in text or END not in text:
        return strip_agent_wrapper(text)
    _, rest = text.split(START, 1)
    body, _ = rest.split(END, 1)
    return strip_agent_wrapper(body)


def remove_marker_block(text: str) -> str:
    if START not in text or END not in text:
        return text
    before, rest = text.split(START, 1)
    _, after = rest.split(END, 1)
    return before + after


def remove_legacy_append(text: str) -> str:
    if LEGACY_WARNING not in text:
        return text
    warning_idx = text.index(LEGACY_WARNING)
    if START in text[warning_idx:]:
        end_idx = text.index(END, warning_idx) + len(END)
        tail = text[end_idx:].lstrip("\n")
        return text[:warning_idx].rstrip() + ("\n\n" + tail if tail else "\n")
    return text[:warning_idx].rstrip() + "\n"


def remove_duplicate_root_agent_blocks(text: str) -> str:
    matches = list(re.finditer(r"^agent:\s*$", text, re.MULTILINE))
    if len(matches) <= 1:
        return text
    # Drop later root-level agent: sections (old installer appended a second block).
    second = matches[1].start()
    return text[:second].rstrip() + "\n"


def wrap_presets(preset_body: str) -> str:
    body = preset_body.strip("\n")
    if not body:
        return ""
    return f"{START}\n{body}\n{END}\n"


def insert_under_personalities(text: str, preset_block: str) -> str:
    text = text.rstrip() + "\n"
    agent_match = re.search(r"^agent:\s*$", text, re.MULTILINE)
    if not agent_match:
        return f"agent:\n  personalities:\n{preset_block}"

    after_agent = text[agent_match.end() :]
    pers_match = re.search(r"^  personalities:\s*$", after_agent, re.MULTILINE)
    if not pers_match:
        insert_at = agent_match.end()
        return text[:insert_at] + "\n  personalities:\n" + preset_block + text[insert_at:]

    insert_at = agent_match.end() + pers_match.end()
    return text[:insert_at] + "\n" + preset_block + text[insert_at:]


new_block = wrap_presets(extract_marker_block(read_text(block_path)))
if not new_block.strip():
    raise SystemExit("error: generated personalities block is empty")

config = read_text(config_path)
config = remove_legacy_append(config)
config = remove_marker_block(config)
config = remove_duplicate_root_agent_blocks(config)
merged = insert_under_personalities(config, new_block)

agent_roots = len(re.findall(r"^agent:\s*$", merged, re.MULTILINE))
if agent_roots != 1:
    print(
        f"warning: expected 1 root agent: key after merge, found {agent_roots}",
        file=sys.stderr,
    )

with open(config_path, "w", encoding="utf-8", newline="\n") as f:
    f.write(merged if merged.endswith("\n") else merged + "\n")
PY
    rm -f "${block_tmp}"
    sf_validate_hermes_config_personalities "${config_path}"
    return 0
  done

  rm -f "${block_tmp}"
  echo "error: python3 required to merge config.yaml personalities" >&2
  exit 1
}

sf_install_hermes_personalities() {
  local repo_root="$1"
  local dry_run="${2:-0}"

  if [[ "${dry_run}" -eq 0 ]]; then
    sf_backup_hermes_config
  fi

  sf_merge_hermes_personalities "${repo_root}" "${dry_run}"

  if [[ "${dry_run}" -eq 0 ]]; then
    echo "Merged agent.personalities → $(sf_hermes_config_path)"
    echo "Debug copy: $(sf_hermes_mirror)/personalities.generated.yaml"
  fi
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

sf_write_hermes_personalities_example() {
  local repo_root="$1"
  local mirror_dir="$2"
  local out="${mirror_dir}/personalities.example.yaml"
  local char_id preset_key label

  {
    echo "# Reference only — install writes ~/.hermes/config.yaml automatically."
    echo "# Switch at runtime with: /personality <preset-key>"
    echo "# Full generated block: ~/.hermes/sky-feather/personalities.generated.yaml"
    echo "#"
    echo "# Preset keys (short aliases):"
  } > "${out}"

  while IFS= read -r char_id; do
    preset_key="$(sf_get_character_personality_key "${char_id}")"
    label="$(sf_hermes_discord_label "${char_id}")"
    echo "#   ${preset_key} → ${label}" >> "${out}"
  done < <(sf_list_character_ids)

  echo "#" >> "${out}"
  echo "# Regenerate preset body: bash scripts/switch-hermes-character.sh <alias> --preset-only" >> "${out}"
}

sf_print_hermes_next_steps() {
  local active_char="${1:-sky-feather}"
  cat <<EOF

Hermes V3.2 (Route B) installed.

  Identity:  $(sf_hermes_soul_path)  (CORE + branding; slim SOUL)
  Config:    $(sf_hermes_config_path)  (agent.personalities presets)
  Mirror:    $(sf_hermes_mirror)/
  Skills:    $(sf_hermes_skills_dir)/
  Manifest:  ${active_char} ($(sf_hermes_discord_label "${active_char}"))

Discord mode switch (primary):
  /personality sky-feather
  /personality setsuna
  /personality tsubaki
  /personality arisu
  /personality akane
  /personality kaede
  /personality koboshi

Next steps:
  1. Restart Hermes (service or gateway) once so SOUL.md reloads
  2. In Discord: /personality sky-feather (default) or another preset above
  3. Personality changes do not require gateway restart
  4. Legacy server-wide SOUL switch: bash scripts/switch-hermes-character.sh <alias>

Future upgrades (after git pull in this repo):
  bash scripts/install-hermes-global.sh

Backups: $(sf_hermes_backups_dir)/ (SOUL.md and config.yaml if any existed)
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
