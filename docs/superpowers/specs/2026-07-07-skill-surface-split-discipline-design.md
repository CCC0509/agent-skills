# Skill Surface Split Discipline Design

**Status:** Design spec for review.

**Goal:** Make skill splitting a repeatable discipline instead of a one-off
v0.5.4 / v0.5.5 repair, and route the release tag / publish lifecycle toward a
future portable skill only after skill-level RED/GREEN pressure testing.

## Problem

v0.5.4 and v0.5.5 proved that smaller trigger surfaces help. The handoff-relay
wrapper made relay / approval rules easier to find, and the optional
work-discipline wrapper gave agents a compact front door for assumptions,
simplicity, surgical edits, and verification. But the repo still lacks a
durable rule for future changes:

- agents may add another reminder to an already-large canonical file when the
  right fix is a narrow wrapper;
- agents may create a new wrapper when the right fix is to shrink duplicate
  prose or add one pointer;
- default-vs-optional install decisions are still made case by case;
- future specs do not yet have to explain why a rule stayed canonical, became a
  wrapper, moved to a reference file, or was deferred;
- the release tag / publish flow just worked for v0.5.6, but copying that
  repo-specific lifecycle into a broad "release skill" without testing would
  overfit to this repo's `.claude-plugin` and `install.sh` mechanics.

The user also asked whether tag / publish should advance for every update. The
answer needs a durable rule: install-facing updates should normally proceed
through the release lifecycle after review and merge; spec-only, plan-only, or
private-artifact work should not force a version bump or tag by itself.

## Design

Implement v0.5.7 as a small authoring-discipline train. It should add a
decision procedure for future skill-surface changes and preserve the portable
release-skill idea as a tested follow-up, not as immediate implementation.

### 1. Canonical Home

The skill-surface split rule belongs in `skills/skill-authoring/SKILL.md`.
That skill already owns extraction, portable skill scope, trigger metadata,
reusable resources, release/version reconciliation, and consumer install
guidance. v0.5.7 should make it the home for "what shape should this rule take?"
decisions.

Keep these boundaries stable:

- `skills/agent-operating-manual/10-model-dispatch.md` owns relay fields,
  `Status:` semantics, copy-block formatting, exact approval text placement,
  and route display rules.
- `skills/agent-operating-manual/25-change-discipline.md` owns Plan / PR and
  release tag / publish object identity, approval transfer, and public evidence
  hygiene.
- `skills/work-discipline/SKILL.md` remains a trigger wrapper. It may point to
  `skill-authoring` if useful, but it should not become a second canonical home
  for skill-surface architecture.
- `skills/handoff-relay/SKILL.md` remains a trigger wrapper. It should not
  absorb skill authoring or release lifecycle doctrine.
- Agent Trigger Kit remains the mechanism owner for validators, generated
  trigger layers, session-check semantics, hooks, and outcome taxonomy.

### 2. Skill Surface Disposition

Future specs and implementation plans that create, split, delete, rename, or
substantially edit a skill should include a short "Skill Surface Disposition"
decision. The implementation should define this as a checklist in
`skill-authoring/SKILL.md`.

The disposition should choose one of these shapes:

- **Keep canonical:** use when the content is normative doctrine with shared
  authority, object identity, approval semantics, or cross-wrapper invariants.
- **Add / keep trigger wrapper:** use when the workflow is high-frequency or
  high-miss, has a distinct trigger phrase, and can point to existing canonical
  homes without restating them.
- **Move to one-hop reference:** use when details are too long or conditional
  for `SKILL.md`, but still belong to the same skill and should load only when
  needed.
- **Split into separate optional skill:** use when trigger, audience, must-read
  set, or install choice differs enough that bundling it increases context load.
- **Make default-installed:** use only when most ordinary adopting-repo
  sessions need the trigger surface. Otherwise keep it explicit-install /
  optional.
- **Delete or shrink:** use when duplicate prose, stale examples, or broad
  reminders add tokens without changing behavior.
- **Defer with owner:** use when the concern belongs to Agent Trigger Kit,
  adopting-repo policy, private planning artifacts, MCP / vector retrieval, or
  another roadmap lane.

The rule should prefer deletion, pointer, or wrapper before broad canonical
growth. It should also prevent wrapper sprawl: one observed miss is not enough
to create a new skill if a small pointer, frontmatter fix, or smoke assertion
would close the gap.

### 3. Trigger And Frontmatter Rules

v0.5.7 should bring the existing `skill-authoring` guidance closer to the
tested lesson from `superpowers:writing-skills`: frontmatter descriptions must
describe triggering conditions, not summarize the workflow so agents can skip
the body.

The implementation should add concise guidance that new or edited skills:

- keep frontmatter trigger-focused and avoid workflow summaries;
- keep `SKILL.md` small enough to be scanned under pressure;
- keep `Must Read` lists minimal and one-hop;
- point to canonical homes instead of restating state machines;
- preserve attribution when adapting public or repo-local source material;
- record default-vs-optional install reasoning when install surface changes.

This is an authoring rule, not a new trigger-layer mechanism. It should be
verified with cheap docs and smoke probes, not a generated validator in this
train.

### 4. Release Cadence Rule

The implementation should add a concise release cadence rule to
`skill-authoring/SKILL.md` near the existing release checklist:

- If a reviewed train changes install-facing skill text, default skill choice,
  plugin metadata, marketplace metadata, installer behavior, or adopting-repo
  install output, it should bump manifests and then proceed through the
  release tag / publish lifecycle after review and merge.
- If a train changes only specs, implementation plans, private planning
  artifacts, non-installed roadmap text, or review evidence, it should not bump
  metadata or create a tag unless a reviewed release plan says otherwise.
