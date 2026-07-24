# Relay Block Fields (Hand-off Request Contract, part 1 of 2)

Continues [`10-model-dispatch.md`](10-model-dispatch.md) §3 Report
Contract. Split out only for the ~250-line cap in `40-maintenance.md` §4;
no rule text changed from the original §3.1. Part 2 (decision rules,
`Status:` semantics, pre-handoff self-check) is
[`12-relay-decisions.md`](12-relay-decisions.md).

---

## §3.1 交接請求合約（Hand-off Request Contract）

凡是把工作交給下一個 agent 繼續、merge、execute、或 review，且對方需要知道
你期待它做什麼時，在交接尾端加三行請求合約：

```text
Review: <full | plan/rule-review | fix-confirmation vs <prev-tip> | closeout-sanity | none-FYI>
Focus: <what you are unsure about or want checked>
Prev reviewed tip: <hash or n/a>
```

這三行不是只給 code review。`Review:` 是下一個 agent 的工作模式：
`plan/rule-review` 用於流程、治理、規則草案或 plan 審查；`none-FYI` 表示只同步
狀態、不要求審查。`Focus:` 說明你最不確定的地方；`Prev reviewed tip:` 綁定
上一輪已審過的 commit / PR head，沒有就寫 `n/a`。

Co-occurrence tie-breaker：三行 `Review:` 合約是 reviewer-facing context；`Status:`
relay block 是 user-facing / next-action control signal。兩者同時出現時，consuming
agent MUST follow `Status:` block 來判斷 immediate next action、approval state、
blockers、accepted residuals。若作者想要 review，`Status` 必須是 `review-needed`；
`Review:` alone must not override a `Status: complete-no-action-needed` relay。Contract
block 欄位優先於 fenced block 外散文；只有 `Review:` 而沒有 `Status:` 的交接不授權
execution、approval、merge、deploy 或 release。

若交接文字是要讓使用者複製給另一個 agent，請把「要複製的完整內容」放進單一
`text` fenced code block。區塊外只放人類說明、風險或狀態；不要把不需要轉貼的
敘述混進區塊。沒有這個合約時，下一個 agent 必須猜意圖；猜對也算交接缺陷。

當交接是要告訴使用者「現在能不能交給下一個 agent / 核准 merge / 停止轉貼」時，
同樣用單一 `text` block 給 relay signal：

```text
Status: <review-needed | ready-for-user-approval | ready-for-continuation | complete-no-action-needed | not-ready>
Target repo: <owner/repo or absolute local repo path, or n/a>
Target: <PR/branch/task + head SHA, or n/a>
Required user text: <exact approval/merge text, required user input, or n/a>
Execution surface: <any | codex-current-session | codex-fresh-session | codex-host-cli | claude-code-current-session | claude-code-fresh-session | claude-code-host-cli | user-executed | multi-surface: ...>
User action: <self-review | to-reviewer | to-agent | reply-required-text | none>[ -> ...]
Next agent action: <what another agent should do, or none>
Blockers: <none, or concise blockers>
Accepted residuals: <none | short finding label + disposition + durable tracker/owner>
```

Completion-report stage: when a named scoped task, task slice, or train stage
has finished to its
current stop point and the closeout pivots to another task, approval-bound
object, or later lane, add this stage immediately before the relay block or
approval menu:

```text
Completed task: <specific completed task or object, with compact durable evidence pointer>
Recommended next task: <one recommended next task, or n/a>
```

These are stage lines, not relay fields. The stage does not add a relay field
or a `Status:` value. Do not use `Completed task:` to make partial or blocked
work look terminal.

Use the stage when all of these are true:

- a named scoped task, task slice, or train stage finished to the task's
  current proof-backed stop point;
- the closeout pivots to another task, approval-bound object, or later lane;
- the next action is not merely the same unfinished task continuing under the
  same blocker.

The completed task needs a compact durable evidence pointer, such as a commit,
PR, tag, review record, closeout record, smoke result, or public-safe
attestation. The stage creates no new authority: it cannot turn skipped
verification into verification, author confidence into review, or a pending
approval-bound object into an approved action.

`Recommended next task:` is advisory orientation. It must name exactly one
recommended task, or `n/a`. `Status:` remains authoritative for the immediate
relay state. `Required user text:` remains the only exact-approval text home.
`Accepted residuals:` remains the non-blocking residual home. `Execution route:`
remains governed by the existing route display rule. If `Recommended next
task:` contradicts `Next agent action:`, the handoff is defective and must be
fixed before forwarding.

