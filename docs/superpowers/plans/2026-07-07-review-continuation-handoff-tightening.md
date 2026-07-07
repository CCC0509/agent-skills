# Review Continuation Handoff Tightening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved v0.5.1 review-continuation handoff tightening doctrine, smoke coverage, roadmap entry, candidate retirement, and release metadata bump.

**Architecture:** This is a markdown-doctrine release. `tests/install-smoke.sh` first protects the installed copies, then `10-model-dispatch.md` becomes the canonical relay/status home, `multi-angle-review/SKILL.md` becomes the reviewer-report home, and `ROADMAP.md` plus plugin metadata record the release state.

**Tech Stack:** Bash smoke tests, markdown doctrine files, JSON plugin metadata.

## Global Constraints

- Approved spec: `docs/superpowers/specs/2026-07-07-review-continuation-handoff-tightening-design.md` at `f947034`.
- Add exactly one new relay `Status:` value: `ready-for-continuation`.
- Widen `ready-for-user-approval` to all exact-text approval gates, including approval to start implementation or execution.
- Retire the old bundled `review-needed` approval-text execution path: approval text may be mentioned as pending context, but it must not authorize execution while review is still pending.
- `ready-for-continuation` is only for named work whose required review / fix-confirmation gates have passed, where no exact user approval text is currently needed, and the next acting agent may execute directly.
- Forwarded author-revision and continuation handoffs must use `Review: none-FYI`; the returning author-revision handoff must request `Review: fix-confirmation vs <prev-tip>`.
- Pre-spec / design-framing conclusions must not live only in chat; route them to the forwarded copy block, later spec disposition, `Accepted residuals:`, or v0.5 repo memory routing.
- Do not make pre-spec review mandatory.
- Do not change the `Review:` enum.
- Do not define branch-first, PR-stop, squash-merge, release-tag, push policy, worker spawn/wait/consume/close, worktree cleanup, branch cleanup, concurrency caps, or post-merge push state.
- Do not change Agent Trigger Kit validators, session-check behavior, hooks, or outcome taxonomy.
- Do not edit adopting repos or generated imported copies directly.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to `0.5.1`; release tagging and publishing remain out of scope.
- In this source repo, `agent-trigger-kit session-check` may exit 1 only for `agent-skills: plugin directory missing`; when a relay signal is present, carry `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

---

## File Structure

- Modify `tests/install-smoke.sh`: add imported-copy smoke tokens for `ready-for-continuation`, exact-text approval gates, pre-spec design-framing, durable conclusion capture, and review deliverable copy-field tightening.
- Modify `skills/agent-operating-manual/10-model-dispatch.md`: update the relay status list, defaults, status criteria, consistency rules, approval-text rule, route display wording, pre-handoff checklist, and add compact pre-spec / durable conclusion rules.
- Modify `skills/multi-angle-review/SKILL.md`: tighten Phase 4 reporting when review output includes relay signals, paste-ready blocks, requested-changes author revision, and review-passed continuation.
- Modify `ROADMAP.md`: add the v0.5.1 landed entry, remove the `Review deliverable handoff copy-field tightening` extraction candidate, and preserve `Plan / PR lifecycle discipline` plus `Branch / worker lifecycle hygiene`.
- Modify `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`: bump version strings from `0.5.0` to `0.5.1`.
- Modify this plan file only to mark execution progress.

---

### Task 1: Smoke Coverage First

**Files:**
- Modify: `tests/install-smoke.sh`
- Modify: `docs/superpowers/plans/2026-07-07-review-continuation-handoff-tightening.md`

**Interfaces:**
- Consumes: current installed-copy smoke helper structure in `tests/install-smoke.sh`.
- Produces: failing smoke tokens that Task 2 satisfies through doctrine and metadata updates.

- [ ] **Step 1: Add imported manual status and approval-token checks**

In `tests/install-smoke.sh`, inside the `for f in CLAUDE.md AGENTS.md GEMINI.md; do` loop, after the existing `complete-no-action-needed` assertion, add:

```bash
  grep -Fq 'Status: <review-needed | ready-for-user-approval | ready-for-continuation | complete-no-action-needed | not-ready>' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing ready-for-continuation relay status"
  grep -Fq 'ready-for-continuation' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing continuation relay signal"
  grep -Fq 'exact-text approval gate' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing exact-text approval gate rule"
