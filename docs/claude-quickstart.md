# Claude Code Quick Reference

One-page cheat sheet for Sky Feather V3.2 global Claude Code setup. Full guide: [claude-code.md](claude-code.md).

## Commands

| Action | macOS / Linux / Git Bash | Windows PowerShell | Windows cmd |
|--------|--------------------------|--------------------|-------------|
| Install | `./scripts/install-claude-global.sh` | `.\scripts\install-claude-global.ps1` | `scripts\install-claude-global.cmd` |
| Switch (any workspace) | `"$HOME/.claude/sky-feather/bin/switch-claude-character.sh" <id>` | `powershell -File "$env:USERPROFILE\.claude\sky-feather\bin\switch-claude-character.ps1" <id>` | `%USERPROFILE%\.claude\sky-feather\bin\switch-claude-character-lite.cmd <id>` |
| In session | `/character <id>` (read bundle + optional Write; no shell) | same | same |
| Update | `git pull && ./scripts/install-claude-global.sh` | `git pull; .\scripts\install-claude-global.ps1` | `git pull` then `scripts\install-claude-global.cmd` |
| Uninstall (preview) | `./scripts/uninstall-claude-global.sh --dry-run` | `.\scripts\uninstall-claude-global.ps1 -DryRun` | `scripts\uninstall-claude-global.cmd -DryRun` |
| Uninstall | `./scripts/uninstall-claude-global.sh` | `.\scripts\uninstall-claude-global.ps1` | `scripts\uninstall-claude-global.cmd` |

After install or switch: **start a new Claude Code session**.

Mid-chat (best-effort): `/character <id>`.

## Character IDs

| ID | Aliases | Best for |
|----|---------|----------|
| `sky-feather` | feather, sky, default | general engineering |
| `sumeragi-setsuna` | setsuna, architect | architecture review |
| `aihara-tsubaki` | tsubaki, pair | debugging, pair programming |
| `suzushima-arisu` | arisu, lab | experiments, tinkering |
| `ousaka-akane` | akane, brainstorm | brainstorming |
| `kujo-kaede` | kaede, ops | ops, postmortems |
| `inohara-koboshi` | koboshi, automation | automation, CI/CD |

## Global paths

After install:

```text
~/.claude/CLAUDE.md                          # active profile (inlined)
~/.claude/sky-feather/                         # mirror + bundles/
~/.claude/sky-feather/bundles/                 # true flat compositions
~/.claude/skills/character/SKILL.md           # /character skill
~/.claude/sky-feather/bin/switch-claude-character.*
```

## See also

- [claude-code.md](claude-code.md) — full install, update, uninstall
- [character-switching.md](character-switching.md) — Discord vs Cursor vs Claude switching rules
- [migration-notes.md](migration-notes.md) — V1 SOUL.md to V3.2 migration
