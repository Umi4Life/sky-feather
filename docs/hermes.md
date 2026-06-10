# Install Sky Feather on Hermes Agent

Hermes loads personality from a **single global identity file**:

```text
~/.hermes/SOUL.md
```

(or `$HERMES_HOME/SOUL.md`)

Sky Feather V3.2 maps onto Hermes as:

| V3 layer | Hermes surface |
|----------|----------------|
| `CORE.md` + active `characters/<id>.md` | Composed `~/.hermes/SOUL.md` |
| `skills/*/SKILL.md` | `~/.hermes/skills/<name>/SKILL.md` |
| Character modes (optional) | `agent.personalities` in `config.yaml` or `/personality` |

Workflow skills stay **out of** `SOUL.md` so the identity file stays under Hermes’s ~20k character cap.

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

# 2. Install V3.2 (backs up existing SOUL.md automatically)
chmod +x scripts/install-hermes-global.sh
./scripts/install-hermes-global.sh

# 3. Restart Hermes
sudo systemctl restart hermes   # or your gateway/service name
```

What the installer does:

1. Backs up your current `~/.hermes/SOUL.md` → `~/.hermes/backups/SOUL.md.<timestamp>`
2. Mirrors repo content to `~/.hermes/sky-feather/` (local source tree + `manifest.json`)
3. Writes composed **CORE + Sky Feather character** → `~/.hermes/SOUL.md`
4. Syncs all `skills/` → `~/.hermes/skills/`
5. Writes `~/.hermes/sky-feather/personalities.example.yaml` for optional mode presets

### Future upgrades

```bash
cd ~/sky-feather   # or wherever you cloned
git pull
./scripts/install-hermes-global.sh
sudo systemctl restart hermes
```

`jq` is optional — install scripts use awk/grep fallbacks when it is not installed.

No more hand-copying `SOUL.md`.

---

## Install modes

| Command | Result |
|---------|--------|
| `./scripts/install-hermes-global.sh` | **V3.2** — CORE + character in SOUL, skills synced |
| `./scripts/install-hermes-global.sh --legacy` | **V1-style** — monolithic `SOUL.md` only |

Use `--legacy` only if you want the old single-file model without layered skills.

---

## Switch character (Discord modes)

Public Discord branding stays **Sky Feather**. Other profiles are delivery modes:

```bash
./scripts/switch-hermes-character.sh setsuna    # Sky Feather: Architect Mode
./scripts/switch-hermes-character.sh kaede      # Sky Feather: Ops Mode
```

Then restart Hermes or start a new session.

Optional: merge `~/.hermes/sky-feather/personalities.example.yaml` into `~/.hermes/config.yaml` and use `/personality <id>`.

See [character-switching.md](character-switching.md) for the full mode table.

---

## Discord default composition

Matches [examples/discord-hermes-sky-feather.md](../examples/discord-hermes-sky-feather.md):

```text
CORE.md
+ characters/sky-feather.md
+ skills/scientific-method/SKILL.md      → ~/.hermes/skills/
+ skills/engineering-journal/SKILL.md   → ~/.hermes/skills/
```

Identity (CORE + character) lives in `SOUL.md`. Skills are loaded from `~/.hermes/skills/` when relevant.

---

## Service user / HERMES_HOME

If Hermes runs as a dedicated user, run install **as that user** (or set `HERMES_HOME` to match the service):

```bash
sudo -u hermes HERMES_HOME=/home/hermes/.hermes ./scripts/install-hermes-global.sh
```

Verify with:

```bash
ls -la ~/.hermes/SOUL.md ~/.hermes/sky-feather/manifest.json
```

---

## Related docs

- [runtime-composition.md](runtime-composition.md) — CORE + character + skills model
- [migration-notes.md](migration-notes.md) — V1 SOUL.md → V3 framework history
- [Hermes SOUL.md docs](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality)
