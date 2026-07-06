# Handoff Relay Control Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tighten the `agent-skills` handoff / relay contract so downstream agents know which signal controls next action, which repo owns the next step, and when control-contract changes require plan-first review.

**Architecture:** Keep the behavioral change local to the shared Agent Operating Manual contract. `skills/agent-operating-manual/10-model-dispatch.md` owns the normative contract, `ROADMAP.md` records the landed doctrine increment, `.claude-plugin` metadata bumps the release train to `0.4.8`, and `tests/install-smoke.sh` probes stable imported-manual tokens instead of brittle full-line text.

**Tech Stack:** Markdown doctrine, JSON plugin metadata, Bash smoke test, existing install flow.

---

## Source Contract

- Scope is limited to the F1 handoff / relay ambiguity plus the newly requested target-repo routing field and plan/review gate for control-contract edits.
- Do not split §3.1 into a new handoff-contract file in this change. Keep that as the separate F2 IA backlog item.
- Do not change operator-bootstrap enum/source-of-truth behavior in this change. Keep that as a separate F3 repo change.
- Do not add the F4 repo entrypoint / staging-boundary mechanics in this change. Keep F4 as a follow-up branch after this plan is updated and re-confirmed.
- Do add durable ROADMAP extraction-candidate rows for the F2 and F4 deferrals referenced by the final relay.
- Do bump `.claude-plugin` version metadata to `0.4.8`, because `v0.4.7` is already tagged/released and this branch records a new landed doctrine increment.
- Do not change `install.sh`, release tags, generated imported files, or adopting repos.
- This change should close with `Status: review-needed`, not `complete-no-action-needed`, because it changes future agent control semantics.

## File Plan

- Modify `skills/agent-operating-manual/10-model-dispatch.md:71-143`: add the co-occurrence tie-breaker, add `Target repo:` to the relay block, define `Target repo` vs `Target`, harden `not-ready` relay authority, and add a plan/review gate plus in-flight staging boundary for handoff / relay / approval / review control-contract changes.
- Modify `ROADMAP.md:26-50`: add a new `v0.4.8` landed entry for this doctrine increment and add F2/F4 durable extraction-candidate rows.
- Modify `.claude-plugin/plugin.json`: bump `version` from `0.4.7` to `0.4.8`.
- Modify `.claude-plugin/marketplace.json`: bump the `agent-skills` plugin `version` from `0.4.7` to `0.4.8`.
- Modify `tests/install-smoke.sh:48-68`: add stable token assertions for the new contract vocabulary in the imported manual.

---

### Task 1: Manual Contract Semantics

**Files:**
- Modify: `skills/agent-operating-manual/10-model-dispatch.md:71-143`

- [ ] **Step 1: Add the Review/Status co-occurrence tie-breaker**

Insert this paragraph after the paragraph ending at line 74, before the paste-ready `text` block rule:

```markdown
Co-occurrence tie-breaker：三行 `Review:` 合約是 reviewer-facing context；`Status:` relay block 是 user-facing / next-action control signal。兩者同時出現時，consuming agent MUST follow `Status:` block 來判斷 immediate next action、approval state、blockers、accepted residuals。若作者想要 review，`Status` 必須是 `review-needed`；`Review:` alone must not override a `Status: complete-no-action-needed` relay。Contract block 欄位優先於 fenced block 外散文；只有 `Review:` 而沒有 `Status:` 的交接不授權 execution、approval、merge、deploy 或 release。
```

- [ ] **Step 2: Add `Target repo:` to the relay block**

Replace the current relay block:

```text
Status: <review-needed | ready-for-user-approval | complete-no-action-needed | not-ready>
Target: <PR/branch/task + head SHA, or n/a>
Required user text: <exact approval/merge text, or n/a>
Next agent action: <what another agent should do, or none>
Blockers: <none, or concise blockers>
Accepted residuals: <none | short finding label + disposition + durable tracker/owner>
```

with:

```text
Status: <review-needed | ready-for-user-approval | complete-no-action-needed | not-ready>
Target repo: <owner/repo or absolute local repo path, or n/a>
Target: <PR/branch/task + head SHA, or n/a>
Required user text: <exact approval/merge text, required user input, or n/a>
Next agent action: <what another agent should do, or none>
Blockers: <none, or concise blockers>
Accepted residuals: <none | short finding label + disposition + durable tracker/owner>
```

- [ ] **Step 3: Define `Target repo:` and preserve `Target:` meaning**

Add this paragraph after the relay block and before the `Accepted residuals` paragraph:

```markdown
`Target repo` 是 cross-repo handoff 的 durable routing field。已知 remote identity 時用 `owner/repo`；下一步依賴 local checkout 時用 absolute local repo path；只有沒有 repo-specific next action 時才用 `n/a`。`Target` 保持原本語意，只描述該 repo 內的 PR、branch、task、head SHA 或其他 work item。不要只把 intended repo 藏在 relay block 外的散文。
```

