# Private Toolchain Workspace Design

**Status:** Transitional design spec for review.

**Goal:** Define a private tool-development workspace that becomes the durable
home for tool portfolio planning, private evidence, review records, roadmap
candidates, and adopter-harness validation while public tool repos keep only
tool source, install-facing documentation, public release history, and
public-safe review attestations.

## Background

`agent-skills`, Agent Trigger Kit, and `operator-bootstrap` now share enough
process surface that planning them only inside their public source repos creates
two recurring problems:

- source repos do not always behave like ordinary adopter repos. In
  `agent-skills`, AGENTS.md explicitly says the checkout is not an adopting
  repo and should not self-install its own skills. Agent Trigger Kit's
  root-source `./` plugin boundary is a documented example of that mismatch.
- detailed superpowers plans, review paste blocks, local evidence, machine
  state, and cross-repo lifecycle notes are useful for tool development but are
  too private or too noisy to keep expanding public source repos.

This spec is the transitional public artifact that defines the boundary before
any files move. It is intentionally public-safe: it does not include local
checkout paths, raw review paste blocks, machine-specific state, credentials,
or private evidence. After the private workspace is created, a copy of this
spec may be migrated there; the public copy should then become a frozen
historical record with a pointer to the private living document.

This spec's review evidence is the last intended full public review artifact
for this boundary decision. That is a deliberate bootstrap exception: the
public/private review-attestation rule cannot govern the evidence that defines
it. Future detailed review evidence should live in the private workspace, with
public repos retaining only public-safe attestations.

## Verified Baseline

`agent-skills` v0.5.10 is the public migration baseline for this repo:

- `v0.5.10` is an annotated tag targeting
  `6fae509e9db8f362eee4e1fde28e222564f03d71`.
- The tag was published on 2026-07-08 and covers the batched install-facing
  content from v0.5.7, v0.5.8, v0.5.9, and v0.5.10.
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` both
  record version `0.5.10`.

Older ROADMAP landed entries still say that v0.5.7 through v0.5.10 require a
later section 3.2 tag. Do not rewrite those historical entries. The next public
release-history update should record the forward-only fact that the v0.5.10 tag
closed that batch. This prevents fresh sessions from treating stale landed-entry
wording as current release state while preserving no-backfill history.

Agent Trigger Kit and `operator-bootstrap` must each receive their own release
state audit before any migration plan treats them as clean baselines.

## Problem Statement

The current public repo shape mixes four concerns:

1. install-facing tool source and public usage docs;
2. reusable doctrine and tool code;
3. planning, review, and evidence artifacts for tool development;
4. cross-repo portfolio state, including versions, residuals, and environment
   freshness notes.

The first two belong in public tool repos when the tool itself is public. The
last two need a private workspace so agents can inspect full context without
publishing private evidence or distorting public repo history.

The private workspace must not become a vague dumping ground. It needs precise
lifecycle rules so public repos remain verifiable after detailed plans and
reviews move out.

## Design

### 1. Workspace Role

Create a private toolchain workspace for tool development across current and
future repos. It is not limited to `agent-skills`, Agent Trigger Kit, and
`operator-bootstrap`; those are the initial portfolio entries.

The private workspace owns:

- portfolio-level roadmap, release train notes, and cross-tool sequencing;
- detailed specs, implementation plans, review reports, handoff paste blocks,
  and private evidence;
- a dynamic tool registry for versions, residuals, freshness checks, and
  adoption state;
- an adopter-harness area that installs released tools like an ordinary
  consumer repo, instead of self-testing from a source checkout;
- a promotion ledger that maps private planning evidence to public commits,
  tags, and public attestations.

Public tool repos keep:

- tool source, installer, manifests, tests, and minimal public usage docs;
- public CHANGELOG or release-history notes;
- public-safe review attestations for merges, tags, or releases whose detailed
  evidence lives privately;
- any reusable doctrine or mechanism that truly belongs in that public repo.

### 2. Public Review Attestation

Moving detailed review evidence private must not weaken public merge, tag, or
release gates. Every public repo change that depends on private review evidence
needs a public-safe attestation in a durable public surface. The primary home
is the public commit body for the merge, release, or change object. PR bodies,
public CHANGELOG entries, and release notes may mirror or point to the same
attestation, but verifiers should know to start from the commit body.

The attestation reuses existing relay and review vocabulary. It is not a new
parallel review system. It records durable review facts, not live handoff
state. A public attestation should include this subset when applicable:

```text
Target: <public repo/object identifier>
Accepted residuals: <public-safe residuals with owners, or none>

Review: <full | plan/rule-review | fix-confirmation vs <prev-tip> | closeout-sanity | none-FYI>
Focus: <public-safe focus or n/a>
Prev reviewed tip: <public commit/tag/PR identifier or n/a>

