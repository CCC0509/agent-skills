---
name: multi-angle-review
description: "Use when running a read-only review of a PR / commit range, an implementation plan before its Approved flip, or a fix-confirmation pass. Runs independent finder angles, then an adversarial anti-hallucination verify pass, then independent re-verification of claimed evidence before reporting."
---

# Multi-Angle Review

Use this methodology for read-only review of a PR / commit range, an
implementation plan before its approval flip, or a fix-confirmation pass after
prior findings. Framework-agnostic：不假設任何 process framework；在有
superpowers 的 repo 可直接作為 requesting-code-review checkpoint 的 reviewer
方法論。

### Cross-phase rule — Reviewer conduct

These rules apply across every phase. They are the read-only counterpart to the
Agent Operating Manual's verify-not-self-verify rule: a reviewer preserves
independence by not becoming the author.

- Hand-off request contract (requester side): end every hand-off that may need
  review with three lines -- `Review: [full | fix-confirmation vs <prev-tip> |
  closeout-sanity | none-FYI]`, `Focus: <what you are unsure about>`, and
  `Prev reviewed tip: <hash>`. Evidence blocks without a request line force the
  reviewer to guess intent; the guess is the defect even when it lands right.
- If a hand-off arrives with evidence but no request line, do not silently guess
  the review type. State `assumed type: <type>` in one line before continuing,
  or ask for the missing request contract.
- Write the report for the next agent, not the human relay: use exactly these
  blocks, in order -- `Verdict`, `Findings` with `file:line` and suggested
  fixes, and `Next actions`. Cut scope recaps, facts the executor already owns,
  and meta explanation. Compress human-only decisions such as approval gates to
  one labeled line.
- Reviewer legal write surface is session memory plus scratch artifacts only. Do
  not edit the reviewed worktree, even for a one-line fix. Attach a suggested
  patch or exact replacement text in the report and leave implementation to the
  author.
- Open every review with a required first line that starts with
  `Review stance:` and then states these three commitments in the repo's reply
  language: read-only reviewer; will not modify the reviewed worktree; output
  is findings plus suggested patches. Missing this first line is a
  review-format violation.
- End at the findings report. The recurring urge to fix, patch, or offer to
  "switch to author" mid-review is the author reflex -- treat it as a signal to
  re-read this rule. If implementation help is worth mentioning at all, one
  line, once; the review must end at the "Next actions" block -- never at an
  offer.
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

### Phase 0 — Pin the scope

- Fetch the exact target yourself before reviewing. For a PR / commit range, save `gh pr diff <N>` or `git diff <A>..<B>` to a scratch file. For a plan review, save the full plan file snapshot, not only the current diff, because stale or missing Verification checkboxes can live outside changed hunks. The saved artifact is the review scope.
- Verify checkout alignment before reading code: worktree HEAD equals the PR head or requested commit, `git status --porcelain` is clean except explicitly in-scope review artifacts, and merge-base against `origin/main` is current.
- Never review from memory or from the author's description.

### Phase 1 — Independent finder angles

Run each angle as an independent pass over the same pinned scope. With subagent support, fan the angles out in parallel; without subagents, run them sequentially one at a time and write candidates to a scratch file before starting the next angle. Every candidate needs `file`, `line`, a one-line `summary`, a concrete `failure_scenario` (inputs/state -> wrong output), and `attribution` (`pr_introduced`, `pre_existing`, or `environment`). Pass every candidate with a nameable failure scenario into Phase 2; do not self-censor before verification.

1. **Line-by-line + removed behavior**: read the full enclosing function / section of every hunk, not just the hunk. For every deleted or replaced line, name the invariant it enforced and find where the new code re-establishes it.
2. **Cross-file tracer**: for every changed exported symbol, prefer code-graph tools when state is `available_indexed` (for example codebase-memory MCP `search_graph`, `trace_path`, `get_code_snippet`, `query_graph`, `search_code`). If graph state is `available_unindexed_or_stale`, use graph only for safe discovery or fall back to `rg` and disclose the stale / unindexed gap. If graph state is `unavailable` (`Transport closed`, missing tool, spawn failure), use `rg` / local file reads and disclose the fallback when cross-file tracing affects confidence. Check new preconditions, changed return shapes, newly thrown error types, and any path where a new error gets silently swallowed (warn-only catch, empty catch, continue-quietly loop).
3. **Contract compliance**: the approved plan / spec's literal code blocks are contracts. Compare signatures, error strings, container types (array vs Map), mock shapes, and import forms at byte level against what shipped; document every deviation even when it is a defensible improvement.
4. **Test quality**: use mutation reasoning (if this guard regressed, would any test fail?), missing negative-path assertions (clean path must not alert / exit nonzero), brittle order-dependent mocks, and whether every `vi.mock` path resolves to a real module.
5. **Cleanup / efficiency / reuse**: flag new code duplicating an existing shared helper, redundant mutable state, steady-state log noise per production run, and evidence merges hand-rolled in multiple places.
6. **Conventions and governance**: check the adopting repo's declared conventions addenda（file-scope allowlists、secret boundaries、messaging-channel boundaries、commit types、forbidden reads）；repo 入口的 agent-skills 指標區塊或 playbook 會說 addenda 在哪。

### Phase 2 — Anti-hallucination verify

- Dedup candidates that point at the same line or mechanism, keeping the most concrete failure scenario.
- Re-verify every surviving candidate against the live checkout: quote the exact line that proves or disproves it.
- Assign one verdict per candidate: **CONFIRMED** (can name inputs/state -> wrong output, line quoted), **PLAUSIBLE** (mechanism real, trigger uncertain; state what would confirm it), or **REFUTED** (quote the guarding line and drop it).
- A finding that cannot be anchored to a quoted line in the actual checkout must not be reported.
- Treat finder output, including subagent output, as candidates, never as conclusions; the verify pass belongs to the primary reviewer.

### Phase 3 — Independent re-verification of claimed evidence

- Re-run the author's claimed gates yourself in the actual worktree: focused tests, typecheck, the repo's full check command（例：`npm run check`）, and live smokes where safe. Never relay a green claim you did not reproduce.
- Independently re-check externally checkable claims such as GitHub API state, mergeable state, deployed revision, and vulnerability-alert status.
- Disclose any side effects your verification created (`npm ci`, build artifacts) even when tracked files stay clean.

### Phase 4 — Report

- Verdict first, findings ranked most-severe first, in the repo's reply language.
- Bucket findings: must-fix before merge / needs the user's decision / accepted residual with a named follow-up owner (roadmap step or worklist item; no orphan follow-ups).
- For each finding, include `attribution` (`pr_introduced`, `pre_existing`, or `environment`) so the report distinguishes PR regressions from inherited defects and tooling / environment failures.
- Do not re-litigate decisions the user already pinned. When new evidence changes a pinned decision's cost, report it as evidence with options, not as re-litigation.
- Fix-confirmation mode: diff `previous-reviewed-tip..new-tip`, verify each claimed fix independently as its own contract, re-run the affected gates, and do not re-review the world.