- [ ] **Step 4: Harden `not-ready` relay authority**

Add this paragraph after the Status 判準 bullet list and before the blocker retry paragraph:

```markdown
Relay readiness rule：`Status: not-ready` 不能搭配可立即執行的 `Next agent action`。若 blocker 是 pending user disposition，`Required user text` 必須明確寫出需要的裁決或文字，且 `Next agent action` 必須是 `none until user provides dispositions` 或同等不可執行描述。
```

- [ ] **Step 5: Add the control-contract plan/review gate and in-flight staging boundary**

Add this paragraph after the route gating paragraph ending at line 143, before the section divider:

```markdown
Normative control-contract changes：任何改變 handoff、relay、approval、review、route、blocker 或 completion semantics 的變更都需要額外謹慎。這類變更預設在 implementation 前使用 `Execution route: plan-first`，implementation 後使用 `Status: review-needed`。作者可以為 docs-only changes 使用較小的 inline plan，但 final relay 必須要求 fresh review，除非使用者在同一 session 明確 waive review。

這類變更 in flight 時，governing contract 是最後已 merge 的 doctrine；對 adopting repos 則是最後已 released tag，不是正在編輯的文字。新文字只在 fresh review 與 merge/release 後生效。Proposed text 只有在比 effective contract 更保守時可提前演練；絕不能用來授權、放寬或跳過 effective contract 要求的步驟。
```

- [ ] **Step 6: Verify the manual contract vocabulary**

Run:

```bash
rg -n "Co-occurrence tie-breaker|Target repo|owner/repo|Relay readiness rule|Normative control-contract changes|governing contract|released tag|plan-first|complete-no-action-needed|Review:" skills/agent-operating-manual/10-model-dispatch.md
```

Expected: output includes the new tie-breaker, the relay block `Target repo:` field, the `Target repo` definition, the `not-ready` relay readiness rule, the control-contract gate, the in-flight staging boundary, and the existing `Review:` and `complete-no-action-needed` references.

- [ ] **Step 7: Commit Task 1**

```bash
git add skills/agent-operating-manual/10-model-dispatch.md
git commit -m "docs: tighten handoff relay control contract"
```

---

### Task 2: Roadmap And Release Metadata

**Files:**
- Modify: `ROADMAP.md:26-31`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Record the landed doctrine increment**

Add this entry after the current v0.4.7 bullet:

```markdown
- v0.4.8: handoff / relay control contract clarifies `Review:` versus
  `Status:` precedence, adds `Target repo:` routing, hardens `not-ready`
  relay authority, and requires plan-first plus fresh review for normative
  control-contract changes.
```

- [ ] **Step 2: Bump plugin metadata to 0.4.8**

In `.claude-plugin/plugin.json`, replace:

```json
"version": "0.4.7"
```

with:

```json
"version": "0.4.8"
```

In `.claude-plugin/marketplace.json`, replace the `agent-skills` plugin version:

```json
"version": "0.4.7"
```

with:

```json
"version": "0.4.8"
```

- [ ] **Step 3: Add durable backlog trackers for F2 and F4**

Add these rows to the `ROADMAP.md` Extraction Candidates table:

```markdown
| agent-skills doctrine | F2 handoff-contract file split | agent-skills | Deferred from v0.4.8; splitting §3.1 needs anchor / link / residual scan after relay control semantics stabilize. |
| agent-skills doctrine | F4 source-repo entrypoint and staging-boundary mechanics | agent-skills | Follow-up branch for AGENTS.md source entrypoint, optional thin CLAUDE.md / GEMINI.md pointers, merge-base proposal checks, and scratch target / temp worktree adoption testing. |
```

- [ ] **Step 4: Keep F2, F3, and F4 out of this implementation scope**

Confirm the roadmap has durable F2/F4 Extraction Candidates, but no landed claim for F2/F3/F4:

```text
F2: splitting §3.1 into a separate handoff-contract file
F3: changing the operator-bootstrap enum/source-of-truth in another repo
F4: adding agent-skills source-repo entrypoints and repo-local staging mechanics
```

Run:

```bash
rg -n "F2 handoff-contract|F4 source-repo|operator-bootstrap|Target repo|control-contract|v0\\.4\\.8|v0\\.4\\.7" ROADMAP.md
rg -n '"version": "0\\.4\\.8"' .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

Expected: output shows the new v0.4.8 landed roadmap wording, F2/F4 only as Extraction Candidates, no claim that F2/F3/F4 was implemented in this branch, and both plugin metadata files at `0.4.8`.

- [ ] **Step 5: Commit Task 2**

```bash
git add ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "docs: record handoff relay contract roadmap"
```

---

### Task 3: Installer Smoke Token Assertions

**Files:**
- Modify: `tests/install-smoke.sh:48-68`

- [ ] **Step 1: Add stable imported-manual token checks**

After the existing `complete-no-action-needed` assertion, add these checks:

```bash
  grep -Fq 'Co-occurrence tie-breaker' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing Review/Status tie-breaker"
  grep -Fq 'Target repo: <owner/repo or absolute local repo path, or n/a>' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing target repo relay field"
  grep -Fq 'Relay readiness rule' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing not-ready relay authority rule"
  grep -Fq 'Normative control-contract changes' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing control-contract review gate"
