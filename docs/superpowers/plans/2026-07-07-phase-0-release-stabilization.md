# Phase 0 Release Stabilization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repair the stale F5 smoke expectations so the current v0.5.0 local `main` stack returns to review-ready without changing doctrine, ROADMAP truth, release metadata, or Phase 1 scope.

**Architecture:** Use the already-failing `tests/cross-repo-reference-map-smoke.sh` as the red test. Keep the stable F5 assertions and remove only moving-state pins for follow-up candidate rows, candidate rationale text, and exact historical plugin metadata versions. No helper scripts, parsers, release metadata, roadmap edits, or doctrine edits are introduced.

**Tech Stack:** Bash smoke tests, git, Agent Trigger Kit session-check, markdown plan/spec docs.

## Global Constraints

- Modify only `tests/cross-repo-reference-map-smoke.sh` for implementation.
- Do not edit `ROADMAP.md`.
- Do not edit `.claude-plugin/plugin.json` or `.claude-plugin/marketplace.json`.
- Do not edit `skills/**` doctrine files.
- Do not add release metadata, release tags, publishing steps, adopting-repo updates, or Phase 1 doctrine work.
- Drop stale moving-state assertions at `tests/cross-repo-reference-map-smoke.sh` lines 80-85 and 87-88.
- Keep stable F5 invariants: map file/content tokens, README/SKILL pointers, Must Read exclusion, append-only `v0.4.11: F5 cross-repo reference map` shipped-log line, retired F5 candidate absence, and install propagation.
- Do not re-pin to current candidate-table contents or current exact plugin metadata versions.
- Carry the accepted residual when session-check emits the documented source-repo boundary: `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.
- Close implementation with `Status: review-needed`, `User action: self-review -> to-reviewer`, and `Review: full`.

---

## File Plan

- Modify `tests/cross-repo-reference-map-smoke.sh`: remove the eight stale moving-state assertions and leave the stable F5 ROADMAP assertions adjacent to install propagation.
- Update `docs/superpowers/plans/2026-07-07-phase-0-release-stabilization.md`: mark execution checkboxes as work proceeds.

### Task 1: Repair Cross-Repo Reference Map Smoke

**Files:**
- Modify: `tests/cross-repo-reference-map-smoke.sh:78-88`
- Update: `docs/superpowers/plans/2026-07-07-phase-0-release-stabilization.md`

**Interfaces:**
- Consumes: Approved design spec `docs/superpowers/specs/2026-07-07-phase-0-release-stabilization-design.md` at `843ba4d`.
- Produces: `tests/cross-repo-reference-map-smoke.sh` that checks stable F5 invariants only and exits 0 on the current v0.5.0 branch.

- [x] **Step 1: Verify the intended checkout and current branch state**

Run:

```bash
git status -sb
git rev-parse --show-toplevel
```

Expected:

```text
/Users/jackchou/Desktop/agent-skills
```

`git status -sb` must show branch `main` with no unstaged, staged, or
untracked files except this plan file if it has not yet been committed. Any
ahead count is acceptable because this repo is intentionally ahead of
`origin/main` during the release train.

- [x] **Step 2: Reproduce the existing red smoke**

Run:

```bash
tests/cross-repo-reference-map-smoke.sh
```

Expected: exit 1 with this first fail-fast message:

```text
CROSS-REPO REFERENCE MAP SMOKE FAIL: ROADMAP.md missing token: | agent-skills doctrine | Relay copy-block completeness self-check |
```

This confirms the existing test still pins moving candidate-table state.

- [x] **Step 3: Remove moving-state assertions**

In `tests/cross-repo-reference-map-smoke.sh`, replace the current ROADMAP / metadata block:

```bash
require_contains ROADMAP.md 'v0.4.11: F5 cross-repo reference map'
require_not_contains ROADMAP.md '| agent-skills doctrine | F5 cross-repo reference map |'
require_contains ROADMAP.md '| agent-skills doctrine | Branch / worker lifecycle hygiene |'
require_contains ROADMAP.md 'simultaneous editing in shared checkouts'
require_contains ROADMAP.md '| agent-skills doctrine | Relay copy-block completeness self-check |'
require_contains ROADMAP.md 'pre-handoff checklist'
require_contains ROADMAP.md '`Review:` contract for the immediate next agent'
require_contains ROADMAP.md 'preserves review findings inside the fenced copy block'

