# Public PR / Release Train Discipline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved v0.5.8 public PR / release train discipline by adding doctrine, smoke coverage, metadata 0.5.8, ROADMAP closeout, and a durable pending-batched-release record.

**Architecture:** Keep object-identity doctrine in `skills/agent-operating-manual/25-change-discipline.md` as a new §3.3 that extends §3.1 and enters §3.2 by pointer. Keep relay fields in `10-model-dispatch.md`; do not fork `Status:` semantics. Dogfood the new public-PR rule at the integration boundary: implementation ends at full review, then the next gate should choose hosted PR push/open or a named local equivalent rather than another default fast-forward merge to public `main`.

**Tech Stack:** Markdown doctrine, Bash install smoke, JSON plugin manifests, Git.

## Global Constraints

- Approved spec: `docs/superpowers/specs/2026-07-07-public-pr-release-train-discipline-design.md` at `2cbb3dd`.
- Base: `5677e4ad043341650aedc60ac34e34b642da3b05` (`origin/main`).
- Effective contract remains merged `main` plus AGENTS.md; branch-local text is proposal until reviewed and merged.
- Extend `25-change-discipline.md` §3.1 / §3.2; do not duplicate `10-model-dispatch.md` relay field or `Status:` enum semantics.
- Implementation advisory A: state 4 must point to §3.1 rule 4 for review-is-not-merge-approval instead of restating the rule.
- Implementation advisory B: durably record the pending batched release for v0.5.7 plus v0.5.8 install-facing content in ROADMAP or residuals.
- Because this train changes installed default doctrine and smoke coverage, bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to `0.5.8`. This metadata bump does not authorize tag creation, tag push, publish, merge, push, branch cleanup, or adopting-repo install.
- Commit the red smoke test before implementation. Commit implementation before green smoke because `tests/install-smoke.sh` clones committed HEAD as its install source.
- Do not stage plan checkbox ticks in Task 1 or Task 2 commits. Plan checkbox ticks ride Task 3.
- Do not rewrite public history through `5677e4a`.
- Do not open a PR, push this branch, merge, fast-forward main, squash, create a tag, push a tag, publish, clean up branches, move `docs/superpowers/**`, create a private planning repo, create a portable release-governance skill, edit adopting repos, or edit generated imported copies in this implementation.
- Carry the ATK residual when relay text is emitted: `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

---

## File Structure

- Modify: `tests/install-smoke.sh`
  - Adds red/green coverage that the installed default `agent-operating-manual` includes the public PR / release train discipline and closeout examples.
- Modify: `skills/agent-operating-manual/25-change-discipline.md`
  - Adds §3.3 `Public PR / Release Train Discipline` beside §3.1 and §3.2.
- Modify: `.claude-plugin/plugin.json`
  - Bumps plugin manifest version from `0.5.7` to `0.5.8`.
- Modify: `.claude-plugin/marketplace.json`
  - Bumps marketplace plugin version from `0.5.7` to `0.5.8`.
- Modify: `ROADMAP.md`
  - Adds v0.5.8 Landed entry, records the pending batched release, retires the two absorbed rows, and preserves unrelated candidates.
- Modify: `docs/superpowers/plans/2026-07-07-public-pr-release-train-discipline.md`
  - Tracks execution checkboxes only; checkbox changes are committed in Task 3.

---

### Task 1: Red Smoke Coverage For Public PR Discipline

**Files:**
- Modify: `tests/install-smoke.sh`

**Interfaces:**
- Consumes: existing default-install `25-change-discipline.md` greps around the release lifecycle assertions.
- Produces: smoke assertions later satisfied by `25-change-discipline.md` §3.3.

- [x] **Step 1: Add failing assertions after the release lifecycle smoke greps**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: tests/install-smoke.sh
@@
   grep -Fq 'Post-publish verification' \
     "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
     || fail "$f imported change discipline missing post-publish verification"
   grep -Fq 'Metadata bump approval does not authorize tag creation' \
     "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
     || fail "$f imported change discipline missing approval non-transfer rule"
+  grep -Fq 'Public PR / Release Train Discipline' \
+    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
+    || fail "$f imported change discipline missing public PR release train section"
+  grep -Fq 'public train branch' \
+    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
+    || fail "$f imported change discipline missing public train branch"
+  grep -Fq 'hosted PR' \
+    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
+    || fail "$f imported change discipline missing hosted PR path"
+  grep -Fq 'local equivalent' \
+    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
+    || fail "$f imported change discipline missing local equivalent path"
+  grep -Fq 'version-only' \
+    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
+    || fail "$f imported change discipline missing version-only evidence rule"
+  grep -Fq 'release choice' \
+    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
+    || fail "$f imported change discipline missing release choice rule"
+  grep -Fq 'complete-no-action-needed means no release remains' \
+    "$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md" \
+    || fail "$f imported change discipline missing post-push no-action example"
   grep -Fq 'Plan / PR Lifecycle Discipline' \
     "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
     || fail "$f imported manual missing Plan / PR lifecycle cross-reference"
*** End Patch
```

