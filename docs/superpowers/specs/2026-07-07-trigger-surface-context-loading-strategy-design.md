# Trigger Surface / Context Loading Strategy Design

**Status:** Design spec for review.

**Goal:** Plan the next `agent-skills` roadmap slice so trigger-surface
improvements, context-loading pressure, portable wrapper extraction, adopting
repo overlap, and the release tag / publish lifecycle gap are routed together
instead of being fixed one reminder at a time.

## Problem

The last release train tightened many individual control-contract rules:
handoff copy blocks, review continuation, closeout memory routing, and Plan /
PR lifecycle discipline. The implementation still exposed a larger pattern:
agents can read the right files and still miss the controlling rule when the
trigger surface is too broad.

The likely failure mode is not a single missing sentence. It is a loading and
routing problem:

- `agent-operating-manual` is a large portable skill with several dense
  sub-documents.
- High-risk rules such as handoff, exact approval, review, lifecycle, release,
  and worker state live close together but activate in different situations.
- The source repo has extra proposal-boundary and ATK root-source constraints
  that adopting repos do not see in the same shape.
- Stock Scanner has smoother routing because its project-local plugin uses many
  short wrapper skills with high-signal descriptions, small `Must Read` lists,
  and narrow checklists.
- ROADMAP now has several related candidates, but they are not grouped by
  problem lane, so future agents may pick one candidate and miss the adjacent
  lifecycle gap.

The release tag / publish workflow is another visible gap. Current doctrine has
metadata / tag consistency guardrails and exact approval requirements, but there
is no canonical release lifecycle that defines metadata bump, push, tag,
publish, post-tag verification, and approval gates as one object-identity flow.

## Design

Treat v0.5.3 as a planning and triage increment. Its job is to define the lane
map and first follow-up sequence, not to implement retrieval, create new
mechanism validators, or publish a release.

### 1. Candidate Lane Map

The spec should group current and newly identified ROADMAP candidates into
lanes that future specs can consume.

**Trigger Surface / Context Loading**

- `Skill context loading / retrieval strategy`
- `F2 handoff-contract file split`
- `Adopting-repo project-scope overlap audit`
- `Plan/spec lifecycle header convention text`

This lane owns the question: how does an agent find the right rule with minimal
context load, and which parts belong in portable doctrine versus generated
trigger surfaces or adopting-repo wrappers?

**Portable Wrapper Pattern**

- `Portable work-discipline / Karpathy-guidelines uplift`

This lane should study the Stock Scanner `karpathy-guidelines` wrapper as a
portable pattern: concise frontmatter, high-signal trigger wording, a short
checklist, and a small number of must-read canonical files. It must not copy
Stock Scanner domain overrides, duplicate TDD / verification doctrine, or
centralize repo-local lessons.

**Release Lifecycle Gap**

- New candidate: `Release tag / publish lifecycle discipline`

This lane should define the missing release state machine later: metadata bump,
review, push, tag, publish, version consistency, post-tag install smoke, and
approval-bound release actions. v0.5.3 only records and prioritizes the gap; it
does not tag or publish anything.

**Execution / Worker Hygiene**

- `Branch / worker lifecycle hygiene`
- `Shared checkout concurrency etiquette`

This lane owns worker spawn / wait / consume / close, concurrency caps,
post-merge push state, local branch cleanup, and shared checkout collision
rules. It should stay separate from trigger-surface work so context-loading
fixes do not become branch-cleanup doctrine.

**Closeout / Evidence Taxonomy**

- `Preflight self-report contract`
- `Named absence statuses for missing closeout evidence`
- `Harness warning triage contract`
- `Probe catalog appendix`
- `Extraction-candidate closeout protocol`

This lane owns evidence naming, warning classification, probe cataloging, and
preflight / closeout memory semantics. It should wait for the trigger surface to
settle enough that closeout rules can point at stable homes.

### 2. First Implementation Slice

The first implementation slice after this strategy should be narrow:

1. Create a small handoff / relay / approval trigger surface, or split the
   existing handoff contract into a smaller conditional reference.
2. Keep the canonical doctrine in the existing manual files unless the split
   spec explicitly moves a section.
3. Add smoke coverage that proves adopted repos receive the new trigger pointer
   or wrapper.
4. Update ROADMAP so the neighboring candidates remain visible instead of being
   silently treated as solved.

This slice should use Stock Scanner's wrapper shape as the model, not its
domain content. The wrapper should say when to use it, which canonical files to
read, and what checklist to run before handoff. It should not create a second
home for relay status definitions.

### 3. Retrieval And Vector Deferral

Do not start with vector search, MCP indexing, or retrieval-augmented skill
loading. Those may become useful after the wrapper split is tested, but they
have different owners:

- `agent-skills` owns portable doctrine and trigger wording.
- Agent Trigger Kit owns generated trigger-layer mechanisms, validators, and
  project-surface audits.
- MCP / vector tooling is optional discovery infrastructure and must not become
  canonical memory or a prerequisite for ordinary doctrine maintenance.

