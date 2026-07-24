# Relay Decision Rules (Hand-off Request Contract, part 2 of 2)

Continues [`11-relay-fields.md`](11-relay-fields.md), itself part of
[`10-model-dispatch.md`](10-model-dispatch.md) §3.1. Split out only for the
~250-line cap in `40-maintenance.md` §4; no rule text changed.

---


`User action` 是給使用者的人類 routing hint，使用 short tokens 串成有序 sequence；
token 之間用 ` -> `。`self-review` 表示使用者應先自行閱讀 / 判斷；`to-reviewer`
表示把完整 copy block 貼給 reviewer agent；`to-agent` 表示貼給下一個 acting agent，
由 `Next agent action` 說明該 agent 要做什麼；`reply-required-text` 表示在目前 chat
回覆 `Required user text` 指定的精確文字或裁決；`none` 只表示使用者不需回覆或轉貼。
常見預設：
`review-needed` + review 類 `Review:` 用 `self-review -> to-reviewer`；
`ready-for-user-approval` 用 `self-review -> reply-required-text`；
`ready-for-continuation` 用 `self-review -> to-agent`；
pending user disposition 的 `not-ready` 用 `self-review -> reply-required-text`；
已 scoped 且需要下一個 acting agent 修正的 `not-ready` 用 `self-review -> to-agent`；
等待外部證據、CI、policy escalation 或 remote metadata，且沒有 user input 或 next-agent
revision 可用的 `not-ready` 用 `none`；
`complete-no-action-needed` 用 `none`。

Full-context copy rule：pre-spec / design-framing、spec、plan、rule-review、full
review、fix-confirmation 類交接，預設把下一個 agent 判斷或行動需要的完整脈絡放進
單一 `text` fenced copy block：使用者需要 reviewer 看到的補充、pre-spec findings、
review findings、author dispositions、target repo / target、verification state、
final relay block，以及三行 `Review:` 合約。純機械續接時，若 relay block + named
target 已足夠，copy block 可以較短；不確定時偏向 full-context copy，不要讓使用者
猜哪些 finding 要保留。

User notes rule：不要新增 `User notes handling:` 欄位。使用者在 fenced block 外補充的
意見可以作為 reviewer 背景，但不覆寫 contract fields。若 author 要求下一個 agent
必須處理使用者補充，應把該補充納入 copy block 脈絡，或在 `Required user text` 明確
點名需要的裁決；若 `User action:` 含 `reply-required-text`，copy block 外的人類說明
應清楚表示 current chat is waiting for a user reply，但不得複製 exact approval /
disposition text。`Required user text` 仍是 exact approval / disposition text 的唯一 home。

`Accepted residuals` 是 non-blocking findings、FYI、out-of-repo follow-ups、
accepted residuals 的唯一 home。若報告仍有 LOW / FYI / accepted residual /
out-of-repo follow-up，這欄不能寫 `none`，也不能只把它留在 fenced block 外的
散文。格式用 short finding label + disposition + durable tracker/owner；沒有
durable tracker/owner 的 residual 不能被當成已安全收尾。

Durable conclusion capture：任何會改變下一個 agent 判斷或行動的結論，不能只留在
對話散文。pre-spec / design-framing 的 findings、user dispositions、scope decisions
或 follow-ups 若會影響 spec，必須放進 forwarded copy block，並在後續 spec 的
`Pre-Spec Review Disposition` 或等價 section 說明如何處理。若 pre-spec framing 最後
沒有 formal spec，non-blocking follow-up 放進 `Accepted residuals:` 並附 durable
tracker / owner；active state、audit evidence 或 reusable lesson 依 `15-repo-memory.md`
的 v0.5 memory routing 寫入 repo memory。純人類說明且不影響後續行動者，可留在
copy block 外散文。pre-spec / design-framing 交接必須在 relay 或 copy block 明說 work
仍是 pre-spec，讓下一個 agent 知道自己在審或續 design framing，不是執行已核准的
spec / plan。

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
  和 `Review: none-FYI`，且 accepted residuals 已列在 `Accepted residuals` 欄並有
  durable tracker / owner、沒有 blocker；它不是 generic "looks good" status，不能
  繞過 review、fix-confirmation 或 exact approval gate。
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

Relay readiness rule：`Status: not-ready` 不能搭配可立即執行的 `Next agent action`，
除非 `User action` 含 `to-agent`、blocker 是另一個 acting agent 必須修正已 scoped work，
且 `Next agent action` 明確寫出該修正。若 blocker 是 pending user disposition，
`Required user text` 必須明確寫出需要的裁決或文字，且 `Next agent action` 必須是
`none until user provides dispositions` 或同等不可執行描述。

