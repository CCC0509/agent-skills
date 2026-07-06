# F4 Source Repo Entrypoint Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the `agent-skills` source-repo entrypoint, local worktree hygiene rules, smoke coverage, and v0.4.10 release metadata for F4.

**Architecture:** `AGENTS.md` becomes the single source-repo entrypoint for this repository. `CLAUDE.md` and `GEMINI.md` stay as thin pointers, while a focused Bash smoke test proves the source boundary, ignore rules, ATK health-boundary wording, and absence of self-install managed blocks.

**Tech Stack:** Markdown entrypoint doctrine, Bash smoke tests, JSON plugin metadata, Git.

---

## Source Contract

- Base this work on approved spec commit `f02bf71` on branch `worktree-f4-source-entrypoint`. If `docs/superpowers/specs/2026-07-06-f4-source-entrypoint-design.md` changes before implementation starts, stop and request a fresh spec review.
- This is a normative entrypoint and control-boundary change. It must stay plan-first and receive fresh review before merge.
- While implementing this branch, the governing contract is the last merged doctrine on `main`, plus user-level instructions and already-effective repo instructions. New root entrypoint text in this branch is proposal text until reviewed and merged.
- Run `agent-trigger-kit session-check` before source-repo edits when available. In this source repo, the current expected result is exit code `1` with `agent-skills: plugin directory missing`; treat that as the documented ATK root-source boundary, not as a request to create a fake plugin directory.
- Do not run `./install.sh` against this repository to adopt its own skills.
- Do not change `install.sh`, `README.md`, `skills/**`, adopting repos, operator-bootstrap files, Agent Trigger Kit files, release tags, or generated imported skill copies.
- Do not delete any existing `.claude/worktrees/**` local residue. F4 documents and ignores future scratch state; it is not a cleanup task.
- Because multiple worktrees may be open, record the intended worktree path at session start outside committed text. Confirm writes land in the current checkout with `git rev-parse --show-toplevel`, and derive any other checkout path at runtime from `git worktree list`.
- Final implementation closeout must include `Status: review-needed`, `User action: self-review -> to-reviewer`, and the accepted residual `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up` whenever the session-check root-source failure is still present.

## File Plan

- Create `AGENTS.md`: canonical source-repo entrypoint for source layout, self-install boundary, effective-contract boundary, worktree hygiene, and ATK health-boundary handling.
- Create `CLAUDE.md`: thin Claude Code pointer to `AGENTS.md`; no duplicated doctrine and no managed install block.
- Create `GEMINI.md`: thin Gemini pointer to `AGENTS.md`; no duplicated doctrine and no managed install block.
- Create `.gitignore`: ignore `.claude/worktrees/`, `/.worktrees/`, and `/worktrees/` scratch directories.
- Create `tests/source-entrypoint-smoke.sh`: smoke test for entrypoint files, pointer thinness, ignore rules, staging-boundary wording, ATK health-boundary wording, and self-install pollution absence.
- Modify `ROADMAP.md:36-55`: add v0.4.10 landed entry and remove the F4 Extraction Candidate row after the landed entry exists. Leave the existing `Shared checkout concurrency etiquette` row intact and do not add a duplicate.
- Modify `.claude-plugin/plugin.json:3`: bump version from `0.4.9` to `0.4.10`.
- Modify `.claude-plugin/marketplace.json:14`: bump `plugins[0].version` from `0.4.9` to `0.4.10`.
- Update this plan's checkboxes as each step lands.

### Task 1: Add Source Entrypoints and Smoke Test

**Files:**
- Create: `tests/source-entrypoint-smoke.sh`
- Create: `AGENTS.md`
- Create: `CLAUDE.md`
- Create: `GEMINI.md`
- Create: `.gitignore`
- Update: `docs/superpowers/plans/2026-07-07-f4-source-entrypoint.md`

- [x] **Step 1: Verify the intended checkout before edits**

Run:

```bash
INTENDED_WORKTREE_FILE="${TMPDIR:-/tmp}/agent-skills-f4-intended-worktree"
git rev-parse --show-toplevel > "$INTENDED_WORKTREE_FILE"
git rev-parse --abbrev-ref HEAD
git merge-base --is-ancestor f02bf71 HEAD && echo spec-ancestor-ok
git status --porcelain
agent-trigger-kit session-check
```

Expected: the first two commands record the intended checkout path in a session-local temp file outside the repo, `git rev-parse --abbrev-ref HEAD` reports `worktree-f4-source-entrypoint`, the merge-base command prints `spec-ancestor-ok`, `git status --porcelain` prints nothing, and `agent-trigger-kit session-check` exits `1` with `agent-skills: plugin directory missing`. Do not commit or paste the recorded worktree path into repo files.

- [x] **Step 2: Create the failing source-entrypoint smoke test**

Create `tests/source-entrypoint-smoke.sh` with this exact content:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "SOURCE ENTRYPOINT SMOKE FAIL: $1" >&2
  exit 1
}

require_file() {
  local file="$1"
  [ -f "$file" ] || fail "missing required file: $file"
}

require_contains() {
  local file="$1"
  local token="$2"
  grep -Fq "$token" "$file" || fail "$file missing token: $token"
}

require_exact_line() {
  local file="$1"
  local line="$2"
  grep -Fxq "$line" "$file" || fail "$file missing exact line: $line"
}

require_not_contains() {
  local file="$1"
  local token="$2"
  ! grep -Fq "$token" "$file" || fail "$file contains forbidden token: $token"
}

require_max_lines() {
  local file="$1"
  local max="$2"
  local count
  count="$(wc -l < "$file" | tr -d ' ')"
  [ "$count" -le "$max" ] || fail "$file has $count lines, expected at most $max"
}

for entry in AGENTS.md CLAUDE.md GEMINI.md; do
  require_file "$entry"
  require_not_contains "$entry" '<!-- agent-skills:begin -->'
  require_not_contains "$entry" '<!-- agent-skills:end -->'
done

require_contains AGENTS.md 'This checkout is the `agent-skills` source repo'
require_contains AGENTS.md 'not an adopting repo'
require_contains AGENTS.md 'not an install target'
require_contains AGENTS.md 'Source doctrine lives under `skills/**`'
require_contains AGENTS.md 'Design specs and implementation plans live under `docs/superpowers/**`'
require_contains AGENTS.md 'Release metadata lives under `.claude-plugin/**`'
require_contains AGENTS.md 'Do not run `./install.sh` against this repo'
require_contains AGENTS.md 'Do not edit generated imported copies in adopting repos'
require_contains AGENTS.md 'plan-first'
require_contains AGENTS.md 'fresh review before merge'
require_contains AGENTS.md 'last merged doctrine on `main`'
require_contains AGENTS.md 'proposal text inside the branch'
require_contains AGENTS.md 'git diff --name-only "$(git merge-base HEAD origin/main)"..HEAD -- skills/ AGENTS.md CLAUDE.md GEMINI.md'
require_contains AGENTS.md '/tmp/<repo>-<branch>'
require_contains AGENTS.md '.worktrees/'
require_contains AGENTS.md '.claude/worktrees/'
require_contains AGENTS.md 'git status -sb'
require_contains AGENTS.md 'git rev-parse --show-toplevel'
require_contains AGENTS.md 'edit tool'
require_contains AGENTS.md 'git restore <path>'
require_contains AGENTS.md 'git checkout -- <path>'
require_contains AGENTS.md 'never delete pre-existing or user-authored content'
require_contains AGENTS.md 'agent-trigger-kit session-check'
require_contains AGENTS.md 'agent-skills: plugin directory missing'
require_contains AGENTS.md 'root-level plugin layout'
require_contains AGENTS.md 'source: "./"'
require_contains AGENTS.md 'ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up'
require_contains AGENTS.md 'Verification notes may add detail, but they are not a substitute for `Accepted residuals`'

