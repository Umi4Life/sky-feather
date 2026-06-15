# Character Switching

## Design Goal

Support two different usage models:

1. **Discord Hermes:** public identity remains Sky Feather; modes via `/personality <preset>`.
2. **Cursor / coding agents:** full character profiles can be selected directly.

## Discord Hermes Branding Rule

Discord bot branding remains:

```text
Sky Feather
```

Sky Feather is the public-facing identity.

Other character profiles may be used internally as mode inspiration, but Discord should not casually say:

```text
I am now Setsuna.
I am now Arisu.
```

unless explicitly requested.

Better public phrasing:

```text
Sky Feather: Architect Mode
Sky Feather: Pair-Programming Mode
Sky Feather: Cozy Lab Mode
Sky Feather: Brainstorm Mode
Sky Feather: Ops Mode
Sky Feather: Automation Mode
```

## Discord Hermes — `/personality` presets (primary)

Install writes presets to `~/.hermes/config.yaml`. Switch modes in Discord with Hermes `/personality`:

| Preset key | Character id | Public Discord label |
|------------|--------------|----------------------|
| `sky-feather` | `sky-feather` | Sky Feather |
| `setsuna` | `sumeragi-setsuna` | Sky Feather: Architect Mode |
| `tsubaki` | `aihara-tsubaki` | Sky Feather: Pair-Programming Mode |
| `arisu` | `suzushima-arisu` | Sky Feather: Cozy Lab Mode |
| `akane` | `ousaka-akane` | Sky Feather: Brainstorm Mode |
| `kaede` | `kujo-kaede` | Sky Feather: Ops Mode |
| `koboshi` | `inohara-koboshi` | Sky Feather: Automation Mode |

```text
/personality sky-feather
/personality setsuna
/personality kaede
```

No gateway restart required for personality changes. See [hermes.md](hermes.md) for install and upgrades.

Character **aliases** (`feather`, `architect`, `ops`, …) still work for bash switch scripts; `/personality` uses **preset keys** only.

## Discord Hermes — legacy server-wide switch (ops)

Rewrites `~/.hermes/SOUL.md` for the whole gateway. Requires restart.

```bash
bash scripts/switch-hermes-character.sh <id-or-alias>
sudo systemctl restart hermes-gateway
```

Prefer `/personality` for Discord. Print preset key without touching SOUL:

```bash
bash scripts/switch-hermes-character.sh setsuna --personality-only
```

### Future in-Discord syntax (Route C — not shipped)

```text
/hermes character sky-feather
/hermes character arisu
/hermes character setsuna
```

## Cursor Full Character Switching

Cursor loads full profiles via the global V3.2 install. See [cursor.md](cursor.md) and [cursor-quickstart.md](cursor-quickstart.md).

### Switch command

**In Cursor chat:** `/character <id>` — agent reads bundle for immediate in-chat voice (no shell). Optional Write to `skill-drops` for persistence.

**Windows terminal (lite, recommended):**

```cmd
%USERPROFILE%\.cursor\sky-feather\bin\switch-character-lite.cmd <id-or-alias>
```

```bash
# macOS / Linux / Git Bash
"$HOME/.cursor/sky-feather/bin/switch-character.sh" <character-id-or-alias>
```

```powershell
# Windows PowerShell
.\scripts\switch-character.ps1 <character-id-or-alias>
```

Start a **new chat** after switching.

Flat bundles (after install): `~/.cursor/sky-feather/bundles/<id>.md`

Composition metadata (which files each bundle includes): `examples/cursor-*.md`

## Claude Full Character Switching

Claude Code loads full profiles via the global V3.2 install. See [claude-code.md](claude-code.md) and [claude-quickstart.md](claude-quickstart.md).

Claude uses an **independent** mirror (`~/.claude/sky-feather/`) — active character may differ from Cursor.

### Switch command

**In Claude Code:** `/character <id>` — reads bundle for in-chat voice; optional Write to `claude-drops` for persistence.

**Windows terminal (lite, recommended):**

```cmd
%USERPROFILE%\.claude\sky-feather\bin\switch-claude-character-lite.cmd <id-or-alias>
```

```bash
# macOS / Linux / Git Bash
./scripts/switch-claude-character.sh <character-id-or-alias>
```

```powershell
# Windows PowerShell
.\scripts\switch-claude-character.ps1 <character-id-or-alias>
```

Start a **new Claude Code session** after switching.

Mid-chat (best-effort): `/character <id>` (installed to `~/.claude/skills/character/SKILL.md`).

Flat bundles (after install): `~/.claude/sky-feather/bundles/<id>.md`

### Character IDs

| ID | Aliases |
|----|---------|
| `sky-feather` | feather, sky, default |
| `sumeragi-setsuna` | setsuna, architect |
| `aihara-tsubaki` | tsubaki, pair |
| `suzushima-arisu` | arisu, lab |
| `ousaka-akane` | akane, brainstorm |
| `kujo-kaede` | kaede, ops |
| `inohara-koboshi` | koboshi, automation |

Applies to both Cursor and Claude global installs.

## Task-Based Suggestions

A later implementation may suggest modes without silently switching:

```text
This looks like an architecture review.
Suggested character: Sumeragi Setsuna.
Proceed with Architect Mode?
```

## Character Selection Guide

| Work type | Suggested profile | Public Discord label | `/personality` key |
|---|---|---|---|
| General engineering | Sky Feather | Sky Feather | `sky-feather` |
| Architecture review | Sumeragi Setsuna | Sky Feather: Architect Mode | `setsuna` |
| Pair programming/debugging | Aihara Tsubaki | Sky Feather: Pair-Programming Mode | `tsubaki` |
| Experiments/tinkering | Suzushima Arisu | Sky Feather: Cozy Lab Mode | `arisu` |
| Brainstorming/ideation | Ousaka Akane | Sky Feather: Brainstorm Mode | `akane` |
| Ops review / postmortem / cleanup | Kujo Kaede | Sky Feather: Ops Mode | `kaede` |
| Automation / workflow optimization | Inohara Koboshi | Sky Feather: Automation Mode | `koboshi` |

## Non-Negotiable Rule

Character switching changes delivery style, not engineering standards.

Every character must preserve:

- `CORE.md` doctrine
- evidence requirements
- safety boundaries
- honest uncertainty
- verification before success claims
