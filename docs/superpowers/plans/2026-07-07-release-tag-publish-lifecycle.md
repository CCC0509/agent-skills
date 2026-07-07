# Release Tag / Publish Lifecycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved v0.5.6 release tag / publish lifecycle
discipline so future release agents stop at exact approval gates for metadata,
tag, tag-push, publish, post-release verification, and terminal closeout.

**Architecture:** Keep release object identity in
`skills/agent-operating-manual/25-change-discipline.md`, add thin
cross-references from authoring and public version docs, and cover the new
tokens through install smoke. This implementation changes default installed
doctrine, so it bumps plugin metadata to `0.5.6`, but it creates no tag,
publishes nothing, and does not push.

**Tech Stack:** Markdown doctrine, Bash install smoke, JSON plugin metadata,
`rg`, `git`, Agent Trigger Kit session-check.

## Global Constraints

- Base this work on approved spec commit `036c50e` and reviewed base
  `ea9990c`.
- Start on branch `spec/v0.5.6-release-lifecycle`; do not execute this plan
  directly on `main`.
- The lifecycle belongs in
  `skills/agent-operating-manual/25-change-discipline.md` beside the Plan / PR
  lifecycle. Do not move relay fields, `Status:` semantics, exact approval text
  placement, or copy-block rules out of `10-model-dispatch.md`.
- Keep `skill-authoring/SKILL.md` as a checklist cross-reference, not a
  duplicate release state machine.
- Keep `README.md` as public install / version guidance, not a release runbook.
- Keep `install.sh` as an install mechanism. Do not turn it into a release
  orchestrator.
- Because this plan changes install-facing default doctrine in the
  `agent-operating-manual` skill, bump both plugin manifests to `0.5.6`.
- A metadata bump is not tag, tag-push, publish, push, merge, install, or
  adopting-repo authorization.
- Do not create, push, delete, move, or backfill any tag, including `v0.4.8`
  through `v0.5.5`.
- Do not publish to a marketplace, GitHub release, package registry, or
  adopting repo.
- Do not define public PR discipline, private plan artifact movement, worker
  lifecycle hygiene, Agent Trigger Kit validators, vector retrieval, MCP
  indexing, or adopting-repo cleanup.
- Close only the `Release tag / publish lifecycle discipline` ROADMAP
  candidate. Keep `Public repo PR / release train discipline`, `Private
  superpowers plan artifact boundary`, `Post-push complete-no-action-needed
  closeout examples`, `Branch / worker lifecycle hygiene`, trigger-surface,
  context-loading, ATK, and evidence-taxonomy candidates open.
- End implementation with `Status: review-needed`, `Review: full`, and a fresh
  review request before any merge, push, tag, publish, or release approval gate.
- The final implementation handoff must include an author verification block,
  not only a prose summary.
