# Handoff Trigger Split Design

**Status:** Design spec for review.

**Goal:** Add a small default handoff / relay / exact-approval trigger surface
so agents find the controlling handoff rules before they emit status, review,
approval, or continuation handoffs. The new surface should reduce context load
without creating a second home for relay semantics.

## Problem

The current relay doctrine is present and increasingly precise, but it is hard
to trigger reliably:

- `agent-operating-manual` is a broad default skill. Its trigger description is
  optimized for dispatch economy, model choice, verification, and escalation,
  not specifically for handoff / approval / review relay work.
- The controlling handoff rules live in
  `skills/agent-operating-manual/10-model-dispatch.md` section 3.1, a dense
  section that also sits inside a larger model-dispatch file.
- Repeated misses happened around exactly this surface: missing pre-spec
  handoff copy blocks, imprecise `Status:` wording, treating approval as if it
  could bypass review, and asking the user to "send to review" instead of
  giving a paste-ready handoff.
- Stock Scanner behaved more smoothly because its local trigger layer uses
  small wrappers with high-signal descriptions, short `Must Read` lists, and
  narrow checklists.

The failure mode is not that the canonical relay rule is absent. The likely
failure mode is that agents do not enter the right small context soon enough.

## Design

Implement v0.5.4 as a trigger-surface split, not a doctrine rewrite.

### 1. Add A Default `handoff-relay` Wrapper Skill

Create a new top-level portable skill:

```text
skills/handoff-relay/SKILL.md
```

The wrapper should be installed by default alongside `agent-operating-manual`
and `multi-angle-review`. This is intentionally different from
`skill-authoring`, which stays optional. Handoff reliability is common-session
infrastructure, so an optional wrapper would not address the immediate misses.

The wrapper is a trigger layer only. It should have:

- concise frontmatter with trigger terms for handoff, relay, `Status:`,
  `Review:`, exact approval text, copy blocks, continuation, review requests,
  and user-forwarded blocks;
- a small `Must Read` section that points to the canonical files;
- a short application checklist that tells the agent what to verify before
  emitting or consuming a handoff.

The wrapper must not define new relay fields, rename `Status:` values, change
the `Review:` enum, or restate the full relay state machine.

### 2. Keep Canonical Homes Stable

The new wrapper should route to existing owners:

- `skills/agent-operating-manual/10-model-dispatch.md` section 3.1 remains the
  canonical home for relay fields, copy-block formatting, `Status:` semantics,
  exact approval text, `User action`, `Accepted residuals`, and execution-route
  display rules.
- `skills/multi-angle-review/SKILL.md` remains the canonical home for read-only
  review report shape, requested-changes handoffs, fix-confirmation reporting,
  and review-passed continuation guidance.
- `skills/agent-operating-manual/25-change-discipline.md` remains the canonical
  home for approval-bound identifiers and Plan / PR lifecycle stop points.

The wrapper can summarize when to read those files, but it should phrase its own
checklist as prompts such as "classify the immediate next action" and "confirm
copy-block completeness," not as a duplicate table of legal statuses.

### 3. Default Install And Entry Pointers

Update install-facing surfaces so adopting repos receive the new trigger:

- add `handoff-relay` to `DEFAULT_SKILLS`;
- add an entry-block pointer line for handoff / review / approval relay work;
- update README and plugin metadata descriptions so the public skill list and
  marketplace description name the new wrapper;
- update install smoke coverage so a default install proves
  `handoff-relay/SKILL.md`, its managed sentinel, and its entry pointer are
  present.

Because this changes install-facing skill content, the implementation train
should bump plugin metadata to `0.5.4` and add a `v0.5.4` ROADMAP Landed entry.
This is not release tag / publish authorization; tag and publish remain a later
approval-bound lifecycle.

### 4. Wrapper Content Shape

The wrapper should stay small enough to load without recreating the context
pressure problem. A good shape is:

```text
---
name: handoff-relay
description: "Use when preparing, reviewing, consuming, or forwarding agent handoffs, relay blocks, exact approval text, Status/User action decisions, Review contracts, or paste-ready copy blocks."
---

# Handoff Relay

This is a trigger layer only. Canonical relay semantics live in the Agent
Operating Manual and Multi-Angle Review.

## Must Read
- ../agent-operating-manual/10-model-dispatch.md, section 3.1
- ../multi-angle-review/SKILL.md, when a review or fix-confirmation is involved
- ../agent-operating-manual/25-change-discipline.md, when the handoff touches
  PR, merge, tag, publish, deploy, release, or another approval-bound object

## Apply
1. Classify the immediate next action before writing the handoff.
2. If review is pending, stop at a review-needed handoff.
3. If exact user approval is pending, put the exact text only in
   Required user text.
4. If the user must forward to a reviewer or acting agent, emit exactly one
   text fenced copy block containing the complete relay block and Review
   contract.
5. Put every non-blocking finding or FYI in Accepted residuals with an owner.
```