```

Expected: the script now probes both the relay enum line and the status semantics.

- [ ] **Step 2: Add imported manual pre-spec and durable-capture checks**

In the same loop, after the existing `Full-context copy rule` assertion, add:

```bash
  grep -Fq 'pre-spec / design-framing' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing pre-spec handoff rule"
  grep -Fq 'Durable conclusion capture' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing durable conclusion capture rule"
  grep -Fq 'Pre-Spec Review Disposition' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing pre-spec disposition home"
```

Expected: the smoke distinguishes pre-spec handoff labeling from general full-context copy.

- [ ] **Step 3: Add imported review-skill checks**

In the same loop, after the existing `Accepted residuals` contract assertion and before the sandbox escalation assertion, add:

```bash
  grep -Fq 'Review deliverable copy-field tightening' \
    "$TMP/target/docs/imported-skills/multi-angle-review/SKILL.md" \
    || fail "$f imported review skill missing deliverable copy-field tightening"
  grep -Fq 'paste-ready relay block' \
    "$TMP/target/docs/imported-skills/multi-angle-review/SKILL.md" \
    || fail "$f imported review skill missing paste-ready relay block surface"
  grep -Fq 'Durable residual list' \
    "$TMP/target/docs/imported-skills/multi-angle-review/SKILL.md" \
    || fail "$f imported review skill missing durable residual list surface"
```

Expected: the installed review skill must carry the review-output surfaces from the spec.

- [ ] **Step 4: Run the focused smoke and confirm it fails red**

Run:

```bash
tests/install-smoke.sh
```

Expected: exit `1` with a missing-token failure, normally:

```text
SMOKE FAIL: CLAUDE.md imported manual missing ready-for-continuation relay status
```

If the first missing token differs but is one of the new Task 1 tokens, continue.

- [ ] **Step 5: Commit the failing smoke**

Run:

```bash
git add tests/install-smoke.sh docs/superpowers/plans/2026-07-07-review-continuation-handoff-tightening.md
git commit -m "test: add review continuation smoke coverage"
```

Expected: commit succeeds with only `tests/install-smoke.sh` and this plan file changed. The repository is intentionally red until Task 2 updates doctrine.

---

### Task 2: Doctrine, Roadmap, and Metadata

**Files:**
- Modify: `skills/agent-operating-manual/10-model-dispatch.md`
- Modify: `skills/multi-angle-review/SKILL.md`
- Modify: `ROADMAP.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `docs/superpowers/plans/2026-07-07-review-continuation-handoff-tightening.md`

**Interfaces:**
- Consumes: failing smoke tokens from Task 1.
- Produces: v0.5.1 doctrine text, release metadata, roadmap state, and a green focused smoke.

- [ ] **Step 1: Update the relay block status enum**

In `skills/agent-operating-manual/10-model-dispatch.md`, replace this line in the relay block:

```text
Status: <review-needed | ready-for-user-approval | complete-no-action-needed | not-ready>
```

with:

```text
Status: <review-needed | ready-for-user-approval | ready-for-continuation | complete-no-action-needed | not-ready>
```

Expected: the relay block declares the new status value exactly once in the enum line.

- [ ] **Step 2: Update common User action mappings**

In the "common defaults" paragraph under `User action`, replace this sequence:

```text
`review-needed` + review 類 `Review:` 用 `self-review -> to-reviewer`；
`ready-for-user-approval` 用 `self-review -> reply-required-text`；
pending user disposition 的 `not-ready` 用 `self-review -> reply-required-text`；
已 scoped 且需要下一個 acting agent 修正的 `not-ready` 用 `self-review -> to-agent`；
等待外部證據、CI、policy escalation 或 remote metadata，且沒有 user input 或 next-agent
revision 可用的 `not-ready` 用 `none`；
`complete-no-action-needed` 用 `none`。
```

