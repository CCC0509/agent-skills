# Fresh Session Continuity Design

**Goal:** Add a portable doctrine slice for context-health and fresh-session
continuity so agents can recognize when context compaction, stale skill
surfaces, or incomplete rule loading makes a handoff safer than continuing in
place.

## Background

Recent handoff and release trains improved relay fields, exact approval gates,
copy-block self-checks, source-repo entrypoints, and cross-repo intake. The
remaining failure mode is not that the rule text is absent. The repeated miss
is that a fresh or compacted agent can fail to load the right small rule set,
misidentify whether it is reading source doctrine, imported skill copies, or a
plugin cache, and then emit a non-compliant handoff.

This is adjacent to the existing `Skill context loading / retrieval strategy`
candidate, but narrower: define what an agent should do when the current
session itself is becoming an unreliable carrier of context, and define the
small provenance report a new session needs before trusting skill freshness.

This train should capture the discussion in public-safe form. Private local
paths, raw cache listings, and adopting-repo evidence stay out of public
artifacts. Portable conclusions can name the surface classes and update rules.

## Problem Statement

Agents need a decision procedure for four related situations:

1. A long-running session has gone through enough compaction or slowdown that
   rule loading and handoff accuracy are at risk.
2. A new session starts from a forwarded handoff and must know which doctrine
   surface it is consuming.
3. The user asks whether a missed rule happened because plugin metadata was not
   bumped or because the agent never read the source file.
4. Older repo-local memory mentions skill cleanup or optimization ideas that
   may belong in `agent-skills`, Agent Trigger Kit, operator-bootstrap, or the
   adopting repo.

Without an explicit provenance preflight, an agent can incorrectly assume:

- source-repo doctrine requires a plugin bump before it can be read;
- an adopting repo has the latest skill text just because `agent-skills` source
  has changed;
- a plugin cache exposes new skills before it has been updated and the runtime
  restarted or refreshed;
- a handoff can be shortened after compaction even when the next agent needs
  full context to apply the relay contract.

## Design

### 1. Context-Health Decision Procedure

Add a compact context-health rule to the Agent Operating Manual rather than a
new standalone skill. The rule should say that the agent may continue in the
current session when it can still verify the relevant doctrine files, target
head, pending gates, and handoff fields directly. It should prefer a fresh
session handoff when any of these signals appear:

- multiple compactions or visible context loss make prior conclusions hard to
  audit;
- the session is slow, hanging, or repeatedly losing the task thread;
- the agent cannot confirm which skill surface is current;
- the next action is approval-bound, review-bound, release-bound, or changes
  relay / approval / review semantics;
- the current session has already produced or consumed a flawed handoff and the
  correction depends on rule precision.

If the harness provides a sanctioned fresh-context worker or continuation
mechanism, the agent may use it only within existing approval and review
boundaries. If no such mechanism exists, it should ask the user to open a new
session and provide a paste-ready continuity packet. The doctrine should not
claim that an agent can silently transfer authority to a new session.

### 2. Continuity Packet

When a fresh session is safer, use existing relay fields instead of inventing a
new status. The packet should include:

- target repo and target object: branch, head, PR, tag candidate, plan, or task;
- effective contract: merged source doctrine, imported copy, plugin cache, and
  user-level bootstrap status as applicable;
- proposal boundary: whether branch-local doctrine or entrypoint files are
  proposal text;
- pending gates: review, fix-confirmation, exact approval, merge, tag, publish,
  or release;
- verification state: commands run, commands not run, and known accepted
  residuals with owners;
- next action: review, plan, implementation, continuation, merge, tag, publish,
  or no action;
- the three-line `Review:` contract inside any forwarded copy block.

The packet should reuse `Status: ready-for-continuation` when a named acting
agent can continue without exact approval, `Status: review-needed` when review
is pending, and `Status: ready-for-user-approval` when the user must reply with
exact approval text. It must keep the existing Route display rule: review-only
or findings-delivery packets do not show an `Execution route:` block.

### 3. Skill Source Provenance / Freshness Report

Add a small provenance report for questions about whether the agent is reading
latest skills. It should classify each relevant surface separately:

- **Source checkout:** read source files directly; no plugin bump is required
  for the current agent to inspect the checkout. Branch-local doctrine remains
  proposal text until review and merge.
- **Imported skill copy:** read `.agent-skills/pin`, managed imported files,
  and install metadata. It changes only after a release/tag or source reference
  is selected and the adopting repo reruns the installer or upgrade path.
- **Plugin cache:** read installed plugin metadata and runtime discovery state.
  Old installed plugin versions cannot expose newly added skills; update,
  upgrade, cache refresh, and restart rules belong to the plugin lifecycle.
- **User-level operator bootstrap:** read the managed instruction block and
  template provenance. Updating source doctrine does not rewrite user-level
  instructions unless operator-bootstrap propagation occurs.
- **Mechanism checks:** Agent Trigger Kit owns validators, session-check,
  live-check, version-check, and doctor-style repair flows.

This report is not a mandatory final-output field. It is required when the user
asks about freshness, when a new session is consuming a continuity packet, or
when a handoff / review failure could plausibly come from stale skill surfaces.

