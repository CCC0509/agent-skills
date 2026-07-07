# Relay Copy-Block Self-Check Design

**Status:** Design spec for review.

**Goal:** Add a compact pre-handoff self-check to the relay contract so agents
catch incomplete copy blocks before handing work to a reviewer, acting agent, or
user approval gate.

## Problem

The current relay contract in `skills/agent-operating-manual/10-model-dispatch.md`
already defines the needed rules: legal `Status:` values, `Review:` / `Status:`
precedence, `User action:` consistency, single fenced copy blocks for forwarded
handoffs, full-context copy defaults, `Accepted residuals:` ownership, and
`Required user text:` as the exact approval / disposition field.

The remaining failure mode is not missing doctrine. It is missed execution at
handoff time. Authors can know the rules and still emit a relay block that drops
review findings outside the copy block, forgets the three-line `Review:`
contract, pairs `Review: none-FYI` with `to-reviewer`, or leaves the canonical
ATK source-repo residual only in prose.

v0.4.12 should add the checklist moment without creating a second normative
home for the same requirements.

## Design

Add a short subsection near the end of `10-model-dispatch.md` section 3.1 with
the stable English heading:

```text
Pre-handoff self-check
```

The subsection should come after the relay, copy, residual, status, readiness,
user-action, blocker, approval-text, route, and normative control-contract rules
it references. It should be a pointer checklist, not a restatement of the rules.

The self-check is performed silently before emitting a handoff. It must not add
an attestation line, checklist dump, new relay field, or new `Status:` value. If
the check fails, the author fixes the handoff before emitting it; the final
handoff artifact is the evidence.

The checklist should stay capped at roughly eight one-line questions:

- Is `Status:` one of the legal relay statuses?
- Does `Review:` cohere with `Status:` and `User action:`?
- When exact approval or disposition text is required, is
  `Required user text:` non-`n/a` and exact?
- When a repo-specific next action exists, is `Target repo:` non-`n/a`?
- When `User action:` includes `to-reviewer` or `to-agent`, is there exactly
  one `text` fenced copy block for the user to forward?
- Does that copy block include the complete relay block and the three-line
  `Review:` contract?
- Are review findings, author dispositions, verification state, and user notes
  that matter to the next agent inside the copy block, with the existing bias
  toward full-context copy when uncertain?
- If the report carries non-blocking findings, FYI, accepted residuals, or
  out-of-repo follow-ups, is `Accepted residuals:` not `none`, with each item
  tied to a durable tracker or owner?

These questions intentionally point at existing section 3.1 rule names and
fields:
Co-occurrence tie-breaker, Full-context copy rule, User notes rule,
`Accepted residuals`, Status criteria, Relay readiness rule, User action
consistency rule, `Required user text`, `Target repo`, and Normative
control-contract changes.

## Pre-Spec Review Disposition

This spec incorporates the pre-spec framing review delivered against effective
contract `main` at `b74f29a`.

- R1, structural constraint: accepted. The implementation must add a compact
  pointer checklist and must not duplicate section 3.1 requirements as a second
  normative home.
- R2, silent execution: accepted. No emitted attestation, checklist dump, relay
  field, or status value should be added.
- R3a, `Review:` / `Status:` coherence: accepted as a checklist question.
- R3b, exact `Required user text:` when status demands it: accepted as a
  checklist question.
- R3c, `Target repo:` when a repo-specific next action exists: accepted as a
  checklist question.
- R3d, `Accepted residuals:` not `none` when findings / FYI / residuals exist:
  accepted as a checklist question, including the recurring ATK root-source
  residual case.
- R4, over-prescription guard: accepted. The checklist must preserve the
  existing judgment clause for what matters to the next agent and the existing
  bias toward full-context copy when uncertain. It must not require every
  possible note in every forwarded block.
- R5, placement and testability: accepted. The stable smoke anchor is
  `Pre-handoff self-check`; token coverage should probe the installed manual
  for the heading and key checklist tokens.
- R6, pre-spec review doctrine: accepted as an exclusion. This session used a
  pre-spec framing review as process hygiene, but v0.4.12 must not make
  pre-spec review a new mandatory doctrine gate. If the pattern proves useful
  across multiple increments, track it separately as an optional author tool.

## Scope

In scope:

- Add the `Pre-handoff self-check` subsection to
  `skills/agent-operating-manual/10-model-dispatch.md`.
- Keep the subsection inline in section 3.1 for now. The deferred F2
  handoff-contract file split still waits until relay control semantics
  stabilize.
- Update `tests/install-smoke.sh` with stable imported-manual tokens for the new
  heading and representative checklist items.
- Add a v0.4.12 landed entry to `ROADMAP.md`.
- Retire the `Relay copy-block completeness self-check` Extraction Candidate
  row after the landed entry exists.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to
  `0.4.12`.

Out of scope:

- Agent Trigger Kit validator behavior, session-check behavior, hook templates,
  or outcome taxonomy.
- `operator-bootstrap` template or user-level instruction changes.
- Adopting-repo updates or generated imported-copy edits.
- The F2 section 3.1 file split.
- Mandatory pre-spec review doctrine.
- Release tagging or publishing `v0.4.12`.

## Verification

Implementation should verify:

- `agent-trigger-kit session-check` at session start and closeout. The expected
  current source-repo boundary remains exit 1 with
  `agent-skills: plugin directory missing`; when a relay signal is present,
  carry the accepted residual:
  `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.
- `./tests/install-smoke.sh`
- `git diff --check`
- A token scan such as:

```bash
rg -n "Pre-handoff self-check|single `text` fenced copy block|three-line `Review:` contract|Target repo|Required user text|Accepted residuals|v0\\.4\\.12|0\\.4\\.12" skills/agent-operating-manual ROADMAP.md tests .claude-plugin
```

The implementation closeout should use `Status: review-needed`,
`User action: self-review -> to-reviewer`, and `Review: full`.

## Review Notes

- The value of this increment is timing: making authors pause before emitting a
  handoff. It is not a new relay-rule source.
- Inline placement is a sequencing choice. It keeps the change near the rules it
  references while F2 remains deferred, and it can give F2 an anchor inventory
  during the future split.
- The checklist should be terse enough to run mentally. If it grows into a
  second copy of section 3.1, the implementation has missed the design.
