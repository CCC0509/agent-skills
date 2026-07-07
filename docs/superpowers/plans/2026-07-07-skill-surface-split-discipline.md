# Skill Surface Split Discipline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved v0.5.7 skill-surface split discipline by adding the disposition checklist, trigger/frontmatter guidance, batched release cadence rule, smoke coverage, metadata bump, and ROADMAP closeout.

**Architecture:** Keep canonical skill-surface authoring guidance in `skills/skill-authoring/SKILL.md`; keep release object identity in `skills/agent-operating-manual/25-change-discipline.md` by pointer only. Add install-smoke assertions for the optional imported `skill-authoring` surface, bump plugin metadata because installed skill text changes, and preserve the portable release-governance skill as a future ROADMAP candidate.

**Tech Stack:** Markdown skill doctrine, Bash install smoke, JSON plugin manifests, Git.

## Global Constraints

- Approved spec: `docs/superpowers/specs/2026-07-07-skill-surface-split-discipline-design.md` at `a1825ee`.
- Base: `14548cbc9b014e49ee32661e7f3ff5f1887e5af9` (`origin/main`, tag `v0.5.6`).
- Effective contract remains merged `main` plus AGENTS.md; branch-local text is proposal until reviewed and merged.
- Do not create the future portable release-governance skill in this train.
- Do not run RED/GREEN pressure scenarios for the future portable release-governance skill in this train.
- Do not change `Status:` values, `Review:` values, relay fields, route semantics, or release lifecycle ownership.
- Do not edit `install.sh`, publish mechanics, Agent Trigger Kit validators, session-check behavior, hooks, outcome taxonomy, vector retrieval, MCP indexing, public PR discipline, private plan artifact boundaries, adopting repos, or generated imported copies.
- Because this train changes install-facing optional skill text and smoke coverage, bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to `0.5.7`. This metadata bump does not authorize tag creation, tag push, publish, merge, push, or adopting-repo install.
- Commit the red smoke test before implementation. Commit implementation before green smoke because `tests/install-smoke.sh` clones committed HEAD as its install source.
- Do not stage plan checkbox ticks in Task 1 or Task 2 commits. Plan checkbox ticks ride the Task 3 verification commit.
- No tag, tag push, publish, merge, remote push, branch cleanup, `.claude/worktrees` cleanup, or adopting-repo install occurs in this implementation.
- Carry the ATK residual when relay text is emitted: `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

---

## File Structure

- Modify: `tests/install-smoke.sh`
  - Adds red/green coverage that explicit optional install includes the new `skill-authoring` trigger/frontmatter, Skill Surface Disposition, and batched release cadence tokens.
- Modify: `skills/skill-authoring/SKILL.md`
  - Canonical home for the new authoring disposition checklist, trigger-focused frontmatter guidance, default-vs-optional install reasoning, and release cadence pointer.
- Modify: `.claude-plugin/plugin.json`
  - Bumps plugin manifest version from `0.5.6` to `0.5.7`.
- Modify: `.claude-plugin/marketplace.json`
  - Bumps marketplace plugin version from `0.5.6` to `0.5.7`.
- Modify: `ROADMAP.md`
  - Adds v0.5.7 Landed entry and preserves all future candidates, including `Portable release-governance skill TDD`.
- Modify: `docs/superpowers/plans/2026-07-07-skill-surface-split-discipline.md`
  - Tracks execution checkboxes only; checkbox changes are committed in Task 3.

---

### Task 1: Red Smoke Coverage For Skill-Authoring Surface

**Files:**
- Modify: `tests/install-smoke.sh`

**Interfaces:**
- Consumes: existing optional install block in `tests/install-smoke.sh` lines 342-351.
- Produces: smoke assertions later satisfied by `skills/skill-authoring/SKILL.md`.

- [x] **Step 1: Add failing assertions after the existing skill-authoring release pointer check**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: tests/install-smoke.sh
@@
 grep -Fq 'Release tag / publish lifecycle discipline' \
   "$TMP/target/docs/imported-skills/skill-authoring/SKILL.md" \
   || fail "imported skill-authoring missing release lifecycle pointer"
+grep -Fq 'Skill Surface Disposition' \
+  "$TMP/target/docs/imported-skills/skill-authoring/SKILL.md" \
+  || fail "imported skill-authoring missing skill surface disposition"
+grep -Fq 'trigger-focused frontmatter' \
+  "$TMP/target/docs/imported-skills/skill-authoring/SKILL.md" \
+  || fail "imported skill-authoring missing trigger frontmatter rule"
+grep -Fq 'directly or as part of a later reviewed batch' \
+  "$TMP/target/docs/imported-skills/skill-authoring/SKILL.md" \
+  || fail "imported skill-authoring missing batched release cadence"
+grep -Fq 'then-current manifest version' \
+  "$TMP/target/docs/imported-skills/skill-authoring/SKILL.md" \
+  || fail "imported skill-authoring missing then-current manifest rule"
+grep -Fq 'intermediate bump-only versions' \
+  "$TMP/target/docs/imported-skills/skill-authoring/SKILL.md" \
+  || fail "imported skill-authoring missing bump-only version rule"
 [ -f "$TMP/target/docs/imported-skills/work-discipline/SKILL.md" ] \
   || fail "missing work-discipline/SKILL.md"
*** End Patch
```

