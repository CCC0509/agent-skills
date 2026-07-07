# Plan / PR Lifecycle Discipline Design

**Status:** Design spec for review.

**Goal:** Add a narrow Plan / PR lifecycle discipline that makes branch-first
work, PR stop, explicit approval, and squash merge boundaries durable without
changing relay status values, review enums, worker lifecycle, release tagging,
or Agent Trigger Kit mechanisms.

## Problem

The current doctrine has strong pieces, but they are scattered:

- `10-model-dispatch.md` defines relay status, exact approval text, execution
  route display, and the rule that approval gates must use
  `ready-for-user-approval`.
- `25-change-discipline.md` defines approval-bound identifiers, verifiable
  commit structure, and a seed note that squash merge closeout must preserve
  probe results.
- `multi-angle-review/SKILL.md` defines read-only review behavior and says
  findings are bucketed before merge.
- `AGENTS.md` says normative doctrine and approval changes are plan-first and
  end in fresh review before merge.

What is missing is the lifecycle state machine that connects those rules. Agents
can still blur these boundaries:

- implementation may begin or continue on an unnamed branch / head;
- a completed implementation may continue into merge instead of stopping at PR
  review;
- review-passed can be treated like merge approval;
- exact approval can be copied as prose instead of living in a fenced relay
  block;
- squash merge can happen without re-checking that the approved PR/head is still
  the executed object;
- post-review merge closeout can lose the verification probes that justified
  approval.

This is not a worker lifecycle problem. It does not decide how many workers to
spawn, when to close subagents, how to clean local worktrees, or how to prune
merged branches. It is also not a release-tagging or publishing workflow.

## Design

Implement this increment as a small addition to `25-change-discipline.md`, with
one cross-reference from `10-model-dispatch.md`.

### 1. Branch-First Work Boundary

For work that is expected to become a PR, merge, release PR, or other
approval-bound change, the acting agent should establish a concrete work branch
/ head before substantive implementation when the harness permits it. The
handoff must name the branch or current head in `Target:` when a later agent
must review, continue, or approve that work.

If the environment is already an externally managed checkout, detached head, or
single-checkout source repo, the agent should record the constraint and keep the
same approval-bound discipline: name the current head, avoid pretending branch
isolation exists, and stop before merge.

This rule is about reviewable object identity. It does not define worktree
creation, cleanup, worker fan-out, or branch pruning.

### 2. Plan / Spec Before Implementation

Normative doctrine, relay, review, approval, release, and entrypoint changes
remain plan-first. The implementation start gate is an exact-text approval gate
when the user has not already approved execution.

A pre-spec or plan approval wait must be emitted as a single `text` fenced relay
block, not loose prose. The exact approval phrase lives only in
`Required user text:`. The surrounding prose may say that the current chat is
waiting for user input, but must not duplicate the exact approval text outside
the relay field.

### 3. PR Stop

After implementing scoped work and running the agreed verification, the author
must stop at review handoff. The closeout should use:

```text
Status: review-needed
User action: self-review -> to-reviewer
Required user text: n/a
```

The author must not merge, squash merge, tag, publish, deploy, or clean up
branches as part of the implementation closeout unless the user gave a separate
approval-bound command for that exact action and identifier.

If no hosted PR exists, the local equivalent is still a stop point: identify the
branch/head and ask for review of the exact range. Do not convert "local only"
into permission to skip review.

### 4. Review Passed Is Not Merge Approval

A passed full review or fix-confirmation only satisfies the review gate. It does
not authorize merge. If merge is the next step, the handoff must move to:

```text
Status: ready-for-user-approval
User action: self-review -> reply-required-text
Required user text: <exact merge approval naming PR/head>
```

The required text must bind to the concrete object, such as `PR #123 at
<head-sha>` or `local branch <name> at <head-sha>`. Ambiguous approvals such as
"looks good" are not merge approval when more than one object or action is in
scope.

### 5. Pre-Merge Recheck

Before an agent executes merge after exact approval, it must re-check the
approved object:

- current PR/head still matches the approved identifier;
- review or fix-confirmation still applies to that head;
- required CI / smoke / repo gates still pass or remain explicitly waived;
- mergeability is current;
- accepted residuals have durable owners.

If the head changed, approval is stale. The agent must stop and request a new
review or exact approval for the new head.

### 6. Squash Merge Evidence

Squash merge is allowed only after the pre-merge recheck and exact approval. The
merge closeout must preserve the proof that the executed merge corresponds to
the reviewed and approved content. The cheap probe is tree equivalence: the
squash merge commit tree should match the approved PR/head tree. If tree
equivalence cannot be checked in the environment, the closeout must disclose the
gap and name the remaining evidence.

The squash commit message, PR closeout, release notes, or audit memory should
carry the verification summary required by `25-change-discipline.md`
`Verifiability-Driven Commit Structure`.

### 7. Release And Worker Boundaries

This increment must explicitly leave these out of scope:

- release tagging or publishing;
- deploys or runtime actions;
- worker spawn / wait / consume / close;
- concurrency caps;
- worktree cleanup;
- local branch cleanup;
- post-merge push-state cleanup;
- Agent Trigger Kit validators, hooks, or outcome taxonomy.

Keep the existing `Branch / worker lifecycle hygiene` ROADMAP row for that
separate problem.

## File-Level Shape

Implementation should touch only these files:

- `tests/install-smoke.sh`: add imported-skill smoke tokens for the new Plan /
  PR lifecycle section.
- `skills/agent-operating-manual/25-change-discipline.md`: add the canonical
  `Plan / PR Lifecycle Discipline` section.
- `skills/agent-operating-manual/10-model-dispatch.md`: add a compact
  cross-reference from approval / route / normative-control wording to the new
  lifecycle section, without adding relay fields or status values.
- `ROADMAP.md`: add a v0.5.2 landed entry, remove the `Plan / PR lifecycle
  discipline` extraction candidate, preserve `Branch / worker lifecycle
  hygiene`, and add the deferred context-loading candidate named below.
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`: bump to
  `0.5.2`.

Do not edit adopting repos or generated imported copies directly.

## Pre-Spec Review Disposition

This spec incorporates the pre-spec / design-framing discussion before the spec
file existed.

- Narrow scope selection: accepted. The chosen approach is the narrow Plan / PR
  lifecycle doctrine increment: branch-first, PR stop, explicit approval, and
  squash merge. Release tagging and worker lifecycle remain separate.
- Missing pre-spec relay surface: accepted. The earlier design approval prompt
  omitted the fenced relay block required by the v0.5.1 durable conclusion
  capture rule. This spec therefore includes an explicit rule that pre-spec,
  plan, and approval waits must use a single `text` fenced relay block.
- Repeated waiting-handoff miss: accepted. A later agent reported "waiting on
  approval" in prose without the copy block. The design treats this as evidence
  that the lifecycle rule must be a concrete state machine, not another loose
  reminder.
- Context-load concern: accepted as a plausible architecture concern, not as a
  proven root cause for the handoff misses. The current `agent-operating-manual`
  skill is large, and agents may fail to apply all loaded rules under context
  pressure. This release should not add vector retrieval machinery. Instead,
  implementation should add a ROADMAP extraction candidate named `Skill context
  loading / retrieval strategy`, likely shared between agent-skills doctrine,
  Agent Trigger Kit mechanisms, and optional MCP / vector-index tooling.

## Scope

In scope:

- Add one canonical Plan / PR lifecycle section to
  `skills/agent-operating-manual/25-change-discipline.md`.
- Clarify branch/head identity before implementation and review.
- Require implementation closeout to stop at review / PR handoff.
- Clarify that review-passed is not merge approval.
- Require exact merge approval to name the PR/head or local branch/head.
- Require pre-merge recheck before executing merge.
- Define squash merge evidence expectations, including tree-equivalence when
  available.
- Add a compact `10-model-dispatch.md` cross-reference to the lifecycle section.
- Add install-smoke tokens for adopted repos.
- Add a v0.5.2 landed entry and retire the Plan / PR lifecycle candidate.
- Preserve `Branch / worker lifecycle hygiene`.
- Add a deferred `Skill context loading / retrieval strategy` ROADMAP candidate.
- Bump plugin metadata to `0.5.2` during implementation.

Out of scope:

- Adding, removing, or renaming relay `Status:` values.
- Changing the `Review:` enum.
- Changing Agent Trigger Kit validators, session-check, hooks, or outcome
  taxonomy.
- Implementing vector search, MCP indexing, retrieval-augmented skill loading,
  or skill chunking machinery.
- Defining worker lifecycle, worktree cleanup, branch cleanup, concurrency caps,
  or post-merge push-state cleanup.
- Defining release tagging, publishing, deploys, or runtime actions.
- Editing adopting repos or generated imported copies.
- Release tagging or publishing `v0.5.2`.

## Verification

Implementation should verify:

- `agent-trigger-kit session-check`
- `tests/install-smoke.sh`
- `tests/source-entrypoint-smoke.sh`
- `tests/cross-repo-reference-map-smoke.sh`
- `git diff --check`
- `git diff --check origin/main..HEAD` or the equivalent merge-base range
- `git status -sb`
- A token scan such as:

```bash
rg -n 'Plan / PR Lifecycle Discipline|branch-first|PR stop|review-passed is not merge approval|pre-merge recheck|squash merge evidence|tree equivalence|Skill context loading / retrieval strategy|Branch / worker lifecycle hygiene|v0\.5\.2|0\.5\.2' skills/agent-operating-manual ROADMAP.md tests .claude-plugin
```

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Review Notes

- The value of this increment is object identity: agents should know what branch,
  PR, head, approval, and merge object they are acting on.
- This should not become another generic "be careful before merge" paragraph.
  The implementation should read like a lifecycle: branch/head, plan, implement,
  PR stop, review, exact approval, pre-merge recheck, squash evidence, closeout.
- The context-loading concern is important, but separate. A vector or retrieval
  strategy may be right later, yet this release should only make the concern
  durable in ROADMAP.
