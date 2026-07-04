# Agent Operating Manual

**這是什麼**：一套給「較弱模型 session」用的操作制度——把強模型的判斷力外化成弱模型可執行的規則。目的是讓每一個之後的 session（Sonnet / Haiku 等）都更可靠、更省 token、更不容易假性完成。

**讀者**：把某個 model 當「指揮官」跑這個 repo 的任何 session。
**由來**：2026-07-03，本環境當時最強模型（harness 標示 Opus 4.8, 1M）建立；2026-07-03 抽出至獨立 repo（CCC0509/agent-skills）。

---

## 新 session 先讀（快速參考卡）

1. 讀 >2 未讀檔（**探索性、得邊讀邊找**）/ 掃 repo / 查網頁 / 批次改檔 → **派 subagent**，主線只吃**結論 + `file:line`**。
2. 每次派工 = **目標與動機 + 驗收條件 + 回報格式**（缺一不可）。
3. **選模型（🟦 此條 Claude Code 專屬；Codex/Gemini 讀各自 model adapter，勿照搬）**：機械批量 `haiku`、預設 `sonnet`、最難推理 `opus`、max-stakes 且 **operator 授權**才 `fable`。逐次能設 **model**、**不能**設 effort。
4. **驗證不自驗**：檔案 read-back、程式碼實跑、高風險加第二意見——都派**新 context**。
5. 小模型錯一次直接升、中階同任務錯兩次帶軌跡升、**最多 2 輪，之後停下問人**；不確定就查，查不到就明說。
6. 有 TodoWrite 類工具也要同步 plan checkbox；沒有工具時 checkbox 就是 todo list。排序看正在跑的時鐘，驗證副作用與 env kill switch 影響要揭露。
7. Repo memory 先讀 `docs/agent-memory-index.md`；狀態記憶可關閉，教訓記憶 append-only 到第 3 次升 rubric，audit 記憶永久 append。

---

## 檔案地圖（依編號閱讀順序）

| 檔 | 內容 | 何時讀 |
|---|---|---|
| [`10-model-dispatch.md`](10-model-dispatch.md) | **C** 指揮官不下場、派工三件套、模型/effort、升降級、驗證不自驗 | **每個 session 的核心；不熟就從這開始** |
| [`15-repo-memory.md`](15-repo-memory.md) | **B** repo-owned shared memory：index、status / lesson / audit lifecycle、ATK / MCP boundaries | Session start、closeout、或要寫 repo memory 時 |
| [`20-judgment-rubrics.md`](20-judgment-rubrics.md) | **D** 何時升級/算完成/停下問人/該換路/驗品質（各附正反例） | 卡在判斷時查對應 § |
| [`30-dispatch-templates.md`](30-dispatch-templates.md) | **E** 搜尋/實作/重構/研究/審查 派工填空模板 | 要委派時複製套用 |
| [`40-maintenance.md`](40-maintenance.md) | **F** 怎麼安全更新這套 + 如何 skill 化給所有 agent/repo | 要改這套、或要發佈成 skill 時 |
| [`codex-model-adapter.md`](codex-model-adapter.md) | Codex capability adapter for model / worker / verification doctrine | Codex sessions reading 🟦 Claude Code sections |
| [`gemini-model-adapter.md`](gemini-model-adapter.md) | Gemini capability adapter for model / worker / verification doctrine | Gemini sessions reading 🟦 Claude Code sections |

per-repo 檔（00-diagnosis / LESSONS / 50-letter）由採用 repo 自建，指引見 40-maintenance.md §6。

## Outcome triage loop

若採用 repo 使用 Agent Trigger Kit，`session-check` / `closeout` 看到新的
failure category、unmarked outcome，或 outcome store 的 `events.jsonl` 證據時：

1. 先處理當輪 gating：mark outcome、修正觸發層或明確列出 blocked 原因。
2. 把可重用的踩坑追加到該 repo 在 `docs/agent-memory-index.md` 指定的 lesson
   memory（常見檔名是 `LESSONS.md`），保留 append-only 脈絡。
3. 同一類 lesson 第 3 次出現時，把它升級成 `20-judgment-rubrics.md` 的正式
   rubric 或採用 repo 的同等規則。

資料流固定是：ATK `events.jsonl` / session-check summary → repo-local lesson
memory → 第 3 次同類 → rubric。ATK 只提供客觀收集器；agent-skills 只提供消化
doctrine；repo 自己保留記憶資料。

---

## 誠實：這套補得了什麼、補不了什麼

- **補得了**：執行品質。靠拆解 + 委派 + 驗證 + 多樣本評審，弱模型的**執行**可以逼近很高的可靠度。
- **補不了**：品味與模糊的產品/設計取捨。這種題目**沒有機器判準**。遇到時的正解是「給選項讓使用者選 / 升到最強模型要第二意見 / 明說做不到」——**不是硬撐一個假答案**。細節見 [`20-judgment-rubrics.md`](20-judgment-rubrics.md) §6。

## 可攜性與 interop

- 本 skill 為 framework-agnostic：不假設 superpowers 等 process framework 存在。
- **SDD（superpowers 等 process framework）管 lifecycle**（brainstorm → spec →
  plan → 執行 → review → merge）；**本 manual 管 dispatch economy**（誰下場、
  派哪個模型、怎麼驗證、何時升級/停下）。兩者正交、互補。
- 有 superpowers 的 repo：同捆的 `multi-angle-review` 可直接作為
  requesting-code-review checkpoint 的 reviewer 方法論。
- 優先序沿用 harness 自身宣告（user instructions / CLAUDE.md > skills >
  default），本 skill 不另立優先序規則。
- 🟦 標記段落為 Claude Code 專屬；其他 agent 讀各自 model adapter，勿照搬。
- 採用到新 repo：見 [`40-maintenance.md`](40-maintenance.md) §6。
