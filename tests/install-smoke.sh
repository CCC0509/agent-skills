#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail() { echo "SMOKE FAIL: $1" >&2; exit 1; }

git clone -q "$ROOT" "$TMP/src"
VER="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  "$TMP/src/.claude-plugin/plugin.json" | head -1)"
git -C "$TMP/src" tag -f "v$VER" >/dev/null

mktarget() {
  rm -rf "$TMP/target"; mkdir "$TMP/target"; git -C "$TMP/target" init -q
  for f in CLAUDE.md AGENTS.md GEMINI.md; do
    printf '# %s\nexisting content\n' "$f" > "$TMP/target/$f"
  done
}

# 1) tagged install
mktarget
bash "$TMP/src/install.sh" "$TMP/target"
for s in agent-operating-manual multi-angle-review; do
  [ -f "$TMP/target/docs/imported-skills/$s/SKILL.md" ] || fail "missing $s/SKILL.md"
  [ -f "$TMP/target/docs/imported-skills/$s/.managed-by-agent-skills" ] || fail "missing $s sentinel"
done
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
[ ! -e "$TMP/target/docs/imported-skills/skill-authoring" ] \
  || fail "skill-authoring installed by default"
[ "$(cat "$TMP/target/.agent-skills/pin")" = "CCC0509/agent-skills@v$VER" ] || fail "pin content"
[ -f "$TMP/target/docs/agent-memory-index.md" ] || fail "missing agent-memory-index.md"
grep -Fq '# Agent Memory Index' "$TMP/target/docs/agent-memory-index.md" \
  || fail "agent-memory-index missing heading"
grep -Fq "\`LESSONS.md\`: not created yet; create it at the repo" \
  "$TMP/target/docs/agent-memory-index.md" \
  || fail "agent-memory-index missing not-yet-created LESSONS line"
[ ! -e "$TMP/target/LESSONS.md" ] || fail "LESSONS.md auto-created"
for f in CLAUDE.md AGENTS.md GEMINI.md; do
  [ "$(grep -Fc '<!-- agent-skills:begin -->' "$TMP/target/$f")" = 1 ] || fail "$f begin marker"
  [ "$(grep -Fc '<!-- agent-skills:end -->' "$TMP/target/$f")" = 1 ] || fail "$f end marker"
  grep -Fq '升級時重跑 install.sh 會替換本區塊' "$TMP/target/$f" \
    || fail "$f missing upgrade marker notice"
  grep -q 'existing content' "$TMP/target/$f" || fail "$f lost existing content"
  grep -Fq 'docs/imported-skills/agent-operating-manual/SKILL.md' "$TMP/target/$f" \
    || fail "$f missing agent-operating-manual pointer"
  grep -Fq 'docs/imported-skills/multi-angle-review/SKILL.md' "$TMP/target/$f" \
    || fail "$f missing multi-angle-review pointer"
  grep -Fq 'ready-for-user-approval' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing merge relay signal"
  grep -Fq 'complete-no-action-needed' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing completion relay signal"
  grep -Fq 'Co-occurrence tie-breaker' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing Review/Status tie-breaker"
  grep -Fq 'Target repo: <owner/repo or absolute local repo path, or n/a>' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing target repo relay field"
  grep -Fq 'User action: <self-review | to-reviewer | to-agent | reply-required-text | none>[ -> ...]' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing user action relay field"
  grep -Fq 'Full-context copy rule' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing full-context copy rule"
  grep -Fq 'User action consistency rule' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing user action consistency rule"
  grep -Fq 'Pre-handoff self-check' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing pre-handoff self-check"
  grep -Fq 'current chat is waiting for a user reply' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing reply-required-text human prompt check"
  grep -Fq 'executable approval / continuation handoff' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing execution-route gating check"
  grep -Fq 'exactly one `text` fenced copy block' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing exactly-one copy block check"
  grep -Fq 'three-line `Review:` contract' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing review contract copy check"
  grep -Fq 'Relay readiness rule' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing not-ready relay authority rule"
  grep -Fq 'Normative control-contract changes' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing control-contract review gate"
  grep -Fq 'Execution route: <direct-apply | plan-first | subagent-driven | inline-execution>' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing execution route contract"
  grep -Fq 'Accepted residuals: <none | short finding label + disposition + durable tracker/owner>' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing accepted residuals contract"
  grep -Fq 'sanctioned sandbox escalation 或 outside-sandbox retry' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing sandbox escalation retry rule"
  grep -Fq 'Trigger Kit durable no-report taxonomy' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing blocked_by_policy canonical home"
  grep -Fq 'exact wording lives in Required user text' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md" \
    || fail "$f imported manual missing approval-text home rule"
  grep -Fq 'plan/rule-review / fix-confirmation' "$TMP/target/$f" \
    || fail "$f pointer missing plan/rule-review scenario"
  grep -Fq 'docs/agent-memory-index.md' "$TMP/target/$f" \
    || fail "$f missing repo memory index pointer"
  grep -Fq 'Closeout self-report and memory routing' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/15-repo-memory.md" \
    || fail "$f imported repo memory manual missing closeout routing"
  grep -Fq 'Memory closeout:' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/15-repo-memory.md" \
    || fail "$f imported repo memory manual missing memory closeout shape"
  grep -Fq 'Status memory update: <none | path + one-line reason>' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/15-repo-memory.md" \
    || fail "$f imported repo memory manual missing status memory update line"
  grep -Fq 'Mechanism evidence consumed: <none | source labels only>' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/15-repo-memory.md" \
    || fail "$f imported repo memory manual missing mechanism evidence line"
  grep -Fq 'Next-session seed: <none | status-memory path>' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/15-repo-memory.md" \
    || fail "$f imported repo memory manual missing next-session seed line"
  grep -Fq 'Obsidian-compatible markdown' \
    "$TMP/target/docs/imported-skills/agent-operating-manual/15-repo-memory.md" \
    || fail "$f imported repo memory manual missing obsidian-compatible boundary"
