# Relay Copy-Block Self-Check Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the v0.4.12 relay copy-block pre-handoff self-check doctrine, execution-route display gating, smoke coverage, roadmap entry, extraction-candidate retirement, and plugin metadata bump after the updated spec / plan review approves it.

**Architecture:** Keep the new behavior inside the existing Agent Operating Manual relay contract as a compact pointer checklist. Installer smoke proves the installed manual carries the new anchor and representative checklist tokens, including route-display gating; ROADMAP and `.claude-plugin` metadata record the release increment.

**Tech Stack:** Markdown doctrine, Bash smoke test, JSON plugin metadata, Git.

---

## Source Contract

- Base this work on approved spec commit `8f243ea` plus the branch-local route-display UX delta in this review pass.
- Do not resume implementation until the updated spec and plan receive fresh review.
- Implement on this work branch; merge to `main` only after fresh review.
- Keep the self-check inline in `skills/agent-operating-manual/10-model-dispatch.md` section 3.1.
- Add a compact pointer checklist. Do not duplicate section 3.1 rules as a second normative home.
- Do not add an attestation line, checklist dump, new relay field, or new `Status:` value.
- Keep exact approval / disposition text only in `Required user text`; human-facing prose may only say that the current chat is waiting for a user reply.
- Include `Execution route:` only on an executable approval / continuation handoff consumed by the agent/chat that will execute the routed work, after all required review / fix-confirmation gates on that routed work are complete, and where any named user approval or continuation reply would directly authorize that execution.
- Omit `Execution route:` from blocked, review-only, plan-review, findings-delivery, fix-confirmation-delivery, and other cross-chat delivery handoffs.
- Do not change Agent Trigger Kit, `operator-bootstrap`, adopting repos, generated imported copies, release tags, or the deferred F2 section 3.1 file split.
- Known non-blocking source-repo residual: `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## File Plan

- Modify `tests/install-smoke.sh`: add installed-manual token checks for `Pre-handoff self-check`, `current chat is waiting for a user reply`, `executable approval / continuation handoff`, `exactly one \`text\` fenced copy block`, and `three-line \`Review:\` contract`.
- Modify `skills/agent-operating-manual/10-model-dispatch.md`: add one reply-prompt sentence to `User notes rule`, one display-timing sentence to the route rules block, then add the compact `Pre-handoff self-check` subsection near the end of section 3.1 after the rules it references.
- Modify `ROADMAP.md`: add a v0.4.12 landed entry and remove the `Relay copy-block completeness self-check` Extraction Candidate row.
- Modify `.claude-plugin/plugin.json`: bump version to `0.4.12`.
- Modify `.claude-plugin/marketplace.json`: bump the `agent-skills` plugin version to `0.4.12`.
- Update this plan's checkboxes as each step lands.

---

### Task 1: Add Failing Install Smoke Tokens

**Files:**
- Modify: `tests/install-smoke.sh`
- Update: `docs/superpowers/plans/2026-07-07-relay-copy-block-self-check.md`

- [x] **Step 1: Add installed-manual smoke assertions**

In `tests/install-smoke.sh`, after the existing `User action consistency rule` assertion, add:

```bash
  grep -Fq 'Pre-handoff self-check' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing pre-handoff self-check"
  grep -Fq 'current chat is waiting for a user reply' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing reply-required-text human prompt check"
  grep -Fq 'executable approval / continuation handoff' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing execution-route gating check"
  grep -Fq 'exactly one `text` fenced copy block' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing exactly-one copy block check"
  grep -Fq 'three-line `Review:` contract' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing review contract copy check"
```

- [x] **Step 2: Run install smoke and verify it fails for the right reason**

Run:

```bash
./tests/install-smoke.sh
```

Expected: exit `1` with `SMOKE FAIL: CLAUDE.md imported manual missing pre-handoff self-check`.

- [x] **Step 3: Commit the failing smoke test and plan progress**

Run:

```bash
git add tests/install-smoke.sh docs/superpowers/plans/2026-07-07-relay-copy-block-self-check.md
git commit -m "test: add relay self-check smoke tokens"
```

