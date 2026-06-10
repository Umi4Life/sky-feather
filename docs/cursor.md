# Sky Feather on Cursor — Install, Update, Uninstall

Global V3.2 setup for character profiles in Cursor. Quick reference: [cursor-quickstart.md](cursor-quickstart.md).

## Table of contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Install (first time)](#install-first-time)
4. [One-time User Rules](#one-time-user-rules)
5. [Switch character](#switch-character)
6. [Update](#update)
7. [Uninstall](#uninstall)
8. [Verify](#verify)
9. [Troubleshooting](#troubleshooting)
10. [Do not use in team repos](#do-not-use-in-team-repos)
11. [Legacy / migration](#legacy--migration)

---

## Overview

Sky Feather V3.2 installs **one global injection point** for personality:

| What | Where | Managed by |
|------|-------|------------|
| Flat character bundles | `~/.cursor/sky-feather/bundles/*.md` | install script |
| Active profile (inlined) | `~/.cursor/skills/sky-feather-character/SKILL.md` | install / switch scripts |
| Thin activation stub | Cursor **User Rules** (manual, once) | you |
| Mid-chat switch helper | `~/.cursor/commands/character.md` | install script |

Character switching changes **delivery style**, not engineering standards (`CORE.md` is inlined in every bundle).

---

## Prerequisites

- Git clone of this repository
- Shell for your OS:
  - **macOS / Linux:** bash or zsh
  - **Windows:** PowerShell 5.1+ or PowerShell 7+ (recommended), or Git Bash, or cmd via `.cmd` wrappers
- Optional on Unix: `jq` (bash scripts fall back with reduced alias support; PowerShell has native JSON)

---

## Install (first time)

Clone the repo, then run the installer for your platform:

| Platform | Command |
|----------|---------|
| macOS | `./scripts/install-cursor-global.sh` |
| Linux | `./scripts/install-cursor-global.sh` |
| Windows PowerShell | `.\scripts\install-cursor-global.ps1` |
| Windows cmd | `scripts\install-cursor-global.cmd` |
| Windows Git Bash | `./scripts/install-cursor-global.sh` |

Optional: pass a repo path (if not running from the clone):

```bash
./scripts/install-cursor-global.sh /path/to/sky-feather
```

```powershell
.\scripts\install-cursor-global.ps1 -RepoPath D:\path\to\sky-feather
```

### Expected output

The installer:

1. Syncs repo content to `~/.cursor/sky-feather/`
2. Builds flat bundles into `~/.cursor/sky-feather/bundles/`
3. Sets active character (default: `sky-feather`, or preserves existing from `manifest.json`)
4. Writes `~/.cursor/skills/sky-feather-character/SKILL.md` with the full inlined bundle
5. Installs `~/.cursor/commands/character.md`
6. Removes legacy `~/.cursor/skills/sky-feather-soul/` if present
7. Prints the User Rules stub and next steps

### Paths created

```text
~/.cursor/sky-feather/
  CORE.md, SOUL.md, characters/, skills/, examples/
  bundles/<character-id>.md
  active-bundle.md
  manifest.json
~/.cursor/skills/sky-feather-character/SKILL.md
~/.cursor/commands/character.md
```

---

## One-time User Rules

Paste this **once** into **Cursor Settings -> Rules -> User Rules**:

```text
Apply the global skill sky-feather-character on every response.
It defines the active V3 character profile. Do not use generic-assistant tone.
Engineering standards come from the inlined CORE section; do not weaken them.
```

Do **not** paste full `SOUL.md` or `CORE.md` here. The skill file contains the full active bundle.

After pasting, start a **new** Cursor chat.

---

## Switch character

**Preferred — global script (any workspace):**

```powershell
# Windows PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor\sky-feather\bin\switch-character.ps1" sumeragi-setsuna
```

```bash
# macOS / Linux / Git Bash
"$HOME/.cursor/sky-feather/bin/switch-character.sh" sumeragi-setsuna
```

**From repo clone (also works):**

```bash
./scripts/switch-character.sh setsuna
```

```powershell
.\scripts\switch-character.ps1 setsuna
```

`/character` slash command uses the global path. Agents must **not** edit switch scripts if a run fails — re-run `install-cursor-global` instead.

Character IDs and aliases: [cursor-quickstart.md](cursor-quickstart.md#character-ids).

After switching, start a **new** Cursor chat for reliable application.

Mid-chat: use the `/character` slash command (best-effort; new chat is still recommended).

---

## Update

When this repository changes (new characters, CORE updates, skill tweaks):

```bash
cd /path/to/sky-feather
git pull
./scripts/install-cursor-global.sh
```

```powershell
cd D:\path\to\sky-feather
git pull
.\scripts\install-cursor-global.ps1
```

The installer is **idempotent**. It rebuilds bundles and refreshes the active skill. User Rules rarely need changes after the initial thin stub.

Re-running install preserves your active character if `manifest.json` still references a valid bundle.

---

## Uninstall

Preview what will be removed:

```bash
./scripts/uninstall-cursor-global.sh --dry-run
```

```powershell
.\scripts\uninstall-cursor-global.ps1 -DryRun
```

### Scopes

| Flag | Removes |
|------|---------|
| `--all` (default) | All V1 + V3 global artifacts |
| `--legacy` / `--v1` | `~/.cursor/skills/sky-feather-soul/`, legacy `.mdc` copies |
| `--v3` / `--current` | `~/.cursor/sky-feather/`, `sky-feather-character` skill, `commands/character.md` |

```bash
./scripts/uninstall-cursor-global.sh --all
./scripts/uninstall-cursor-global.sh --legacy
./scripts/uninstall-cursor-global.sh --v3
```

```powershell
.\scripts\uninstall-cursor-global.ps1
.\scripts\uninstall-cursor-global.ps1 -Legacy
.\scripts\uninstall-cursor-global.ps1 -V3
```

### Clean accidental repo rules

```bash
./scripts/uninstall-cursor-global.sh --repo-rules ~/Documents/Projects
```

```powershell
.\scripts\uninstall-cursor-global.ps1 -RepoRules C:\Users\you\Documents\Projects
```

### Manual step (required)

Scripts cannot edit Cursor User Rules. After uninstall:

1. Open **Settings -> Rules -> User Rules**
2. Remove the Sky Feather / SOUL.md / thin-stub block
3. Start a new chat

**Never removed:** `~/.cursor/skills-cursor/` (Cursor internal built-ins).

---

## Verify

1. Start a **new** Cursor chat (not an old thread).
2. Ask the same technical question under two profiles, e.g. Sky Feather then Setsuna:
   ```bash
   ./scripts/switch-character.sh sky-feather    # new chat, ask question
   ./scripts/switch-character.sh sumeragi-setsuna   # new chat, same question
   ```
3. Expect the **same engineering conclusion** and evidence standards, but **different delivery style**.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Generic assistant tone | Old chat thread | Start **new** chat after install/switch |
| Sky Feather when expecting Setsuna | Stale or duplicate V1 skill | `uninstall --legacy` then re-run install; confirm only `sky-feather-character` skill exists |
| Rules ignored | Full SOUL still in User Rules | Replace User Rules with thin stub only |
| Wrong / missing character files | Stale mirror | Re-run `install-cursor-global` |
| `git status` noise in team repos | `.cursor/rules/sky-feather-soul.mdc` in repo | `uninstall --repo-rules <path>` or delete manually |
| Windows script blocked | ExecutionPolicy | Use `.cmd` wrappers, or `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| bash alias resolution fails | `jq` not installed | Install `jq`, or use PowerShell scripts on Windows |

---

## Do not use in team repos

| Avoid | Why |
|-------|-----|
| `<team-repo>/.cursor/rules/sky-feather-soul.mdc` | Shows up in `git status` and PRs |
| Symlinking into many work clones | Accidental commits, reviewer confusion |
| Pasting full character rules into shared repos | Personal config belongs globally |

Use global install + User Rules instead. See [Important: do not commit into team repos](../README.md#important-do-not-commit-into-team-repos).

---

## Legacy / migration

- **V1 (SOUL.md only):** `~/.cursor/skills/sky-feather-soul/` — removed automatically on install; use `uninstall --legacy` to prune manually.
- **V3.2:** `sky-feather-character` skill with inlined bundles.
- **`install-cursor-local.sh`:** removed in V3.2; use `install-cursor-global.{sh,ps1,cmd}`.

Full migration notes: [migration-notes.md](migration-notes.md).

Composition metadata (not paste-into-User-Rules): [examples/cursor-sky-feather.md](../examples/cursor-sky-feather.md) and siblings. True flat bundles: `~/.cursor/sky-feather/bundles/` after install.
