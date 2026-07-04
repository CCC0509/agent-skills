# Agent Skills v0.3.1 Doctrine Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a docs-only `agent-skills` v0.3.1 release that turns the recent review-cycle lessons into portable doctrine for reviewer conduct, durable progress tracking, clock-aware prioritization, and verification side-effect handling.

**Architecture:** Keep this as markdown doctrine only. `multi-angle-review` owns read-only reviewer conduct; `agent-operating-manual` owns execution discipline; Codex / Gemini adapters express the task-tracking capability without copying Claude-specific assumptions. Version metadata moves to `0.3.1`, but installer behavior, runtime behavior, and adopting repos stay untouched.

**Tech Stack:** Markdown skills, Claude plugin metadata JSON, existing shell smoke tests and skill validators.

---

## Source Contract

- Scope is limited to `agent-skills` doctrine and release metadata.
- Do not change `install.sh`, `tests/install-smoke.sh`, or starter memory-index behavior.
- Do not add runtime hooks, validators, MCP schema, central memory storage, or adopting-repo updates.
- Do not implement the deferred ROADMAP items for preflight / closeout self-report, Plan / PR lifecycle discipline, or ATK templates in this release.
- Tag `v0.3.1` only after the implementation PR is merged and main release gates pass.

## File Plan

- Modify `skills/multi-angle-review/SKILL.md`: add cross-phase reviewer conduct rules and make `attribution` a required candidate / finding field.
- Modify `skills/agent-operating-manual/10-model-dispatch.md`: add progress, active-clock ordering, side-effect, and environment kill-switch discipline.
- Modify `skills/agent-operating-manual/SKILL.md`: add the same execution-discipline rule to the quick reference card.
- Modify `skills/agent-operating-manual/README.md`: keep the user-facing quick reference card in sync with `SKILL.md`.
- Modify `skills/agent-operating-manual/codex-model-adapter.md`: add a `Task-tracking surface` capability row.
- Modify `skills/agent-operating-manual/gemini-model-adapter.md`: add the same capability row using Gemini-neutral wording.
- Modify `ROADMAP.md`: mark v0.3.1 as landed while preserving deferred rows.
- Modify `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`: bump versions to `0.3.1`.

---

### Task 1: Multi-Angle Reviewer Conduct

**Files:**
- Modify: `skills/multi-angle-review/SKILL.md`

- [x] **Step 1: Insert a cross-phase conduct section before Phase 0**

Add this section after the introductory paragraph and before `### Phase 0 — Pin the scope`:

```markdown
### Cross-phase rule — Reviewer conduct

These rules apply across every phase. They are the read-only counterpart to the
Agent Operating Manual's verify-not-self-verify rule: a reviewer preserves
independence by not becoming the author.

- Reviewer legal write surface is session memory plus scratch artifacts only. Do
  not edit the reviewed worktree, even for a one-line fix. Attach a suggested
  patch or exact replacement text in the report and leave implementation to the
  author.
- Before reporting a failure, classify it with one attribution:
  `pr_introduced`, `pre_existing`, or `environment`. A code path untouched by the
  diff cannot be reported as a PR regression unless the changed contract newly
  exposes it.
- Treat every disclosed verification gap as a reviewer action item, not a waiver. Try
  to close the gap from your own environment; if policy, credentials, network, or
  tooling blocks it, report the remaining gap explicitly.
- When new evidence weakens or refutes your earlier warning, say so in the
  report. Do not leave stale alarms implicit.
- Policy denial is a verification gap, not an invitation to route around the
  boundary. If production access, credentials, or host policy blocks a probe,
  stop at the boundary and state what remains author-attested.
- Prefer decisive cheap probes before expensive reruns or speculation. Examples:
  if a squash merge tree hash equals the reviewed head tree hash, reviewed gates
  transfer to the merge commit; for annotated tags, verify the peeled `^{}` target
  instead of trusting the tag object alone.
```

- [x] **Step 2: Add `attribution` to the Phase 1 candidate format**

Replace the Phase 1 candidate-format sentence:

```markdown
Every candidate needs `file`, `line`, a one-line `summary`, and a concrete `failure_scenario` (inputs/state -> wrong output).
```

with:

```markdown
Every candidate needs `file`, `line`, a one-line `summary`, a concrete `failure_scenario` (inputs/state -> wrong output), and `attribution` (`pr_introduced`, `pre_existing`, or `environment`).
```

- [x] **Step 3: Add attribution to the report contract**

In Phase 4, add this bullet after the finding-bucket bullet:

```markdown
- For each finding, include `attribution` (`pr_introduced`, `pre_existing`, or `environment`) so the report distinguishes PR regressions from inherited defects and tooling / environment failures.
```

- [x] **Step 4: Verify conduct vocabulary is present**

Run:

