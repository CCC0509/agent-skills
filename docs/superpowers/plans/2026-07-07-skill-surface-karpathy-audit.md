# Skill Surface / Karpathy-Guidelines Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved v0.5.5 skill-surface audit slice by recording
the audit decision, adding an optional `work-discipline` trigger wrapper, and
updating install-facing smoke, docs, metadata, and ROADMAP surfaces.

**Architecture:** Keep existing canonical homes stable and add only one small
optional wrapper. The wrapper is a trigger layer inspired by the Stock Scanner
`karpathy-guidelines` shape: it routes agents to existing doctrine while
reminding them to state assumptions, prefer simple scope, make surgical edits,
and verify against concrete success criteria.

**Tech Stack:** Markdown skills, Bash installer and smoke tests, JSON plugin
metadata, `rg`, `git`, Agent Trigger Kit session-check.

## Global Constraints

- Base this work on approved spec commit `f0c6a4f` and reviewed base
  `9ebdfce`.
- Start on branch `spec/v0.5.5-skill-surface-audit`; do not execute this plan
  directly on `main`.
- First slice decision: implement an optional `work-discipline` skill. Do not
  add it to `DEFAULT_SKILLS`.
- Preserve attribution: the portable wrapper is adapted from
  `multica-ai/andrej-karpathy-skills` at commit `2c606141936f` under MIT terms
  via the Stock Scanner repo-local `karpathy-guidelines` wrapper.
- Do not import Stock Scanner domain overrides, local playbooks, production
  policy, or absolute local paths.
- Do not move `docs/superpowers/**` artifacts to a private repo.
- Do not rewrite public `main` history or force-push already-landed commits.
- Do not define the full release tag / publish lifecycle.
- Because this plan creates an install-facing optional wrapper, bump release
  metadata to `0.5.5` per the v0.5.4 precedent.
- Do not tag, publish, push, or create release artifacts. A metadata bump is
  not tag / publish authorization.
- Keep `Release tag / publish lifecycle discipline`, `Public repo PR / release
  train discipline`, `Private superpowers plan artifact boundary`, and
  `Post-push complete-no-action-needed closeout examples` visible and open in
  `ROADMAP.md`.
- End implementation with `Status: review-needed`, `Review: full`, and a fresh
  review request before any merge, push, tag, publish, or release approval
  gate.
