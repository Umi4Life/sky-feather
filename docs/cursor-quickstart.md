# Cursor Quick Reference

One-page cheat sheet for Sky Feather V3.2 global Cursor setup. Full guide: [cursor.md](cursor.md).

## Commands

| Action | macOS / Linux / Git Bash | Windows PowerShell | Windows cmd |
|--------|--------------------------|--------------------|-------------|
| Install | `./scripts/install-cursor-global.sh` | `.\scripts\install-cursor-global.ps1` | `scripts\install-cursor-global.cmd` |
| Switch (any workspace) | `"$HOME/.cursor/sky-feather/bin/switch-character.sh" <id>` | `powershell -File "$env:USERPROFILE\.cursor\sky-feather\bin\switch-character.ps1" <id>` | `%USERPROFILE%\.cursor\sky-feather\bin\switch-character.cmd <id>` |
| Update | `git pull && ./scripts/install-cursor-global.sh` | `git pull; .\scripts\install-cursor-global.ps1` | `git pull` then `scripts\install-cursor-global.cmd` |
| Uninstall (preview) | `./scripts/uninstall-cursor-global.sh --dry-run` | `.\scripts\uninstall-cursor-global.ps1 -DryRun` | `scripts\uninstall-cursor-global.cmd -DryRun` |
| Uninstall (all) | `./scripts/uninstall-cursor-global.sh --all` | `.\scripts\uninstall-cursor-global.ps1` | `scripts\uninstall-cursor-global.cmd` |

After install or switch: **start a new Cursor chat**.

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

## One-time User Rules stub

Paste into **Cursor Settings -> Rules -> User Rules** once:

```text
Apply the global skill sky-feather-character on every response.
It defines the active V3 character profile. Do not use generic-assistant tone.
Engineering standards come from the inlined CORE section; do not weaken them.
```

## Global paths

After install:

```text
~/.cursor/sky-feather/              # mirror + bundles/
~/.cursor/sky-feather/bundles/      # true flat compositions
~/.cursor/skills/sky-feather-character/SKILL.md   # active profile (inlined)
~/.cursor/commands/character.md     # /character slash command
```

## See also

- [cursor.md](cursor.md) — full install, update, uninstall, troubleshooting
- [character-switching.md](character-switching.md) — Discord vs Cursor switching rules
- [migration-notes.md](migration-notes.md) — V1 SOUL.md to V3.2 migration
