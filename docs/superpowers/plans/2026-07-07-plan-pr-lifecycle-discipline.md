# Plan / PR Lifecycle Discipline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved v0.5.2 Plan / PR lifecycle discipline doctrine, smoke coverage, roadmap update, deferred context-loading tracker, and plugin metadata bump.

**Architecture:** This is a markdown-doctrine release. `tests/install-smoke.sh` first protects the installed copy, `25-change-discipline.md` becomes the canonical lifecycle home, `10-model-dispatch.md` only cross-references the lifecycle home, and `ROADMAP.md` plus plugin metadata record the release state.

**Tech Stack:** Bash smoke tests, markdown doctrine files, JSON plugin metadata.

## Global Constraints

- Approved spec: `docs/superpowers/specs/2026-07-07-plan-pr-lifecycle-discipline-design.md` at `2fd9e32`.
- Reviewer advisory: in `25-change-discipline.md`, cross-reference `10-model-dispatch.md` §3.1 instead of restating the relay-block rule in the lifecycle section.
- Reviewer advisory: make the final token scan case-insensitive, or include lowercase phrasing coverage; this plan uses `rg -ni`.
- Add one canonical Plan / PR lifecycle section to `skills/agent-operating-manual/25-change-discipline.md`.
- Clarify branch/head identity before implementation and review.
- Require implementation closeout to stop at review / PR handoff.
- Clarify that review-passed is not merge approval.
- Require exact merge approval to name the PR/head or local branch/head.
- Require pre-merge recheck before executing merge.
- Define squash merge evidence expectations, including tree-equivalence when available.
- Add a compact `10-model-dispatch.md` cross-reference to the lifecycle section.
- Add install-smoke tokens for adopted repos.
- Add a v0.5.2 landed entry and retire the Plan / PR lifecycle candidate.
- Preserve `Branch / worker lifecycle hygiene`.
- Add a deferred `Skill context loading / retrieval strategy` ROADMAP candidate.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to `0.5.2` during implementation.
- Do not add, remove, or rename relay `Status:` values.
- Do not change the `Review:` enum.
- Do not change Agent Trigger Kit validators, session-check, hooks, or outcome taxonomy.
- Do not implement vector search, MCP indexing, retrieval-augmented skill loading, or skill chunking machinery.
- Do not define worker lifecycle, worktree cleanup, branch cleanup, concurrency caps, or post-merge push-state cleanup.
- Do not define release tagging, publishing, deploys, or runtime actions.
- Do not edit adopting repos or generated imported copies.
- Do not release tag or publish `v0.5.2`.
- In this source repo, `agent-trigger-kit session-check` may exit 1 only for `agent-skills: plugin directory missing`; when a relay signal is present, carry `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

---

## File Structure

- Modify `tests/install-smoke.sh`: add imported-copy smoke tokens for the new change-discipline section and the `10-model-dispatch.md` cross-reference.
- Modify `skills/agent-operating-manual/25-change-discipline.md`: add the canonical `Plan / PR Lifecycle Discipline` section after `Approval-Bound Identifiers`.
- Modify `skills/agent-operating-manual/10-model-dispatch.md`: add a compact cross-reference to `25-change-discipline.md` §3.1 without copying the relay block or adding fields.
- Modify `ROADMAP.md`: add the v0.5.2 landed entry, remove the `Plan / PR lifecycle discipline` candidate, preserve `Branch / worker lifecycle hygiene`, and add `Skill context loading / retrieval strategy`.
- Modify `.claude-plugin/plugin.json`: bump `"version": "0.5.1"` to `"version": "0.5.2"`.
- Modify `.claude-plugin/marketplace.json`: bump the plugin `"version": "0.5.1"` to `"version": "0.5.2"`.
- Modify this plan file only to mark execution progress.

---

### Task 1: Smoke Coverage First

**Files:**
- Modify: `tests/install-smoke.sh`
- Modify: `docs/superpowers/plans/2026-07-07-plan-pr-lifecycle-discipline.md`

**Interfaces:**
- Consumes: installed imported skill paths already used by `tests/install-smoke.sh`.
- Produces: failing smoke coverage that Task 2 satisfies through doctrine and metadata updates.

- [x] **Step 1: Add imported Plan / PR lifecycle smoke tokens**

In `tests/install-smoke.sh`, inside the `for f in CLAUDE.md AGENTS.md GEMINI.md; do` loop, after the existing assertion:

```bash
  grep -Fq 'exact wording lives in Required user text' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing approval-text home rule"