require_contains CLAUDE.md 'See [AGENTS.md](AGENTS.md)'
require_contains CLAUDE.md 'thin pointer for Claude Code'
require_contains GEMINI.md 'See [AGENTS.md](AGENTS.md)'
require_contains GEMINI.md 'thin pointer for Gemini'
require_max_lines CLAUDE.md 6
require_max_lines GEMINI.md 6

require_file .gitignore
require_exact_line .gitignore '.claude/worktrees/'
require_exact_line .gitignore '/.worktrees/'
require_exact_line .gitignore '/worktrees/'

echo "source entrypoint smoke ok"
```

- [x] **Step 3: Run the new smoke test and confirm it fails for the right reason**

Run:

```bash
bash tests/source-entrypoint-smoke.sh
```

Expected: FAIL with `SOURCE ENTRYPOINT SMOKE FAIL: missing required file: AGENTS.md`.

- [x] **Step 4: Add the canonical `AGENTS.md` source entrypoint**

Create `AGENTS.md` with this exact content:

```md
# agent-skills Source Entrypoint

This checkout is the `agent-skills` source repo for `CCC0509/agent-skills`. It is not an adopting repo, not an install target, and not a place to test self-installation.

## Source Layout

- Source doctrine lives under `skills/**`.
- Design specs and implementation plans live under `docs/superpowers/**`.
- Release metadata lives under `.claude-plugin/**`.

## Source-Repo Rules

- Do not run `./install.sh` against this repo to adopt its own skills.
- Do not edit generated imported copies in adopting repos as a substitute for source changes here.
- Normative doctrine, relay, review, approval, release, and entrypoint changes are plan-first and end in fresh review before merge.

## Effective Contract Boundary

While editing this repo, the governing contract is the last merged doctrine on `main`, plus user-level instructions and already-effective repo instructions. Branch-local changes are proposals until reviewed and merged. Proposed text may be exercised early only when it is strictly more conservative than the effective contract, and never to authorize, relax, or skip a step the effective contract requires.

Check proposal status with:

```bash
git diff --name-only "$(git merge-base HEAD origin/main)"..HEAD -- skills/ AGENTS.md CLAUDE.md GEMINI.md
```

If that command lists doctrine or entrypoint files, new text in those files is proposal text inside the branch. Inspect it, but do not treat it as already-effective authority for that same branch.

## Worktree Hygiene

- Prefer external scratch worktrees in a system temp directory outside the repo, such as `/tmp/<repo>-<branch>` or the platform equivalent.
- If a project-local worktree is needed, use ignored `.worktrees/`.
- Do not create new worktrees under `.claude/worktrees/`.
- If `.claude/worktrees/` already exists, treat it as local hygiene residue: report it, do not commit it, and do not let it influence scope review.
- Before writing files, confirm the intended checkout with `git status -sb` or `git rev-parse --show-toplevel`.
- If an edit tool does not accept a workdir or there are multiple worktrees open, use paths rooted in the intended worktree and verify `git status -sb` in both the intended worktree and the main checkout after the first edit.
- If an accidental write lands in the wrong checkout, revert only what the write changed: delete the file only if it did not exist before the write and is untracked; if it modified a tracked file, restore it with `git restore <path>` or `git checkout -- <path>`; never delete pre-existing or user-authored content. Report the incident in the handoff.

## ATK Health Boundary

Run `agent-trigger-kit session-check` before source-repo edits when available. In this source repo, an exit 1 trigger-layer failure containing `agent-skills: plugin directory missing` is a known source-repo boundary: Agent Trigger Kit reads `.claude-plugin/marketplace.json`, sees the root-level plugin layout with `source: "./"`, normalizes it to an empty plugin directory, and reports it missing even though the plugin content is the repo root.

Do not create a fake plugin directory to silence that result. Continue with docs/planning work only when ordinary repo gates still pass. Defer ATK root-`"./"` source handling, validator/session-check semantics, and plugin layout changes to Agent Trigger Kit.

