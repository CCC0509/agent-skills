# Phase 0 Release Stabilization Design

**Status:** Design spec for review.

**Goal:** Restore the current v0.5.0 local `main` branch to review-ready by
repairing stale smoke-test expectations without changing doctrine, roadmap
truth, release metadata, or the next doctrine candidate.

## Problem

The local `main` branch is ahead of `origin/main` and already contains the
landed v0.4.10, v0.4.11, v0.4.12, and v0.5.0 release-train commits. The branch
state is intentionally newer than the F5 cross-repo reference-map increment:

- `ROADMAP.md` keeps the append-only landed entry for
  `v0.4.11: F5 cross-repo reference map`.
- `ROADMAP.md` intentionally graduated the relay copy-block self-check from an
  F5 follow-up candidate into the shipped v0.4.12 landed entry.
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
  intentionally carry version `0.5.0`.

The current failing gate is `tests/cross-repo-reference-map-smoke.sh`. It still
contains F5-era assertions that were valid only while later follow-up
candidates were deferred and plugin metadata was still `0.4.11`. Because the
script fails fast, the first visible error is the missing relay copy-block
self-check candidate row, but the stale inventory contains eight assertions:

| Line | Stale assertion | Current truth |
|---|---|---|
| 80 | `| agent-skills doctrine | Branch / worker lifecycle hygiene |` must remain in Extraction Candidates. | This is a future doctrine candidate and should not be pinned by an F5 smoke test. |
| 81 | `simultaneous editing in shared checkouts` must appear as candidate rationale text. | This rationale belongs to a moving candidate-table row, not to the stable F5 invariant set. |
| 82 | `| agent-skills doctrine | Relay copy-block completeness self-check |` must remain in Extraction Candidates. | The candidate intentionally landed as v0.4.12. |
| 83 | `pre-handoff checklist` must appear as candidate rationale text. | The shipped v0.4.12 landed entry contains the concept across wrapped lines; it is no longer deferred rationale. |
| 84 | `` `Review:` contract for the immediate next agent `` must appear as candidate rationale text. | That F5 candidate rationale was intentionally removed when v0.4.12 landed. |
| 85 | `preserves review findings inside the fenced copy block` must appear as candidate rationale text. | That F5 candidate rationale was intentionally removed when v0.4.12 landed. |
| 87 | `.claude-plugin/plugin.json` must contain exact version `0.4.11`. | Metadata intentionally advanced to `0.5.0`. |
| 88 | `.claude-plugin/marketplace.json` must contain exact version `0.4.11`. | Metadata intentionally advanced to `0.5.0`. |

Touching `ROADMAP.md`, `.claude-plugin/*`, or `skills/**` to satisfy these old
assertions would revert landed work or create a new doctrine / release-metadata
change. Phase 0 should instead repair the test so it checks stable F5
invariants.

## Design

Modify only `tests/cross-repo-reference-map-smoke.sh`.

Keep assertions that are stable properties of the F5 cross-repo reference-map
increment:

- The source map file exists.
- The source map contains the cross-repo ownership tokens for
  `operator-bootstrap`, Agent Trigger Kit, adopting repos, MCP /
  codebase-index tooling, `15-repo-memory.md`, non-canonical memory, generated
  imported copies, fake plugin directories, machine-local MCP, and
  branch-local proposal text.
- `skills/agent-operating-manual/README.md` and
  `skills/agent-operating-manual/SKILL.md` mention
  `cross-repo-reference-map.md`.
- The `SKILL.md` Must Read section does not force the conditional appendix into
  daily startup load.
- `ROADMAP.md` preserves the append-only landed line for
  `v0.4.11: F5 cross-repo reference map`.
- `ROADMAP.md` no longer lists the F5 candidate in Extraction Candidates.
- The installed copy includes the map and the README / SKILL pointers.

