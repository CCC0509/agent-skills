# Handoff Trigger Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved v0.5.4 default `handoff-relay` trigger wrapper,
installer entry surface, smoke coverage, README / marketplace descriptions,
metadata bump, and ROADMAP closeout.

**Architecture:** Add one small top-level wrapper skill that is installed by
default and points agents to existing canonical relay, review, and
approval-bound object homes. Keep `10-model-dispatch.md` section 3.1,
`multi-angle-review/SKILL.md`, and `25-change-discipline.md` authoritative;
the wrapper is a trigger layer and a short checklist only.

**Tech Stack:** Markdown skills, Bash installer and smoke tests, JSON plugin
metadata, `rg`, `git`, Agent Trigger Kit session-check.

## Global Constraints

- Base this work on approved spec commit `2a19bb1` and reviewed base
  `fed6002`.
- Implement the reviewer disposition from the spec review:
  - F1: keep `F2 handoff-contract file split` and
    `Skill context loading / retrieval strategy` visible and open in
    `ROADMAP.md`; do not treat the new wrapper as solving those rows.
  - F2: acknowledge that adopters receive `handoff-relay` only through
    `--dev` installs until a later reviewed tag / publish action exists.
  - F3: report token-scan evidence per token in the implementation closeout.
- `handoff-relay` is a default install skill, not optional-only.
- The wrapper must not add relay fields, rename `Status:` values, change the
  `Review:` enum, move `10-model-dispatch.md` section 3.1, or duplicate the
  relay state machine.
- Do not define release tag / publish lifecycle, tag, publish, push release
  artifacts, edit adopting repos, edit generated imported copies, add Agent
  Trigger Kit validators, change session-check behavior, add vector / MCP
  retrieval, or extract `karpathy-guidelines`.
- End implementation with `Status: review-needed`, `Review: full`, and a fresh
  review request before any merge, tag, publish, or push approval gate.
- Known non-blocking source-repo residual:
  `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

---

## File Structure

- Create: `skills/handoff-relay/SKILL.md`
  Owns the new trigger-only wrapper, canonical file pointers, and small
  handoff checklist.
- Modify: `install.sh`
  Adds `handoff-relay` to default installs and injects one managed entry-pointer
  line for handoff / relay / approval forwarding work.
- Modify: `tests/install-smoke.sh`
  Proves default install copies `handoff-relay`, writes a managed sentinel,
  injects the entry pointer, preserves optional `skill-authoring` behavior, and
  keeps canonical tokens available in installed copies.
- Modify: `README.md`
  Names the new default skill and updates the default / explicit install
  examples.
- Modify: `.claude-plugin/plugin.json`
  Bumps metadata to `0.5.4` and names the new wrapper in the description.
- Modify: `.claude-plugin/marketplace.json`
  Bumps metadata to `0.5.4` and names the new wrapper in the marketplace
  description.
- Modify: `ROADMAP.md`
  Adds the v0.5.4 Landed entry while preserving neighboring open candidates.
- Update during execution:
  `docs/superpowers/plans/2026-07-07-handoff-trigger-split.md` checkboxes.

---

### Task 1: Red Install-Smoke Coverage

**Files:**
- Modify: `tests/install-smoke.sh`
- Modify: `docs/superpowers/plans/2026-07-07-handoff-trigger-split.md`

**Interfaces:**
- Consumes: current default install behavior from `install.sh`.
- Produces: failing smoke assertions that define the required wrapper install
  surface for Task 2.

- [ ] **Step 1: Confirm baseline and source health**

Run:

```bash
git rev-parse --short HEAD
git status --porcelain
agent-trigger-kit session-check
```

Expected:

- `git rev-parse --short HEAD` prints `2a19bb1` or a descendant created by this
  plan.
- `git status --porcelain` is empty before editing, except the plan checkbox
  update if this step is being marked after execution starts.
- `agent-trigger-kit session-check` exits `1` only with
  `agent-skills: plugin directory missing`, no failure categories, and no
  failure drivers.

- [ ] **Step 2: Extend the default-skill sentinel assertions**

In `tests/install-smoke.sh`, replace:

```bash
for s in agent-operating-manual multi-angle-review; do
```

with:

```bash
for s in agent-operating-manual handoff-relay multi-angle-review; do
```

- [ ] **Step 3: Assert the managed entry pointer is injected**

In the first install loop over `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md`, after
the existing `agent-operating-manual` pointer assertion, add:

```bash
  grep -Fq 'docs/imported-skills/handoff-relay/SKILL.md' "$TMP/target/$f" \
    || fail "$f missing handoff-relay pointer"
