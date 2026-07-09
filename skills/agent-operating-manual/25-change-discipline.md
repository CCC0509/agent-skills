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
   command for that exact action and identifier. If no hosted PR exists, the
   local equivalent is still a stop point: identify the branch/head and ask for
   review of the exact range. Do not convert "local only" into permission to
   skip review.
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

This Plan / PR lifecycle does not define deploys, runtime actions, worker spawn
/ wait / consume / close, concurrency caps, worktree cleanup, local branch
cleanup, post-merge push-state cleanup, Agent Trigger Kit validators, hooks, or
outcome taxonomy; release tagging and publishing are defined in §3.2 below.

## §3.2 Release Tag / Publish Lifecycle Discipline

Use this lifecycle for release actions after reviewed content exists. This
section owns release object identity and irreversible stop points. Relay fields,
copy-block formatting, and exact approval text placement remain in
[`10-model-dispatch.md`](10-model-dispatch.md) §3.1. Install mechanics remain in
`README.md`, `install.sh`, and `tests/install-smoke.sh`.

1. **Implementation / metadata train**: a reviewed branch may bump
   `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` when it
   changes install-facing doctrine or plugin surface. A metadata bump is not a
   tag, tag-push, publish, install, deploy, merge, or adopting-repo
   authorization.
2. **Reviewed main candidate**: the candidate commit is on `main` or a reviewed
   release branch, required review or fix-confirmation has passed, the worktree
   is clean, and both manifests agree on the intended version.
3. **Pre-tag approval gate**: stop with `Status: ready-for-user-approval`.
   Required text must name the exact annotated tag and target commit, for
   example `approve create annotated tag v0.5.6 at COMMIT_SHA`.
4. **Local annotated tag created**: after exact approval, create an annotated
   tag and verify the peeled target with `git rev-parse vX.Y.Z^{}`. The peeled
   target must equal the approved commit. Prefer annotated tags; the old
   `v0.1.0` lightweight tag is historical.
5. **Pre-tag-push approval gate**: if the tag is not on the remote, stop again
   unless prior approval explicitly named pushing that tag to that remote.
   Required text must name tag, target commit, and remote, for example
   `approve push tag v0.5.6 targeting COMMIT_SHA to origin`.
6. **Remote tag verified**: after tag push, verify the remote tag identity with
   `git ls-remote --tags origin vX.Y.Z` and, when available, a fetched local
   peeled-target check.
7. **Post-tag smoke**: from a clean checkout at the exact tag, prove normal
   install no longer needs `--dev`. At minimum, run `bash tests/install-smoke.sh`
   and a direct tagged-source `./install.sh "$TMP/target"` probe that records
   pin `CCC0509/agent-skills@vX.Y.Z`.
8. **Publish inventory / approval gate**: if another publish surface exists
   beyond the pushed tag, first identify the exact surface and command or
   platform action. Stop with `Status: ready-for-user-approval` before that
   publish. If no separate publish surface exists, say so explicitly and do not
   invent one.
9. **Post-publish verification**: verify the published surface independently
   where possible. If credentials, policy, CLI availability, or marketplace
   semantics block verification, report the gap as a blocker or accepted
   residual with a durable owner; do not route around credentials or policy.
10. **Terminal closeout**: emit `Status: complete-no-action-needed` only when
    tag, publish, and verification actions are complete and no user or
    next-agent action remains. Otherwise follow the relay status rules in
    `10-model-dispatch.md` §3.1.

Approval does not transfer:

- Metadata bump approval does not authorize tag creation.
- Tag creation approval does not authorize pushing the tag unless the exact
  text says so.
- Pushing a tag does not authorize any separate marketplace, GitHub release,
  package registry, plugin publish action, or adopting-repo install.
- A prior release approval does not authorize a later version or later commit.
- If the candidate commit changes after approval, approval is stale.

Do not backfill missing tags for already-public trains unless a separate
reviewed release-repair plan authorizes that exact backfill. The normal path is
to tag the reviewed release head with the current manifest version.

## §3.3 Public PR / Release Train Discipline

Use this lifecycle in public source repos where branch, PR, public `main`
history, and release evidence are visible to adopters. It extends §3.1 and
enters §3.2; relay fields, exact approval text placement, and copy-block shape
remain in [`10-model-dispatch.md`](10-model-dispatch.md) §3.1.

