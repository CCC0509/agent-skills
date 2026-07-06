# C. 模型調度守則（Model-Dispatch Doctrine）

> 讀者：較弱模型（Sonnet / Haiku 等）當「指揮官」時。
> 目的：修 `00-diagnosis.md` 的 **Leak 3**（inline 讀爆 context、失焦、假性完成）。
> 這一節多數是**跨 harness 通則**；只有「§5 模型別名 / §6 effort / §7 Agent vs Workflow」是 **Claude Code 專屬**，已用 🟦 標出，搬到別的 agent 要換掉。
> Codex users: read [`codex-model-adapter.md`](codex-model-adapter.md) instead of copying §5-§7 literally.
> Gemini users: read [`gemini-model-adapter.md`](gemini-model-adapter.md) instead of copying §5-§7 literally.

---

## §0 一句話原則：指揮官不下場

**主對話 = 指揮官。指揮官只做三件事：分派、吃結論、下判斷。** 大量讀取、掃 repo、查網頁、批次改檔——這些是「下場勞動」，一律派 subagent，主線只收**結論 + `file:line`**。

**為什麼**：主線的 context 是你唯一的、會被塞爆的資源。一旦你 inline 讀 15 個檔，還沒動手 context 就沒了、任務主軸也丟了。subagent 的職責是**壓縮**：它讀 15 個檔，回你 200 字結論。這就是防 context 讀爆的機制。

---

## §1 何時派工 vs 何時自己做（明確判準）

**符合任一 → 派 subagent，不要 inline 做：**
- 需要開 **>2 個未讀檔**、且**得邊讀邊找**（探索性）才能回答。（已知路徑、目標明確的少數幾個小檔 → 自己讀更快，見下方「自己做」。）
- 任何**結果集你無法預測**的 repo-wide 搜尋 / grep / glob（探索性搜尋）。
- 任何**查網頁 / 查外部套件文件**。
- 任何**跨 >3 個檔的機械式改動**（把一個已知 transformation 套到很多檔）。
- 任何**長輸出指令**（你得翻很久才找到重點的那種）。

**以下自己做（不要為了派而派，過度委派一樣浪費 token）：**
- 改**你已經讀過**的 1–3 個檔。
- 對**已知路徑**的檔做單次、目標明確的 `Read`。
- **最終決策 / 綜合判斷**——這是指揮官的本職，**判斷永遠不外包**。
- 一行、結果短且可預測的指令（`git status`、跑一個測試檔）。

> 判準的精神：**委派「勞動」，保留「判斷」。** 勞動可以壓縮成結論；判斷不能。

---

## §2 派工三件套（每次委派都必含）

每一個 subagent prompt 都要有這三塊，缺一不可。填空模板見 [`30-dispatch-templates.md`](30-dispatch-templates.md)。

1. **目標與動機**：要什麼＋**為什麼**。動機讓 subagent 在遇到你沒預料的岔路時，能替你做對的取捨（沒有動機，它只會照字面做，撞到邊界就亂猜）。
2. **驗收條件**：具體、可勾稽。「看完你的回報我能判斷 X / 做出 Y 決定」。模糊的驗收＝subagent 不知道何時算完成。
3. **回報格式**：結構 + 長度上限 + **「只回結論與 `file:line`，不要貼大段檔案」** + 長產物落檔傳路徑。

**反例（不要這樣派）**：「幫我看看 scraper 有沒有問題」——沒動機、沒驗收、沒格式，subagent 會回一大坨它自己也不確定的東西，把你 context 塞爆。

---

## §3 回報合約（Report Contract）

subagent 回給主線的東西，**預設只有兩種**：
- **結論**（判斷 / 答案 / 清單），配 **`path:line` 佐證**。
- **長產物**（報告、產生的程式碼、資料）→ **寫進檔案**，回**檔案路徑 + ≤3 行摘要**。

**絕對不要**：把整個檔案內容、整份搜尋結果、整段 log 傾印回主線。那等於把 subagent 的 context 污染倒進指揮官的 context，前功盡棄。

> 一句檢查：subagent 回來的東西，如果你**還要再讀一次原始檔才懂**，代表它沒做壓縮的工作，退回去要它重寫回報。

### §3.1 交接請求合約（Hand-off Request Contract）

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

若交接文字是要讓使用者複製給另一個 agent，請把「要複製的完整內容」放進單一
`text` fenced code block。區塊外只放人類說明、風險或狀態；不要把不需要轉貼的
敘述混進區塊。沒有這個合約時，下一個 agent 必須猜意圖；猜對也算交接缺陷。

當交接是要告訴使用者「現在能不能交給下一個 agent / 核准 merge / 停止轉貼」時，
同樣用單一 `text` block 給 relay signal：

```text
Status: <review-needed | ready-for-user-approval | complete-no-action-needed | not-ready>
Target: <PR/branch/task + head SHA, or n/a>
Required user text: <exact approval/merge text, or n/a>
Next agent action: <what another agent should do, or none>
Blockers: <none, or concise blockers>
```