- [x] **Step 2: Run the red smoke**

Run:

```bash
bash tests/install-smoke.sh
```

Expected: exit nonzero with first failure:

```text
SMOKE FAIL: CLAUDE.md imported change discipline missing public PR release train section
```

- [x] **Step 3: Commit red smoke only**

Run:

```bash
git add tests/install-smoke.sh
git commit -m "test: cover public PR release train discipline"
```

Expected:

- Commit succeeds.
- No doctrine, metadata, ROADMAP, or plan checkbox files are staged in this commit.

---

### Task 2: Implement Doctrine, Metadata, And ROADMAP

**Files:**
- Modify: `skills/agent-operating-manual/25-change-discipline.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `ROADMAP.md`

**Interfaces:**
- Consumes: red smoke assertions from Task 1.
- Produces: installed public PR / release train doctrine, metadata version `0.5.8`, and ROADMAP closeout with pending batched-release record.

- [x] **Step 1: Insert §3.3 public PR / release train doctrine before §4**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: skills/agent-operating-manual/25-change-discipline.md
@@
 Do not backfill missing tags for already-public trains unless a separate
 reviewed release-repair plan authorizes that exact backfill. The normal path is
 to tag the reviewed release head with the current manifest version.

+## §3.3 Public PR / Release Train Discipline
+
+Use this lifecycle in public source repos where branch, PR, public `main`
+history, and release evidence are visible to adopters. It extends §3.1 and
+enters §3.2; relay fields, exact approval text placement, and copy-block shape
+remain in [`10-model-dispatch.md`](10-model-dispatch.md) §3.1.
+
+1. **public train branch**: substantive public-repo work starts on a named
+   branch with a named base commit. Normative doctrine, release, entrypoint,
+   installer, metadata, and public artifact changes remain plan-first. Direct
+   public `main` edits require an explicit emergency or tiny administrative
+   repair approval, and closeout must say why branch / PR routing did not
+   apply.
+2. **hosted PR or local equivalent**: when network and platform access allow
+   it, push the branch and open a hosted PR before merge. If the harness cannot
+   open a hosted PR, the local equivalent is a review handoff naming exact
+   branch, base, head, and range. Local-only work is still review-bound.
+3. **evidence-bearing PR**: keep public-safe specs, plans, review results,
+   smoke evidence, and author verification on the branch, in the PR body, in
+   the squash body, release notes, or another durable public record. Do not
+   publish raw private paths, raw local logs, or secret-like evidence.
+4. **public merge candidate**: after full review or fix-confirmation, follow
+   §3.1 rule 4 for exact merge approval naming the PR/head or local
+   branch/head. Do not restate or weaken that gate here.
+5. **merge shape chosen**: prefer hosted PR squash merge when the PR preserves
+   detailed evidence. Hosted rebase or merge commits are allowed when commit
+   granularity is intentionally public and each commit has a clear probe. A
+   local squash / release commit is allowed when hosted PR tooling is
+   unavailable; prove tree equivalence to the approved branch head or disclose
+   the verification gap. Fast-forwarding a multi-commit train into public
+   `main` is exceptional after this rule lands and must be explicitly chosen.
+6. **public main closeout**: after merge and push, verify remote `main` points
+   at the executed merge object.
+   `complete-no-action-needed means no release remains`, no next-agent action
+   remains, and all accepted residuals have owners. If install-facing metadata
+   changed, surface the release choice: direct §3.2 pre-tag approval, or an
+   explicit batched release train record.
+
+`version-only` public history is allowed only after evidence is durably
+captured elsewhere. A terse version commit, squash subject, or closeout cannot
+erase review, probe, approval, residual, or tree-equivalence evidence required
+by §2 and §3.1.
+
+Post-push examples:
+
+- No release remains: a docs-only PR is merged and pushed, remote `main`
+  matches the executed commit, no residuals remain, and
+  `Status: complete-no-action-needed` is correct.
+- Release choice remains: an install-facing PR is merged and pushed; stop at
+  direct §3.2 tag approval or record the batched release train before claiming
+  terminal closeout.
+- Review remains: a branch is pushed but review has not passed, so use
+  `Status: review-needed`.
+- Merge approval remains: full review passed but exact PR/head merge approval
+  has not been given, so use `Status: ready-for-user-approval` under
+  `10-model-dispatch.md` §3.1.
+
 ## §4 Public Evidence Hygiene

 Doctrine releases can cite evidence, but public evidence must be sanitized.
*** End Patch
```

