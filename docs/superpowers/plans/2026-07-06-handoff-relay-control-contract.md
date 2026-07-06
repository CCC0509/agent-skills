# Handoff Relay Control Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tighten the `agent-skills` handoff / relay contract so downstream agents know which signal controls next action, which repo owns the next step, and when control-contract changes require plan-first review.

**Architecture:** Keep the change docs-only and local to the shared Agent Operating Manual contract. `skills/agent-operating-manual/10-model-dispatch.md` owns the normative contract, `ROADMAP.md` records the landed doctrine increment, and `tests/install-smoke.sh` probes stable imported-manual tokens instead of brittle full-line text.

**Tech Stack:** Markdown doctrine, Bash smoke test, existing install flow.

---

## Source Contract

- Scope is limited to the F1 handoff / relay ambiguity plus the newly requested target-repo routing field and plan/review gate for control-contract edits.
- Do not split §3.1 into a new handoff-contract file in this change. Keep that as the separate F2 IA backlog item.
- Do not change operator-bootstrap enum/source-of-truth behavior in this change. Keep that as a separate F3 repo change.
- Do not change `install.sh`, plugin metadata, release tags, generated imported files, or adopting repos.
- This change should close with `Status: review-needed`, not `complete-no-action-needed`, because it changes future agent control semantics.

## File Plan

- Modify `skills/agent-operating-manual/10-model-dispatch.md:71-143`: add the co-occurrence tie-breaker, add `Target repo:` to the relay block, define `Target repo` vs `Target`, and add a plan/review gate for handoff / relay / approval / review control-contract changes.
- Modify `ROADMAP.md:26-31`: add a landed entry for this doctrine increment, or revise the current v0.4.7 line if the implementation branch is intentionally folded into the unreleased v0.4.7 train.
- Modify `tests/install-smoke.sh:48-68`: add stable token assertions for the new contract vocabulary in the imported manual.

---

### Task 1: Manual Contract Semantics

**Files:**
- Modify: `skills/agent-operating-manual/10-model-dispatch.md:71-143`

- [ ] **Step 1: Add the Review/Status co-occurrence tie-breaker**

Insert this paragraph after the paragraph ending at line 74, before the paste-ready `text` block rule:

```markdown
Co-occurrence tie-breaker: the three-line `Review:` contract is reviewer-facing context; the `Status:` relay block is the user-facing / next-action control signal. If both appear, the consuming agent MUST follow the `Status:` block for immediate next action, approval state, blockers, and accepted residuals. If the author wants review, `Status` must be `review-needed`; `Review:` alone must not override a `Status: complete-no-action-needed` relay.
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
Required user text: <exact approval/merge text, or n/a>
Next agent action: <what another agent should do, or none>
Blockers: <none, or concise blockers>
Accepted residuals: <none | short finding label + disposition + durable tracker/owner>
```

- [ ] **Step 3: Define `Target repo:` and preserve `Target:` meaning**

Add this paragraph after the relay block and before the `Accepted residuals` paragraph:

```markdown
`Target repo` is the durable routing field for cross-repo handoff. Use `owner/repo` when the remote identity is known; use an absolute local repo path when the next action depends on a local checkout; use `n/a` only when there is no repo-specific next action. `Target` stays scoped to the PR, branch, task, head SHA, or other work item inside that repo. Do not hide the intended repo only in prose outside the relay block.
```

- [ ] **Step 4: Add the control-contract plan/review gate**

Add this paragraph after the route gating paragraph ending at line 143, before the section divider:

```markdown
Normative control-contract changes require extra caution. Any change that alters handoff, relay, approval, review, route, blocker, or completion semantics defaults to `Execution route: plan-first` before implementation and `Status: review-needed` after implementation. The author may use a smaller inline plan for docs-only changes, but the final relay must request fresh review unless the user explicitly waives that review in the same session.
```

- [ ] **Step 5: Verify the manual contract vocabulary**

Run:

```bash
rg -n "Co-occurrence tie-breaker|Target repo|owner/repo|Normative control-contract changes|plan-first|complete-no-action-needed|Review:" skills/agent-operating-manual/10-model-dispatch.md
```

Expected: output includes the new tie-breaker, the relay block `Target repo:` field, the `Target repo` definition, the control-contract gate, and the existing `Review:` and `complete-no-action-needed` references.

- [ ] **Step 6: Commit Task 1**

```bash
git add skills/agent-operating-manual/10-model-dispatch.md
git commit -m "docs: tighten handoff relay control contract"
```

---

### Task 2: Roadmap Scope Record

**Files:**
- Modify: `ROADMAP.md:26-31`

- [ ] **Step 1: Record the landed doctrine increment**

If this branch is a new increment after v0.4.7, add this entry after the current v0.4.7 bullet:

```markdown
- v0.4.8: handoff / relay control contract clarifies `Review:` versus
  `Status:` precedence, adds `Target repo:` routing, and requires plan-first
  plus fresh review for normative control-contract changes.
```

If maintainers decide this belongs inside the unreleased v0.4.7 train, replace the current v0.4.7 entry with:

```markdown
- v0.4.7: relay signals preserve accepted residuals, clarify review-needed
  versus not-ready boundaries, define `Review:` versus `Status:` precedence,
  add `Target repo:` routing, and require plan-first plus fresh review for
  normative control-contract changes.
```

- [ ] **Step 2: Keep F2 and F3 out of scope**

Confirm the roadmap still has no landed claim for:

```text
F2: splitting §3.1 into a separate handoff-contract file
F3: changing the operator-bootstrap enum/source-of-truth in another repo
```

Run:

```bash
rg -n "handoff-contract|operator-bootstrap|Target repo|control-contract|v0\\.4\\.8|v0\\.4\\.7" ROADMAP.md
```

Expected: output shows the new landed roadmap wording and no claim that F2 or F3 was implemented.

- [ ] **Step 3: Commit Task 2**

```bash
git add ROADMAP.md
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

- [ ] **Step 1: Run whitespace and token verification**

Run:

```bash
git diff --check
rg -n "Co-occurrence tie-breaker|Target repo|Normative control-contract changes|complete-no-action-needed|Review:|Status:" skills/agent-operating-manual ROADMAP.md tests
```

Expected: `git diff --check` exits 0. The `rg` output shows hits in the manual and smoke test, plus the roadmap landed entry.

- [ ] **Step 2: Confirm the implementation scope**

Run:

```bash
git diff --stat "$(git merge-base HEAD main)"..HEAD
git diff --name-only "$(git merge-base HEAD main)"..HEAD
```

Expected files:

```text
ROADMAP.md
skills/agent-operating-manual/10-model-dispatch.md
tests/install-smoke.sh
```

No `install.sh`, plugin metadata, generated imported files, adopting-repo files, or operator-bootstrap files should appear.

- [ ] **Step 3: Prepare the final handoff block**

Use this relay shape in the closeout:

```text
Status: review-needed
Target repo: CCC0509/agent-skills
Target: handoff relay control contract docs/test change + current branch/head SHA
Required user text: n/a
Next agent action: review the control-contract semantics, smoke coverage, and scope boundary before merge/publish
Blockers: none
Accepted residuals: F2 handoff-contract split deferred to IA backlog / owner: agent-skills ROADMAP; F3 operator-bootstrap enum deferred to source repo / owner: operator-bootstrap repo

Execution route: subagent-driven
Route reason: normative control-contract changes should receive fresh review from a new context
User approval needed: no
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

- Spec coverage: Task 1 covers `Review:`/`Status:` precedence, `Target repo:`, and the cautious plan/review gate. Task 2 records the scope. Task 3 makes install smoke probe the imported manual. Task 4 requires verification and a `review-needed` relay.
- Placeholder scan: No unresolved placeholders are present; branch/head SHA is intentionally supplied at closeout because it cannot be known before implementation.
- Scope check: F2 handoff-contract file extraction and F3 operator-bootstrap enum changes are explicitly excluded.
