# Install Sky Feather on GitHub Copilot

Copilot reads project instructions from `.github/copilot-instructions.md` when present. For Sky Feather, prefer **personal** configuration — not team service repos.

## Option A: Personal dotfiles repo

1. Maintain a private **dotfiles** or `github-settings` repo you own.
2. Add `.github/copilot-instructions.md` using [examples/github/copilot-instructions.md](../examples/github/copilot-instructions.md) as a starting point.
3. Either paste the full [SOUL.md](../SOUL.md) below the activation block, or keep SOUL in one file and reference it in your workflow (“read SOUL from …”).

Use that repo only for repos **you** control, not shared team backends unless the team agrees.

## Option B: VS Code user-level instructions

Where your Copilot / VS Code build supports **user-level** custom instructions:

1. Open VS Code settings for Copilot Chat / code generation instructions.
2. Paste the activation block from `examples/github/copilot-instructions.md`.
3. Paste or attach full `SOUL.md` (or store SOUL in a fixed path and tell Copilot to read it).

Exact setting names vary by Copilot version; check current Microsoft docs for “custom instructions” or “instruction files.”

## Option C: Single-repo experiment (not team default)

For a **personal sandbox** repo only:

```bash
mkdir -p .github
cp /path/to/sky-feather/examples/github/copilot-instructions.md .github/copilot-instructions.md
# Optionally append SOUL.md content or link in README for humans
```

**Do not** add this to shared team codebases by default.

## Verify

Open Copilot Chat in a project that uses your personal instructions. Ask a technical question; confirm voice matches SOUL (reaction beat, operator flavor, no flat neutral-only prose).

## Update

`git pull` in your sky-feather clone and refresh whichever global copy you use.
