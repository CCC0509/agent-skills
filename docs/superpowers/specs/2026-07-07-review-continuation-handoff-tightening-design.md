# Review Continuation Handoff Tightening Design

**Status:** Design spec for review.

**Goal:** Tighten pre-spec, review-delivery, and review-passed continuation
handoffs so agents preserve decisions durably and do not confuse review,
revision, approval, continuation, and execution states.

## Problem

The current Agent Operating Manual relay contract already defines legal
`Status:` values, `User action:` routing, `Required user text:` as the exact
approval / disposition field, `Execution route:` display timing, and
`Accepted residuals:` ownership. v0.4.12 also added a pre-handoff self-check.

The remaining gap is a narrower control-contract problem exposed during Phase 0:

- A pre-spec / design-framing conversation can produce real findings and
  dispositions before a formal spec exists, but those conclusions can be left in
  chat instead of the copy block or later spec.
- Review reports that request author changes can be phrased as if the user must
  approve or choose a process, even though the next action is author revision.
- Review-passed reports can say "approved" but still use a status shape that
  implies work is not ready, or can omit the execution / merge approval boundary.
- Follow-ups that should be durable can be left in prose rather than
  `Accepted residuals:`, a roadmap row, or the v0.5 memory-routing surface.

These are not worker lifecycle problems. They do not define how many agents to
spawn, how to close worktrees, whether to push, or how to clean local branches.
They are also not the full Plan / PR lifecycle candidate; branch-first,
PR-stop, squash-merge, and release workflow rules remain separate.

## Design

Implement Phase 1 as a control-contract tightening over the relay fields. Add
exactly one narrow `Status:` value:

```text
ready-for-continuation
```

Use `ready-for-continuation` only when all required review / fix-confirmation
gates for the named work have passed, no exact user approval text is currently
needed, and the next acting agent may execute the named continuation directly.
This value closes the gap where `not-ready` was too pessimistic,
`review-needed` was stale, `ready-for-user-approval` wrongly asked for a reply,
and `complete-no-action-needed` hid an actual next action.

The rest of the design makes the status and copy fields precise for four
handoff shapes.

### 1. Pre-Spec / Design-Framing Handoffs

When the work is still pre-spec, the relay or copy block must say so plainly.
The next agent should be able to tell that it is reviewing or continuing design
framing, not executing an approved spec or implementation plan.

If pre-spec discussion produced findings, requested changes, user dispositions,
scope decisions, or follow-ups that affect the spec, the copy block must carry
them. When the spec is later written, it should include a `Pre-Spec Review
Disposition` or equivalent section that records how those findings were handled.

This does not make pre-spec review mandatory. It only says that when pre-spec
review or design-framing handoff happens, the resulting decisions must be
durable enough for the spec author or reviewer to consume without reconstructing
chat history.

### 2. Review Requested-Changes Handoffs

When a review finds required changes and the next action is author revision, the
handoff should use:

```text
Status: not-ready
User action: self-review -> to-agent
Required user text: n/a
Next agent action: revise the scoped work to address the requested changes, then return for fix-confirmation
```

This shape is valid only when the blocker is another acting agent revising
already scoped work. It must not be used for pending user decisions, missing
external evidence, or final approval gates.

The copy block must preserve the actionable findings, the approved remainder of
the scope if any, and the fix-confirmation focus. A reviewer report that leaves
the requested changes outside the forwarded block is incomplete.

### 3. Review-Passed Continuation Handoffs

When review or fix-confirmation passes and the next agent may execute an already
approved continuation, the handoff should not pretend another review is needed.
It should use the new continuation status:

```text
Status: ready-for-continuation
User action: self-review -> to-agent
Required user text: n/a
Next agent action: execute the named continuation directly
```

If the same chat both receives the review-passed continuation signal and is the
acting agent, it may execute `Next agent action` directly under the effective
contract. It should not bounce the same `review-needed` or approval relay back to
another reviewer. If the user must still reply with exact approval text, the
handoff is not ready for continuation; use `ready-for-user-approval` instead.

`Execution route:` may appear only on this executable approval / continuation
handoff after all required review or fix-confirmation gates are complete. It
must remain absent from findings-delivery, plan-review, pre-spec-review,
review-only, and fix-confirmation-delivery handoffs.

### 4. Final Merge / Closeout Handoffs

Final merge, tag, deploy, release, or other irreversible approval gates keep
using `Status: ready-for-user-approval` with exact text in `Required user text:`.
Routine post-review execution that needs no exact user reply uses
`Status: ready-for-continuation`. Fully closed work with no remaining user or
agent action uses `Status: complete-no-action-needed`.

