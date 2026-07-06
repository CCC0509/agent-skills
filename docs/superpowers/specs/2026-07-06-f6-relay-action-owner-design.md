# F6 Relay Action Owner Design

**Status:** Design spec for review.

**Goal:** Make relay handoffs tell the user whether to read, reply, forward to a reviewer, forward to the next acting agent, or stop, while keeping the fenced relay block as the controlling signal.

## Problem

The v0.4.8 relay block now separates `Review:` context from `Status:` control,
but the user still has to infer their own immediate action. In practice the user
usually reads spec / plan / rule-review output, may add personal notes, and then
pastes the material to a reviewer agent. The current block says what the next
agent should do, but not whether the user should answer here, forward to a
reviewer, forward to an acting agent, or do nothing.

F6 should remove that guesswork without turning every handoff into a new
decision tree. The field must also avoid the mistake in the first draft: "read
yourself" and "send to reviewer" are not mutually exclusive.

## Design

Add a `User action:` line to the relay block after `Required user text:`:

```text
User action: <self-review | to-reviewer | to-agent | reply-required-text | none>[ -> ...]
```

The value is an ordered sequence of short tokens separated by ` -> `. `self-review`
means the user should read or decide first; it can be followed by another token.
The receiving agent should treat the sequence as the user's routing instruction,
while `Next agent action` remains the instruction for the agent who receives the
handoff.

Token meanings:

| Token | Meaning |
|---|---|
| `self-review` | The user should read / judge the material before any forwarding or approval. |
| `to-reviewer` | Paste the complete copy block to a reviewer agent. |
| `to-agent` | Paste the complete copy block to the next acting agent; `Next agent action` says what that agent does. |
| `reply-required-text` | Reply in the current chat with the exact text or disposition named in `Required user text`. |
| `none` | The user does not need to reply or forward the block. |

Common mappings:

| Condition | Default `User action` |
|---|---|
| `Status: review-needed` with `Review: plan/rule-review`, `full`, `fix-confirmation ...`, or `closeout-sanity` | `self-review -> to-reviewer` |
| `Status: ready-for-user-approval` | `self-review -> reply-required-text` |
| `Status: not-ready` because user disposition is pending | `self-review -> reply-required-text` |
| `Status: not-ready` because another acting agent must revise work already scoped by the relay | `self-review -> to-agent` |
| `Status: not-ready` because external evidence, CI, policy escalation, or remote metadata is pending and no user input or next-agent revision is available yet | `none` |
| `Status: complete-no-action-needed` | `none` |
| Pure FYI with no review, approval, blocker, or next action | `none` |

## Full-Context Copy Rule

For spec, plan, rule-review, full review, and fix-confirmation handoffs, the
default copy area should contain all context the next agent needs to judge or
act: the user's relevant notes if the author is including them, reviewer
findings, author dispositions, target repo / target, verification state, and the
final relay block with the three-line `Review:` contract. The user should not
need to choose which findings to preserve for a reviewer.

For purely mechanical continuation, the copy area may be shorter if the relay
block plus the named target is enough. When uncertain, prefer the full-context
copy block.

## User Notes Rule

Do not add a `User notes handling:` relay field. User notes are always allowed
outside the fenced block, but they do not override the contract fields. If the
author wants the next agent to treat user notes as part of the review or action
contract, the author should include those notes in the copy block's context
section or name the required disposition in `Required user text`.

This keeps `Required user text` as the only home for exact approval / disposition
text, and keeps the relay block from gaining a boilerplate line that is true in
almost every handoff.

## Consistency Rules

- `Status: complete-no-action-needed` must use `User action: none`.
- `User action: none` only says the user does not need to reply or forward the
  block; it does not override `Next agent action`.
- `Review: none-FYI` must not pair with a `User action` sequence containing
  `to-reviewer`.
- `Status: not-ready` must not pair with a `User action` sequence containing
  `to-agent` unless the blocker is explicitly "another acting agent must revise
  scoped work" and `Next agent action` names that revision. This requires the
  existing Relay readiness rule to carry the same carve-out.
- `Status: not-ready` with pending user disposition must use
  `reply-required-text`, must name the needed input in `Required user text`, and
  must keep `Next agent action` non-executable until that input exists.
- `Status: ready-for-user-approval` must use `reply-required-text`, and
  `Required user text` must name the exact approval text.
- When `User action` contains `to-reviewer` or `to-agent`, the copy block must
  include the complete fenced relay block, including `Status:`, `Target repo:`,
  `Target:`, `Required user text:`, `Next agent action:`, `Blockers:`,
  `Accepted residuals:`, and the three-line `Review:` contract.

## Sequencing

F6 depends on v0.4.8. It must be based on `origin/main` after PR #13 merged, where the
relay block already includes `Target repo:`, the `Review:` / `Status:`
co-occurrence tie-breaker, relay readiness rule, and the in-flight staging
boundary. F6 must not be implemented against the stale v0.4.7 relay block.

## Scope

In scope:

- Add `User action:` to `skills/agent-operating-manual/10-model-dispatch.md`.
- Add the token meanings, common mapping table, full-context copy rule, user
  notes rule, and consistency rules to §3.1.
- Update `tests/install-smoke.sh` with stable tokens for the imported manual.
- Add a v0.4.9 `ROADMAP.md` landed entry for F6.
- Add a durable F5 cross-repo reference map Extraction Candidate row.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to
  `0.4.9`.
- Close implementation with `Status: review-needed` and
  `User action: self-review -> to-reviewer`.

Out of scope:

- F4 source-repo entrypoint / staging-boundary mechanics.
- F5 cross-repo reference map content beyond a ROADMAP tracker row.
- operator-bootstrap template / enum changes.
- Agent Trigger Kit validator or trigger-layer mechanism changes.
- Tagging or releasing `v0.4.9`.

## Verification

- `./tests/install-smoke.sh`
- `git diff --check`
- `rg -n "User action|self-review|to-reviewer|to-agent|reply-required-text|Full-context copy rule|User notes rule|User action consistency rule|0\\.4\\.9|F5 cross-repo" skills/agent-operating-manual ROADMAP.md tests .claude-plugin`

## Review Notes

This design adopts the reviewer feedback as follows:

- Finding 1: `User action` is an ordered short-token sequence, not a single
  mutually exclusive long sentence.
- Finding 2: cross-field consistency rules are explicit.
- Finding 3: `User notes handling` is not a field; notes handling becomes
  normative prose.
- Finding 4: v0.4.8 merge sequencing is a precondition.
- Finding 5: F5 receives a ROADMAP Extraction Candidate row; F6 is tracked by
  the v0.4.9 landed entry because it is the current release scope.
- Finding 6: enum values use short tokens and get smoke coverage.
- Finding 7: `to-reviewer` / `to-agent` copy blocks must include the complete
  relay block and three-line `Review:` contract.
