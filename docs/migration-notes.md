# Migration Notes — SOUL.md to V3 Framework

## What Changed

The original repository centered on a single file:

```text
SOUL.md
```

V3 introduces a reusable multi-character framework:

```text
CORE.md
+ Character Profile
+ Skills
```

## Terminology Change

V2 used:

```text
CORE + Persona + Skills
```

V3 uses:

```text
CORE + Character Profile + Skills
```

Reason: `persona` sounds like a light tone overlay. The intended use includes full character switching in Cursor, so `character profile` is more accurate.

## Compatibility

[`SOUL.md`](../SOUL.md) remains in the repository as the **historical V1 single-file reference** (legacy banner at top). It is **not** used in V3 runtime composition for Cursor or Hermes Route B.

| File | V3 role |
|------|---------|
| Repo `SOUL.md` | Legacy reference; `--legacy` Hermes install only |
| `~/.hermes/SOUL.md` | Composed `CORE` + Discord branding (not repo `SOUL.md`) |
| `characters/*.md` | Active voice for Cursor bundles and Hermes `/personality` |

New compositions should prefer:

```text
CORE.md
+ characters/sky-feather.md
+ relevant skills
```

## Migration Phases

### Phase 1 — Create New Structure

Add:

```text
CORE.md
characters/
skills/
examples/
docs/runtime-composition.md
docs/character-switching.md
docs/migration-notes.md
```

Do not mutate runtime-specific Hermes configuration during this repository refactor.

### Phase 2 — Extract Durable Doctrine

Move non-character-specific principles into `CORE.md`:

- evidence-first engineering
- scientific method
- failure as feedback
- documentation doctrine
- safety boundaries
- verification expectations

### Phase 3 — Extract Sky Feather Profile

Move Sky Feather-specific tone, speech, visual flavor, and examples into:

```text
characters/sky-feather.md
```

### Phase 4 — Add Other Character Profiles

Create:

```text
characters/suzushima-arisu.md
characters/sumeragi-setsuna.md
characters/aihara-tsubaki.md
characters/ousaka-akane.md
```

### Phase 5 — Move Workflows Into Skills

Create workflow modules:

```text
skills/scientific-method/SKILL.md
skills/engineering-journal/SKILL.md
skills/architecture-review/SKILL.md
skills/debugging/SKILL.md
skills/gsd/SKILL.md
```

### Phase 6 — Create Composition Examples

Create Discord and Cursor examples under `examples/`.

### Phase 7 — Test Character Consistency

Run the same technical prompt across all characters.

Expected result:

- same engineering conclusion
- same evidence standards
- different tone

### Phase 8 — V3.1 Utility Characters

Add:

```text
characters/kujo-kaede.md
characters/inohara-koboshi.md
examples/cursor-kaede.md
examples/cursor-koboshi.md
```

No architectural changes. Utility profiles fill ops/maintenance and automation/DX niches.

### Phase 9 — Cursor Global Lifecycle (V3.2)

**Removed:**

```text
scripts/install-cursor-local.sh
```

**Added:**

```text
scripts/install-cursor-global.{sh,ps1,cmd}
scripts/switch-character.{sh,ps1,cmd}
scripts/uninstall-cursor-global.{sh,ps1,cmd}
scripts/build-bundles.{sh,ps1}
scripts/lib/characters.json
scripts/lib/cursor-paths.json
docs/cursor-quickstart.md
```

**Path changes:**

| Before (V1 / early V3) | After (V3.2) |
|------------------------|--------------|
| `~/.cursor/skills/sky-feather-soul/` | `~/.cursor/skills/sky-feather-character/` |
| Paste full SOUL.md into User Rules | Thin User Rules stub (once) |
| `examples/cursor-*.md` as paste targets | Composition **metadata** only |
| Manual character switch | `switch-character` script + new chat |

**True flat compositions** live at `~/.cursor/sky-feather/bundles/*.md` after running `install-cursor-global`.

**Migration steps for existing users:**

1. Run `install-cursor-global` for your OS (see [cursor.md](cursor.md))
2. Replace User Rules: remove full `SOUL.md` block; paste thin stub from install output
3. Legacy `sky-feather-soul` skill is removed automatically on install
4. Use `switch-character <id>` instead of swapping composition files
5. Optional cleanup: `uninstall-cursor-global --dry-run` then `--legacy` if duplicates remain

## Migration Risk

The main risk is accidentally moving engineering doctrine into a character profile, which would make standards vary by character.

Mitigation:

- keep `CORE.md` character-neutral
- keep `characters/*.md` presentation-focused
- keep `skills/*/SKILL.md` workflow-focused