```

add:

```bash
  grep -Fq 'Plan / PR Lifecycle Discipline' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing Plan / PR lifecycle section"
  grep -Fq 'branch-first' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing branch-first lifecycle rule"
  grep -Fq 'PR stop' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing PR stop lifecycle rule"
  grep -Fq 'review-passed is not merge approval' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing review-passed merge boundary"
  grep -Fq 'pre-merge recheck' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing pre-merge recheck"
  grep -Fq 'squash merge evidence' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing squash merge evidence"
  grep -Fq 'tree equivalence' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
    || fail "$f imported change discipline missing tree equivalence evidence"
  grep -Fq 'Plan / PR Lifecycle Discipline' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing Plan / PR lifecycle cross-reference"
```

Expected: the smoke now protects the new lifecycle home and the relay cross-reference after install.

- [x] **Step 2: Run the focused smoke and confirm it fails red**

Run:

```bash
tests/install-smoke.sh
```

Expected: exit `1` with:

```text
SMOKE FAIL: CLAUDE.md imported change discipline missing Plan / PR lifecycle section
```

If the first missing token is a later Task 1 token, continue because the new smoke is still red for the intended reason.

- [x] **Step 3: Commit the failing smoke**

Run:

```bash
git add tests/install-smoke.sh docs/superpowers/plans/2026-07-07-plan-pr-lifecycle-discipline.md
git commit -m "test: add red plan pr lifecycle smoke coverage"
```

Expected: commit succeeds with only `tests/install-smoke.sh` and this plan file changed. The repository remains red until Task 2 implements the doctrine.

---

### Task 2: Doctrine, Roadmap, and Metadata

**Files:**
- Modify: `skills/agent-operating-manual/25-change-discipline.md`
- Modify: `skills/agent-operating-manual/10-model-dispatch.md`
- Modify: `ROADMAP.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `docs/superpowers/plans/2026-07-07-plan-pr-lifecycle-discipline.md`

**Interfaces:**
- Consumes: failing smoke tokens from Task 1.
- Produces: v0.5.2 doctrine text, release metadata, roadmap state, and a green focused smoke.

- [x] **Step 1: Add the Plan / PR lifecycle section**

In `skills/agent-operating-manual/25-change-discipline.md`, after the `Approval-Bound Identifiers` section ending with:

```markdown
**Fail condition**：agent infers approval from tone, old approval, nearby conversation, or a different object.
```

add:

```markdown
## §3.1 Plan / PR Lifecycle Discipline

Use this lifecycle for work expected to become a PR, merge, release PR, or
other approval-bound change. This section owns object identity and stop points.
Relay fields, exact approval text, and copy-block formatting remain in
[`10-model-dispatch.md`](10-model-dispatch.md) §3.1; do not fork those rules
here.

1. **branch-first / head-first before implementation**: Establish a concrete
   work branch and current head before substantive implementation when the
   harness permits it. If the environment is a detached head, externally managed
   worktree, or single-checkout source repo, name the current head and the
   constraint instead of pretending branch isolation exists.
2. **plan / spec gate before implementation**: Normative doctrine, relay,
   review, approval, release, and entrypoint changes remain plan-first. When
   user approval is needed to begin implementation or execution, stop at the
   exact-text approval gate defined by `10-model-dispatch.md` §3.1.
3. **PR stop after implementation**: After scoped implementation and agreed
   verification, stop at PR or review handoff. The author does not merge,
   squash merge, tag, publish, deploy, or clean up branches as part of
   implementation closeout unless the user gave a separate approval-bound
   command for that exact action and identifier.
4. **review-passed is not merge approval**: A passed full review or
   fix-confirmation satisfies only the review gate. Merge approval is a separate
   exact-text gate and must name the concrete object, such as `PR #123 at
   <head-sha>` or `local branch <name> at <head-sha>`.
5. **pre-merge recheck**: Before executing an approved merge, re-check that the
   current PR/head still matches the approved identifier, review or
   fix-confirmation still applies, required CI / smoke / repo gates still pass
   or remain explicitly waived, mergeability is current, and accepted residuals
   have durable owners. If the head changed, approval is stale.
6. **squash merge evidence**: Squash merge is allowed only after the pre-merge
   recheck and exact approval. The merge closeout must preserve proof that the
   executed merge corresponds to the reviewed and approved content. Prefer a
   tree equivalence probe: the squash merge commit tree should match the
   approved PR/head tree. If the environment cannot check tree equivalence,
   disclose the gap and name the remaining evidence.

This lifecycle does not define release tagging, publishing, deploys, runtime
actions, worker spawn / wait / consume / close, concurrency caps, worktree
cleanup, local branch cleanup, post-merge push-state cleanup, Agent Trigger Kit
validators, hooks, or outcome taxonomy.
```