- Known non-blocking source-repo residual:
  `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

---

## Plan-Time Audit Decision

Current skill-surface audit result to be rechecked in Task 1:

| Surface | Classification | Decision |
|---|---|---|
| `skills/agent-operating-manual/**` | Keep canonical | Dense manual stays canonical. Do not split broad sections in this slice. |
| `skills/handoff-relay/SKILL.md` | Keep wrapper | Already covers relay / approval trigger misses; do not expand it with work-discipline content. |
| `skills/multi-angle-review/SKILL.md` | Keep canonical wrapper | Review method stays in one skill; do not move reviewer conduct into work-discipline. |
| `skills/skill-authoring/SKILL.md` | Keep optional authoring wrapper | Maintainer / extraction doctrine stays optional and separate from everyday work discipline. |
| Work-discipline trigger surface | Split optional wrapper | Add `skills/work-discipline/SKILL.md` as a small optional pointer skill. |
| Public PR / private plan / release lifecycle concerns | Defer with owner | Keep the new ROADMAP rows open; v0.5.5 only records and preserves them. |

The plan intentionally chooses a wrapper over deleting existing doctrine because
the common failure is trigger salience, and the wrapper can stay small while
pointing to current canonical homes.

## File Structure

- Create: `skills/work-discipline/SKILL.md`
  Optional trigger-only wrapper for assumptions, scope control, surgical edits,
  and verifiable success criteria.
- Modify: `install.sh`
  Adds an explicit-install entry pointer for `work-discipline`; leaves
  `DEFAULT_SKILLS` unchanged.
- Modify: `tests/install-smoke.sh`
  Proves `work-discipline` is not installed by default, installs when explicitly
  requested, has a managed sentinel, injects one entry pointer, and preserves
  attribution / trigger tokens.
- Modify: `README.md`
  Adds the optional skill row and explicit install example.
- Modify: `.claude-plugin/plugin.json`
  Bumps metadata to `0.5.5` and names optional `work-discipline`.
- Modify: `.claude-plugin/marketplace.json`
  Bumps metadata to `0.5.5` and names optional `work-discipline`.
- Modify: `ROADMAP.md`
  Adds the v0.5.5 Landed entry, removes the solved Portable Wrapper Pattern
  lane and its two solved rows, and preserves adjacent open candidates.
- Update during execution:
  `docs/superpowers/plans/2026-07-07-skill-surface-karpathy-audit.md`
  checkboxes.

---

### Task 1: Audit Confirmation And Red Smoke

**Files:**
- Modify: `tests/install-smoke.sh`
- Modify: `docs/superpowers/plans/2026-07-07-skill-surface-karpathy-audit.md`

**Interfaces:**
- Consumes: approved spec `docs/superpowers/specs/2026-07-07-skill-surface-karpathy-audit-design.md`.
- Produces: failing smoke coverage for the optional `work-discipline` install
  surface; audit confirmation that Task 2 may add one wrapper without broad
  skill splitting.

- [x] **Step 1: Confirm branch, base, and source health**

Run:

```bash
git branch --show-current
git rev-parse --short HEAD
git merge-base --is-ancestor 9ebdfce HEAD
git status --porcelain
agent-trigger-kit session-check
```

Expected:

- `git branch --show-current` prints `spec/v0.5.5-skill-surface-audit`.
- `git rev-parse --short HEAD` prints `f0c6a4f` or a descendant created by this
  plan.
- `git merge-base --is-ancestor 9ebdfce HEAD` exits `0`.
- `git status --porcelain` is empty before editing, except this plan file after
  checkboxes are ticked.
- `agent-trigger-kit session-check` exits `1` only with
  `agent-skills: plugin directory missing`, no failure categories, and no
  failure drivers.

- [x] **Step 2: Reproduce the skill-surface audit inputs**

Run:

```bash
find skills -maxdepth 2 -name SKILL.md -print | sort
rg -n 'name:|description:|Must Read|Apply|trigger layer only|Canonical content|Release metadata|DEFAULT_SKILLS|skill-authoring|handoff-relay' \
  skills README.md install.sh tests/install-smoke.sh .claude-plugin
```

Expected:

- The `find` command prints exactly these four top-level skills:

```text
skills/agent-operating-manual/SKILL.md
skills/handoff-relay/SKILL.md
skills/multi-angle-review/SKILL.md
skills/skill-authoring/SKILL.md
```

- The `rg` command shows `handoff-relay` in `DEFAULT_SKILLS`, shows
  `skill-authoring` as optional, and shows no existing `work-discipline` skill.

- [x] **Step 3: Confirm the plan-time audit decision**

Read the files below and compare them to the `Plan-Time Audit Decision` table:

```bash
sed -n '1,90p' skills/agent-operating-manual/SKILL.md
sed -n '1,80p' skills/handoff-relay/SKILL.md
sed -n '1,90p' skills/multi-angle-review/SKILL.md
sed -n '1,80p' skills/skill-authoring/SKILL.md
```

Expected:

- `agent-operating-manual` is a broad canonical entry point with numbered
  sub-documents.
- `handoff-relay` is already trigger-only and points at relay / review /
  approval-bound canonical homes.
- `multi-angle-review` owns review methodology and reviewer conduct.
- `skill-authoring` owns maintainer / extraction guidance and is optional.
- No existing skill owns the four Karpathy-guidelines-inspired reminders as a
  small portable trigger surface.

- [x] **Step 4: Add red default non-install and explicit-install smoke checks**

In `tests/install-smoke.sh`, after:

```bash
[ ! -e "$TMP/target/docs/imported-skills/skill-authoring" ] \
  || fail "skill-authoring installed by default"
```

add:

```bash
[ ! -e "$TMP/target/docs/imported-skills/work-discipline" ] \
  || fail "work-discipline installed by default"
```

In the optional skill section, replace:

```bash
# 13) optional skill-authoring installs only when explicitly requested
mktarget
bash "$TMP/src/install.sh" "$TMP/target" --skills agent-operating-manual,handoff-relay,multi-angle-review,skill-authoring
```

with:

```bash
# 13) optional skills install only when explicitly requested
mktarget
bash "$TMP/src/install.sh" "$TMP/target" --skills agent-operating-manual,handoff-relay,multi-angle-review,work-discipline,skill-authoring
```

After the existing `skill-authoring` sentinel assertion, add:

```bash
[ -f "$TMP/target/docs/imported-skills/work-discipline/SKILL.md" ] \
  || fail "missing work-discipline/SKILL.md"
[ -f "$TMP/target/docs/imported-skills/work-discipline/.managed-by-agent-skills" ] \
  || fail "missing work-discipline sentinel"
```

After the existing `CLAUDE.md missing handoff-relay pointer with
skill-authoring` assertion, add:

```bash
[ "$(grep -Fc 'docs/imported-skills/work-discipline/SKILL.md' "$TMP/target/CLAUDE.md")" = 1 ] \
  || fail "CLAUDE.md missing work-discipline pointer"
grep -Fq 'trigger layer only' \
  "$TMP/target/docs/imported-skills/work-discipline/SKILL.md" \
  || fail "imported work-discipline missing trigger-only boundary"
grep -Fq 'multica-ai/andrej-karpathy-skills' \
  "$TMP/target/docs/imported-skills/work-discipline/SKILL.md" \
  || fail "imported work-discipline missing upstream attribution"
grep -Fq '2c606141936f' \
  "$TMP/target/docs/imported-skills/work-discipline/SKILL.md" \
  || fail "imported work-discipline missing source commit"
grep -Fq 'surface assumptions' \
  "$TMP/target/docs/imported-skills/work-discipline/SKILL.md" \
  || fail "imported work-discipline missing assumptions reminder"
grep -Fq 'verifiable success criteria' \
  "$TMP/target/docs/imported-skills/work-discipline/SKILL.md" \
  || fail "imported work-discipline missing verification reminder"
```

- [x] **Step 5: Run smoke and verify the red failure**

Run:

```bash
bash tests/install-smoke.sh
```

Expected: exit `1` with this stderr line from `install.sh`:

```text
unknown skill: work-discipline
```

- [x] **Step 6: Commit red smoke coverage and checkbox update**

Run:

```bash
git add tests/install-smoke.sh docs/superpowers/plans/2026-07-07-skill-surface-karpathy-audit.md
git commit -m "test: add work discipline install smoke"
```

Expected: commit succeeds. The smoke test remains red until Task 2 creates the
optional skill and installer pointer.

---

### Task 2: Optional Wrapper, Installer Pointer, Docs, Metadata, And Roadmap

**Files:**
- Create: `skills/work-discipline/SKILL.md`
- Modify: `install.sh`
- Modify: `README.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `ROADMAP.md`
- Modify: `docs/superpowers/plans/2026-07-07-skill-surface-karpathy-audit.md`

**Interfaces:**
- Consumes: Task 1 red smoke assertions.
- Produces: optional install-facing `work-discipline` wrapper, metadata
  `0.5.5`, and ROADMAP closeout for the two solved v0.5.5 rows.

- [x] **Step 1: Create the optional trigger-only wrapper**

Create `skills/work-discipline/SKILL.md`:

```markdown
---
name: work-discipline
description: "Use when writing, reviewing, refactoring, or modifying docs, skills, plans, tests, scripts, trigger layers, or release surfaces to reduce common LLM mistakes: surface assumptions, keep scope simple and surgical, and define verifiable success criteria."
---

# Work Discipline

This is a trigger layer only. It is adapted from
`multica-ai/andrej-karpathy-skills` at commit `2c606141936f` (MIT), via the
Stock Scanner repo-local `karpathy-guidelines` wrapper. Existing agent-skills
manuals remain canonical.

## Must Read

- [`../agent-operating-manual/25-change-discipline.md`](../agent-operating-manual/25-change-discipline.md) -- read for convention migrations, release PRs, approval-bound identifiers, public evidence hygiene, and verifiable commit structure.
- [`../agent-operating-manual/10-model-dispatch.md`](../agent-operating-manual/10-model-dispatch.md) -- read for delegation, context management, verification, progress tracking, and when to stop.
- [`../handoff-relay/SKILL.md`](../handoff-relay/SKILL.md) -- read before emitting handoff, review, approval, continuation, or no-action closeout signals.
- [`../multi-angle-review/SKILL.md`](../multi-angle-review/SKILL.md) -- read when reviewing a plan, rule, PR, commit range, or fix.

## Apply

1. Think before changing.
   - State assumptions when the task has multiple reasonable interpretations.
   - Present tradeoffs before choosing a risky direction.
   - Ask when confusion would change the implementation.

2. Prefer simplicity.
   - Build the minimum change that satisfies the request and repo rules.
   - Avoid speculative configurability, side features, and single-use abstractions.
   - If the solution is growing faster than the problem, shrink the slice.

3. Make surgical changes.
   - Touch only files needed for this turn.
   - Match local style, helper APIs, and existing release patterns.
   - Clean up unused imports or orphan text created by your own edits, but do not remove unrelated pre-existing work.

4. Finish against verifiable success criteria.
   - Translate the request into success criteria before editing.
   - For multi-step work, keep a short plan with verification for each risky step.
   - Before claiming completion, run the checks that actually prove the changed surface.

5. Route excess scope.
   - Put adjacent concerns in ROADMAP or `Accepted residuals` with an owner.
   - Do not turn one wrapper or cleanup into a full doctrine migration.
```

- [x] **Step 2: Add an explicit-install entry pointer**

In `install.sh`, after the existing `handoff-relay)` case, add:

```bash
    work-discipline)
      POINTER_LINES="${POINTER_LINES}寫作 / 修改 docs、skills、plans、tests、scripts、trigger layers 時讀 [$DEST/work-discipline/SKILL.md]($DEST/work-discipline/SKILL.md) 控制 assumptions、scope、surgical diff、verification。
" ;;
```

Do not change this line:

```bash
DEFAULT_SKILLS="agent-operating-manual,handoff-relay,multi-angle-review"
```

- [x] **Step 3: Update README public skill list and optional install example**

In `README.md`, add this row after `multi-angle-review`:

```markdown
| [`skills/work-discipline/`](skills/work-discipline/SKILL.md) | optional work discipline：假設、scope、surgical diff、verification success criteria |
```

Replace:

```markdown
Default install 只包含 `agent-operating-manual,handoff-relay,multi-angle-review`。
`skill-authoring` 是 maintainer / extraction 用 optional skill，需要時明確指定：

    ./install.sh <target-repo-path> --skills agent-operating-manual,handoff-relay,multi-angle-review,skill-authoring
```

with:

```markdown
Default install 只包含 `agent-operating-manual,handoff-relay,multi-angle-review`。
`work-discipline` 是一般修改前的 optional scope / simplicity / verification
trigger；`skill-authoring` 是 maintainer / extraction 用 optional skill，需要時明確指定：

    ./install.sh <target-repo-path> --skills agent-operating-manual,handoff-relay,multi-angle-review,work-discipline,skill-authoring
```

- [x] **Step 4: Bump plugin metadata to 0.5.5 and name the optional wrapper**

Replace `.claude-plugin/plugin.json` with:

```json
{
  "name": "agent-skills",
  "version": "0.5.5",
  "description": "Portable agent doctrine skills: agent-operating-manual (dispatch economy), handoff-relay (handoff / approval trigger surface), multi-angle-review (adversarial review pipeline), optional work-discipline (scope / simplicity / verification guardrails), and optional skill-authoring.",
  "skills": [
    "./skills/"
  ]
}
```

In `.claude-plugin/marketplace.json`, replace:

```json
    "description": "Portable agent doctrine skills: dispatch economy, handoff relay, adversarial review, and skill authoring"
```

with:

```json
    "description": "Portable agent doctrine skills: dispatch economy, handoff relay, adversarial review, work discipline, and skill authoring"
```

Then replace the plugin object description and version with:

```json
      "description": "Portable agent doctrine skills: agent-operating-manual (dispatch economy), handoff-relay (handoff / approval trigger surface), multi-angle-review (adversarial review pipeline), optional work-discipline (scope / simplicity / verification guardrails), and optional skill-authoring.",
      "version": "0.5.5",
```

- [x] **Step 5: Update ROADMAP landed entry and solved rows**

In `ROADMAP.md`, after the v0.5.4 Landed entry, add:

```markdown
- v0.5.5: repo-wide skill-surface audit uses the Karpathy-guidelines lens to
  confirm canonical homes, adds optional `work-discipline` as a small
  assumptions / simplicity / surgical-diff / verification trigger wrapper, and
  preserves release lifecycle, public PR discipline, private plan artifact
  boundary, post-push no-action closeout examples, ATK mechanism, vector / MCP
  retrieval, and broad skill splitting as separate follow-ups.
```

Remove the solved Portable Wrapper Pattern lane bullet from Candidate Lanes:

```markdown
- **Portable Wrapper Pattern:** `Repo-wide skill-surface audit /
  simplification pass` and `Portable work-discipline / Karpathy-guidelines
  uplift`. This lane studies the Stock Scanner wrapper shape while preserving
  upstream attribution, removing domain overrides, auditing existing trigger
  surfaces before splitting more wrappers, and avoiding duplicate homes for
  existing TDD / verification doctrine.
```

Remove these two solved rows from the Extraction Candidates table:

```markdown
| agent-skills doctrine | Repo-wide skill-surface audit / simplification pass | agent-skills | Use the Stock Scanner `karpathy-guidelines` lens to audit every current skill and manual file for overbroad triggers, duplicated canonical homes, oversized must-read sets, and overbuilt process text before splitting more wrappers. |
| agent-skills doctrine | Portable work-discipline / Karpathy-guidelines uplift | agent-skills | Extract the reusable core of the Stock Scanner repo-local `karpathy-guidelines` wrapper -- clarify assumptions, keep designs simple, make surgical diffs, and define verification success -- while preserving attribution, removing domain overrides, and avoiding duplicate homes for existing TDD / verification doctrine. |
```

Do not remove these rows:

```markdown
| agent-skills doctrine | Release tag / publish lifecycle discipline | agent-skills | Existing guardrails cover metadata / tag consistency and approval-bound tag identifiers, but no lifecycle owns metadata bump, push, tag, publish, post-tag / post-publish smoke, and exact approval gates as one irreversible-action flow. |
| agent-skills doctrine / release process | Public repo PR / release train discipline | agent-skills | Direct-main trains through `9ebdfce` should not be rewritten, but future public-repo work needs a branch / PR / review / squash-or-release-commit lifecycle and a clear rule for when main closeout should be version-only versus evidence-bearing. |
| agent-skills doctrine / artifact boundary | Private superpowers plan artifact boundary | agent-skills / private planning repo | Public specs and summaries can live here, but detailed superpowers plans, review paste blocks, local paths, and private evidence may belong in a private planning or audit repo; define the boundary before moving files. |
| agent-skills doctrine | Post-push complete-no-action-needed closeout examples | agent-skills | Recent push closeout discussion showed agents can omit the no-action terminal status when a push truly has no remaining user or agent action; decide whether examples belong in handoff-relay, `10-model-dispatch.md`, or release lifecycle after the skill-surface audit. |
```

- [x] **Step 6: Run smoke and token checks**

Run:

```bash
bash tests/install-smoke.sh
for token in \
  'work-discipline' \
  'Work Discipline' \
  'multica-ai/andrej-karpathy-skills' \
  '2c606141936f' \
  'surface assumptions' \
  'verifiable success criteria' \
  '0.5.5' \
  'v0.5.5' \
  'Public repo PR / release train discipline' \
  'Private superpowers plan artifact boundary' \
  'Post-push complete-no-action-needed' \
  'Release tag / publish lifecycle'
do
  rg -ni "$token" skills README.md ROADMAP.md tests .claude-plugin
done
```

Expected:

- `bash tests/install-smoke.sh` exits `0` with `install smoke ok`.
- Every token search exits `0`.
- `Public repo PR / release train discipline`,
  `Private superpowers plan artifact boundary`,
  `Post-push complete-no-action-needed`, and
  `Release tag / publish lifecycle` still hit `ROADMAP.md`.

- [x] **Step 7: Commit implementation and checkbox update**

Run:

```bash
git add \
  skills/work-discipline/SKILL.md \
  install.sh \
  tests/install-smoke.sh \
  README.md \
  .claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  ROADMAP.md \
  docs/superpowers/plans/2026-07-07-skill-surface-karpathy-audit.md
git commit -m "docs: add optional work discipline wrapper"
```

Expected: commit succeeds.

---

### Task 3: Full Verification And Review Handoff

**Files:**
- Modify: `docs/superpowers/plans/2026-07-07-skill-surface-karpathy-audit.md`

**Interfaces:**
- Consumes: Task 2 implementation commit.
- Produces: checked plan boxes, verification evidence, and a full-review
  handoff. Produces no push, tag, publish, merge, or release artifact.

- [ ] **Step 1: Run source closeout and repo checks**

Run:

```bash
agent-trigger-kit session-check --closeout
git diff --check
git status --porcelain
bash tests/install-smoke.sh
```

Expected:

- `agent-trigger-kit session-check --closeout` exits `1` only with
  `agent-skills: plugin directory missing`; plugin-version-freshness may be
  indeterminate from the same root-source cause; no unmarked outcome events.
- `git diff --check` exits `0`.
- `git status --porcelain` shows only this plan file until the verification
  checkbox update is committed.
- `bash tests/install-smoke.sh` exits `0` with `install smoke ok`.

- [ ] **Step 2: Verify scope boundaries**

Run:

```bash
git diff --name-status 9ebdfce..HEAD
git tag --points-at HEAD
git log --oneline --decorate -6
```

Expected:

- The changed-file list contains only the approved spec file
  `docs/superpowers/specs/2026-07-07-skill-surface-karpathy-audit-design.md`,
  this plan, `skills/work-discipline`, `install.sh`,
  `tests/install-smoke.sh`, `README.md`, `.claude-plugin` metadata, and
  `ROADMAP.md`.
- `git tag --points-at HEAD` prints nothing.
- `git log --oneline --decorate -6` shows the local branch commits only; no
  merge commit, tag, or publish action.

- [ ] **Step 3: Verify version consistency and optional install behavior**

Run:

```bash
sed -n '1,12p' .claude-plugin/plugin.json
sed -n '1,24p' .claude-plugin/marketplace.json
rg -n 'DEFAULT_SKILLS="agent-operating-manual,handoff-relay,multi-angle-review"' install.sh
rg -n 'work-discipline' install.sh tests/install-smoke.sh README.md .claude-plugin skills/work-discipline/SKILL.md
```

Expected:

- Both manifests show `0.5.5`.
- `DEFAULT_SKILLS` remains exactly
  `agent-operating-manual,handoff-relay,multi-angle-review`.
- `work-discipline` appears in the explicit install path, tests, README,
  metadata, and skill file.

- [ ] **Step 4: Verify token coverage without plan self-match**

Run:

```bash
for token in \
  'work-discipline' \
  'Work Discipline' \
  'multica-ai/andrej-karpathy-skills' \
  '2c606141936f' \
  'surface assumptions' \
  'verifiable success criteria' \
  '0.5.5' \
  'v0.5.5' \
  'Public repo PR / release train discipline' \
  'Private superpowers plan artifact boundary' \
  'Post-push complete-no-action-needed' \
  'Release tag / publish lifecycle'
do
  printf '%s: ' "$token"
  rg -ni "$token" skills README.md ROADMAP.md tests .claude-plugin | wc -l
done
```

Expected:

- Every printed count is greater than `0`.
- Do not include `docs/superpowers/plans` in this scan; a plan self-match must
  not mask missing implementation text.

- [ ] **Step 5: Commit verification checkbox update**

Run:

```bash
git add docs/superpowers/plans/2026-07-07-skill-surface-karpathy-audit.md
git commit -m "docs: mark work discipline verification"
```

Expected: commit succeeds if this plan file changed only by checkbox updates.

- [ ] **Step 6: Emit review-needed handoff**

Before emitting the handoff, run:

```bash
git rev-parse --short HEAD
```

Use that output as the concrete commit in `Target`. Set `Prev reviewed tip` to
the implementation-plan commit that most recently passed plan/rule-review or
fix-confirmation. Do not leave descriptive placeholders in the emitted handoff.

The emitted handoff must have these exact field semantics:

- `Status: review-needed`
- `Target repo: /Users/jackchou/Desktop/agent-skills`
- `Target:` names `spec/v0.5.5-skill-surface-audit`, the actual short HEAD
  printed above, base `9ebdfce`, and spec `f0c6a4f`
- `Required user text: n/a`
- `User action: self-review -> to-reviewer`
- `Next agent action:` asks for full review of audit decision, optional wrapper
  boundaries, explicit install behavior, metadata `0.5.5`, ROADMAP row
  handling, smoke evidence, and absence of push / tag / publish authorization
- `Blockers: none`
- `Accepted residuals:` carries the direct-main history, adopter delivery gap,
  private plan artifact boundary, ATK root-source boundary, and
  `.claude/worktrees` hygiene residue with the same durable owners used in this
  plan
- `Review: full`
- `Focus:` asks the reviewer to verify the approved optional work-discipline
  first slice, stable canonical homes, and no push / tag / publish / history
  rewrite / private-plan movement
- `Prev reviewed tip:` is the actual implementation-plan commit that most
  recently passed plan/rule-review or fix-confirmation

Expected:

- The handoff uses `Status: review-needed`.
- No `Execution route:` block is present because this is a review handoff.
- `Review:` is `full`, not `none-FYI`.
