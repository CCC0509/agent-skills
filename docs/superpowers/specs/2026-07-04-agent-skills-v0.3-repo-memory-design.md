# Agent Skills v0.3 Repo Memory Design

Status: Draft
Date: 2026-07-04

## Goal

Ship agent-skills v0.3.0 as a small doctrine-and-install release that gives
adopting repos a shared memory protocol without centralizing memory data or
moving Agent Trigger Kit mechanisms into agent-skills.

The release must make three things explicit:

- Canonical repo memory lives in repo-owned files, not in MCP caches, imported
  skill copies, or ATK outcome stores.
- Different memory files have different lifecycles; "complete and remove" is
  valid for status memory, wrong for lesson history, and wrong for audit logs.
- Cross-agent support is capability-based. Codex and Gemini adapters describe
  what to do when the harness has or lacks subagents, model control, background
  workers, and independent verification sources; they do not copy Claude Code
  model aliases.

## Non-Goals

- Do not create a central memory database, central LESSONS file, or cross-repo
  memory service.
- Do not move ATK outcome collector, store, mark, schema, or gating into
  agent-skills.
- Do not expand ATK outcome schema, add historical backfill, or migrate outcome
  data.
- Do not make codebase-memory-mcp canonical memory. It remains an index and
  tracing accelerator only.
- Do not auto-create an empty `LESSONS.md`. Its path is repo-owned and may
  differ by consumer.
- Do not generate `00-diagnosis.md`, done logs, review logs, or observations.
- Do not add runtime dependencies or a daemon to agent-skills. The install
  contract remains copy markdown plus pointer injection.

## Release Scope

v0.3.0 contains four locked changes.

### 1. Repo Memory Protocol

Add `skills/agent-operating-manual/15-repo-memory.md` and link it from
`README.md` / `SKILL.md` as a first-class manual section.

The protocol defines the memory surfaces an adopting repo may have:

| Memory type | Examples | Lifecycle | Write rule | Delete / compact rule |
|---|---|---|---|---|
| Status memory | `docs/todo.md`, `00-diagnosis.md`, `50-letter-to-future-session.md`, repo runbooks with live state | Update in place when state changes; close when done | Write when future work, current risks, active constraints, or next-session context would otherwise live only in chat | Remove or mark closed when the state is no longer active; keep durable completion elsewhere if needed |
| Lesson memory | `LESSONS.md`, per-repo mistake log | Append-only until it is compacted | Append when a reusable pitfall appears, especially from ATK `events.jsonl`, session-check failures, review findings, or repeated closeout misses | Do not delete just because the immediate task is done; when the same class appears a third time, promote to a rubric, and compact only after the promotion preserves the lesson |
| Audit / trace memory | `review-log.md`, `done-log.md`, `docs/ops-observations/YYYY-MM.md`, release notes | Permanent append | Write when the repo needs evidence of review, deploy, production observation, or completion | Do not remove routine "completed" rows; archive only by an explicit repo convention |
| Index memory | `docs/agent-memory-index.md` | Repo-owned index, updated in place | Write during install if absent; update when repo memory locations change | Never treat index content as generated sentinel-managed content; do not validate prose beyond existence |
| Mechanism evidence | ATK outcome store, CI logs, MCP graph cache, local scratch | Not canonical memory | Consume as input when triaging or reviewing | Do not copy wholesale into doctrine; summarize only the reusable lesson or audit fact |

The protocol extends the v0.2 outcome triage loop rather than replacing it:

1. Session start reads `docs/agent-memory-index.md` when present.
2. If the repo uses ATK, `session-check` / `closeout` evidence and
   `events.jsonl` are objective inputs.
3. Reusable mistakes go to the repo's lesson memory.
4. The third occurrence of a lesson class promotes to a rubric in
   `20-judgment-rubrics.md` or an equivalent repo rule.
5. Audit facts go to repo audit logs, not to `LESSONS.md`.

The new section must explicitly say that a missing `LESSONS.md` can be a valid
baseline state if the index says where the first lesson should be created.

### 2. Agent Memory Index Baseline

