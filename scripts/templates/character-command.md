# Switch Sky Feather character profile

Switch the global Cursor character profile (V3.2). Engineering standards stay the same; delivery style changes.

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

1. Ask the user which character ID (or alias) they want if not specified.
2. Run the **global** switch script below. Works from **any workspace** after `install-cursor-global`.
3. **Do NOT** edit, rewrite, or reimplement `switch-character` scripts. **Do NOT** switch manually by copying bundle files.
4. If the script fails, report the error and tell the user to run `install-cursor-global` again.
5. After the script succeeds, **read** `%USERPROFILE%\.cursor\skills\sky-feather-character\SKILL.md` (Windows) or `~/.cursor/skills/sky-feather-character/SKILL.md` (macOS/Linux).
6. Adopt that character's voice for the rest of this thread.

### Windows PowerShell (preferred)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor\sky-feather\bin\switch-character.ps1" <id>
```

### macOS / Linux / Git Bash

```bash
"$HOME/.cursor/sky-feather/bin/switch-character.sh" <id>
```

### Fallback (only if global bin is missing)

Run from a sky-feather repo clone:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\switch-character.ps1" <id>
```

## Limitation

Mid-chat switching is best-effort. Prior messages may still carry the old voice. Recommend starting a **new chat** after switching for reliable results.
