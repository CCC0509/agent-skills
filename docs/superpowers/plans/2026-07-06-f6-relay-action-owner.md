# F6 Relay Action Owner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `User action:` relay field so users know whether to self-review, forward to a reviewer, forward to the next acting agent, reply with required text, or stop.

**Architecture:** This is a doctrine and smoke-test change only. The Agent Operating Manual remains the source of truth; installer smoke proves the imported manual carries the new field; ROADMAP and plugin metadata record the v0.4.9 doctrine increment.

**Tech Stack:** Markdown doctrine, Bash smoke test, JSON plugin metadata.

---

## Source Contract

- Base the branch on `origin/main` after PR #13 (`7e55603`) or later. Do not implement against v0.4.7 or a stale local `main`.
- Keep F4 source-repo entrypoint / worktree hygiene out of this change.
- Keep F5 cross-repo reference map content out of this change except for one durable ROADMAP Extraction Candidate row.
- Do not change `install.sh`, generated imported files, adopting repos, operator-bootstrap, Agent Trigger Kit, or release tags.
- Bump both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to `0.4.9`.
- Final implementation closeout must use `Status: review-needed` and `User action: self-review -> to-reviewer`.

## File Plan

- Modify `skills/agent-operating-manual/10-model-dispatch.md`: add `User action:` to the relay block and define sequence tokens, full-context copy behavior, notes handling, and consistency rules.
- Modify `tests/install-smoke.sh`: add imported-manual token checks for the new relay action-owner contract.
- Modify `ROADMAP.md`: add v0.4.9 landed entry and F5 Extraction Candidate row.
- Modify `.claude-plugin/plugin.json`: bump version to `0.4.9`.
- Modify `.claude-plugin/marketplace.json`: bump plugin version to `0.4.9`.
- Update this plan's checkboxes as each step lands.

### Task 1: Update Relay Doctrine

**Files:**
- Modify: `skills/agent-operating-manual/10-model-dispatch.md:88-140`
- Update: `docs/superpowers/plans/2026-07-06-f6-relay-action-owner.md`

- [x] **Step 1: Add `User action:` to the relay block**

In `skills/agent-operating-manual/10-model-dispatch.md`, change the relay block from:

```text
Status: <review-needed | ready-for-user-approval | complete-no-action-needed | not-ready>
Target repo: <owner/repo or absolute local repo path, or n/a>
Target: <PR/branch/task + head SHA, or n/a>
Required user text: <exact approval/merge text, required user input, or n/a>
Next agent action: <what another agent should do, or none>
Blockers: <none, or concise blockers>
Accepted residuals: <none | short finding label + disposition + durable tracker/owner>
```

to:

```text
Status: <review-needed | ready-for-user-approval | complete-no-action-needed | not-ready>
Target repo: <owner/repo or absolute local repo path, or n/a>
Target: <PR/branch/task + head SHA, or n/a>
Required user text: <exact approval/merge text, required user input, or n/a>
User action: <self-review | to-reviewer | to-agent | reply-required-text | none>[ -> ...]
Next agent action: <what another agent should do, or none>
Blockers: <none, or concise blockers>
Accepted residuals: <none | short finding label + disposition + durable tracker/owner>
```

- [x] **Step 2: Add token definitions after the `Target repo` paragraph**

Insert this paragraph after the paragraph ending with `block 外的散文。`:

```md
`User action` 是給使用者的人類 routing hint，使用 short tokens 串成有序 sequence；
token 之間用 ` -> `。`self-review` 表示使用者應先自行閱讀 / 判斷；`to-reviewer`
表示把完整 copy block 貼給 reviewer agent；`to-agent` 表示貼給下一個 acting agent，
由 `Next agent action` 說明該 agent 要做什麼；`reply-required-text` 表示在目前 chat
回覆 `Required user text` 指定的精確文字或裁決；`none` 只表示使用者不需回覆或轉貼。
常見預設：
`review-needed` + review 類 `Review:` 用 `self-review -> to-reviewer`；
`ready-for-user-approval` 用 `self-review -> reply-required-text`；
pending user disposition 的 `not-ready` 用 `self-review -> reply-required-text`；
已 scoped 且需要下一個 acting agent 修正的 `not-ready` 用 `self-review -> to-agent`；
等待外部證據、CI、policy escalation 或 remote metadata，且沒有 user input 或 next-agent
revision 可用的 `not-ready` 用 `none`；
`complete-no-action-needed` 用 `none`。
```

- [x] **Step 3: Add full-context copy and user-notes prose**

Insert this paragraph after Step 2's new paragraph:

```md
Full-context copy rule：spec、plan、rule-review、full review、fix-confirmation 類交接，
預設把下一個 agent 判斷或行動需要的完整脈絡放進單一 `text` fenced copy block：
使用者需要 reviewer 看到的補充、review findings、author dispositions、target repo /
target、verification state、final relay block，以及三行 `Review:` 合約。純機械續接時，
若 relay block + named target 已足夠，copy block 可以較短；不確定時偏向 full-context
copy，不要讓使用者猜哪些 finding 要保留。

User notes rule：不要新增 `User notes handling:` 欄位。使用者在 fenced block 外補充的
意見可以作為 reviewer 背景，但不覆寫 contract fields。若 author 要求下一個 agent
必須處理使用者補充，應把該補充納入 copy block 脈絡，或在 `Required user text` 明確
點名需要的裁決；`Required user text` 仍是 exact approval / disposition text 的唯一 home。
```

- [x] **Step 4: Amend the existing Relay readiness rule**

Replace the paragraph that starts with `Relay readiness rule：` and ends with
`不可執行描述。` with:

```md
Relay readiness rule：`Status: not-ready` 不能搭配可立即執行的 `Next agent action`，
除非 `User action` 含 `to-agent`、blocker 是另一個 acting agent 必須修正已 scoped work，
且 `Next agent action` 明確寫出該修正。若 blocker 是 pending user disposition，
`Required user text` 必須明確寫出需要的裁決或文字，且 `Next agent action` 必須是
`none until user provides dispositions` 或同等不可執行描述。
```

Keep the `Relay readiness rule` label unchanged because `tests/install-smoke.sh`
already uses it as a stable token.

- [x] **Step 5: Add consistency rules after the amended Relay readiness rule**

Insert this paragraph after the amended Relay readiness rule paragraph:

```md
User action consistency rule：`Status: complete-no-action-needed` 必須搭配
`User action: none`。`User action: none` 只表示使用者不需回覆或轉貼，不覆寫
`Next agent action`。`Review: none-FYI` 不能搭配含 `to-reviewer` 的 `User action`。
`Status: not-ready` 不能搭配含 `to-agent` 的 `User action`，除非 blocker 是另一個
acting agent 必須修正已 scoped work，且 `Next agent action` 明確寫出該修正。
pending user disposition 的 `not-ready` 必須使用 `reply-required-text`、在
`Required user text` 寫出需要的輸入，並讓 `Next agent action` 維持不可執行直到輸入存在。
`Status: ready-for-user-approval` 必須使用 `reply-required-text`，且 `Required user text`
必須命名 exact approval text。`User action` 含 `to-reviewer` 或 `to-agent` 時，copy block
必須包含完整 fenced relay block 與三行 `Review:` 合約。
```

- [x] **Step 6: Verify doctrine tokens**

Run:

```bash
rg -n "User action|self-review|to-reviewer|to-agent|reply-required-text|Full-context copy rule|User notes rule|User action consistency rule" skills/agent-operating-manual/10-model-dispatch.md
```

Expected: output includes the relay block field, token definitions, full-context copy rule, user notes rule, and consistency rule.

- [x] **Step 7: Commit Task 1**

```bash
git add skills/agent-operating-manual/10-model-dispatch.md docs/superpowers/plans/2026-07-06-f6-relay-action-owner.md
git commit -m "docs: add relay user action contract"
```

### Task 2: Update ROADMAP and Metadata

**Files:**
- Modify: `ROADMAP.md:32-56`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Update: `docs/superpowers/plans/2026-07-06-f6-relay-action-owner.md`

- [ ] **Step 1: Add v0.4.9 landed entry**

In `ROADMAP.md`, add this entry immediately after the v0.4.8 entry:

```md
- v0.4.9: relay action-owner clarity adds `User action:` routing, full-context
  copy defaults for spec / plan / review handoffs, and consistency rules so
  users know whether to self-review, forward to a reviewer, forward to an acting
  agent, reply with required text, or stop.
```

- [ ] **Step 2: Add F5 Extraction Candidate row**

In the `agent-skills doctrine` bucket, after the F4 row, add:

```md
| agent-skills doctrine | F5 cross-repo reference map | agent-skills | Separate follow-up for documenting operator-bootstrap as machine/user layer, agent-skills as doctrine, and Agent Trigger Kit as mechanism without creating circular install dependencies. |
```

Do not add an F6 Extraction Candidate row. F6 is this release scope and is tracked by the v0.4.9 landed entry.

- [ ] **Step 3: Bump plugin metadata to 0.4.9**

Change `.claude-plugin/plugin.json`:

```json
{
  "name": "agent-skills",
  "version": "0.4.9",
  "description": "Portable agent doctrine skills: agent-operating-manual (dispatch economy), multi-angle-review (adversarial review pipeline), and optional skill-authoring.",
  "skills": [
    "./skills/"
  ]
}
```

Change the `plugins[0].version` in `.claude-plugin/marketplace.json` from `0.4.8` to `0.4.9`. Leave all other fields unchanged.

- [ ] **Step 4: Verify ROADMAP and metadata**

Run:

```bash
rg -n "v0\\.4\\.9|F5 cross-repo reference map|\"version\": \"0\\.4\\.9\"" ROADMAP.md .claude-plugin
```

Expected: output includes the v0.4.9 ROADMAP entry, F5 row, `.claude-plugin/plugin.json` version, and `.claude-plugin/marketplace.json` plugin version.

