---
name: work-discipline
description: "Use when writing, reviewing, refactoring, or modifying docs, skills, plans, tests, scripts, trigger layers, workflow profiles, or release surfaces to reduce common LLM mistakes: surface assumptions, keep scope simple and surgical, and define verifiable success criteria."
---

# Work Discipline

This is a trigger layer only. It is adapted from
`multica-ai/andrej-karpathy-skills` at commit `2c606141936f` (MIT), via the
Stock Scanner repo-local `karpathy-guidelines` wrapper. Existing agent-skills
manuals remain canonical.

## Must Read

- [`../agent-operating-manual/25-change-discipline.md`](../agent-operating-manual/25-change-discipline.md) -- read for convention migrations, workflow adoption profiles, release PRs, approval-bound identifiers, public evidence hygiene, and verifiable commit structure.
- [`../agent-operating-manual/10-model-dispatch.md`](../agent-operating-manual/10-model-dispatch.md) -- read for delegation, context management, verification, progress tracking, and when to stop.
- [`../handoff-relay/SKILL.md`](../handoff-relay/SKILL.md) -- read before emitting handoff, review, approval, continuation, or no-action closeout signals.
- [`../multi-angle-review/SKILL.md`](../multi-angle-review/SKILL.md) -- read when reviewing a plan, rule, PR, commit range, or fix.

## Apply

1. Think before changing.
   - State assumptions when the task has multiple reasonable interpretations.
   - Present tradeoffs before choosing a risky direction.
   - Ask when confusion would change the implementation.

2. Prefer simplicity.
   - Build the minimum change that satisfies the request and repo rules.
   - Avoid speculative configurability, side features, and single-use abstractions.
   - If the solution is growing faster than the problem, shrink the slice.

3. Make surgical changes.
   - Touch only files needed for this turn.
   - Match local style, helper APIs, and existing release patterns.
   - Clean up unused imports or orphan text created by your own edits, but do not remove unrelated pre-existing work.

4. Finish against verifiable success criteria.
   - Translate the request into success criteria before editing.
   - For multi-step work, keep a short plan with verification for each risky step.
   - Before claiming completion, run the checks that actually prove the changed surface.

5. Route excess scope.
   - Put adjacent concerns in ROADMAP or `Accepted residuals` with an owner.
   - Do not turn one wrapper or cleanup into a full doctrine migration.
   - Before planning or performing approval-bound release, deploy, publish,
     promotion, cleanup, install, plugin refresh, imported-copy update, or
     cross-agent workflow handoff work, check whether workflow adoption in
     `25-change-discipline.md` §3.5 is triggered.
