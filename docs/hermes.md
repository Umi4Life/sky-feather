# Install Sky Feather on Hermes Agent

Hermes loads personality from a **global identity file** and optional **runtime presets**:

```text
~/.hermes/SOUL.md              ← CORE + Discord branding (slim identity)
~/.hermes/config.yaml          ← agent.personalities (mode overlays)
~/.hermes/skills/              ← workflow skills
```

(or `$HERMES_HOME/...`)

Sky Feather V3.2 Route B maps onto Hermes as:

| V3 layer | Hermes surface |
|----------|----------------|
| `CORE.md` + Discord branding | Composed `~/.hermes/SOUL.md` (no character voice in SOUL) |
| `characters/<id>.md` per mode | `agent.personalities` presets in `config.yaml` |
| `skills/*/SKILL.md` | `~/.hermes/skills/<name>/SKILL.md` |
| Discord mode switch | `/personality <preset-key>` |

Workflow skills stay **out of** `SOUL.md` so the identity file stays under Hermes's ~20k character cap.

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

# 2. Install V3.2 Route B (backs up existing SOUL.md and config.yaml)
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
5. Generates and merges `agent.personalities` into `~/.hermes/config.yaml` (marker-based merge)
6. Writes debug copy → `~/.hermes/sky-feather/personalities.generated.yaml`

### Future upgrades

```bash
cd ~/sky-feather   # or wherever you cloned
git pull
bash scripts/install-hermes-global.sh
sudo systemctl restart hermes-gateway   # SOUL changes only; personalities apply without restart
```

No more hand-copying `SOUL.md`.

Preview personality merge without writing config:

```bash
bash scripts/install-hermes-global.sh --dry-run
```

---

## Linux distro support

The Hermes install scripts are **bash** and target common server Linux (Ubuntu, Debian, Fedora, Arch, etc.). Requirements:

| Tool | Required? | Notes |
|------|-----------|--------|
| `bash` | Yes | Usually preinstalled |
| `git` | For clone/pull upgrades | |
| `python3` | Yes (Route B) | Config.yaml marker merge |
| `jq` | Optional | Faster JSON parsing; scripts fall back without it |
| `grep`, `sed`, `cp` | Yes | Standard on minimal installs |

Hermes Agent itself is distro-agnostic; this repo only installs files under `~/.hermes/` (or `$HERMES_HOME`). Restart command depends on your unit name (`hermes-gateway`, `hermes`, etc.) — check with `systemctl list-units \| grep -i hermes`.

---

## Install modes

| Command | Result |
|---------|--------|
| `bash scripts/install-hermes-global.sh` | **V3.2 Route B** — slim SOUL, skills synced, personalities merged into config.yaml |
| `bash scripts/install-hermes-global.sh --dry-run` | Preview personality block; no config.yaml write |
| `bash scripts/install-hermes-global.sh --legacy` | **V1-style** — monolithic `SOUL.md` only |

Use `--legacy` only if you want the old single-file model without layered skills or `/personality` presets.

---

## Switch character / mode in Discord (primary)

Public Discord branding stays **Sky Feather**. Other profiles are delivery modes via Hermes `/personality`:

| Preset key | Character | Public Discord label |
|------------|-----------|----------------------|
| `sky-feather` | Sky Feather | Sky Feather |
| `setsuna` | Sumeragi Setsuna | Sky Feather: Architect Mode |
| `tsubaki` | Aihara Tsubaki | Sky Feather: Pair-Programming Mode |
| `arisu` | Suzushima Arisu | Sky Feather: Cozy Lab Mode |
| `akane` | Ousaka Akane | Sky Feather: Brainstorm Mode |
| `kaede` | Kujo Kaede | Sky Feather: Ops Mode |
| `koboshi` | Inohara Koboshi | Sky Feather: Automation Mode |

```text
/personality sky-feather    # default Sky Feather delivery
/personality setsuna        # Architect Mode
/personality kaede          # Ops Mode
```

Personality changes **do not require** gateway restart. SOUL.md changes do.

### `/personality` scope

> **Operator note:** Confirm on your gateway whether `/personality` applies per-user, per-channel, or server-wide, and record the finding here after VM validation.