`install.sh` creates a starter `docs/agent-memory-index.md` in the target repo
only when the file does not already exist.

The starter index is repo-owned and intentionally not marked with
`.managed-by-agent-skills`. It must contain a line with this exact semantics:

```markdown
- `LESSONS.md`: not created yet; create it at the repo's chosen lesson-memory path when the first reusable lesson appears.
```

An adopting repo may edit that line to a real path, for example:

```markdown
- `docs/agent-operating-manual/LESSONS.md`: reusable lesson memory.
```

The installer also adds a pointer line inside the managed entry marker block:

```markdown
Repo memory index: [docs/agent-memory-index.md](docs/agent-memory-index.md).
```

The pointer can live inside the managed block because the path is fixed and
generic. The index content itself stays outside sentinel management.

Installer guardrails:

- Never overwrite an existing `docs/agent-memory-index.md`.
- Do not create `LESSONS.md`.
- Do not fail just because the index points at a not-yet-created lesson file.
- Keep `--dest`, `--skills`, and `--create-entry` behavior unchanged.
- Keep default skills unchanged: `agent-operating-manual,multi-angle-review`.
- `skill-authoring` remains optional and not installed by default.

### 3. MCP Graph-First Doctrine

Add graph-first tracing doctrine to the manual and multi-angle-review, while
keeping MCP as non-canonical memory.

The doctrine defines three states:

| State | Meaning | Required behavior |
|---|---|---|
| `available_indexed` | MCP tool can start and reports a usable index | Prefer graph tools for exported symbols, call paths, architecture lookups, and cross-file tracing |
| `available_unindexed_or_stale` | MCP tool starts but graph is missing or stale | Use graph only for safe discovery if useful; otherwise run `rg`; disclose the stale / unindexed gap in review or final |
| `unavailable` | Tool is absent, cannot spawn, or errors such as `Transport closed` | Fall back to `rg` / local file reads; disclose the fallback when the task depends on cross-file tracing |

Hard boundary:

- Do not treat MCP graph contents as source of truth for repo memory.
- Do not write graph persistence artifacts into the repo.
- Do not "fix" portable repo MCP config by changing bare commands to absolute
  user paths. PATH fixes belong in user / machine configuration, not shared repo
  config.

### 4. Codex / Gemini Model Adapters

Add adapter docs under `skills/agent-operating-manual/` so copy-install
consumers receive them:

- `codex-model-adapter.md`
- `gemini-model-adapter.md`

The existing Claude Code model / effort / workflow sections stay fenced as
Claude-specific. The adapters translate the core dispatch doctrine into
capability predicates:

| Capability | If present | If absent |
|---|---|---|
| Fresh subagent / worker contexts | Delegate exploration, review, and read-back to fresh workers | Keep task smaller; use CI, local commands, or a later human / agent review for independent verification |
| Per-worker model control | Use cheaper models for mechanical work and stronger models for ambiguous review, following local harness names | Do not invent aliases; describe the needed capability and rely on the current session / external review |
| Background or parallel workers | Fan out independent finder angles or repo scans | Run sequentially and write intermediate notes before synthesis |
| Tool-backed verification | Treat tests, linters, validators, and GitHub checks as primary verification | State the verification gap; do not claim pass from reasoning alone |

Adapter docs must not claim exact model names, prices, or feature availability
that can drift. They should say how to map the doctrine onto the harness the
agent actually has in the current session.

## File Plan

### New files

- `docs/superpowers/specs/2026-07-04-agent-skills-v0.3-repo-memory-design.md`
  - This design.
- `skills/agent-operating-manual/15-repo-memory.md`
  - Canonical repo-memory protocol and lifecycle table.
- `skills/agent-operating-manual/codex-model-adapter.md`
  - Codex capability-based model / verification adapter.
- `skills/agent-operating-manual/gemini-model-adapter.md`
  - Gemini capability-based model / verification adapter.

### Modified files

- `install.sh`
  - Create starter `docs/agent-memory-index.md` only if absent.
  - Add the managed-block pointer line.