Expected: commit succeeds. The new smoke test is expected to fail until Task 2 adds the manual subsection. If a prior local commit already added a narrower smoke version, amend or add a follow-up test commit that includes the `executable approval / continuation handoff` token before continuing to Task 2.

---

### Task 2: Add Doctrine, Roadmap, And Metadata

**Files:**
- Modify: `skills/agent-operating-manual/10-model-dispatch.md`
- Modify: `ROADMAP.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Update: `docs/superpowers/plans/2026-07-07-relay-copy-block-self-check.md`

- [x] **Step 1: Add the route/reply rule-home sentences and compact pre-handoff self-check subsection**

In `skills/agent-operating-manual/10-model-dispatch.md`, update `User notes rule` by adding this sentence before `` `Required user text` 仍是 exact approval / disposition text 的唯一 home。``:

```markdown
若 `User action:` 含 `reply-required-text`，copy block 外的人類說明應清楚表示 current chat is waiting for a user reply，但不得複製 exact approval / disposition text。
```

In the same file, update the route rules block by adding this sentence after the paragraph that defines `Execution route:`, `Route reason:`, and `User approval needed:`:

```markdown
Route display rule：`Execution route:` 只出現在 executable approval / continuation handoff：承接者就是會執行 routed work 的 agent/chat、該 routed work 的所有必要 review / fix-confirmation gate 已完成，且任何 named user approval / continuation reply 會依既有 approval-to-execute rule 直接授權該執行；blocked、review-only、plan-review，或 cross-chat delivery handoffs（例如 findings delivery、fix-confirmation delivery）不顯示 route block。
```

Then insert this subsection after the `Normative control-contract changes` paragraphs and before the `---` divider that starts section 4:

```markdown
Pre-handoff self-check：送出 handoff 前，先默默跑一次這個 compact checklist；不要輸出 attestation、checklist dump、新 relay 欄位或新 `Status:`。若任何項目不成立，先修 handoff 再送出。

- `Status:` 是否是合法 relay status？
- `Review:` 是否和 `Status:`、`User action:` 一致；若出現 `Execution route:`，是否符合 Route display rule 的 executable approval / continuation handoff，而不是 blocked、review-only、plan-review、findings-delivery 或 fix-confirmation-delivery handoff？
- 需要 exact approval / disposition text 時，`Required user text:` 是否非 `n/a` 且精確；若 `User action:` 含 `reply-required-text`，copy block 外的人類說明是否清楚表示 current chat is waiting for a user reply，且沒有複製 exact text？
- 有 repo-specific next action 時，`Target repo:` 是否非 `n/a`？
- `User action:` 含 `to-reviewer` 或 `to-agent` 時，是否只有 exactly one `text` fenced copy block 供使用者轉貼？
- 該 copy block 是否包含完整 relay block 與 three-line `Review:` contract？
- 對下一個 agent 有意義的 review findings、author dispositions、verification state、user notes 是否在 copy block 內；不確定時是否偏向 Full-context copy rule？
- 報告含 non-blocking findings、FYI、accepted residuals 或 out-of-repo follow-ups 時，`Accepted residuals:` 是否不是 `none`，且每項都有 durable tracker / owner？
```

- [x] **Step 2: Record the v0.4.12 ROADMAP landed entry**

In `ROADMAP.md`, add this landed entry after the v0.4.11 entry:

```markdown
- v0.4.12: relay copy-block self-check adds a compact pre-handoff
  checklist for legal relay status, cross-field coherence, forwarded copy
  block completeness, visible user-reply prompts, execution-route display
  gating, and accepted residuals without adding a second normative home or
  emitted attestation.
