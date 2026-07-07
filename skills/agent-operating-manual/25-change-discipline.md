# H. Change Discipline

> 讀者：要改制、改名、遷移慣例、切 PR、或執行需要明確 approval 的 agent。
> 目的：把「今天做對了」的 change craft 寫成可查核步驟，讓弱模型不靠記憶、不靠語氣推斷、不靠大而全的最後驗證。

---

## §1 Convention Migration Discipline

用在改名、改 heading、改 workflow 名稱、搬 source of truth、或把舊慣例換成新慣例時。完成前五步都要有證據：

1. **Authoritative search first**：用全 repo search 推導 sync list，不用口頭清單或記憶。記錄 search command、scope、排除邊界，以及每一類 hit 的處理方式。
2. **Frozen boundary declared**：明確宣告哪些歷史面不改，例如 frozen archives、quoted historical evidence、old release notes、compat anchors。邊界要寫進 PR body 或 review notes，不能只留在 chat。
3. **Compat anchor preserved**：改 heading、anchor、ID、link target 時，保留兼容 anchor 或 pointer；若刻意不保留，必須有 link-check / residual-scan 證據證明沒有 live consumer。
4. **Transition bridge written**：新制第一天如何接舊 baseline 要寫清楚。例：舊 audit surface 到新 audit surface的第一筆 row 如何查、舊 counter 如何 rollover、舊 schedule 如何停止。
5. **Residual scan triaged**：收尾跑 residual scan。每個 residual hit 必須分類為 live pointer、compat anchor、glob / validator pattern、read-only historical evidence、或 false positive。零筆 untriaged live instruction 才算完成。

**Pass condition**：PR body 或 release notes 能列出 search command、frozen boundary、compat anchor decision、transition bridge、residual triage summary。

**Fail condition**：只說「我改了所有地方」、只靠 reviewer 記憶列 sync list、或 residual grep 還有活指令但沒有分類。

## §2 Verifiability-Driven Commit Structure

切 commit 的目的不是美觀，是讓每顆 commit 都能用便宜、決定性的 probe 判斷 pass/fail。

- 每顆 commit 應回答：「reviewer 可以用哪一條低成本 probe 知道這顆對了？」
- 同一 PR 可以包含多顆 commit；每顆 commit 的 probe 應獨立可跑，PR body 再把它們彙總。
- 若最後用 squash merge，squash commit message 或 PR closeout 必須保留 probes 的結果摘要。
- 不要把不共享 probe 的變更硬塞同一顆 commit。例：doctrine wording 和 release metadata 可以同 PR，但 metadata probe 是 tag/version consistency，doctrine probe 是 residual scan / public evidence hygiene scan。
- 例外：純 typo 或單行 doc fix 可以一顆 commit 搭配 `git diff --check`；不要為了形式拆到不可讀。

**Good probe examples**：

- byte identity: installed copy equals source skill after `install.sh`.
- residual scan: old term has only compat anchors / historical evidence hits.
- link check: changed anchors still resolve.
- version consistency: annotated tag target and plugin metadata agree.
- presence-only secret check: required variable exists without printing value.

## §3 Approval-Bound Identifiers

Approval is evidence only for the concrete object it names. Do not transfer approval across PRs, commits, tags, deployments, artifacts, or runtime actions.

- Required shape: approval text must name a target class plus identifier, such as `PR #123`, commit `<hash>`, tag `v1.2.3`, deploy revision `<hash>`, or a run-specific artifact ID.
- Ambiguous approval is not approval. If the user says "looks good" while multiple PRs, commits, or runtime actions are in scope, ask which target is approved.
- Prior approval does not carry forward. Approval for PR #123 is zero evidence for PR #124; approval for a docs PR is zero evidence for a later deploy; approval for one broker / runtime action is zero evidence for another.
- Merge, deploy, destructive cleanup, credentialed probe, or real-world action must bind to the specific approved identifier before execution.
- Keep approval evidence in the PR closeout, release notes, or adopting repo audit memory, not only in chat.