- [x] **Step 2: Bump plugin metadata to 0.5.8**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: .claude-plugin/plugin.json
@@
-  "version": "0.5.7",
+  "version": "0.5.8",
*** Update File: .claude-plugin/marketplace.json
@@
-      "version": "0.5.7",
+      "version": "0.5.8",
*** End Patch
```

- [x] **Step 3: Update ROADMAP Landed entry, lane, and retired rows**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: ROADMAP.md
@@
 - v0.5.7: skill-surface split discipline adds Skill Surface Disposition,
   trigger-focused frontmatter guidance, default-vs-optional install reasoning,
   and batched release cadence for install-facing changes while preserving
   portable release-governance skill TDD, public PR discipline, private plan
   artifact boundary, post-push no-action examples, worker hygiene, ATK
   mechanism, and retrieval candidates as separate follow-ups.
+- v0.5.8: public PR / release train discipline adds public train branch,
+  hosted PR / local equivalent routing, merge-shape selection, version-only
+  evidence preservation, post-push closeout examples, and release choice
+  surfacing after install-facing merges. The release remains batched:
+  v0.5.7 and v0.5.8 install-facing content require a later §3.2 tag before
+  non-dev adopter delivery.
@@
-- **Public Artifact / Release Hygiene:** `Public repo PR / release train
-  discipline`, `Private superpowers plan artifact boundary`, and
-  `Post-push complete-no-action-needed closeout examples`, plus
-  `Portable release-governance skill TDD`. This lane owns public main-history
-  hygiene, private/public planning artifact boundaries, terminal closeout
-  examples, and portable release-skill extraction; it stays adjacent to but
-  separate from the release lifecycle state machine.
+- **Public Artifact / Release Hygiene:** `Private superpowers plan artifact
+  boundary` plus `Portable release-governance skill TDD`. This lane owns
+  private/public planning artifact boundaries and portable release-skill
+  extraction; it stays adjacent to but separate from the release lifecycle
+  state machine.
@@
-| agent-skills doctrine / release process | Public repo PR / release train discipline | agent-skills | Direct-main trains through `9ebdfce` should not be rewritten, but future public-repo work needs a branch / PR / review / squash-or-release-commit lifecycle and a clear rule for when main closeout should be version-only versus evidence-bearing. |
 | agent-skills doctrine / artifact boundary | Private superpowers plan artifact boundary | agent-skills / private planning repo | Public specs and summaries can live here, but detailed superpowers plans, review paste blocks, local paths, and private evidence may belong in a private planning or audit repo; define the boundary before moving files. |
-| agent-skills doctrine | Post-push complete-no-action-needed closeout examples | agent-skills | Recent push closeout discussion showed agents can omit the no-action terminal status when a push truly has no remaining user or agent action; decide whether examples belong in handoff-relay, `10-model-dispatch.md`, or release lifecycle after the skill-surface audit. |
 | agent-skills doctrine / portable skill | Portable release-governance skill TDD | agent-skills / future portable skill | The v0.5.6 lifecycle works for this repo, but broad reuse needs `writing-skills` RED/GREEN pressure scenarios across Git-tag-only, hosted release, package registry, plugin marketplace, and no-publish-surface repos before extracting a portable release skill. |
*** End Patch
```

- [x] **Step 4: Inspect implementation diff before committing**

Run:

```bash
git diff -- skills/agent-operating-manual/25-change-discipline.md .claude-plugin/plugin.json .claude-plugin/marketplace.json ROADMAP.md
```

Expected:

- `25-change-discipline.md` has new `§3.3 Public PR / Release Train Discipline`.
- State 4 points to `§3.1 rule 4` and does not restate the review-is-not-merge-approval paragraph.
- The new doctrine contains `public train branch`, `hosted PR`, `local equivalent`, `version-only`, `release choice`, and `complete-no-action-needed means no release remains`.
- Both manifests say `0.5.8`.
- ROADMAP has one `v0.5.8` Landed entry and records `v0.5.7 and v0.5.8 install-facing content`.
- ROADMAP no longer contains the candidate rows `Public repo PR / release train discipline` or `Post-push complete-no-action-needed closeout examples`.
- ROADMAP still contains `Private superpowers plan artifact boundary`, `Portable release-governance skill TDD`, `Branch / worker lifecycle hygiene`, `Skill context loading / retrieval strategy`, and `F2 handoff-contract file split`.

