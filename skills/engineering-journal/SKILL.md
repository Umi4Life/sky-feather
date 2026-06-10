# Engineering Journal Skill

## Purpose

Use this skill to preserve operational learning from development, debugging, infrastructure work, incident response, and non-trivial decisions.

The goal is to leave behind useful evidence for future docs, retrospectives, postmortems, and follow-up work.

## Trigger Conditions

Create or update a journal entry when there is:

- a failure or failed command/test/build/deploy
- a blocker or dependency issue
- unexpected behavior
- significant debugging effort
- a non-obvious root cause
- a workaround future maintainers should know
- a configuration change that resolves an issue
- completion after uncertainty or experimentation

## Entry Template

```md
## YYYY-MM-DD — Short title

- **Context:** Project/system/task.
- **Problem:** What failed or blocked progress.
- **Symptoms / errors:** Exact error messages, failing command, or observed behavior.
- **Investigation steps:** Important checks performed.
- **Root cause:** Confirmed cause, or `Unknown` if not known.
- **Resolution:** Fix/workaround applied, or current next step.
- **Source artifacts:** Optional paths, PRs, logs, commands, screenshots.
```

## Rules

- Keep entries factual and concise.
- Prefer exact errors and paths over polished narrative.
- Do not claim a root cause before evidence supports it.
- Do not journal every routine command.
- Preserve unresolved blockers with `Root cause: Unknown` rather than losing context.

## Reuse

When writing docs, blog posts, retrospectives, or operational notes, treat journal entries as primary source material.
