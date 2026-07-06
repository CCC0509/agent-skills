# F5 Cross-Repo Reference Map Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved F5 standalone cross-repo reference map appendix, pointers, smoke coverage, roadmap rows, and `0.4.11` metadata.

**Architecture:** Add one conditional reference appendix inside `skills/agent-operating-manual/`, link it from existing manual entry surfaces without adding it to default `Must Read`, and verify the routing surface with a dedicated smoke test. Keep external repositories out of scope; lifecycle and relay-copy concerns are recorded as ROADMAP extraction candidates only.

**Tech Stack:** Markdown doctrine files, bash smoke tests, git-based source/install verification, Agent Trigger Kit session-check.

---

## Constraints

- Base this work on approved spec commit `f517c6f` on branch `worktree-f5-cross-repo-reference-map`.
- F5 is a normative doctrine and release-metadata change. The implementation must follow this reviewed plan and end with fresh review before merge.
- Do not edit `operator-bootstrap`, Agent Trigger Kit, adopting repos, generated imported skill copies, MCP configuration, or external plugin layouts.
- Do not install or configure codebase MCP servers.
- Do not commit machine-local paths, usernames, MCP caches, graph indexes, or private local evidence.
- Keep `skills/agent-operating-manual/cross-repo-reference-map.md` conditional. It must not appear in the `SKILL.md` default `Must Read` list.
- Keep `Branch / worker lifecycle hygiene` and `Relay copy-block completeness self-check` as ROADMAP extraction candidates only. Do not define their doctrine body in F5.
- Known session-check residuals are non-blocking only when ordinary repo gates pass:
  `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`
  and `ATK plugin-version-freshness advisory indeterminate from same root-source cause / owner: Agent Trigger Kit follow-up`.

## Files

- Create: `skills/agent-operating-manual/cross-repo-reference-map.md`
- Modify: `skills/agent-operating-manual/README.md`
- Modify: `skills/agent-operating-manual/SKILL.md`
- Create: `tests/cross-repo-reference-map-smoke.sh`
- Modify: `tests/install-smoke.sh`
- Modify: `ROADMAP.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Update during execution: `docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md` checkboxes

---

### Task 1: Preflight And F5 Smoke Test

**Files:**
- Create: `tests/cross-repo-reference-map-smoke.sh`
- Modify: `docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md`

- [ ] **Step 1: Confirm branch, spec ancestor, clean state, and session health**

Run:

```bash
git rev-parse --abbrev-ref HEAD
git merge-base --is-ancestor f517c6f HEAD && echo spec-ancestor-ok
git status --porcelain
agent-trigger-kit session-check
```

Expected: branch is `worktree-f5-cross-repo-reference-map`; the merge-base command prints `spec-ancestor-ok`; `git status --porcelain` is empty before implementation; session-check exits `1` with `agent-skills: plugin directory missing` and no unmarked outcome events.

- [ ] **Step 2: Add the failing F5 smoke test**

Create `tests/cross-repo-reference-map-smoke.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "CROSS-REPO REFERENCE MAP SMOKE FAIL: $1" >&2
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

