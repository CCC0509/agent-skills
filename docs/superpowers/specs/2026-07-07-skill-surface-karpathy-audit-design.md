# Skill Surface / Karpathy-Guidelines Audit Design

**Status:** Design spec for review.

**Goal:** Use the Stock Scanner `karpathy-guidelines` wrapper as a portable
review lens for the whole `agent-skills` repo, then plan a narrow first slice
that improves skill readability without turning the next train into a broad
cleanup. This spec also records adjacent public-repo and private-artifact
roadmap candidates raised during pre-spec discussion.

## Problem

The v0.5.4 handoff-relay wrapper improved one high-friction trigger surface,
but the larger repo shape still has unresolved context pressure:

- `agent-operating-manual` is a broad default skill with several dense
  sub-documents. Agents can load the right skill and still miss the controlling
  rule.
- The repo now has both canonical manuals and small wrappers, but there is not
  yet a repo-wide rule for deciding when to split a wrapper, when to keep text
  canonical, and when to delete overbuilt or duplicate process text.
- The approved v0.5.3 follow-up named portable
  `karpathy-guidelines` extraction, but the user clarified that the next slice
  should not merely add a wrapper. It should first use the guidelines to audit
  the whole skill surface for unnecessary complexity, oversized trigger
  surfaces, and changes that were made too broadly.
- Recent public-repo trains were committed and pushed directly on `main`.
  Rewriting that public history is not an acceptable cleanup strategy, but
  future public work should move back toward branch / PR / review / merge
  discipline.
- Superpowers specs and plans are public in this repo. Some future plan,
  review, or local evidence artifacts may be better housed in a private
  planning repo, with only public-safe summaries remaining here.

The failure mode is still rule salience and scope control, not lack of more
words. The next design needs to teach future agents how to reduce the surface
area they must hold in context.

## Design

Implement v0.5.5 as a repo-wide skill-surface audit and first-slice design, not
as a full repository cleanup.

### 1. Use Karpathy-Guidelines As An Audit Lens

The Stock Scanner wrapper source is the repo-local
`plugins/stock-scanner-ops/skills/karpathy-guidelines/SKILL.md` file in the
Stock Scanner checkout. Keep public references path-relative; do not publish a
maintainer's absolute local checkout path.

It identifies itself as adapted from `multica-ai/andrej-karpathy-skills` at
commit `2c606141936f` under MIT terms. v0.5.5 should preserve that attribution
if it creates a portable wrapper, but it must not import Stock Scanner domain
overrides or local playbook policy.

For `agent-skills`, the audit lens is:

1. **Think before changing:** record assumptions when a rule can reasonably
   live in more than one home.
2. **Prefer simplicity:** remove speculative process surface and avoid adding a
   wrapper unless it reduces real context load.
3. **Make surgical changes:** keep canonical doctrine in one home and add
   small trigger wrappers only as pointers.
4. **Finish against verifiable goals:** every split, deletion, or deferral
   needs a cheap probe such as token scan, installed-copy smoke, or byte-level
   wrapper comparison.

### 2. Audit The Existing Skill Surface Before Splitting More

The implementation plan should start with a read-only audit of the current
portable skill surface:

- `skills/agent-operating-manual/SKILL.md` and its sub-documents;
- `skills/handoff-relay/SKILL.md`;
- `skills/multi-angle-review/SKILL.md`;
- `skills/skill-authoring/SKILL.md`;
- README, installer pointers, smoke tests, and plugin metadata only as they
  affect trigger availability.

The audit should classify findings into these buckets:

- **Keep canonical:** large or normative material that should remain in the
  manual and be linked from wrappers.
- **Split trigger wrapper:** high-frequency, high-miss workflows that need a
  smaller front door.
- **Delete or shrink:** duplicate wording, over-specific examples, or process
  text that makes agents read more without changing behavior.
- **Defer with owner:** real concerns that belong to release lifecycle, public
  artifact hygiene, private planning artifacts, Agent Trigger Kit mechanisms,
  or adopting-repo local policy.

This audit should not become a free-form rewrite. It should produce a short
candidate map and choose one first implementation slice.

### 3. First Slice: Portable Work-Discipline Wrapper Or Equivalent

The preferred first slice is a small portable work-discipline trigger surface
inspired by `karpathy-guidelines`. The implementation plan should decide the
exact installed skill name, with `work-discipline` preferred for portability
and `karpathy-guidelines` retained in attribution / source notes.

The wrapper, if created, should be optional unless the audit shows it is needed
by most ordinary sessions. It should:

- trigger when agents are writing, reviewing, refactoring, or modifying docs,
  skills, plans, tests, scripts, or trigger layers;
- point to existing canonical homes for TDD, verification, change discipline,
  and review instead of restating them;
