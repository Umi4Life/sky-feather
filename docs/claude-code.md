# Install Sky Feather on Claude Code

Claude Code loads global instructions from `~/.claude/CLAUDE.md`. Sky Feather V3.2 installs a **managed flat bundle** there (activation + character + CORE + skill index) — same composition as Cursor, without legacy `SOUL.md`.

Quick reference: [claude-quickstart.md](claude-quickstart.md).

## Table of contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Install (first time)](#install-first-time)
4. [Switch character](#switch-character)
5. [Update](#update)
6. [Uninstall](#uninstall)
7. [Verify](#verify)
8. [Do not use in team repos](#do-not-use-in-team-repos)

---

## Overview

Sky Feather V3.2 for Claude Code installs **one global injection point**:

| What | Where | Managed by |
|------|-------|------------|
| Mirror + bundles | `~/.claude/sky-feather/` | install script |
| Active profile (inlined) | `~/.claude/CLAUDE.md` | install / switch scripts |
| Mid-chat switch helper | `~/.claude/skills/character/SKILL.md` | install script (`/character`) |

Character switching changes **delivery style**, not engineering standards (`CORE.md` is inlined in every bundle).

Claude and Cursor use **independent mirrors** — you can run different active characters on each surface.

---

## Prerequisites

- Git clone of this repository
- Shell for your OS:
  - **macOS / Linux:** bash or zsh
  - **Windows:** PowerShell 5.1+ or PowerShell 7+ (recommended), or Git Bash, or cmd via `.cmd` wrappers

---

## Install (first time)

Clone the repo, then run the installer for your platform:

| Platform | Command |
|----------|---------|
| macOS | `./scripts/install-claude-global.sh` |
| Linux | `./scripts/install-claude-global.sh` |
| Windows PowerShell | `.\scripts\install-claude-global.ps1` |
| Windows cmd | `scripts\install-claude-global.cmd` |
| Windows Git Bash | `./scripts/install-claude-global.sh` |

Optional: pass a repo path (if not running from the clone):

```bash
./scripts/install-claude-global.sh /path/to/sky-feather
```

```powershell
.\scripts\install-claude-global.ps1 -RepoPath D:\path\to\sky-feather
```

### Expected output

The installer:

1. Syncs repo content to `~/.claude/sky-feather/` (no `SOUL.md`)
2. Builds flat bundles into `~/.claude/sky-feather/bundles/`
3. Sets active character (default: `sky-feather`, or preserves existing from `manifest.json`)
4. Writes `~/.claude/CLAUDE.md` with the full inlined bundle
5. Installs `~/.claude/skills/character/SKILL.md` for `/character`
6. Copies switch scripts to `~/.claude/sky-feather/bin/`

### Paths created

```text
~/.claude/CLAUDE.md
~/.claude/sky-feather/
~/.claude/sky-feather/bundles/
~/.claude/sky-feather/active-bundle.md
~/.claude/sky-feather/bin/switch-claude-character.*
~/.claude/skills/character/SKILL.md
```

After install, start a **new** Claude Code session.

---

## Switch character

### Script (recommended)

**Preferred — global script (any workspace):**

```powershell
# Windows PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sky-feather\bin\switch-claude-character.ps1" sumeragi-setsuna
```

```bash
# macOS / Linux / Git Bash
"$HOME/.claude/sky-feather/bin/switch-claude-character.sh" sumeragi-setsuna
```

**From repo clone (also works):**

```bash
./scripts/switch-claude-character.sh setsuna
```

```powershell
.\scripts\switch-claude-character.ps1 setsuna
```

Character IDs and aliases: [claude-quickstart.md](claude-quickstart.md#character-ids).

After switching, start a **new** Claude Code session for reliable application.

### In-CLI (`/character` skill)

Type `/character setsuna` (or `/character` and Claude asks which id). The skill runs the global switch script, reads `~/.claude/CLAUDE.md`, and adopts the new voice for the rest of the thread.

Mid-chat switching is **best-effort** — prior messages may still carry the old voice. New session is still recommended.

### Not supported

Conversational switching (`"Switch to Architect Mode"`) does not update `CLAUDE.md` or `manifest.json`.

---

## Update

When this repository changes (new characters, CORE updates, skill tweaks):

```bash
cd /path/to/sky-feather
git pull
./scripts/install-claude-global.sh
```

```powershell
cd D:\path\to\sky-feather
git pull
.\scripts\install-claude-global.ps1
```

Re-running install refreshes bundles and rewrites `CLAUDE.md` from the preserved active character.

---

## Uninstall

Preview:

```bash
./scripts/uninstall-claude-global.sh --dry-run
```

```powershell
.\scripts\uninstall-claude-global.ps1 -DryRun
```

Remove:

```bash
./scripts/uninstall-claude-global.sh
```

```powershell
.\scripts\uninstall-claude-global.ps1
```

Removes:

- `~/.claude/sky-feather/` mirror
- `~/.claude/skills/character/`
- `~/.claude/CLAUDE.md` **only if** it contains the sky-feather managed header (custom files are skipped)

---

## Verify

1. Start a new Claude Code session.
2. Ask a technical question.
3. Confirm engineering clarity + light character seasoning (90/10 ratio).
4. Run `switch-claude-character setsuna`, start a new session, confirm voice shift.

---

## Do not use in team repos

Keep persona in `~/.claude/CLAUDE.md` (global user file), not project `./CLAUDE.md`, unless the team explicitly opts in.

See [README.md](../README.md#important-do-not-commit-into-team-repos).

Official reference: [Claude Code memory / CLAUDE.md](https://code.claude.com/docs/en/best-practices)