require_must_read_not_contains() {
  local file="$1"
  local token="$2"
  local section
  section="$(awk '/^## Must Read/{flag=1; next} /^## / && flag{flag=0} flag{print}' "$file")"
  ! printf '%s\n' "$section" | grep -Fq "$token" \
    || fail "$file Must Read section contains conditional appendix: $token"
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

MAP="skills/agent-operating-manual/cross-repo-reference-map.md"

require_file "$MAP"
require_contains "$MAP" '# Cross-Repo Reference Map'
require_contains "$MAP" 'operator-bootstrap'
require_contains "$MAP" 'Agent Trigger Kit'
require_contains "$MAP" 'Adopting repos'
require_contains "$MAP" 'MCP / codebase-index tooling'
require_contains "$MAP" '15-repo-memory.md'
require_contains "$MAP" 'not canonical memory'
require_contains "$MAP" 'Do not edit generated imported copies'
require_contains "$MAP" 'Do not create fake plugin directories'
require_contains "$MAP" 'Do not commit machine-local MCP'
require_contains "$MAP" 'branch-local proposal text'

require_contains skills/agent-operating-manual/README.md 'cross-repo-reference-map.md'
require_contains skills/agent-operating-manual/SKILL.md 'cross-repo-reference-map.md'
require_must_read_not_contains skills/agent-operating-manual/SKILL.md 'cross-repo-reference-map.md'

require_contains ROADMAP.md 'v0.4.11: F5 cross-repo reference map'
require_not_contains ROADMAP.md '| agent-skills doctrine | F5 cross-repo reference map |'
require_contains ROADMAP.md '| agent-skills doctrine | Branch / worker lifecycle hygiene |'
require_contains ROADMAP.md 'simultaneous editing in shared checkouts'
require_contains ROADMAP.md '| agent-skills doctrine | Relay copy-block completeness self-check |'
require_contains ROADMAP.md 'pre-handoff checklist'
require_contains ROADMAP.md 'preserves review findings inside the fenced copy block'

require_contains .claude-plugin/plugin.json '"version": "0.4.11"'
require_contains .claude-plugin/marketplace.json '"version": "0.4.11"'

copy_current_source_to_tmp_repo
VER="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  "$TMP/src/.claude-plugin/plugin.json" | head -1)"
git -C "$TMP/src" tag -f "v$VER" >/dev/null

mkdir "$TMP/target"
git -C "$TMP/target" init -q
printf '# AGENTS.md\nexisting content\n' > "$TMP/target/AGENTS.md"
bash "$TMP/src/install.sh" "$TMP/target"

INSTALLED="$TMP/target/docs/imported-skills/agent-operating-manual/cross-repo-reference-map.md"
require_file "$INSTALLED"
require_contains "$INSTALLED" 'operator-bootstrap'
require_contains "$INSTALLED" 'Agent Trigger Kit'
require_contains "$INSTALLED" '15-repo-memory.md'
require_contains "$TMP/target/docs/imported-skills/agent-operating-manual/README.md" \
  'cross-repo-reference-map.md'
require_contains "$TMP/target/docs/imported-skills/agent-operating-manual/SKILL.md" \
  'cross-repo-reference-map.md'

echo "cross-repo reference map smoke ok"
```

Make it executable:

```bash
chmod +x tests/cross-repo-reference-map-smoke.sh
```

- [ ] **Step 3: Run the F5 smoke test to verify it fails for the right reason**

Run:

```bash
./tests/cross-repo-reference-map-smoke.sh
```

Expected: exit `1` with `CROSS-REPO REFERENCE MAP SMOKE FAIL: missing required file: skills/agent-operating-manual/cross-repo-reference-map.md`.

- [ ] **Step 4: Commit the failing smoke test and plan checkbox update**

Run:

```bash
git add tests/cross-repo-reference-map-smoke.sh docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md
git commit -m "test: add f5 cross-repo map smoke"
```

Expected: commit succeeds. The smoke test is allowed to fail at this point because Task 2 provides the implementation.

---

### Task 2: Add Appendix, Pointers, Roadmap, And Metadata

**Files:**
- Create: `skills/agent-operating-manual/cross-repo-reference-map.md`
- Modify: `skills/agent-operating-manual/README.md`
- Modify: `skills/agent-operating-manual/SKILL.md`
- Modify: `ROADMAP.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md`

- [ ] **Step 1: Add the standalone appendix**

Create `skills/agent-operating-manual/cross-repo-reference-map.md`:

```markdown
# Cross-Repo Reference Map

This appendix routes ownership when a task crosses repository boundaries. It
does not replace sibling manual docs, repo-local instructions, release notes,
Agent Trigger Kit validators, or adopting-repo memory.

Read this file when a task asks where a change belongs, mentions
`operator-bootstrap`, Agent Trigger Kit, adopting repos, generated imported
skill copies, MCP / codebase-index tooling, or cross-repo residual ownership.

## Responsibility Map

| Layer | Owns | Does not own | Change here when | Residual / follow-up owner |
|---|---|---|---|---|
| `operator-bootstrap` | User-level and machine-level bootstrap instructions, generated instruction templates, operator distribution mechanics. | Portable doctrine, Agent Trigger Kit validators, adopting-repo local playbooks, MCP indexes. | The bootstrap source text, generated user-level instructions, or operator distribution path must change. | `operator-bootstrap` owner. |
| `agent-skills` | Portable doctrine skills, review / relay / approval semantics, dispatch economy doctrine, specs, plans, install-facing skill content, release metadata. | Runtime validators, outcome stores, hook mechanisms, adopting-repo domain memory, operator bootstrap templates, MCP graph caches. | The reusable doctrine itself should change for future adopting repos. | `agent-skills` ROADMAP or follow-up spec. |
| Agent Trigger Kit | Trigger validators, session-check and closeout behavior, outcome taxonomy, hook templates, trigger-layer implementation details. | Portable doctrine prose except mechanism docs, adopting-repo domain policy, generated imported skill copies. | Validation, session health, outcome recording, hooks, or trigger-layer mechanisms need different behavior. | Agent Trigger Kit follow-up. |
| Adopting repos | Local policy, generated imports, `.agent-skills/pin`, repo-specific memory, domain playbooks, review logs, local integration evidence. | Source doctrine for imported skills, operator bootstrap templates, shared ATK mechanisms, central MCP caches. | The change is domain-specific or only affects that repo's local workflow. | The adopting repo's own issue, ROADMAP, or audit memory. |
| MCP / codebase-index tooling | Optional discovery indexes and graph tooling for symbol, call-path, or architecture exploration. | Canonical repo memory, portable doctrine, install-time source of truth. | Tool configuration, launch, or index health needs mechanism work outside portable doctrine. | Agent Trigger Kit mechanism follow-up for validators; user or machine config for local paths; adopting repo when the config is repo-local. |

## Routing Checklist

- Portable doctrine, review semantics, relay fields, approval gates, dispatch
  economy, install-facing skill text, or release metadata: change
  `agent-skills`.
- User-level bootstrap text, machine bootstrap templates, or operator
  distribution mechanics: change `operator-bootstrap`.
- `session-check`, closeout, validators, hooks, outcome taxonomy, trigger-layer
  templates, or root-source plugin layout handling: route to Agent Trigger Kit.
- Generated imported files under an adopting repo are install artifacts. Fix the
  source in `agent-skills`, then reinstall or upgrade the adopting repo.
- Repo-local domain playbooks, local memory, audit evidence, and generated pin
  state belong to the adopting repo.
- MCP / codebase-index availability, graph state, fallback, and disclosure
  rules are documented in [`15-repo-memory.md`](15-repo-memory.md). Do not make
  this appendix a second normative home for those fallback rules.
- MCP tooling is not canonical memory; repo-owned files remain the durable
  source of truth for future agents.

## Do Not Do

- Do not edit generated imported copies in an adopting repo as a substitute for
  changing source doctrine in `agent-skills`.
- Do not create fake plugin directories to silence the known F4
  `agent-skills: plugin directory missing` Agent Trigger Kit boundary.
- Do not commit machine-local MCP paths, graph indexes, caches, usernames, or
  private local evidence to `agent-skills`.
- Do not make codebase MCP required for ordinary doctrine maintenance.
- Do not treat branch-local proposal text as effective doctrine before review
  and merge.
- Do not add install-time cross-repo lookups for this map; it is doctrine text
  inside the existing skill directory.
```

- [ ] **Step 2: Add the README conditional pointer**

In `skills/agent-operating-manual/README.md`, add a row to the file map after
`15-repo-memory.md`:

```markdown
| [`cross-repo-reference-map.md`](cross-repo-reference-map.md) | Cross-repo ownership map for doctrine, bootstrap, mechanism, adopting-repo, and MCP routing | When a task crosses repo boundaries or asks where a change belongs |
```

Expected: this row is in the table only. Do not add the appendix to the quick-reference startup list.

- [ ] **Step 3: Add the SKILL conditional pointer**

In `skills/agent-operating-manual/SKILL.md`, add this sentence after the existing conditional sentence for `25-change-discipline.md`:

```markdown
For cross-repo routing, ownership, codebase MCP availability, or residual owner questions, also read [`cross-repo-reference-map.md`](cross-repo-reference-map.md).
```

Expected: the `## Must Read` list remains exactly `README.md`, `10-model-dispatch.md`, and `15-repo-memory.md`. The appendix pointer appears only after that list in a conditional paragraph.

- [ ] **Step 4: Update ROADMAP landed and extraction candidate rows**

In `ROADMAP.md`, add this landed entry after `v0.4.10`:

```markdown
- v0.4.11: F5 cross-repo reference map adds a conditional
  agent-operating-manual appendix for routing operator-bootstrap, agent-skills,
  Agent Trigger Kit, adopting-repo, and MCP ownership without adding external
  repo dependencies or daily startup load.
```

Remove this Extraction Candidate row:

```markdown
| agent-skills doctrine | F5 cross-repo reference map | agent-skills | Separate follow-up for documenting operator-bootstrap as machine/user layer, agent-skills as doctrine, and Agent Trigger Kit as mechanism without creating circular install dependencies. |
```

Add these Extraction Candidate rows near the other `agent-skills doctrine` rows:

```markdown
| agent-skills doctrine | Branch / worker lifecycle hygiene | agent-skills / ATK | Separate from Shared checkout concurrency etiquette: this covers worker spawn / wait / consume / close, concurrency caps, post-merge push state, and cleanup of merged worktrees / local branches after scoped work reaches review or merge; any validator mechanism belongs with ATK. |
| agent-skills doctrine | Relay copy-block completeness self-check | agent-skills | Needs a pre-handoff checklist that validates legal `Status:` values, `User action:` / `Next agent action:` pairing, a single fenced copy block when forwarding to another agent, and preserves review findings inside the fenced copy block. |
```

Expected: the existing `Shared checkout concurrency etiquette` row remains unchanged.

- [ ] **Step 5: Bump release metadata to 0.4.11**

In `.claude-plugin/plugin.json`, change:

```json
"version": "0.4.10"
```

to:

```json
"version": "0.4.11"
```

In `.claude-plugin/marketplace.json`, change the plugin entry version from:

```json
"version": "0.4.10"
```

to:

```json
"version": "0.4.11"
```

Expected: no other metadata fields change.

- [ ] **Step 6: Run the F5 smoke test to verify it now passes**

Run:

```bash
./tests/cross-repo-reference-map-smoke.sh
```

Expected: exit `0` and prints `cross-repo reference map smoke ok`.

- [ ] **Step 7: Verify Must Read exclusion directly**

Run:

```bash
if awk '/^## Must Read/{flag=1; next} /^## / && flag{flag=0} flag{print}' skills/agent-operating-manual/SKILL.md | grep -Fq 'cross-repo-reference-map.md'; then
  echo must-read-leak
  exit 1
else
  echo must-read-clean
fi
```

Expected: exit `0` and prints `must-read-clean`. This proves the appendix is not in the default `Must Read` list.

- [ ] **Step 8: Commit appendix, pointers, roadmap, metadata, smoke pass, and plan checkbox update**

Run:

```bash
git add skills/agent-operating-manual/cross-repo-reference-map.md skills/agent-operating-manual/README.md skills/agent-operating-manual/SKILL.md ROADMAP.md .claude-plugin/plugin.json .claude-plugin/marketplace.json docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md
git commit -m "docs: add f5 cross-repo reference map"
```

Expected: commit succeeds. The dedicated F5 smoke test passed before commit.

---

### Task 3: Reinforce Install Smoke Coverage

**Files:**
- Modify: `tests/install-smoke.sh`
- Modify: `docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md`

- [ ] **Step 1: Add installed-copy assertions to install smoke**

In `tests/install-smoke.sh`, after the default installed-skill sentinel loop:

```bash
for s in agent-operating-manual multi-angle-review; do
  [ -f "$TMP/target/docs/imported-skills/$s/SKILL.md" ] || fail "missing $s/SKILL.md"
  [ -f "$TMP/target/docs/imported-skills/$s/.managed-by-agent-skills" ] || fail "missing $s sentinel"
done
```

add:

```bash
MAP="$TMP/target/docs/imported-skills/agent-operating-manual/cross-repo-reference-map.md"
[ -f "$MAP" ] || fail "missing cross-repo reference map"
grep -Fq 'operator-bootstrap' "$MAP" || fail "reference map missing operator-bootstrap"
grep -Fq 'Agent Trigger Kit' "$MAP" || fail "reference map missing Agent Trigger Kit"
grep -Fq '15-repo-memory.md' "$MAP" || fail "reference map missing repo-memory routing"
grep -Fq 'cross-repo-reference-map.md' \
  "$TMP/target/docs/imported-skills/agent-operating-manual/README.md" \
  || fail "imported manual README missing reference map pointer"
grep -Fq 'cross-repo-reference-map.md' \
  "$TMP/target/docs/imported-skills/agent-operating-manual/SKILL.md" \
  || fail "imported manual SKILL missing reference map pointer"
```

- [ ] **Step 2: Run install smoke**

Run:

```bash
./tests/install-smoke.sh
```

Expected: exit `0` and prints `install smoke ok`.

- [ ] **Step 3: Commit install smoke reinforcement and plan checkbox update**

Run:

```bash
git add tests/install-smoke.sh docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md
git commit -m "test: cover installed f5 reference map"
```

Expected: commit succeeds.

---

### Task 4: Final Verification And Closeout

**Files:**
- Modify: `docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md`

- [ ] **Step 1: Run full source and install smokes**

Run:

```bash
./tests/cross-repo-reference-map-smoke.sh
./tests/source-entrypoint-smoke.sh
./tests/install-smoke.sh
```

Expected: each exits `0`; outputs include `cross-repo reference map smoke ok`, `source entrypoint smoke ok`, and `install smoke ok`.

- [ ] **Step 2: Run diff whitespace check**

Run:

```bash
git diff --check "$(git merge-base HEAD main)"..HEAD
```

Expected: exit `0` with no output.

- [ ] **Step 3: Run public-evidence hygiene scan**

Run:

```bash
LOCAL_USER="$(id -un)"
LOCAL_PATH_RE='/(Users|private)/'
rg -n "$LOCAL_PATH_RE|$LOCAL_USER" docs/superpowers/specs/2026-07-07-f5-cross-repo-reference-map-design.md docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md skills/agent-operating-manual/cross-repo-reference-map.md ROADMAP.md tests/cross-repo-reference-map-smoke.sh tests/install-smoke.sh
```

Expected: exit `1` with no output.

- [ ] **Step 4: Run token scan**

Run:

```bash
rg -n "cross-repo reference map|operator-bootstrap|Agent Trigger Kit|adopting repos|codebase MCP|15-repo-memory\\.md|not canonical memory|Branch / worker lifecycle hygiene|Relay copy-block completeness self-check|Must Read|v0\\.4\\.11|0\\.4\\.11" skills/agent-operating-manual ROADMAP.md tests .claude-plugin
```

Expected: output includes hits in `skills/agent-operating-manual/cross-repo-reference-map.md`, `skills/agent-operating-manual/README.md`, `skills/agent-operating-manual/SKILL.md`, `ROADMAP.md`, `tests/cross-repo-reference-map-smoke.sh`, `tests/install-smoke.sh`, and `.claude-plugin/**`.

- [ ] **Step 5: Verify F5 candidate retired and tracker rows present**

Run:

```bash
if grep -Fq '| agent-skills doctrine | F5 cross-repo reference map |' ROADMAP.md; then
  echo f5-candidate-still-present
  exit 1
else
  echo f5-candidate-retired
fi
grep -F '| agent-skills doctrine | Branch / worker lifecycle hygiene |' ROADMAP.md
grep -F '| agent-skills doctrine | Relay copy-block completeness self-check |' ROADMAP.md
```

Expected: the first block prints `f5-candidate-retired`; second and third commands print the new tracker rows.

- [ ] **Step 6: Run session-check closeout**

Run:

```bash
agent-trigger-kit session-check --closeout
```

Expected: exit `1` with `agent-skills: plugin directory missing`; plugin-version-freshness may be indeterminate from the same root-source cause; no unmarked outcome events. If exit `4` reports unmarked events, mark them per the session-check skill when possible, rerun closeout, and report any remaining blocker precisely.

- [ ] **Step 7: Verify worktree clean except final plan checkbox update**

Run:

```bash
git status --short --branch
git rev-parse HEAD
```

Expected: before the final commit, status shows only this plan file modified for Task 4 checkbox updates. HEAD prints the implementation commit.

- [ ] **Step 8: Commit final plan checkbox update**

Run:

```bash
git add docs/superpowers/plans/2026-07-07-f5-cross-repo-reference-map.md
git commit -m "docs: mark f5 implementation closeout"
```

Expected: commit succeeds.

- [ ] **Step 9: Final handoff**

Use this relay shape, filling in the final HEAD:

```text
Status: review-needed
Target repo: CCC0509/agent-skills
Target: F5 cross-repo reference map implementation on branch worktree-f5-cross-repo-reference-map at <HEAD>
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: review F5 appendix scope, conditional pointers, smoke coverage, ROADMAP landed/tracker rows, metadata 0.4.11, and absence of external repo / MCP config changes
Blockers: none
Accepted residuals: ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up; ATK plugin-version-freshness advisory indeterminate from same root-source cause / owner: Agent Trigger Kit follow-up

Review: full
Focus: F5 cross-repo ownership map, conditional Must Read exclusion, MCP fallback canonical-home routing to 15-repo-memory.md, installed-copy smoke coverage, ROADMAP F5 retirement plus branch/worker lifecycle and relay copy-block tracker rows
Prev reviewed tip: f517c6f
```

Expected: the `Next agent action` names exactly what the reviewer should inspect, and any findings from review or implementation are preserved inside the fenced copy block before handoff.