with:

```text
`review-needed` + review 類 `Review:` 用 `self-review -> to-reviewer`；
`ready-for-user-approval` 用 `self-review -> reply-required-text`；
`ready-for-continuation` 用 `self-review -> to-agent`；
pending user disposition 的 `not-ready` 用 `self-review -> reply-required-text`；
已 scoped 且需要下一個 acting agent 修正的 `not-ready` 用 `self-review -> to-agent`；
等待外部證據、CI、policy escalation 或 remote metadata，且沒有 user input 或 next-agent
revision 可用的 `not-ready` 用 `none`；
`complete-no-action-needed` 用 `none`。
```

Expected: `ready-for-continuation` has the default `self-review -> to-agent`.

- [ ] **Step 3: Add pre-spec copy wording to Full-context copy rule**

In the `Full-context copy rule` paragraph, replace:

```text
Full-context copy rule：spec、plan、rule-review、full review、fix-confirmation 類交接，
預設把下一個 agent 判斷或行動需要的完整脈絡放進單一 `text` fenced copy block：
使用者需要 reviewer 看到的補充、review findings、author dispositions、target repo /
target、verification state、final relay block，以及三行 `Review:` 合約。純機械續接時，
若 relay block + named target 已足夠，copy block 可以較短；不確定時偏向 full-context
copy，不要讓使用者猜哪些 finding 要保留。
```

with:

```text
Full-context copy rule：pre-spec / design-framing、spec、plan、rule-review、full
review、fix-confirmation 類交接，預設把下一個 agent 判斷或行動需要的完整脈絡放進
單一 `text` fenced copy block：使用者需要 reviewer 看到的補充、pre-spec findings、
review findings、author dispositions、target repo / target、verification state、
final relay block，以及三行 `Review:` 合約。純機械續接時，若 relay block + named
target 已足夠，copy block 可以較短；不確定時偏向 full-context copy，不要讓使用者
猜哪些 finding 要保留。
```

Expected: pre-spec / design-framing is a first-class copy-block case.

- [ ] **Step 4: Add the Durable conclusion capture subsection**

In `skills/agent-operating-manual/10-model-dispatch.md`, after the `Accepted residuals` paragraph ending with:

```text
durable tracker/owner 的 residual 不能被當成已安全收尾。
```

add:

```text
Durable conclusion capture：任何會改變下一個 agent 判斷或行動的結論，不能只留在
對話散文。pre-spec / design-framing 的 findings、user dispositions、scope decisions
或 follow-ups 若會影響 spec，必須放進 forwarded copy block，並在後續 spec 的
`Pre-Spec Review Disposition` 或等價 section 說明如何處理。若 pre-spec framing 最後
沒有 formal spec，non-blocking follow-up 放進 `Accepted residuals:` 並附 durable
tracker / owner；active state、audit evidence 或 reusable lesson 依 `15-repo-memory.md`
的 v0.5 memory routing 寫入 repo memory。純人類說明且不影響後續行動者，可留在
copy block 外散文。
```

Expected: the AOM has a stable `Durable conclusion capture` heading and the `Pre-Spec Review Disposition` token.

- [ ] **Step 5: Replace Status criteria**

Replace the current `Status 判準：` bullet list:

```text
Status 判準：
- `ready-for-user-approval`：只用於 merge / tag / deploy / release 等 final
  approval gate，且所有 review / fix-confirmation 都解完、目前 head 已核對、驗證完成、
  accepted residuals 已列在 `Accepted residuals` 欄、沒有 blocker。
- `review-needed`：下一步是 review、scope confirmation，或對已推送且目前 head 的
  fix-confirmation。
- `not-ready`：仍有 blocker、驗證未跑或失敗、head stale / 尚未推送 / 尚未可審、決定
  要修的 finding 尚未推上去、residual 缺 durable tracker/owner，或 review / approval
  前還需要外部證據或外部動作。
- `complete-no-action-needed`：只有工作已完全收尾、沒有下一個 agent 或使用者動作時才能用；
  這是提醒使用者不要再把同一段 closeout 貼給另一個 agent 空跑。若
  `Accepted residuals` 不是 `none`，每個 residual 都必須已有 durable tracker/owner；
  否則用 `not-ready`。
```

