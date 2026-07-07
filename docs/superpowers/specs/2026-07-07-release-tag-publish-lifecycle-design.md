# Release Tag / Publish Lifecycle Design

**Status:** Design spec for review.

**Goal:** Define a release tag / publish lifecycle for `agent-skills` so
metadata bumps, reviewed commits, tags, pushes, publish actions, post-release
smoke, and exact approval gates are handled as one object-identity flow.

## Problem

The repo now has several landed trains whose plugin metadata advanced past the
last published tag. As of `ea9990c`, both manifests say `0.5.5`, `main` and
`origin/main` point at `ea9990c`, but the local release tags only reach
`v0.4.7`. `install.sh` intentionally rejects clean but untagged source checkouts
unless `--dev` is used, so adopters cannot receive the current default /
optional skill surface through the normal exact-tag path.

Existing doctrine covers pieces of the release problem:

- `README.md` says `git tag vX.Y.Z` is the single version source and manifests
  must agree with the tag.
- `install.sh` enforces clean source, exact tag, and tag/metadata agreement.
- `tests/install-smoke.sh` covers untagged source, dev pins, and metadata
  mismatch behavior.
- `skill-authoring/SKILL.md` says release metadata and tag must agree before
  publishing.
- `25-change-discipline.md` owns approval-bound identifiers and Plan / PR
  lifecycle stop points, but explicitly does not define release tagging or
  publishing.
- `10-model-dispatch.md` owns relay fields, exact approval text, and
  `ready-for-user-approval`.

What is missing is the connective lifecycle: when a metadata bump is merely a
reviewed implementation artifact, when a tag may be created, which exact
approval text is required, how a tag push differs from a publish action, what
post-tag / post-publish smoke proves, and how to report terminal closeout.

## Design

Implement the next train as doctrine and tests for the lifecycle, not as the
release action itself. The implementation should make future release agents
follow a deterministic sequence and stop at each irreversible gate.

### 1. Canonical Home And Boundaries

Add the lifecycle to `skills/agent-operating-manual/25-change-discipline.md`
near Plan / PR lifecycle discipline, because this is an approval-bound object
identity flow. That section should own release object identity and stop points.

Keep these boundaries stable:

- `10-model-dispatch.md` remains the canonical home for relay fields,
  `Status: ready-for-user-approval`, exact approval text placement, and
  `complete-no-action-needed`.
- `skill-authoring/SKILL.md` remains a concise authoring checklist. It may point
  to the release lifecycle but should not duplicate the full state machine.
- `README.md` may keep the public version rule and install guidance, but it
  should not become a release runbook.
- `install.sh` and `tests/install-smoke.sh` remain mechanism / smoke surfaces.
  They may gain cheap probes or token coverage, but this train should not turn
  them into a release orchestrator.
- Agent Trigger Kit validators, marketplace cache refresh, generated release
  audits, GitHub release automation, and adopting-repo updates are out of scope.

### 2. Release Object State Machine

The lifecycle should name these states and the evidence required to leave each
state:

1. **Implementation / metadata train:** a normal reviewed branch may bump
   `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` when it
   changes install-facing doctrine or plugin surface. This is not tag or publish
   authorization.
2. **Reviewed main candidate:** the candidate commit is on `main` or a reviewed
   release branch, required review/fix-confirmation has passed, worktree is
   clean, and manifest versions agree on the intended `X.Y.Z`.
3. **Pre-tag approval gate:** the agent stops with `Status:
   ready-for-user-approval`. Required text must name the exact tag and target
   commit, for example `approve create annotated tag v0.5.6 at COMMIT_SHA`.
4. **Local annotated tag created:** create an annotated tag only after approval.
   Verify the peeled target with `git rev-parse vX.Y.Z^{}` and verify it equals
   the approved commit. Existing tags are mostly annotated; keep that pattern and
   treat the old `v0.1.0` lightweight tag as historical.
5. **Pre-tag-push approval gate:** if the tag has not been pushed, stop again
   unless the prior approval explicitly covered pushing that tag to the named
   remote. Required text must name tag, target commit, and remote, for example
   `approve push tag v0.5.6 targeting COMMIT_SHA to origin`.
6. **Remote tag verified:** after push, verify the remote tag and peeled target.
   Prefer `git ls-remote --tags origin vX.Y.Z` plus a local fetch / peeled-target
   check when available.
7. **Post-tag smoke:** from a clean checkout at the exact tag, prove normal
   install no longer needs `--dev`. At minimum, run `bash tests/install-smoke.sh`
   and a direct tagged-source `./install.sh "$TMP/target"` probe that records pin
   `CCC0509/agent-skills@vX.Y.Z`.
8. **Publish inventory / approval gate:** if the release has another publish
   surface beyond the pushed tag, first identify the surface and exact command
   or platform action. Stop with `Status: ready-for-user-approval` before that
   publish. If there is no separate publish surface, say that explicitly and do
   not invent one.
9. **Post-publish verification:** verify the published surface independently
   where possible. If credentials, policy, CLI availability, or marketplace
   semantics block verification, report the gap as a blocker or accepted
   residual with a durable owner; do not route around credentials or policy.
