# Fresh Session Continuity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the reviewed v0.5.10 Fresh Session Continuity doctrine so agents know when to hand off to a fresh session and how to report skill-source provenance before blaming misses on version bumps.

**Architecture:** Add one focused smoke script that proves the source and installed copies expose the new continuity/provenance tokens. Keep canonical semantics in `skills/agent-operating-manual/10-model-dispatch.md`, add only a pointer-style trigger reminder to `skills/handoff-relay/SKILL.md`, update ROADMAP and metadata for the install-facing train, and stop for fresh review before merge, push, tag, publish, or implementation cleanup.

**Tech Stack:** Markdown doctrine, Bash smoke tests, JSON plugin metadata, Git.

## Global Constraints

- Base the implementation on reviewed spec/disposition commit `bf31a11`, which records plan/rule-review pass for `1d97020` over range `0395c70..1d97020`.
- Carry both review advisories: continuity-packet wording must carry the positive half of the Route display rule for executable approval / continuation packets, and implementation must not restate a compressed `ready-for-continuation` precondition.
- Keep canonical wording in existing doctrine: `10-model-dispatch.md` for context-health handoff and provenance, `15-repo-memory.md` only if memory routing must change, and `handoff-relay/SKILL.md` only as a trigger wrapper pointer.
- Do not create a new default-installed skill.
- Do not change Agent Trigger Kit validators, `session-check`, `live-check`, version-check, doctor behavior, hooks, or outcome taxonomy.
- Do not edit operator-bootstrap templates, adopting repo files, generated imported copies in adopting repos, or `.agent-skills/pin` in any target repo.
- Do not create, push, or publish a release tag. Do not push `main`. Do not delete branches.
- Do not commit private local paths, usernames, raw cache listings, or adopting-repo private evidence to public artifacts.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to `0.5.10` because this train changes install-facing doctrine.
- Branch-local doctrine is proposal text until reviewed and merged; adopting repos see new doctrine only after the later reviewed tag/release and installer refresh.
- In this source repo, `agent-trigger-kit session-check` may exit 1 only for `agent-skills: plugin directory missing`; when a relay signal is present, carry the accepted residual exactly as documented in AGENTS.md.

---

## File Structure

- Create `tests/fresh-session-continuity-smoke.sh`: source + installed-copy smoke for context-health, continuity packet, provenance surfaces, route-display positive half, metadata `0.5.10`, and ROADMAP retirement.
- Modify `skills/agent-operating-manual/10-model-dispatch.md`: add compact `Context-health handoff` and `Skill source provenance` doctrine after the existing pre-handoff self-check, before §4.
- Modify `skills/handoff-relay/SKILL.md`: add a trigger-wrapper pointer for context-health / fresh-session / provenance handoffs without restating the canonical state machine.
- Modify `ROADMAP.md`: add the v0.5.10 Landed entry, remove the implemented `Session continuity / context-health handoff` and `Skill source provenance / freshness report` candidate rows from the active candidate table, keep `Skill context loading / retrieval strategy` and `Automated skill maintenance / optimization protocol` open, and extend the batched-release note to v0.5.10.
- Modify `.claude-plugin/plugin.json`: bump `version` from `0.5.9` to `0.5.10`.
- Modify `.claude-plugin/marketplace.json`: bump `plugins[0].version` from `0.5.9` to `0.5.10`.
- Update `docs/superpowers/plans/2026-07-08-fresh-session-continuity.md`: mark execution checkboxes as tasks complete, then commit verification state.

---

### Task 1: Add Failing Fresh-Session Continuity Smoke

**Files:**
- Create: `tests/fresh-session-continuity-smoke.sh`
- Update: `docs/superpowers/plans/2026-07-08-fresh-session-continuity.md`

**Interfaces:**
- Consumes: reviewed spec/disposition `docs/superpowers/specs/2026-07-08-fresh-session-continuity-design.md`.
- Produces: executable smoke command `bash tests/fresh-session-continuity-smoke.sh` that later tasks must make pass.

- [ ] **Step 1: Create the smoke script**

Create `tests/fresh-session-continuity-smoke.sh` with this exact content:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "FRESH SESSION CONTINUITY SMOKE FAIL: $1" >&2
  exit 1
}