Expected: `25-change-discipline.md` becomes the canonical lifecycle home and references the relay-block rule instead of restating it.

- [x] **Step 2: Add the relay cross-reference**

In `skills/agent-operating-manual/10-model-dispatch.md`, after the paragraph ending with:

```text
不能授權 execution；等 review / fix-confirmation 通過後，再送
`ready-for-user-approval` 或 `ready-for-continuation`。
```

add:

```text
Plan / PR lifecycle routing：branch-first、PR stop、review-passed is not merge
approval、pre-merge recheck、squash merge evidence 等 object-identity /
merge stop-point 規則的 canonical home 是 `25-change-discipline.md` §3.1
`Plan / PR Lifecycle Discipline`。本 §3.1 只維護 relay fields、approval text
home、copy-block formatting、Status / User action coherence；不要在這裡重寫
PR lifecycle state machine。
```

Expected: `10-model-dispatch.md` points to the lifecycle home without adding relay fields, status values, or a local copy of the lifecycle state machine.

- [x] **Step 3: Update ROADMAP landed and candidate rows**

In `ROADMAP.md`, after the v0.5.1 landed entry:

```markdown
- v0.5.1: review continuation handoff tightening adds the narrow
  `ready-for-continuation` relay status, widens `ready-for-user-approval` to all
  exact-text approval gates, preserves pre-spec / design-framing conclusions, and
  tightens review deliverable copy fields without adding worker lifecycle or
  Plan / PR lifecycle doctrine.
```

add:

```markdown
- v0.5.2: Plan / PR lifecycle discipline adds branch/head identity, PR stop,
  review-passed-is-not-merge-approval, pre-merge recheck, and squash merge
  evidence while keeping worker lifecycle, release publishing, and retrieval
  strategy deferred.
```

Then remove this extraction-candidate row:

```markdown
| agent-skills doctrine | Plan / PR lifecycle discipline: branch-first, PR stop, explicit approval, squash merge | agent-skills | High-value shared state machine; needs careful wording across consumer repos. |
```

After the `Plan/spec lifecycle header convention text` row, add:

```markdown
| agent-skills doctrine / tooling | Skill context loading / retrieval strategy | agent-skills / Agent Trigger Kit / optional MCP tooling | The Agent Operating Manual is large enough that agents may fail to apply all loaded rules under context pressure; investigate split, routing, retrieval, vector-index, or MCP-backed loading strategy separately so v0.5.2 remains lifecycle-only. |
```

Expected: the v0.5.2 landed entry exists, the Plan / PR lifecycle candidate is retired, `Branch / worker lifecycle hygiene` remains, and the context-loading concern is durable but deferred.

- [x] **Step 4: Bump plugin metadata**

In `.claude-plugin/plugin.json`, replace:

```json
  "version": "0.5.1",
```

with:

```json
  "version": "0.5.2",
```

In `.claude-plugin/marketplace.json`, replace the plugin entry version:

```json
      "version": "0.5.1",
```

with:

```json
      "version": "0.5.2",
```

Expected: both plugin metadata files report `0.5.2`.

- [x] **Step 5: Run focused smoke and token scan**

Run:

```bash
tests/install-smoke.sh
```

Expected: output is empty and exit code is `0`.

Run the reviewer-advised case-insensitive token scan:

```bash
rg -ni 'Plan / PR Lifecycle Discipline|branch-first|PR stop|review-passed is not merge approval|pre-merge recheck|squash merge evidence|tree equivalence|Skill context loading / retrieval strategy|Branch / worker lifecycle hygiene|v0\.5\.2|0\.5\.2' skills/agent-operating-manual ROADMAP.md tests .claude-plugin
```

Expected: output includes hits in `25-change-discipline.md`, `10-model-dispatch.md`, `tests/install-smoke.sh`, `ROADMAP.md`, `.claude-plugin/plugin.json`, and `.claude-plugin/marketplace.json`.

- [x] **Step 6: Commit doctrine, roadmap, metadata, and plan progress**

Run:

```bash
git add skills/agent-operating-manual/25-change-discipline.md skills/agent-operating-manual/10-model-dispatch.md ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json docs/superpowers/plans/2026-07-07-plan-pr-lifecycle-discipline.md
git commit -m "docs: add plan pr lifecycle discipline"
```