### 4. Skill Surface Disposition

The first implementation should not create a new default-installed skill.
Context continuity is a cross-cutting invariant, so the canonical wording
belongs in existing doctrine:

- `10-model-dispatch.md` for when to stop, hand off, or route to a fresh
  session;
- `15-repo-memory.md` for next-session seed and memory routing;
- `handoff-relay/SKILL.md` only as a trigger wrapper pointer if the trigger
  terms need a small update;
- `skill-authoring/SKILL.md` only if the train needs to clarify skill
  maintenance and extraction boundaries.

Mechanisms stay out of this markdown train:

- Agent Trigger Kit owns machine-readable freshness probes, live installed
  surface checks, session-check semantics, and doctor commands.
- operator-bootstrap owns user-level template propagation.
- adopting repos own `.agent-skills/pin`, generated imports, repo memory, and
  local cleanup.

### 5. Skill Maintenance / Optimization Follow-Up

The older idea of automatic skill cleanup or skill optimization should not be
implemented as an unbounded automation feature in this train. It should become
a roadmap candidate with these prerequisites:

- source material is pinned to public-safe conclusions, not raw private memory;
- each proposed cleanup is classified as doctrine, mechanism, repo-local data,
  or private evidence;
- `writing-skills` RED/GREEN pressure scenarios prove that the proposed skill
  text changes agent behavior;
- Agent Trigger Kit owns any repeatable scanner, doctor, or classifier
  mechanism;
- cleanup of adopting-repo generated imports or local rules remains
  approval-bound and opt-in.

## Scope

### In Scope

- Add a design spec for fresh-session continuity and source provenance.
- Update `ROADMAP.md` so the discussion is not lost.
- In the later implementation train, add compact doctrine and smoke tokens for
  the chosen wording.
- Bump install-facing metadata in the later implementation train if doctrine or
  installed skill text changes.

### Out of Scope

- Creating, pushing, or publishing a release tag.
- Updating any adopting repo's `.agent-skills/pin` or generated imports.
- Editing operator-bootstrap templates.
- Changing Agent Trigger Kit validators, session-check, live-check, or doctor
  behavior.
- Creating automation that rewrites, deletes, or optimizes skills without a
  reviewed plan.
- Treating current branch proposal text as effective doctrine before review and
  merge.

## Implementation Shape

The implementation plan should use TDD-style documentation pressure:

1. Add failing smoke assertions for the new source and installed-copy tokens.
2. Add compact doctrine in the canonical homes.
3. Update trigger-wrapper wording only if needed for discovery.
4. Add a v0.5.10 ROADMAP Landed entry and retire or narrow the implemented
   candidate rows.
5. Bump `.claude-plugin` metadata to `0.5.10` only in the implementation train
   that changes install-facing doctrine.
6. Run source and install smoke tests, `git diff --check`, token scans, and
   source-repo `session-check` with the documented root-source residual.

Suggested pressure scenarios:

- Source repo: agent distinguishes source checkout reading from plugin cache
  freshness and does not self-install the repo.
- Adopting repo: stale `.agent-skills/pin` leads to release / install guidance,
  not hand-editing generated imports.
- Plugin cache: stale installed plugin state leads to update / restart guidance,
  not a claim that source metadata alone updates runtime discovery.
- Handoff: a fresh-session packet includes relay fields and the three-line
  `Review:` contract, and omits `Execution route:` for review-only delivery.
- Proposal boundary: branch-local doctrine is read as proposal text until
  reviewed and merged.

## Verification Plan

- `agent-trigger-kit session-check`
- `bash tests/cross-repo-reference-map-smoke.sh`
- `bash tests/install-smoke.sh`
- `git diff --check origin/main..HEAD`
- Token scan for:
  `Fresh Session Continuity`, `context-health`, `Continuity Packet`,
  `Skill source provenance`, `Source checkout`, `Imported skill copy`,
  `Plugin cache`, `operator-bootstrap`, `Automated skill maintenance`,
  and `v0.5.10`.

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source plugin boundary: `agent-skills: plugin directory
missing`. If a relay signal is present and this is the only trigger-layer
failure, carry the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Review Focus

- Whether this should stay as compact canonical doctrine instead of a new
  default skill.
- Whether the provenance surfaces are complete enough for Codex, Claude Code,
  source checkouts, adopting repos, and plugin caches.
- Whether the continuity packet correctly reuses existing relay fields without
  creating new `Status:` values or route-display exceptions.
- Whether the automated skill maintenance idea is safely captured as a deferred
  candidate rather than premature mechanism work.

## Spec Review Disposition

Plan/rule-review passed for `1d97020` over range `0395c70..1d97020`; the
spec/roadmap capture is approved as-is. No edits were required to the reviewed
commit.

Carry these advisory notes into the later v0.5.10 implementation train:

- Continuity-packet wording must carry the positive half of the Route display
  rule: executable `ready-for-continuation` packets default to including a
  recommended `Execution route:` block.
- Do not restate a compressed `ready-for-continuation` precondition; defer to
  canonical `Status:` semantics in `10-model-dispatch.md`.

Push and any implementation-train start remain separate approval-bound actions.