require_file() {
  local file="$1"
  [ -f "$file" ] || fail "missing required file: $file"
}

require_contains() {
  local file="$1"
  local token="$2"
  grep -Fq "$token" "$file" || fail "$file missing token: $token"
}

require_not_contains() {
  local file="$1"
  local token="$2"
  ! grep -Fq "$token" "$file" || fail "$file contains forbidden token: $token"
}

copy_current_source_to_tmp_repo() {
  mkdir -p "$TMP/src"
  (
    cd "$ROOT"
    git ls-files
    git ls-files --others --exclude-standard
  ) | while IFS= read -r file; do
    [ -f "$ROOT/$file" ] || continue
    mkdir -p "$TMP/src/$(dirname "$file")"
    cp "$ROOT/$file" "$TMP/src/$file"
  done

  git -C "$TMP/src" init -q
  git -C "$TMP/src" add .
  git -C "$TMP/src" -c user.name='Smoke Test' \
    -c user.email='smoke@example.invalid' commit -q -m smoke
}

cd "$ROOT"

AOM="skills/agent-operating-manual/10-model-dispatch.md"
RELAY="skills/handoff-relay/SKILL.md"
ROADMAP="ROADMAP.md"

require_file "$AOM"
require_file "$RELAY"
require_file "$ROADMAP"

require_contains "$AOM" 'Context-health handoff'
require_contains "$AOM" 'Continuity packet'
require_contains "$AOM" 'Skill source provenance'
require_contains "$AOM" 'Source checkout'
require_contains "$AOM" 'Imported skill copy'
require_contains "$AOM" 'Plugin cache'
require_contains "$AOM" 'User-level operator bootstrap'
require_contains "$AOM" 'Executable continuity packets include the recommended route block'
require_contains "$AOM" 'Do not restate `ready-for-continuation` preconditions here'

require_contains "$RELAY" 'context-health'
require_contains "$RELAY" 'skill-source provenance'
require_contains "$RELAY" '10-model-dispatch.md'

require_contains "$ROADMAP" 'v0.5.10: Fresh session continuity'
require_contains "$ROADMAP" 'v0.5.7, v0.5.8, v0.5.9, and v0.5.10 install-facing content require a later §3.2 tag'
require_not_contains "$ROADMAP" '| agent-skills doctrine | Session continuity / context-health handoff |'
require_not_contains "$ROADMAP" '| agent-skills doctrine / freshness | Skill source provenance / freshness report |'
require_contains "$ROADMAP" '| agent-skills doctrine / tooling | Skill context loading / retrieval strategy |'
require_contains "$ROADMAP" '| agent-skills doctrine / skill maintenance | Automated skill maintenance / optimization protocol |'

require_contains .claude-plugin/plugin.json '"version": "0.5.10"'
require_contains .claude-plugin/marketplace.json '"version": "0.5.10"'

copy_current_source_to_tmp_repo
VER="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  "$TMP/src/.claude-plugin/plugin.json" | head -1)"
git -C "$TMP/src" tag -f "v$VER" >/dev/null

mkdir "$TMP/target"
git -C "$TMP/target" init -q
printf '# AGENTS.md\nexisting content\n' > "$TMP/target/AGENTS.md"
bash "$TMP/src/install.sh" "$TMP/target"

INSTALLED_AOM="$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md"
INSTALLED_RELAY="$TMP/target/docs/imported-skills/handoff-relay/SKILL.md"
require_file "$INSTALLED_AOM"
require_file "$INSTALLED_RELAY"

require_contains "$INSTALLED_AOM" 'Context-health handoff'
require_contains "$INSTALLED_AOM" 'Continuity packet'
require_contains "$INSTALLED_AOM" 'Skill source provenance'
require_contains "$INSTALLED_AOM" 'Source checkout'
require_contains "$INSTALLED_AOM" 'Imported skill copy'
require_contains "$INSTALLED_AOM" 'Plugin cache'
require_contains "$INSTALLED_AOM" 'User-level operator bootstrap'
require_contains "$INSTALLED_AOM" 'Executable continuity packets include the recommended route block'
require_contains "$INSTALLED_AOM" 'Do not restate `ready-for-continuation` preconditions here'
require_contains "$INSTALLED_RELAY" 'context-health'
require_contains "$INSTALLED_RELAY" 'skill-source provenance'

