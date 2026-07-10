#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "COMPLETION REPORT RELAY STAGE SMOKE FAIL: $1" >&2
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

require_contains_normalized() {
  local file="$1"
  local token="$2"
  local haystack
  local needle

  haystack="$(tr '\n\t' '  ' < "$file" | sed 's/[[:space:]][[:space:]]*/ /g')"
  needle="$(printf '%s' "$token" | tr '\n\t' '  ' | sed 's/[[:space:]][[:space:]]*/ /g')"
  [[ "$haystack" == *"$needle"* ]] || fail "$file missing token: $token"
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
CHANGELOG="CHANGELOG.md"

require_file "$AOM"
require_file "$RELAY"
require_file "$CHANGELOG"

require_contains "$AOM" 'Completion-report stage:'
require_contains "$AOM" 'Completed task: <specific completed task or object, with compact durable evidence pointer>'
require_contains "$AOM" 'Recommended next task: <one recommended next task, or n/a>'
require_contains "$AOM" 'These are stage lines, not relay fields.'
require_contains_normalized "$AOM" 'The stage does not add a relay field or a `Status:` value.'
require_contains "$AOM" '`Recommended next task:` is advisory orientation.'
require_contains "$AOM" '`Required user text:` remains the only exact-approval text home.'
require_contains "$AOM" '`Accepted residuals:` remains the non-blocking residual home.'
require_contains_normalized "$AOM" '`Execution route:` remains governed by the existing route display rule.'
require_contains "$AOM" 'inside the same fenced `text` copy block above `Status:`'
require_contains "$AOM" 'approval menu can follow the stage'
require_contains_normalized "$AOM" '`Recommended next task:` may identify one preferred approval item, but it does not approve it.'
require_contains "$AOM" '`Status: review-needed`'
require_contains "$AOM" '`Status: ready-for-user-approval`'
require_contains "$AOM" '`Status: ready-for-continuation`'
require_contains "$AOM" '`Status: complete-no-action-needed`'
require_contains "$AOM" '`Recommended next task: n/a`'
require_contains_normalized "$AOM" 'differs from `Next agent action:` without contradicting it'
require_contains_normalized "$AOM" 'the difference is a blocker'
require_not_contains "$AOM" 'Status: completion-report'
require_not_contains "$AOM" 'completion-report-needed'
require_not_contains "$AOM" 'completion-report-complete'
require_not_contains "$AOM" 'Superpowers / repo-governance'
require_not_contains "$AOM" 'bounded Superpowers'

require_contains "$RELAY" 'completion-report closeouts'
require_contains_normalized "$RELAY" 'stage lines before the relay block'
require_contains "$RELAY" 'not relay fields'

require_contains "$CHANGELOG" 'v0.5.13: Completion-report relay stage'
require_contains .claude-plugin/plugin.json '"version": "0.5.16"'
require_contains .claude-plugin/marketplace.json '"version": "0.5.16"'

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

require_contains "$INSTALLED_AOM" 'Completion-report stage:'
require_contains "$INSTALLED_AOM" 'Completed task: <specific completed task or object, with compact durable evidence pointer>'
require_contains "$INSTALLED_AOM" 'Recommended next task: <one recommended next task, or n/a>'
require_contains "$INSTALLED_AOM" 'These are stage lines, not relay fields.'
require_contains_normalized "$INSTALLED_AOM" 'The stage does not add a relay field or a `Status:` value.'
require_contains "$INSTALLED_AOM" '`Recommended next task:` is advisory orientation.'
require_contains "$INSTALLED_AOM" 'inside the same fenced `text` copy block above `Status:`'
require_contains "$INSTALLED_AOM" 'approval menu can follow the stage'
require_contains_normalized "$INSTALLED_AOM" 'differs from `Next agent action:` without contradicting it'
require_contains_normalized "$INSTALLED_AOM" 'the difference is a blocker'
require_not_contains "$INSTALLED_AOM" 'Status: completion-report'
require_not_contains "$INSTALLED_AOM" 'completion-report-needed'
require_not_contains "$INSTALLED_AOM" 'completion-report-complete'
require_not_contains "$INSTALLED_AOM" 'Superpowers / repo-governance'
require_not_contains "$INSTALLED_AOM" 'bounded Superpowers'
require_contains "$INSTALLED_RELAY" 'completion-report closeouts'
require_contains_normalized "$INSTALLED_RELAY" 'stage lines before the relay block'
require_contains "$INSTALLED_RELAY" 'not relay fields'

[ "$(cat "$TMP/target/.agent-skills/pin")" = "CCC0509/agent-skills@v0.5.16" ] \
  || fail "pin did not resolve v0.5.16"

echo "completion report relay stage smoke ok"
