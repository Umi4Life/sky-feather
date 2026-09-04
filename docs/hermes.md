# Install Sky Feather on Hermes Agent

Hermes loads personality from a **global identity file** and a **character switch skill**:

```text
~/.hermes/SOUL.md                                    ← CORE + Discord branding (slim identity)
~/.hermes/skills/                                    ← workflow skills
~/.hermes/skills/sky-feather-characters/character/     ← character switch skill (profiles in `references/`)
```

(or `$HERMES_HOME/...`)

Sky Feather V3.2 Route B maps onto Hermes as:

| V3 layer | Hermes surface |
|----------|----------------|
| `CORE.md` + Discord branding | Composed `~/.hermes/SOUL.md` (no character voice in SOUL) |
| `characters/<id>.md` per mode | `~/.hermes/skills/sky-feather-characters/character/references/<key>.md` |
| `skills/*/SKILL.md` | `~/.hermes/skills/<name>/SKILL.md` |
| Discord mode switch | `/skill character <key>` |

Workflow and character skills stay **out of** `SOUL.md` so the identity file stays under Hermes's ~20k character cap.

---

## Upgrading from legacy monolithic SOUL.md

Typical V1 VM setup:

```text
~/.hermes/SOUL.md   ← old copy-paste from this repo, no git on the VM
```

### One-time upgrade (recommended)

On the Hermes VM:

```bash
# 1. Clone the repo (first time only — gives you source control + upgrade path)
git clone https://github.com/Umi4Life/sky-feather.git
cd sky-feather

# Optional: deploy clones only — ignore chmod-only git noise on git pull
git config core.fileMode false

# 2. Install V3.2 Route B (backs up existing SOUL.md)
bash scripts/install-hermes-global.sh

# 3. Restart Hermes (SOUL reload)
sudo systemctl restart hermes-gateway   # or your gateway/service name
```

**How to run scripts:** prefer `bash scripts/<script>.sh` — no `chmod +x` required.  
Using `chmod +x` then `./scripts/...` also works, but Git may treat the executable-bit change as a local modification and block `git pull` until you `git restore` or `git reset --hard` (or set `core.fileMode false` above).

What the installer does:

1. Backs up your current `~/.hermes/SOUL.md` → `~/.hermes/backups/SOUL.md.<timestamp>`
2. Mirrors repo content to `~/.hermes/sky-feather/` (local source tree + `manifest.json`)
3. Writes **slim SOUL** (CORE + Discord branding) → `~/.hermes/SOUL.md`
4. Syncs all `skills/` → `~/.hermes/skills/`
5. Installs the `character` switch skill → `~/.hermes/skills/sky-feather-characters/character/SKILL.md` (+ `references/<key>.md`)

### Future upgrades

```bash
cd ~/sky-feather   # or wherever you cloned
git pull
bash scripts/install-hermes-global.sh
sudo systemctl restart hermes-gateway   # SOUL changes only; character switches apply without restart
```

No more hand-copying `SOUL.md`.

---

## Linux distro support

The Hermes install scripts are **bash** and target common server Linux (Ubuntu, Debian, Fedora, Arch, etc.). Requirements:

| Tool | Required? | Notes |
|------|-----------|--------|
| `bash` | Yes | Usually preinstalled |
| `git` | For clone/pull upgrades | |
| `python3` | Route B fallback | Character alias lookup |
| `jq` | Optional | Faster JSON parsing; scripts fall back without it |
| `grep`, `sed`, `cp` | Yes | Standard on minimal installs |

Hermes Agent itself is distro-agnostic; this repo only installs files under `~/.hermes/` (or `$HERMES_HOME`). Restart command depends on your unit name (`hermes-gateway`, `hermes`, etc.) — check with `systemctl list-units \| grep -i hermes`.

---

## Install modes

| Command | Result |
|---------|--------|
| `bash scripts/install-hermes-global.sh` | **V3.2 Route B** — slim SOUL, workflow skills synced, character skills installed |
| `bash scripts/install-hermes-global.sh --legacy` | **V1-style** — copies repo [`SOUL.md`](../SOUL.md) verbatim (legacy reference file) |

Use `--legacy` only if you want the old single-file model without layered skills. V3 Route B does **not** inject repo `SOUL.md` — it composes `CORE` + branding into `~/.hermes/SOUL.md`.

### Character skill priming (V3.2+)

Character references include: preamble → activation block → character profile. Full voice requires an active switch (default: `/skill character sky-feather`). `~/.hermes/SOUL.md` alone is doctrine + branding.

After `git pull` + reinstall, use `/new` then `/skill character <key>` before testing delivery.

---

## Switch character / mode in Discord (primary)