```bash
rg -n "Reviewer conduct|pr_introduced|pre_existing|environment|squash merge tree hash|peeled" skills/multi-angle-review/SKILL.md
```

Expected: output includes the new section, all three snake_case attribution labels, and both cheap-probe examples.

- [x] **Step 5: Commit Task 1**

```bash
git add skills/multi-angle-review/SKILL.md
git commit -m "docs: add reviewer conduct doctrine"
```

---

### Task 2: Manual Execution Discipline

**Files:**
- Modify: `skills/agent-operating-manual/10-model-dispatch.md`
- Modify: `skills/agent-operating-manual/SKILL.md`
- Modify: `skills/agent-operating-manual/README.md`

- [x] **Step 1: Add a new execution-discipline section after §4**

Insert this section after the §4 verify-not-self-verify table and before `## §5`:

```markdown
## §4.1 進度、時鐘、驗證副作用（Progress / Clock / Side-effect Discipline）

進度記錄分兩層：session-local tracker 管當下執行，repo-local plan / spec checkbox 管跨 agent、跨 session 的耐久狀態。

- 如果 harness 有 TodoWrite / task-tracking surface，用它管理當下執行；但它不是 plan checkbox 的替代品。每個 checkpoint / commit 點都要把 plan / spec 裡已完成、已驗證的 `- [ ]` 同步改成 `- [x]`。
- 如果 harness 沒有 task-tracking surface，plan / spec checkbox 就是你的 todo list。完成一步就更新 checkbox，不要等 closeout 才一次補。
- 排序看正在跑的時鐘，不只看概念順序。會燒 quota、會 automerge、會過期、會阻塞別人的事，優先級高於沒有時鐘壓力的 doctrine polish。
- 驗證會留下副作用時要記帳：暫存檔、gitignored outcome store、cache、remote check run、外部服務 read-back，都要在回報中揭露。
- 環境 kill switch 只包住目標命令。跑整個 test suite 前先判斷 env var 會不會被 spawned child process 繼承；會污染子行程預期時，不要把它掛在整輪測試外層。
```

- [x] **Step 2: Update the §9 quick reference card**

Add this bullet before the final escalation bullet:

```markdown
- 有 TodoWrite 類工具也要同步 plan checkbox；沒有工具時 checkbox 就是 todo list。排序看正在跑的時鐘，驗證副作用與 env kill switch 影響要揭露。
```

- [x] **Step 3: Update the SKILL.md quick reference card**

Add this numbered rule before the repo-memory rule:

```markdown
6. 有 TodoWrite 類工具也要同步 plan checkbox；沒有工具時 checkbox 就是 todo list。排序看正在跑的時鐘，驗證副作用與 env kill switch 影響要揭露。
```

Then renumber the existing repo-memory rule from `6.` to `7.`.

- [x] **Step 4: Update the README.md quick reference card**

In `skills/agent-operating-manual/README.md`, add the same numbered rule before
the repo-memory rule:

```markdown
6. 有 TodoWrite 類工具也要同步 plan checkbox；沒有工具時 checkbox 就是 todo list。排序看正在跑的時鐘，驗證副作用與 env kill switch 影響要揭露。
```

Then renumber the existing repo-memory rule from `6.` to `7.`.

- [x] **Step 5: Verify the manual vocabulary**

Run:

```bash
rg -n "TodoWrite|task-tracking|plan checkbox|正在跑的時鐘|kill switch|env var" skills/agent-operating-manual/10-model-dispatch.md skills/agent-operating-manual/SKILL.md skills/agent-operating-manual/README.md
```

Expected: output includes the new §4.1 section, the §9 quick reference bullet, the SKILL.md quick reference rule, and the README.md quick reference rule.

- [x] **Step 6: Commit Task 2**

```bash
git add skills/agent-operating-manual/10-model-dispatch.md skills/agent-operating-manual/SKILL.md skills/agent-operating-manual/README.md
git commit -m "docs: add execution discipline to manual"
```

---

### Task 3: Capability Adapter Rows

**Files:**
- Modify: `skills/agent-operating-manual/codex-model-adapter.md`
- Modify: `skills/agent-operating-manual/gemini-model-adapter.md`

- [x] **Step 1: Add the Codex task-tracking row**

In the Codex capability table, add this row after `Parallel workers`:

```markdown
| Task-tracking surface | Use TodoWrite or the harness task tracker for current-session execution, and sync durable plan / spec checkboxes at each checkpoint or commit. | Treat the plan / spec checkbox list as the task tracker; tick completed steps as they become true and commit those ticks with the work. |
```

- [x] **Step 2: Add the Gemini task-tracking row**

In the Gemini capability table, add this row after `Background review`:

```markdown
| Task-tracking surface | Use the environment's task tracker for current-session execution, and sync durable plan / spec checkboxes at each checkpoint or commit. | Treat the plan / spec checkbox list as the task tracker; tick completed steps as they become true and commit those ticks with the work. |
```

- [x] **Step 3: Verify adapter rows and absence of Claude aliases**

Run:

```bash
rg -n "Task-tracking surface|durable plan / spec checkboxes" skills/agent-operating-manual/*-model-adapter.md
rg -n "haiku|sonnet|opus|fable" skills/agent-operating-manual/*-model-adapter.md
```

Expected: first command reports both adapters. Second command reports no matches.

- [x] **Step 4: Commit Task 3**

```bash
git add skills/agent-operating-manual/codex-model-adapter.md skills/agent-operating-manual/gemini-model-adapter.md
git commit -m "docs: add task-tracking adapter capability"
```

---

### Task 4: Roadmap and Version Metadata

**Files:**
- Modify: `ROADMAP.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [x] **Step 1: Mark v0.3.1 landed**

Add this bullet under `## Landed`, after the v0.3.0 bullet:

```markdown
- v0.3.1: reviewer conduct doctrine, attribution labels for review findings,
  task-tracking capability adapters, active-clock prioritization, and
  verification side-effect / kill-switch discipline.
```

Do not remove any deferred rows from `## v0.3+ Extraction Candidates`.

- [x] **Step 2: Bump plugin metadata versions**

Change both version fields from `0.3.0` to `0.3.1`:

```bash
rg -n '"version": "0\.3\.0"' .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

Expected before edit: two matches.

Expected after edit:

```bash
rg -n '"version": "0\.3\.1"' .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

reports two matches.

- [x] **Step 3: Commit Task 4**

```bash
git add ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: prepare agent-skills v0.3.1"
```

---

### Task 5: Release Gates and PR Handoff

**Files:**
- No additional planned file edits.

- [x] **Step 1: Run formatting and smoke gates**

Run:

```bash
git diff --check origin/main..HEAD
bash tests/install-smoke.sh
bash -n install.sh tests/install-smoke.sh
shellcheck install.sh tests/install-smoke.sh
```

Expected: all commands exit 0. If `shellcheck` is unavailable, record the exact command failure as a verification gap instead of claiming it passed.

- [x] **Step 2: Run plugin and skill validation**

Run:

```bash
claude plugin validate .
python3 ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/agent-operating-manual
python3 ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/multi-angle-review
```

Expected: plugin validation passes and both skills report valid. If the system `python3` lacks PyYAML, use the known local Python with PyYAML and record the interpreter path in the PR notes.

- [x] **Step 3: Run doctrine-specific grep gates**

Run:

```bash
rg -n "pr_introduced|pre_existing|environment" skills/multi-angle-review/SKILL.md
rg -n "Task-tracking surface|durable plan / spec checkboxes" skills/agent-operating-manual/*-model-adapter.md
rg -n "haiku|sonnet|opus|fable" skills/agent-operating-manual/*-model-adapter.md
```

Expected: first two commands find the new doctrine. Third command finds no matches.

- [ ] **Step 4: Open PR and stop for review**

Push the branch and open a PR against `main`. The PR body must state:

```markdown
Scope:
- docs-only v0.3.1 doctrine hardening
- reviewer conduct and attribution labels in multi-angle-review
- progress / clock / side-effect discipline in agent-operating-manual
- task-tracking capability rows in Codex / Gemini adapters
- version metadata bumped to 0.3.1

Not in scope:
- install.sh / smoke-test behavior changes
- runtime validators or hooks
- stock-scanner adoption
- v0.3+ deferred roadmap rows
```

Stop after opening the PR. Do not merge or tag until review explicitly approves.

- [ ] **Step 5: Merge and tag only after approval**

After explicit approval:

```bash
git switch main
git pull --ff-only
git tag -a v0.3.1 -m "agent-skills v0.3.1"
git push origin v0.3.1
```

Before tagging, verify `main` contains the merged PR and both plugin metadata files still say `0.3.1`.

---

## Plan Self-Review

- Spec coverage: reviewer self-restraint, attribution labels, gap-closing duty, self-correction, policy-boundary handling, cheap decisive probes, durable progress tracking, active-clock prioritization, side-effect ledger, kill-switch scoping, adapter capability rows, ROADMAP, and version metadata all map to explicit tasks.
- Boundary coverage: no task edits installer behavior, smoke scenarios, runtime validation, MCP schema, central memory, or adopting repos.
- Placeholder scan: this plan contains no unresolved placeholder instructions or unspecified test commands.
- Traceability: Task 1 owns reviewer conduct; Task 2 owns manual execution discipline; Task 3 owns cross-agent adapter capability; Task 4 owns roadmap and release metadata; Task 5 owns gates and handoff.
