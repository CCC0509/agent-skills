# Public PR / Release Train Discipline Design

**Status:** Design spec for review.

**Goal:** Define the public-repo branch / PR / merge / release-train discipline
that keeps public `main` history deliberate, review evidence preserved, and
release tag choices explicit after install-facing changes land.

## Problem

The repo now has strong object-identity rules for plans, PRs, merges, tags, and
publish actions, but the public-repo operating shape is still inconsistent.
Recent trains improved the situation by moving work onto spec branches before
merge, but some already-public history was produced by direct local
fast-forwards or direct pushes to `main`. That history should not be rewritten,
yet future public work needs a clearer default.

The unresolved questions are:

- when a public repo must use a hosted PR rather than a local review range;
- whether a multi-commit spec / plan / smoke / implementation train should
  land on public `main` as-is or be squashed / summarized;
- what "version-only" public closeout means without losing required review and
  verification evidence;
- how a merged install-facing train hands off to release tagging without
  silently creating a tag or pretending the release is complete;
- where post-push `complete-no-action-needed` examples belong after v0.5.6 and
  v0.5.7 made tag choices explicit.

Existing doctrine covers adjacent pieces:

- `25-change-discipline.md` §3.1 owns Plan / PR object identity, PR stop,
  review-passed-is-not-merge-approval, pre-merge recheck, and squash merge
  evidence.
- `25-change-discipline.md` §3.2 owns release tag / publish object identity,
  exact tag and tag-push approvals, post-tag smoke, and no-backfill policy.
- `10-model-dispatch.md` §3.1 owns relay fields, exact approval text placement,
  `complete-no-action-needed`, and copy-block shape.
- `skill-authoring/SKILL.md` now says install-facing trains should proceed
  through the release lifecycle directly or as part of a later reviewed batch.

What is missing is the public-facing discipline that joins those rules together
for a public source repo.

## Design

Implement v0.5.8 as a doctrine increment, not as a release action. The
implementation should define the public repo path for future trains and leave
the current public history through `5677e4a` intact.

### 1. Canonical Home

Add the public PR / release train discipline to
`skills/agent-operating-manual/25-change-discipline.md`, adjacent to §3.1 and
§3.2. This is the right home because the new rule is about public object
identity: branch, PR, merge commit, release candidate, tag candidate, and
evidence location.

Keep these boundaries stable:

- `10-model-dispatch.md` remains the home for relay fields, `Status:` values,
  copy block formatting, and exact approval text placement.
- `25-change-discipline.md` §3.1 remains the generic Plan / PR lifecycle. The
  new text should extend it for public repos, not replace it.
- `25-change-discipline.md` §3.2 remains the release tag / publish lifecycle.
  The new text should decide when to enter that lifecycle, not duplicate its
  tag state machine.
- `skill-authoring/SKILL.md` may keep pointing at §3.2 for release gates. It
  should not become the public PR runbook.
- GitHub Actions, branch protection, PR templates, Agent Trigger Kit validators,
  and private plan repositories are out of scope for this train.

### 2. Public Repo Train States

Define a small state machine for public source repos:

1. **Public train branch:** substantive public-repo work starts on a branch
   whose base commit is named. Normative doctrine, release, entrypoint,
   installer, metadata, and public artifact changes remain plan-first. Direct
   public `main` editing is allowed only for an explicitly approved emergency
   or tiny administrative repair, and the closeout must say why branch / PR
   routing did not apply.
2. **Reviewable public PR or local equivalent:** when network and platform
   access allow it, push the branch and open a hosted PR before merge. If the
   harness cannot open a hosted PR, the local equivalent is a review handoff
   that names the exact branch, base, head, and range. "Local only" is not
   permission to skip review.
3. **Evidence-bearing branch / PR:** detailed specs, implementation plans,
   review reports, smoke evidence, and author verification live on the branch,
   in the PR body, or in public-safe review notes until the private plan
   artifact boundary is defined. Do not dump private paths, raw local logs, or
   secret-like evidence into public summaries.