require_contains .claude-plugin/plugin.json '"version": "0.4.11"'
require_contains .claude-plugin/marketplace.json '"version": "0.4.11"'
```

with this stable F5-only block:

```bash
require_contains ROADMAP.md 'v0.4.11: F5 cross-repo reference map'
require_not_contains ROADMAP.md '| agent-skills doctrine | F5 cross-repo reference map |'
```

Do not add replacement checks for current candidate-table rows or exact plugin versions.

- [x] **Step 4: Run the focused green smoke**

Run:

```bash
tests/cross-repo-reference-map-smoke.sh
```

Expected: exit 0 and output ending with:

```text
cross-repo reference map smoke ok
```

- [x] **Step 5: Run full Phase 0 verification**

Run:

```bash
agent-trigger-kit session-check
tests/install-smoke.sh
tests/source-entrypoint-smoke.sh
tests/cross-repo-reference-map-smoke.sh
git diff --check
git diff --check origin/main..HEAD
git status -sb
```

Expected:

```text
agent-trigger-kit session-check
```

may exit 1 only with:

```text
agent-skills: plugin directory missing
- None
```

The output must include `Unmarked outcome events since` followed by `- None`;
the timestamp in that heading changes between runs.

Expected smoke results:

```text
install smoke ok
source entrypoint smoke ok
cross-repo reference map smoke ok
```

Expected git checks:

```text
git diff --check
git diff --check origin/main..HEAD
```

both print nothing and exit 0. `git status -sb` shows only the intended modified plan/test files before the commit.

- [x] **Step 6: Commit the smoke repair and plan progress**

Mark the completed checkboxes in this plan, then run:

```bash
git add tests/cross-repo-reference-map-smoke.sh docs/superpowers/plans/2026-07-07-phase-0-release-stabilization.md
git commit -m "test: repair phase 0 cross-repo smoke"
```

Expected: commit succeeds with only the test and this plan file changed.

### Task 2: Final Review Handoff

**Files:**
- Update: `docs/superpowers/plans/2026-07-07-phase-0-release-stabilization.md`

**Interfaces:**
- Consumes: Task 1 commit and verification output.
- Produces: Review-ready closeout relay for the Phase 0 stale-smoke stabilization patch.

- [x] **Step 1: Re-run final status checks after the commit**

Run:

```bash
git status -sb
git log --oneline -3
```

Expected: working tree is clean; latest commit is `test: repair phase 0 cross-repo smoke`.

- [x] **Step 2: Prepare the final relay**

Run:

```bash
HEAD_SHA="$(git rev-parse --short HEAD)"
: "${PLAN_REVIEWED_TIP:?set PLAN_REVIEWED_TIP to the Phase 0 plan-review pass tip named in the approval relay}"
printf '%s\n' \
  'Status: review-needed' \
  'Target repo: /Users/jackchou/Desktop/agent-skills' \
  "Target: Phase 0 release stabilization implementation @ $HEAD_SHA" \
  'Required user text: n/a' \
  'User action: self-review -> to-reviewer' \
  'Next agent action: review the single-file smoke repair, full verification output, absence of ROADMAP / metadata / skills doctrine changes, and accepted ATK root-source residual before merge or next Phase 1 planning' \
  'Blockers: none' \
  'Accepted residuals: ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up' \
  '' \
  'Review: full' \
  'Focus: Confirm only moving-state pins at cross-repo-reference-map-smoke.sh lines 80-85 and 87-88 were removed, stable F5 invariants remain, and no current release state was re-pinned.' \
  "Prev reviewed tip: $PLAN_REVIEWED_TIP"
```

Expected: the command prints a relay block with the actual short `HEAD` SHA
embedded in the `Target:` line and the Phase 0 plan-review pass tip from the
approval relay embedded in the `Prev reviewed tip:` line. If
`PLAN_REVIEWED_TIP` is unset, the command fails before printing a malformed
relay.

- [x] **Step 3: Commit final plan checkbox progress if changed**

If Task 2 checkbox updates changed this plan after Task 1's commit, run:

```bash
git add docs/superpowers/plans/2026-07-07-phase-0-release-stabilization.md
git commit -m "docs: mark phase 0 stabilization plan closeout"
```

Expected: commit succeeds with only this plan file changed. If no checkbox changes remain, skip the commit and mention that no plan-progress commit was needed.

## Self-Review Notes

- Spec coverage: Task 1 covers the eight stale moving-state assertions, keeps stable F5 invariants, and forbids ROADMAP / metadata / doctrine edits. Task 2 covers review-needed closeout and accepted residual handling.
- Placeholder scan: no `TBD`, `TODO`, incomplete implementation instructions, or "similar to" shortcuts remain.
- Type / interface consistency: this plan has no code-level exported interfaces; the shell script keeps the existing helper functions and removes only call sites for stale assertions.