When a handoff is forwarded to another agent or reviewer, include the stage
inside the same fenced `text` copy block above `Status:`. When an approval menu
is needed, the approval menu can follow the stage, but every executable item
still needs exact object identity under the existing approval rules.
`Recommended next task:` may identify one preferred approval item, but it does
not approve it.

Forwarded copy-block placement example:

```text
Completed task: formal spec authored and checked; evidence reviews/example-formal-spec-review.md
Recommended next task: request plan/rule-review of the implementation plan

Status: review-needed
Target repo: owner/repo
Target: plans/example-implementation.md at abc1234
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review the implementation plan against the formal spec
Blockers: none
Accepted residuals: none

Review: plan/rule-review
Focus: <what you are unsure about or want checked>
Prev reviewed tip: <hash or n/a>
```

Examples:

- `Status: review-needed`: `Completed task: formal spec authored and checked;
  evidence specs/portfolio/example-design.md plus review request`, then
  `Recommended next task: request plan/rule-review of the implementation plan`.
- `Status: ready-for-user-approval`: `Completed task: reviewed branch reached
  merge stop point; evidence PR #123 at abc1234`, then `Recommended next task:
  request exact merge approval for PR #123 at abc1234`.
- `Status: ready-for-continuation`: `Completed task: fix-confirmation passed
  for the formal spec; evidence reviews/portfolio/example-fix-confirmation.md`,
  then `Recommended next task: author the implementation plan`.
- `Status: complete-no-action-needed`: `Completed task: docs-only closeout
  recorded; evidence reviews/portfolio/example-closeout.md`, then
  `Recommended next task: n/a`.

Allowed difference example: `Recommended next task: request plan/rule-review of
the implementation plan` differs from `Next agent action:` without
contradicting it when `Next agent action:` says `review the implementation plan
against the formal spec`; both point to the same review lane.

Blocking difference example: `Recommended next task: update imported copies`
conflicts with `Next agent action: revise the current requested-changes
finding`; the difference is a blocker because it points the receiver at a
different immediate task and could imply an approval-bound imported-copy action.

`Target repo` 是 cross-repo handoff 的 durable routing field。已知 remote identity 時用
`owner/repo`；下一步依賴 local checkout 時用 absolute local repo path；只有沒有
repo-specific next action 時才用 `n/a`。`Target` 保持原本語意，只描述該 repo 內的
PR、branch、task、head SHA 或其他 work item。不要只把 intended repo 藏在 relay
block 外的散文。

Execution surface routes surface-sensitive work to the required runtime, sandbox, auth, or user-execution boundary. It does not grant approval, choose a model, choose an implementation route, or make a blocked action safe.

The field is optional for ordinary relay blocks and mandatory for new surface-sensitive handoffs. Surface-sensitive work includes fresh-session or live behavior probes, credential-store / keychain / auth / plugin-cache / global-config checks, Claude Code versus Codex command execution, user-executed terminal commands, multi-agent workflow steps, and work where the user or reviewed plan says only one agent or one surface should execute the next step.

Canonical values:

- `any`
- `codex-current-session`
- `codex-fresh-session`
- `codex-host-cli`
- `claude-code-current-session`
- `claude-code-fresh-session`
- `claude-code-host-cli`
- `user-executed`
- `multi-surface: <controlled token roles and constraints>`

Freeform role text is allowed only after `multi-surface:`. Single-surface tokens stay controlled. Do not put model names, model aliases, intelligence labels, effort names, account names, or cost tiers in `Execution surface:`.
Model choice belongs to capability-based model routing and the relevant model adapter.

Missing, ambiguous, or conflicting `Execution surface:` is a blocker for surface-sensitive work. The field never overrides `Status:`, `Review:`, a reviewed plan, exact approval boundaries, `User action:`, `Next agent action:`, or `Execution route:`.

Older relay blocks without `Execution surface:` remain valid. Absence means
unconstrained unless the receiving agent can identify that the next action is
surface-sensitive. If surface sensitivity is discovered during consumption,
stop for a handoff repair, route decision, or plan revision instead of
guessing.

Single-surface requirements must not be broadened into multi-surface fallback without a reviewed plan or later user decision. If the named surface reports `tool_unavailable` or `blocked_by_policy`, record the evidence and stop at the appropriate route decision or blocker. Do not try another surface by habit.