The final implementation may polish wording, but it should preserve these
boundaries: trigger-only, canonical pointers, short checklist, no duplicate
status table.

### 5. Expected Failure Handling

The implementation should make failure modes obvious:

- If the wrapper and canonical manual appear to conflict, the canonical manual
  wins and the wrapper should be fixed.
- If a requested handoff still lacks enough object identity, the agent should
  use `not-ready` or ask for the missing identifier instead of inventing
  approval.
- If a spec or implementation has not been reviewed, the wrapper should steer
  agents to a `review-needed` handoff rather than a user-approval gate.
- If accepted residuals exist, they must be carried in `Accepted residuals:`,
  not left only in surrounding prose.

## Scope

In scope for v0.5.4 implementation:

- Add the default `handoff-relay` wrapper skill.
- Add install and entry-pointer support for the wrapper.
- Add installed-copy smoke coverage for the wrapper and its key trigger tokens.
- Keep existing canonical relay and review homes linked from the wrapper.
- Update README, ROADMAP, and plugin metadata for the new default skill.

Out of scope for v0.5.4 implementation:

- Moving `10-model-dispatch.md` section 3.1 into a new canonical file.
- Adding, removing, or renaming relay `Status:` values.
- Changing the `Review:` enum.
- Changing Plan / PR lifecycle semantics.
- Defining release tag / publish lifecycle.
- Tagging, publishing, or pushing release artifacts.
- Adding Agent Trigger Kit validators, generated trigger-layer audits, hooks,
  outcome taxonomy changes, or session-check behavior changes.
- Implementing vector search, MCP indexing, retrieval-augmented loading, or
  skill chunking machinery.
- Extracting the portable `karpathy-guidelines` wrapper. That remains the
  separate portable wrapper-pattern lane after this handoff trigger slice.
- Editing adopting repos or generated imported copies directly.

## Verification For The Implementation

The implementation plan should include at least these checks:

- `agent-trigger-kit session-check`
- `bash tests/install-smoke.sh`
- `git diff --check`
- `git status -sb`
- Token scan:

```bash
rg -n 'handoff-relay|Handoff Relay|Status:|Review:|Required user text|Accepted residuals|10-model-dispatch.md|multi-angle-review|25-change-discipline.md|v0\.5\.4|0\.5\.4' skills README.md ROADMAP.md tests .claude-plugin
```

If available, the implementation may also run a skill frontmatter validation on
`skills/handoff-relay`, but the core gate remains installed-copy smoke coverage
because the miss is about adopting-repo trigger availability.

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Pre-Spec Review Disposition

This spec incorporates the design discussion and observed misses before the
file existed.

- User approval: accepted. The user approved direction A with the exact text
  `approve v0.5.4 handoff trigger split direction A and write spec`.
- Context dilution concern: accepted. The first fix should be a smaller default
  trigger surface, not vector retrieval or MCP indexing.
- Stock Scanner comparison: accepted. Its wrapper shape is useful, but its
  domain policy and local playbooks stay out of portable doctrine.
- Handoff misses after recent trains: accepted. Missing copy blocks, wrong
  approval/review sequencing, and imprecise status wording are treated as
  trigger-surface evidence, not as proof that the canonical relay rules should
  be duplicated.
- `karpathy-guidelines` follow-up: accepted as adjacent but separate. This spec
  uses the wrapper shape, while the portable work-discipline uplift remains a
  later lane.
- Release tag / publish gap: accepted as important but separate. This spec may
  bump metadata for install-facing content, but it does not define tag,
  publish, or post-publish lifecycle.

## Review Notes

- Please check whether making `handoff-relay` a default skill is the right
  install-surface choice. The design intentionally rejects optional-only because
  the observed failures happen in ordinary handoff work.
- Please check that the wrapper stays trigger-only and does not become a second
  canonical relay-rule home.
- Please check that v0.5.4 does not accidentally solve the later release
  lifecycle, vector retrieval, ATK mechanism, or `karpathy-guidelines` lanes.