The tightening is that "review passed" alone is not enough to choose either
shape. The handoff must name what remains:

- another acting agent revision,
- user approval for an execution / merge / release gate,
- direct continuation after already supplied approval, or
- no action.

## Durable Conclusion Capture

Any conclusion that changes what the next agent should believe or do must live
inside the forwarded context, the formal spec / plan, `Accepted residuals:`, or
repo memory chosen by the v0.5 closeout memory-routing rule.

Use these homes:

| Conclusion type | Durable home |
|---|---|
| Pre-spec finding or user disposition that affects the spec | Forwarded copy block, then the spec's `Pre-Spec Review Disposition` or equivalent section |
| Review finding that must be fixed | Forwarded copy block and `Next agent action` / fix-confirmation focus |
| Non-blocking finding, FYI, out-of-repo follow-up, or accepted residual | `Accepted residuals:` with a durable tracker / owner |
| Reusable lesson, active next-session state, audit proof, or index change | Existing v0.5 memory routing in `15-repo-memory.md` |
| Pure human explanation that does not affect future action | Prose outside the copy block |

If a report has a non-blocking follow-up but no durable tracker or owner, it
must not present the work as ready or fully closed. The author should either add
the tracker / owner, move the issue into scoped work, or mark the handoff
`not-ready`.

## Review Deliverable Copy-Field Tightening

Update `skills/multi-angle-review/SKILL.md` so review reports that include relay
signals distinguish three surfaces:

1. Findings report: `Verdict`, `Findings`, and `Next actions` for the human and
   author to read.
2. Paste-ready relay block: included only when the user should forward content
   or reply with exact text.
3. Durable residual list: any accepted residuals or out-of-repo follow-ups that
   survive the review.

The reviewer should not invent a relay block for a pure FYI review with no next
action. But when the report asks the user to forward to an author, reviewer, or
acting agent, the copy block must contain all findings and dispositions needed
by that next agent.

## Scope

In scope:

- Tighten `skills/agent-operating-manual/10-model-dispatch.md` around pre-spec
  handoff labeling, requested-changes handoffs, review-passed continuation, and
  durable conclusion capture.
- Tighten `skills/multi-angle-review/SKILL.md` around review deliverables that
  include relay signals or paste-ready copy blocks.
- Update `tests/install-smoke.sh` with stable imported-manual and review-skill
  tokens for the new doctrine.
- Extend the relay status token list and consistency rules for
  `ready-for-continuation`.
- Add a v0.5.1 landed entry to `ROADMAP.md`.
- Retire the `Review deliverable handoff copy-field tightening` Extraction
  Candidate row after the landed entry exists.
- Preserve or clarify the deferred rows for `Plan / PR lifecycle discipline` and
  `Branch / worker lifecycle hygiene`.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to
  `0.5.1` during implementation.
- Close implementation with `Status: review-needed`,
  `User action: self-review -> to-reviewer`, and `Review: full`.

Out of scope:

- Adding more than the single `ready-for-continuation` status value.
- Changing the `Review:` enum.
- Making pre-spec review mandatory.
- Defining branch-first, PR-stop, squash-merge, release-tag, or push policy.
- Defining worker spawn, wait, consume, close, worktree cleanup, branch cleanup,
  concurrency caps, or post-merge push state.
- Changing Agent Trigger Kit validators, session-check behavior, hooks, or
  outcome taxonomy.
- Editing adopting repos or generated imported copies directly.
- Release tagging or publishing `v0.5.1`.

## Verification

Implementation should verify:

- `agent-trigger-kit session-check`
- `tests/install-smoke.sh`
- `git diff --check`
- A token scan such as:

```bash
rg -n 'ready-for-continuation|pre-spec|design-framing|review-passed continuation|Durable conclusion capture|Review deliverable copy-field tightening|Plan / PR lifecycle discipline|Branch / worker lifecycle hygiene|v0\.5\.1|0\.5\.1' skills/agent-operating-manual skills/multi-angle-review ROADMAP.md tests .claude-plugin
```

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Review Notes

- The value of this increment is continuity: a future agent should know whether
  it is reading pre-spec framing, requested changes, executable continuation,
  final approval, or closeout.
- `ready-for-continuation` is intentionally narrow. It is not a generic "looks
  good" status and it must not bypass review, fix-confirmation, or exact user
  approval gates.
- Durable conclusion capture uses existing homes. It should not create a new
  memory type or a new relay field.
- Keeping worker lifecycle and Plan / PR lifecycle out of this release is part of
  the design. Those rows should remain available for later focused specs.
