---
name: handoff-relay
description: "Use when preparing, reviewing, consuming, or forwarding agent handoffs, relay blocks, completion-report closeouts, exact approval text, Status/User action decisions, Execution surface constraints, Review contracts, or paste-ready copy blocks."
---

# Handoff Relay

This is a trigger layer only. Canonical relay semantics live in the Agent
Operating Manual and Multi-Angle Review. If this wrapper appears to conflict
with a canonical file, follow the canonical file and fix this wrapper.

## Must Read

- [`../agent-operating-manual/10-model-dispatch.md`](../agent-operating-manual/10-model-dispatch.md) §3.1 — relay fields, copy-block formatting, `Status:` semantics, exact approval text, `User action`, `Accepted residuals`, and execution-route display rules.
- [`../multi-angle-review/SKILL.md`](../multi-angle-review/SKILL.md) — read when a review, plan/rule-review, fix-confirmation, requested-changes revision, or review-passed continuation is involved.
- [`../agent-operating-manual/25-change-discipline.md`](../agent-operating-manual/25-change-discipline.md) — read when the handoff touches PR, merge, tag, publish, deploy, release, or another approval-bound object.

## Apply

1. Classify the immediate next action before writing or consuming a handoff.
2. If review is pending, stop at a review-needed handoff and include the copy
   block the user should forward to a reviewer.
3. If exact user approval is pending, put the exact text only in
   `Required user text`; surrounding prose can say the chat is waiting.
4. For completion-report closeouts, read `../agent-operating-manual/10-model-dispatch.md`
   §3.1. Keep the completion-report lines as stage lines before the relay
   block, not relay fields.
5. For surface-sensitive handoffs, ensure the relay block carries
   `Execution surface:` and read `10-model-dispatch.md` §3.1 for canonical
   values, missing-field blockers, and conflict handling. Keep this wrapper as
   a pointer; do not restate the field's full state machine here.
6. If the user must forward context to a reviewer or acting agent, emit exactly
   one `text` fenced copy block containing the complete relay block and
   `Review:` contract.
7. Put every non-blocking finding, FYI, external follow-up, or accepted gap in
   `Accepted residuals:` with a durable owner.
8. Do not add relay fields, rename `Status:` values, change the `Review:` enum,
   or copy the full relay state machine into this wrapper.
9. For context-health, fresh-session, or skill-source provenance questions,
   read `../agent-operating-manual/10-model-dispatch.md` before deciding
   whether to continue in the current session, emit a continuity packet, or
   explain source / imported-copy / plugin-cache freshness.