- Tag creation, tag push, publish, and post-release smoke remain separate exact
  approval gates under `25-change-discipline.md` §3.2.
- Publish is inventory-driven. If the pushed Git tag is the only delivery
  surface, say no separate publish surface exists and do not invent one.

This answers "should tag and publish advance every update?" as: every
install-facing version update should be carried to a reviewed tag, while
non-install planning updates do not require a release.

### 5. Portable Release Skill Direction

Do not create a portable release-governance skill in v0.5.7. The v0.5.6
release lifecycle is valuable source material, but a reusable skill must pass
the `superpowers:writing-skills` RED/GREEN discipline first.

A later portable release-governance train should:

1. define pressure scenarios before writing the skill;
2. run baseline scenarios without the skill and record actual failures;
3. cover at least these repo types:
   - Git-tag-only delivery with no separate publish surface;
   - GitHub Release or equivalent hosted release surface;
   - package registry publish such as npm, PyPI, or crates;
   - plugin marketplace install / publish flow;
   - metadata bump with no install-facing change, which should not release;
4. write the minimal skill that fixes observed failures;
5. verify agents stop at separate tag-create, tag-push, publish, and
   post-publish gates;
6. keep repo-specific commands in adopting-repo docs or references rather than
   claiming one universal command sequence.

The future skill's frontmatter should trigger on release action planning,
metadata/tag mismatch, publish approval, post-tag smoke, or "is this release
done?" questions. It should not summarize the whole workflow in the
description.

### 6. Roadmap Handling

This spec should add a durable roadmap candidate for the future portable
release-governance skill TDD train. It should not mark the candidate landed.

The eventual v0.5.7 implementation should:

- add a `v0.5.7` Landed entry for skill-surface split discipline and release
  cadence guidance;
- keep `Skill context loading / retrieval strategy`, `F2 handoff-contract file
  split`, `Public repo PR / release train discipline`, `Private superpowers
  plan artifact boundary`, `Post-push complete-no-action-needed closeout
  examples`, worker hygiene, ATK mechanism, and retrieval candidates open;
- add or preserve the portable release-governance skill TDD candidate as a
  future train;
- avoid claiming that the future portable skill exists before it has been
  pressure-tested.

## Scope

In scope for v0.5.7 implementation planning:

- Add a compact skill-surface split / disposition rule to
  `skills/skill-authoring/SKILL.md`.
- Add trigger-frontmatter and default-vs-optional install guidance there.
- Add release cadence guidance that points to `25-change-discipline.md` §3.2
  without restating the release state machine.
- Add or preserve ROADMAP coverage for the future portable release-governance
  skill TDD train.
- Add smoke or token coverage for the new guidance.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to
  `0.5.7` only in the implementation plan if install-facing skill text changes.

Out of scope for this spec and its implementation train:

- Creating the future portable release-governance skill.
- Running RED/GREEN pressure scenarios for that future skill.
- Changing the `Status:` enum, `Review:` enum, relay block fields, or route
  display rules.
- Moving release lifecycle doctrine out of `25-change-discipline.md`.
- Changing `install.sh`, publishing mechanics, Agent Trigger Kit validators,
  session-check behavior, hooks, or outcome taxonomy.
- Implementing vector search, MCP indexing, or retrieval-backed skill loading.
- Moving `docs/superpowers/**` to a private repo.
- Defining public PR / squash / release-commit discipline.
- Creating, pushing, deleting, or publishing `v0.5.7`.
- Editing adopting repos or generated imported copies.

## Verification For This Spec

Because this is a design / roadmap increment, verification should be
lightweight:

```bash
agent-trigger-kit session-check
git diff --check
rg -n '[T]BD|[T]ODO|[P]LACEHOLDER' docs/superpowers/specs/2026-07-07-skill-surface-split-discipline-design.md
rg -ni 'skill-surface split|Skill Surface Disposition|portable release-governance|release cadence|default-vs-optional|frontmatter|Public repo PR / release train discipline|Private superpowers plan artifact boundary|Skill context loading / retrieval strategy' docs/superpowers/specs ROADMAP.md skills README.md
```

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Pre-Spec Disposition

This spec incorporates the discussion before the file existed.

- User approval: accepted. The controlling approval text is
  `approve v0.5.7 skill-surface split discipline and portable release-skill direction at 14548cbc9b014e49ee32661e7f3ff5f1887e5af9 and write spec`.
- Skill split as a recurring rule: accepted. v0.5.4 and v0.5.5 were not meant
  to be one-off repairs; future skill changes need a reusable disposition
  checklist.
- Portable release skill question: accepted but deferred. The release tag /
  publish lifecycle is broadly useful, but a portable skill requires
  `writing-skills` RED/GREEN pressure scenarios first.
- Tag / publish for every update: accepted with qualification. Install-facing
  version updates should advance through tag gates after review and merge;
  spec-only or private planning changes do not require tags.
- Branch-first public repo expectation: accepted. This spec was written on a
  branch from `14548cbc`; direct-main history through v0.5.6 should not be
  rewritten.
- v0.5.6 release closeout: accepted as source evidence. The pushed `v0.5.6`
  tag and post-tag smoke show the lifecycle can work here, but that does not
  prove the same shape is portable to package registries or hosted release
  platforms.

## Review Notes

- Please check whether `skill-authoring/SKILL.md` is the right canonical home
  for the split / disposition rule.
- Please check whether the release cadence rule answers the user's "every
  update" concern without forcing tags for non-install planning commits.
- Please check whether the portable release-governance skill is deferred
  strongly enough to avoid shipping an untested process skill.
- Please check whether the ROADMAP candidate keeps the future portable skill
  visible without re-opening the v0.5.6 release lifecycle implementation.