with:

```text
Status 判準：
- `ready-for-user-approval`：用於任何 exact-text approval gate，包含開始
  implementation / execution，以及 merge / tag / deploy / release 等 final gate；
  必須搭配 `User action: self-review -> reply-required-text`，`Required user text`
  必須寫出 exact approval text，且所有必要 review / fix-confirmation 都解完、目前
  head 已核對、驗證完成、accepted residuals 已列在 `Accepted residuals` 欄、沒有
  blocker。
- `ready-for-continuation`：用於 named work 的所有必要 review / fix-confirmation gate
  已通過、不需要 exact user approval text、下一個 acting agent 可以直接執行 named
  continuation。必須搭配 `User action: self-review -> to-agent`、`Required user text: n/a`
  和 `Review: none-FYI`；它不是 generic "looks good" status，不能繞過 review、
  fix-confirmation 或 exact approval gate。
- `review-needed`：下一步是 review、scope confirmation，或對已推送且目前 head 的
  fix-confirmation。若 review 仍 pending，不要把 exact approval text 綁在
  `review-needed` handoff 當作 execution authorization；先取得 review /
  fix-confirmation，通過後再送 `ready-for-user-approval` 或 `ready-for-continuation`。
- `not-ready`：仍有 blocker、驗證未跑或失敗、head stale / 尚未推送 / 尚未可審、決定
  要修的 finding 尚未推上去、residual 缺 durable tracker/owner，或 review / approval
  前還需要外部證據或外部動作。
- `complete-no-action-needed`：只有工作已完全收尾、沒有下一個 agent 或使用者動作時才能用；
  這是提醒使用者不要再把同一段 closeout 貼給另一個 agent 空跑。若
  `Accepted residuals` 不是 `none`，每個 residual 都必須已有 durable tracker/owner；
  否則用 `not-ready`。
```

Expected: this resolves the accepted residual by retiring execution authorization from bundled `review-needed` approval text.

- [ ] **Step 6: Update User action consistency rule**

In `User action consistency rule`, replace:

```text
`Status: ready-for-user-approval` 必須使用 `reply-required-text`，且 `Required user text`
必須命名 exact approval text。`User action` 含 `to-reviewer` 或 `to-agent` 時，copy block
必須包含完整 fenced relay block 與三行 `Review:` 合約。
```

with:

```text
`Status: ready-for-user-approval` 必須使用 `reply-required-text`，且 `Required user text`
必須命名 exact approval text。`Status: ready-for-continuation` 必須使用
`User action: self-review -> to-agent`、`Required user text: n/a`、可執行的
`Next agent action`，且三行 `Review:` 合約必須是 `Review: none-FYI`。review requested
changes 且 blocker 是 acting agent revision 的 `not-ready` handoff 也必須使用
`Review: none-FYI`；修正後返回時才使用 `Review: fix-confirmation vs <prev-tip>`。
`User action` 含 `to-reviewer` 或 `to-agent` 時，copy block 必須包含完整 fenced relay
block 與三行 `Review:` 合約。
```

Expected: author-revision and continuation pairings are normative.

- [ ] **Step 7: Replace approval-text paragraph**

Replace the paragraph:

```text
若 relay signal 是要取得開始實作或開始執行的核准，`Required user text` 仍是 exact
approval text 的唯一 home；使用者送出該文字後，下一個 agent 應直接執行
`Next agent action`，不要把同一個 `review-needed` 訊號再貼回去要求二次 review。
```

with:

```text
若 relay signal 是要取得任何 exact-text approval（包含開始 implementation /
execution、merge、tag、deploy、release），`Status` 必須是 `ready-for-user-approval`，
`Required user text` 仍是 exact approval text 的唯一 home；使用者送出該文字後，
下一個 agent 應直接執行 `Next agent action`，不要把同一個 approval 訊號再貼回去
要求二次 review。若 review 仍 pending，approval text 只能作為 pending context，
不能授權 execution；等 review / fix-confirmation 通過後，再送
`ready-for-user-approval` 或 `ready-for-continuation`。
```

