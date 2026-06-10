# Handoff — Discord personality switching (Route B implement, Route C roadmap)

**For the next implementation session.**  
**Repo:** `sky-feather` (https://github.com/Umi4Life/sky-feather)  
**Deployed target:** Hermes VM, user `hermes`, `HERMES_HOME=~/.hermes`, service `hermes-gateway`

---

## Current state (as of 2026-06-10)

### What works today

| Surface | Status |
|---------|--------|
| `bash scripts/install-hermes-global.sh` | ✅ V3.2 install (CORE + character → `SOUL.md`, skills synced) |
| `bash scripts/switch-hermes-character.sh <alias>` | ✅ Rewrites `SOUL.md` server-wide |
| `~/.hermes/sky-feather/manifest.json` | ✅ Tracks `active` character id |
| `~/.hermes/skills/` | ✅ All workflow skills synced |
| Legacy SOUL backups | ✅ `~/.hermes/backups/SOUL.md.<timestamp>` |
| No `jq` on VM | ✅ Scripts use python3/grep fallbacks (do not reintroduce `grep '"default"'` footgun) |

### What does NOT work yet

| Item | Status |
|------|--------|
| In-Discord character/mode switch | ❌ No `/hermes character` command |
| `/personality` presets for Sky Feather modes | ❌ Only stub `personalities.example.yaml` |
| Slim SOUL for layering | ❌ `SOUL.md` = full CORE + active character (conflicts with overlay model) |
| `config.yaml` merge on install | ❌ Not implemented |

### Operator commands (today)

```bash
cd ~/sky-feather
git pull
bash scripts/install-hermes-global.sh
sudo systemctl restart hermes-gateway
```

Use `bash scripts/...` — avoid `chmod +x` on tracked files (or set `git config core.fileMode false` on VM clone).

---

## Goal

### Route B — **implement next** (in-Discord mode switch)

Use Hermes native **`/personality <preset>`** with short preset keys (`setsuna`, `kaede`, `feather`, …) generated from this repo.

### Route C — **roadmap only** (polish)

Custom **`/hermes character <alias>`** as a thin branded wrapper over B. Do not start until B is validated in Discord.

---

## Route B — architecture

### Prompt layering (target)

```text
~/.hermes/SOUL.md
  → CORE.md + Discord branding rules (Sky Feather public identity, mode label rules)
  → NOT full character voice for non-default modes

~/.hermes/config.yaml → agent.personalities
  → <short-key>: character profile + public mode label instruction
  → Generated on install; keys = short aliases (setsuna, tsubaki, feather, …)

~/.hermes/skills/
  → unchanged; Hermes loads via skill_view when relevant
```

### Why slim SOUL

Full character in `SOUL.md` + `/personality` overlay = **stacked/conflicting voice**.  
Default delivery can live in SOUL **or** default preset (`feather`); non-default modes must come from personalities only.

**Recommended:**

- `SOUL.md` = `CORE.md` + short **Discord branding block** (from new template file)
- Default mode = `/personality feather` **or** SOUL includes `characters/sky-feather.md` (pick one; document the choice)
- Other modes = personality presets only (character file content, no duplicate CORE)

### Preset key naming (short aliases)

Use **one canonical short key per character** for `/personality` — not full ids.

| Character id | Preset key (proposed) | Discord public label |
|--------------|----------------------|----------------------|
| `sky-feather` | `feather` | Sky Feather |
| `sumeragi-setsuna` | `setsuna` | Sky Feather: Architect Mode |
| `aihara-tsubaki` | `tsubaki` | Sky Feather: Pair-Programming Mode |
| `suzushima-arisu` | `arisu` | Sky Feather: Cozy Lab Mode |
| `ousaka-akane` | `akane` | Sky Feather: Brainstorm Mode |
| `kujo-kaede` | `kaede` | Sky Feather: Ops Mode |
| `inohara-koboshi` | `koboshi` | Sky Feather: Automation Mode |

**Avoid** Hermes built-in preset names:  
`helpful`, `concise`, `technical`, `creative`, `teacher`, `kawaii`, `catgirl`, `pirate`, `shakespeare`, `surfer`, `noir`, `uwu`, `philosopher`, `hype`.

**Implementation:** add `personalityKey` per character in `scripts/lib/characters.json` (or `personalityKeys` in `hermes-paths.json`) — do not guess from aliases at runtime.

### Preset body template (each personality)

```yaml
agent:
  personalities:
    setsuna: |
      You are operating in Sky Feather: Architect Mode.
      Public branding: remain Sky Feather; do not say "I am now Setsuna."
      Delivery style: Sumeragi Setsuna — architecture review tone.
      Engineering doctrine: follow CORE in SOUL.md; do not weaken evidence or safety standards.

      <contents of characters/sumeragi-setsuna.md — character section only>
```

- Include **public label** + **branding rules** in every preset.
- Do **not** duplicate full `CORE.md` in each preset (size + drift risk).
- Watch **~20k chars** per preset if Hermes truncates overlays similarly to SOUL.

---

## Route B — implementation checklist

### 1. Config schema

- [ ] Add `personalityKey` to each entry in `scripts/lib/characters.json`
- [ ] Mirror field in PowerShell `common.ps1` if used
- [ ] Add `sf_get_character_personality_key(char_id)` in `scripts/lib/common.sh`

### 2. New content template

- [ ] Add `templates/hermes-soul-branding.md` — Discord rules only (no character voice)
- [ ] Optional: `templates/hermes-personality-preamble.md` — shared lines prepended to each preset

### 3. Soul builder split

- [ ] `sf_build_hermes_soul_core_file()` → CORE + branding template → `SOUL.md`
- [ ] `sf_build_hermes_personality_preset(char_id)` → preset body string (character file + preamble)
- [ ] Refactor `sf_build_hermes_soul_file()` — keep for **server-wide switch** (full CORE + character) OR deprecate in favor of personalities-only modes

**Decision for implementer:**  
- **Option A (recommended):** install writes slim SOUL; modes only via `/personality`  
- **Option B:** keep fat SOUL for default + personalities for other modes (simpler migration, worse layering)

### 4. Config.yaml merge

- [ ] Locate `~/.hermes/config.yaml` (create minimal if missing)
- [ ] Backup before merge: `config.yaml.bak.<timestamp>`
- [ ] Merge strategy: replace block between markers:

```yaml
# --- sky-feather:personalities:start (generated; do not edit) ---
    setsuna: |
      ...
# --- sky-feather:personalities:end ---
# (Inserted under the existing root agent.personalities — not a second agent: block.)
```

- [ ] Preserve other `agent:` keys and top-level Hermes settings
- [ ] Implement `sf_merge_hermes_personalities()` in `common.sh` (+ PowerShell twin if needed)
- [ ] Write merged presets to `~/.hermes/sky-feather/personalities.generated.yaml` for diff/debug

### 5. Install script changes

File: `scripts/install-hermes-global.sh`

- [ ] After skills sync: call personality merge
- [ ] Replace `sf_write_hermes_personalities_example` with `sf_install_hermes_personalities` (or keep example as reference)
- [ ] Update `sf_print_hermes_next_steps` with Discord commands:

```text
/personality feather
/personality setsuna
/personality kaede
```

- [ ] Note: **no gateway restart required** for personality changes (verify on VM); restart still needed for SOUL.md changes

### 6. Switch script alignment

File: `scripts/switch-hermes-character.sh`

- [ ] Document: server-wide SOUL switch = **legacy ops path**
- [ ] Optional: add `--personality-only` that tells user to run `/personality <key>` instead
- [ ] Keep `--preset-only` for regenerating preset bodies into mirror

### 7. Docs

- [ ] Update `docs/hermes.md` — Route B as primary Discord switch
- [ ] Update `docs/character-switching.md` — `/personality` table with short keys
- [ ] Link this handoff from `docs/hermes.md` until B is done (then archive or trim)

### 8. VM validation (acceptance criteria)

On `hermes@hermes` after `git pull && bash scripts/install-hermes-global.sh`:

```bash
# Files
test -f ~/.hermes/config.yaml
grep -q 'sky-feather:personalities:start' ~/.hermes/config.yaml
head -20 ~/.hermes/SOUL.md    # CORE + branding; not full Setsuna unless Option B

# Discord (manual)
/personality setsuna
# → Architect delivery, public Sky Feather branding

/personality feather
# → default Sky Feather

# Same technical question across modes → same engineering conclusion, different tone
```

- [ ] Confirm scope: per-user vs per-channel vs server-wide (document finding in `docs/hermes.md`)
- [ ] Confirm no conflict with built-in `/personality` presets

---

## Route B — risks and mitigations

| Risk | Mitigation |
|------|------------|
| CORE doctrine drift across presets | CORE only in SOUL; presets reference SOUL; generate from repo |
| 20k truncation | Character-only in presets; monitor size in install log |
| `config.yaml` merge breaks Hermes | Marker-based merge; backup; dry-run flag `--dry-run` |
| SOUL + personality voice stack | Slim SOUL (implement Option A) |
| `git pull` on VM blocked by chmod | Document `bash` + `core.fileMode false` |
| grep `default` alias bug | Use `grep -F '"default": "'` only (already fixed — do not regress) |

---

## Route C — roadmap (do not implement until B passes VM validation)

### Purpose

Branded Discord UX on top of B:

```text
/hermes character setsuna
  → internally: /personality setsuna (or preset key from map)
  → reply: "Sky Feather: Architect Mode"
```

### Prerequisites

- [ ] Route B live and tested
- [ ] Spike: Hermes gateway custom slash command registration (where is code? extension point?)

### Scope (when started)

| Task | Notes |
|------|-------|
| Alias map | Reuse `characters.json` aliases → `personalityKey` |
| Slash handler | Thin wrapper; no duplicate composition |
| Public confirmation message | Use `discordLabels` from `hermes-paths.json` |
| Permissions | Optional: restrict mode switch to admin role |
| Suggested mode | Optional V2: "looks like ops review → `/hermes character kaede`?" |

### Out of scope for C v1

- Per-user persistent mode in database
- Replacing SOUL.md on each command (Route D)
- Full character identity swap in Discord ("I am Setsuna")

### C — effort / risk (reminder)

- **Effort:** ~1.5–3× Route B (gateway coupling)
- **Risk:** Medium (upstream Hermes changes); mitigated if C only wraps B

---

## Key files reference

| Path | Role |
|------|------|
| `scripts/install-hermes-global.sh` | Main install entry |
| `scripts/switch-hermes-character.sh` | Server-wide SOUL switch |
| `scripts/lib/common.sh` | Bundle/soul/personality helpers |
| `scripts/lib/characters.json` | Character ids, aliases, skills |
| `scripts/lib/hermes-paths.json` | Discord labels, soulMaxChars |
| `docs/hermes.md` | Operator docs |
| `docs/character-switching.md` | Mode table + branding rules |
| `examples/discord-hermes-sky-feather.md` | Default composition reference |
| `~/.hermes/SOUL.md` | Hermes identity slot #1 |
| `~/.hermes/config.yaml` | `agent.personalities` target |
| `~/.hermes/sky-feather/` | Mirror + manifest |

---

## Suggested session prompt (copy for next agent)

```text
Implement Route B from docs/hermes-discord-personality-handoff.md:

1. Add personalityKey to characters.json
2. Slim SOUL install (CORE + branding template)
3. Generate agent.personalities into ~/.hermes/config.yaml with marker merge
4. Short keys: feather, setsuna, tsubaki, arisu, akane, kaede, koboshi
5. Update docs/hermes.md and character-switching.md
6. Do NOT implement Route C (/hermes character) yet

Validate against acceptance criteria in handoff doc.
Target VM: hermes user, hermes-gateway, bash without jq.
```

---

## Engineering journal (incidents from this rollout)

| Issue | Cause | Fix |
|-------|-------|-----|
| `jq required` on VM | hard jq dependency | python3/grep fallbacks |
| Corrupt `active` id + SOUL header | `grep '"default"'` matched alias `"default"` in arrays | `grep -F '"default": "'` + validation |
| `git pull` blocked | `chmod +x` changed file mode | `bash scripts/...` + `core.fileMode false` |
| Ugly discord label in install output | greedy grep/sed on wrong file | fixed discord label lookup |
| Stray SOUL path in install log | `sf_build_hermes_soul_file` printed path to stdout | removed printf |

Do not regress these fixes.