4. **Public merge candidate:** after full review or fix-confirmation, stop at
   `ready-for-user-approval` for the exact PR/head or local branch/head. A
   passed review is not merge approval.
5. **Public merge execution:** before merge, re-check head identity, review
   applicability, smoke / repo gates, mergeability, and accepted residual
   owners. Prefer hosted PR merge with squash or rebase when it keeps public
   history compact and preserves evidence. Fast-forwarding a multi-commit
   superpowers train into public `main` should be exceptional after this rule
   lands and must be explicitly chosen.
6. **Public main closeout:** after merge and push, verify remote `main` points
   at the executed merge object. If no release action remains, emit
   `complete-no-action-needed`. If install-facing metadata changed, either
   stop at the §3.2 pre-tag approval gate for direct release, or record that the
   release is intentionally batched into a later reviewed release train.

### 3. Merge Shape And "Version-Only" Public History

The rule should make "version-only" precise. Public `main` should be concise,
but it must not lose evidence required by §2 or §3.1.

Allowed public merge shapes:

- **Hosted PR squash merge:** preferred when the PR preserves the detailed
  evidence. The squash commit subject may be short and version-scoped, but the
  PR body or squash body must preserve public-safe probes, review state, and
  accepted residuals.
- **Hosted PR rebase / merge commit:** allowed when commit granularity is
  intentionally public and each commit has a clear probe. This is useful for
  source repos where spec, red test, implementation, and verification commits
  are valuable public history.
- **Local squash / release commit:** allowed when hosted PR tooling is
  unavailable. The executor must prove tree equivalence between the approved
  branch head and the resulting main commit, or disclose the verification gap.

Not allowed as a default after v0.5.8:

- pushing directly to `main` before review;
- treating a full review as merge approval;
- fast-forwarding a noisy multi-commit train into public `main` without
  explicit merge-shape approval;
- using a terse version-only commit or closeout as a reason to omit review
  evidence.

In short: "version-only" means the public main-facing closeout can be compact
once evidence is captured elsewhere. It does not mean evidence disappears.

### 4. Release Train Interaction

The public PR discipline should call into §3.2 only after reviewed content is
on `main` or on a reviewed release branch.

- If the merged train changed install-facing skill text, default skill choice,
  plugin metadata, marketplace metadata, installer behavior, or adopting-repo
  install output, the merge closeout must surface the release choice:
  direct tag now, or batch into a later reviewed release train.
- Direct tag now means a fresh §3.2 pre-tag approval gate with exact text such
  as `approve create annotated tag v0.5.8 at COMMIT_SHA`.
- Batch later means record the batch decision as an accepted residual or roadmap
  entry with an owner. Do not imply normal adopters can receive the change until
  a tag or other publish surface is completed.
- Spec-only, plan-only, review-only, private-artifact-only, or non-installed
  roadmap updates do not require a metadata bump or tag by themselves.
- Tag creation, tag push, publish inventory, post-tag smoke, and post-publish
  verification remain separate gates under §3.2.

### 5. Post-Push Closeout Examples

This train should absorb the `Post-push complete-no-action-needed closeout
examples` roadmap row by adding concise examples to the public PR discipline or
nearby relay-facing pointer text.

Examples should cover:

- **No release remains:** a docs-only PR is merged and pushed, remote `main`
  matches the executed commit, no residuals remain, so
  `Status: complete-no-action-needed` is correct.
- **Release choice remains:** an install-facing PR is merged and pushed. The
  merge action is complete, but the release decision must be surfaced as direct
  tag approval text or an explicit batch decision.
- **Review remains:** a branch is pushed but review has not passed, so
  `Status: review-needed`, not `ready-for-user-approval`.
- **Merge approval remains:** full review passed but the user has not approved
  the exact PR/head merge, so `Status: ready-for-user-approval`.

These examples should remain short and point to `10-model-dispatch.md` §3.1 for
the relay field contract.