done

# 2) idempotency: second run must be byte-identical
SNAP1="$(cd "$TMP/target" && find . -path ./.git -prune -o -type f -print0 | sort -z | xargs -0 shasum)"
bash "$TMP/src/install.sh" "$TMP/target"
SNAP2="$(cd "$TMP/target" && find . -path ./.git -prune -o -type f -print0 | sort -z | xargs -0 shasum)"
[ "$SNAP1" = "$SNAP2" ] || fail "second install not idempotent"

# 3) v0.2-style managed block is replaced in place and gains memory pointer
mktarget
for f in CLAUDE.md AGENTS.md GEMINI.md; do
  cat > "$TMP/target/$f" <<'EOF'
# entry
before
<!-- agent-skills:begin -->
<!-- managed by agent-skills CCC0509/agent-skills@v0.2.0；手動編輯會在下次 install 被覆蓋 -->
非 trivial 任務（委派、選模型、驗證、何時停）先讀 [docs/imported-skills/agent-operating-manual/SKILL.md](docs/imported-skills/agent-operating-manual/SKILL.md)。
Read-only review（PR / commit range / plan/rule-review / fix-confirmation）套 [docs/imported-skills/multi-angle-review/SKILL.md](docs/imported-skills/multi-angle-review/SKILL.md)。
<!-- agent-skills:end -->
after
EOF
done
bash "$TMP/src/install.sh" "$TMP/target"
for f in CLAUDE.md AGENTS.md GEMINI.md; do
  [ "$(grep -Fc '<!-- agent-skills:begin -->' "$TMP/target/$f")" = 1 ] || fail "$f upgrade begin marker"
  [ "$(grep -Fc '<!-- agent-skills:end -->' "$TMP/target/$f")" = 1 ] || fail "$f upgrade end marker"
  grep -Fq '升級時重跑 install.sh 會替換本區塊' "$TMP/target/$f" \
    || fail "$f upgrade missing upgrade marker notice"
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

# 5) user-edited memory index survives reinstall
mktarget
mkdir -p "$TMP/target/docs"
printf '# My Custom Index\ncustom content\n' > "$TMP/target/docs/agent-memory-index.md"
bash "$TMP/src/install.sh" "$TMP/target"
grep -Fq 'custom content' "$TMP/target/docs/agent-memory-index.md" || fail "user index overwritten"
grep -Fq '# Agent Memory Index' "$TMP/target/docs/agent-memory-index.md" \
  && fail "starter clobbered user index"

# 6) broken memory-index symlink is not followed outside the target repo
mktarget
mkdir -p "$TMP/target/docs"
ln -s "$TMP/outside-index.md" "$TMP/target/docs/agent-memory-index.md"
bash "$TMP/src/install.sh" "$TMP/target"
[ -L "$TMP/target/docs/agent-memory-index.md" ] || fail "memory index symlink replaced"
[ ! -e "$TMP/outside-index.md" ] || fail "memory index symlink wrote outside target"

# 7) dirty source fails even with --dev
touch "$TMP/src/dirty.tmp"
if bash "$TMP/src/install.sh" "$TMP/target" --dev 2>"$TMP/err" ; then fail "dirty source accepted"; fi
grep -q source_dirty "$TMP/err" || fail "expected source_dirty"
rm "$TMP/src/dirty.tmp"

