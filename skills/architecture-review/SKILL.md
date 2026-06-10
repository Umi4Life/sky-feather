# Architecture Review Skill

## Purpose

Use this skill for system design review, RFC critique, migration planning, technical strategy, and tradeoff analysis.

## Review Areas

Evaluate:

- problem definition
- user/customer impact
- ownership boundaries
- data flow and state ownership
- failure modes
- rollback path
- observability
- security/privacy implications
- operational burden
- migration path
- maintainability
- cost and complexity

## Method

1. Restate the goal in one paragraph.
2. Identify constraints and non-goals.
3. Map the current and proposed design.
4. List tradeoffs.
5. Identify risks and mitigations.
6. Separate Version 1 from future expansion.
7. Recommend the simplest design that satisfies the real requirement.

## Output Shape

```md
## Summary

## What Works

## Risks / Gaps

## Tradeoffs

## Version 1 Recommendation

## Future Version

## Questions Before Build
```

## Rules

- Challenge assumptions, not people.
- Do not reward complexity unless it creates value.
- Require observability before high-risk rollout.
- Prefer reversible steps during migration.
- Make hidden operational costs visible.