- Known non-blocking source-repo residual:
  `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

---

## File Structure

- Modify: `tests/install-smoke.sh`
  Adds red-then-green token coverage for the installed release lifecycle
  doctrine and authoring checklist pointer.
- Modify: `skills/agent-operating-manual/25-change-discipline.md`
  Adds the canonical release tag / publish lifecycle state machine.
- Modify: `skills/skill-authoring/SKILL.md`
  Points release checklist readers to the canonical lifecycle.
- Modify: `README.md`
  Keeps the public version rule and adds a short lifecycle pointer.
- Modify: `.claude-plugin/plugin.json`
  Bumps metadata to `0.5.6`.
- Modify: `.claude-plugin/marketplace.json`
  Bumps metadata to `0.5.6`.
- Modify: `ROADMAP.md`
  Adds the v0.5.6 Landed entry, removes the solved release-lifecycle lane and
  row when it is empty, and preserves adjacent open candidates.
- Update during execution:
  `docs/superpowers/plans/2026-07-07-release-tag-publish-lifecycle.md`
  checkboxes.

---

### Task 1: Red Install-Smoke Coverage

**Files:**
- Modify: `tests/install-smoke.sh`
- Modify: `docs/superpowers/plans/2026-07-07-release-tag-publish-lifecycle.md`

**Interfaces:**
- Consumes: current installed `agent-operating-manual` and optional
  `skill-authoring` smoke coverage.
- Produces: failing smoke assertions for the lifecycle doctrine and checklist
  pointer that Task 2 must satisfy.

- [ ] **Step 1: Confirm branch, reviewed spec, and source health**

Run:

```bash
git branch --show-current
git rev-parse --short HEAD
git merge-base --is-ancestor ea9990c HEAD
git status --porcelain
agent-trigger-kit session-check
```

Expected:

- `git branch --show-current` prints
  `spec/v0.5.6-release-lifecycle`.
- `git rev-parse --short HEAD` prints `036c50e` or a descendant created by
  this plan.
- `git merge-base --is-ancestor ea9990c HEAD` exits `0`.
- `git status --porcelain` is empty before editing, except this plan file after
  checkboxes are ticked.
- `agent-trigger-kit session-check` exits `1` only with
  `agent-skills: plugin directory missing`, no failure categories, and no
  failure drivers.

- [ ] **Step 2: Add red release-lifecycle assertions to the default install**

In `tests/install-smoke.sh`, after the existing assertion:

```bash
  grep -Fq 'tree equivalence' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing tree equivalence evidence"
```

add:

```bash
  grep -Fq 'Release Tag / Publish Lifecycle Discipline' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing release lifecycle section"
  grep -Fq 'approve create annotated tag' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing tag-create approval example"
  grep -Fq 'approve push tag' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing tag-push approval example"
  grep -Fq 'Post-tag smoke' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing post-tag smoke"
  grep -Fq 'Post-publish verification' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing post-publish verification"
  grep -Fq 'Metadata bump approval does not authorize tag creation' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing approval non-transfer rule"
```

- [ ] **Step 3: Add red release-lifecycle assertion to optional skill-authoring**

In `tests/install-smoke.sh`, in section `# 13) optional skills install only
when explicitly requested`, after:

```bash
[ -f "$TMP/target/docs/imported-skills/skill-authoring/.managed-by-agent-skills" ] \
  || fail "missing skill-authoring sentinel"
```

add:

```bash
grep -Fq 'Release tag / publish lifecycle discipline' \
  "$TMP/target/docs/imported-skills/skill-authoring/SKILL.md" \
  || fail "imported skill-authoring missing release lifecycle pointer"
```

- [ ] **Step 4: Run smoke and verify the red failure**

Run:

```bash
bash tests/install-smoke.sh
```

Expected: exit `1` with this first failure:

```text
SMOKE FAIL: CLAUDE.md imported change discipline missing release lifecycle section
```

- [ ] **Step 5: Commit red smoke coverage and checkbox update**

Run:

```bash
git add tests/install-smoke.sh docs/superpowers/plans/2026-07-07-release-tag-publish-lifecycle.md
git commit -m "test: add release lifecycle install smoke"
```

Expected: commit succeeds. The smoke test stays red until Task 2 adds the
release lifecycle doctrine.

---

### Task 2: Doctrine, Cross-References, Metadata, And Roadmap

**Files:**
- Modify: `skills/agent-operating-manual/25-change-discipline.md`
- Modify: `skills/skill-authoring/SKILL.md`
- Modify: `README.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `ROADMAP.md`
- Modify: `docs/superpowers/plans/2026-07-07-release-tag-publish-lifecycle.md`

**Interfaces:**
- Consumes: red smoke assertions from Task 1.
- Produces: canonical release lifecycle doctrine, metadata `0.5.6`, and
  ROADMAP closeout for the solved release-lifecycle row.

- [ ] **Step 1: Add release lifecycle doctrine**

In `skills/agent-operating-manual/25-change-discipline.md`, insert this section
after `§3.1 Plan / PR Lifecycle Discipline` and before `§4 Public Evidence
Hygiene`:

