# Sky Feather

> **Evidence-first engineering built on the scientific method.** [`CORE.md`](CORE.md) defines the operating standard that never changes; [`characters/`](characters/) and [`skills/`](skills/) add presentation and task workflows on top.

Made mainly for Discord → Hermes, with install paths for Cursor, GitHub Copilot, Claude Code, and other agents.

## [Scientific method](https://flagmac.com/id/lessons/scientific_method/scientific_method.html) for engineers

<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/The_Scientific_Method.svg/1920px-The_Scientific_Method.svg.png" width="50%" alt="The Scientific Method">
</div>

Software development and debugging are not guess-and-patch exercises. They are inquiry: collect observations, narrow causes, test the smallest change that could falsify a theory, and update the model when the result surprises you.

The core loop:

```text
Observe
→ Question
→ Hypothesize
→ Experiment
→ Analyze
→ Iterate
```

Software version:

```text
Symptoms / logs
→ actual blocker
→ ranked causes
→ minimal repro or test
→ diagnosis from evidence
→ improved version
```

Outcomes you should expect:

- Faster root-cause isolation
- Fewer “fix the wrong thing” detours
- Smaller, falsifiable experiments instead of large speculative diffs
- Better incident learning through engineering journal patterns

Full doctrine: [`CORE.md`](CORE.md) (Permanent Principles, Evidence Standards, Failure Handling). Workflow module: [`skills/scientific-method/SKILL.md`](skills/scientific-method/SKILL.md).

---

## Quick links

- [CORE.md](CORE.md) — durable doctrine
- [Character Introduction Wiki](docs/wiki/character-introductions/README.md)
- [Cursor quickstart](docs/cursor-quickstart.md)
- [Claude Code quickstart](docs/claude-quickstart.md)
- [Hermes install](docs/hermes.md)

---

## Characters

Official-source intros, profile art, and game metadata live in the **[Character Introduction Wiki](docs/wiki/character-introductions/README.md)**.

Runtime voice files for agent composition are in [`characters/`](characters/).

| Profile | Best for | Cursor metadata |
|---|---|---|
| Sky Feather | general engineering, Discord Hermes, homelab, blogging | [example](examples/cursor-sky-feather.md) |
| Suzushima Arisu | cozy lab, experiments, tinkering | [example](examples/cursor-suzushima-arisu.md) |
| Sumeragi Setsuna | architecture review, RFC critique, planning | [example](examples/cursor-sumeragi-setsuna.md) |
| Aihara Tsubaki | pair programming, debugging, code review | [example](examples/cursor-aihara-tsubaki.md) |
| Ousaka Akane | brainstorming, ideation, ambitious planning | [example](examples/cursor-ousaka-akane.md) |
| Kujo Kaede | ops review, cleanup, postmortems, reliability | [example](examples/cursor-kaede.md) |
| Inohara Koboshi | automation, scripting, CI/CD, workflow optimization | [example](examples/cursor-koboshi.md) |

Character profiles may change tone, phrasing, humor, emotional posture, and catchphrases. They must not change correctness standards, safety behavior, evidence requirements, or `CORE.md` doctrine.

---

## How it fits together

```text
CORE.md
+ Character Profile
+ Skills
```

See [docs/runtime-composition.md](docs/runtime-composition.md) for composition rules and load order. [`SOUL.md`](SOUL.md) remains the historical single-file Sky Feather reference; new setups should prefer the split layout above.

---

## Get started

| Surface | Doc |
|---|---|
| Cursor | [quickstart](docs/cursor-quickstart.md) → [full guide](docs/cursor.md) |
| Hermes | [hermes.md](docs/hermes.md) |
| GitHub Copilot | [github-copilot.md](docs/github-copilot.md) |
| Claude Code | [quickstart](docs/claude-quickstart.md) → [full guide](docs/claude-code.md) |
| Other agents | [other-agents.md](docs/other-agents.md) |

**Cursor (summary):** clone this repo → run the global installer → paste the one-time User Rules stub → `switch-character` → start a new chat.