User-observed GUI concerns about repeated auth failures, surprising retries, or no-progress loops are valid control-contract input. Treat them as surface-routing evidence when they concern surface selection, auth visibility, sandbox behavior, external-service egress, or surface mismatch. The agent should pause, explain the surface evidence, and return to the relevant review, route, or plan gate instead of silently continuing retries.

Capability/surface preflight applies before new surface-sensitive execution. It checks whether the requested surface can safely perform the next action, whether the handoff allows one surface or multiple surfaces, whether auth and egress are visible from the executing surface, and when to stop instead of trying fallback routes.

Use the existing surface-sensitive definition above. For this preflight, host or sandbox checks are also surface-sensitive, and relay text is another source of one-surface requirements when the relay itself constrains the next action.

Organization names are also forbidden in `Execution surface:`.

The preflight has six layers:

1. **Handoff surface parse.** Identify whether the next action is unconstrained, controlled single-surface, `multi-surface:` with role text, `user-executed`, missing, ambiguous, or conflicting. If surface-sensitive work lacks a usable `Execution surface:`, stop for handoff repair, route decision, or plan revision. The field never overrides `Status:`, `Review:`, a reviewed plan, exact approval boundaries, `User action:`, `Next agent action:`, or `Execution route:`.
2. **Capability inventory.** Check only the capabilities needed by the immediate next action, such as subagent launcher availability, worker wait/result/cleanup lifecycle, background job status/result/cancel lifecycle, CLI visibility, browser/app connector/MCP availability, filesystem or sandbox access, and user-executed command ownership. Missing capability is a capability gap, not agent error.
3. **Runtime smoke where safe.** Help text, binary discovery, a command path, or launcher presence proves only presence. A surface execution claim requires the smallest non-destructive invocation that exercises the relevant surface. If that invocation would cross external-service egress, credential-store access, plugin refresh, package install, global config mutation, live behavior evidence, or another approval gate, record the surface as blocked or unproven and stop.
4. **Presence-only auth visibility.** Check auth from the surface that will execute the action. Host auth does not prove sandbox auth. Sandbox-missing auth does not prove the user is logged out on the host. Plain-language classes are: not required; not checked; status visible: a status-only check is available and safe from the executing surface, but has not yet produced a `present` or `missing` result; present; missing; blocked. Do not record secret values, account identifiers, organization identifiers, tokens, key material, raw credential-store output, or private auth logs.
5. **Policy and egress check.** External-service egress is route authorization, not merely login status. Classify policy and egress gaps in prose, such as sandbox boundary, network or external-service egress block, credential-store or keychain boundary, account or organization boundary, host permission boundary, plugin-cache or global-config boundary, user-owned terminal decision, or public/private evidence boundary.
6. **Execution disposition.** Proceed only when the named surface passes the needed checks. Otherwise stop for handoff repair, route decision, reviewed plan or plan amendment, exact user approval naming the action and object, or accepted residual with durable owner. `Execution route:` remains governed by the existing route display rule.

Single-surface fallback requires a reviewed plan, reviewed plan amendment, or explicit user route decision naming the replacement surface. The consumer must not broaden to another agent, host shell, fresh session, current session, user terminal, or external service merely because that alternative might work.

For `multi-surface:` handoffs, each role needs its own named surface, capability check, auth/egress visibility when relevant, and stop condition. One multi-surface role passing does not satisfy another role.

Plans that require subagent-driven execution or fresh-context verification must preflight launcher support before trying to spawn workers. Minimum inventory is launcher availability, wait or completion observation, result retrieval, and cleanup or cancellation semantics when relevant. If a load-bearing piece is missing, record a capability gap and stop. Do not repeatedly call unavailable tools.

Preflight results are immediate, surface-bound, and time-bound. Use them to decide whether the next action can proceed; do not treat them as permanent proof that future sessions, accounts, policies, or tools have the same capabilities. Carry results in existing relay prose, `Blockers:`, `Accepted residuals:`, review records, or status memory. Do not add relay fields for preflight results.

No new machine-readable outcome tokens are introduced by capability/surface preflight. Only `tool_unavailable` and `blocked_by_policy` are reviewed machine tokens for this lane. Login-status wording is not a machine token for this lane. Capability gap, auth-visibility gap, policy block, egress block, and surface mismatch are prose classifications. Any durable taxonomy extension belongs to Agent Trigger Kit through a reviewed mechanism plan.

Ordinary low-risk docs work does not need a full capability/surface preflight unless it introduces or depends on a surface-sensitive action.