**Pass condition**：closeout can point to the approved identifier and the executed identifier, and they match.

**Fail condition**：agent infers approval from tone, old approval, nearby conversation, or a different object.

## §3.1 Plan / PR Lifecycle Discipline

Use this lifecycle for work expected to become a PR, merge, release PR, or
other approval-bound change. This section owns object identity and stop points.
Relay fields, exact approval text, and copy-block formatting remain in
[`10-model-dispatch.md`](10-model-dispatch.md) §3.1; do not fork those rules
here.

1. **branch-first / head-first before implementation**: Establish a concrete
   work branch and current head before substantive implementation when the
   harness permits it. If the environment is a detached head, externally managed
   worktree, or single-checkout source repo, name the current head and the
   constraint instead of pretending branch isolation exists.
2. **plan / spec gate before implementation**: Normative doctrine, relay,
   review, approval, release, and entrypoint changes remain plan-first. When
   user approval is needed to begin implementation or execution, stop at the
   exact-text approval gate defined by `10-model-dispatch.md` §3.1.
3. **PR stop after implementation**: After scoped implementation and agreed
   verification, stop at PR or review handoff. The author does not merge,
   squash merge, tag, publish, deploy, or clean up branches as part of
   implementation closeout unless the user gave a separate approval-bound
   command for that exact action and identifier.
4. **review-passed is not merge approval**: A passed full review or
   fix-confirmation satisfies only the review gate. Merge approval is a separate
   exact-text gate and must name the concrete object, such as `PR #123 at
   <head-sha>` or `local branch <name> at <head-sha>`.
5. **pre-merge recheck**: Before executing an approved merge, re-check that the
   current PR/head still matches the approved identifier, review or
   fix-confirmation still applies, required CI / smoke / repo gates still pass
   or remain explicitly waived, mergeability is current, and accepted residuals
   have durable owners. If the head changed, approval is stale.
6. **squash merge evidence**: Squash merge is allowed only after the pre-merge
   recheck and exact approval. The merge closeout must preserve proof that the
   executed merge corresponds to the reviewed and approved content. Prefer a
   tree equivalence probe: the squash merge commit tree should match the
   approved PR/head tree. If the environment cannot check tree equivalence,
   disclose the gap and name the remaining evidence.

This lifecycle does not define release tagging, publishing, deploys, runtime
actions, worker spawn / wait / consume / close, concurrency caps, worktree
cleanup, local branch cleanup, post-merge push-state cleanup, Agent Trigger Kit
validators, hooks, or outcome taxonomy.

## §4 Public Evidence Hygiene

Doctrine releases can cite evidence, but public evidence must be sanitized.

Treat public references as provenance pointers unless the public artifact itself
contains the full, reviewable evidence. A PR number, commit, or tag can say where
a decision came from; it must not imply that private logs, local paths, or
credentialed probes are publicly verifiable. Keep raw private evidence in the
adopting repo's audit memory and publish only the sanitized conclusion plus the
public-safe pointer.

Allowed in public doctrine / PR bodies:

- public repo name
- public PR number
- public commit hash
- public tag
- sanitized outcome labels, such as `byte-identity passed`

Not allowed in public doctrine / PR bodies:

- absolute local filesystem paths
- usernames or home-directory names
- hostnames, private network names, Tailscale hosts, or machine IDs
- private repo paths or private artifact paths
- raw logs, account identifiers, IP addresses, order IDs, or secret-like values

When evidence is local or private, write a compact public summary and keep the
raw detail in the adopting repo's audit memory.

## Evidence Seeds

| Evidence | Why it matters | Public-safe form |
|---|---|---|
| stock-scanner PR #163 | convention/adoption migration used byte-identity, trigger-layer, docs, and post-merge gates | `stock-scanner PR #163 / commit a4be2d68` |
| v0.3.1 reviewer hardening | release kept related doctrine in one small scope and deferred unrelated candidates | `agent-skills v0.3.1` |
| approval-bound merge flow | PR closeout requires explicit approval for the PR number before squash merge | `approval-bound PR number` |