# 8) untagged without --dev fails; with --dev pins dev-<sha>
git -C "$TMP/src" commit -q --allow-empty -m tmp
if bash "$TMP/src/install.sh" "$TMP/target" 2>"$TMP/err"; then fail "untagged accepted"; fi
grep -q source_untagged "$TMP/err" || fail "expected source_untagged"
mktarget
bash "$TMP/src/install.sh" "$TMP/target" --dev 2>/dev/null
grep -q '@dev-' "$TMP/target/.agent-skills/pin" || fail "dev pin format"

# 9) release metadata mismatch fails
git -C "$TMP/src" tag -f v9.9.9 >/dev/null
if bash "$TMP/src/install.sh" "$TMP/target" 2>"$TMP/err"; then fail "metadata mismatch accepted"; fi
grep -q release_metadata_mismatch "$TMP/err" || fail "expected release_metadata_mismatch"

# 10) unmanaged destination fails
git -C "$TMP/src" tag -d v9.9.9 >/dev/null; git -C "$TMP/src" reset -q --hard HEAD~1
git -C "$TMP/src" tag -f "v$VER" >/dev/null
mktarget
mkdir -p "$TMP/target/docs/imported-skills/agent-operating-manual"
touch "$TMP/target/docs/imported-skills/agent-operating-manual/hand-authored.md"
if bash "$TMP/src/install.sh" "$TMP/target" 2>"$TMP/err"; then fail "unmanaged dest accepted"; fi
grep -q destination_exists_unmanaged "$TMP/err" || fail "expected destination_exists_unmanaged"

# 11) single-sided marker fails
mktarget
printf '<!-- agent-skills:begin -->\n' >> "$TMP/target/CLAUDE.md"
if bash "$TMP/src/install.sh" "$TMP/target" 2>"$TMP/err"; then fail "single-sided marker accepted"; fi
grep -q marker_mismatch "$TMP/err" || fail "expected marker_mismatch"

# 12) --create-entry creates named entry; other missing entries reported skipped
rm -rf "$TMP/target"; mkdir "$TMP/target"; git -C "$TMP/target" init -q
OUT="$(bash "$TMP/src/install.sh" "$TMP/target" --create-entry AGENTS.md)"
[ -f "$TMP/target/AGENTS.md" ] || fail "create-entry did not create AGENTS.md"
[ "$(grep -Fc '<!-- agent-skills:begin -->' "$TMP/target/AGENTS.md")" = 1 ] || fail "created AGENTS.md begin marker"
[ "$(grep -Fc '<!-- agent-skills:end -->' "$TMP/target/AGENTS.md")" = 1 ] || fail "created AGENTS.md end marker"
grep -Fq '升級時重跑 install.sh 會替換本區塊' "$TMP/target/AGENTS.md" \
  || fail "created AGENTS.md missing upgrade marker notice"
grep -Fq 'docs/agent-memory-index.md' "$TMP/target/AGENTS.md" \
  || fail "created AGENTS.md missing memory pointer"
[ -f "$TMP/target/docs/agent-memory-index.md" ] \
  || fail "create-entry missing memory index"
[ ! -f "$TMP/target/CLAUDE.md" ] || fail "CLAUDE.md created without --create-entry"
[ ! -f "$TMP/target/GEMINI.md" ] || fail "GEMINI.md created without --create-entry"
printf '%s\n' "$OUT" | grep -q 'skipped missing entry files:.*CLAUDE\.md' || fail "expected CLAUDE.md in skipped list"
printf '%s\n' "$OUT" | grep -q 'skipped missing entry files:.*GEMINI\.md' || fail "expected GEMINI.md in skipped list"

# 13) optional skill-authoring installs only when explicitly requested
mktarget
bash "$TMP/src/install.sh" "$TMP/target" --skills agent-operating-manual,multi-angle-review,skill-authoring
[ -f "$TMP/target/docs/imported-skills/skill-authoring/SKILL.md" ] \
  || fail "missing skill-authoring/SKILL.md"
[ -f "$TMP/target/docs/imported-skills/skill-authoring/.managed-by-agent-skills" ] \
  || fail "missing skill-authoring sentinel"
[ "$(grep -Fc 'docs/imported-skills/skill-authoring/SKILL.md' "$TMP/target/CLAUDE.md")" = 1 ] \
  || fail "CLAUDE.md missing skill-authoring pointer"
[ "$(grep -Fc 'docs/agent-memory-index.md' "$TMP/target/CLAUDE.md")" = 1 ] \
  || fail "CLAUDE.md missing memory pointer with skill-authoring"

echo "install smoke ok"