[ "$(cat "$TMP/target/.agent-skills/pin")" = "CCC0509/agent-skills@v0.5.10" ] \
  || fail "pin did not resolve v0.5.10"

echo "fresh session continuity smoke ok"
```

- [ ] **Step 2: Make the smoke script executable**

Run:

```bash
chmod +x tests/fresh-session-continuity-smoke.sh
```

Expected: command exits `0`.

- [ ] **Step 3: Run the smoke script and verify it fails red**

Run:

```bash
bash tests/fresh-session-continuity-smoke.sh
```

Expected: exit `1` with:

```text
FRESH SESSION CONTINUITY SMOKE FAIL: skills/agent-operating-manual/10-model-dispatch.md missing token: Context-health handoff
```

If the first failure is a different missing token from the same new v0.5.10 token set, inspect the script ordering and source tree before continuing. Do not proceed if the script passes before Task 2.

- [ ] **Step 4: Commit the red smoke**

Run:

```bash
git add tests/fresh-session-continuity-smoke.sh docs/superpowers/plans/2026-07-08-fresh-session-continuity.md
git commit -m "test: add fresh session continuity smoke"
```

Expected: commit succeeds. The new smoke is expected to fail until Task 2 adds the doctrine, roadmap, and metadata tokens.

---

### Task 2: Add v0.5.10 Doctrine, Roadmap, Metadata, and Green Smoke

**Files:**
- Modify: `skills/agent-operating-manual/10-model-dispatch.md`
- Modify: `skills/handoff-relay/SKILL.md`
- Modify: `ROADMAP.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Update: `docs/superpowers/plans/2026-07-08-fresh-session-continuity.md`

**Interfaces:**
- Consumes: `tests/fresh-session-continuity-smoke.sh` red assertions.
- Produces: v0.5.10 install-facing doctrine and metadata that make the new smoke pass.

- [ ] **Step 1: Add canonical context-health and provenance doctrine**

In `skills/agent-operating-manual/10-model-dispatch.md`, insert the following subsection after the existing `Pre-handoff self-check` bullet list and before the horizontal rule that precedes `## §4 驗證不自驗（Verify, not self-verify）`:

```markdown
Context-health handoff：當 current session 的 context 本身開始不可靠時，先判斷
是否該繼續在本 session 作業，或改成 fresh-session handoff。可繼續的條件是：你能
直接重新核對相關 doctrine file、target head、pending gates、verification state 與
handoff fields。若出現多次 compaction / visible context loss、明顯 slowdown / hang、
反覆失去 task thread、無法確認 skill source provenance、下一步是 approval-bound /
review-bound / release-bound / control-contract change，或本 session 已產生或收到
不合規 handoff，偏向產生 Continuity packet，讓使用者開新 session 或交給 sanctioned
fresh-context worker。不要聲稱 agent 能靜默轉移 authority；fresh session 仍受既有
review、approval、merge、tag、publish 邊界約束。

Continuity packet：fresh-session handoff 不新增 `Status:` 值，使用既有 relay block。
packet 至少帶 target repo / object、effective contract、proposal boundary、pending
gates、verification state、next action、accepted residuals，以及 three-line `Review:`
contract。review-only、findings-delivery、fix-confirmation-delivery 仍不顯示
`Execution route:`。Executable continuity packets include the recommended route block：
當 packet 依 Route display rule 屬於 executable approval / continuation handoff 時，
在 relay signal 後加入推薦的 `Execution route:`、`Route reason:`、`User approval needed:`
block。Do not restate `ready-for-continuation` preconditions here；是否可 continuation
完全依本節上方 canonical `Status:` semantics 和 Route display rule 判斷。

Skill source provenance：當使用者問「是否沒讀到 skill」、「是否 version 沒 bump」、
或 handoff / review miss 可能來自 stale skill surface 時，先分開報告 relevant
surfaces，不要把 source、import、plugin cache、operator-bootstrap 混成一個 freshness
判斷。

- Source checkout：直接讀目前 checkout 的 source files；agent 檢查 source repo
  不需要 plugin bump。Branch-local doctrine / entrypoint text 在 fresh review 與
  merge 前仍是 proposal text，不能用來放寬 effective contract。
- Imported skill copy：讀 adopting repo 的 `.agent-skills/pin`、managed imported files
  和 install metadata。它只會在選定 release/tag/source reference 並 rerun installer /
  upgrade path 後更新；不要手改 generated imported copies 代替 source doctrine。
- Plugin cache：讀 installed plugin metadata 與 runtime discovery state。舊 installed
  plugin version 不會知道新 skill；更新、upgrade、cache refresh、restart 規則屬於
  plugin lifecycle / Agent Trigger Kit mechanism。
- User-level operator bootstrap：讀 managed instruction block 與 template provenance。
  更新 `agent-skills` source doctrine 不會自動改 user-level instructions；需要
  operator-bootstrap propagation 才會更新。
- Mechanism checks：validators、session-check、live-check、version-check、doctor /
  repair flow 屬於 Agent Trigger Kit 或 owning surface；agent-skills 只記錄 portable
  doctrine，不把 runtime collection 寫進 markdown skill。
```