- [x] **Step 2: Run the red smoke**

Run:

```bash
bash tests/install-smoke.sh
```

Expected: exit nonzero with first failure:

```text
SMOKE FAIL: imported skill-authoring missing skill surface disposition
```

- [x] **Step 3: Commit the red smoke only**

Run:

```bash
git add tests/install-smoke.sh
git commit -m "test: cover skill authoring surface discipline"
```

Expected:

- Commit succeeds.
- `docs/superpowers/plans/2026-07-07-skill-surface-split-discipline.md` remains unstaged if checkbox ticks were edited.
- No implementation files are staged in this commit.

---

### Task 2: Implement Skill-Authoring Doctrine, Metadata, And ROADMAP

**Files:**
- Modify: `skills/skill-authoring/SKILL.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `ROADMAP.md`

**Interfaces:**
- Consumes: red smoke assertions from Task 1.
- Produces: installed optional `skill-authoring` text with the required tokens; metadata version `0.5.7`; v0.5.7 ROADMAP Landed entry.

- [x] **Step 1: Replace `skills/skill-authoring/SKILL.md` with the v0.5.7 canonical text**

Use `apply_patch`:

```diff
*** Begin Patch
*** Delete File: skills/skill-authoring/SKILL.md
*** Add File: skills/skill-authoring/SKILL.md
+---
+name: skill-authoring
+description: "Use when creating, extracting, splitting, reviewing, or releasing portable agent skills or plugin-facing doctrine, especially when deciding whether guidance belongs in canonical doctrine, a trigger wrapper, one-hop reference, optional skill, release train, or repo-local owner."
+---
+
+# Skill Authoring
+
+Use this when turning repo-local agent behavior into a reusable skill or plugin
+surface. Keep the boundary sharp:
+
+- **Doctrine text lives in agent-skills**: reusable judgment, workflows,
+  review methods, lifecycle rules, and authoring guidance.
+- **Mechanism lives in agent-trigger-kit or the adopting repo**: validators,
+  trigger-layer generators, script templates, pin/session/closeout tooling, and
+  outcome collection.
+- **Memory data stays per repo**: `LESSONS.md`, `00-diagnosis.md`,
+  ops-observations, review logs, and domain playbooks are not centralized.
+
+## Authoring Flow
+
+1. Pin the source material: exact files, commit/range, and which repo owns each
+   piece after extraction.
+2. Decide whether the content is doctrine, mechanism, or repo-local data before
+   writing. Do not mix runtime collection into a markdown-only skill.
+3. Record a Skill Surface Disposition before creating, splitting, deleting,
+   renaming, or substantially editing a skill.
+4. Write concise, trigger-focused frontmatter. The `description` names when to
+   load the skill: symptoms, tasks, and decisions. Do not summarize the workflow
+   so agents can skip the body.
+5. Keep `SKILL.md` small. Add one-hop `references/` files only when details are
+   too long or conditional. Avoid README-style auxiliary docs inside a skill.
+6. Prefer existing repo patterns for validation. If a validator or classifier is
+   reusable, make it an Agent Trigger Kit template rather than embedding it in a
+   doctrine skill.
+7. Document consumer adoption separately from implementation details: exact tag,
+   install command, default-vs-optional skill choice, and expected entrypoint
+   pointer updates.
+
+## Skill Surface Disposition
+
+When a spec or plan changes a skill surface, choose one disposition and record
+the reason:
+
+- **Keep canonical**: shared authority, object identity, approval semantics, or
+  cross-wrapper invariants belong in one canonical doctrine home.
+- **Add or keep trigger wrapper**: use a wrapper only when the workflow is
+  high-frequency or high-miss, has distinct trigger words, and can point to
+  canonical homes without restating them.
+- **Move to one-hop reference**: use a referenced file when details are too long
+  or conditional for `SKILL.md`, but still belong to the same skill.
+- **Split into separate optional skill**: split when trigger, audience, must-read
+  set, or install choice differs enough that bundling increases context load.
+- **Make default-installed**: install by default only when most ordinary
+  adopting-repo sessions need the trigger surface; otherwise keep explicit
+  install.
+- **Delete or shrink**: remove duplicate prose, stale examples, and broad
+  reminders that add tokens without changing behavior.
+- **Defer with owner**: route mechanism, adopting-repo policy, private artifact,
+  MCP / vector retrieval, or roadmap-lane work to its real owner.
+
+Prefer deletion, pointer, or wrapper before broad canonical growth. One observed
+miss is not enough to create a new skill if a small pointer, frontmatter fix, or
+smoke assertion closes the gap.
+
+## Release Checklist
+
+- The skill folder name matches the frontmatter `name`.
+- The skill is optional unless it is needed by most consumer sessions.
+- Installer tests cover default install, explicit install, idempotency, and
+  managed sentinel files.
+- Release metadata and tag agree before publishing. If a reviewed train changes
+  install-facing skill text, default skill choice, plugin metadata, marketplace
+  metadata, installer behavior, or adopting-repo install output, bump manifests
+  and proceed through the release lifecycle
+  directly or as part of a later reviewed batch. After review and merge, the tag
+  targets the reviewed head at the then-current manifest version. Do not create
+  retroactive tags for intermediate bump-only versions unless a separate
+  reviewed release-repair plan authorizes them. Follow
+  `agent-operating-manual/25-change-discipline.md` §3.2
+  `Release tag / publish lifecycle discipline` for the release gates.
+- If a train changes only specs, implementation plans, private planning
+  artifacts, non-installed roadmap text, or review evidence, do not bump
+  metadata or create a tag unless a reviewed release plan says otherwise.
+- Tag creation, tag push, publish approval, post-tag smoke, post-publish
+  verification, and no-backfill policy follow `25-change-discipline.md` §3.2.
+- Consumer repos upgrade by re-running the installer; imported skill files are
+  managed artifacts, not hand-edited local doctrine.
+
+## Public Skill / Plugin Hygiene
+
+- Keep scratch or generated artifacts in an ignored, namespaced path.
+- Make premerge version checks fail loud when generated manifests, marketplace
+  entries, plugin metadata, or tags disagree.
+- Keep public runbooks thin. A runbook should onboard wiring once; ongoing
+  learning loops belong in doctrine and per-repo lessons, not in a pin prompt.
+- Do not publish a portable release-governance skill from one repo's release
+  run. A future portable skill needs writing-skills RED/GREEN pressure
+  scenarios across Git-tag-only delivery, hosted releases, package registries,
+  plugin marketplaces, and no-publish-surface repos.
*** End Patch
```

- [x] **Step 2: Bump plugin metadata to 0.5.7**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: .claude-plugin/plugin.json
@@
-  "version": "0.5.6",
+  "version": "0.5.7",
*** Update File: .claude-plugin/marketplace.json
@@
-      "version": "0.5.6",
+      "version": "0.5.7",
*** End Patch
```

