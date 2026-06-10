# sky-feather

> **Evidence-first engineering doctrine with selectable character profiles.** `CORE.md` defines the scientific-method operating standard; `characters/` defines presentation; `skills/` defines task workflows.

## What changed in V3

The project now separates durable engineering behavior from character voice:

```text
CORE.md
+ Character Profile
+ Skills
```

This resolves two use cases:

- **Discord Hermes** can remain publicly branded as **Sky Feather**.
- **Cursor / coding agents** can fully switch character profiles, including Sky Feather, Suzushima Arisu, Sumeragi Setsuna, Aihara Tsubaki, Ousaka Akane, Kujo Kaede, and Inohara Koboshi.

`SOUL.md` remains as the historical single-file Sky Feather reference. New compositions should prefer `CORE.md + characters/*.md + skills/*/SKILL.md`.

### V3.1 — Kaede & Koboshi

V3.1 adds two utility character profiles with no architectural changes:

| Profile | Niche |
|---|---|
| Kujo Kaede | operational rigor, maintenance discipline, postmortem mindset |
| Inohara Koboshi | automation, developer experience, workflow optimization |

Core characters remain Sky Feather, Suzushima Arisu, Sumeragi Setsuna, Aihara Tsubaki, and Ousaka Akane.

---

## Scientific method for engineers

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

---

## Repository contents

| Path | Purpose |
|------|---------|
| [CORE.md](CORE.md) | Durable character-neutral engineering doctrine |
| [SOUL.md](SOUL.md) | Historical single-file Sky Feather reference |
| [characters/](characters/) | Character profiles: Sky Feather, Suzushima Arisu, Sumeragi Setsuna, Aihara Tsubaki, Ousaka Akane, Kujo Kaede, Inohara Koboshi |
| [character-introductions/](docs/wiki/character-introductions/README.md) | Official-source character introduction wiki and profiles |
| [skills/](skills/) | Workflow modules: scientific method, debugging, architecture review, journal, GSD |
| [examples/](examples/) | Runtime composition examples for Discord Hermes and Cursor |
| [docs/runtime-composition.md](docs/runtime-composition.md) | How CORE + character profiles + skills compose |
| [docs/character-switching.md](docs/character-switching.md) | Discord branding and Cursor full character switching rules |
| [docs/migration-notes.md](docs/migration-notes.md) | V3 migration notes from single SOUL.md |
| [docs/cursor-quickstart.md](docs/cursor-quickstart.md) | One-page Cursor install / switch / update cheat sheet |
| [scripts/install-cursor-global.sh](scripts/install-cursor-global.sh) | Global Cursor install (macOS / Linux / Git Bash) |
| [scripts/install-cursor-global.ps1](scripts/install-cursor-global.ps1) | Global Cursor install (Windows PowerShell) |
| [scripts/switch-character.sh](scripts/switch-character.sh) | Switch active global character profile |
| [scripts/uninstall-cursor-global.sh](scripts/uninstall-cursor-global.sh) | Uninstall / prune global Cursor artifacts |
| [docs/hermes.md](docs/hermes.md) | Hermes install and upgrade from legacy `SOUL.md` |
| [docs/roadmap.md](docs/roadmap.md) | Roadmap: shipped work, planned initiatives, validation logs |
| [scripts/install-hermes-global.sh](scripts/install-hermes-global.sh) | Install V3.2 on Hermes (`~/.hermes/SOUL.md` + skills) |

---

## Character profiles

| Profile | Best for | Cursor example |
|---|---|---|
| Sky Feather | general engineering, Discord Hermes, homelab, blogging | [examples/cursor-sky-feather.md](examples/cursor-sky-feather.md) |
| Suzushima Arisu | cozy lab, experiments, tinkering | [examples/cursor-suzushima-arisu.md](examples/cursor-suzushima-arisu.md) |
| Sumeragi Setsuna | architecture review, RFC critique, planning | [examples/cursor-sumeragi-setsuna.md](examples/cursor-sumeragi-setsuna.md) |
| Aihara Tsubaki | pair programming, debugging, code review | [examples/cursor-aihara-tsubaki.md](examples/cursor-aihara-tsubaki.md) |
| Ousaka Akane | brainstorming, ideation, ambitious planning | [examples/cursor-ousaka-akane.md](examples/cursor-ousaka-akane.md) |
| Kujo Kaede | ops review, cleanup, postmortems, reliability | [examples/cursor-kaede.md](examples/cursor-kaede.md) |
| Inohara Koboshi | automation, scripting, CI/CD, workflow optimization | [examples/cursor-koboshi.md](examples/cursor-koboshi.md) |

Character profiles may change tone, phrasing, humor, emotional posture, and catchphrases.

They must not change correctness standards, safety behavior, evidence requirements, or `CORE.md` doctrine.

---

## Discord Hermes branding rule

Discord Hermes should remain publicly branded as:

```text
Sky Feather
```

Other character profiles may be used internally as mode inspiration, but Discord should not casually say:

```text
I am now Setsuna.
I am now Arisu.
```

unless explicitly requested.

Better public phrasing:

```text
Sky Feather: Architect Mode
Sky Feather: Pair-Programming Mode
Sky Feather: Cozy Lab Mode
Sky Feather: Brainstorm Mode
Sky Feather: Ops Mode
Sky Feather: Automation Mode
```

See [examples/discord-hermes-sky-feather.md](examples/discord-hermes-sky-feather.md).

---

## Use in Cursor

1. Clone this repo somewhere on your machine.
2. Run the global installer: [docs/cursor-quickstart.md](docs/cursor-quickstart.md).
3. Paste the one-time User Rules stub (see [docs/cursor.md](docs/cursor.md)).
4. Switch characters with `switch-character` — full guide in [docs/cursor.md](docs/cursor.md).
5. Start a new chat and verify evidence-first engineering with character-appropriate delivery.

Other agents: [GitHub Copilot](docs/github-copilot.md) · [Claude Code](docs/claude-code.md) · [Other agents](docs/other-agents.md)

---

## Important: do not commit into team repos

Do **not** add these personal character/agent rules to shared service repositories unless everyone agrees.

| Avoid in team repos | Use instead |
|---------------------|-------------|
| `.cursor/rules/sky-feather-soul.mdc` | Cursor **User Rules** or local personal config |
| `.github/copilot-instructions.md` with personal character rules | Personal dotfiles or VS Code user instructions |
| Root `CLAUDE.md` with full character profile | `~/.claude/CLAUDE.md` or personal rules |

Symlinking this repo into many clones causes accidental PR noise and `git status` clutter.
