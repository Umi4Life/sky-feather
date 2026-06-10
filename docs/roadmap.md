# Sky Feather — Roadmap

Living record of planned, in-progress, and shipped work across Sky Feather surfaces (Hermes, Cursor, docs, scripts, etc.).

**How to use this file**

- Add a row to the **index** when a new initiative starts.
- Keep operator runbooks in surface-specific docs ([`hermes.md`](hermes.md), [`character-switching.md`](character-switching.md), …); this file tracks **intent, status, acceptance, and incidents**.
- When something ships, move detail into a **Shipped** subsection and leave a short summary in the index.
- Record VM validation dates and regressions in **Engineering journal** (or per-initiative journals below).

**Deployed Hermes target:** user `hermes`, `HERMES_HOME=~/.hermes`, service `hermes-gateway`

---

## Roadmap index

| ID | Initiative | Status | Target | Notes |
|----|------------|--------|--------|-------|
| **H-B** | Hermes Discord `/personality` presets (Route B) | ✅ Shipped | Hermes VM | VM-validated 2026-06-10; commits `6c871ac`, `88ea963` |
| **H-C** | Hermes `/hermes character` branded wrapper (Route C) | 📋 Planned | Hermes gateway | Thin wrapper over H-B; not started |
| **H-P** | `/personality` scope + mode contrast polish | 📋 Planned | Hermes VM | Document per-user/channel/server scope; optional preamble/SOUL tuning |
| | *(add future rows here)* | | | |

---

## H-B — Hermes Discord `/personality` presets (Route B)

**Status:** ✅ Shipped and VM-validated (2026-06-10)

**Summary:** In-Discord mode switch via Hermes native `/personality <preset-key>`. Slim `SOUL.md` (CORE + branding); character delivery in `agent.personalities` presets generated on install.

**Preset keys** (`personalityKey` in `scripts/lib/characters.json`):

`sky-feather`, `setsuna`, `tsubaki`, `arisu`, `akane`, `kaede`, `koboshi`

| Character id | Preset key | Discord public label |
|--------------|------------|----------------------|
| `sky-feather` | `sky-feather` | Sky Feather |
| `sumeragi-setsuna` | `setsuna` | Sky Feather: Architect Mode |
| `aihara-tsubaki` | `tsubaki` | Sky Feather: Pair-Programming Mode |
| `suzushima-arisu` | `arisu` | Sky Feather: Cozy Lab Mode |
| `ousaka-akane` | `akane` | Sky Feather: Brainstorm Mode |
| `kujo-kaede` | `kaede` | Sky Feather: Ops Mode |
| `inohara-koboshi` | `koboshi` | Sky Feather: Automation Mode |

### Architecture (shipped)

```text
~/.hermes/SOUL.md
  → CORE.md + Discord branding (no per-mode character voice)

~/.hermes/config.yaml → agent.personalities
  → <personalityKey>: preamble + characters/<id>.md

~/.hermes/skills/
  → synced on install
```

### VM validation log (2026-06-10)