When a relay signal is present and this is the only trigger-layer failure, list this canonical accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`

Verification notes may add detail, but they are not a substitute for `Accepted residuals`.
```

- [x] **Step 5: Add thin `CLAUDE.md` and `GEMINI.md` pointers**

Create `CLAUDE.md` with this exact content:

```md
# Claude Entrypoint

See [AGENTS.md](AGENTS.md) for this repo's source-repo rules, effective-contract boundary, worktree hygiene, and ATK health-boundary handling.

Do not add an `agent-skills` managed install block here; this file is only a thin pointer for Claude Code.
```

Create `GEMINI.md` with this exact content:

```md
# Gemini Entrypoint

See [AGENTS.md](AGENTS.md) for this repo's source-repo rules, effective-contract boundary, worktree hygiene, and ATK health-boundary handling.

Do not add an `agent-skills` managed install block here; this file is only a thin pointer for Gemini.
```

- [x] **Step 6: Add local worktree scratch ignores**

Create `.gitignore` with this exact content:

```gitignore
.claude/worktrees/
/.worktrees/
/worktrees/
```

- [x] **Step 7: Make the smoke test executable and verify it passes**

Run:

```bash
chmod +x tests/source-entrypoint-smoke.sh
./tests/source-entrypoint-smoke.sh
```

Expected: PASS with `source entrypoint smoke ok`.

- [x] **Step 8: Verify writes landed in the intended worktree**

Run:

```bash
INTENDED_WORKTREE_FILE="${TMPDIR:-/tmp}/agent-skills-f4-intended-worktree"
INTENDED_WORKTREE="$(cat "$INTENDED_WORKTREE_FILE")"
CURRENT_WORKTREE="$(git rev-parse --show-toplevel)"
[ "$CURRENT_WORKTREE" = "$INTENDED_WORKTREE" ] && echo intended-worktree-ok
MAIN_WORKTREE="$(git worktree list --porcelain | sed -n '1s/^worktree //p')"
git status -sb
git -C "$MAIN_WORKTREE" status -sb
```

Expected: the checkout comparison prints `intended-worktree-ok`. The F4 worktree shows new `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.gitignore`, and `tests/source-entrypoint-smoke.sh`. The main checkout remains on its original branch and its status is unchanged from the pre-edit baseline; do not delete or commit local residue.

- [x] **Step 9: Commit Task 1**

Run:

```bash
git add AGENTS.md CLAUDE.md GEMINI.md .gitignore tests/source-entrypoint-smoke.sh docs/superpowers/plans/2026-07-07-f4-source-entrypoint.md
git commit -m "docs: add source repo entrypoint"
```

Expected: commit succeeds and contains only the root entrypoint files, `.gitignore`, the source-entrypoint smoke test, and this plan checkbox update.

### Task 2: Record v0.4.10 Roadmap and Metadata

**Files:**
- Modify: `ROADMAP.md:36-55`
- Modify: `.claude-plugin/plugin.json:3`
- Modify: `.claude-plugin/marketplace.json:14`
- Update: `docs/superpowers/plans/2026-07-07-f4-source-entrypoint.md`

- [ ] **Step 1: Add the v0.4.10 landed entry**

In `ROADMAP.md`, add this entry immediately after the v0.4.9 entry:

```md
- v0.4.10: F4 source-repo entrypoint adds canonical root AGENTS.md guidance,
  thin Claude / Gemini pointers, local worktree scratch ignore rules, and
  source-entrypoint smoke coverage for proposal boundaries, self-install
  pollution, and the documented ATK root-source health boundary.
```

- [ ] **Step 2: Remove the retired F4 Extraction Candidate row**

Remove this exact row from `ROADMAP.md` after the landed entry exists:

```md
| agent-skills doctrine | F4 source-repo entrypoint and staging-boundary mechanics | agent-skills | Follow-up branch for AGENTS.md source entrypoint, optional thin CLAUDE.md / GEMINI.md pointers, merge-base proposal checks, and scratch target / temp worktree adoption testing. |
```