```markdown
## §3.2 Release Tag / Publish Lifecycle Discipline

Use this lifecycle for release actions after reviewed content exists. This
section owns release object identity and irreversible stop points. Relay fields,
copy-block formatting, and exact approval text placement remain in
[`10-model-dispatch.md`](10-model-dispatch.md) §3.1. Install mechanics remain in
`README.md`, `install.sh`, and `tests/install-smoke.sh`.

1. **Implementation / metadata train**: a reviewed branch may bump
   `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` when it
   changes install-facing doctrine or plugin surface. A metadata bump is not a
   tag, tag-push, publish, install, deploy, merge, or adopting-repo
   authorization.
2. **Reviewed main candidate**: the candidate commit is on `main` or a reviewed
   release branch, required review or fix-confirmation has passed, the worktree
   is clean, and both manifests agree on the intended version.
3. **Pre-tag approval gate**: stop with `Status: ready-for-user-approval`.
   Required text must name the exact annotated tag and target commit, for
   example `approve create annotated tag v0.5.6 at COMMIT_SHA`.
4. **Local annotated tag created**: after exact approval, create an annotated
   tag and verify the peeled target with `git rev-parse vX.Y.Z^{}`. The peeled
   target must equal the approved commit. Prefer annotated tags; the old
   `v0.1.0` lightweight tag is historical.
5. **Pre-tag-push approval gate**: if the tag is not on the remote, stop again
   unless prior approval explicitly named pushing that tag to that remote.
   Required text must name tag, target commit, and remote, for example
   `approve push tag v0.5.6 targeting COMMIT_SHA to origin`.
6. **Remote tag verified**: after tag push, verify the remote tag identity with
   `git ls-remote --tags origin vX.Y.Z` and, when available, a fetched local
   peeled-target check.
7. **Post-tag smoke**: from a clean checkout at the exact tag, prove normal
   install no longer needs `--dev`. At minimum, run `bash tests/install-smoke.sh`
   and a direct tagged-source `./install.sh "$TMP/target"` probe that records
   pin `CCC0509/agent-skills@vX.Y.Z`.
8. **Publish inventory / approval gate**: if another publish surface exists
   beyond the pushed tag, first identify the exact surface and command or
   platform action. Stop with `Status: ready-for-user-approval` before that
   publish. If no separate publish surface exists, say so explicitly and do not
   invent one.
9. **Post-publish verification**: verify the published surface independently
   where possible. If credentials, policy, CLI availability, or marketplace
   semantics block verification, report the gap as a blocker or accepted
   residual with a durable owner; do not route around credentials or policy.
10. **Terminal closeout**: emit `Status: complete-no-action-needed` only when
    tag, publish, and verification actions are complete and no user or
    next-agent action remains. Otherwise follow the relay status rules in
    `10-model-dispatch.md` §3.1.

Approval does not transfer:

- Metadata bump approval does not authorize tag creation.
- Tag creation approval does not authorize pushing the tag unless the exact
  text says so.
- Pushing a tag does not authorize any separate marketplace, GitHub release,
  package registry, plugin publish action, or adopting-repo install.
- A prior release approval does not authorize a later version or later commit.
- If the candidate commit changes after approval, approval is stale.

Do not backfill missing tags for already-public trains unless a separate
reviewed release-repair plan authorizes that exact backfill. The normal path is
to tag the reviewed release head with the current manifest version.
```

- [ ] **Step 2: Add the skill-authoring release checklist pointer**

In `skills/skill-authoring/SKILL.md`, replace:

```markdown
- Release metadata and tag agree before publishing.
```

with:

```markdown
- Release metadata and tag agree before publishing; for tag creation, tag push,
  publish approval, post-tag smoke, post-publish verification, and no-backfill
  policy, follow `agent-operating-manual/25-change-discipline.md` §3.2 Release
  tag / publish lifecycle discipline.
```

- [ ] **Step 3: Add a short README lifecycle pointer**

In `README.md`, after:

```markdown
git tag `vX.Y.Z` 是唯一版本來源；`.claude-plugin/*.json` version 必須同號
（install.sh source gate 與 `tests/install-smoke.sh` 兩處把關）。
```

add:

```markdown
Release sequencing stays approval-bound: metadata bump, annotated tag creation,
tag push, publish inventory, and post-tag / post-publish smoke follow
`skills/agent-operating-manual/25-change-discipline.md` §3.2.
```

- [ ] **Step 4: Bump plugin metadata to 0.5.6**

Replace `.claude-plugin/plugin.json` with:

```json
{
  "name": "agent-skills",
  "version": "0.5.6",
  "description": "Portable agent doctrine skills: agent-operating-manual (dispatch economy), handoff-relay (handoff / approval trigger surface), multi-angle-review (adversarial review pipeline), optional work-discipline (scope / simplicity / verification guardrails), and optional skill-authoring.",
  "skills": [
    "./skills/"
  ]
}
```

In `.claude-plugin/marketplace.json`, replace the plugin object version with:

```json
      "version": "0.5.6",
```

Do not change `source`, `strict`, `category`, owner metadata, or descriptions in
this task.

- [ ] **Step 5: Update ROADMAP landed entry and solved release row**

In `ROADMAP.md`, after the v0.5.5 Landed entry, add:

```markdown
- v0.5.6: release tag / publish lifecycle discipline defines metadata-train,
  reviewed-candidate, annotated-tag, tag-push, publish-inventory, post-tag /
  post-publish smoke, exact approval, no-backfill, and terminal closeout gates
  while leaving public PR discipline, private plan artifact boundary, post-push
  no-action examples, worker lifecycle, ATK mechanism, and retrieval open.
```

Remove this now-solved candidate lane only if no other release-lifecycle row
remains in that lane:

```markdown
- **Release Lifecycle Gap:** `Release tag / publish lifecycle discipline`. This
  lane should later define metadata bump, push, tag, publish, version
  consistency, post-tag / post-publish smoke, and exact approval gates as a
  separate irreversible-action lifecycle.
```

On the approved base, this is the only row in that lane, so remove the lane.

Remove this solved row from the Extraction Candidates table:

```markdown
| agent-skills doctrine | Release tag / publish lifecycle discipline | agent-skills | Existing guardrails cover metadata / tag consistency and approval-bound tag identifiers, but no lifecycle owns metadata bump, push, tag, publish, post-tag / post-publish smoke, and exact approval gates as one irreversible-action flow. |
```

Do not remove these rows:

```markdown
| agent-skills doctrine / release process | Public repo PR / release train discipline | agent-skills | Direct-main trains through `9ebdfce` should not be rewritten, but future public-repo work needs a branch / PR / review / squash-or-release-commit lifecycle and a clear rule for when main closeout should be version-only versus evidence-bearing. |
| agent-skills doctrine / artifact boundary | Private superpowers plan artifact boundary | agent-skills / private planning repo | Public specs and summaries can live here, but detailed superpowers plans, review paste blocks, local paths, and private evidence may belong in a private planning or audit repo; define the boundary before moving files. |
| agent-skills doctrine | Post-push complete-no-action-needed closeout examples | agent-skills | Recent push closeout discussion showed agents can omit the no-action terminal status when a push truly has no remaining user or agent action; decide whether examples belong in handoff-relay, `10-model-dispatch.md`, or release lifecycle after the skill-surface audit. |
| agent-skills doctrine | Branch / worker lifecycle hygiene | agent-skills | Separate from Shared checkout concurrency etiquette: the existing row covers simultaneous editing in shared checkouts; this covers worker spawn / wait / consume / close, concurrency caps, post-merge push state, and cleanup of merged worktrees / local branches after scoped work reaches review or merge; any validator mechanism belongs with ATK. |
```

- [ ] **Step 6: Run smoke and token checks**

Run:

```bash
bash tests/install-smoke.sh
for token in \
  'Release Tag / Publish Lifecycle Discipline' \
  'approve create annotated tag' \
  'approve push tag' \
  'Post-tag smoke' \
  'Post-publish verification' \
  'Metadata bump approval does not authorize tag creation' \
  'Release tag / publish lifecycle discipline' \
  '0.5.6' \
  'v0.5.6' \
  'Public repo PR / release train discipline' \
  'Private superpowers plan artifact boundary' \
  'Post-push complete-no-action-needed closeout examples' \
  'Branch / worker lifecycle hygiene'
do
  rg -ni "$token" skills README.md ROADMAP.md tests .claude-plugin
done
```

Expected:

- `bash tests/install-smoke.sh` exits `0` with `install smoke ok`.
- Every token search exits `0`.
- `Public repo PR / release train discipline`,
  `Private superpowers plan artifact boundary`,
  `Post-push complete-no-action-needed closeout examples`, and
  `Branch / worker lifecycle hygiene` still hit `ROADMAP.md`.

- [ ] **Step 7: Commit implementation and checkbox update**

Run:

```bash
git add \
  skills/agent-operating-manual/25-change-discipline.md \
  skills/skill-authoring/SKILL.md \
  README.md \
  tests/install-smoke.sh \
  .claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  ROADMAP.md \
  docs/superpowers/plans/2026-07-07-release-tag-publish-lifecycle.md
git commit -m "docs: add release lifecycle discipline"
```

Expected: commit succeeds. No tag, tag push, publish, merge, or remote push is
performed.

---

### Task 3: Full Verification And Review Handoff

**Files:**
- Modify: `docs/superpowers/plans/2026-07-07-release-tag-publish-lifecycle.md`

**Interfaces:**
- Consumes: implementation from Tasks 1 and 2.
- Produces: checked plan boxes, verification evidence, and a full-review
  handoff. Produces no tag, tag push, publish, merge, remote push, or adopting
  repo install.

- [ ] **Step 1: Run source closeout and repo checks**

Run:

```bash
agent-trigger-kit session-check --closeout
git diff --check
git diff --check ea9990c..HEAD
git status --porcelain
bash tests/install-smoke.sh
```

Expected:

- `agent-trigger-kit session-check --closeout` exits `1` only with
  `agent-skills: plugin directory missing`; plugin-version-freshness may be
  indeterminate from the same root-source cause; no unmarked outcome events.
- `git diff --check` exits `0`.
- `git diff --check ea9990c..HEAD` exits `0`.
- `git status --porcelain` shows only this plan file until the verification
  checkbox update is committed.
- `bash tests/install-smoke.sh` exits `0` with `install smoke ok`.

- [ ] **Step 2: Verify scope boundaries**

Run:

```bash
git diff --name-status ea9990c..HEAD
git tag --points-at HEAD
git log --oneline --decorate -8
```

Expected:

- The changed-file list contains only the approved spec file
  `docs/superpowers/specs/2026-07-07-release-tag-publish-lifecycle-design.md`,
  this plan, `skills/agent-operating-manual/25-change-discipline.md`,
  `skills/skill-authoring/SKILL.md`, `README.md`, `tests/install-smoke.sh`,
  `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and
  `ROADMAP.md`.
- `git tag --points-at HEAD` prints nothing.
- `git log --oneline --decorate -8` shows local branch commits only; no merge
  commit, tag, or publish action.

- [ ] **Step 3: Verify lifecycle and version anchors directly**

Run:

```bash
rg -n '"version": "0.5.6"' .claude-plugin/plugin.json .claude-plugin/marketplace.json
rg -n 'Release Tag / Publish Lifecycle Discipline|approve create annotated tag|approve push tag|Post-tag smoke|Post-publish verification|Metadata bump approval does not authorize tag creation' \
  skills/agent-operating-manual/25-change-discipline.md tests/install-smoke.sh
rg -n 'Release tag / publish lifecycle discipline' skills/skill-authoring/SKILL.md README.md ROADMAP.md
```

Expected:

- Both manifest files show `0.5.6`.
- Lifecycle title, tag-create approval, tag-push approval, post-tag smoke,
  post-publish verification, and approval non-transfer rule hit the canonical
  doctrine and smoke coverage.
- The authoring checklist, README, and ROADMAP all hit
  `Release tag / publish lifecycle discipline`.

- [ ] **Step 4: Verify token coverage without plan self-match**

Run:

```bash
for token in \
  'Release Tag / Publish Lifecycle Discipline' \
  'approve create annotated tag' \
  'approve push tag' \
  'Post-tag smoke' \
  'Post-publish verification' \
  'Metadata bump approval does not authorize tag creation' \
  'Release tag / publish lifecycle discipline' \
  '0.5.6' \
  'v0.5.6' \
  'Public repo PR / release train discipline' \
  'Private superpowers plan artifact boundary' \
  'Post-push complete-no-action-needed closeout examples' \
  'Branch / worker lifecycle hygiene'
do
  printf '%s: ' "$token"
  rg -ni "$token" skills README.md ROADMAP.md tests .claude-plugin | wc -l
done
```

Expected:

- Every printed count is greater than `0`.
- Do not include `docs/superpowers/plans` in this scan; a plan self-match must
  not mask missing implementation text.
- Preserve the printed counts in the implementation review handoff's author
  verification block.

- [ ] **Step 5: Commit verification checkbox update**

Run:

```bash
git add docs/superpowers/plans/2026-07-07-release-tag-publish-lifecycle.md
git commit -m "docs: mark release lifecycle verification"
```

Expected: commit succeeds if this plan file changed only by checkbox updates.
If no checkbox update remains because a previous task already committed it, do
not create an empty commit; record that in the handoff.

- [ ] **Step 6: Emit review-needed handoff with author verification**

Before emitting the handoff, run:

```bash
git rev-parse --short HEAD
git log -1 --format=%h -- docs/superpowers/plans/2026-07-07-release-tag-publish-lifecycle.md
```

Use the first output as the implementation head. Use the second output as the
plan commit. Set `Prev reviewed tip` to the implementation-plan commit that
most recently passed plan/rule-review or fix-confirmation. Do not leave
descriptive placeholders in the emitted handoff.

The emitted handoff must include an `Author verification:` paragraph before the
relay block with these facts:

- `tests/install-smoke.sh` result and exact success line.
- `git diff --check` and `git diff --check ea9990c..HEAD` results.
- Manifest version proof for both manifests.
- `git tag --points-at HEAD` result proving no tag points at the implementation
  head.
- Token scan counts from Step 4.
- `agent-trigger-kit session-check --closeout` result and accepted boundary.

Then emit one `text` fenced relay block with these field values:

- `Status: review-needed`
- `Target repo: /Users/jackchou/Desktop/agent-skills`
- `Target:` names `spec/v0.5.6-release-lifecycle`, the actual implementation
  head, base `ea9990c`, spec `036c50e`, and plan commit
- `Required user text: n/a`
- `User action: self-review -> to-reviewer`
- `Next agent action:` asks for full review of release lifecycle doctrine,
  canonical-home boundaries, tag/tag-push/publish exact approval separation,
  post-tag / post-publish verification semantics, metadata `0.5.6`, ROADMAP
  row handling, smoke/token evidence, and absence of tag / publish / push /
  merge authorization
- `Blockers: none`
- `Accepted residuals:` carries the public PR discipline candidate, private plan
  artifact boundary candidate, no-retroactive-backfill decision, ATK root-source
  boundary, and `.claude/worktrees` hygiene residue with durable owners
- `Review: full`
- `Focus:` asks the reviewer to verify the lifecycle state machine, exact
  approval non-transfer rules, metadata bump without release authorization,
  ROADMAP neighbor preservation, no tag at HEAD, and author verification
  evidence
- `Prev reviewed tip:` is the actual implementation-plan commit that most
  recently passed plan/rule-review or fix-confirmation

Expected:

- The handoff uses `Status: review-needed`.
- No `Execution route:` block is present because this is a review handoff.
- `Review:` is `full`, not `none-FYI`.
- The handoff contains author verification evidence, not only a summary.
