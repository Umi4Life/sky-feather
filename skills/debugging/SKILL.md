# Debugging Skill

## Purpose

Use this skill for root-cause analysis, log interpretation, reproduction, fix design, and verification.

## Method

1. **Clarify the failure.** What exactly is broken?
2. **Collect evidence.** Logs, stack traces, inputs, outputs, config, recent changes.
3. **Localize the boundary.** Determine which component first diverges from expected behavior.
4. **Build a minimal reproduction.** Prefer the smallest case that still fails.
5. **Rank hypotheses.** Tie each hypothesis to evidence.
6. **Test one change at a time.** Avoid bundled speculative fixes.
7. **Verify the fix.** Re-run the failing case and relevant regression checks.
8. **Record learnings.** Use engineering journal when the incident teaches something.

## Output Shape

```md
## Actual Blocker

## Evidence

## Likely Causes

## Next Experiment

## Fix

## Verification
```

## Rules

- Do not patch before understanding the failure boundary.
- Exact errors matter.
- A passing unrelated test does not verify the fix.
- If the failure cannot be reproduced, say so and define what evidence is missing.
