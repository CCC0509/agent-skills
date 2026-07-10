# agent-skills

可攜 agent doctrine skills，供多 repo / 多 agent（Claude Code、Codex、Gemini CLI）共用：

| Skill | 用途 |
|---|---|
| [`skills/agent-operating-manual/`](skills/agent-operating-manual/SKILL.md) | dispatch economy：誰下場、派哪個模型、怎麼驗證、何時升級/停下 |
| [`skills/handoff-relay/`](skills/handoff-relay/SKILL.md) | handoff / relay / exact approval trigger surface：交接、review、核准文字、copy block |
| [`skills/multi-angle-review/`](skills/multi-angle-review/SKILL.md) | read-only review pipeline：finder angles → 反幻覺 verify → 獨立 re-verify |
| [`skills/work-discipline/`](skills/work-discipline/SKILL.md) | optional work discipline：假設、scope、surgical diff、verification success criteria |
| [`skills/skill-authoring/`](skills/skill-authoring/SKILL.md) | optional authoring doctrine：撰寫、萃取、發佈可攜 skills / plugin-facing doctrine |

## 安裝（主路徑：複製 + 指標注入）

從 clean checkout、HEAD 在 exact tag 上執行：

    ./install.sh <target-repo-path>

產出：`<target>/docs/imported-skills/<skill>/`、`<target>/.agent-skills/pin`
（單行 `CCC0509/agent-skills@vX.Y.Z`），並向存在的 `CLAUDE.md` / `AGENTS.md` /
`GEMINI.md` 注入 `<!-- agent-skills:begin/end -->` 指標區塊（重跑冪等 = 升級）。
`docs/agent-memory-index.md` is created once if absent. It is repo-owned and not
overwritten by later installs.
`<!-- agent-skills:begin -->` / `<!-- agent-skills:end -->` sentinel lines are a
frozen compatibility boundary. Do not rename them; upgrades replace only the
managed block between those markers.
`--dev` 只放寬 exact-tag（dirty 一律 fail loud），pin 記 `dev-<shortsha>`。
其他 flags：`--dest <dir>`、`--skills a,b`、`--create-entry <file>`。

Companion boundary: agent-skills is the portable doctrine half. Mechanisms such
as trigger validators, hook templates, and outcome collectors belong in their
own tooling repos; adopting repos connect the two in local playbooks.

Default install 只包含 `agent-operating-manual,handoff-relay,multi-angle-review`。
`work-discipline` 是一般修改前的 optional scope / simplicity / verification
trigger；`skill-authoring` 是 maintainer / extraction 用 optional skill，需要時明確指定：

    ./install.sh <target-repo-path> --skills agent-operating-manual,handoff-relay,multi-angle-review,work-discipline,skill-authoring

## Claude Code plugin（選配）

    claude plugin marketplace add CCC0509/agent-skills --scope project
    claude plugin install agent-skills@ccc-agent-skills --scope project

## 採用 checklist（新 repo）

1. install.sh（如上）。
2. Review `docs/agent-memory-index.md`; choose repo-owned status / lesson /
   audit memory paths. `LESSONS.md` does not need to exist until the first
   reusable lesson appears.
3. Optional：在支援的環境安裝 superpowers 取得 SDD lifecycle；agent-skills
   本身仍保持 framework-agnostic。
4. 把 `docs/imported-skills/**` 與 `.agent-skills/**` 納入該 repo 變更治理。
5. 升級：checkout 新 tag → 重跑 install.sh；不手改 imported 檔案。

## 版本

git tag `vX.Y.Z` 是唯一版本來源；`.claude-plugin/*.json` version 必須同號
（install.sh source gate 與 `tests/install-smoke.sh` 兩處把關）。
Release tag / publish lifecycle discipline stays approval-bound: metadata bump,
annotated tag creation, tag push, publish inventory, and post-tag /
post-publish smoke follow
`skills/agent-operating-manual/25-change-discipline.md` §3.2.
