# Agent Skills v0.3 Repo Memory Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement v0.3.0 repo-memory doctrine, memory-index install baseline, MCP graph-first fallback doctrine, and Codex/Gemini model adapters without adding runtime state or moving ATK mechanisms.

**Architecture:** Keep agent-skills markdown-copy based. `install.sh` creates one repo-owned memory index file if absent and injects one generic pointer line into managed entry blocks; doctrine lives inside `skills/agent-operating-manual/` and `skills/multi-angle-review/`. Tests stay shell-smoke based and prove default installs, upgrades, no-overwrite behavior, custom `--dest`, `--create-entry`, and optional `skill-authoring`.

**Tech Stack:** Bash installer and smoke tests, markdown skills, Claude plugin JSON manifests, git tag source gate.

---

## Source Contract

Implement against the approved spec:

- `docs/superpowers/specs/2026-07-04-agent-skills-v0.3-repo-memory-design.md`

Do not implement the deferred doctrine rows in this release:

- Preflight / closeout self-report contract
- Plan / PR lifecycle discipline

Keep them deferred in `ROADMAP.md` as v0.3.1+ candidates.

## File Structure

- `install.sh`
  - Owns deterministic file copy, pin write, memory-index creation, and entry pointer injection.
- `tests/install-smoke.sh`
  - Owns all installer behavior contracts. Add tests before implementation.
- `skills/agent-operating-manual/15-repo-memory.md`
  - New canonical repo-memory protocol and lifecycle table.
- `skills/agent-operating-manual/codex-model-adapter.md`
  - New capability-based Codex adapter.
- `skills/agent-operating-manual/gemini-model-adapter.md`
  - New capability-based Gemini adapter.
- `skills/agent-operating-manual/README.md`
  - Manual map and quick-card entry for memory.
- `skills/agent-operating-manual/SKILL.md`
  - Trigger shim quick-reference memory entry and links.
- `skills/agent-operating-manual/10-model-dispatch.md`
  - Points non-Claude agents to adapter docs.
- `skills/agent-operating-manual/40-maintenance.md`
  - Adoption / maintenance protocol alignment.
- `skills/multi-angle-review/SKILL.md`
  - Graph-first tracing and fallback disclosure.
- `README.md`
  - User-facing install behavior.
- `ROADMAP.md`
  - Landed vs deferred rows.
- `.claude-plugin/plugin.json`
  - Version bump to `0.3.0`.
- `.claude-plugin/marketplace.json`
  - Version bump to `0.3.0`.

## Task 1: Installer Contract Tests First

**Files:**
- Modify: `tests/install-smoke.sh`
- Later modify: `install.sh`

- [ ] **Step 1: Add fresh-install memory-index assertions**

In scenario `# 1) tagged install`, immediately after the pin assertion, add:

```bash
[ -f "$TMP/target/docs/agent-memory-index.md" ] || fail "missing agent-memory-index.md"
grep -Fq '# Agent Memory Index' "$TMP/target/docs/agent-memory-index.md" \
  || fail "agent-memory-index missing heading"
grep -Fq '`LESSONS.md`: not created yet; create it at the repo' \
  "$TMP/target/docs/agent-memory-index.md" \
  || fail "agent-memory-index missing not-yet-created LESSONS line"
[ ! -e "$TMP/target/LESSONS.md" ] || fail "LESSONS.md auto-created"
```

Inside the same scenario's `for f in CLAUDE.md AGENTS.md GEMINI.md; do` loop,
add:

```bash
  grep -Fq 'docs/agent-memory-index.md' "$TMP/target/$f" \
    || fail "$f missing repo memory index pointer"
```

- [ ] **Step 2: Run smoke and verify the new test fails**

Run:

```bash
bash tests/install-smoke.sh
```

Expected: FAIL with `SMOKE FAIL: missing agent-memory-index.md` or missing
memory pointer. This proves the test is live.

- [ ] **Step 3: Add upgrade-path, custom-dest, and no-overwrite smoke contracts**

Append this scenario after idempotency and before dirty-source checks:

```bash
# 3) v0.2-style managed block is replaced in place and gains memory pointer
mktarget
for f in CLAUDE.md AGENTS.md GEMINI.md; do
  cat > "$TMP/target/$f" <<'EOF'
# entry
before
<!-- agent-skills:begin -->
<!-- managed by agent-skills CCC0509/agent-skills@v0.2.0；手動編輯會在下次 install 被覆蓋 -->
非 trivial 任務（委派、選模型、驗證、何時停）先讀 [docs/imported-skills/agent-operating-manual/SKILL.md](docs/imported-skills/agent-operating-manual/SKILL.md)。
Read-only review（PR / commit range / plan / fix-confirmation）套 [docs/imported-skills/multi-angle-review/SKILL.md](docs/imported-skills/multi-angle-review/SKILL.md)。
<!-- agent-skills:end -->
after
EOF
done
bash "$TMP/src/install.sh" "$TMP/target"
for f in CLAUDE.md AGENTS.md GEMINI.md; do
  [ "$(grep -Fc '<!-- agent-skills:begin -->' "$TMP/target/$f")" = 1 ] || fail "$f upgrade begin marker"
  [ "$(grep -Fc 'docs/agent-memory-index.md' "$TMP/target/$f")" = 1 ] || fail "$f upgrade missing memory pointer"
  grep -Fq 'before' "$TMP/target/$f" || fail "$f upgrade lost pre-block content"
  grep -Fq 'after' "$TMP/target/$f" || fail "$f upgrade lost post-block content"
done

# 4) custom --dest does not move the fixed repo memory index
mktarget
bash "$TMP/src/install.sh" "$TMP/target" --dest vendor/imported-skills
[ -f "$TMP/target/vendor/imported-skills/agent-operating-manual/SKILL.md" ] \
  || fail "custom dest missing agent-operating-manual"
[ -f "$TMP/target/docs/agent-memory-index.md" ] || fail "custom dest missing fixed memory index"
[ ! -e "$TMP/target/vendor/agent-memory-index.md" ] || fail "memory index followed custom dest"
grep -Fq 'vendor/imported-skills/agent-operating-manual/SKILL.md' "$TMP/target/CLAUDE.md" \
  || fail "custom dest missing skill pointer"
grep -Fq 'docs/agent-memory-index.md' "$TMP/target/CLAUDE.md" \
  || fail "custom dest missing fixed memory pointer"
```

Then append the no-overwrite contract for repo-owned memory:

```bash
# 5) user-edited memory index survives reinstall
mktarget
mkdir -p "$TMP/target/docs"
printf '# My Custom Index\ncustom content\n' > "$TMP/target/docs/agent-memory-index.md"
bash "$TMP/src/install.sh" "$TMP/target"
grep -Fq 'custom content' "$TMP/target/docs/agent-memory-index.md" || fail "user index overwritten"
grep -Fq '# Agent Memory Index' "$TMP/target/docs/agent-memory-index.md" \
  && fail "starter clobbered user index"
```

Then renumber existing scenario comments if desired; the numbers are comments
only, so renumbering is optional.

- [ ] **Step 4: Extend `--create-entry` smoke**

In the existing `# 8) --create-entry creates named entry` scenario, after the
created marker assertions, add:

```bash
grep -Fq 'docs/agent-memory-index.md' "$TMP/target/CLAUDE.md" \
  || fail "created CLAUDE.md missing memory pointer"
[ -f "$TMP/target/docs/agent-memory-index.md" ] \
  || fail "create-entry missing memory index"
```

- [ ] **Step 5: Extend optional skill smoke**

In the existing optional `skill-authoring` scenario, after the skill-authoring
pointer assertion, add:

```bash
[ "$(grep -Fc 'docs/agent-memory-index.md' "$TMP/target/CLAUDE.md")" = 1 ] \
  || fail "CLAUDE.md missing memory pointer with skill-authoring"
```

- [ ] **Step 6: Run smoke and verify it fails before implementation**

Run:

```bash
bash tests/install-smoke.sh
```

Expected: FAIL on missing index or missing memory pointer.

- [ ] **Step 7: Commit the failing smoke contract**

Commit only the smoke test change:

```bash
git add tests/install-smoke.sh
git commit -m "test: cover repo memory install baseline"
```