- [x] **Step 3: Add the v0.5.7 ROADMAP Landed entry without closing future candidates**

Use `apply_patch`:

```diff
*** Begin Patch
*** Update File: ROADMAP.md
@@
 - v0.5.6: release tag / publish lifecycle discipline defines metadata-train,
   reviewed-candidate, annotated-tag, tag-push, publish-inventory, post-tag /
   post-publish smoke, exact approval, no-backfill, and terminal closeout gates
   while leaving public PR discipline, private plan artifact boundary, post-push
   no-action examples, worker lifecycle, ATK mechanism, and retrieval open.
+- v0.5.7: skill-surface split discipline adds Skill Surface Disposition,
+  trigger-focused frontmatter guidance, default-vs-optional install reasoning,
+  and batched release cadence for install-facing changes while preserving
+  portable release-governance skill TDD, public PR discipline, private plan
+  artifact boundary, post-push no-action examples, worker hygiene, ATK
+  mechanism, and retrieval candidates as separate follow-ups.
*** End Patch
```

- [x] **Step 4: Inspect the implementation diff before committing**

Run:

```bash
git diff -- skills/skill-authoring/SKILL.md .claude-plugin/plugin.json .claude-plugin/marketplace.json ROADMAP.md
```

Expected:

- `skill-authoring/SKILL.md` now contains `Skill Surface Disposition`, `trigger-focused frontmatter`, `directly or as part of a later reviewed batch`, `then-current manifest version`, and `intermediate bump-only versions`.
- Both manifests say `0.5.7`.
- ROADMAP has one new `v0.5.7` Landed entry.
- ROADMAP still contains `Portable release-governance skill TDD`, `Public repo PR / release train discipline`, `Private superpowers plan artifact boundary`, `Post-push complete-no-action-needed closeout examples`, `Skill context loading / retrieval strategy`, and `F2 handoff-contract file split`.