Private evidence ref: <opaque private workspace reference>
```

Rules:

- Do not include live relay control fields such as `Status:` or
  `Next agent action:` in durable attestations. Those fields remain in live
  handoffs where stale state can be acted on immediately and retired.
- `Review:` must use the existing enum.
- `Accepted residuals:` uses the same durable-owner rule as relay handoffs.
- `Private evidence ref:` is audit metadata, not a relay field and not
  approval text. It must be opaque enough for public use and must not reveal
  local paths, machine names, credentials, or raw private notes.
- The attestation does not replace exact approval gates. Merge, tag, push,
  publish, deploy, and branch cleanup still need their normal approval-bound
  object identity.

### 3. Ownership Split

The public cross-repo reference map and the private registry have different
jobs.

- Public cross-repo reference map: static routing doctrine. It says which repo
  owns reusable doctrine, operator-bootstrap templates, Agent Trigger Kit
  mechanisms, adopting-repo local policy, generated imports, and MCP / local
  tooling surfaces.
- Private tool registry: dynamic portfolio state. It records current released
  versions, local checkout heads, known residuals, freshness-check results,
  active migration state, and environment-specific notes.

If the two disagree, treat public routing doctrine as the ownership rule and
private registry data as state that needs correction. The registry should point
back to public doctrine instead of restating it at length.

### 4. Roadmap And Memory Split

The current `ROADMAP.md` mixes public release history with private planning
candidates. Migration should split it into two public/private surfaces:

- Public CHANGELOG or release history: the public successor for the Landed
  section. It should preserve what each public tag or public commit train
  delivered, including the forward-only note that v0.5.10 closed the v0.5.7 to
  v0.5.10 batch.
- Private portfolio roadmap: the successor for Candidate Lanes and Extraction
  Candidates. It owns unsolved planning candidates, cross-tool sequencing,
  private evidence boundaries, and tool-development backlog.

The private workspace should support both portfolio-level and tool-specific
memory:

- portfolio memory for cross-tool sequencing, shared lifecycle choices,
  release trains, and private/public boundary decisions;
- tool memory for a single repo's roadmap, residuals, known trigger gaps,
  release state, and adopter-harness findings.

Private specs, plans, and reviews should either live under tool-specific
subdirectories or include a `Tool:` metadata line so registry cards can index
them. The first implementation should choose one convention and apply it only
to new private artifacts; historical public files should not be rewritten just
to add metadata.

### 5. Historical Artifact Migration

Do not move or delete historical `docs/superpowers/**` artifacts as part of the
first private-workspace setup. Define the boundary first, seed the private
repo, then migrate in reviewed batches.

Migration rules:

- Historical plans with appended review blocks should move as intact historical
  records. Do not split old evidence just to fit a new `reviews/` convention.
- New work in the private workspace should use separate `specs/`, `plans/`,
  and `reviews/` surfaces, plus a promotion ledger entry linking private
  evidence to public output.
- Public repo cleanup should happen only after the private copy, public
  attestation, and public release-history successor exist.
- Public links or compatibility anchors should be preserved until a reviewed
  cleanup plan decides otherwise.

### 6. Ignored Plan Residue

Older Agent Trigger Kit plans and local ignore rules may have left ignored plan
residue on more than one machine. Treat this as migration input, not as junk to
delete during bootstrap.

The private workspace should include an inventory-first cleanup track:

- identify ignored plan artifacts and their owning repo / machine class;
- classify each as `migrate`, `archive`, `discard`, or `local-only residue`;
- record whether the artifact belongs to public-safe history, private evidence,
  ATK mechanism work, or adopter-local memory;
- require explicit approval before deleting or rewriting anything outside the
  new private workspace.

### 7. Adopter Harness

The first private workspace version should include an adopter-harness design,
but not automation scripts.

The harness should act like an ordinary consuming repo:

- install `agent-skills` from a public tag;
- install or enable Agent Trigger Kit the same way a user project would;
- apply or verify operator-bootstrap instructions through their ordinary
  distribution path;
- start fresh sessions and verify whether skills, relay rules, handoffs,
  freshness reports, and review attestations are discovered correctly.

This closes the source-repo self-test gap without creating a new orchestration
system. Repeatable validators, scanners, repair commands, and generated trigger
layers remain Agent Trigger Kit mechanism candidates unless a later ownership
spec decides otherwise.

### 8. Candidate Impact

This spec fully addresses only the boundary decision for
`Private superpowers plan artifact boundary`, after implementation and migration
complete.

It partially unblocks but does not close:

- `Automated skill maintenance / optimization protocol`: private source
  material and ownership classification improve, but RED/GREEN skill-writing
  pressure scenarios and ATK mechanism boundaries remain required.
- `Skill context loading / retrieval strategy`: private artifact movement may
  reduce public noise, but the large Agent Operating Manual and retrieval
  problem remain unsolved.
- cross-repo ownership management: the private registry can track dynamic
  state, but public routing doctrine remains the source of static ownership
  truth.

## Scope

In scope for this transitional spec:

- Define the private workspace purpose and public/private artifact boundary.
- Define the public review attestation requirement using existing relay and
  review vocabulary.
- Define roadmap splitting into public release history and private candidates.
- Define historical migration sequencing and review evidence preservation.
- Define ignored-plan residue as inventory-first cleanup.
- Define an adopter-harness role without adding automation scripts.

Out of scope for this spec:

- Creating the private repo.
- Moving, deleting, or rewriting `docs/superpowers/**`.
- Editing public repo layout, README, CHANGELOG, ROADMAP, or doctrine.
- Creating sync, migration, release orchestration, validator, scanner, or repair
  scripts.
- Changing Agent Trigger Kit mechanisms, operator-bootstrap templates, or
  adopting-repo files.
- Publishing private evidence or local machine state in public artifacts.

## Suggested Implementation Sequence

1. Write and review this transitional spec in `agent-skills`.
2. Create the private workspace after spec review passes.
3. Seed the private workspace with a registry, portfolio roadmap, promotion
   ledger, lifecycle docs, adopter-harness fixture area, and a private copy of
   this spec.
4. Freeze this public spec as historical record and add a public pointer to the
   private living document only if a reviewed plan says that pointer is
   public-safe.
5. Add a forward-only public release-history note that v0.5.10 closed the
   v0.5.7 to v0.5.10 install-facing batch. This does not depend on private
   workspace creation and may run independently any time after this spec
   passes review.
6. Migrate historical specs, plans, reviews, and roadmap candidates in
   batches. Preserve historical review blocks intact.
7. Only after migration evidence and public attestations exist, plan public repo
   cleanup so source repos contain tool source, minimal public docs, and public
   release history.

## Verification For This Spec

Because this is a public-safe design spec only, verification is lightweight:

```bash
agent-trigger-kit session-check
git diff --check
rg -n '[T]BD|[T]ODO|[P]LACEHOLDER' docs/superpowers/specs/2026-07-08-private-toolchain-workspace-design.md
rg -ni 'Private Toolchain Workspace|public review attestation|Private evidence ref|v0.5.10|promotion ledger|public CHANGELOG|private portfolio roadmap|ignored plan residue|adopter harness|Tool:' docs/superpowers/specs/2026-07-08-private-toolchain-workspace-design.md
```

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. A plugin-version-freshness advisory
that is indeterminate from the same root-source cause is the same accepted
residual. When a relay signal is present, carry:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`
and, when reported,
`ATK plugin-version-freshness advisory indeterminate from same root-source cause / owner: Agent Trigger Kit follow-up`.

## Pre-Spec Direction Disposition

- Private workspace direction: accepted. The first version is planning,
  evidence, registry, and adopter harness only; sync and release orchestration
  scripts are deferred.
- Sequencing correction: accepted. Write this transitional spec first in
  `agent-skills`, then create the private repo after review passes.
- v0.5.10 baseline: accepted. The published v0.5.10 tag is the
  `agent-skills` migration baseline and closes the earlier batched release.
- Public review evidence finding: accepted. Public repos need durable
  public-safe review attestations even when full evidence moves private.
- Ownership drift finding: accepted. Public cross-repo maps remain static
  routing doctrine; private registry cards hold dynamic state.
- Roadmap impact finding: accepted. This spec fully addresses only the private
  artifact boundary. Other candidates are partially unblocked and remain open.
- Reviews migration finding: accepted. Historical appended review records stay
  intact; new private work may use separate review files.
- Ignored plan residue finding: accepted. Inventory and classify before moving
  or deleting residue on any machine.
- Roadmap split finding: accepted. Landed release history should become public
  CHANGELOG / release history; candidate lanes and extraction candidates move
  to the private portfolio roadmap.
- Attestation vocabulary finding: accepted. Attestations reuse existing
  `Accepted residuals:` and three-line `Review:` contract vocabulary, add only
  an opaque private evidence reference as audit metadata, and exclude live
  relay control fields such as `Status:` and `Next agent action:`.

## Review Focus

- Whether the public review attestation preserves review-gate verifiability
  without inventing a parallel relay / review vocabulary.
- Whether the forward-only treatment of stale ROADMAP release wording is clear
  enough for fresh sessions.
- Whether the public cross-repo map versus private registry split prevents
  ownership drift.
- Whether the migration sequence avoids moving evidence before the private
  workspace has a reviewed lifecycle.
- Whether the no-scripts first version keeps Agent Trigger Kit mechanism
  ownership intact.