## Task 2: Implement Memory Index Install Behavior

**Files:**
- Modify: `install.sh`
- Test: `tests/install-smoke.sh`

- [ ] **Step 1: Add fixed index constants**

Near the marker constants in `install.sh`, add:

```bash
MEMORY_INDEX="docs/agent-memory-index.md"
```

- [ ] **Step 2: Add fixed memory pointer line to the managed block**

After `POINTER_LINES=""`, initialize it with the repo-memory pointer:

```bash
POINTER_LINES="Repo memory index: [$MEMORY_INDEX]($MEMORY_INDEX).
"
```

Keep the existing per-skill pointer appends unchanged.

- [ ] **Step 3: Create the starter index after pin write**

After the `.agent-skills/pin` write and before pointer block injection, add:

```bash
# --- Repo-owned memory index ---
MEMORY_INDEX_PATH="$TARGET/$MEMORY_INDEX"
if [ ! -e "$MEMORY_INDEX_PATH" ]; then
  mkdir -p "$(dirname "$MEMORY_INDEX_PATH")"
  cat > "$MEMORY_INDEX_PATH" <<'EOF'
# Agent Memory Index

This repo owns this file. agent-skills creates it once as a starter index and
does not overwrite local edits.

## Canonical Memory

- `LESSONS.md`: not created yet; create it at the repo's chosen lesson-memory path when the first reusable lesson appears.
- Status memory: repo-owned todo / diagnosis / future-session notes.
- Audit memory: repo-owned review log, done log, observations, or release notes.

## Not Canonical Memory

- Imported skill copies under `docs/imported-skills/**`.
- Agent Trigger Kit outcome stores.
- MCP graph caches.
- Local scratch files.
EOF
fi
```

This file is intentionally not marked with `.managed-by-agent-skills`.

- [ ] **Step 4: Run smoke and verify installer behavior**

Run:

```bash
bash tests/install-smoke.sh
```

Expected: `install smoke ok`.

- [ ] **Step 5: Run shell syntax check**

Run:

```bash
bash -n install.sh
bash -n tests/install-smoke.sh
```

Expected: both commands exit 0.

- [ ] **Step 6: Commit installer implementation**

Commit the installer change:

```bash
git add install.sh
git commit -m "feat: add repo memory index installer"
```

## Task 3: Add Repo Memory Doctrine

**Files:**
- Create: `skills/agent-operating-manual/15-repo-memory.md`
- Modify: `skills/agent-operating-manual/README.md`
- Modify: `skills/agent-operating-manual/SKILL.md`
- Modify: `skills/agent-operating-manual/40-maintenance.md`

- [ ] **Step 1: Create `15-repo-memory.md`**

Create `skills/agent-operating-manual/15-repo-memory.md` with these sections:

```markdown
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
```

- [ ] **Step 2: Update manual README map**

In `skills/agent-operating-manual/README.md`, add `15-repo-memory.md` to the
file map between `10-model-dispatch.md` and `20-judgment-rubrics.md`:

```markdown
| [`15-repo-memory.md`](15-repo-memory.md) | **B** repo-owned shared memory：index、status / lesson / audit lifecycle、ATK / MCP boundaries | Session start、closeout、或要寫 repo memory 時 |
```

Add a short quick-card line after the existing five-line card:

```markdown
6. Repo memory 先讀 `docs/agent-memory-index.md`；狀態記憶可關閉，教訓記憶 append-only 到第 3 次升 rubric，audit 記憶永久 append。
```

If the numbered "5-line card" wording becomes inaccurate, rename it to
"quick reference card" without changing the existing five core rules.

- [ ] **Step 3: Update SKILL.md quick reference**

In `skills/agent-operating-manual/SKILL.md`, add to `Must Read`:

```markdown
- [`15-repo-memory.md`](15-repo-memory.md) — repo-owned shared memory：index、LESSONS lifecycle、audit boundaries、ATK / MCP 非 canonical。
```

Add a sixth core rule:

```markdown
6. Repo memory 先讀 `docs/agent-memory-index.md`；狀態記憶可關閉，教訓記憶 append-only 到第 3 次升 rubric，audit 記憶永久 append。
```

- [ ] **Step 4: Update maintenance adoption guidance**

In `skills/agent-operating-manual/40-maintenance.md` §6, change adoption step 2
from self-building `00-diagnosis.md` / `LESSONS.md` to index-first language:

```markdown
2. Review `docs/agent-memory-index.md` and choose repo-owned paths for status,
   lesson, and audit memory. A missing `LESSONS.md` is valid until the first
   reusable lesson appears, if the index says where to create it.
```

Keep the warning that per-repo memory data is never moved into agent-skills.

- [ ] **Step 5: Validate markdown references by grep**

Run:

```bash
rg -n "15-repo-memory|agent-memory-index|LESSONS.md|third same-class|第 3 次|canonical memory" skills/agent-operating-manual
```

Expected: hits in `README.md`, `SKILL.md`, `15-repo-memory.md`, and
`40-maintenance.md`.

- [ ] **Step 6: Commit repo-memory doctrine**

Commit:

```bash
git add skills/agent-operating-manual/15-repo-memory.md \
  skills/agent-operating-manual/README.md \
  skills/agent-operating-manual/SKILL.md \
  skills/agent-operating-manual/40-maintenance.md
git commit -m "docs: add repo memory protocol"
```

## Task 4: Add Codex and Gemini Model Adapters

**Files:**
- Create: `skills/agent-operating-manual/codex-model-adapter.md`
- Create: `skills/agent-operating-manual/gemini-model-adapter.md`
- Modify: `skills/agent-operating-manual/10-model-dispatch.md`
- Modify: `skills/agent-operating-manual/README.md`
- Modify: `skills/agent-operating-manual/SKILL.md`

- [ ] **Step 1: Create the Codex adapter**

Create `skills/agent-operating-manual/codex-model-adapter.md` with:

```markdown
# Codex Model Adapter

Use this when Codex reads the Agent Operating Manual and reaches Claude Code
model / effort / workflow sections.

## Capability mapping

| Capability | If available in this Codex session | If unavailable |
|---|---|---|
| Fresh workers / subagents | Delegate exploration, read-back, and independent review to fresh contexts. Keep prompts scoped and ask for `path:line` evidence. | Keep the task smaller, use local commands and CI as verification, and disclose that no fresh-context review was available. |
| Per-worker model control | Use the harness-provided model selector for mechanical vs ambiguous work. Do not copy Claude aliases. | State the needed capability rather than inventing model names. |
| Parallel workers | Fan out independent finder angles and merge only verified findings. | Run the angles sequentially and write interim notes before synthesis. |
| Tool-backed verification | Prefer tests, linters, validators, GitHub checks, and command output over reasoning. | State the verification gap and do not claim pass. |

## Rules

- Do not use Claude Code model aliases as Codex facts.
- Treat this adapter as capability-based; current Codex surfaces may change.
- Use repo instructions and available tools before defaulting to generic advice.
```

- [ ] **Step 2: Create the Gemini adapter**

Create `skills/agent-operating-manual/gemini-model-adapter.md` with:

```markdown
# Gemini Model Adapter

Use this when Gemini CLI or Gemini Code Assist reads the Agent Operating Manual
and reaches Claude Code model / effort / workflow sections.

## Capability mapping

| Capability | If available in the Gemini environment | If unavailable |
|---|---|---|
| Fresh workers / independent contexts | Use them for exploration, read-back, and review. Require concise conclusions with evidence. | Keep work scoped to the current context and rely on tests, CI, or human review for independence. |
| Model or effort controls | Map doctrine to Gemini's current documented controls. Do not copy Claude aliases. | Avoid model-selection claims; describe the reasoning difficulty and verification need. |
| Background review | Use it for review-only passes over pinned diffs or plans. | Run manual read-back with local tools and disclose the missing independent review surface. |
| Tool-backed verification | Treat command output and repository checks as primary. | Report the exact command that could not be run and the resulting gap. |

## Rules

- Do not claim exact Gemini model names or pricing from this doctrine.
- Prefer capability predicates over version-specific instructions.
- Follow the adopting repo's Gemini entrypoint when present.
```

- [ ] **Step 3: Point Claude-specific sections to adapters**

In `skills/agent-operating-manual/10-model-dispatch.md`, near the first
Claude-specific warning, add:

```markdown
Codex users: read [`codex-model-adapter.md`](codex-model-adapter.md) instead of copying §5-§7 literally.
Gemini users: read [`gemini-model-adapter.md`](gemini-model-adapter.md) instead of copying §5-§7 literally.
```

Do not change the Claude Code model table itself in this task.

- [ ] **Step 4: Link adapters from README and SKILL.md**

In the manual file map in `README.md`, add rows:

```markdown
| [`codex-model-adapter.md`](codex-model-adapter.md) | Codex capability adapter for model / worker / verification doctrine | Codex sessions reading 🟦 Claude Code sections |
| [`gemini-model-adapter.md`](gemini-model-adapter.md) | Gemini capability adapter for model / worker / verification doctrine | Gemini sessions reading 🟦 Claude Code sections |
```

In `SKILL.md`, add one sentence after the `Must Read` list:

```markdown
Codex / Gemini sessions must read their adapter file before applying Claude Code model / effort / workflow sections.
```

- [ ] **Step 5: Verify no exact model tables were copied**

Run:

```bash
rg -n "haiku|sonnet|opus|fable" skills/agent-operating-manual/codex-model-adapter.md skills/agent-operating-manual/gemini-model-adapter.md
```

Expected: no matches.

- [ ] **Step 6: Commit adapters**

Commit:

```bash
git add skills/agent-operating-manual/codex-model-adapter.md \
  skills/agent-operating-manual/gemini-model-adapter.md \
  skills/agent-operating-manual/10-model-dispatch.md \
  skills/agent-operating-manual/README.md \
  skills/agent-operating-manual/SKILL.md
git commit -m "docs: add cross-agent model adapters"
```

## Task 5: Add MCP Graph-First Doctrine

**Files:**
- Modify: `skills/agent-operating-manual/15-repo-memory.md`
- Modify: `skills/multi-angle-review/SKILL.md`

- [ ] **Step 1: Add MCP states to repo-memory doctrine**

In `15-repo-memory.md`, add section `## MCP graph state`:

```markdown
## MCP graph state

| State | Meaning | Behavior |
|---|---|---|
| `available_indexed` | Graph tool starts and reports a usable index | Prefer graph tools for exported symbols, call paths, architecture lookups, and cross-file tracing |
| `available_unindexed_or_stale` | Tool starts but the graph is missing or stale | Use graph only for safe discovery if useful; otherwise use `rg`; disclose the gap |
| `unavailable` | Tool is absent, cannot spawn, or returns errors such as `Transport closed` | Fall back to `rg` / local file reads; disclose the fallback when cross-file tracing matters |

Do not change shared repo MCP config from portable bare commands to absolute
machine paths. PATH fixes belong in user or machine configuration.
```

- [ ] **Step 2: Strengthen multi-angle-review cross-file tracer**

In `skills/multi-angle-review/SKILL.md`, replace the cross-file tracer bullet
with wording that includes the three states:

```markdown
2. **Cross-file tracer**: for every changed exported symbol, prefer code-graph tools when state is `available_indexed` (for example codebase-memory MCP `search_graph`, `trace_path`, `get_code_snippet`, `query_graph`, `search_code`). If graph state is `available_unindexed_or_stale`, use graph only for safe discovery or fall back to `rg` and disclose the stale / unindexed gap. If graph state is `unavailable` (`Transport closed`, missing tool, spawn failure), use `rg` / local file reads and disclose the fallback when cross-file tracing affects confidence. Check new preconditions, changed return shapes, newly thrown error types, and any path where a new error gets silently swallowed (warn-only catch, empty catch, continue-quietly loop).
```

- [ ] **Step 3: Verify state names are present**

Run:

```bash
rg -n "available_indexed|available_unindexed_or_stale|unavailable|Transport closed|absolute" skills/agent-operating-manual/15-repo-memory.md skills/multi-angle-review/SKILL.md
```

Expected: all three state names appear in both relevant doctrine surfaces where
appropriate; `absolute` appears in the PATH boundary.

- [ ] **Step 4: Commit MCP doctrine**

Commit:

```bash
git add skills/agent-operating-manual/15-repo-memory.md \
  skills/multi-angle-review/SKILL.md
git commit -m "docs: define MCP graph fallback doctrine"
```

## Task 6: Update README, ROADMAP, and Release Metadata

**Files:**
- Modify: `README.md`
- Modify: `ROADMAP.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Update README install output**

In `README.md`, update the install output paragraph to mention:

```markdown
`docs/agent-memory-index.md` is created once if absent. It is repo-owned and not
overwritten by later installs.
```

Keep the default install sentence unchanged: default skills are still
`agent-operating-manual,multi-angle-review`.

- [ ] **Step 2: Update adoption checklist**

In `README.md` adoption checklist, replace the current self-build line with:

```markdown
2. Review `docs/agent-memory-index.md`; choose repo-owned status / lesson /
   audit memory paths. `LESSONS.md` does not need to exist until the first
   reusable lesson appears.
```

- [ ] **Step 3: Update ROADMAP rows**

In `ROADMAP.md`:

- Move or mark these agent-skills doctrine rows as landed in v0.3.0:
  - `MCP three-state fallback doctrine`
  - `Codebase MCP graph-first tracing doctrine`
  - `Codex / Gemini model adapter doctrine`
- Add a landed row or note for `repo-memory protocol`.
- Keep these as v0.3.1+ deferred:
  - `Preflight / closeout self-report contract`
  - `Plan / PR lifecycle discipline: branch-first, PR stop, explicit approval, squash merge`
- Keep all ATK template rows deferred.

Use explicit wording such as:

```markdown
## Landed

- v0.3.0: repo-memory protocol, memory-index install baseline, MCP graph-first /
  fallback doctrine, Codex / Gemini model adapters.
```

- [ ] **Step 4: Bump plugin manifests to 0.3.0**

Change both manifest versions:

```json
"version": "0.3.0"
```

Files:

- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`

Do not tag yet. The tag is created only after merge.

- [ ] **Step 5: Commit release metadata docs**

Commit:

```bash
git add README.md ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: prepare v0.3.0 metadata"
```

## Task 7: Run Release Gates and Self-Review

**Files:**
- All changed files

- [ ] **Step 1: Run install smoke**

Run:

```bash
bash tests/install-smoke.sh
```

Expected:

```text
install smoke ok
```

- [ ] **Step 2: Run shell syntax checks**

Run:

```bash
bash -n install.sh
bash -n tests/install-smoke.sh
```

Expected: both exit 0.

- [ ] **Step 3: Run shellcheck when available**

Run:

```bash
command -v shellcheck && shellcheck install.sh tests/install-smoke.sh
```

Expected:

- If `shellcheck` exists: exit 0.
- If missing: record `shellcheck unavailable` as a verification gap in the PR
  body and final response.

- [ ] **Step 4: Validate changed skills when validator is available**

Run if the validator exists on this machine:

```bash
quick_validate.py skills/agent-operating-manual
quick_validate.py skills/multi-angle-review
```

If the command is unavailable, use the available Codex skill validator path or
record the gap.

- [ ] **Step 5: Validate Claude plugin when available**

Run:

```bash
claude plugin validate .
```

Expected: pass. If `claude` is unavailable, record the gap.

- [ ] **Step 6: Run whitespace and placeholder scans**

Run:

```bash
git diff --check origin/main..HEAD
rg -n "$(printf '%s' 'TB[D]|TO[D]O|implement[ ]later|fill[ ]in[ ]details|similar[ ]to[ ]Task|appropriate[ ]error[ ]handling')" .
```

Expected:

- `git diff --check` exit 0.
- Placeholder scan has no unresolved hits. Existing historical text may be
  acceptable only if manually classified and listed in the PR body.

- [ ] **Step 7: Verify install output manually in temp consumer**

Run:

```bash
TMP="$(mktemp -d)"
mkdir "$TMP/consumer"
printf '# AGENTS\n' > "$TMP/consumer/AGENTS.md"
bash install.sh "$TMP/consumer" --dev
find "$TMP/consumer" -maxdepth 3 -type f | sort
sed -n '1,120p' "$TMP/consumer/docs/agent-memory-index.md"
sed -n '1,80p' "$TMP/consumer/AGENTS.md"
rm -rf "$TMP"
```

Expected:

- `docs/agent-memory-index.md` exists.
- `LESSONS.md` does not exist.
- `AGENTS.md` contains exactly one managed block with memory pointer.

- [ ] **Step 8: Self-review spec coverage**

Compare the implementation against:

```bash
sed -n '1,280p' docs/superpowers/specs/2026-07-04-agent-skills-v0.3-repo-memory-design.md
```

Confirm every scope item is represented:

- Repo-memory protocol.
- Memory index baseline.
- MCP graph-first doctrine.
- Codex / Gemini adapters.
- No central memory DB.
- No auto-created `LESSONS.md`.
- No ATK runtime / schema changes.
- Default install skill list unchanged.

- [ ] **Step 9: Commit any final fixes**

If any gate requires a fix, make the minimal patch and commit:

```bash
git add <changed-files>
git commit -m "fix: close v0.3 validation gaps"
```

## Task 8: Open PR for Review

**Files:**
- PR body only

- [ ] **Step 1: Confirm branch and diff**

Run:

```bash
git status --short --branch
git diff --stat origin/main..HEAD
git log --oneline origin/main..HEAD
```

Expected:

- Worktree clean.
- Branch contains the spec commits plus implementation commits.
- Diff contains only agent-skills files listed in this plan.

- [ ] **Step 2: Push branch**

Run:

```bash
git push
```

Expected: branch updates on origin.

- [ ] **Step 3: Open draft PR**

Use GitHub UI or `gh pr create`. PR body must include:

```markdown
## Summary
- Adds repo-memory protocol and memory-index install baseline.
- Adds MCP graph-first fallback doctrine.
- Adds Codex / Gemini capability-based adapters.
- Keeps default skills unchanged and leaves `skill-authoring` optional.

## Non-goals
- No central memory DB.
- No auto-created `LESSONS.md`.
- No ATK runtime, schema, collector, or store changes.

## Verification
- [ ] bash tests/install-smoke.sh
- [ ] bash -n install.sh
- [ ] bash -n tests/install-smoke.sh
- [ ] shellcheck install.sh tests/install-smoke.sh, or gap
- [ ] quick_validate.py changed skills, or gap
- [ ] claude plugin validate ., or gap
- [ ] git diff --check origin/main..HEAD
- [ ] placeholder scan
- [ ] manual temp consumer install
```

- [ ] **Step 4: Stop for review**

Do not merge or tag. Send the PR number, branch, commits, and verification
results to the user for review.

## Final Verification Before Merge

After review approval, the merge turn must:

- Re-check PR head, mergeability, and CI.
- Squash merge.
- Pull `main`.
- Re-run release gates on `main`.
- Tag `v0.3.0` only after merge and only if manifest versions are `0.3.0`.
- Push tag.
- Do not update stock-scanner consumer in this PR. That is the next PR.

## Plan Self-Review

- Spec coverage: every v0.3 scope item maps to Tasks 2-6; validation and PR
  handoff map to Tasks 7-8.
- Placeholder scan: no unresolved placeholder markers are intentionally present.
- Smoke requirements traceability:
  1. Fresh index creation: Task 1 Step 1.
  2. Managed-block pointer injection: Task 1 Step 1.
  3. Idempotent reinstall: existing smoke scenario, extended by Task 1.
  4. Existing index not overwritten: Task 1 Step 3 no-overwrite scenario.
  5. v0.2 marker-replace upgrade path: Task 1 Step 3 upgrade scenario.
  6. `--create-entry` pointer: Task 1 Step 4.
  7. Optional `skill-authoring` pointer: Task 1 Step 5.
  8. Missing `LESSONS.md` remains valid: Task 1 Step 1 and Task 7 Step 7.
- Type / path consistency: index path is always `docs/agent-memory-index.md`;
  imported skill path remains controlled by `--dest`; adapters live under
  `skills/agent-operating-manual/`.
- Scope check: one implementation PR is reasonable because the change is
  doctrine plus installer smoke, with no runtime service or consumer migration.
