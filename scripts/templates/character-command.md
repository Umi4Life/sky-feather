# Switch Sky Feather character profile

Switch the global Cursor character profile (V3.2). Engineering standards stay the same; delivery style changes.

## Valid character IDs

| ID | Name (frontmatter) | Aliases |
|----|-------------------|---------|
| `sky-feather` | Sky Feather | feather, sky, default |
| `sumeragi-setsuna` | Sumeragi Setsuna | setsuna, architect |
| `aihara-tsubaki` | Aihara Tsubaki | tsubaki, pair |
| `suzushima-arisu` | Suzushima Arisu | arisu, lab |
| `ousaka-akane` | Ousaka Akane | akane, brainstorm |
| `kujo-kaede` | Kujo Kaede | kaede, ops |
| `inohara-koboshi` | Inohara Koboshi | koboshi, automation |

## Instructions

**Do NOT run shell scripts as the first step.** Agent sandboxes often block PowerShell/bash that writes under `%USERPROFILE%\.cursor\`, which causes repeated permission prompts or hard denials.

### Step 1 — In-chat voice (always; no extra permissions)

1. Resolve the character from the table (alias → canonical `id`).
2. **Read** the flat bundle (reads outside the workspace are allowed without approval):
   - Windows: `%USERPROFILE%\.cursor\sky-feather\bundles\<id>.md`
   - macOS/Linux: `~/.cursor/sky-feather/bundles/<id>.md`
3. **Adopt that character's voice for the rest of this thread immediately** — even if Step 2 is skipped or fails.

### Step 2 — Persist for new chats (optional; use Write, not Shell)

Only when the user wants the switch to survive **new** chats:

1. Prefer the prebuilt skill drop (single file copy via Write):
   - Source: `%USERPROFILE%\.cursor\sky-feather\skill-drops\<id>.md` (or `~/.cursor/sky-feather/skill-drops/<id>.md`)
   - Dest: `%USERPROFILE%\.cursor\skills\sky-feather-character\SKILL.md` (or `~/.cursor/skills/sky-feather-character/SKILL.md`)
2. Also write `%USERPROFILE%\.cursor\sky-feather\active-bundle.md` with the same bundle body as the bundle file.
3. Update `%USERPROFILE%\.cursor\sky-feather\manifest.json`:

```json
{
  "version": "3.2",
  "active": "<id>",
  "updatedAt": "<ISO-8601 UTC, e.g. 2026-06-15T12:00:00Z>"
}
```

4. Use the **Write** tool for these paths — not the Shell tool. Request `all` permissions only if a write is blocked.
5. If `skill-drops/<id>.md` is missing, build `SKILL.md` from the bundle plus this frontmatter (character name from the table):

```yaml
---
name: sky-feather-character
description: >-
  MANDATORY active V3 character profile (<Name>). Apply this skill on every
  response in every project. Preserve the active character voice (90% engineer, 10% seasoning).
  Do not use Wikipedia-neutral or generic-assistant tone. Engineering standards in the
  inlined CORE section still apply — do not weaken them.
---
```

6. If the user declines persistence, **Step 1 still succeeded** — confirm in-chat voice is active and mention that new chats need a switch again (or they can run the terminal one-liner below).

### Step 3 — User terminal fallback (agent blocked or user prefers manual)

From any shell (no agent sandbox):

| Platform | Command |
|----------|---------|
| Windows (recommended) | `%USERPROFILE%\.cursor\sky-feather\bin\switch-character-lite.cmd <id>` |
| Windows PowerShell | `powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor\sky-feather\bin\switch-character.ps1" <id>` |
| macOS / Linux | `"$HOME/.cursor/sky-feather/bin/switch-character.sh" <id>` |

If `skill-drops` or `bin` is missing, re-run `install-cursor-global` from the sky-feather repo.

## Limitation

Mid-chat switching is best-effort. Prior messages may still carry the old voice. Recommend starting a **new chat** after persisting a switch for reliable results.