- `tests/install-smoke.sh`
  - Add v0.3 smoke coverage.
- `skills/agent-operating-manual/README.md`
  - Add `15-repo-memory.md` to the map and quick memory guidance.
- `skills/agent-operating-manual/SKILL.md`
  - Link the repo-memory section and adapter docs as needed.
- `skills/agent-operating-manual/10-model-dispatch.md`
  - Point non-Claude agents to adapter docs without copying Claude aliases.
- `skills/agent-operating-manual/40-maintenance.md`
  - Align adoption guidance with the index baseline and memory lifecycles.
- `skills/multi-angle-review/SKILL.md`
  - Make graph-first / fallback disclosure explicit.
- `README.md`
  - Document the new index baseline, optional skill status, and v0.3 install behavior.
- `ROADMAP.md`
  - Mark v0.3 landed items and leave ATK-template items deferred.
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
  - Bump to `0.3.0` only in the implementation PR, together with the release
    tag.

## Install Contract

The v0.3 install result for a default consumer should be:

- `docs/imported-skills/agent-operating-manual/**`
- `docs/imported-skills/multi-angle-review/**`
- `.agent-skills/pin`
- Entry marker block in each existing or created `CLAUDE.md`, `AGENTS.md`,
  and `GEMINI.md`
- `docs/agent-memory-index.md` only if absent

The index file is not a managed imported skill. It is repo-local memory
infrastructure, so consumer edits are expected.

## Smoke Requirements

`tests/install-smoke.sh` must cover:

1. Fresh install creates `docs/agent-memory-index.md`.
2. Fresh install injects the memory pointer inside the managed marker block.
3. Re-running install is idempotent.
4. Existing index content is not overwritten.
5. Existing v0.2-style consumer marker block is replaced, not appended, and the
   new pointer appears through the marker-replace path.
6. `--create-entry AGENTS.md` creates a new entry file containing the pointer.
7. Explicit `--skills agent-operating-manual,multi-angle-review,skill-authoring`
   still adds the skill-authoring pointer and does not change the default set.
8. A starter index with a not-yet-created `LESSONS.md` pointer is valid and does
   not require creating that file.

Validation for implementation:

- `bash tests/install-smoke.sh`
- `shellcheck install.sh tests/install-smoke.sh` when available
- `claude plugin validate .` or the repo's existing plugin validation command
  when available
- `git diff --check`
- `quick_validate.py` for changed skills when the validator is available

## Error Handling

- If the target already has an unmanaged imported skill directory, keep the
  existing `destination_exists_unmanaged` failure.
- If the index path exists, leave it untouched and continue.
- If marker blocks are mismatched, keep the existing fail-loud behavior.
- If the source checkout is dirty or untagged without `--dev`, keep the existing
  source gate.
- If a consumer has no entry files and does not request `--create-entry`, install
  still succeeds and reports skipped entries, as v0.2 does.

## Compatibility

The release is backwards-compatible for v0.2 consumers:

- Existing managed skill copies are replaced as before.
- Existing entry marker blocks are replaced in place.
- Existing repo-owned memory files are not overwritten.
- No consumer runtime dependency is introduced.
- The default skill list remains unchanged.

The only new repo-local file is `docs/agent-memory-index.md`, and only when it
does not already exist.

## Open Decisions

None. User decisions already pinned:

- Create index only; do not auto-create empty `LESSONS.md`.
- Put the memory pointer inside the managed block.
- Add lifecycle semantics for status, lesson, and audit memory.
- Put Codex / Gemini adapter docs inside `skills/agent-operating-manual/`.
- Include upgrade-path smoke for v0.2 marker replacement and `--create-entry`.

## Spec Self-Review

- Placeholder scan: no unresolved placeholder markers.
- Scope check: one release-sized spec; implementation can be one PR if kept to
  doctrine, installer, and smoke coverage.
- Boundary check: no central memory DB, no ATK runtime changes, no schema
  expansion, no data migration.
- Ambiguity check: missing `LESSONS.md` is explicitly valid when the index says
  where to create the first lesson.
