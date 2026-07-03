# agent-skills

可攜 agent doctrine skills，供多 repo / 多 agent（Claude Code、Codex、Gemini CLI）共用：

| Skill | 用途 |
|---|---|
| [`skills/agent-operating-manual/`](skills/agent-operating-manual/SKILL.md) | dispatch economy：誰下場、派哪個模型、怎麼驗證、何時升級/停下 |
| [`skills/multi-angle-review/`](skills/multi-angle-review/SKILL.md) | read-only review pipeline：finder angles → 反幻覺 verify → 獨立 re-verify |

## 安裝（主路徑：複製 + 指標注入）

從 clean checkout、HEAD 在 exact tag 上執行：

    ./install.sh <target-repo-path>

產出：`<target>/docs/imported-skills/<skill>/`、`<target>/.agent-skills/pin`
（單行 `CCC0509/agent-skills@vX.Y.Z`），並向存在的 `CLAUDE.md` / `AGENTS.md` /
`GEMINI.md` 注入 `<!-- agent-skills:begin/end -->` 指標區塊（重跑冪等 = 升級）。
`--dev` 只放寬 exact-tag（dirty 一律 fail loud），pin 記 `dev-<shortsha>`。
其他 flags：`--dest <dir>`、`--skills a,b`、`--create-entry <file>`。

## Claude Code plugin（選配）

    claude plugin marketplace add CCC0509/agent-skills --scope project
    claude plugin install agent-skills@agent-skills --scope project

## 採用 checklist（新 repo）

1. install.sh（如上）。
2. 自建 per-repo `00-diagnosis.md` / `LESSONS.md`（永遠 per-repo，不搬）。
3. 把 `docs/imported-skills/**` 與 `.agent-skills/**` 納入該 repo 變更治理。
4. 升級：checkout 新 tag → 重跑 install.sh；不手改 imported 檔案。

## 版本

git tag `vX.Y.Z` 是唯一版本來源；`.claude-plugin/*.json` version 必須同號
（install.sh source gate 與 `tests/install-smoke.sh` 兩處把關）。