```

- [x] **Step 3: Retire the extraction candidate row**

Remove this row from `ROADMAP.md` after the landed entry exists:

```markdown
| agent-skills doctrine | Relay copy-block completeness self-check | agent-skills | Needs a pre-handoff checklist that validates legal `Status:` values, `User action:` / `Next agent action:` pairing, a single fenced copy block when forwarding to another agent, the `Review:` contract for the immediate next agent, and preserves review findings inside the fenced copy block. |
```

- [x] **Step 4: Bump plugin metadata to 0.4.12**

Change `.claude-plugin/plugin.json` to:

```json
{
  "name": "agent-skills",
  "version": "0.4.12",
  "description": "Portable agent doctrine skills: agent-operating-manual (dispatch economy), multi-angle-review (adversarial review pipeline), and optional skill-authoring.",
  "skills": [
    "./skills/"
  ]
}
```

Change `.claude-plugin/marketplace.json` `plugins[0].version` from `0.4.11` to `0.4.12`. Leave all other fields unchanged.

- [x] **Step 5: Run focused token scan**

Run:

```bash
rg -n 'Pre-handoff self-check|current chat is waiting for a user reply|executable approval / continuation handoff|exactly one `text` fenced copy block|three-line `Review:` contract|Target repo|Required user text|Accepted residuals|v0\.4\.12|0\.4\.12' skills/agent-operating-manual ROADMAP.md tests .claude-plugin
```

Expected: output includes the new manual subsection, the execution-route gating token, the ROADMAP v0.4.12 entry, installed-smoke checks, and both plugin metadata versions.

- [x] **Step 6: Run install smoke and verify it passes**

Run:

```bash
./tests/install-smoke.sh
```

Expected: PASS with `install smoke ok`.

- [x] **Step 7: Commit doctrine, roadmap, metadata, and plan progress**

Run:

```bash
git add skills/agent-operating-manual/10-model-dispatch.md ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json docs/superpowers/plans/2026-07-07-relay-copy-block-self-check.md
git commit -m "docs: add relay copy-block self-check"
```

Expected: commit succeeds.

---

### Task 3: Final Verification And Review Handoff

**Files:**
- Update: `docs/superpowers/plans/2026-07-07-relay-copy-block-self-check.md`

- [ ] **Step 1: Run final verification**

Run:

```bash
agent-trigger-kit session-check --closeout
./tests/install-smoke.sh
git diff --check
rg -n 'Pre-handoff self-check|current chat is waiting for a user reply|executable approval / continuation handoff|exactly one `text` fenced copy block|three-line `Review:` contract|Target repo|Required user text|Accepted residuals|v0\.4\.12|0\.4\.12' skills/agent-operating-manual ROADMAP.md tests .claude-plugin
git status -sb
```

Expected: `session-check --closeout` exits `1` only for the documented `agent-skills: plugin directory missing` source-repo boundary and possibly the related plugin freshness advisory; install smoke passes; `git diff --check` is clean; token scan includes the v0.4.12 surfaces and execution-route gating token; status is clean on `worktree-v0.4.12-relay-self-check`.

- [ ] **Step 2: Commit final plan progress if changed**

Run:

```bash
git add docs/superpowers/plans/2026-07-07-relay-copy-block-self-check.md
git commit -m "docs: mark relay self-check plan closeout"
```

Expected: commit succeeds if the plan checkbox update changed the file. If there is no staged plan change, do not create an empty commit.

- [ ] **Step 3: Prepare final handoff**

Use this relay shape:

```text
Status: review-needed
Target repo: /private/tmp/agent-skills-v0.4.12-relay-self-check
Target: v0.4.12 relay copy-block self-check implementation @ <head-sha>
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review the pre-handoff self-check doctrine, smoke coverage, ROADMAP landed/retired rows, metadata 0.4.12, and absence of ATK/operator-bootstrap/adopting-repo/release-tag changes
Blockers: none
Accepted residuals: ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up; ATK plugin-version-freshness advisory indeterminate from same root-source cause / owner: Agent Trigger Kit follow-up; origin/main behind local main / push at or before v0.4.12 closeout / owner: user

Review: full
Focus: Pointer-checklist constraint, no emitted attestation or second normative home, reply-required-text UX clarity, Execution route gating after review completion, and install-smoke coverage.
Prev reviewed tip: <tip approved by fix-confirmation after 7336a9c>
```

---

## Self-Review Notes

- Spec coverage: Task 1 covers smoke-first verification; Task 2 covers reply-prompt and route-display rule homes, checklist pointers, ROADMAP, extraction-row retirement, metadata, token scan, and install smoke; Task 3 covers closeout and final review handoff.
- Placeholder scan: this plan contains no placeholder markers or unspecified implementation steps.
- Scope check: this is one cohesive docs/test/metadata change and does not need decomposition.
