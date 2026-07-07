# Cross-Repo Integration Intake Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land the v0.5.9 cross-repo intake protocol as installed agent-operating-manual doctrine without editing any external repo.

**Architecture:** Extend the existing cross-repo reference map with a compact intake packet and read-only adopting-repo overlap audit. Pin source and installed-copy smoke coverage to the new tokens, bump install-facing metadata to 0.5.9, and close the solved ROADMAP candidate while preserving adjacent lanes.

**Tech Stack:** Markdown doctrine, Bash smoke tests, JSON plugin metadata, Git commits.

## Global Constraints

- Effective authority is merged `main` plus repo/user instructions; branch-local doctrine remains proposal text until reviewed and merged.
- Do not edit `operator-bootstrap`, Agent Trigger Kit, Stock Scanner, or any adopting repo in this train.
- Do not create, push, or publish a v0.5.9 tag.
- Do not delete local or remote branches; branch cleanup remains in `Branch / worker lifecycle hygiene`.
- Local checkout paths, usernames, and private evidence belong only in handoffs or private evidence, never in committed public artifacts.
- The v0.5.7 and v0.5.8 install-facing batch remains pending; this train adds v0.5.9 content to that later release-choice surface after merge.
- In this source repo, `agent-trigger-kit session-check` may exit 1 only for `agent-skills: plugin directory missing`; carry the accepted residual exactly.

---

## Files

- Modify: `skills/agent-operating-manual/cross-repo-reference-map.md`
  - Add the canonical `Cross-Repo Integration Intake` and `Adopting-repo overlap audit` doctrine.
  - Record the public-artifact hygiene refinement from plan review: local checkout paths stay in handoffs or private evidence.
- Modify: `tests/cross-repo-reference-map-smoke.sh`
  - Assert the source map and installed map expose the intake, allowed-write, overlap-audit, sandbox retry, and local-path hygiene tokens.
- Modify: `tests/install-smoke.sh`
  - Assert the default install imports the new cross-repo intake tokens.
- Modify: `.claude-plugin/plugin.json`
  - Bump version from `0.5.8` to `0.5.9`.
- Modify: `.claude-plugin/marketplace.json`
  - Bump plugin version from `0.5.8` to `0.5.9`.
- Modify: `ROADMAP.md`
  - Add the v0.5.9 Landed entry.
  - Remove the solved `Adopting-repo project-scope overlap audit` row and its lane mention.
  - Preserve `Skill context loading / retrieval strategy`, `F2 handoff-contract file split`, `Plan/spec lifecycle header convention text`, `Branch / worker lifecycle hygiene`, `Private superpowers plan artifact boundary`, and ATK template rows.

---

### Task 1: Red Smoke Coverage For Cross-Repo Intake

**Files:**
- Modify: `tests/cross-repo-reference-map-smoke.sh`
- Modify: `tests/install-smoke.sh`

**Interfaces:**
- Consumes: existing smoke helpers `require_contains` and `fail`.
- Produces: failing source and install smoke assertions for the v0.5.9 doctrine tokens.

- [x] **Step 1: Add source and installed map smoke assertions**

Apply this patch:

```diff
*** Begin Patch
*** Update File: tests/cross-repo-reference-map-smoke.sh
@@
 require_contains "$MAP" 'Do not create fake plugin directories'
 require_contains "$MAP" 'Do not commit machine-local MCP'
 require_contains "$MAP" 'branch-local proposal text'
+require_contains "$MAP" 'Cross-Repo Integration Intake'
+require_contains "$MAP" 'Allowed write surface'
+require_contains "$MAP" 'Adopting-repo overlap audit'
+require_contains "$MAP" 'local checkout paths stay in handoffs or private evidence'
+require_contains "$MAP" 'sanctioned outside-sandbox path'
+require_contains "$MAP" 'Cleanup is always opt-in'
 require_contains skills/agent-operating-manual/README.md 'cross-repo-reference-map.md'
 require_contains skills/agent-operating-manual/SKILL.md 'cross-repo-reference-map.md'
@@
 require_file "$INSTALLED"
 require_contains "$INSTALLED" 'operator-bootstrap'
 require_contains "$INSTALLED" 'Agent Trigger Kit'
 require_contains "$INSTALLED" '15-repo-memory.md'
+require_contains "$INSTALLED" 'Cross-Repo Integration Intake'
+require_contains "$INSTALLED" 'Allowed write surface'
+require_contains "$INSTALLED" 'Adopting-repo overlap audit'
+require_contains "$INSTALLED" 'local checkout paths stay in handoffs or private evidence'
+require_contains "$INSTALLED" 'sanctioned outside-sandbox path'
+require_contains "$INSTALLED" 'Cleanup is always opt-in'
 require_contains "$TMP/target/docs/imported-skills/agent-operating-manual/README.md" \
   'cross-repo-reference-map.md'
*** End Patch
```