只在所有 review / fix-confirmation 都解完、目前 head 已核對、驗證與 accepted gaps
都列明時，才能用 `ready-for-user-approval`。只有工作已完全收尾、沒有下一個 agent
或使用者動作時，才能用 `complete-no-action-needed`；這是提醒使用者不要再把同一段
closeout 貼給另一個 agent 空跑。若還需要 review、修正、merge、tag、deploy、或
任何外部證據，就用 `review-needed` 或 `not-ready` 並列 blocker。

當下一個 agent 還需要選擇執行方式時，預設由交接者直接推薦 route，不要把例行的
「用哪種方式執行」丟回給使用者選。把 route 接在 relay signal 後面：

```text
Execution route: <direct-apply | plan-first | subagent-driven | inline-execution>
Route reason: <why this immediate next action fits>
User approval needed: <yes | no; exact wording lives in Required user text>
```

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

---

## §4 驗證不自驗（Verify, not self-verify）

**做事的 agent 不能當自己的驗收官。** 驗收要交給**新 context** 的 agent 或
機器判定；如果 harness 沒有 fresh-context worker，就用決定性 probe 並揭露
剩下的驗證缺口，不要把作者自己的語氣當驗收。按產物類型：

| 產物 | 驗收方式 |
|---|---|
| 檔案 / 文件 | fresh-context agent **read-back**：「這個檔有沒有含 X、Y、Z？把那幾行引出來。」 |
| 程式碼 | **實跑 / 跑測試**——不接受「應該會動」。能跑就跑，跑不了就說明為何跑不了。 |
| 高風險判斷 | **第二意見** agent，或**產生 N 個答案 + 一個 judge 選優/合併**。 |

細部判準（何時才算真的「done」）見 [`20-judgment-rubrics.md`](20-judgment-rubrics.md) §2。

---

## §4.1 進度、時鐘、驗證副作用（Progress / Clock / Side-effect Discipline）

進度記錄分兩層：session-local tracker 管當下執行，repo-local plan / spec checkbox 管跨 agent、跨 session 的耐久狀態。

- 如果 harness 有 TodoWrite / task-tracking surface，用它管理當下執行；但它不是 plan checkbox 的替代品。每個 checkpoint / commit 點都要把 plan / spec 裡已完成、已驗證的 `- [ ]` 同步改成 `- [x]`。
- 如果 harness 沒有 task-tracking surface，plan / spec checkbox 就是你的 todo list。完成一步就更新 checkbox，不要等 closeout 才一次補。
- 排序看正在跑的時鐘，不只看概念順序。會燒 quota、會 automerge、會過期、會阻塞別人的事，優先級高於沒有時鐘壓力的 doctrine polish。
- 驗證會留下副作用時要記帳：暫存檔、gitignored outcome store、cache、remote check run、外部服務 read-back，都要在回報中揭露。
- 環境 kill switch 只包住目標命令。跑整個 test suite 前先判斷 env var 會不會被 spawned child process 繼承；會污染子行程預期時，不要把它掛在整輪測試外層。

---

## §5 🟦 模型選擇表（Claude Code 專屬）

**已查證事實**：Agent 工具的 `model` 可指定 `haiku` / `sonnet` / `opus` / `fable`（或完整 model ID）；不指定時**繼承主對話模型**。

| model | 用在 | 不要用在 | 成本 |
|---|---|---|---|
| **haiku** | 機械、規格明確、可批量：套用已知 pattern 到多檔、格式化、單檔查值、**read-back 驗證**、簡單 grep 整理、廣度掃檔（Explore） | 需要推理判斷、模糊任務、架構決策 | 最低 |
| **sonnet** | **預設 worker**。實作、審查、多數搜尋、寫測試、一般委派。**不確定用哪個 → sonnet** | 全場最難的推理 / 對抗式仲裁 | 中 |
| **opus** | 最難推理：架構決策、模糊 bug 的 root-cause、高風險宣稱的**對抗式驗證**、judge / synthesis | 機械批量（用它跑批量是浪費） | 高 |
| **fable** | 極少數 max-stakes 一次性判斷（品味 / 取捨仲裁）。**預設不用**；用前先確認你的 operator 有授權它可用 | 日常任務 | 最高 |

**日常升降級只用三階：haiku → sonnet → opus。** fable 是可選頂階，只有 operator 明說可用、且任務是 max-stakes 一次性判斷時才動；否則用 opus。

> 誠實標註：我沒有 fable vs opus 的公開能力排序基準，不憑印象斷言誰更強。把 fable 當「operator 指定的 premium 頂階」，需要時再問，不預設常用。

---

## §6 🟦 Effort 控制的真相（Claude Code 專屬，別搞錯）