```

- [ ] **Step 4: Assert the installed wrapper keeps the trigger-only boundary**

In the same first install loop, after the `multi-angle-review` pointer assertion
and before the existing imported manual relay-token checks, add:

```bash
  grep -Fq 'trigger layer only' \
    "$TMP/target/docs/imported-skills/handoff-relay/SKILL.md" \
    || fail "$f imported handoff relay missing trigger-only boundary"
  grep -Fq '10-model-dispatch.md' \
    "$TMP/target/docs/imported-skills/handoff-relay/SKILL.md" \
    || fail "$f imported handoff relay missing relay canonical pointer"
  grep -Fq 'multi-angle-review/SKILL.md' \
    "$TMP/target/docs/imported-skills/handoff-relay/SKILL.md" \
    || fail "$f imported handoff relay missing review canonical pointer"
  grep -Fq '25-change-discipline.md' \
    "$TMP/target/docs/imported-skills/handoff-relay/SKILL.md" \
    || fail "$f imported handoff relay missing approval-bound pointer"
  grep -Fq 'Required user text' \
    "$TMP/target/docs/imported-skills/handoff-relay/SKILL.md" \
    || fail "$f imported handoff relay missing required-user-text reminder"
  grep -Fq 'Accepted residuals' \
    "$TMP/target/docs/imported-skills/handoff-relay/SKILL.md" \
    || fail "$f imported handoff relay missing accepted-residuals reminder"
```

- [ ] **Step 5: Keep explicit optional install aligned with the new default set**

In the optional `skill-authoring` section, replace:

```bash
bash "$TMP/src/install.sh" "$TMP/target" --skills agent-operating-manual,multi-angle-review,skill-authoring
```

with:

```bash
bash "$TMP/src/install.sh" "$TMP/target" --skills agent-operating-manual,handoff-relay,multi-angle-review,skill-authoring
```

After the existing `CLAUDE.md missing skill-authoring pointer` assertion, add:

```bash
[ "$(grep -Fc 'docs/imported-skills/handoff-relay/SKILL.md' "$TMP/target/CLAUDE.md")" = 1 ] \
  || fail "CLAUDE.md missing handoff-relay pointer with skill-authoring"
```

- [ ] **Step 6: Run the smoke test and verify the red failure**

Run:

```bash
bash tests/install-smoke.sh
```

Expected: exit `1` with this failure:

```text
SMOKE FAIL: missing handoff-relay/SKILL.md
```

- [ ] **Step 7: Commit the red smoke coverage and checkbox update**

Run:

```bash
git add tests/install-smoke.sh docs/superpowers/plans/2026-07-07-handoff-trigger-split.md
git commit -m "test: add handoff relay install smoke"
```

Expected: commit succeeds. The smoke test is expected to fail until Task 2.

---

### Task 2: Wrapper, Installer, Docs, Metadata, And Roadmap

**Files:**
- Create: `skills/handoff-relay/SKILL.md`
- Modify: `install.sh`
- Modify: `README.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `ROADMAP.md`
- Modify: `docs/superpowers/plans/2026-07-07-handoff-trigger-split.md`

**Interfaces:**
- Consumes: red assertions from Task 1.
- Produces: default wrapper install surface and `0.5.4` metadata that Task 3
  verifies.

- [ ] **Step 1: Create the trigger-only wrapper skill**

Create `skills/handoff-relay/SKILL.md`:

```markdown
---
name: handoff-relay
description: "Use when preparing, reviewing, consuming, or forwarding agent handoffs, relay blocks, exact approval text, Status/User action decisions, Review contracts, or paste-ready copy blocks."
---

# Handoff Relay

This is a trigger layer only. Canonical relay semantics live in the Agent
Operating Manual and Multi-Angle Review. If this wrapper appears to conflict
with a canonical file, follow the canonical file and fix this wrapper.

## Must Read

- [`../agent-operating-manual/10-model-dispatch.md`](../agent-operating-manual/10-model-dispatch.md) §3.1 — relay fields, copy-block formatting, `Status:` semantics, exact approval text, `User action`, `Accepted residuals`, and execution-route display rules.
- [`../multi-angle-review/SKILL.md`](../multi-angle-review/SKILL.md) — read when a review, plan/rule-review, fix-confirmation, requested-changes revision, or review-passed continuation is involved.
- [`../agent-operating-manual/25-change-discipline.md`](../agent-operating-manual/25-change-discipline.md) — read when the handoff touches PR, merge, tag, publish, deploy, release, or another approval-bound object.

## Apply

1. Classify the immediate next action before writing or consuming a handoff.
2. If review is pending, stop at a review-needed handoff and include the copy
   block the user should forward to a reviewer.
3. If exact user approval is pending, put the exact text only in
   `Required user text`; surrounding prose can say the chat is waiting.
4. If the user must forward context to a reviewer or acting agent, emit exactly
   one `text` fenced copy block containing the complete relay block and
   `Review:` contract.
5. Put every non-blocking finding, FYI, external follow-up, or accepted gap in
   `Accepted residuals:` with a durable owner.
6. Do not add relay fields, rename `Status:` values, change the `Review:` enum,
   or copy the full relay state machine into this wrapper.
```

