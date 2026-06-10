# Install Sky Feather / V3 Character Profiles on Cursor

Use **global** configuration so team repositories stay clean.

## Recommended: User Rules

For the default Sky Feather experience, paste this composition into **Cursor Settings → Rules → User Rules**:

```text
Read and follow the repository-local files in this order:

1. CORE.md
2. characters/sky-feather.md
3. skills/scientific-method/SKILL.md
4. skills/engineering-journal/SKILL.md
5. relevant task-specific skills under skills/
```

Then paste or reference the actual contents from this repo.

If you want a full character switch, use one of the flat composition examples:

- [examples/cursor-sky-feather.md](../examples/cursor-sky-feather.md)
- [examples/cursor-arisu.md](../examples/cursor-arisu.md)
- [examples/cursor-setsuna.md](../examples/cursor-setsuna.md)
- [examples/cursor-tsubaki.md](../examples/cursor-tsubaki.md)
- [examples/cursor-akane.md](../examples/cursor-akane.md)

## Compatibility: old SOUL.md path

`SOUL.md` remains available as the historical single-file Sky Feather reference.

If you want the old behavior, paste [SOUL.md](../SOUL.md) into User Rules or use the existing legacy activation block from [examples/cursor/sky-feather-soul.mdc](../examples/cursor/sky-feather-soul.mdc).

## Optional: local mirror + install script

After cloning this repo:

```bash
./scripts/install-cursor-local.sh
# or with explicit clone path:
./scripts/install-cursor-local.sh /path/to/sky-feather-soul-md
```

This copies V3 materials into:

```text
~/.cursor/sky-feather/CORE.md
~/.cursor/sky-feather/SOUL.md
~/.cursor/sky-feather/characters/
~/.cursor/sky-feather/skills/
~/.cursor/sky-feather/examples/
```

It also keeps the legacy skill mirror:

```text
~/.cursor/skills/sky-feather-soul/
```

## Do not use in team repos

| Avoid | Why |
|-------|-----|
| `<team-repo>/.cursor/rules/sky-feather-soul.mdc` | Shows up in `git status` and PRs |
| Symlinking into many work clones | Accidental commits, reviewer confusion |

If symlinks were added previously, remove them with your personal cleanup script at `~/.cursor/sky-feather/uninstall-repo-rules.sh` if installed, or delete the file under each repo’s `.cursor/rules/`.

## Verify

1. Start a **new** Cursor chat, not an old thread.
2. Ask the same technical question under two profiles, such as Sky Feather and Setsuna.
3. Expect the same engineering conclusion and evidence requirements, but different delivery style.

## Update

```bash
cd /path/to/sky-feather-soul-md
git pull
./scripts/install-cursor-local.sh
# Refresh Cursor User Rules if copied inline
```