The first test should be whether smaller trigger surfaces reduce misses. If
agents still miss rules after the split, the follow-up can compare retrieval
options with evidence from those failures.

### 4. Release Lifecycle Deferral

The release tag / publish lifecycle gap should become a named ROADMAP
candidate, but it should not be implemented inside the trigger-surface slice.

The later release lifecycle spec should answer:

- when metadata bump is allowed relative to review and merge;
- when `main` push is enough versus when a PR is required;
- exact approval text for tag and publish actions;
- how to verify tag target, metadata version, and installed pin agree;
- what post-tag / post-publish smoke evidence is required;
- how to report gaps when a platform cannot check a tag or marketplace state.

This separation matters because release/tag/publish is an irreversible action
lane, while trigger-surface work is about rule discovery.

### 5. Source Repo And Adopting Repo Boundaries

The design should preserve the current ownership map:

- Source doctrine changes happen in `agent-skills`.
- Generated imported copies in adopting repos are not edited directly.
- Adopting repo local wrappers may inspire portable doctrine, but domain policy
  and local memory stay in the adopting repo.
- Agent Trigger Kit mechanism changes stay out of a markdown-only
  `agent-skills` release unless a later spec explicitly crosses repo boundary.
- The known `agent-skills: plugin directory missing` source-repo health boundary
  remains an accepted residual, not a reason to create fake plugin directories.

## Scope

In scope for this strategy spec:

- Group related ROADMAP candidates into lanes.
- Include `Portable work-discipline / Karpathy-guidelines uplift` in the
  trigger-surface planning discussion.
- Identify `Release tag / publish lifecycle discipline` as a missing candidate.
- Recommend the first implementation slice: handoff / relay / approval trigger
  surface split or wrapper.
- State that vector / MCP retrieval is deferred until after smaller trigger
  surfaces are evaluated.
- Keep worker lifecycle, shared checkout etiquette, and closeout evidence
  taxonomy as separate lanes.

Out of scope for this strategy spec:

- Creating new skill wrappers.
- Moving existing doctrine sections.
- Changing relay `Status:` values or the `Review:` enum.
- Changing install behavior, ATK validators, session-check semantics, hooks, or
  outcome taxonomy.
- Implementing vector search, MCP indexing, retrieval-augmented loading, or
  skill chunking machinery.
- Defining worker lifecycle or shared checkout rules.
- Defining the release tag / publish lifecycle.
- Bumping plugin metadata.
- Tagging, publishing, or editing adopting repos.

## Proposed Follow-Up Sequence

1. **v0.5.3 strategy / roadmap grouping:** record the lane map, add the release
   lifecycle candidate, and preserve all unsolved neighboring candidates.
2. **v0.5.4 handoff trigger split:** add the first small trigger surface for
   handoff / relay / exact approval, with installed-copy smoke coverage.
3. **v0.5.5 portable work-discipline wrapper:** extract the reusable core of
   the Stock Scanner `karpathy-guidelines` wrapper without importing domain
   policy.
4. **v0.5.6 release lifecycle discipline:** define metadata / push / tag /
   publish gates after trigger-surface behavior is more stable.
5. **Later ATK / MCP investigation:** evaluate generated trigger-surface audits
   or retrieval only after smaller wrappers have evidence.

The exact version numbers are planning labels, not release commitments. A later
spec may adjust them if review finds a safer ordering.

## Verification For This Spec

Because this is a design-only increment, verification should be lightweight:

- `agent-trigger-kit session-check`
- `git diff --check`
- `git status -sb`
- Token scan:

```bash
rg -n 'Trigger Surface|Context Loading|Karpathy-guidelines|Release tag / publish lifecycle|Skill context loading / retrieval strategy|F2 handoff-contract file split|Adopting-repo project-scope overlap audit|Branch / worker lifecycle hygiene|Shared checkout concurrency etiquette' docs/superpowers/specs ROADMAP.md skills
```

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Pre-Spec Disposition

This spec incorporates the discussion that happened before the file existed.

- Context dilution concern: accepted. The current evidence suggests rule
  salience and trigger-surface shape are more likely than a pure skill-trigger
  miss.
- Stock Scanner comparison: accepted. Its repo-local short wrappers are a useful
  pattern for portable trigger design, while its domain policy remains local.
- `karpathy-guidelines` omission: accepted. It belongs in the lane map as the
  main portable wrapper-pattern candidate.
- Release tag / publish gap: accepted. Existing docs contain guardrails, but no
  full release lifecycle; this should become a named candidate.
- Vector / retrieval idea: accepted as a later investigation, not the first
  implementation slice.

## Review Notes

- This strategy should not become a grab bag. Its value is grouping related
  candidates so future specs can pick narrow implementation slices.
- The first concrete follow-up should improve immediate handoff / approval
  trigger reliability.
- Release tag / publish lifecycle is important, but it should remain separate
  from context-loading work because it governs irreversible actions.
- The Stock Scanner `karpathy-guidelines` wrapper should be treated as a shape
  example, not copied as-is.