- carry the four lightweight principles from the audit lens;
- avoid Stock Scanner domain overrides;
- include attribution and license provenance for the adapted idea.

If the audit finds that an immediate wrapper would duplicate existing doctrine,
the first slice may instead be a smaller canonical pointer / README /
ROADMAP-only refinement. The implementation plan must make that choice
explicit.

### 4. Roadmap Additions From Pre-Spec Discussion

This spec should update ROADMAP now so the newly surfaced concerns do not get
lost behind the larger skill-surface work:

- `Repo-wide skill-surface audit / simplification pass`;
- `Public repo PR / release train discipline`;
- `Private superpowers plan artifact boundary`;
- `Post-push complete-no-action-needed closeout examples`.

These candidates are adjacent to v0.5.5 but not all implemented by it. The
roadmap should keep `Release tag / publish lifecycle discipline` visible as a
separate candidate because adopter delivery remains blocked for non-dev
installs until a reviewed tag / publish train exists.

### 5. Public Repo And Artifact Boundaries

The design should avoid rewriting public history. Direct-main commits through
`9ebdfce` should be treated as landed history, not something to repair with a
force-push. Future public repo work should prefer a branch / PR / review path
when the harness permits it, and the eventual release discipline spec should
decide how version bumps, release tags, and main-history shape interact.

The private-plan question should remain a roadmap candidate for now. Do not
move `docs/superpowers/**` in this train. A later spec should decide:

- which public specs / plans stay in this repo;
- which detailed plans, reviews, paste blocks, local paths, and private
  evidence belong in a private planning or audit repo;
- how public-safe summaries point to private evidence without leaking local or
  credentialed details;
- whether any migration keeps compatibility anchors for existing links.

## Scope

In scope for v0.5.5 design and implementation planning:

- Run a repo-wide skill-surface audit using the Karpathy-guidelines lens.
- Decide the first narrow skill-surface slice.
- Potentially create a small portable work-discipline wrapper, if the audit
  supports it.
- Preserve attribution for the upstream Karpathy-guidelines source if reused.
- Update ROADMAP with the newly surfaced public-repo and private-artifact
  candidates.
- Keep release lifecycle, private-plan movement, and broad skill splitting as
  separate follow-ups unless the first-slice plan explicitly narrows one
  small change.

Out of scope for v0.5.5:

- Rewriting public `main` history or force-pushing away already-landed commits.
- Moving existing `docs/superpowers/**` artifacts to a private repo.
- Defining the full release tag / publish lifecycle.
- Tagging, publishing, or changing release metadata.
- Adding Agent Trigger Kit validators, hooks, session-check semantics, or
  generated trigger-layer audits.
- Implementing vector search, MCP indexing, or retrieval-augmented loading.
- Editing adopting repos or generated imported copies directly.
- Splitting every skill that looks large in one train.

## Verification For This Spec

Because this is a design / roadmap increment, verification should be
lightweight:

- `agent-trigger-kit session-check`
- `git diff --check`
- placeholder scan for unfinished placeholder markers
- token scan:

```bash
rg -ni 'Karpathy-guidelines|repo-wide skill-surface audit|Public repo PR / release train discipline|Private superpowers plan artifact boundary|Post-push complete-no-action-needed|Release tag / publish lifecycle|work-discipline' docs/superpowers/specs ROADMAP.md skills README.md
```

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Pre-Spec Disposition

This spec incorporates the discussion that happened before the file existed.

- Revised user approval: accepted. The controlling approval text is
  `approve v0.5.5 repo-wide skill-surface audit and Karpathy-guidelines direction at 9ebdfce`.
- Karpathy-guidelines scope correction: accepted. The next train should not
  only add a wrapper; it should use the guidelines as a repo-wide audit lens
  and then choose a narrow first slice.
- Skill readability concern: accepted. The user explicitly tied recent misses
  to insufficiently split trigger surfaces, so the spec treats discoverability
  as a first-class design concern.
- Public repo direct-main concern: accepted. Already-pushed history should not
  be rewritten, but future public work needs a roadmap candidate for PR /
  release train discipline.
- Private superpowers plan concern: accepted. The public/private artifact
  boundary should be designed before moving plans or evidence.
- Push-closeout status miss: accepted. A push closeout with no remaining user
  or agent action should use `complete-no-action-needed`; this spec records a
  roadmap candidate for examples or trigger guidance.
- Release lifecycle gap: accepted but deferred. It remains important and
  visible, but v0.5.5 focuses on skill-surface architecture first.

## Review Notes

- Please check whether the spec keeps the audit narrow enough for one
  implementation plan.
- Please check whether the first-slice wrapper guidance avoids duplicating TDD,
  verification, review, or change-discipline canonical homes.
- Please check whether the ROADMAP additions make the public PR discipline,
  private plan boundary, and post-push status issue durable without pretending
  v0.5.5 solves them.