- [ ] **Step 5: Commit Task 2**

```bash
git add ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json docs/superpowers/plans/2026-07-06-f6-relay-action-owner.md
git commit -m "docs: record relay action owner roadmap"
```

### Task 3: Update Install Smoke Coverage

**Files:**
- Modify: `tests/install-smoke.sh:54-75`
- Update: `docs/superpowers/plans/2026-07-06-f6-relay-action-owner.md`

- [ ] **Step 1: Add imported-manual token checks**

In `tests/install-smoke.sh`, after the `Target repo:` assertion, add:

```bash
  grep -Fq 'User action: <self-review | to-reviewer | to-agent | reply-required-text | none>[ -> ...]' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing user action relay field"
  grep -Fq 'Full-context copy rule' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing full-context copy rule"
  grep -Fq 'User action consistency rule' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing user action consistency rule"
```

- [ ] **Step 2: Run smoke test**

Run:

```bash
./tests/install-smoke.sh
```

Expected: exits 0 and prints `install smoke ok`.

- [ ] **Step 3: Commit Task 3**

```bash
git add tests/install-smoke.sh docs/superpowers/plans/2026-07-06-f6-relay-action-owner.md
git commit -m "test: assert relay user action tokens"
```

### Task 4: Final Verification and Review Handoff

**Files:**
- Update: `docs/superpowers/plans/2026-07-06-f6-relay-action-owner.md`

- [ ] **Step 1: Run final verification**

Run:

```bash
git fetch origin main
git diff --check "$(git merge-base HEAD origin/main)"..HEAD
./tests/install-smoke.sh
rg -n "User action|self-review|to-reviewer|to-agent|reply-required-text|Full-context copy rule|User notes rule|User action consistency rule|0\\.4\\.9|F5 cross-repo" skills/agent-operating-manual ROADMAP.md tests .claude-plugin
```

Expected:

- `git diff --check` prints no output.
- smoke prints `install smoke ok`.
- `rg` output includes manual doctrine, smoke assertions, ROADMAP v0.4.9, ROADMAP F5, and both plugin metadata files.

- [ ] **Step 2: Verify scope**

Run:

```bash
git diff --name-only "$(git merge-base HEAD origin/main)"..HEAD
```

Expected files only:

```text
.claude-plugin/marketplace.json
.claude-plugin/plugin.json
ROADMAP.md
docs/superpowers/plans/2026-07-06-f6-relay-action-owner.md
skills/agent-operating-manual/10-model-dispatch.md
tests/install-smoke.sh
```

No `install.sh`, generated imported files, adopting repo files, operator-bootstrap files, Agent Trigger Kit files, F4 entrypoint files, or F5 reference-map content should appear.

- [ ] **Step 3: Update plan progress and commit**

Mark completed checkboxes in this plan, then run:

```bash
git add docs/superpowers/plans/2026-07-06-f6-relay-action-owner.md
git commit -m "docs: update relay action owner plan progress"
```

- [ ] **Step 4: Stop for fresh review**

Do not merge, tag, release, or update adopting repos. Send a full-context copy block to the user with this relay shape:

```text
Status: review-needed
Target repo: CCC0509/agent-skills
Target: F6 relay action-owner docs/test/metadata change @ <head-sha>, branch <branch-name>
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review the User action semantics, cross-field consistency rules, full-context copy behavior, smoke coverage, version metadata, and scope boundary before merge/publish
Blockers: none
Accepted residuals: F4 source-repo entrypoint / staging-boundary mechanics deferred / owner: agent-skills ROADMAP Extraction Candidates; F5 cross-repo reference map deferred / owner: agent-skills ROADMAP Extraction Candidates; operator-bootstrap template / enum updates deferred / owner: operator-bootstrap repo; Agent Trigger Kit mechanism updates deferred / owner: agent-trigger-kit repo

Review: full
Focus: User action sequence semantics, copy-block fullness defaults, and consistency with Required user text as sole exact approval/disposition home
Prev reviewed tip: a0072ed
```

## Self-Review

- Spec coverage: Task 1 covers `User action`, ordered short tokens, mapping defaults, full-context copy, user notes prose, and cross-field consistency. Task 2 covers v0.4.9 metadata and durable F5 tracker. Task 3 covers install smoke. Task 4 covers scope and review-needed closeout.
- Scope check: F4 and F5 implementation content are explicitly excluded; F5 receives only a tracker row. operator-bootstrap, Agent Trigger Kit, tags, release actions, and adopting repos are excluded.
- Review feedback handling: The previous reviewer findings 1-7 are addressed, with one explicit disposition: F6 is tracked as a v0.4.9 landed entry rather than an Extraction Candidate because it is the current implementation scope. The fix-confirmation findings against `a0072ed` are also addressed: the plan now amends the existing Relay readiness rule with the `to-agent` carve-out, narrows `none` to user routing, adds the external-evidence waiting mapping, and binds the final review handoff to `a0072ed`.