- [ ] **Step 2: Add `handoff-relay` to default install order**

In `install.sh`, replace:

```bash
DEFAULT_SKILLS="agent-operating-manual,multi-angle-review"
```

with:

```bash
DEFAULT_SKILLS="agent-operating-manual,handoff-relay,multi-angle-review"
```

- [ ] **Step 3: Add the entry-pointer line**

In the `case "$name" in` block in `install.sh`, after the
`agent-operating-manual)` case and before `multi-angle-review)`, add:

```bash
    handoff-relay)
      POINTER_LINES="${POINTER_LINES}Agent handoff / relay / approval / reviewer forwarding 時讀 [$DEST/handoff-relay/SKILL.md]($DEST/handoff-relay/SKILL.md)。
" ;;
```

- [ ] **Step 4: Update README skill list and install examples**

In `README.md`, add this row after `agent-operating-manual`:

```markdown
| [`skills/handoff-relay/`](skills/handoff-relay/SKILL.md) | handoff / relay / exact approval trigger surface：交接、review、核准文字、copy block |
```

Replace:

```markdown
Default install 只包含 `agent-operating-manual,multi-angle-review`。
```

with:

```markdown
Default install 只包含 `agent-operating-manual,handoff-relay,multi-angle-review`。
```

Replace:

```bash
./install.sh <target-repo-path> --skills agent-operating-manual,multi-angle-review,skill-authoring
```

with:

```bash
./install.sh <target-repo-path> --skills agent-operating-manual,handoff-relay,multi-angle-review,skill-authoring
```

- [ ] **Step 5: Update plugin metadata**

Replace `.claude-plugin/plugin.json` with:

```json
{
  "name": "agent-skills",
  "version": "0.5.4",
  "description": "Portable agent doctrine skills: agent-operating-manual (dispatch economy), handoff-relay (handoff / approval trigger surface), multi-angle-review (adversarial review pipeline), and optional skill-authoring.",
  "skills": [
    "./skills/"
  ]
}
```

In `.claude-plugin/marketplace.json`, set the plugin entry to:

```json
{
  "name": "agent-skills",
  "owner": {
    "name": "Jack Chou"
  },
  "metadata": {
    "description": "Portable agent doctrine skills: dispatch economy, handoff relay, adversarial review, and skill authoring"
  },
  "plugins": [
    {
      "name": "agent-skills",
      "source": "./",
      "description": "Portable agent doctrine skills: agent-operating-manual (dispatch economy), handoff-relay (handoff / approval trigger surface), multi-angle-review (adversarial review pipeline), and optional skill-authoring.",
      "version": "0.5.4",
      "author": {
        "name": "Jack Chou"
      },
      "category": "workflow",
      "strict": false
    }
  ]
}
```

- [ ] **Step 6: Add the v0.5.4 ROADMAP Landed entry without closing neighbors**

In `ROADMAP.md`, add this Landed item after v0.5.3:

```markdown
- v0.5.4: default handoff-relay trigger wrapper adds a small install-facing
  handoff / relay / exact-approval entry surface, keeps relay semantics
  canonical in Agent Operating Manual section 3.1 and review behavior in
  multi-angle-review, and leaves F2 handoff-contract file split, skill context
  loading / retrieval, release tag / publish lifecycle, ATK mechanism,
  vector / MCP retrieval, and portable Karpathy-guidelines uplift open.
  Adopters need a later reviewed tag / publish train for non-dev delivery.
```

Do not delete or rewrite these candidate rows:

```text
F2 handoff-contract file split
Skill context loading / retrieval strategy
Release tag / publish lifecycle discipline
Portable work-discipline / Karpathy-guidelines uplift
```

- [ ] **Step 7: Run the install smoke and verify it passes**

Run:

```bash
bash tests/install-smoke.sh
```

Expected:

```text
install smoke ok
```

- [ ] **Step 8: Commit implementation surfaces and checkbox update**

Run:

```bash
git add skills/handoff-relay/SKILL.md install.sh README.md .claude-plugin/plugin.json .claude-plugin/marketplace.json ROADMAP.md docs/superpowers/plans/2026-07-07-handoff-trigger-split.md
git commit -m "docs: add handoff relay trigger wrapper"
```