### 6. Roadmap Handling

When implemented, v0.5.8 should:

- add a `v0.5.8` Landed entry for public PR / release train discipline;
- retire `Public repo PR / release train discipline`;
- retire `Post-push complete-no-action-needed closeout examples` if the
  implementation adds the examples above;
- keep `Private superpowers plan artifact boundary` open, because this train
  does not move `docs/superpowers/**` or create a private repo;
- keep `Portable release-governance skill TDD` open, because this train does
  not create a portable release skill;
- keep `Branch / worker lifecycle hygiene` open unless the implementation
  explicitly narrows cleanup / branch deletion wording without defining worker
  spawn / wait / consume / close.

## Scope

In scope for v0.5.8 implementation planning:

- Add public PR / release train discipline to
  `skills/agent-operating-manual/25-change-discipline.md`.
- Add a concise pointer from any nearby installed surface only if the
  implementation plan finds a real trigger gap.
- Add smoke or token coverage for the public PR / merge / release choice terms.
- Add short post-push closeout examples.
- Update `ROADMAP.md` according to this spec's roadmap handling.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to
  `0.5.8` if installed doctrine changes.
- End implementation at full review before merge, push, tag, publish, branch
  cleanup, or release action.

Out of scope for this spec and its implementation train:

- Rewriting public history through `5677e4a`.
- Creating, pushing, deleting, or publishing `v0.5.8`.
- Opening a PR for this spec automatically, unless a later reviewed plan makes
  that the explicit execution route.
- Moving `docs/superpowers/**` to a private repo.
- Defining a private planning repo layout.
- Creating a portable release-governance skill.
- Adding GitHub Actions, branch protection, PR templates, validators, hooks, or
  Agent Trigger Kit mechanisms.
- Defining worker spawn / wait / consume / close or branch cleanup automation.
- Editing adopting repos or generated imported copies.

## Verification For This Spec

Because this is a design spec only, verification should be lightweight:

```bash
agent-trigger-kit session-check
git diff --check
rg -n '[T]BD|[T]ODO|[P]LACEHOLDER' docs/superpowers/specs/2026-07-07-public-pr-release-train-discipline-design.md
rg -ni 'Public repo PR / release train discipline|Post-push complete-no-action-needed closeout examples|public train branch|hosted PR|local equivalent|version-only|release choice|Private superpowers plan artifact boundary|Portable release-governance skill TDD|v0.5.8|0.5.8' docs/superpowers/specs ROADMAP.md skills README.md
```

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Pre-Spec Review Disposition

- User approval: accepted. The controlling approval text is
  `approve v0.5.8 public repo PR / release train discipline direction at 5677e4a and write spec`.
- Tag prompt after merge: accepted as v0.5.6 / v0.5.7 doctrine in action. The
  prompt is not automatic tagging; it surfaces the direct-vs-batched release
  choice after install-facing changes land.
- Public repo branch / PR expectation: accepted. Future public-repo trains
  should default to branch / PR or a named local equivalent before merge.
- Direct-main history through `5677e4a`: accepted residual. Do not rewrite it;
  use it as evidence for why the public PR discipline is needed.
- "Version-only" main closeout: accepted with precision. Public main-facing
  history should be concise, but required review and verification evidence must
  remain in a PR body, squash body, release note, public-safe audit summary, or
  other durable public record.
- Private superpowers plan artifact boundary: deferred. This train may note the
  boundary but must not move files or create a private repo.
- Portable release-governance skill: deferred. It remains a future
  writing-skills RED/GREEN train.

## Review Notes

- Please verify that this spec extends §3.1 and §3.2 without duplicating relay
  semantics from `10-model-dispatch.md`.
- Please verify that the merge-shape rules are strong enough to prevent noisy
  direct-main public history while preserving evidence required by §2 and §3.1.
- Please verify that the post-push examples can close the roadmap row without
  changing `Status:` enum semantics.
- Please verify that private plan artifact movement and portable release skill
  extraction stay out of scope.
