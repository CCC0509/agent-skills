---
name: agent-operating-manual
description: Use at the start of any non-trivial session or task, and whenever deciding whether to delegate vs read inline, which model to launch a subagent with, how to verify a change is truly done, when to escalate a model, or when to stop and ask the user. Externalizes strong-model judgment into executable rules for weaker models — commander-stays-off-the-field delegation, the dispatch triple, model/effort selection, escalation ladder, and verify-not-self-verify. Keywords: delegate, subagent, which model, haiku/sonnet/opus, escalate, is this done, verify, context blowout, when to ask the user.
---

# Agent Operating Manual (trigger shim)

Canonical content lives alongside this file in this skill directory ([README.md](README.md)). This SKILL.md is a thin entry point; read the numbered docs for the full rules.

## Must Read
- [`README.md`](README.md) — 索引 + 新 session 的 5 行快速參考卡。
- [`10-model-dispatch.md`](10-model-dispatch.md) — 核心：指揮官不下場、派工三件套、模型/effort、升降級、驗證不自驗。

## Core rules (the 5-line card)
1. 讀 >2 未讀檔 / 掃 repo / 查網頁 / 批次改檔 → 派 subagent；主線只吃**結論 + `file:line`**。
2. 每次派工 = **目標與動機 + 驗收條件 + 回報格式**。
3. 選模型（🟦 Claude Code 專屬；其他 agent 讀各自 model adapter，勿照搬）：機械批量 `haiku`、預設 `sonnet`、最難推理 `opus`、max-stakes 且 operator 授權才 `fable`。逐次能設 model、**不能**設 effort。
4. **驗證不自驗**：檔案 read-back、程式碼實跑、高風險加第二意見——都派新 context。
5. 小模型錯一次直接升、中階同任務錯兩次帶軌跡升、**最多 2 輪、之後停下問人**；不確定就查、查不到就明說。