**已查證**：
- **一般 Agent / Task 呼叫沒有 `effort` 參數——你不能逐次替某個 subagent 設 effort。**
- 你**能**逐次設的是 **`model`**（見 §5）。
- effort 的實際控制途徑只有三條：
  1. **session 層級**：`CLAUDE_CODE_EFFORT_LEVEL` 環境變數（全域覆寫），subagent 繼承。
  2. **預先定義的 custom subagent type**：其 frontmatter 可帶 `effort`（low/medium/high/xhigh/max）。
  3. **Workflow 的 `agent({effort})`**：唯一能「逐個 stage 設不同 effort」的途徑。
- **Extended thinking** 由主 session 繼承，**不能逐 subagent 設**。

> **來源標註（誠實）**：「Agent 呼叫無 `effort` 參數」與「Workflow `agent({effort})` 可逐 stage 設 effort」= 本 session 從實際工具 schema **直接證實**。上面第 1、2 條（`CLAUDE_CODE_EFFORT_LEVEL` 環境變數、custom subagent frontmatter 的 `effort`）來自 Claude Code 官方文件轉述——**動用前請自行核對當前版本文件**，不要當鐵律。

**給指揮官的實用結論**：日常委派用 Agent 工具、**逐次控 `model`**。若某子任務需要更高 effort：要嘛把整個 session 拉高 effort，要嘛（需要混合 effort 的 fan-out 時）改用 Workflow。**不要假裝能對一次性 Agent 呼叫傳 effort——那個參數不存在。**

---

## §7 🟦 Agent 工具 vs Workflow（Claude Code 專屬）

| 面向 | Agent 工具 | Workflow |
|---|---|---|
| 是什麼 | 開單一 subagent，fresh context | JS script 協調多個 subagent |
| 決策者 | 你，turn by turn | script 邏輯（迴圈 / branching / 條件） |
| 適用 | 單一委派、側任務、少量並行 | 大規模：審 100+ 檔、跨源驗證、批次遷移、loop-until-done |
| effort/model | 逐次可設 model；不可設 effort | 逐 `agent()` 可設 model **與** effort |

**選擇規則**：一次性、少量、你會看結果再決定下一步 → **Agent 工具**。需要確定性控制流（固定的 fan-out / 迴圈 / 每 item 跑同一條 pipeline） → **Workflow**。不確定 → 先用 Agent 工具，證明需要規模化再升 Workflow。

---

## §8 升降級階梯（Escalation / Downgrade Ladder）

明確觸發，弱模型照做即可：

1. **小模型（haiku）產出實質錯誤（邏輯/判斷錯）一次 → 直接升 sonnet 重派**，不要讓 haiku 重試（它這種錯通常是能力不足）。**但純 typo / 路徑手滑**這種一次性小失誤 → 讓它自己修一次；**同一任務手滑第 2 次才升**。
2. **中階（sonnet）在同一子任務錯兩次 → 升 opus，且必帶完整失敗軌跡**（兩次的 prompt、錯誤輸出、試過什麼）。沒帶軌跡就升級＝讓 opus 從零重踩。
3. **解出難題後降級套用**：opus/fable 解出一個難 pattern → 把 pattern 抽成明確步驟，**降回 haiku/sonnet 批量套用**。貴模型解一次，便宜模型套很多次。
4. **硬上限：升到最高可用階仍失敗 → 停下問使用者，不要空轉。** 一輪 = 一次跨階升級（從**實際起始模型**算）：sonnet 起步 → 最多升 opus（1 次）；haiku 起步 → 最多 haiku→sonnet→opus（2 次）。走到最高階（opus，或 operator 授權的 fable）仍過不了，就停下問人（見 [`20-judgment-rubrics.md`](20-judgment-rubrics.md) §3），**不要在同一階反覆重試**。

> 區分「手滑」與「能力不足」：同一個錯誤類別**換了做法還再犯** → 能力/方向問題，升級或換路（見 rubrics §4）；只是 typo、路徑打錯這種一次性小失誤 → 讓它自己修一次，不算升級事件。

---

## §9 快速參考卡（貼在腦子裡）

- 讀 >2 未讀檔 / 掃 repo / 查網頁 / 批次改檔 → **派 subagent**。
- 每次派工 = **目標動機 + 驗收 + 回報格式**。
- subagent 只回**結論 + `file:line`**；長產物**落檔傳路徑**。
- 驗收派**新 context**：檔案 read-back、程式碼實跑、高風險加第二意見。
- 選模型／effort（🟦 Claude Code 專屬；其他 agent 讀各自 adapter，勿照搬）：機械批量 **haiku**、預設 **sonnet**、最難推理 **opus**、max-stakes 且 **operator 授權**才 **fable**；逐次能設 **model**、**不能**設 effort。
- 有 TodoWrite 類工具也要同步 plan checkbox；沒有工具時 checkbox 就是 todo list。排序看正在跑的時鐘，驗證副作用與 env kill switch 影響要揭露。
- 小模型錯一次直接升；中階同任務錯兩次帶軌跡升；**最多 2 輪，之後問人**。