Public Discord branding stays **Sky Feather**. Other profiles are delivery modes via `/skill character <key>`:

| Key | Character | Public Discord label |
|-----------|-----------|----------------------|
| `sky-feather` | Sky Feather | Sky Feather |
| `setsuna` | Sumeragi Setsuna | Sky Feather: Architect Mode |
| `tsubaki` | Aihara Tsubaki | Sky Feather: Pair-Programming Mode |
| `arisu` | Suzushima Arisu | Sky Feather: Cozy Lab Mode |
| `akane` | Ousaka Akane | Sky Feather: Brainstorm Mode |
| `kaede` | Kujo Kaede | Sky Feather: Ops Mode |
| `koboshi` | Inohara Koboshi | Sky Feather: Automation Mode |

```text
/skill character sky-feather    # default Sky Feather delivery
/skill character setsuna        # Architect Mode
/skill character kaede          # Ops Mode
```

Character switches **do not require** gateway restart. SOUL.md changes do.

### `/skill character` scope

> **Operator note:** Confirm on your gateway whether `/skill character` applies per-user, per-channel, or server-wide, and record the finding here after VM validation.

Built-in Hermes presets (`helpful`, `concise`, `kawaii`, etc.) remain available; the Sky Feather `character` skill takes the short key above as its argument.

---

## Legacy server-wide SOUL switch (ops)

Rewrites `~/.hermes/SOUL.md` with full CORE + character for the **entire gateway** until switched back. Prefer `/skill character <key>` for Discord mode changes.

```bash
bash scripts/switch-hermes-character.sh setsuna
sudo systemctl restart hermes-gateway
```

Print the Discord key without writing SOUL:

```bash
bash scripts/switch-hermes-character.sh setsuna --skill-key
```

**There is no in-Discord `/hermes character` command yet** (Route C — see [roadmap.md](roadmap.md)).

See [character-switching.md](character-switching.md) for the full mode table and branding rules.

---

## Discord default composition

Matches [examples/discord-hermes-sky-feather.md](../examples/discord-hermes-sky-feather.md):

```text
CORE.md + Discord branding     → ~/.hermes/SOUL.md
characters/sky-feather.md      → ~/.hermes/skills/sky-feather-characters/character/references/sky-feather.md
skills/scientific-method/...   → ~/.hermes/skills/
skills/engineering-journal/... → ~/.hermes/skills/
```

Identity doctrine lives in slim `SOUL.md`. Default voice and other modes come from `/skill character <key>`.

---

## VM validation (acceptance)

After `git pull && bash scripts/install-hermes-global.sh` on the Hermes VM:

```bash
head -20 ~/.hermes/SOUL.md   # CORE + branding; not full Setsuna voice
test -f ~/.hermes/skills/sky-feather-characters/character/SKILL.md
test -f ~/.hermes/skills/sky-feather-characters/character/references/setsuna.md
ls ~/.hermes/skills/sky-feather-characters/character/references/   # should list 7 keys
test -f ~/.hermes/sky-feather/manifest.json
```

Manual Discord checks:

- `/skill character setsuna` → Architect delivery, public Sky Feather branding
- `/skill character sky-feather` → default Sky Feather delivery
- Same technical question across modes → same engineering conclusion, different tone

### Troubleshooting: skill not recognized

1. **Confirm skill files exist:**

   ```bash
   ls ~/.hermes/skills/sky-feather-characters/
   ```

   Should show: `sky-feather  setsuna  tsubaki  arisu  akane  kaede  koboshi`

2. **Re-run install and restart gateway:**

   ```bash
   cd ~/sky-feather && git pull
   bash scripts/install-hermes-global.sh
   sudo systemctl restart hermes-gateway
   ```

3. **Skill resolves?** Try `/skill character setsuna`. If it fails, Hermes may not be scanning `~/.hermes/skills/sky-feather-characters/` — check gateway skill scan path config.

---

## Service user / HERMES_HOME

If Hermes runs as a dedicated user, run install **as that user** (or set `HERMES_HOME` to match the service):

```bash
sudo -u hermes HERMES_HOME=/home/hermes/.hermes bash /home/hermes/sky-feather/scripts/install-hermes-global.sh
```

Verify with:

```bash
ls -la ~/.hermes/SOUL.md ~/.hermes/sky-feather/manifest.json
```

---

## Related docs

- [roadmap.md](roadmap.md) — shipped work, planned initiatives, VM validation log
- [character-switching.md](character-switching.md) — mode table + branding rules
- [runtime-composition.md](runtime-composition.md) — CORE + character + skills model
- [migration-notes.md](migration-notes.md) — V1 SOUL.md → V3 framework history
- [Hermes SOUL.md docs](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality)