Leave these two rows in place:

```md
| agent-skills doctrine | Shared checkout concurrency etiquette | agent-skills | Useful but outside v0.4 change-discipline scope; needs wording that fits multiple harnesses and shared-worktree policies. |
| agent-skills doctrine | F5 cross-repo reference map | agent-skills | Separate follow-up for documenting operator-bootstrap as machine/user layer, agent-skills as doctrine, and Agent Trigger Kit as mechanism without creating circular install dependencies. |
```

- [ ] **Step 3: Bump plugin metadata to 0.4.10**

Change `.claude-plugin/plugin.json` to this exact content:

```json
{
  "name": "agent-skills",
  "version": "0.4.10",
  "description": "Portable agent doctrine skills: agent-operating-manual (dispatch economy), multi-angle-review (adversarial review pipeline), and optional skill-authoring.",
  "skills": [
    "./skills/"
  ]
}
```

Change `.claude-plugin/marketplace.json` to this exact content:

```json
{
  "name": "agent-skills",
  "owner": {
    "name": "Jack Chou"
  },
  "metadata": {
    "description": "Portable agent doctrine skills: dispatch economy, adversarial review, and skill authoring"
  },
  "plugins": [
    {
      "name": "agent-skills",
      "source": "./",
      "description": "Portable agent doctrine skills: agent-operating-manual (dispatch economy), multi-angle-review (adversarial review pipeline), and optional skill-authoring.",
      "version": "0.4.10",
      "author": {
        "name": "Jack Chou"
      },
      "category": "workflow",
      "strict": false
    }
  ]
}
```

- [ ] **Step 4: Verify ROADMAP and metadata tokens**

Run:

```bash
rg -n "v0\\.4\\.10|F4 source-repo entrypoint|source-entrypoint smoke|\"version\": \"0\\.4\\.10\"" ROADMAP.md .claude-plugin
rg -n "F4 source-repo entrypoint and staging-boundary mechanics" ROADMAP.md
```

Expected: the first command shows the v0.4.10 ROADMAP entry and both metadata versions. The second command exits `1` with no output because the F4 Extraction Candidate row has been retired.

- [ ] **Step 5: Commit Task 2**

Run:

```bash
git add ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json docs/superpowers/plans/2026-07-07-f4-source-entrypoint.md
git commit -m "docs: record source entrypoint release"
```

Expected: commit succeeds and contains only ROADMAP, plugin metadata, and this plan checkbox update.

### Task 3: Run Full Verification and Prepare Review Handoff

**Files:**
- Update: `docs/superpowers/plans/2026-07-07-f4-source-entrypoint.md`

- [ ] **Step 1: Run session-check and classify the known boundary**

Run:

```bash
agent-trigger-kit session-check
```

Expected: exit code `1` with `agent-skills: plugin directory missing`. Record this in verification notes as `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`. Continue only if ordinary repo gates below pass.

- [ ] **Step 2: Run installer smoke**

Run:

```bash
./tests/install-smoke.sh
```

Expected: PASS with `install smoke ok`.

- [ ] **Step 3: Run source-entrypoint smoke**

Run:

```bash
./tests/source-entrypoint-smoke.sh
```

Expected: PASS with `source entrypoint smoke ok`.

- [ ] **Step 4: Run the explicit self-install pollution probe**

Run:

```bash
if rg -n '<!-- agent-skills:begin -->|<!-- agent-skills:end -->' AGENTS.md CLAUDE.md GEMINI.md; then
  echo "self-install pollution found" >&2
  exit 1
fi
```

Expected: exit code `0` with no `rg` matches and no `self-install pollution found` output.

- [ ] **Step 5: Run the F4 token scan**

Run:

```bash
rg -n "source repo|not an install target|last merged doctrine|proposal text|agent-skills: plugin directory missing|root-level plugin layout|\\.claude/worktrees|edit tool|self-install|v0\\.4\\.10|F4 source-repo" AGENTS.md CLAUDE.md GEMINI.md .gitignore ROADMAP.md tests .claude-plugin
```

