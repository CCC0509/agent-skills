# F. 維護協議（Maintenance Protocol）

> 給未來較弱模型：**怎麼安全地更新這套 manual**，以及**怎麼把它 skill 化給所有 agent / repo**。

---

## §1 你可以自己改、不用先問

- **在 repo lesson memory 追加一條教訓**（append-only，只加不改舊的；路徑以 `docs/agent-memory-index.md` 為準）。
- 修**明顯的 typo / 壞連結 / 錯路徑**（改前先驗證正確值：`ls` / `grep` 確認再改）。
- 在既有 rubric（D）**補一個正例或反例**，只要**不改動規則本身的意思**。
- 更新檔尾的 `last reviewed` 日期。

## §2 動之前必須先問使用者

- 改**規則的意思或門檻**（例：把「>2 檔」改成「>5 檔」、動升降級階梯的階數）。
- **刪**一條規則或整節。
- 改**模型選擇預設**（哪個 model 當 default worker）。
- **重構 / 改名 / 搬移**檔案。
- 動到 **CLAUDE.md 路由**、或 **plugins/** 註冊、或要跑 **validate gate**。
- 把 manual **接進別的 agent 入口**（AGENTS.md / GEMINI.md / `.cursor`）。

> 判準：**加東西、修錯字、補例子 = 自己來；改語意、刪、搬、接線 = 先問。**

## §3 踩坑 → 教訓：寫回哪、什麼格式

每次踩坑後，在 `docs/agent-memory-index.md` 指定的 lesson memory（常見檔名是
`LESSONS.md`）追加一條，用這個格式：

```
## YYYY-MM-DD — <一句話標題>
- **當時在做**: <什麼任務>
- **症狀**: <觀察到什麼壞掉>
- **root cause**: <真正原因，不是表面>
- **規則變更**: <none | 改了哪條 rubric/§ | 新增哪個判準>
- **例子**: <一個具體正/反例，讓未來模型認得出這情境>
```

**同一類坑出現第 3 次** → 它不該只待在 log 裡，要**升級成 D 的正式 rubric**（見 §4 精簡）。

若採用 repo 同時使用 Agent Trigger Kit，優先把 `session-check` / `closeout`
裡的新 failure category、unmarked outcome、或 `events.jsonl` 事件當成客觀輸入：

1. 先完成當輪 outcome mark / gating closeout。
2. 將可重用教訓追加到 repo-local lesson memory（以
   `docs/agent-memory-index.md` 指定的路徑為準）。
3. 同類第 3 次出現時，再升級到 `20-judgment-rubrics.md` 或該 repo 的同等
   rubric。

不要把 outcome store 搬進 agent-skills；收集器留在 ATK，消化 doctrine 留在
本 manual，記憶資料永遠留在各 repo。

## §4 累積多長要精簡（防止 manual 變成它要修的問題）

**觸發**：repo lesson memory 超過 **30 條** 或 **~400 行**。
**動作**（派一個 `sonnet` subagent 做）：
1. 合併重複的教訓。
2. **把出現 ≥3 次的教訓，提升成 D 的正式 rubric**（附正反例）。
3. 依 repo 慣例歸檔原始 log，讓 active lesson memory 保持精簡。

**長度上限**：每個 doctrine 檔控制在 **~250 行內**；超過就拆。
**核心自省**：整套 manual（常載指標 + 被讀到的內容）**絕不能大到反過來變成 `00-diagnosis.md` Leak 2 那種負擔**。若它省下的 token < 它自己吃掉的，就是該精簡的訊號。

## §5 改動前的備份

- **不要為了備份而把 WIP commit 到當前分支（尤其 `main`）。** 備份用 **branch / worktree**，或複製一份到 **repo 外 scratch**（如 scratchpad）。
- **commit 一律走該 repo 的對應 gate**，不要拿「備份」當藉口繞過 review：
  - repo hook：變更治理依採用 repo 的規則（例：behavior-impact file-set 走 branch → PR → explicit review；docs-only 走該 repo 的 docs closeout）。
- 做**跨多檔重構**時，先開 branch/worktree，或額外複製到 `backups/<name>.<YYYY-MM-DD>.bak` 再動。
- 若某檔**不在 git**（少見）→ 動前複製到 scratch。

---

## §6 採用與發佈

### 採用到新 repo
1. 從 agent-skills 的 exact tag checkout 跑 `./install.sh <target-repo>`（詳見
   repo README）；產出 `docs/imported-skills/**`、`.agent-skills/pin`、
   入口指標區塊。
2. Review `docs/agent-memory-index.md` and choose repo-owned paths for status,
   lesson, and audit memory. A missing `LESSONS.md` is valid until the first
   reusable lesson appears, if the index says where to create it. Memory data is
   always per-repo; do not move it into agent-skills.
3. 把 `docs/imported-skills/**` 與 `.agent-skills/**` 納入該 repo 的變更治理
   （例：behavior-impact file-set），避免升級被當一般 docs 繞過 review。
4. 升級：agent-skills checkout 到新 tag → 重跑 install.sh；不手改 imported
   檔案。

### 發佈紀律（agent-skills maintainer）
1. doctrine 變更走 PR；release 時同步 bump `.claude-plugin/plugin.json` 與
   `.claude-plugin/marketplace.json` 的 version，打同號 tag `vX.Y.Z`。
2. `install.sh` source gate 與 `tests/install-smoke.sh` 都驗 tag == manifest
   version，不符 fail loud。
3. 🟦（Claude Code 專屬）段落維持圍欄；新 harness 變體另立檔案，不混寫。

---

*last reviewed: 2026-07-03*
