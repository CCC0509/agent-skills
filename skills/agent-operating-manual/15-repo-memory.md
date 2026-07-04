# B. Repo Memory Protocol

## One-line rule

Canonical memory is repo-owned. agent-skills provides doctrine, ATK provides
objective mechanism evidence, MCP provides indexes, and the repo owns the files
that future agents must read and update.

## Memory lifecycle table

| Memory type | Examples | Lifecycle | Write when | Delete / compact when |
|---|---|---|---|---|
| Status memory | `docs/todo.md`, `00-diagnosis.md`, `50-letter-to-future-session.md` | Update in place; close when done | A future agent needs current state, risk, next step, or active constraint | Remove or mark closed when no longer active; keep durable completion in audit memory if needed |
| Lesson memory | `LESSONS.md` or repo-chosen lesson log | Append-only until promoted / compacted | A reusable pitfall appears from ATK outcome evidence, review findings, closeout misses, or repeated operator correction | Do not delete because the task is done; third same-class lesson promotes to rubric, then compact only after preserving the lesson |
| Audit memory | `review-log.md`, `done-log.md`, `docs/ops-observations/YYYY-MM.md`, release notes | Permanent append | The repo needs review, deploy, smoke, observation, or completion evidence | Archive only by explicit repo convention; do not remove routine completed rows |
| Index memory | `docs/agent-memory-index.md` | Repo-owned index, updated in place | Memory locations change, or the first lesson path is chosen | Never treat as managed generated content; validators may check existence, not prose |
| Mechanism evidence | ATK outcome store, CI logs, MCP graph cache, local scratch | Not canonical memory | It helps diagnose, triage, or review | Summarize reusable lessons or audit facts into repo-owned files; do not copy wholesale |

## Session protocol

1. Read `docs/agent-memory-index.md` when present.
2. If a listed lesson file does not exist yet, treat that as valid when the
   index says it will be created at first lesson.
3. For ATK repos, use `session-check`, `closeout`, and `events.jsonl` as
   objective input.
4. Append reusable pitfalls to lesson memory.
5. Promote the third same-class lesson to `20-judgment-rubrics.md` or a
   repo-equivalent rule.
6. Write review, deploy, smoke, and observation facts to audit memory.

## Boundaries

- Do not centralize repo memory into agent-skills.
- Do not move ATK outcome stores into agent-skills.
- Do not use MCP caches as canonical memory.
- Do not auto-create `LESSONS.md` from install.sh.