- [x] **Step 5: Commit implementation before the green smoke**

Run:

```bash
git add skills/skill-authoring/SKILL.md .claude-plugin/plugin.json .claude-plugin/marketplace.json ROADMAP.md
git commit -m "docs: add skill surface split discipline"
```

Expected:

- Commit succeeds.
- No tag, tag push, publish, merge, or remote push occurs.
- `docs/superpowers/plans/2026-07-07-skill-surface-split-discipline.md` remains unstaged if checkbox ticks were edited.

- [x] **Step 6: Run the green smoke against committed HEAD**

Run:

```bash
bash tests/install-smoke.sh
```

Expected final line:

```text
install smoke ok
```

- [x] **Step 7: Run a no-plan-self-match token scan**

Run:

```bash
for token in \
  'Skill Surface Disposition' \
  'trigger-focused frontmatter' \
  'directly or as part of a later reviewed batch' \
  'then-current manifest version' \
  'intermediate bump-only versions' \
  'Portable release-governance skill TDD' \
  '0.5.7' \
  'v0.5.7'
do
  count="$(rg -ni --fixed-strings "$token" skills/ ROADMAP.md .claude-plugin tests | wc -l | tr -d ' ')"
  printf '%s\t%s\n' "$count" "$token"
  test "$count" -gt 0
done
```

Expected:

- Every printed count is greater than zero.
- The scan paths exclude `docs/superpowers/plans/` and `docs/superpowers/specs/`.

---

### Task 3: Final Verification And Review Handoff