Expected: output includes source-repo and self-install boundary hits in `AGENTS.md`, `.claude/worktrees` hits in `AGENTS.md`, `.gitignore`, and `tests/source-entrypoint-smoke.sh`, v0.4.10 and F4 source-repo hits in `ROADMAP.md` and `.claude-plugin/**`, and smoke-test coverage hits in `tests/source-entrypoint-smoke.sh`.

- [ ] **Step 6: Run whitespace and status checks**

Run:

```bash
git diff --check
INTENDED_WORKTREE_FILE="${TMPDIR:-/tmp}/agent-skills-f4-intended-worktree"
INTENDED_WORKTREE="$(cat "$INTENDED_WORKTREE_FILE")"
CURRENT_WORKTREE="$(git rev-parse --show-toplevel)"
[ "$CURRENT_WORKTREE" = "$INTENDED_WORKTREE" ] && echo intended-worktree-ok
MAIN_WORKTREE="$(git worktree list --porcelain | sed -n '1s/^worktree //p')"
git status -sb
git -C "$MAIN_WORKTREE" status -sb
```

Expected: `git diff --check` exits `0` and the checkout comparison prints `intended-worktree-ok`. The F4 worktree status shows only this plan file modified for Task 3 checkbox updates before the final commit. The main checkout remains on its original branch and its status is unchanged from the pre-edit baseline; local residue is not deleted or committed.

- [ ] **Step 7: Commit verification checkbox updates**

Run:

```bash
git add docs/superpowers/plans/2026-07-07-f4-source-entrypoint.md
git commit -m "docs: mark source entrypoint verification"
```

Expected: commit succeeds and contains only this plan checkbox update.

- [ ] **Step 8: Run closeout session-check**

Run:

```bash
agent-trigger-kit session-check --closeout
```

Expected: exit code `1` with `agent-skills: plugin directory missing` and no unmarked outcome events. Report it as the same accepted residual, not as an implementation blocker.

If closeout exits `4` because implementation work recorded unmarked outcome events, mark those events according to the session-check guidance when possible, then rerun closeout. After markable events are handled, the expected remaining closeout result is exit code `1` with only the known `agent-skills: plugin directory missing` boundary.

- [ ] **Step 9: Capture final review handoff fields**

Run:

```bash
git status -sb
git rev-parse HEAD
```

Expected: worktree clean on `worktree-f4-source-entrypoint`. The final implementation handoff uses these tokens:

```text
Status: review-needed
Target repo: CCC0509/agent-skills
Target: F4 source-repo entrypoint implementation on branch worktree-f4-source-entrypoint at the HEAD printed above
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review the F4 implementation against the approved spec and plan
Blockers: none
Accepted residuals: ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up

Review: full
Focus: F4 source-repo entrypoint, pointer thinness, worktree hygiene ignore rules, source-entrypoint smoke coverage, ROADMAP/metadata v0.4.10, and absence of self-install managed blocks
Prev reviewed tip: use the reviewed plan commit SHA
```

## Plan Self-Review

- Spec coverage: This plan implements the in-scope `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.gitignore`, source-entrypoint smoke test, v0.4.10 ROADMAP entry, F4 Extraction Candidate retirement, and metadata bump. It explicitly excludes F5, operator-bootstrap, Agent Trigger Kit validator/session-check mechanics, release tags, adopting repos, self-installation, and `.claude/worktrees/**` deletion.
- Verification coverage: The plan runs `agent-trigger-kit session-check`, `./tests/install-smoke.sh`, `./tests/source-entrypoint-smoke.sh`, `git diff --check`, the self-install pollution probe, the required token scan, target/main checkout status checks, and closeout session-check.
- Closeout coverage: The plan requires `Status: review-needed`, `User action: self-review -> to-reviewer`, and the canonical ATK root-source accepted residual when the known session-check boundary is present.