Drop the F5-era assertions on Branch / worker lifecycle hygiene candidate
state, relay copy-block self-check candidate rationale, and exact `0.4.11`
metadata. Do not replace them with assertions for current candidate-table
contents or current exact version numbers. Re-pinning to today's release state
would reproduce the same staleness class at the next release.

No new helper, parser, or test fixture is needed. The existing shell helpers
are sufficient because this is a test-scope correction, not a new feature.

## Pre-Spec Review Disposition

This spec incorporates the Phase 0 pre-spec framing review against local
`main` at `a455187`.

- Scope classification: accepted. Phase 0 is stale-smoke stabilization, not a
  doctrine, roadmap, release-metadata, or new release-candidate change.
- Single-file scope: accepted. The only implementation file is
  `tests/cross-repo-reference-map-smoke.sh`.
- Eight-assertion inventory: accepted after review. The spec enumerates all
  stale assertions at lines 80-85 and 87-88 so fixing the first visible failure
  does not merely reveal the next stale pin.
- Time-bound guard caution: accepted. Lines 80-85 were guards that later
  follow-up candidates remained deferred. Those guards should be removed
  because candidate-table rows and rationale text are intentionally moving
  state.
- Version pin caution: accepted. Lines 87-88 should not be updated to `0.5.0`
  because this F5 smoke should not pin moving release metadata.
- Route-display feedback: accepted. The pre-spec handoff was review-only /
  plan-review, so it correctly omitted `Execution route:` under the route
  display rule.
- Review-format note: a later requested-change handoff used
  `Status: review-needed` and a non-token `User action` even though review had
  completed with author revisions required. Treat that as a relay-format miss;
  the corrected shape is `Status: not-ready` with
  `User action: self-review -> to-agent`. This note does not add implementation
  scope.

## Scope

In scope:

- Remove the Branch / worker lifecycle hygiene candidate-row and
  candidate-rationale checks from `tests/cross-repo-reference-map-smoke.sh`.
- Remove the relay copy-block self-check candidate-row and candidate-rationale
  checks from `tests/cross-repo-reference-map-smoke.sh`.
- Remove the exact `0.4.11` metadata checks from
  `tests/cross-repo-reference-map-smoke.sh`.
- Preserve the stable F5 structural, ROADMAP landed-entry, retired-F5-candidate,
  Must Read exclusion, and install-propagation checks.
- Run the existing smoke and whitespace gates.
- Close the implementation with a review-needed handoff that names this as a
  stale-smoke stabilization patch.

Out of scope:

- Editing `ROADMAP.md`.
- Editing `.claude-plugin/plugin.json` or `.claude-plugin/marketplace.json`.
- Editing `skills/**` doctrine files.
- Adding new release metadata, release tags, publishing steps, or adopting-repo
  updates.
- Starting Phase 1 doctrine work such as Plan / PR lifecycle discipline,
  Branch / worker lifecycle hygiene, preflight self-reporting, or review
  deliverable copy-field tightening.
- Making pre-spec review mandatory doctrine. The pre-spec review was used here
  as process hygiene under the existing handoff contract.

## Verification

Implementation should verify:

- `agent-trigger-kit session-check`
- `tests/install-smoke.sh`
- `tests/source-entrypoint-smoke.sh`
- `tests/cross-repo-reference-map-smoke.sh`
- `git diff --check origin/main..HEAD`
- `git status -sb`

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

The implementation closeout should use `Status: review-needed`,
`User action: self-review -> to-reviewer`, and `Review: full`.

## Review Notes

- The purpose of Phase 0 is to make the existing v0.5.0 stack reviewable. A
  one-file test correction is the intended endpoint.
- The safe test boundary is "F5 invariants", not "current release state".
  Append-only shipped-log entries are stable; candidate tables and exact plugin
  metadata versions are intentionally moving state.
- The next doctrine candidate remains separate. Phase 1 should start only after
  this stabilization patch is written, verified, and reviewed.