Expected: the old bundled `review-needed` approval-text path no longer authorizes execution.

- [ ] **Step 8: Update Route display rule and pre-handoff checklist**

In the `Route display rule` paragraph, replace:

```text
且任何 named user approval / continuation reply 會依既有
approval-to-execute rule 直接授權該執行；
```

with:

```text
且任何 named user approval reply 或 `ready-for-continuation` signal 會依既有
approval-to-execute / continuation rule 直接授權該執行；
```

In the pre-handoff self-check bullet that starts with `` `Status:` 是否是合法 relay status？``, replace it with:

```text
- `Status:` 是否是合法 relay status；review 已過且無 exact user approval 時是否用
  `ready-for-continuation`，需要 exact approval text 時是否用 `ready-for-user-approval`？
```

Expected: route display and self-check both recognize the continuation status.

- [ ] **Step 9: Update multi-angle-review Phase 4**

In `skills/multi-angle-review/SKILL.md`, after the existing bullet:

```text
- If the report includes a relay signal from Agent Operating Manual `10-model-dispatch.md` §3.1, every non-blocking finding, FYI, environment note, and out-of-repo follow-up must appear in `Accepted residuals`. A ready / complete signal that leaves those items only in prose is incomplete; if any residual lacks a durable tracker/owner, do not present the work as ready or fully closed.
```

add:

```text
- Review deliverable copy-field tightening: when a report includes a relay signal,
  keep three surfaces distinct: the findings report (`Verdict`, `Findings`, `Next
  actions`), the paste-ready relay block when the user should forward or reply,
  and the Durable residual list carried by `Accepted residuals:`. Do not invent a
  relay block for pure FYI with no next action. When the report asks the user to
  forward to an author, reviewer, or acting agent, the single `text` copy block
  must contain the relay block plus all findings and dispositions needed by that
  receiving agent.
- Requested-changes author revision handoffs use `Status: not-ready`,
  `User action: self-review -> to-agent`, `Required user text: n/a`, and
  `Review: none-FYI`; the returning handoff after revision requests
  `Review: fix-confirmation vs <prev-tip>`.
- Review-passed continuation handoffs that need no exact user reply use
  `Status: ready-for-continuation`, `User action: self-review -> to-agent`,
  `Required user text: n/a`, and `Review: none-FYI`.
```

Expected: the review skill carries the three surfaces and the two relay pairings.

- [ ] **Step 10: Update ROADMAP**

In `ROADMAP.md`, after the v0.5.0 landed entry, add:

```markdown
- v0.5.1: review continuation handoff tightening adds the narrow
  `ready-for-continuation` relay status, widens `ready-for-user-approval` to all
  exact-text approval gates, preserves pre-spec / design-framing conclusions, and
  tightens review deliverable copy fields without adding worker lifecycle or
  Plan / PR lifecycle doctrine.
```

Then delete this Extraction Candidate row:

```markdown
| agent-skills doctrine | Review deliverable handoff copy-field tightening | agent-skills | Control-contract work over multi-angle-review and Agent Operating Manual section 3.1; separate from closeout memory routing. |
```

Expected: the v0.5.1 landed entry exists, the review-deliverable candidate is retired, and the `Plan / PR lifecycle discipline` plus `Branch / worker lifecycle hygiene` rows remain.

- [ ] **Step 11: Bump plugin metadata**

In `.claude-plugin/plugin.json`, change:

```json
"version": "0.5.0"
```

to:

```json
"version": "0.5.1"
```

In `.claude-plugin/marketplace.json`, change:

```json
"version": "0.5.0"
```

to:

```json
"version": "0.5.1"
```

Expected: both metadata files carry version `0.5.1`.

- [ ] **Step 12: Run focused verification**

Run:

```bash
tests/install-smoke.sh
rg -n 'ready-for-continuation|pre-spec / design-framing|exact-text approval gate|Durable conclusion capture|Review deliverable copy-field tightening|Plan / PR lifecycle discipline|Branch / worker lifecycle hygiene|v0\.5\.1|0\.5\.1' skills/agent-operating-manual skills/multi-angle-review ROADMAP.md tests .claude-plugin
git diff --check
```

