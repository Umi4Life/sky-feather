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

# Optional: deploy clones only — ignore chmod-only git noise on git pull
git config core.fileMode false

# 2. Install V3.2 (backs up existing SOUL.md automatically)
bash scripts/install-hermes-global.sh

# 3. Restart Hermes
sudo systemctl restart hermes-gateway   # or your gateway/service name
```

**How to run scripts:** prefer `bash scripts/<script>.sh` — no `chmod +x` required.  
Using `chmod +x` then `./scripts/...` also works, but Git may treat the executable-bit change as a local modification and block `git pull` until you `git restore` or `git reset --hard` (or set `core.fileMode false` above).

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
bash scripts/install-hermes-global.sh
sudo systemctl restart hermes-gateway
```

No more hand-copying `SOUL.md`.

---

## Linux distro support

The Hermes install scripts are **bash** and target common server Linux (Ubuntu, Debian, Fedora, Arch, etc.). Requirements:

| Tool | Required? | Notes |
|------|-----------|--------|
| `bash` | Yes | Usually preinstalled |
| `git` | For clone/pull upgrades | |
| `python3` | Optional | Used for JSON parsing if `jq` is missing |
| `jq` | Optional | Faster JSON parsing; scripts fall back without it |
| `grep`, `sed`, `cp` | Yes | Standard on minimal installs |

Hermes Agent itself is distro-agnostic; this repo only installs files under `~/.hermes/` (or `$HERMES_HOME`). Restart command depends on your unit name (`hermes-gateway`, `hermes`, etc.) — check with `systemctl list-units \| grep -i hermes`.

---

## Install modes

| Command | Result |
|---------|--------|
| `bash scripts/install-hermes-global.sh` | **V3.2** — CORE + character in SOUL, skills synced |
| `bash scripts/install-hermes-global.sh --legacy` | **V1-style** — monolithic `SOUL.md` only |

Use `--legacy` only if you want the old single-file model without layered skills.

---

## Switch character (Discord modes)

Public Discord branding stays **Sky Feather**. Other profiles are delivery modes.

**There is no in-Discord `/hermes character` command yet** (documented as a future design). Today, switching is **server-side**:

```bash
bash scripts/switch-hermes-character.sh setsuna   # Sky Feather: Architect Mode
bash scripts/switch-hermes-character.sh kaede     # Sky Feather: Ops Mode
sudo systemctl restart hermes-gateway
```

This updates `~/.hermes/SOUL.md` for the whole gateway until you switch back. Aliases work (`setsuna`, `kaede`, `tsubaki`, `arisu`, `akane`, `koboshi`, `feather`, …).

**Optional — per-session overlay:** merge `~/.hermes/sky-feather/personalities.example.yaml` into `~/.hermes/config.yaml` and use Hermes `/personality <preset>`. That layers on top of `SOUL.md`; it does not replace a full character switch.

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
sudo -u hermes HERMES_HOME=/home/hermes/.hermes bash /home/hermes/sky-feather/scripts/install-hermes-global.sh
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
