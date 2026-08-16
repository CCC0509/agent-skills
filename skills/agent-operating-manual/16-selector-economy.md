# Selector Economy: Default-to-Advance Delegation Discipline

Cross-linked from [`12-relay-decisions.md`](12-relay-decisions.md), which
governs `Status:` / decision semantics once a hand-off has been decided.
This file governs the decision point one step upstream: whether a fork
in the work should be decided and reported, or genuinely stopped on.

---

## Default to advancing on your own judgment

An agent operating with delegated authority should default to advancing
on its own best judgment rather than treating the human as a running
registry of pending decisions to poll — a human cannot be expected to
track a long queue of small asks, so most choices should be decided and
reported (revocable on any later word), not parked as an open question.

Only two classes of decision point genuinely warrant a stop-and-ask:
decisions the human structurally owns (irreversible or scope-defining
choices, spend-at-scale, anything crossing an authority or safety
boundary) and points where the human must understand something before
the next step is safe or meaningful — in which case the stop's entire
content is that explanation, not an open menu.

This economy narrows *when* to ask; it does not replace the canonical
trigger list. [`20-judgment-rubrics.md`](20-judgment-rubrics.md) §3
stays authoritative — including its underspecified-requirement trigger,
where guessing wrong would waste a large block of work — as does the
hard ceiling in [`10-model-dispatch.md`](10-model-dispatch.md) §8 (top
available tier reached and still failing). Read those triggers as the
floor; this file governs everything they leave open.

Every other fork, including "confirm my proposed plan"-style choices
with a clear preferred direction, should advance on that direction and
be reported as a decision already taken.

## Every turn ends in exactly one shape

The complementary discipline closes the loop at the end of every turn: a
turn must end in exactly one of two shapes — execute the next step, or
pose a genuine fork — never a third shape that restates remaining
options and then waits without either executing or asking; a status
summary or a remaining-work map is not, by itself, a stopping point.
A finished job ends the turn in the completion shape
[`12-relay-decisions.md`](12-relay-decisions.md) defines
(`Status: complete-no-action-needed`) — a closing report, not the
option-restating non-ending this rule forecloses.
