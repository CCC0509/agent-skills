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
ROADMAP="ROADMAP.md"

require_file "$AOM"
require_file "$RELAY"
require_file "$ROADMAP"
require_file "$CHANGELOG"

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

require_contains "$CHANGELOG" 'v0.5.10: Fresh session continuity'
require_contains_normalized "$CHANGELOG" 'v0.5.7, v0.5.8, v0.5.9, and v0.5.10 install-facing content require a later §3.2 tag'
require_not_contains "$CHANGELOG" '## Candidate Lanes'
require_not_contains "$CHANGELOG" '## Extraction Candidates'
require_contains "$ROADMAP" 'Public release history now lives in [CHANGELOG.md](CHANGELOG.md).'
require_contains "$ROADMAP" 'compatibility pointer'

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
