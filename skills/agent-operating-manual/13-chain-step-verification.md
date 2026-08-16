# Chain-Step Verification and Claim Verification

Extends [`10-model-dispatch.md`](10-model-dispatch.md) §4 (Verify, not
self-verify) with rules new in this file, not resliced from it; kept
separate for the ~250-line cap in `40-maintenance.md` §4. The write-time chain law and the audit-time
claim/record-verification doctrine sit together in one file because the
second is the audit-time cousin of the first.

---

## Chain-Step Verification

A multi-step edit or emission chain must verify each step's own exit
condition before any later step runs or claims it: a failed step aborts
the chain's downstream claims, not merely its own line, and a record
describing the chain's effect must be derived from the artifact's landed
bytes, never from the chain's stated intent or a template's header
comment.

This binds with particular force on regenerated artifacts: whenever a
generator or template produces a file carrying a declared list of
required items — a checklist, a required-flags set, a manifest — that
declared list must be byte-verified against the artifact's live emitted
content at write time, on every regeneration, never narrated from the
template or trusted from a prior pass. Regeneration is not a
one-time-verified pattern that inherits trust; each fresh emission earns
its own compliance check.

A small companion checker that diffs the declared item list against
emitted bytes, and separately forbids any known-retired token outright,
is the natural mechanization of this rule; the checker's own
repo-specific item list, paths, and retired-token names stay private —
only the general check shape travels.

---

## Claim Verification: The Record Is Also A Claim

A record that claims a change was made to a named artifact — a work-log
entry, a completion report, a changelog line — is only as trustworthy as
the bytes it can be checked against: the record's claimed scope must
actually touch the path it claims to touch, when that can be
mechanically checked.

Claim classes that cannot be re-derived from available evidence — a bare
count with no enumerated content, an existence claim with no content
check, a freshness claim with no fetch behind it — must be labeled
UNCHECKED-WITH-REASON rather than silently treated as verified; a claim
that cannot be checked is not the same as a claim that passed.
Verification runs on a standing cadence (at minimum: session start and
session close, over the newest unverified records) rather than only on
suspicion, because the failure mode this catches is an honest
over-claim, not fraud.

This doctrine generalizes "verify, not self-verify" to the record layer
itself: a record describing work is itself a claim, and needs the same
evidentiary discipline as the work it describes.