User action consistency rule：`Status: complete-no-action-needed` 必須搭配
`User action: none`。`User action: none` 只表示使用者不需回覆或轉貼，不覆寫
`Next agent action`。`Review: none-FYI` 不能搭配含 `to-reviewer` 的 `User action`。
`Status: not-ready` 不能搭配含 `to-agent` 的 `User action`，除非 blocker 是另一個
acting agent 必須修正已 scoped work，且 `Next agent action` 明確寫出該修正。
pending user disposition 的 `not-ready` 必須使用 `reply-required-text`、在
`Required user text` 寫出需要的輸入，並讓 `Next agent action` 維持不可執行直到輸入存在。
`Status: ready-for-user-approval` 必須使用 `reply-required-text`，且 `Required user text`
必須命名 exact approval text。`Status: ready-for-continuation` 必須使用
`User action: self-review -> to-agent`、`Required user text: n/a`、可執行的
`Next agent action`，且三行 `Review:` 合約必須是 `Review: none-FYI`。review requested
changes 且 blocker 是 acting agent revision 的 `not-ready` handoff 也必須使用
`Review: none-FYI`；修正後返回時才使用 `Review: fix-confirmation vs <prev-tip>`。
`User action` 含 `to-reviewer` 或 `to-agent` 時，copy block 必須包含完整 fenced relay
block 與三行 `Review:` 合約。

若 blocker 來自 GitHub / credential-store / network / remote metadata 類操作，且目前
環境有 sanctioned sandbox escalation 或 outside-sandbox retry 機制，先用該機制重跑
同一個最小命令，再把它寫進 `Blockers`。若 policy 不允許 escalation，就用 Agent
Trigger Kit durable no-report taxonomy 的 `blocked_by_policy` 標記 gap；若 escalation
後成功，繼續執行，不要把 sandbox 內的失敗當成最終狀態。

若 relay signal 是要取得任何 exact-text approval（包含開始 implementation /
execution、merge、tag、deploy、release），`Status` 必須是 `ready-for-user-approval`，
`Required user text` 仍是 exact approval text 的唯一 home；使用者送出該文字後，
下一個 agent 應直接執行 `Next agent action`，不要把同一個 approval 訊號再貼回去
要求二次 review。若 review 仍 pending，approval text 只能作為 pending context，
不能授權 execution；等 review / fix-confirmation 通過後，再送
`ready-for-user-approval` 或 `ready-for-continuation`。

Plan / PR lifecycle routing：branch-first、PR stop、review-passed is not merge
approval、pre-merge recheck、squash merge evidence 等 object-identity /
merge stop-point 規則的 canonical home 是 `25-change-discipline.md` §3.1
`Plan / PR Lifecycle Discipline`。Reviewed-range carry-forward, approval menus,
merge-shape policy, and universal fresh gates live in `26-fresh-gate.md`
§3.4. 本 §3.1 只維護 relay fields、approval text home、copy-block formatting、
Status / User action coherence；不要在這裡重寫 PR lifecycle state machine。

當下一個 agent 還需要選擇執行方式時，預設由交接者直接推薦 route，不要把例行的
「用哪種方式執行」丟回給使用者選。把 route 接在 relay signal 後面：

```text
Execution route: <direct-apply | plan-first | subagent-driven | inline-execution>
Route reason: <why this immediate next action fits>
User approval needed: <yes | no; exact wording lives in Required user text>
```

Route display rule：`Execution route:` 只出現在 executable approval / continuation handoff：
承接者就是會執行 routed work 的 agent/chat、該 routed work 的所有必要 review /
fix-confirmation gate 已完成，且任何 named user approval reply 或
`ready-for-continuation` signal 會依既有 approval-to-execute / continuation rule
直接授權該執行；blocked、review-only、plan-review，或
cross-chat delivery handoffs（例如 findings delivery、fix-confirmation delivery）不顯示
route block。

`Status` 說明現在在哪裡；`Execution route` 只說剩下的工作要怎麼做，兩者不得互相
重寫。`review-only`、`merge-closeout`、`stop` 不是 route 值；那些狀態應由
`Status`、`Next agent action`、`Blockers` 表達。`Required user text` 是核准文字的
唯一 home；route block 只寫是否需要使用者核准，不重複貼 exact text。

Route 判準：
- `direct-apply`：小型、低風險、scope 已清楚，下一個 agent 可直接修改或執行。
- `plan-first`：還沒有可信 plan；下一步是先拆 scope / 寫 plan，不是執行 plan。
- `subagent-driven`：已有 plan，任務可切分，適合一 task 一 agent 加 review loop。
- `inline-execution`：已有 plan，但任務凝聚、較小，適合同一 agent 連續執行並 checkpoint。

只有 route 會改變產品方向、風險、成本、production 狀態、破壞性操作或授權邊界時，
才問使用者。若不確定是否需要授權，merge、destructive、production 一律偏向詢問。

Normative control-contract changes：任何改變 handoff、relay、approval、review、route、
blocker 或 completion semantics 的變更都需要額外謹慎。這類變更預設在 implementation
前使用 `Execution route: plan-first`，implementation 後使用 `Status: review-needed`。
作者可以為 docs-only changes 使用較小的 inline plan，但 final relay 必須要求 fresh
review，除非使用者在同一 session 明確 waive review。