Expected: commit succeeds with the doctrine, roadmap, metadata, and plan progress changes. `tests/install-smoke.sh` was already committed in Task 1.

---

### Task 3: Full Verification and Review Handoff

**Files:**
- Modify: `docs/superpowers/plans/2026-07-07-plan-pr-lifecycle-discipline.md`

**Interfaces:**
- Consumes: Task 1 smoke coverage and Task 2 implementation.
- Produces: final verification evidence, updated plan checkboxes, and a review-ready relay block.

- [ ] **Step 1: Run source-repo health check**

Run:

```bash
agent-trigger-kit session-check
```

Expected: exit `1` only for:

```text
agent-skills: plugin directory missing
```

Expected: no unmarked outcome events. Record this accepted residual in the final relay.

- [ ] **Step 2: Run all required smoke and whitespace gates**

Run:

```bash
tests/install-smoke.sh
tests/source-entrypoint-smoke.sh
tests/cross-repo-reference-map-smoke.sh
git diff --check
git diff --check "$(git merge-base HEAD origin/main)"..HEAD
```

Expected:

```text
source entrypoint smoke ok
cross-repo reference map smoke ok
```

Expected: `tests/install-smoke.sh`, both `git diff --check` commands, and all smoke scripts exit `0`.

- [ ] **Step 3: Run final token and status checks**

Run:

```bash
rg -ni 'Plan / PR Lifecycle Discipline|branch-first|PR stop|review-passed is not merge approval|pre-merge recheck|squash merge evidence|tree equivalence|Skill context loading / retrieval strategy|Branch / worker lifecycle hygiene|v0\.5\.2|0\.5\.2' skills/agent-operating-manual ROADMAP.md tests .claude-plugin
git status -sb
```

Expected: token scan includes lifecycle doctrine, cross-reference, smoke tokens, roadmap landed/deferred rows, and both metadata versions. `git status -sb` shows only plan-file checkbox progress before the final plan-progress commit.

- [ ] **Step 4: Commit final plan progress**

Run:

```bash
git add docs/superpowers/plans/2026-07-07-plan-pr-lifecycle-discipline.md
git commit -m "docs: mark plan pr lifecycle verification"
```

Expected: commit succeeds with only this plan file changed.

- [ ] **Step 5: Prepare final review relay**

Send a full-context copy block to the user with this exact shape, replacing `<HEAD>` with the actual commit hash and listing the verification commands that passed:

```text
Status: review-needed
Target repo: /Users/jackchou/Desktop/agent-skills
Target: Plan / PR lifecycle discipline implementation @ <HEAD>
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review the v0.5.2 implementation against the approved spec and plan, including 25-change-discipline lifecycle home, 10-model-dispatch cross-reference without relay-rule restatement, install-smoke coverage, ROADMAP landed/deferred rows, metadata 0.5.2, case-insensitive token scan, and full verification output
Blockers: none
Accepted residuals: ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up

Review: full
Focus: Branch/head object identity, PR stop, review-passed-is-not-merge-approval, pre-merge recheck, squash merge evidence, deferred skill context-loading strategy, and absence of worker lifecycle / release publishing / retrieval implementation scope creep
Prev reviewed tip: n/a
```

Expected: implementation does not merge, tag, publish, edit adopting repos, or execute cleanup. The next step is full review.

---

## Plan Self-Review

- Spec coverage: Task 1 covers installed-copy smoke. Task 2 covers the canonical lifecycle section, the `10-model-dispatch.md` cross-reference, roadmap landed/candidate changes, metadata bump, reviewer advisory about cross-reference over relay restatement, and reviewer advisory about case-insensitive token scan. Task 3 covers the full verification set and final review handoff.
- Red-flag scan: this plan intentionally contains no unresolved markers or unspecified implementation steps.
- Type / token consistency: lifecycle tokens are consistent across test, doctrine, roadmap, and scan: `Plan / PR Lifecycle Discipline`, `branch-first`, `PR stop`, `review-passed is not merge approval`, `pre-merge recheck`, `squash merge evidence`, `tree equivalence`, `Skill context loading / retrieval strategy`, `Branch / worker lifecycle hygiene`, `v0.5.2`, and `0.5.2`.
- Scope check: the plan does not add relay status values, change the `Review:` enum, define worker/worktree/branch cleanup lifecycle, implement retrieval/vector tooling, define release publishing, alter ATK mechanisms, edit adopting repos, tag, or publish.
