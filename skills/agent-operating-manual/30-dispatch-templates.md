# E. 派工 Prompt 模板

> 未來主模型直接套用。每份都已內建[派工三件套](10-model-dispatch.md#2-派工三件套每次委派都必含)與[回報合約](10-model-dispatch.md#3-回報合約report-contract)。
> **用法**：複製對應模板 → 填 `[方括號]` → 刪掉不適用的行 → 依 [§5 模型表](10-model-dispatch.md#5--模型選擇表claude-code-專屬)設 `model`。
> 標「repo hook」的部分由採用 repo 的 conventions addenda 補充。

---

## 通用提醒（每份都適用）
- subagent 只回**結論 + `file:line`**；長產物**落檔傳路徑**。
- 驗收條件寫成「看完回報我能做什麼判斷/動作」，不是「做得好」。
- 查不到 / 卡住 → 要它**明說**，不要臆測。

---

## 模板 1 — 搜尋 / 定位（Search / Locate）
**何時**：找東西在哪、跨多檔蒐集事實，**不改任何東西**。
**建議 model**：`haiku`（純廣度掃）或 `sonnet`（需判讀）。**subagent_type: `Explore`**（唯讀）。

```
## 目標與動機
我需要 [找到什麼 / 搞清楚什麼]，因為 [下一步我要拿它做什麼]。你是唯讀偵察，不要改任何檔。

## 任務
- [具體要找的東西 1]
- [具體要找的東西 2]

## 驗收條件
看完回報，我能 [做出什麼判斷 / 動作]。每個宣稱附 path:line。

## 回報格式
Markdown，≤[N] 字，[固定幾節]。只回結論 + path:line，不要貼大段檔案。找不到就明說「找不到 X」。
```
**驗收**：結論若要拿去做不可逆決策 → 派第二個 agent 獨立核對關鍵 `path:line`。

---

## 模板 2 — 實作（Implement）
**何時**：做功能 / 修 bug，跨多個你不想 inline 載入的檔。
**建議 model**：`sonnet`（預設）；邏輯真的難才 `opus`。

```
## 目標與動機
實作 [功能 / 修 bug]，因為 [要滿足什麼行為]。

## 前置與邊界
- 分支：你在 [branch-name]；**每次 commit 前先 `git branch --show-current` 確認是這個**，不是就停下回報。
- 禁止 fetch / reset / checkout / 切分支。
- 先讀 [關鍵檔清單] 再動手；沿用周邊風格，不要重寫無關的東西。

## 驗收條件
- [可測的行為 1]，且有測試覆蓋。
- 跑目標 repo 宣告的 full check 指令（例：`npm run check`）綠。
- `git diff` 沒有無關改動。

## 回報格式
回：改了哪些 `file:line`（清單）+ 測試最後狀態行 + 還沒解的問題。**不要貼整個 diff。**
```
**驗收**：主線或第三個 fresh agent 跑 `npm run check` + **實跑受影響流程**；read-back 關鍵改動。
> 為何釘分支：曾發生 subagent 的 `git commit` 落到 local main。分支必釘、commit 前必驗 HEAD、實作者 prompt 禁 fetch/reset/checkout。

---

## 模板 3 — 重構（Refactor，兩階段：解一次、批量套）
**何時**：行為不變、跨很多處的改動。
**建議**：Phase A 用 `sonnet`/`opus` 在一處確立 recipe；Phase B 用 `haiku` 批量套。

**Phase A（確立 recipe）**
```
## 目標與動機
把 [舊 pattern] 重構成 [新 pattern]，**行為不變**，因為 [為什麼]。

## 任務
只在 [一個代表性檔] 示範改法，產出「改動 recipe」：before/after 片段 + 逐步規則 + 邊界情況。**不要一次改全部。**

## 驗收條件
recipe 明確到「haiku 照著就能套到其他檔」。該檔測試綠。

## 回報格式
回 recipe（≤[N] 字）+ 該檔 `file:line`。
```
**Phase B（批量套用）**
```
## 目標與動機
照下面 recipe 把 [新 pattern] 套到 [檔清單]，行為必須不變。
[貼上 Phase A 的 recipe]

## 邊界
只做 recipe 涵蓋的改動；遇到 recipe 沒講到的情況 → **停下標記那個檔，不要自己發明改法**。

## 驗收條件 / 回報
每檔改完跑測試；回改了哪些 `file:line` + 哪些檔卡住（附原因）。
```
**驗收**：fresh agent 跑全測試 + 抽樣 read-back 幾個檔確認行為不變。

---

## 模板 4 — 研究（Research）
**何時**：需要外部事實 / 套件文件 / 設計選項。
**建議 model**：`sonnet`；Claude/工具問題用 **subagent_type: `claude-code-guide`**；多來源深查用 **deep-research** skill。

```
## 目標與動機
我要決定 [決策]，需要查證 [問題]，因為 [為什麼]。

## 要回答
1. [問題]
2. [問題]

## 誠實要求
每個答案標 `Confidence: verified（附來源 URL/檔案）/ uncertain`。查不到就說查不到，**不要編**。多來源衝突就並陳。

## 回報格式
Markdown ≤[N] 字，一題一節，每節結尾一行 Confidence。
```
**驗收**：高風險決策所依賴的關鍵事實 → 派第二個 agent 用**不同來源**獨立查證。

---

## 模板 5 — 審查（Review，對抗式）
**何時**：驗證一個變更的品質（code 或 docs）。
**建議 model**：`sonnet`（一般）／`opus`（高風險、對抗式驗證）。**一律用 fresh context，絕不用寫的人自己審。**
同捆的 `multi-angle-review` skill（多角度＋反幻覺總審）可搭配。

```
## 目標與動機
對抗式審查 [變更範圍]，因為 [風險 / 為什麼在意]。你沒寫這段，用新眼睛挑毛病，預設「有問題」直到證明沒有。

## 檢查清單（逐條回 yes/no + file:line）
- 正確性：[具體風險點]
- 有錯誤處理、沒 swallow error
- 輸入驗證 / 邊界條件
- 沒硬編 secret、沒殘留 debug log
- 風格與周邊一致
- 測試有覆蓋新行為

## 回報格式
表格：問題 | 嚴重度(CRITICAL/HIGH/MEDIUM/LOW) | file:line | 建議。最後一行總判：**可過 / 有 HIGH / 有 CRITICAL 擋**。不要貼整份 code。
```
**驗收**：CRITICAL/HIGH 修完後，**再派一個 fresh agent 只複驗那幾條**（不要讓修的人自己說修好了）。
