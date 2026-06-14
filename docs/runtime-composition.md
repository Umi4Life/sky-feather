# Runtime Composition

This repository separates agent behavior into three layers:

```text
CORE.md
+ Character Profile
+ Skills
```

## Layer Responsibilities

| Layer | Answers | Contains | Must not contain |
|---|---|---|---|
| `CORE.md` | What standards never change? | mission, evidence standards, scientific method, safety boundaries, documentation doctrine | character-specific speech |
| `characters/*.md` | How does the agent present itself? | voice, tone, catchphrases, emotional posture, examples | task procedures that override core doctrine |
| `skills/*/SKILL.md` | How should this work be performed? | workflow steps, checklists, output templates | character identity |

## Composition Priority

```text
Runtime/system/developer rules
→ CORE.md
→ character profile
→ skills
→ task-specific user request
```

A lower layer may specialize a higher layer, but it must not weaken safety, correctness, evidence, or user-consent requirements.

## Priming order vs conflict priority

**Conflict priority** (which layer wins on disagreements) follows the order above: `CORE.md` beats character profile beats skills.

**Priming order** (physical layout in composed bundles) may differ so voice is not buried under engineering text:

```text
Activation block (90/10 contract)
→ character profile
→ CORE.md
→ skills (reference index — load paths when task matches)
```

Cursor bundles and Hermes `/personality` presets use this priming layout. Hermes `~/.hermes/SOUL.md` stays `CORE` + Discord branding only.

Repo root [`SOUL.md`](../SOUL.md) is **legacy V1 reference** — not injected by Cursor V3.2 or Hermes Route B.

## Discord Hermes Default

Discord public identity remains Sky Feather.

```text
CORE.md
+ characters/sky-feather.md
+ skills/scientific-method/SKILL.md
+ skills/engineering-journal/SKILL.md
```

## Discord Hermes Modes

For Discord, other characters should usually act as hidden mode inspiration unless explicitly enabled.

Recommended public labels:

```text
Sky Feather: Architect Mode
Sky Feather: Pair-Programming Mode
Sky Feather: Cozy Lab Mode
Sky Feather: Brainstorm Mode
Sky Feather: Ops Mode
Sky Feather: Automation Mode
```

Avoid casual public identity switching:

```text
I am now Setsuna.
I am now Arisu.
```

unless the user explicitly requests it.

## Cursor Full Character Switch

Cursor can load full character profiles directly.

Examples:

```text
CORE.md + characters/sky-feather.md + relevant skills
CORE.md + characters/sumeragi-setsuna.md + skills/architecture-review/SKILL.md
CORE.md + characters/aihara-tsubaki.md + skills/debugging/SKILL.md
CORE.md + characters/suzushima-arisu.md + skills/scientific-method/SKILL.md
CORE.md + characters/ousaka-akane.md
CORE.md + characters/kujo-kaede.md + skills/architecture-review/SKILL.md
CORE.md + characters/inohara-koboshi.md + skills/debugging/SKILL.md
```

## Success Criteria

The same technical problem should produce:

- same engineering standards
- same safety boundaries
- same evidence requirements
- same final recommendation quality

Character profiles may change:

- tone
- phrasing
- humor
- emotional posture
- catchphrases

Character profiles must not change:

- correctness standards
- safety behavior
- evidence requirements
- `CORE.md` doctrine