Expected: commit succeeds.

---

### Task 3: Full Verification And Review Handoff

**Files:**
- Modify: `docs/superpowers/plans/2026-07-07-handoff-trigger-split.md`

**Interfaces:**
- Consumes: implementation from Tasks 1 and 2.
- Produces: verified implementation range ready for fresh review.

- [ ] **Step 1: Re-run install smoke**

Run:

```bash
bash tests/install-smoke.sh
```

Expected:

```text
install smoke ok
```

- [ ] **Step 2: Run whitespace check**

Run:

```bash
git diff --check
```

Expected: no output and exit `0`.

- [ ] **Step 3: Run per-token scan and record counts**

Run:

```bash
for token in \
  'handoff-relay' \
  'Handoff Relay' \
  'Status:' \
  'Review:' \
  'Required user text' \
  'Accepted residuals' \
  '10-model-dispatch.md' \
  'multi-angle-review' \
  '25-change-discipline.md' \
  'v0.5.4' \
  '0.5.4' \
  'F2 handoff-contract file split' \
  'Skill context loading / retrieval strategy' \
  'Release tag / publish lifecycle discipline' \
  'Portable work-discipline / Karpathy-guidelines uplift'
do
  count="$(rg -n --fixed-strings "$token" skills README.md ROADMAP.md tests .claude-plugin docs/superpowers/plans/2026-07-07-handoff-trigger-split.md | wc -l | tr -d ' ')"
  printf '%s\t%s\n' "$token" "$count"
  [ "$count" -gt 0 ] || exit 1
done
```

Expected: every token prints a count greater than `0`. Preserve the printed
counts in the review handoff summary so F3 is closed with per-token evidence.

- [ ] **Step 4: Verify ROADMAP neighbors remain open**

Run:

```bash
rg -n --fixed-strings 'F2 handoff-contract file split' ROADMAP.md
rg -n --fixed-strings 'Skill context loading / retrieval strategy' ROADMAP.md
rg -n --fixed-strings 'Release tag / publish lifecycle discipline' ROADMAP.md
rg -n --fixed-strings 'Portable work-discipline / Karpathy-guidelines uplift' ROADMAP.md
```

Expected: each command exits `0` and prints at least one live candidate-row hit,
not only the v0.5.4 Landed entry.

- [ ] **Step 5: Run closeout session-check**

Run:

```bash
agent-trigger-kit session-check --closeout
```

Expected: exit `1` only for `agent-skills: plugin directory missing`; outcome
summary has no failure categories and no failure drivers. If the plugin version
freshness advisory appears, carry it as part of the same ATK root-source
boundary residual unless new failure categories or drivers appear.

- [ ] **Step 6: Confirm git status and commit final plan progress**

Run:

```bash
git status -sb
git add docs/superpowers/plans/2026-07-07-handoff-trigger-split.md
git commit -m "docs: mark handoff relay verification"
```

Expected:

- `git status -sb` shows only the plan checkbox update before staging.
- Commit succeeds if the plan checkbox update is the only remaining change.
- If no checkbox update remains because a previous task already committed it,
  do not create an empty commit; record that in the handoff.

- [ ] **Step 7: Emit review-needed handoff**

Before writing the handoff, run:

```bash
git rev-parse --short HEAD
git log -1 --format=%h -- docs/superpowers/plans/2026-07-07-handoff-trigger-split.md
```

Use the first output as the implementation head and the second output as the
plan commit. Then emit one `text` fenced relay block with these field values:

- `Status: review-needed`
- `Target repo: /Users/jackchou/Desktop/agent-skills`
- `Target:` literal prefix `v0.5.4 handoff trigger split implementation @ `,
  then the implementation head output, then literal suffix
  ` (spec 2a19bb1, plan `, then the plan commit output, then `)`.
- `Required user text: n/a`
- `User action: self-review -> to-reviewer`
- `Next agent action:` ask the reviewer to review the v0.5.4 implementation
  range against spec `2a19bb1` and the plan commit output, including default
  wrapper install surface, trigger-only boundary, canonical-home stability,
  install smoke coverage, README / metadata / ROADMAP updates, and per-token
  scan counts.
- `Blockers: none`
- `Accepted residuals:` include the ATK root-source boundary, the closeout
  version-freshness advisory if present, and the `.claude/worktrees` local
  hygiene residue with the owner from AGENTS.md.
- `Review: full`
- `Focus:` default `handoff-relay` install behavior, trigger-only wrapper
  boundary, canonical relay / review / approval homes, ROADMAP neighbor
  preservation, metadata `0.5.4` without tag / publish authorization, and
  verification evidence.
- `Prev reviewed tip: 2a19bb1`