**Claude Code (summary):** clone this repo → run `install-claude-global` → start a new session → `switch-claude-character` or `/character`.

---

## Repository map

### Core

| Path | Purpose |
|------|---------|
| [CORE.md](CORE.md) | Durable character-neutral engineering doctrine |
| [SOUL.md](SOUL.md) | Historical single-file Sky Feather reference |
| [characters/](characters/) | Character voice profiles |
| [skills/](skills/) | Workflow modules: scientific method, debugging, architecture review, journal, GSD |
| [examples/](examples/) | Runtime composition examples for Discord Hermes and Cursor |

### Wiki

| Path | Purpose |
|------|---------|
| [Character Introduction Wiki](docs/wiki/character-introductions/README.md) | Official-source character intros, art, and metadata |

### Docs

| Path | Purpose |
|------|---------|
| [docs/runtime-composition.md](docs/runtime-composition.md) | How CORE + character profiles + skills compose |
| [docs/character-switching.md](docs/character-switching.md) | Discord branding and Cursor / Claude character switching |
| [docs/migration-notes.md](docs/migration-notes.md) | Migration notes from single `SOUL.md` |
| [docs/cursor-quickstart.md](docs/cursor-quickstart.md) | One-page Cursor install / switch / update |
| [docs/claude-quickstart.md](docs/claude-quickstart.md) | One-page Claude Code install / switch / update |
| [docs/claude-code.md](docs/claude-code.md) | Full Claude Code install, update, uninstall |
| [docs/cursor.md](docs/cursor.md) | Full Cursor install, update, uninstall |
| [docs/hermes.md](docs/hermes.md) | Hermes install and upgrade |
| [docs/roadmap.md](docs/roadmap.md) | Shipped work, planned initiatives, validation logs |

### Scripts

| Path | Purpose |
|------|---------|
| [scripts/install-cursor-global.sh](scripts/install-cursor-global.sh) | Global Cursor install (macOS / Linux / Git Bash) |
| [scripts/install-cursor-global.ps1](scripts/install-cursor-global.ps1) | Global Cursor install (Windows PowerShell) |
| [scripts/install-claude-global.sh](scripts/install-claude-global.sh) | Global Claude Code install (macOS / Linux / Git Bash) |
| [scripts/install-claude-global.ps1](scripts/install-claude-global.ps1) | Global Claude Code install (Windows PowerShell) |
| [scripts/switch-character.sh](scripts/switch-character.sh) | Switch active global Cursor character profile |
| [scripts/switch-claude-character.sh](scripts/switch-claude-character.sh) | Switch active global Claude Code character profile |
| [scripts/uninstall-cursor-global.sh](scripts/uninstall-cursor-global.sh) | Uninstall / prune global Cursor artifacts |
| [scripts/uninstall-claude-global.sh](scripts/uninstall-claude-global.sh) | Uninstall / prune global Claude Code artifacts |
| [scripts/install-hermes-global.sh](scripts/install-hermes-global.sh) | Install on Hermes (`~/.hermes/SOUL.md` + skills) |

---

## Discord Hermes branding

Discord Hermes stays publicly branded as **Sky Feather**. Other profiles act as internal mode inspiration — use labels like `Sky Feather: Architect Mode`, not casual identity swaps (`I am now Setsuna.`).

Preset keys, public labels, and switching rules: [docs/character-switching.md](docs/character-switching.md). Default composition: [examples/discord-hermes-sky-feather.md](examples/discord-hermes-sky-feather.md).

---

## Important: do not commit into team repos

Do **not** add these personal character/agent rules to shared service repositories unless everyone agrees.

| Avoid in team repos | Use instead |
|---------------------|-------------|
| `.cursor/rules/sky-feather-soul.mdc` | Cursor **User Rules** or local personal config |
| `.github/copilot-instructions.md` with personal character rules | Personal dotfiles or VS Code user instructions |
| Root `CLAUDE.md` with full character profile | `~/.claude/CLAUDE.md` or personal rules |

Symlinking this repo into many clones causes accidental PR noise and `git status` clutter.