1. **public train branch**: substantive public-repo work starts on a named
   branch with a named base commit. Normative doctrine, release, entrypoint,
   installer, metadata, and public artifact changes remain plan-first. Direct
   public `main` edits require an explicit emergency or tiny administrative
   repair approval, and closeout must say why branch / PR routing did not
   apply.
2. **hosted PR or local equivalent**: when network and platform access allow
   it, push the branch and open a hosted PR before merge. If the harness cannot
   open a hosted PR, the local equivalent is a review handoff naming exact
   branch, base, head, and range. Local-only work is still review-bound.
3. **evidence-bearing PR**: keep public-safe specs, plans, review results,
   smoke evidence, and author verification on the branch, in the PR body, in
   the squash body, release notes, or another durable public record. Do not
   publish raw private paths, raw local logs, or secret-like evidence.
4. **public merge candidate**: after full review or fix-confirmation, follow
   §3.1 rule 4 for exact merge approval naming the PR/head or local
   branch/head. Do not restate or weaken that gate here.
5. **merge shape chosen**: prefer hosted PR squash merge when the PR preserves
   detailed evidence. Hosted rebase or merge commits are allowed when commit
   granularity is intentionally public and each commit has a clear probe. A
   local squash / release commit is allowed when hosted PR tooling is
   unavailable; prove tree equivalence to the approved branch head or disclose
   the verification gap. Fast-forwarding a multi-commit train into public
   `main` is exceptional after this rule lands and must be explicitly chosen.
6. **public main closeout**: after merge and push, verify remote `main` points
   at the executed merge object.
   `complete-no-action-needed means no release remains`, no next-agent action
   remains, and all accepted residuals have owners. If install-facing metadata
   changed, surface the release choice: direct §3.2 pre-tag approval, or an
   explicit batched release train record.

`version-only` public history is allowed only after evidence is durably
captured elsewhere. A terse version commit, squash subject, or closeout cannot
erase review, probe, approval, residual, or tree-equivalence evidence required
by §2 and §3.1.

Post-push examples:

- No release remains: a docs-only PR is merged and pushed, remote `main`
  matches the executed commit, no residuals remain, and
  `Status: complete-no-action-needed` is correct.
- Release choice remains: an install-facing PR is merged and pushed; stop at
  direct §3.2 tag approval or record the batched release train before claiming
  terminal closeout.
- Review remains: a branch is pushed but review has not passed, so use
  `Status: review-needed`.
- Merge approval remains: full review passed but exact PR/head merge approval
  has not been given, so use `Status: ready-for-user-approval` under
  `10-model-dispatch.md` §3.1.

## §3.4 Reviewed-Range Carry-Forward And Universal Fresh Gate Discipline

Use this lifecycle when reviewed public or cross-repo work needs hosted PR
metadata, approval menus, merge-shape decisions, or remote freshness checks.
This section extends §3.1 and §3.3. Relay fields, exact approval text, and
copy-block formatting remain in [`10-model-dispatch.md`](10-model-dispatch.md)
§3.1.

### Reviewed-Range Carry-Forward

Carry-forward transfers review only; it never transfers approval.

Creating a hosted PR from an already reviewed branch head is metadata
publication, not a new content change, when all of these are true:

- the hosted PR head commit is the reviewed head;
- the hosted PR head tree is the reviewed tree;
- the PR targets the intended base branch;
- freshness is re-verified for the relevant local and remote refs;
- the PR body, title, labels, or hosted metadata do not add
  contract-changing claims beyond the reviewed branch content and public-safe
  evidence.

Carry-forward is invalidated by new head commits, head rewrites, a different
head tree, material base change, new CI or required-check failures, conflict
state, contract-changing PR-body / title / release-note edits, or
release-metadata changes not covered by the reviewed range.

Routine hosted metadata does not invalidate carry-forward when it does not
change the contract. Examples include PR number assignment, draft/open state,
timestamps, reviewer assignment, branch-protection metadata, or labels that do
not make behavioral, release, or approval claims.

A no-effect base advance may remain carry-forward only after a recorded fresh
recheck shows no change to reviewed diff, tree, required checks, conflict
state, public evidence placement, or release candidate identity.

Minimum carry-forward records name the reviewed object, current hosted object,
reviewed head/tree, current head/tree, intended base, freshness result,
PR-body contract check, invalidation check, and scope: review only, no
approval.