Expected:

- `tests/install-smoke.sh` exits `0` with `install smoke ok`.
- The token scan returns hits in `10-model-dispatch.md`, `multi-angle-review/SKILL.md`, `ROADMAP.md`, `tests/install-smoke.sh`, and both metadata files.
- `git diff --check` exits `0` with no output.

- [ ] **Step 13: Commit doctrine and release metadata**

Run:

```bash
git add skills/agent-operating-manual/10-model-dispatch.md skills/multi-angle-review/SKILL.md ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json docs/superpowers/plans/2026-07-07-review-continuation-handoff-tightening.md
git commit -m "docs: add review continuation handoff tightening"
```

Expected: commit succeeds with doctrine, roadmap, metadata, and this plan changed. `tests/install-smoke.sh` is already committed from Task 1.

---

### Task 3: Full Verification and Review Handoff

**Files:**
- Modify: `docs/superpowers/plans/2026-07-07-review-continuation-handoff-tightening.md`

**Interfaces:**
- Consumes: Task 1 smoke commit and Task 2 doctrine commit.
- Produces: verified review-ready implementation handoff.

- [ ] **Step 1: Run full verification gates**

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

- `agent-trigger-kit session-check` exits `1` only for `agent-skills: plugin directory missing`, with no unmarked outcome events.
- `tests/install-smoke.sh` exits `0` with `install smoke ok`.
- `tests/source-entrypoint-smoke.sh` exits `0` with `source entrypoint smoke ok`.
- `tests/cross-repo-reference-map-smoke.sh` exits `0` with `cross-repo reference map smoke ok`.
- Both `git diff --check` commands exit `0` with no output.
- `git status -sb` shows only this plan file modified for checkbox progress, or a clean tree if no checkbox edits remain.

- [ ] **Step 2: Commit final plan checkbox progress if changed**

If Task 3 checkbox updates changed this plan after Task 2's commit, run:

```bash
git add docs/superpowers/plans/2026-07-07-review-continuation-handoff-tightening.md
git commit -m "docs: mark review continuation plan closeout"
```

Expected: commit succeeds if the plan changed. If there is no plan diff, skip this step and record that no closeout checkbox commit was needed.

- [ ] **Step 3: Prepare final review handoff**

Use this exact relay shape, replacing `<HEAD>` with the final commit hash:

```text
Status: review-needed
Target repo: /Users/jackchou/Desktop/agent-skills
Target: Phase 1 review continuation handoff tightening implementation @ <HEAD>
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review the v0.5.1 implementation against the approved spec and plan, including ready-for-continuation semantics, widened ready-for-user-approval criteria, retired bundled review-needed approval-text execution path, pre-spec durable conclusion capture, multi-angle-review deliverable tightening, ROADMAP / metadata changes, and full verification output
Blockers: none
Accepted residuals: ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up

Review: full
Focus: ready-for-continuation status semantics, exact-text approval gate widening, Review:none-FYI pairings, durable conclusion capture, installed-copy smoke coverage, and absence of worker lifecycle / Plan-PR lifecycle doctrine.
Prev reviewed tip: f947034
```

Expected: final handoff requests fresh full review and carries only the canonical ATK accepted residual.

---

## Plan Self-Review Notes

- Spec coverage: Task 1 covers smoke-first imported-copy checks. Task 2 covers AOM status semantics, bundled approval-text reconciliation, pre-spec durable capture, multi-angle-review deliverables, ROADMAP, candidate retirement, and metadata. Task 3 covers full verification and review handoff.
- Scope boundary: The plan does not define worker lifecycle, worktree cleanup, branch-first, PR-stop, squash-merge, release tagging, ATK validators, or adopting-repo edits.
- Accepted residual disposition: The fix-confirmation residual about `review-needed` bundled approval text is resolved in Task 2 Step 5 and Step 7 by retiring execution authorization from review-pending approval text and routing exact-text gates through `ready-for-user-approval`.