- [x] **Step 5: Commit implementation before green smoke**

Run:

```bash
git add skills/agent-operating-manual/25-change-discipline.md .claude-plugin/plugin.json .claude-plugin/marketplace.json ROADMAP.md
git commit -m "docs: add public PR release train discipline"
```

Expected:

- Commit succeeds.
- No tag, tag push, publish, merge, remote push, branch cleanup, or adopting-repo install occurs.

- [x] **Step 6: Run green smoke against committed HEAD**

Run:

```bash
bash tests/install-smoke.sh
```

Expected final line:

```text
install smoke ok
```

- [x] **Step 7: Run no-plan-self-match token scan**

Run:

```bash
for token in \
  'Public PR / Release Train Discipline' \
  'public train branch' \
  'hosted PR' \
  'local equivalent' \
  'version-only' \
  'release choice' \
  'complete-no-action-needed means no release remains' \
  'v0.5.7 and v0.5.8 install-facing content' \
  'Private superpowers plan artifact boundary' \
  'Portable release-governance skill TDD' \
  '0.5.8' \
  'v0.5.8'
do
  count="$(rg -ni --fixed-strings "$token" skills/ ROADMAP.md tests .claude-plugin | wc -l | tr -d ' ')"
  printf '%s\t%s\n' "$count" "$token"
  test "$count" -gt 0
done
```

Expected:

- Every printed count is greater than zero.
- Scan paths exclude `docs/superpowers/plans/` and `docs/superpowers/specs/`.

---

### Task 3: Final Verification And Review Handoff

**Files:**
- Modify: `docs/superpowers/plans/2026-07-07-public-pr-release-train-discipline.md`

**Interfaces:**
- Consumes: Task 1 red smoke commit and Task 2 implementation commit.
- Produces: verification-mark commit and a full-review handoff.

- [x] **Step 1: Confirm the expected branch range files**

Run:

```bash
git diff --name-only origin/main..HEAD
```

Expected set, order may differ:

```text
.claude-plugin/marketplace.json
.claude-plugin/plugin.json
ROADMAP.md
docs/superpowers/plans/2026-07-07-public-pr-release-train-discipline.md
docs/superpowers/specs/2026-07-07-public-pr-release-train-discipline-design.md
skills/agent-operating-manual/25-change-discipline.md
tests/install-smoke.sh
```

- [x] **Step 2: Run full range whitespace check**

Run:

```bash
git diff --check origin/main..HEAD
```

Expected: exit 0, no output.

- [x] **Step 3: Run placeholder scan on changed live surfaces**

Run:

```bash
rg -n '[T]BD|[T]ODO|[P]LACEHOLDER|[i]mplement later|[f]ill in details|[s]imilar to Task|[A]dd appropriate|[W]rite tests for the above' \
  docs/superpowers/plans/2026-07-07-public-pr-release-train-discipline.md \
  docs/superpowers/specs/2026-07-07-public-pr-release-train-discipline-design.md \
  skills/agent-operating-manual/25-change-discipline.md \
  tests/install-smoke.sh \
  ROADMAP.md
```

Expected: exit 1, no matches.

- [x] **Step 4: Re-run install smoke**

Run:

```bash
bash tests/install-smoke.sh
```

Expected final line:

```text
install smoke ok
```

- [x] **Step 5: Re-run token scan and record counts**

Run:

```bash
for token in \
  'Public PR / Release Train Discipline' \
  'public train branch' \
  'hosted PR' \
  'local equivalent' \
  'version-only' \
  'release choice' \
  'complete-no-action-needed means no release remains' \
  'v0.5.7 and v0.5.8 install-facing content' \
  'Private superpowers plan artifact boundary' \
  'Portable release-governance skill TDD' \
  '0.5.8' \
  'v0.5.8'
do
  count="$(rg -ni --fixed-strings "$token" skills/ ROADMAP.md tests .claude-plugin | wc -l | tr -d ' ')"
  printf '%s\t%s\n' "$count" "$token"
  test "$count" -gt 0
done
```

Expected:

- Every count is greater than zero.
- Report exact counts in the author verification block.

