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

**Do NOT run shell scripts as the first step.** Agent sandboxes often block PowerShell/bash that writes under `%USERPROFILE%\.claude\`, which causes repeated permission prompts or hard denials.

### Step 1 — In-chat voice (always; no extra permissions)

1. Use `$ARGUMENTS` as the character ID or alias when provided; otherwise ask the user which character they want.
2. Resolve alias → canonical `id` from the table.
3. **Read** the flat bundle (reads outside the workspace are allowed without approval):
   - Windows: `%USERPROFILE%\.claude\sky-feather\bundles\<id>.md`
   - macOS/Linux: `~/.claude/sky-feather/bundles/<id>.md`
4. **Adopt that character's voice for the rest of this thread immediately** — even if Step 2 is skipped or fails.

### Step 2 — Persist for new sessions (optional; use Write, not Shell)

Only when the user wants the switch to survive **new** sessions:

1. Prefer the prebuilt Claude drop (single file copy via Write):
   - Source: `%USERPROFILE%\.claude\sky-feather\claude-drops\<id>.md` (or `~/.claude/sky-feather/claude-drops/<id>.md`)
   - Dest: `%USERPROFILE%\.claude\CLAUDE.md` (or `~/.claude/CLAUDE.md`)
2. Also write `%USERPROFILE%\.claude\sky-feather\active-bundle.md` with the bundle body (not the drop — bundle only).
3. Update `%USERPROFILE%\.claude\sky-feather\manifest.json`:

```json
{
  "version": "3.2",
  "active": "<id>",
  "updatedAt": "<ISO-8601 UTC>"
}
```

4. Use the **Write** tool — not Shell. Request `all` permissions only if a write is blocked.
5. If `claude-drops/<id>.md` is missing, write `CLAUDE.md` as:

```text
<!-- Managed by sky-feather. Re-run install-claude-global or switch-claude-character. -->

```

followed by the full bundle body from Step 1.

6. If the user declines persistence, **Step 1 still succeeded** — confirm in-chat voice is active.

### Step 3 — User terminal fallback

| Platform | Command |
|----------|---------|
| Windows (recommended) | `%USERPROFILE%\.claude\sky-feather\bin\switch-claude-character-lite.cmd <id>` |
| Windows PowerShell | `powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sky-feather\bin\switch-claude-character.ps1" <id>` |
| macOS / Linux | `"$HOME/.claude/sky-feather/bin/switch-claude-character.sh" <id>` |

If `claude-drops` or `bin` is missing, re-run `install-claude-global` from the sky-feather repo.

## Limitation

Mid-chat switching is best-effort. Prior messages may still carry the old voice. Recommend starting a **new Claude Code session** after persisting a switch for reliable results.
