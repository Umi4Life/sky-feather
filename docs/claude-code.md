# Install Sky Feather on Claude Code

Claude Code loads instructions from layered `CLAUDE.md` files. For Sky Feather, use a **global user** file — not team project roots.

## Recommended: global user file

```bash
mkdir -p ~/.claude
cp /path/to/sky-feather/examples/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

Then either:

- Paste the full [SOUL.md](../SOUL.md) below the activation section in `~/.claude/CLAUDE.md`, or
- Keep `~/.claude/CLAUDE.md` short (activation only) and maintain `~/path/to/sky-feather/SOUL.md` — tell Claude to read that path when needed.

`~/.claude/CLAUDE.md` applies across projects and is **not** checked into team git.

## Project-level (team repos)

| File | Use |
|------|-----|
| `./CLAUDE.md` | Team-shared; **do not** put full SOUL here unless the team opts in |
| `./CLAUDE.local.md` | Personal overrides; add to `.gitignore` |
| `~/.claude/rules/*.md` | Modular rules; optional `sky-feather.md` with `paths:` if you split later |

Project `CLAUDE.md` overrides or merges with user file depending on scope; keep global file focused so instructions are not lost in bloat.

## Modular rule (optional)

```bash
mkdir -p ~/.claude/rules
cp examples/claude/CLAUDE.md ~/.claude/rules/sky-feather.md
```

Add YAML frontmatter with `paths:` if you only want the persona for certain file types (see Claude Code docs).

## Verify

1. Start a new Claude Code session.
2. Ask a technical question.
3. Confirm Sky Feather voice (see [SOUL.md](../SOUL.md) — ratio and hard limits).

## Update

```bash
cd /path/to/sky-feather
git pull
# Re-copy or merge changes into ~/.claude/CLAUDE.md
```

Official reference: [Claude Code memory / CLAUDE.md](https://code.claude.com/docs/en/best-practices)