Expected: the inserted subsection contains every token asserted by `tests/fresh-session-continuity-smoke.sh` and does not create new relay fields or `Status:` values.

- [ ] **Step 2: Add the handoff-relay trigger pointer**

In `skills/handoff-relay/SKILL.md`, append this item to the numbered `## Apply` list after the current item 6:

```markdown
7. For context-health, fresh-session, or skill-source provenance questions,
   read `../agent-operating-manual/10-model-dispatch.md` before deciding
   whether to continue in the current session, emit a continuity packet, or
   explain source / imported-copy / plugin-cache freshness.
```

Expected: this stays pointer-only and does not copy the canonical relay state machine into the wrapper.

- [ ] **Step 3: Update ROADMAP for v0.5.10**

In `ROADMAP.md`, add this Landed entry after the v0.5.9 entry:

```markdown
- v0.5.10: Fresh session continuity adds context-health handoff and
  skill-source provenance reporting to the handoff / relay doctrine, records
  when agents should continue in-session versus emit a continuity packet, and
  distinguishes source checkout, imported skill copy, plugin cache, user-level
  operator-bootstrap, and Agent Trigger Kit mechanism surfaces. The release
  remains batched: v0.5.7, v0.5.8, v0.5.9, and v0.5.10 install-facing content
  require a later §3.2 tag before non-dev adopter delivery.
```

Then replace the `Trigger Surface / Context Loading` lane paragraph with:

```markdown
- **Trigger Surface / Context Loading:** `Skill context loading / retrieval
  strategy`, `F2 handoff-contract file split`, and `Plan/spec lifecycle header
  convention text`. This lane owns remaining rule discovery, trigger wording,
  context-load reduction, and the doctrine / ATK / adopting-repo split for
  generated or local trigger surfaces after v0.5.10 covers fresh-session
  continuity and skill-source provenance.
```

Then remove exactly these two rows from the `Extraction Candidates` table:

```markdown
| agent-skills doctrine | Session continuity / context-health handoff | agent-skills / Agent Trigger Kit / operator-bootstrap | Context compaction, slow sessions, or failed handoffs need a portable decision rule for when to continue in place, use a sanctioned fresh-context mechanism, or ask the user to open a new session with a complete relay packet; mechanisms and user-level propagation stay with their owners. |
| agent-skills doctrine / freshness | Skill source provenance / freshness report | agent-skills / Agent Trigger Kit / operator-bootstrap / adopting repos | Agents need to distinguish source checkout reading, `.agent-skills/pin` imported copies, plugin cache/runtime discovery, and user-level bootstrap templates before blaming a miss on missing version bumps; machine-readable probes belong with ATK or the owning surface. |
```

Expected: `Skill context loading / retrieval strategy`, `F2 handoff-contract file split`, `Plan/spec lifecycle header convention text`, and `Automated skill maintenance / optimization protocol` remain open in `ROADMAP.md`.

- [ ] **Step 4: Bump plugin metadata to 0.5.10**

In `.claude-plugin/plugin.json`, change only the version field:

```json
  "version": "0.5.10",
```

In `.claude-plugin/marketplace.json`, change only `plugins[0].version`:

```json
      "version": "0.5.10",
```

Expected: no description, source, owner, category, or strict-field changes.

- [ ] **Step 5: Run the new smoke and verify it passes green**

Run:

```bash
bash tests/fresh-session-continuity-smoke.sh
```

Expected:

```text
fresh session continuity smoke ok
```

- [ ] **Step 6: Run the install smoke**

Run:

```bash
bash tests/install-smoke.sh
```

Expected:

```text
install smoke ok
```

- [ ] **Step 7: Commit doctrine, roadmap, metadata, and plan progress**

Run:

```bash
git add tests/fresh-session-continuity-smoke.sh skills/agent-operating-manual/10-model-dispatch.md skills/handoff-relay/SKILL.md ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json docs/superpowers/plans/2026-07-08-fresh-session-continuity.md
git commit -m "docs: add fresh session continuity doctrine"
```

Expected: commit succeeds and contains no operator-bootstrap, Agent Trigger Kit, adopting-repo, generated imported-copy, push, tag, publish, or branch-cleanup changes.

---

### Task 3: Verify and Prepare Fresh Review Handoff

**Files:**
- Update: `docs/superpowers/plans/2026-07-08-fresh-session-continuity.md`

**Interfaces:**
- Consumes: Task 1 red smoke and Task 2 green implementation.
- Produces: verification commit plus a review-needed relay for the implementation train.

- [ ] **Step 1: Run the full verification set**

Run:

```bash
agent-trigger-kit session-check --closeout
bash tests/fresh-session-continuity-smoke.sh
bash tests/cross-repo-reference-map-smoke.sh
bash tests/install-smoke.sh
git diff --check origin/main..HEAD
rg -n 'Context-health handoff|Continuity packet|Skill source provenance|Source checkout|Imported skill copy|Plugin cache|User-level operator bootstrap|Executable continuity packets include the recommended route block|Do not restate `ready-for-continuation` preconditions here|v0\.5\.10|0\.5\.10|Automated skill maintenance / optimization protocol' skills ROADMAP.md tests .claude-plugin docs/superpowers/specs docs/superpowers/plans
```

Expected:

- `agent-trigger-kit session-check --closeout` exits `1` only for `agent-skills: plugin directory missing` and may report the related plugin-version-freshness advisory as indeterminate from the same root-source cause; unmarked outcome events are none.
- `bash tests/fresh-session-continuity-smoke.sh` prints `fresh session continuity smoke ok`.
- `bash tests/cross-repo-reference-map-smoke.sh` prints `cross-repo reference map smoke ok`.
- `bash tests/install-smoke.sh` prints `install smoke ok`.
- `git diff --check origin/main..HEAD` exits `0`.
- The token scan includes source doctrine, installed-smoke coverage, ROADMAP v0.5.10, metadata `0.5.10`, the preserved automated-maintenance row, and the reviewed spec / plan references.

- [ ] **Step 2: Verify proposal-only scope and release boundaries**

Run:

```bash
git diff --name-only "$(git merge-base HEAD origin/main)"..HEAD -- skills/ AGENTS.md CLAUDE.md GEMINI.md
git diff --name-only origin/main..HEAD
git tag --points-at HEAD
```

Expected:

- The first command lists `skills/agent-operating-manual/10-model-dispatch.md` and `skills/handoff-relay/SKILL.md`; treat the new text as proposal text until review and merge.
- The second command lists only the approved source-repo surfaces accumulated
  since `origin/main`: `.claude-plugin/marketplace.json`,
  `.claude-plugin/plugin.json`, `ROADMAP.md`,
  `docs/superpowers/plans/2026-07-08-cross-repo-integration-intake.md`,
  `docs/superpowers/plans/2026-07-08-fresh-session-continuity.md`,
  `docs/superpowers/specs/2026-07-07-cross-repo-integration-intake-design.md`,
  `docs/superpowers/specs/2026-07-08-fresh-session-continuity-design.md`,
  `skills/agent-operating-manual/10-model-dispatch.md`,
  `skills/agent-operating-manual/cross-repo-reference-map.md`,
  `skills/handoff-relay/SKILL.md`, `tests/cross-repo-reference-map-smoke.sh`,
  `tests/fresh-session-continuity-smoke.sh`, and `tests/install-smoke.sh`.