1. `git pull` → `6c871ac`, `bash scripts/install-hermes-global.sh`, `sudo systemctl restart hermes-gateway`
2. File checks passed: single root `agent:`, marker block present, seven preset keys in `config.yaml`
3. **Incident:** Discord `unknown personality: setsuna` — duplicate root `agent:` from first merge on existing VM config
4. **Fix:** `88ea963` — merge presets under existing `agent.personalities`; re-install + restart
5. **Discord:** Presets in `/personality` list; `/personality setsuna`, `/personality arisu`, etc. succeed
6. **Voice check:** Switch ack / generic “test personality” still sounds like default Sky Feather (SOUL slot #1 + branding — expected)
7. **Validated delivery:** `/new` → `/personality arisu` → delivery-stress prompt → Arisu understatement confirmed ✅
8. **Operator takeaway:** Use `/new` before mode testing; ack after `/personality` is not a reliable voice demo

### Operator upgrade path

```bash
cd ~/sky-feather
git pull
bash scripts/install-hermes-global.sh
sudo systemctl restart hermes-gateway   # SOUL reload; personality-only changes need no restart
```

Use `bash scripts/...` — avoid `chmod +x` on tracked files (or `git config core.fileMode false` on the VM clone).

### Acceptance criteria (met)

```bash
test -f ~/.hermes/config.yaml
grep -q 'sky-feather:personalities:start' ~/.hermes/config.yaml
test "$(grep -c '^agent:[[:space:]]*$' ~/.hermes/config.yaml)" -eq 1
head -20 ~/.hermes/SOUL.md   # CORE + branding; not full character voice
```

Discord: `/new` → `/personality arisu` → delivery-stress prompt → mode-specific tone.

### Implementation checklist (complete)

<details>
<summary>Route B checklist (archived)</summary>

- [x] `personalityKey` in `characters.json`; `sf_get_character_personality_key()` in `common.sh`
- [x] Templates: `hermes-soul-branding.md`, `hermes-personality-preamble.md`
- [x] Slim SOUL install (Option A); legacy full-SOUL switch retained in `switch-hermes-character.sh`
- [x] `sf_merge_hermes_personalities()` — marker block under first `agent.personalities`
- [x] Install script: skills sync + personality merge + `--dry-run`
- [x] Docs: `hermes.md`, `character-switching.md`

</details>

### Risks (do not regress)

| Risk | Mitigation |
|------|------------|
| Duplicate root `agent:` (`unknown personality`) | Single root `agent:`; merge under first `agent.personalities` (`88ea963`) |
| CORE drift in presets | CORE only in SOUL; presets reference SOUL |
| 20k truncation | Character-only in presets; install size warnings |
| SOUL + overlay stacking | Slim SOUL; test delivery with `/new` + stress prompt |
| `git pull` blocked by chmod | `bash scripts/...` + `core.fileMode false` |
| grep `default` alias bug | `grep -F '"default": "'` only |

---

## H-C — Hermes `/hermes character` wrapper (Route C)

**Status:** 📋 Planned (H-B prerequisite met on VM)

**Summary:** Branded Discord UX on top of Route B — no duplicate composition.

```text
/hermes character setsuna
  → internally: /personality setsuna
  → reply: "Sky Feather: Architect Mode"
```

### Prerequisites

- [x] H-B live and tested on VM
- [ ] Spike: Hermes gateway custom slash command registration (extension point in upstream)

### Scope (v1)

| Task | Notes |
|------|-------|
| Alias map | Reuse `characters.json` aliases → `personalityKey` |
| Slash handler | Thin wrapper only |
| Public confirmation | `discordLabels` from `hermes-paths.json` |
| Permissions | Optional: admin-only mode switch |
| Suggested mode | Optional V2: heuristic nudge toward a mode |

### Out of scope (v1)

- Per-user persistent mode in database
- Replacing SOUL.md on each command
- Full identity swap in Discord ("I am Setsuna")

### Effort / risk

- **Effort:** ~1.5–3× Route B (gateway coupling)
- **Risk:** Medium (upstream Hermes changes); mitigated if C only wraps B

---

## H-P — Hermes personality polish & operator notes

**Status:** 📋 Planned

| Task | Notes |
|------|-------|
| Document `/personality` scope | Per-user vs per-channel vs server-wide — record finding in [`hermes.md`](hermes.md) |
| Stronger mode contrast (optional) | Louder preamble and/or slimmer SOUL if delivery feels too subtle on generic prompts |

---

## Future roadmaps

Add new sections below (or new top-level `## XX — Title` blocks) using this template:

```markdown
## XX — Short title

**Status:** 📋 Planned | 🚧 In progress | ✅ Shipped

**Summary:** One paragraph — what and why.

### Prerequisites
- [ ] …

### Scope
| Task | Notes |
|------|-------|

### Acceptance criteria
…

### Validation log
…
```

---

## Key files (Hermes)

| Path | Role |
|------|------|
| `scripts/install-hermes-global.sh` | Main install entry |
| `scripts/switch-hermes-character.sh` | Legacy server-wide SOUL switch |
| `scripts/lib/common.sh` | Soul/personality merge helpers |
| `scripts/lib/characters.json` | Character ids, aliases, `personalityKey` |
| `scripts/lib/hermes-paths.json` | Discord labels, `soulMaxChars` |
| `docs/hermes.md` | Operator runbook |
| `docs/character-switching.md` | Mode table + branding rules |
| `~/.hermes/SOUL.md` | Hermes identity slot #1 |
| `~/.hermes/config.yaml` | `agent.personalities` target |

---

## Engineering journal

Cross-initiative incidents and fixes. **Do not regress.**

| Issue | Cause | Fix | Initiative |
|-------|-------|-----|------------|
| `jq required` on VM | Hard jq dependency | python3/grep fallbacks | Hermes install |
| Corrupt `active` id + SOUL header | `grep '"default"'` matched alias in arrays | `grep -F '"default": "'` | Hermes install |
| `git pull` blocked | `chmod +x` changed file mode | `bash scripts/...` + `core.fileMode false` | VM ops |
| Ugly discord label in install output | Greedy grep/sed | Fixed label lookup | Hermes install |
| Stray SOUL path in install log | `sf_build_hermes_soul_file` printed to stdout | Removed printf | Hermes install |
| `unknown personality: setsuna` | Second root `agent:` in `config.yaml` | `88ea963` merge fix | H-B |
| Mode switch ack = default voice | SOUL dominates; branding preamble | `/new` + delivery test (arisu OK) | H-B |

---

## Suggested session prompt (next agent)

```text
Read docs/roadmap.md for status. Route B (H-B) is shipped.

Pick from roadmap index:
- H-C: spike /hermes character wrapper over /personality
- H-P: document /personality scope on VM; optional preamble/SOUL polish
- Or add a new roadmap row + section for the next initiative

Operator runbooks: docs/hermes.md, docs/character-switching.md
Do NOT regress: single root agent: in config.yaml, bash scripts without chmod.
```
