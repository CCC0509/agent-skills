# Reviewed-Range Carry-Forward And Universal Fresh Gate Discipline

Continues [`25-change-discipline.md`](25-change-discipline.md) §3.3. Split
out only for the ~250-line cap in `40-maintenance.md` §4; no rule text
changed from the original §3.4. Next:
[`27-workflow-adoption.md`](27-workflow-adoption.md).

---

## §3.4 Reviewed-Range Carry-Forward And Universal Fresh Gate Discipline

Use this lifecycle when reviewed public or cross-repo work needs hosted PR
metadata, approval menus, merge-shape decisions, or remote freshness checks.
This section extends §3.1 and §3.3. Relay fields, exact approval text, and
copy-block formatting remain in [`11-relay-fields.md`](11-relay-fields.md)
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