- [x] **Step 2: Add install-smoke assertions for the default imported map**

Apply this patch:

```diff
*** Begin Patch
*** Update File: tests/install-smoke.sh
@@
 grep -Fq 'operator-bootstrap' "$MAP" || fail "reference map missing operator-bootstrap"
 grep -Fq 'Agent Trigger Kit' "$MAP" || fail "reference map missing Agent Trigger Kit"
 grep -Fq '15-repo-memory.md' "$MAP" || fail "reference map missing repo-memory routing"
+grep -Fq 'Cross-Repo Integration Intake' "$MAP" \
+  || fail "reference map missing Cross-Repo Integration Intake"
+grep -Fq 'Allowed write surface' "$MAP" \
+  || fail "reference map missing Allowed write surface"
+grep -Fq 'Adopting-repo overlap audit' "$MAP" \
+  || fail "reference map missing Adopting-repo overlap audit"
+grep -Fq 'local checkout paths stay in handoffs or private evidence' "$MAP" \
+  || fail "reference map missing local-path public artifact boundary"
+grep -Fq 'sanctioned outside-sandbox path' "$MAP" \
+  || fail "reference map missing sandbox credential retry boundary"
 grep -Fq 'cross-repo-reference-map.md' \
   "$TMP/target/docs/imported-skills/agent-operating-manual/README.md" \
   || fail "imported manual README missing reference map pointer"
*** End Patch
```

- [x] **Step 3: Commit the red smoke assertions before running clone-based smoke**

Run:

```bash
git add tests/cross-repo-reference-map-smoke.sh tests/install-smoke.sh
git commit -m "test: cover cross-repo integration intake"
```

Expected: commit succeeds. This red commit is required because `tests/install-smoke.sh` clones committed `HEAD`.

- [x] **Step 4: Run the source map smoke and confirm it fails red**

Run:

```bash
bash tests/cross-repo-reference-map-smoke.sh
```

Expected: exit 1 with:

```text
CROSS-REPO REFERENCE MAP SMOKE FAIL: skills/agent-operating-manual/cross-repo-reference-map.md missing token: Cross-Repo Integration Intake
```

- [x] **Step 5: Run the install smoke and confirm it fails red**

Run:

```bash
bash tests/install-smoke.sh
```

Expected: exit 1 with:

```text
SMOKE FAIL: reference map missing Cross-Repo Integration Intake
```

---

### Task 2: Implement Intake Doctrine, Metadata, And ROADMAP Closeout

**Files:**
- Modify: `skills/agent-operating-manual/cross-repo-reference-map.md`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `ROADMAP.md`

**Interfaces:**
- Consumes: failing smoke assertions from Task 1.
- Produces: installed v0.5.9 doctrine and durable ROADMAP closure without cross-repo edits.

- [x] **Step 1: Add the cross-repo intake and adopting-repo audit doctrine**

Apply this patch:

```diff
*** Begin Patch
*** Update File: skills/agent-operating-manual/cross-repo-reference-map.md
@@
 - MCP tooling is not canonical memory; repo-owned files remain the durable
   source of truth for future agents.
+
+## Cross-Repo Integration Intake
+
+Before changing another repo, or deciding that portable doctrine should be
+applied there, produce a compact intake packet. The packet is routing evidence,
+not permission to edit every repo it names.
+
+### Intake Packet
+
+- **Source repo / source object:** doctrine, spec, plan, PR, tag, rule, or
+  review finding that triggered the cross-repo question.
+- **Target repo / target head:** public repo name, branch, base, head, and
+  target identifier. Public summaries may name repo/head identifiers, but
+  local checkout paths stay in handoffs or private evidence; do not commit
+  machine-local paths, usernames, or private evidence to public artifacts.
+- **Current entrypoints:** AGENTS.md, CLAUDE.md, GEMINI.md, README pointers,
+  installed skill pointers, local plugin or skill wrappers, and repo-specific
+  conventions addenda.
+- **Installed source state:** `.agent-skills/pin`, plugin manifest or
+  marketplace metadata, generated imports, and whether updates come from
+  source doctrine, installer rerun, or local policy.
+- **Mechanism surfaces:** Agent Trigger Kit hooks, validators, session-check
+  and closeout behavior, outcome-store state, MCP or index configuration, and
+  harness-specific escalation or credential boundaries.
+- **Public artifact boundary:** evidence that is public-safe, evidence that
+  must remain private, and the durable public summary location.
+- **Ownership disposition:** one of `agent-skills`, `operator-bootstrap`,
+  `Agent Trigger Kit`, `adopting repo`, `MCP / local tooling`, or
+  `defer with owner`.
+- **Allowed write surface:** exact files or repos that may be changed in the
+  current train; every other repo remains read-only.
+- **Verification / residual plan:** cheap probes, expected gaps, and accepted
+  residual owners.
+
+If sandbox credential or remote metadata probes fail, retry the same minimal
+command through the sanctioned outside-sandbox path when policy permits before
+declaring a credential blocker. If policy blocks the retry, report the gap as
+policy-blocked evidence instead of routing around it.
+
+### Adopting-repo overlap audit
+
+Run this audit read-only before adopter cleanup, migration, or local rule
+replacement. It answers whether a target repo already has local rules that
+overlap with `agent-skills`, and where each overlap belongs.
+
+Audit these surfaces:
+
+- entrypoints: AGENTS.md, CLAUDE.md, GEMINI.md, README, plugin marketplace
+  pointers, and local command wrappers;
+- imported skills or generated copies under the target repo;
+- `.agent-skills/pin`, install metadata, plugin manifests, marketplace
+  entries, and default or optional skill lists;
+- local skill wrappers, project-scope skills, trigger rules, Cursor / Gemini /
+  Claude / Codex pointers, and Agent Trigger Kit trigger layers;
+- repo memory index, lesson / audit / status files, review logs, domain
+  playbooks, and private evidence locations;
+- release / PR flow, branch protections, tag / publish surfaces, and whether
+  the repo is public.
+
+Classify each overlap as `Source doctrine update`, `Bootstrap propagation`,
+`Mechanism update`, `Repo-local keep`, `Private evidence boundary`, or
+`No action`. Cleanup is always opt-in. The audit may recommend deleting
+duplicate local rules or generated residue, but implementation must stop for a
+separate approval-bound plan before changing adopter-owned files.
+
 ## Do Not Do

 - Do not edit generated imported copies in an adopting repo as a substitute for
*** End Patch
```

- [x] **Step 2: Bump plugin metadata to 0.5.9**

Apply this patch:

```diff
*** Begin Patch
*** Update File: .claude-plugin/plugin.json
@@
-  "version": "0.5.8",
+  "version": "0.5.9",
*** Update File: .claude-plugin/marketplace.json
@@
-      "version": "0.5.8",
+      "version": "0.5.9",
*** End Patch
```

- [x] **Step 3: Add the ROADMAP Landed entry and retire the solved overlap row**

Apply this patch:

```diff
*** Begin Patch
*** Update File: ROADMAP.md
@@
 - v0.5.8: public PR / release train discipline adds public train branch,
   hosted PR / local equivalent routing, merge-shape selection, version-only
   evidence preservation, post-push closeout examples, and release choice
   surfacing after install-facing merges. The release remains batched:
   v0.5.7 and v0.5.8 install-facing content require a later §3.2 tag before
   non-dev adopter delivery.
+- v0.5.9: Cross-Repo Integration Intake adds a compact read-only packet,
+  Allowed write surface field, and Adopting-repo overlap audit to the
+  cross-repo reference map, routes operator-bootstrap and Agent Trigger Kit
+  coordination without editing either repo, and records that v0.5.7, v0.5.8,
+  and v0.5.9 install-facing content require a later §3.2 tag before non-dev
+  adopter delivery.
@@
-- **Trigger Surface / Context Loading:** `Skill context loading / retrieval
-  strategy`, `F2 handoff-contract file split`, `Adopting-repo project-scope
-  overlap audit`, and `Plan/spec lifecycle header convention text`. This lane
-  owns rule discovery, trigger wording, context-load reduction, and the
-  doctrine / ATK / adopting-repo split for generated or local trigger surfaces.
+- **Trigger Surface / Context Loading:** `Skill context loading / retrieval
+  strategy`, `F2 handoff-contract file split`, and `Plan/spec lifecycle header
+  convention text`. This lane owns rule discovery, trigger wording,
+  context-load reduction, and the doctrine / ATK / adopting-repo split for
+  generated or local trigger surfaces.
@@
-| agent-skills installer / adoption | Adopting-repo project-scope overlap audit | agent-skills / Agent Trigger Kit | Before any install-time cleanup or migration, define a read-only audit for project-scope skills, trigger rules, playbooks, and entrypoint pointers that overlap or conflict with agent-skills; cleanup / adjustment must be explicit opt-in so ordinary install does not silently rewrite adopter-owned doctrine. |
*** End Patch
```

