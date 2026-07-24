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

## Recommended lesson-memory entry template

Lesson memory has no fixed schema, but this structured shape (borrow-adapt,
rebelytics/one-skill-to-rule-them-all `task-observer`'s Observation-log
format) is a low-risk default when a repo has not already chosen one:

```text
### <date> -- <one-line title>
Issue: <what pitfall or gap was observed>
Suggested improvement: <the concrete change that would prevent recurrence>
Principle: <the reusable rule this generalizes to>
Status: OPEN <date> | ACTIONED <date> | DECLINED <date>
```

This is a template, not a mechanism: no automation, numbering, or collision
handling is implied. Repos may keep an existing lesson-memory format
instead; this is a recommended default, not a requirement.

### REFERENCE (inactive; automation-gated) -- log-write safety pattern

This block is a labeled reference, not an active rule. It applies only if
memory writes ever become concurrent or multi-agent; today's single-writer
invariant already prevents the collision this pattern guards against.

Borrow-adapt from rebelytics/one-skill-to-rule-them-all `task-observer`'s
Observation-log mechanics: bounded-entry mutation, a pre-write assertion
that the target slot is free, a post-write structural-invariant count
check, and a survival re-check after write. If multi-writer memory work is
ever scoped, adapt this pattern instead of reinventing it; do not
implement it now.

### REFERENCE (inactive; concept only) -- periodic review over accumulated backlog

This block is a labeled reference, not an active rule; it records a
pattern, not an obligation. Borrow-adapt from
rebelytics/one-skill-to-rule-them-all `task-observer`'s README and Session
Start Protocol: pairing continuous per-session observation with a
periodic (its default: weekly) review pass over the accumulated backlog,
so pitfalls surface even when no single session triggers a promotion on
its own. If a repo later adopts a periodic review cadence over its own
lesson/audit backlog, this is a concrete instance to adapt rather than
reinvent. No automation, schedule, or self-triggering is implied or
adopted here.

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
7. At closeout, use `Closeout self-report and memory routing` below to decide
   whether closing facts belong in status, lesson, audit, index, mechanism
   evidence, or no repo memory update.

## Closeout self-report and memory routing

At closeout, read `docs/agent-memory-index.md` when present, then classify each
closing fact by destination. This subsection adds the closeout-time decision
procedure; the memory lifecycle table above remains the canonical taxonomy.

| Destination | Use when | Do not use for |
|---|---|---|
| Status memory | Future agents need active state, next actions, blockers, current risks, or a compact next-session seed. | Permanent proof that work happened. |
| Lesson memory | A reusable pitfall, repeated correction, review finding pattern, or ATK closeout signal should teach future agents. | One-off task facts or ordinary completion notes. |
| Audit memory | The repo needs durable evidence of review, verification, deploy, smoke, production observation, release, or completion. | Active worklists or conversational context. |
| Index memory | Memory locations changed, or the first concrete lesson, status, or audit path is chosen. | Routine task notes. |
| Mechanism evidence | ATK outcome stores, CI logs, MCP caches, command output, or scratch artifacts inform the closeout. | Canonical storage; summarize reusable facts into repo memory instead. |

Run this compact self-report mentally before final response or relay:

```text
Memory closeout:
- Status memory update: <none | path + one-line reason>
- Lesson memory update: <none | path + lesson class>
- Audit memory update: <none | path + evidence type>
- Index memory update: <none | path + location change>
- Mechanism evidence consumed: <none | source labels only>
- Next-session seed: <none | status-memory path>
```

The `Next-session seed` line is a status-memory subset. When a seed is written,
the same path may appear in both `Status memory update` and
`Next-session seed`; do not invent a separate seed file just to make the lines
differ.

This shape is a self-report discipline, not a new relay block and not a
required final-output field for every task. For ordinary small tasks where no
repo memory changes are warranted, keep it internal unless the user requested a
memory closeout report or the absence of memory updates is important to avoid
ambiguity.

When repo memory files are updated, the diff or commit is the self-evidencing
artifact. The final response does not need to print the self-report shape
unless the user requested it or the handoff is a relay.

When a task emits the Agent Operating Manual relay block, put any memory facts
needed by the next agent in the forwarded context or in `Accepted residuals:`
when they are non-blocking residuals. The memory self-report does not override
`Status:`, `User action:`, `Blockers:`, or `Accepted residuals:`.

Closeout routing rules:

1. Read `docs/agent-memory-index.md` when present before deciding paths.
2. Route facts to existing memory types only. Do not create new peer types.
3. Prefer status memory for active state a near-future session needs to act
   safely.
4. Prefer audit memory for durable proof: review, verification, deploy, smoke,
   production observation, release, or completion evidence.
5. Prefer lesson memory only when the fact is reusable across future work.
6. Update index memory only when memory locations change or the repo chooses a
   concrete path that was previously absent.
7. Treat mechanism evidence as input. Do not paste raw logs, outcome stores, or
   cache data into portable doctrine.
8. If closeout says no memory update is needed, that means no future agent
   needs active state, no reusable lesson appeared, and durable evidence is
   unnecessary or already recorded by repo convention.

### Obsidian-compatible markdown

Repo-owned memory should stay portable markdown that tools such as Obsidian can
open and connect. Use normal relative markdown links for repo files. Do not
require `[[wikilinks]]`, Dataview queries, YAML frontmatter, tags, or Obsidian
plugins in canonical repo memory.

A personal or cross-project vault may mirror or index repo memory, but it is an
accelerator. Decision-grade facts flow from repo memory to the vault, not from
the vault back into canonical memory unless an agent explicitly writes the
corresponding repo-owned file through normal repo governance.

## Boundaries

- Do not centralize repo memory into agent-skills.
- Do not move ATK outcome stores into agent-skills.
- Do not use MCP caches as canonical memory.
- Do not write graph persistence artifacts into the repo.
- Do not auto-create `LESSONS.md` from install.sh.

## MCP graph state

| State | Meaning | Behavior |
|---|---|---|
| `available_indexed` | Graph tool starts and reports a usable index | Prefer graph tools for exported symbols, call paths, architecture lookups, and cross-file tracing |
| `available_unindexed_or_stale` | Tool starts but the graph is missing or stale | Use graph only for safe discovery if useful; otherwise use `rg`; disclose the gap |
| `unavailable` | Tool is absent, cannot spawn, or returns errors such as `Transport closed` | Fall back to `rg` / local file reads; disclose the fallback when cross-file tracing matters |

Do not change shared repo MCP config from portable bare commands to absolute
machine paths. PATH fixes belong in user or machine configuration.