```

- [ ] **Step 2: Keep existing broad relay assertions**

Confirm these existing checks remain in place:

```bash
grep -Fq 'ready-for-user-approval'
grep -Fq 'complete-no-action-needed'
grep -Fq 'Execution route: <direct-apply | plan-first | subagent-driven | inline-execution>'
grep -Fq 'Accepted residuals: <none | short finding label + disposition + durable tracker/owner>'
```

- [ ] **Step 3: Run the smoke test**

Run:

```bash
./tests/install-smoke.sh
```

Expected:

```text
install smoke ok
```

- [ ] **Step 4: Commit Task 3**

```bash
git add tests/install-smoke.sh
git commit -m "test: assert handoff relay contract tokens"
```

---

### Task 4: Final Verification And Review Relay

**Files:**
- Inspect: `skills/agent-operating-manual/10-model-dispatch.md`
- Inspect: `ROADMAP.md`
- Inspect: `tests/install-smoke.sh`
- Inspect: `.claude-plugin/plugin.json`
- Inspect: `.claude-plugin/marketplace.json`
- Inspect: `docs/superpowers/plans/2026-07-06-handoff-relay-control-contract.md`

- [ ] **Step 1: Run whitespace and token verification**

Run:

```bash
git diff --check
rg -n "Co-occurrence tie-breaker|Target repo|Relay readiness rule|Normative control-contract changes|complete-no-action-needed|Review:|Status:|0\\.4\\.8|F2 handoff-contract|F4 source-repo" skills/agent-operating-manual ROADMAP.md tests .claude-plugin
```

Expected: `git diff --check` exits 0. The `rg` output shows hits in the manual and smoke test, plus the roadmap landed entry, F2/F4 Extraction Candidate rows, and both `0.4.8` metadata files.

- [ ] **Step 2: Confirm the implementation scope**

Run:

```bash
git diff --stat "$(git merge-base HEAD main)"..HEAD
git diff --name-only "$(git merge-base HEAD main)"..HEAD
```

Expected files:

```text
.claude-plugin/marketplace.json
.claude-plugin/plugin.json
ROADMAP.md
docs/superpowers/plans/2026-07-06-handoff-relay-control-contract.md
skills/agent-operating-manual/10-model-dispatch.md
tests/install-smoke.sh
```

No `install.sh`, release tag, generated imported files, adopting-repo files, operator-bootstrap files, or F4 entrypoint files should appear.

- [ ] **Step 3: Prepare the final handoff block**

Use this relay shape in the closeout:

```text
Status: review-needed
Target repo: CCC0509/agent-skills
Target: handoff relay control contract docs/test change + current branch/head SHA
Required user text: n/a
Next agent action: review the control-contract semantics, smoke coverage, and scope boundary before merge/publish
Blockers: none
Accepted residuals: F2 handoff-contract split deferred to IA backlog / owner: agent-skills ROADMAP Extraction Candidates; F3 operator-bootstrap enum deferred to source repo / owner: operator-bootstrap repo; F4 entrypoint/staging mechanics deferred to follow-up branch / owner: agent-skills ROADMAP Extraction Candidates
```

- [ ] **Step 4: Commit final plan checkbox updates only if the implementation updated this plan**

If the implementer checks off this plan during execution, commit the plan checkbox updates separately:

```bash
git add docs/superpowers/plans/2026-07-06-handoff-relay-control-contract.md
git commit -m "docs: update handoff relay plan progress"
```

Skip this commit if the plan file was not modified during implementation.

---

## Self-Review

- Spec coverage: Task 1 covers `Review:`/`Status:` precedence, `Target repo:`, contract-block precedence over prose, `Review:` without `Status:`, `not-ready` relay authority, the plan/review gate, and the in-flight staging boundary. Task 2 records v0.4.8 scope and metadata. Task 3 makes install smoke probe the imported manual. Task 4 requires verification and a `review-needed` relay without an execution route.
- Placeholder scan: No unresolved placeholders are present; branch/head SHA is intentionally supplied at closeout because it cannot be known before implementation.
- Scope check: F2 handoff-contract file extraction, F3 operator-bootstrap enum changes, and F4 repo entrypoint / staging mechanics are explicitly excluded from implementation; F2/F4 receive durable ROADMAP Extraction Candidate rows because the final relay references them as accepted residuals.
