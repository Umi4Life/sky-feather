---
description: Switch the global Sky Feather character profile for Claude Code (V3.2). Engineering standards stay the same; delivery style changes.
user-invocable: true
argument-hint: "[character-id-or-alias]"
---

# Switch Sky Feather character profile

Switch the global Claude Code character profile (V3.2). Engineering standards stay the same; delivery style changes.

## Valid character IDs

| ID | Aliases |
|----|---------|
| `sky-feather` | feather, sky, default |
| `sumeragi-setsuna` | setsuna, architect |
| `aihara-tsubaki` | tsubaki, pair |
| `suzushima-arisu` | arisu, lab |
| `ousaka-akane` | akane, brainstorm |
| `kujo-kaede` | kaede, ops |
| `inohara-koboshi` | koboshi, automation |

## Instructions

1. Use `$ARGUMENTS` as the character ID or alias when provided; otherwise ask the user which character they want.
2. Run the **global** switch script below. Works from **any workspace** after `install-claude-global`.
3. **Do NOT** edit, rewrite, or reimplement `switch-claude-character` scripts. **Do NOT** switch manually by copying bundle files.
4. If the script fails, report the error and tell the user to run `install-claude-global` again.
5. After the script succeeds, **read** `~/.claude/CLAUDE.md` (Windows: `%USERPROFILE%\.claude\CLAUDE.md`).
6. Adopt that character's voice for the rest of this thread.

### Windows PowerShell (preferred)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sky-feather\bin\switch-claude-character.ps1" <id>
```

### macOS / Linux / Git Bash

```bash
"$HOME/.claude/sky-feather/bin/switch-claude-character.sh" <id>
```

### Fallback (only if global bin is missing)

Run from a sky-feather repo clone:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\switch-claude-character.ps1" <id>
```

## Limitation

Mid-chat switching is best-effort. Prior messages may still carry the old voice. Recommend starting a **new Claude Code session** after switching for reliable results.
