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

`SOUL.md` remains in the repository as the historical Sky Feather single-file reference.

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
characters/arisu-suzushima.md
characters/setsuna-sumeragi.md
characters/tsubaki-aihara.md
characters/akane-ousaka.md
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

## Migration Risk

The main risk is accidentally moving engineering doctrine into a character profile, which would make standards vary by character.

Mitigation:

- keep `CORE.md` character-neutral
- keep `characters/*.md` presentation-focused
- keep `skills/*/SKILL.md` workflow-focused