Built-in Hermes presets (`helpful`, `concise`, `kawaii`, etc.) remain available; Sky Feather presets use distinct short keys above to avoid collisions.

---

## Legacy server-wide SOUL switch (ops)

Rewrites `~/.hermes/SOUL.md` with full CORE + character for the **entire gateway** until switched back. Prefer `/personality` for Discord mode changes.

```bash
bash scripts/switch-hermes-character.sh setsuna
sudo systemctl restart hermes-gateway
```

Print Discord preset key without writing SOUL:

```bash
bash scripts/switch-hermes-character.sh setsuna --personality-only
```

**There is no in-Discord `/hermes character` command yet** (Route C roadmap). See [hermes-discord-personality-handoff.md](hermes-discord-personality-handoff.md).

See [character-switching.md](character-switching.md) for the full mode table and branding rules.

---

## Discord default composition

Matches [examples/discord-hermes-sky-feather.md](../examples/discord-hermes-sky-feather.md):

```text
CORE.md + Discord branding     → ~/.hermes/SOUL.md
characters/sky-feather.md      → /personality sky-feather preset
skills/scientific-method/...     → ~/.hermes/skills/
skills/engineering-journal/...   → ~/.hermes/skills/
```

Identity doctrine lives in slim `SOUL.md`. Default voice and other modes come from `/personality` presets.

---

## VM validation (acceptance)

After `git pull && bash scripts/install-hermes-global.sh` on the Hermes VM:

```bash
test -f ~/.hermes/config.yaml
grep -q 'sky-feather:personalities:start' ~/.hermes/config.yaml
test "$(grep -c '^agent:[[:space:]]*$' ~/.hermes/config.yaml)" -eq 1   # must be exactly 1
head -20 ~/.hermes/SOUL.md   # CORE + branding; not full Setsuna voice
grep -E '^[[:space:]]{4}(sky-feather|setsuna|tsubaki|arisu|akane|kaede|koboshi):' ~/.hermes/config.yaml
test -f ~/.hermes/sky-feather/personalities.generated.yaml
bash scripts/install-hermes-global.sh --dry-run
```

Manual Discord checks:

- `/personality setsuna` → Architect delivery, public Sky Feather branding
- `/personality sky-feather` → default Sky Feather delivery
- Same technical question across modes → same engineering conclusion, different tone

### Troubleshooting: `unknown personality: setsuna`

Usually means Hermes did not load Sky Feather presets from `agent.personalities`.

1. **Check for duplicate root `agent:` keys** (common after first Route B install on an existing VM):

   ```bash
   grep -n '^agent:' ~/.hermes/config.yaml
   ```

   Must be **exactly one** `agent:` at the root. If you see two, re-run install after `git pull` (merge fix consolidates under the first `agent.personalities`).

2. **Confirm presets sit under `agent.personalities`**, not in a second `agent:` block:

   ```bash
   sed -n '/^agent:/,/^[^ #]/p' ~/.hermes/config.yaml | head -40
   ```

3. **Re-apply merge and restart gateway** (SOUL + config reload):

   ```bash
   cd ~/sky-feather && git pull
   bash scripts/install-hermes-global.sh
   sudo systemctl restart hermes-gateway
   ```

4. **Built-in presets still work?** Try `/personality helpful`. If built-ins work but `setsuna` does not, the custom block is not in the active `agent.personalities` map.

---

## Service user / HERMES_HOME

If Hermes runs as a dedicated user, run install **as that user** (or set `HERMES_HOME` to match the service):

```bash
sudo -u hermes HERMES_HOME=/home/hermes/.hermes bash /home/hermes/sky-feather/scripts/install-hermes-global.sh
```

Verify with:

```bash
ls -la ~/.hermes/SOUL.md ~/.hermes/config.yaml ~/.hermes/sky-feather/manifest.json
```

---

## Related docs

- [hermes-discord-personality-handoff.md](hermes-discord-personality-handoff.md) — Route B implementation notes + Route C roadmap
- [character-switching.md](character-switching.md) — mode table + branding rules
- [runtime-composition.md](runtime-composition.md) — CORE + character + skills model
- [migration-notes.md](migration-notes.md) — V1 SOUL.md → V3 framework history
- [Hermes SOUL.md docs](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality)