**Files:**
- Modify: `docs/superpowers/plans/2026-07-07-skill-surface-split-discipline.md`

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
docs/superpowers/plans/2026-07-07-skill-surface-split-discipline.md
docs/superpowers/specs/2026-07-07-skill-surface-split-discipline-design.md
skills/skill-authoring/SKILL.md
tests/install-smoke.sh
```

- [x] **Step 2: Run full range whitespace check**

Run:

```bash
git diff --check origin/main..HEAD
```

Expected: exit 0, no output.

- [x] **Step 3: Run placeholder scan on the changed live surfaces**

Run:

```bash
rg -n '[T]BD|[T]ODO|[P]LACEHOLDER' \
  docs/superpowers/plans/2026-07-07-skill-surface-split-discipline.md \
  docs/superpowers/specs/2026-07-07-skill-surface-split-discipline-design.md \
  skills/skill-authoring/SKILL.md \
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
  'Skill Surface Disposition' \
  'trigger-focused frontmatter' \
  'directly or as part of a later reviewed batch' \
  'then-current manifest version' \
  'intermediate bump-only versions' \
  'Portable release-governance skill TDD' \
  '0.5.7' \
  'v0.5.7'
do
  count="$(rg -ni --fixed-strings "$token" skills/ ROADMAP.md .claude-plugin tests | wc -l | tr -d ' ')"
  printf '%s\t%s\n' "$count" "$token"
  test "$count" -gt 0
done
```

Expected:

- Every count is greater than zero.
- Report the exact counts in the author verification block.

- [x] **Step 6: Verify release boundaries remained untouched**

Run:

```bash
git status -sb
git rev-parse HEAD origin/main
git tag --points-at HEAD
```

Expected:

- Status is on `spec/v0.5.7-skill-surface-discipline`.
- `origin/main` remains `14548cbc9b014e49ee32661e7f3ff5f1887e5af9`.
- `git tag --points-at HEAD` prints no `v0.5.7` tag.
- No push, tag push, publish, merge, branch cleanup, or adopting-repo install has occurred.

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
git add docs/superpowers/plans/2026-07-07-skill-surface-split-discipline.md
git commit -m "docs: mark skill surface discipline verification"
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
Target: v0.5.7 skill-surface split discipline implementation @ <HEAD> on branch spec/v0.5.7-skill-surface-discipline (spec a1825ee, base 14548cb = origin/main = v0.5.6)
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review the implementation range after <PLAN_REVIEWED_TIP>; verify Skill Surface Disposition canonical home, trigger-focused frontmatter guidance, batched release cadence wording, optional skill smoke coverage, metadata 0.5.7, ROADMAP Landed entry with future candidates preserved, and absence of tag / publish / push / merge / adopting-repo scope creep
Blockers: none
Accepted residuals: portable release-governance skill not created / intentionally deferred to future writing-skills RED-GREEN train, recorded in ROADMAP row / owner: future portable release-governance train; Public repo PR / release train discipline remains ROADMAP candidate / owner: that candidate row; Private superpowers plan artifact boundary remains ROADMAP candidate / owner: future private-plan boundary spec; stale executed-step checkboxes (v0.5.5/v0.5.6 plans) / cleanup in next file-touching train or drop the tick convention / owner: next train author; ATK root-source boundary incl. closeout version-freshness advisory / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up; .claude/worktrees residue (feature+handoff-relay-control-contract) / local hygiene, no scope influence / owner: author cleanup per AGENTS.md

Author verification:
- git diff --check origin/main..HEAD: clean
- bash tests/install-smoke.sh: install smoke ok
- placeholder scan on changed live surfaces: no matches
- token scan counts: <paste exact counts from Task 3 Step 5>
- expected changed files: .claude-plugin/marketplace.json, .claude-plugin/plugin.json, ROADMAP.md, docs/superpowers/plans/2026-07-07-skill-surface-split-discipline.md, docs/superpowers/specs/2026-07-07-skill-surface-split-discipline-design.md, skills/skill-authoring/SKILL.md, tests/install-smoke.sh
- release boundary: no v0.5.7 tag, no push, no publish, no merge, origin/main still 14548cb
- session-check --closeout: exit 1 boundary-only, no unmarked events

Review: full
Focus: Skill Surface Disposition canonical placement, release cadence batching semantics, smoke/token coverage, metadata 0.5.7, ROADMAP candidate preservation, and absence of release or public-PR scope creep
Prev reviewed tip: <PLAN_REVIEWED_TIP>
```

Expected:

- The handoff asks for full review, not user approval.
- It does not include an `Execution route:` block because `review-needed` is not an executable approval / continuation handoff.
