# Install Sky Feather on other agents

Pattern for every tool: **clone this repo → copy an example stub → reference V3 composition** (`CORE.md` + `characters/<id>.md` + skills). Avoid checking persona files into team repositories.

## V3 composition (active)

```text
Activation (90/10 contract)
→ characters/<id>.md
→ CORE.md
→ skills/*/SKILL.md (when task matches)
```

Repo [`SOUL.md`](../SOUL.md) is **legacy V1 reference** — not used in Cursor V3.2 or Hermes Route B. Use [`characters/`](../characters/) for voice.

## OpenAI Codex / generic `AGENTS.md`

```bash
cp examples/agents/AGENTS.md AGENTS.md
```

**Global:** check your agent's docs for a user-level instructions file; paste activation stub + character profile there if supported.

## Windsurf

```bash
cp examples/other/windsurf-rules.md .windsurfrules
```

## Cline

```bash
cp examples/other/clinerules.md .clinerules
```

## Aider

```bash
cp examples/other/aider-conventions.md CONVENTIONS.md
```

## Gemini CLI

```bash
cp examples/agents/AGENTS.md GEMINI.md
# Adapt header; reference characters/ + CORE from clone
```

## Hermes legacy

`install-hermes-global.sh --legacy` still copies repo `SOUL.md` for V1-style monolithic installs.

## Keeping one source of truth

| Do | Don't |
|----|--------|
| Edit voice in `characters/*.md` | Add new flavor only to legacy `SOUL.md` |
| Use short activation stubs in `examples/` | Commit stubs to team service repos without agreement |
| `git pull` here, refresh global install | Duplicate full persona in five tools and let them drift |

## Verify

New session → technical question → engineering clarity + light seasoning per character delivery contract.