這類變更 in flight 時，governing contract 是最後已 merge 的 doctrine；對 adopting
repos 則是最後已 released tag，不是正在編輯的文字。新文字只在 fresh review 與
merge/release 後生效。Proposed text 只有在比 effective contract 更保守時可提前演練；
絕不能用來授權、放寬或跳過 effective contract 要求的步驟。

Pre-handoff self-check：送出 handoff 前，先默默跑一次這個 compact checklist；不要輸出
attestation、checklist dump、新 relay 欄位或新 `Status:`。若任何項目不成立，先修
handoff 再送出。

- `Status:` 是否是合法 relay status；review 已過、無 exact user approval、且還有
  named continuation 時是否用 `ready-for-continuation`，需要 exact approval text 時
  是否用 `ready-for-user-approval`？
- `Review:` 是否和 `Status:`、`User action:` 一致；若出現 `Execution route:`，是否
  符合 Route display rule 的 executable approval / continuation handoff，而不是
  blocked、review-only、plan-review、findings-delivery 或 fix-confirmation-delivery
  handoff？
- 需要 exact approval / disposition text 時，`Required user text:` 是否非 `n/a` 且精確；
  若 `User action:` 含 `reply-required-text`，copy block 外的人類說明是否清楚表示
  current chat is waiting for a user reply，且沒有複製 exact text？
- 有 repo-specific next action 時，`Target repo:` 是否非 `n/a`？
- 下一步是否 surface-sensitive；若是，`Execution surface:` 是否存在、是否使用 canonical token、是否不含 model names / aliases / intelligence labels？
- `User action:` 含 `to-reviewer` 或 `to-agent` 時，是否只有 exactly one `text` fenced copy block 供使用者轉貼？
- 該 copy block 是否包含完整 relay block 與 three-line `Review:` contract？
- 對下一個 agent 有意義的 review findings、author dispositions、verification state、
  user notes 是否在 copy block 內；不確定時是否偏向 Full-context copy rule？
- 報告含 non-blocking findings、FYI、accepted residuals 或 out-of-repo follow-ups 時，
  `Accepted residuals:` 是否不是 `none`，且每項都有 durable tracker / owner？

Context-health handoff：當 current session 的 context 本身開始不可靠時，先判斷
是否該繼續在本 session 作業，或改成 fresh-session handoff。可繼續的條件是：你能
直接重新核對相關 doctrine file、target head、pending gates、verification state 與
handoff fields。若出現多次 compaction / visible context loss、明顯 slowdown / hang、
反覆失去 task thread、無法確認 skill source provenance、下一步是 approval-bound /
review-bound / release-bound / control-contract change，或本 session 已產生或收到
不合規 handoff，偏向產生 Continuity packet，讓使用者開新 session 或交給 sanctioned
fresh-context worker。不要聲稱 agent 能靜默轉移 authority；fresh session 仍受既有
review、approval、merge、tag、publish 邊界約束。

Continuity packet：fresh-session handoff 不新增 `Status:` 值，使用既有 relay block。
packet 至少帶 target repo / object、effective contract、proposal boundary、pending
gates、verification state、next action、accepted residuals，以及 three-line `Review:`
contract。blocked、plan-review、review-only、findings-delivery、fix-confirmation-delivery 仍不顯示
`Execution route:`。Executable continuity packets include the recommended route block：
當 packet 依 Route display rule 屬於 executable approval / continuation handoff 時，
在 relay signal 後加入推薦的 `Execution route:`、`Route reason:`、`User approval needed:`
block。Do not restate `ready-for-continuation` preconditions here；是否可 continuation
完全依本節上方 canonical `Status:` semantics 和 Route display rule 判斷。

Skill source provenance：當使用者問「是否沒讀到 skill」、「是否 version 沒 bump」、
或 handoff / review miss 可能來自 stale skill surface 時，先分開報告 relevant
surfaces，不要把 source、import、plugin cache、operator-bootstrap 混成一個 freshness
判斷。

- Source checkout：直接讀目前 checkout 的 source files；agent 檢查 source repo
  不需要 plugin bump。Branch-local doctrine / entrypoint text 在 fresh review 與
  merge 前仍是 proposal text，不能用來放寬 effective contract。
- Imported skill copy：讀 adopting repo 的 `.agent-skills/pin`、managed imported files
  和 install metadata。它只會在選定 release/tag/source reference 並 rerun installer /
  upgrade path 後更新；不要手改 generated imported copies 代替 source doctrine。
- Plugin cache：讀 installed plugin metadata 與 runtime discovery state。舊 installed
  plugin version 不會知道新 skill；更新、upgrade、cache refresh、restart 規則屬於
  plugin lifecycle / Agent Trigger Kit mechanism。
- User-level operator bootstrap：讀 managed instruction block 與 template provenance。
  更新 `agent-skills` source doctrine 不會自動改 user-level instructions；需要
  operator-bootstrap propagation 才會更新。
- Mechanism checks：validators、session-check、live-check、version-check、doctor /
  repair flow 屬於 Agent Trigger Kit 或 owning surface；agent-skills 只記錄 portable
  doctrine，不把 runtime collection 寫進 markdown skill。
