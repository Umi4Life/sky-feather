# Character Switching

## Design Goal

Support two different usage models:

1. **Discord Hermes:** public identity remains Sky Feather.
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

## Cursor Full Character Switching

Cursor loads full profiles via the global V3.2 install. See [cursor.md](cursor.md) and [cursor-quickstart.md](cursor-quickstart.md).

### Switch command

```bash
# macOS / Linux / Git Bash
./scripts/switch-character.sh <character-id-or-alias>
```

```powershell
# Windows PowerShell
.\scripts\switch-character.ps1 <character-id-or-alias>
```

Start a **new chat** after switching.

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

Flat bundles (after install): `~/.cursor/sky-feather/bundles/<id>.md`

Composition metadata (which files each bundle includes): `examples/cursor-*.md`

## Discord Hermes — switching today

In-Discord `/hermes character …` is **not shipped yet** (future syntax). On the Hermes VM today:

```bash
bash scripts/switch-hermes-character.sh <id-or-alias>
sudo systemctl restart hermes-gateway
```

See [hermes.md](hermes.md) for install, upgrades, and mode labels.

### Future in-Discord syntax (design only)

```text
/hermes character sky-feather
/hermes character arisu
/hermes character setsuna
```

## Task-Based Suggestions

A later implementation may suggest modes without silently switching:

```text
This looks like an architecture review.
Suggested character: Sumeragi Setsuna.
Proceed with Architect Mode?
```

## Character Selection Guide

| Work type | Suggested profile | Public Discord label |
|---|---|---|
| General engineering | Sky Feather | Sky Feather |
| Architecture review | Sumeragi Setsuna | Sky Feather: Architect Mode |
| Pair programming/debugging | Aihara Tsubaki | Sky Feather: Pair-Programming Mode |
| Experiments/tinkering | Suzushima Arisu | Sky Feather: Cozy Lab Mode |
| Brainstorming/ideation | Ousaka Akane | Sky Feather: Brainstorm Mode |
| Ops review / postmortem / cleanup | Kujo Kaede | Sky Feather: Ops Mode |
| Automation / workflow optimization | Inohara Koboshi | Sky Feather: Automation Mode |

## Non-Negotiable Rule

Character switching changes delivery style, not engineering standards.

Every character must preserve:

- `CORE.md` doctrine
- evidence requirements
- safety boundaries
- honest uncertainty
- verification before success claims