- [x] **Step 6: Verify release and public-integration boundaries remained untouched**

Run:

```bash
git status -sb
git rev-parse HEAD origin/main
git tag --points-at HEAD
```

Expected:

- Status is on `spec/v0.5.8-public-pr-release-discipline`.
- `origin/main` remains `5677e4ad043341650aedc60ac34e34b642da3b05`.
- `git tag --points-at HEAD` prints no `v0.5.8` tag.
- No hosted PR, push, merge, fast-forward, squash, tag push, publish, branch cleanup, or adopting-repo install has occurred.

- [x] **Step 7: Run closeout health check**

Run:

```bash
agent-trigger-kit session-check --closeout
```

Expected:

- Exit 1 only for `agent-skills: plugin directory missing`.
- No unmarked outcome events.
- Carry accepted residual: `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

- [x] **Step 8: Commit plan checkbox ticks**

Run:

```bash
git add docs/superpowers/plans/2026-07-07-public-pr-release-train-discipline.md
git commit -m "docs: mark public PR release train verification"
```

Expected:

- Commit succeeds.
- Commit touches only the plan file.
- This commit records checkbox progress only; it does not alter implementation behavior.

- [ ] **Step 9: Emit the review-needed handoff**

Use this shape, filling `<HEAD>` with the verification-mark commit and `<PLAN_REVIEWED_TIP>` with the latest reviewed implementation-plan tip at execution time:

```text
Status: review-needed
Target repo: /Users/jackchou/Desktop/agent-skills
Target: v0.5.8 public PR / release train discipline implementation @ <HEAD> on branch spec/v0.5.8-public-pr-release-discipline (spec 2cbb3dd, base 5677e4a = origin/main)
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review the implementation range after <PLAN_REVIEWED_TIP>; verify public PR / release train doctrine placement, pointer-style relationship to §3.1 rule 4 and §3.2, post-push closeout examples, smoke/token coverage, metadata 0.5.8, ROADMAP retirement of the two absorbed rows, preservation of private-plan / portable-release / worker candidates, durable pending-batched-release record, and absence of hosted PR / push / merge / tag / publish scope creep. If review passes, the next integration gate should dogfood the new public PR discipline by preparing hosted PR push/open approval when available, or naming the local equivalent explicitly if hosted PR tooling is unavailable.
Blockers: none
Accepted residuals: pending batched release for v0.5.7 + v0.5.8 install-facing content / recorded in ROADMAP Landed entry, requires later §3.2 tag before non-dev adopter delivery / owner: next release train; direct-main / fast-forward public history through 5677e4a / do not rewrite, source evidence for v0.5.8 / owner: n/a after implementation lands; Private superpowers plan artifact boundary / deferred, no files moved / owner: future private-plan boundary spec; Portable release-governance skill TDD / deferred to future writing-skills RED-GREEN train / owner: future portable release-governance train; stale executed-step checkboxes (v0.5.5-v0.5.7 plans) / cleanup in next file-touching train or drop the tick convention / owner: next train author; ATK root-source boundary incl. closeout version-freshness advisory / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up; .claude/worktrees residue / local hygiene, no scope influence / owner: author cleanup per AGENTS.md

Author verification:
- git diff --check origin/main..HEAD: clean
- bash tests/install-smoke.sh: install smoke ok
- placeholder scan on changed live surfaces: no matches
- token scan counts: <paste exact counts from Task 3 Step 5>
- expected changed files: .claude-plugin/marketplace.json, .claude-plugin/plugin.json, ROADMAP.md, docs/superpowers/plans/2026-07-07-public-pr-release-train-discipline.md, docs/superpowers/specs/2026-07-07-public-pr-release-train-discipline-design.md, skills/agent-operating-manual/25-change-discipline.md, tests/install-smoke.sh
- release / integration boundary: no v0.5.8 tag, no hosted PR opened, no push, no merge, no publish, origin/main still 5677e4a
- session-check --closeout: exit 1 boundary-only, no unmarked events

Review: full
Focus: public PR vs local-equivalent boundary, pointer-style §3.1 / §3.2 relationships, merge-shape / version-only evidence preservation, post-push closeout examples, pending batched-release record, ROADMAP retirements, and absence of private-artifact / portable-release / hosted-PR execution scope creep
Prev reviewed tip: <PLAN_REVIEWED_TIP>
```

Expected:

- The handoff asks for full review, not user approval.
- It does not include an `Execution route:` block because `review-needed` is not an executable approval / continuation handoff.