- `git tag --points-at HEAD` prints nothing. If it prints a tag, stop and investigate because this plan does not authorize tag creation.

- [ ] **Step 3: Commit verification checkbox updates**

After marking completed checkboxes in this plan, run:

```bash
git add docs/superpowers/plans/2026-07-08-fresh-session-continuity.md
git commit -m "docs: mark fresh session continuity verification"
```

Expected: commit succeeds. If there are no checkbox changes because the executor chose not to update plan state, do not create an empty commit; record that fact in the review handoff.

- [ ] **Step 4: Prepare the review-needed handoff**

Before writing the handoff, run:

```bash
git rev-parse HEAD
git log -1 --format=%H -- docs/superpowers/plans/2026-07-08-fresh-session-continuity.md
git status -sb
```

Expected: record the current implementation head, the latest plan-file commit, and clean or explicitly scoped worktree status.

Use this relay shape. Replace the target SHA with the exact `git rev-parse HEAD` output. Use the latest plan-file commit after plan review passes as `Prev reviewed tip`; if the plan review pass tip differs from the plan-file commit, use the reviewed plan tip named by the reviewer.

```text
Status: review-needed
Target repo: CCC0509/agent-skills
Target: v0.5.10 Fresh Session Continuity implementation @ <implementation-head-sha>
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review v0.5.10 fresh-session continuity doctrine, trigger-wrapper pointer, smoke coverage, ROADMAP landed/retired rows, metadata 0.5.10, proposal-boundary handling, and absence of push/tag/publish/operator-bootstrap/ATK/adopting-repo/generated-import scope creep
Blockers: none
Accepted residuals: ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up; ATK plugin-version-freshness advisory indeterminate from same root-source cause / owner: Agent Trigger Kit follow-up; batched release for v0.5.7 + v0.5.8 + v0.5.9 + v0.5.10 install-facing content / recorded in ROADMAP Landed entries, requires later §3.2 tag before non-dev adopter delivery / owner: next release train; local main ahead of origin/main / push remains separate approval-bound action / owner: user

Review: full
Focus: context-health handoff semantics, skill-source provenance surface split, positive Route display rule handling for executable continuity packets, no compressed ready-for-continuation restatement, ROADMAP retirement/preservation, metadata 0.5.10, and install/source smoke coverage
Prev reviewed tip: <reviewed-plan-tip>
```

Expected: no `Execution route:` block appears because this is a review-only handoff.

---

## Plan Self-Review

- Spec coverage: Task 1 covers source and installed-copy pressure tests; Task 2 covers canonical doctrine, trigger-wrapper pointer, ROADMAP, metadata, green smoke, and both review advisories; Task 3 covers full verification, proposal-boundary checks, no-tag check, and final review handoff.
- Scope control: No task edits operator-bootstrap, Agent Trigger Kit, adopting repos, generated imported copies in adopting repos, push/tag/publish surfaces, or branch cleanup.
- Skill Surface Disposition: Keep canonical wording in `10-model-dispatch.md`; keep `handoff-relay/SKILL.md` as a pointer-only trigger wrapper; do not create a new default-installed skill; defer mechanisms to Agent Trigger Kit and propagation to operator-bootstrap.
- ROADMAP handling: v0.5.10 should close only `Session continuity / context-health handoff` and `Skill source provenance / freshness report`; preserve `Skill context loading / retrieval strategy`, `F2 handoff-contract file split`, `Plan/spec lifecycle header convention text`, `Automated skill maintenance / optimization protocol`, worker hygiene, public/private artifact, portable-release, memory, and ATK template rows.
- Type/token consistency: Required tokens are consistent across smoke, doctrine, roadmap, and metadata: `Context-health handoff`, `Continuity packet`, `Skill source provenance`, `Source checkout`, `Imported skill copy`, `Plugin cache`, `User-level operator bootstrap`, `Executable continuity packets include the recommended route block`, `Do not restate \`ready-for-continuation\` preconditions here`, `v0.5.10`, and `0.5.10`.