10. **Terminal closeout:** once tag/publish actions and verification are done,
    emit `Status: complete-no-action-needed` only when no user or next-agent
    action remains. Otherwise use the existing relay status rules.

### 3. Exact Approval Text Rules

The lifecycle should make approval transfer impossible:

- Metadata bump approval does not authorize tag creation.
- Tag creation approval does not authorize pushing the tag unless the exact text
  says so.
- Pushing a tag does not authorize any separate marketplace, GitHub release, or
  plugin publish action.
- A prior release approval does not authorize a later version or later commit.
- If the candidate commit changes after approval, the approval is stale.

The implementation should add concrete examples to doctrine without changing
the `Status:` enum or `Review:` enum.

### 4. Version Gap And Backfill Policy

Do not retroactively create tags for `v0.4.8` through `v0.5.5` in this train.
Those commits are already public history and their missing tags are useful
evidence of the gap this lifecycle is closing. A later release can deliver all
current content by tagging the reviewed release head with the then-current
manifest version.

If the implementation train changes install-facing doctrine, it should bump
both manifests to `0.5.6` and later release action should target `v0.5.6` after
review and merge. The spec itself does not authorize the metadata bump, tag,
tag push, publish, or any adopting-repo install.

### 5. Roadmap Handling

When implemented, this lifecycle should:

- add a `v0.5.6` Landed entry describing release lifecycle doctrine;
- remove the `Release tag / publish lifecycle discipline` extraction candidate
  and its now-empty lane only if no other release-lifecycle row remains there;
- keep `Public repo PR / release train discipline`, `Private superpowers plan
  artifact boundary`, `Post-push complete-no-action-needed closeout examples`,
  `Branch / worker lifecycle hygiene`, and trigger/context-loading candidates
  open unless a reviewed plan explicitly narrows one of them.

The public PR discipline row remains separate: it decides future branch / PR /
merge history shape. The release lifecycle row decides tag / publish object
identity after reviewed content exists.

## Scope

In scope for the eventual v0.5.6 implementation plan:

- Add release tag / publish lifecycle doctrine to `25-change-discipline.md`.
- Add concise cross-references from `skill-authoring/SKILL.md` and, if useful,
  the README version section.
- Add smoke or token coverage for the new lifecycle terms and approval examples.
- Update `ROADMAP.md` according to the roadmap handling above.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to
  `0.5.6` if install-facing default doctrine changes.
- End implementation at full review before merge / tag / publish.

Out of scope for this spec and its implementation train:

- Creating, pushing, deleting, moving, or backfilling any tag.
- Publishing to any marketplace, GitHub release, package registry, or adopting
  repo.
- Editing adopting repos or generated imported copies.
- Defining public PR discipline beyond the release lifecycle's dependency on a
  reviewed candidate commit.
- Moving `docs/superpowers/**` to a private repo.
- Defining worker spawn / wait / consume / cleanup lifecycle.
- Adding Agent Trigger Kit validators, hooks, outcome taxonomy, or generated
  release audit mechanisms.
- Implementing vector search, MCP indexing, or retrieval-backed loading.

## Verification For This Spec

Because this is a design spec only, verification should be lightweight:

```bash
agent-trigger-kit session-check
git diff --check
rg -n '[T]BD|[T]ODO|[P]LACEHOLDER' docs/superpowers/specs/2026-07-07-release-tag-publish-lifecycle-design.md
rg -ni 'Release tag / publish lifecycle|annotated tag|peeled target|post-tag smoke|post-publish|ready-for-user-approval|complete-no-action-needed|0.5.6|v0.5.6|Public repo PR / release train discipline|Private superpowers plan artifact boundary' docs/superpowers/specs ROADMAP.md skills README.md install.sh tests
```

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Pre-Spec Disposition

- User approval: accepted. The controlling approval text is
  `approve v0.5.6 release tag / publish lifecycle direction at ea9990c and write spec`.
- Recommended direction: accepted. The next train should address the release tag
  / publish lifecycle before public PR discipline or private plan artifact
  movement because current manifests are `0.5.5` while tags only reach
  `v0.4.7`.
- Public PR / release train discipline: deferred. It remains a separate ROADMAP
  candidate because it governs future public branch / PR / merge shape, not the
  tag / publish state machine itself.
- Private superpowers plan artifact boundary: deferred. It remains a separate
  ROADMAP candidate and no files move in this train.
- Post-push no-action closeout examples: deferred except for the terminal
  closeout relationship in the release lifecycle.
- Backfill tags: rejected for this train. Future release should target the
  reviewed release head, not retroactively reconstruct missing tags.

## Review Notes

- Please verify that the lifecycle belongs in `25-change-discipline.md` without
  duplicating relay semantics from `10-model-dispatch.md`.
- Please verify that exact approval gates are strong enough for tag creation,
  tag push, and publish, but do not authorize any of those actions during the
  implementation train.
- Please verify that the spec closes the adopter delivery gap directionally
  without trying to solve public PR discipline, private artifact boundaries, or
  Agent Trigger Kit mechanisms in the same slice.