### Approval Menus And Object Identity

Approval menus may show several next actions, but each menu row remains its own
object-bound approval. The agent may execute only rows whose object identities
are known, approved, and freshly rechecked at execution time.

Input-object approvals name a fully known input object and may create
platform-assigned output identifiers that are recorded after execution. For
example, `approve push branch feature at HEAD to origin and create a draft PR`
names the branch, head, remote, and PR action; the PR number is output metadata
to record after creation.

Unknown future objects remain hard stops before approval. A post-squash main
commit, generated release artifact, or tag target that does not yet exist may
be listed as a pending future step for visibility, but it cannot be exact
approval text until the object exists and is named.

Disallowed menu shapes:

- `approve the rest`;
- `continue release train`;
- `merge and tag the result` when the tag target commit does not yet exist;
- any wording that turns a future object into an approved object before it is
  created and verified.

### Merge-Shape Policy Point

agent-skills preserves reviewed commits by default. Squash remains a
per-change election that must preserve review and probe evidence in the PR
body, squash body, release notes, or another durable public-safe record.

When squash is elected, prefer tree equivalence between the executed squash
merge result and the reviewed branch tree. If tree equivalence cannot be
proved, disclose the gap before claiming carry-forward review transferred.

Adopting repos may choose stricter merge-shape defaults in local policy.
stock-scanner remains a repo-specific adapter and comparison point; portable
doctrine adopts only fail-loud freshness and squash-tree-equivalence patterns
from that repo.

### Universal Fresh Gate

Fresh gate action classes: read-only/planning, edit, branch, push, PR
open/update, merge, tag, release/publish, cleanup.

`freshness-unverified` is the only freshness-gap outcome label. Use it when the
agent attempted or considered the required freshness check but could not verify
the relevant refs. Cite the cause in prose, such as network unavailable,
credential unavailable, policy denied remote access, sandbox denied remote
access, remote missing, or offline work explicitly allowed.

Do not use evidence verdict tokens, auth-failure labels, alternate snake_case
freshness labels, or other synonyms as freshness outcomes. Those terms belong
to other systems or create drift.

Read-only or local-only work may continue with `freshness-unverified` only when
the handoff discloses the cause and no publication, merge, tag, release,
publish, or cleanup action is implied. Local-only edits under
`freshness-unverified` need a new fresh gate before any publication action.
Publication actions may not proceed under `freshness-unverified`.

Minimum gates:

- Read-only/planning: identify whether the repo has a remote; if the answer
  depends on remote state, fetch or query the relevant remote; record
  `freshness-unverified` with cause when remote state cannot be verified.
- Edit: identify current branch and intended base; fetch intended base when a
  remote exists and access is available; stop on stale or diverged state unless
  the task is explicitly local-only or the user accepts offline/stale work.
- Branch: fetch the intended base, record base branch and commit, and create or
  select the branch only after the base identity is known.
- Push: fetch target remote branch and intended base, verify local head is the
  intended head, verify remote branch absence/equality/fast-forward
  expectation, and never force-push as a freshness workaround.
- PR open/update: fetch or query remote branch state, verify hosted head and
  target base, verify PR body/metadata do not add unreviewed contract-changing
  claims, and record whether the action is metadata-only.
- Merge: fetch PR head and base refs, verify the approved PR/head still
  matches the hosted object, verify carry-forward review still applies or ask
  for review/fix-confirmation, verify checks or reviewed waivers, and execute
  only the approved merge shape.
- Tag: fetch tags and the target commit branch, verify the exact target commit,
  verify tag absence or matching identity, stop if the tag points elsewhere,
  and create or push only the exact approved tag.
- Release/publish: verify the release or publish surface, verify the tag or
  source object, verify the current object matches the approved identifier, and
  stop on credentials, policy, marketplace, or remote-state gaps unless a
  reviewed plan classifies the action as read-only verification.
- Cleanup: fetch/prune relevant refs where a remote exists, prove the
  branch/worktree is merged, explicitly abandoned, or safe under repo policy.
  For squash-merged work, ancestry alone is insufficient; use tree
  equivalence, hosted merge state, or reviewed proof that the branch content is
  preserved before deleting local or remote refs. Do not delete remote branches
  by default unless exact approval names that remote branch cleanup.

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