- [x] **Step 4: Commit implementation before green clone-based smoke**

Run:

```bash
git add skills/agent-operating-manual/cross-repo-reference-map.md .claude-plugin/plugin.json .claude-plugin/marketplace.json ROADMAP.md
git commit -m "docs: add cross-repo integration intake"
```

Expected: commit succeeds. Do not include the plan file in this implementation commit.

- [x] **Step 5: Run the source map smoke and confirm it passes**

Run:

```bash
bash tests/cross-repo-reference-map-smoke.sh
```

Expected:

```text
cross-repo reference map smoke ok
```

- [x] **Step 6: Run the install smoke and confirm it passes**

Run:

```bash
bash tests/install-smoke.sh
```

Expected:

```text
install smoke ok
```

---

### Task 3: Full Verification And Review Handoff

**Files:**
- Modify: `docs/superpowers/plans/2026-07-08-cross-repo-integration-intake.md`

**Interfaces:**
- Consumes: Task 1 red commit and Task 2 implementation commit.
- Produces: verification evidence and a paste-ready `review-needed` handoff.

- [x] **Step 1: Verify branch and changed-file scope**

Run:

```bash
git status -sb
git diff --name-only origin/main..HEAD
```

Expected branch prefix:

```text
## spec/v0.5.9-cross-repo-intake...origin/main [ahead
```

Expected changed files, sorted:

```text
.claude-plugin/marketplace.json
.claude-plugin/plugin.json
ROADMAP.md
docs/superpowers/plans/2026-07-08-cross-repo-integration-intake.md
docs/superpowers/specs/2026-07-07-cross-repo-integration-intake-design.md
skills/agent-operating-manual/cross-repo-reference-map.md
tests/cross-repo-reference-map-smoke.sh
tests/install-smoke.sh
```

- [x] **Step 2: Verify no cross-repo or release action happened**

Run:

```bash
git tag --points-at HEAD
git ls-remote --heads origin spec/v0.5.9-cross-repo-intake
git ls-remote --tags origin v0.5.9
```

Expected:

```text
```

All three commands print no lines. If a command cannot reach the remote because sandbox policy blocks network or credential access, retry the same minimal command through the sanctioned outside-sandbox path when policy permits, then report either the verified result or `blocked_by_policy`.

- [x] **Step 3: Run full local gates**

Run:

```bash
bash tests/cross-repo-reference-map-smoke.sh
bash tests/install-smoke.sh
git diff --check origin/main..HEAD
```

Expected:

```text
cross-repo reference map smoke ok
install smoke ok
```

`git diff --check` prints no output and exits 0.

- [x] **Step 4: Run placeholder and public-artifact hygiene scans**

Run:

```bash
rg -n 'T[B]D|T[O]DO|FILL M[E]|P[L]ACEHOLDER|X[X]X|REPLACE M[E]|/U[s]ers/|/p[r]ivate/|j[a]ckchou' docs/superpowers/plans/2026-07-08-cross-repo-integration-intake.md docs/superpowers/specs/2026-07-07-cross-repo-integration-intake-design.md skills/agent-operating-manual/cross-repo-reference-map.md ROADMAP.md
```

Expected: no matches. `rg` exits 1 for a clean no-match scan; that exit code is
the passing condition here. The owner-name token is allowed only inside existing
committed metadata owner names; this scan path intentionally avoids metadata
JSON.

- [x] **Step 5: Run the implementation token scan without plan/spec self-match**

Run:

```bash
for token in \
  'Cross-Repo Integration Intake' \
  'Allowed write surface' \
  'Adopting-repo overlap audit' \
  'local checkout paths stay in handoffs or private evidence' \
  'sanctioned outside-sandbox path' \
  'Cleanup is always opt-in' \
  'operator-bootstrap' \
  'Agent Trigger Kit' \
  'Branch / worker lifecycle hygiene' \
  'Private superpowers plan artifact boundary' \
  'Skill context loading / retrieval strategy' \
  'v0.5.9' \
  '0.5.9'
do
  count="$(rg -n -F "$token" ROADMAP.md skills tests README.md .claude-plugin | wc -l | tr -d ' ')"
  printf '%s %s\n' "$count" "$token"
  [ "$count" -gt 0 ] || exit 1
done
```

Expected: every token prints a positive count. The scan path intentionally excludes `docs/superpowers/plans/**` and `docs/superpowers/specs/**` so the plan and spec cannot mask a missing implementation.

- [x] **Step 6: Run source-repo session closeout**

Run:

```bash
agent-trigger-kit session-check --closeout
```

Expected: exit 1 is acceptable only when the trigger-layer failure is:

```text
agent-skills: plugin directory missing
```

Expected unmarked outcome events:

```text
None
```

Carry this accepted residual exactly:

```text
ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up
```

- [x] **Step 7: Commit verification checkbox ticks**

Run:

```bash
git add docs/superpowers/plans/2026-07-08-cross-repo-integration-intake.md
git commit -m "docs: mark cross-repo intake verification"
```

Expected: commit succeeds and changes only checkbox marks in this plan file.

- [ ] **Step 8: Derive review handoff tip**

Run:

```bash
git rev-parse --short HEAD
git rev-parse HEAD
```

Expected: record both values in the handoff. Use the latest reviewed plan tip as `Prev reviewed tip` in the review request; for this plan execution that is the plan commit after plan review passes, not the spec commit.

- [ ] **Step 9: Emit the review-needed handoff**

Use this structure, filling the final hashes and verification facts from the commands above:

```text
Status: review-needed
Target repo: CCC0509/agent-skills
Target: v0.5.9 cross-repo integration intake implementation @ <HEAD> on branch spec/v0.5.9-cross-repo-intake (spec 739b3f3, base 2881931 = origin/main)
Required user text: n/a
User action: self-review -> to-reviewer
Next agent action: run full review of the v0.5.9 implementation, checking that cross-repo work stayed read-only, local checkout paths are excluded from committed public artifacts, the adopting-repo overlap audit is source-doctrine only, ROADMAP rows were retired/preserved correctly, metadata is 0.5.9 without tag/publish/branch cleanup, and the release batch remains deferred.
Blockers: none
Accepted residuals: pending batched release for v0.5.7 + v0.5.8 + v0.5.9 install-facing content / recorded in ROADMAP Landed entry, requires later section 3.2 tag before non-dev adopter delivery / owner: next release train; Branch / worker lifecycle hygiene / branch cleanup not authorized by this train / owner: future branch-worker lifecycle train; operator-bootstrap propagation / route-only residual, no external repo edited / owner: operator-bootstrap follow-up; Agent Trigger Kit mechanism coordination incl. root-source boundary / no fake plugin directory, no validator/session-check changes / owner: Agent Trigger Kit follow-up; Private superpowers plan artifact boundary / deferred, no files moved / owner: future private-plan boundary spec; ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up

Review: full
Focus: cross-repo read-only boundary, local-path public-artifact hygiene, adopting-repo overlap audit closure, ROADMAP preservation, metadata 0.5.9 without release action, and deferred release batch
Prev reviewed tip: <latest reviewed implementation-plan tip>
```

---

## Plan Self-Review

- Spec coverage: the plan implements the canonical home, intake packet, adopting-repo overlap audit, operator-bootstrap / ATK route-only coordination, public repo propagation deferral, branch cleanup deferral, smoke coverage, metadata bump, and ROADMAP closeout.
- Review advisory coverage: Task 2 Step 1 records that local checkout paths stay in handoffs or private evidence and must not be committed to public artifacts; Task 3 Step 4 verifies the committed public files do not contain local path or username evidence.
- Scope boundary: no external repo edits, no branch deletion, no push or PR, no tag, no publish, no private artifact move, and no Agent Trigger Kit mechanism change.
- Clone-based smoke ordering: Task 1 commits red tests before red install-smoke; Task 2 commits implementation before green install-smoke; Task 3 checkbox ticks ride a separate verification commit.
