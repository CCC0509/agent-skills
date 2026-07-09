#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "PUBLIC TRAIN FRESH GATE SMOKE FAIL: $1" >&2
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

CHANGE="skills/agent-operating-manual/25-change-discipline.md"
DISPATCH="skills/agent-operating-manual/10-model-dispatch.md"
CHANGELOG="CHANGELOG.md"

require_file "$CHANGE"
require_file "$DISPATCH"
require_file "$CHANGELOG"

require_contains "$CHANGE" '## §3.4 Reviewed-Range Carry-Forward And Universal Fresh Gate Discipline'
require_contains "$CHANGE" 'Carry-forward transfers review only; it never transfers approval.'
require_contains_normalized "$CHANGE" 'Input-object approvals name a fully known input object and may create platform-assigned output identifiers that are recorded after execution.'
require_contains "$CHANGE" 'Unknown future objects remain hard stops before approval.'
require_contains_normalized "$CHANGE" 'Routine hosted metadata does not invalidate carry-forward when it does not change the contract.'
require_contains "$CHANGE" 'agent-skills preserves reviewed commits by default.'
require_contains "$CHANGE" 'stock-scanner remains a repo-specific adapter and comparison point;'
require_contains_normalized "$CHANGE" 'Fresh gate action classes: read-only/planning, edit, branch, push, PR open/update, merge, tag, release/publish, cleanup.'
require_contains_normalized "$CHANGE" '`freshness-unverified` is the only freshness-gap outcome label.'
require_contains_normalized "$CHANGE" 'Local-only edits under `freshness-unverified` need a new fresh gate before any publication action.'
require_contains "$CHANGE" 'Publication actions may not proceed under `freshness-unverified`.'
require_not_contains "$CHANGE" 'freshness_unavailable'
require_not_contains "$CHANGE" 'freshness_unknown'

require_contains_normalized "$DISPATCH" 'Reviewed-range carry-forward, approval menus, merge-shape policy, and universal fresh gates live in `25-change-discipline.md` §3.4.'

require_contains "$CHANGELOG" 'v0.5.12: Public train fresh gates'
require_contains .claude-plugin/plugin.json '"version": "0.5.13"'
require_contains .claude-plugin/marketplace.json '"version": "0.5.13"'

copy_current_source_to_tmp_repo
VER="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  "$TMP/src/.claude-plugin/plugin.json" | head -1)"
git -C "$TMP/src" tag -f "v$VER" >/dev/null

mkdir "$TMP/target"
git -C "$TMP/target" init -q
printf '# AGENTS.md\nexisting content\n' > "$TMP/target/AGENTS.md"
bash "$TMP/src/install.sh" "$TMP/target"

INSTALLED_CHANGE="$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md"
INSTALLED_DISPATCH="$TMP/target/docs/imported-skills/agent-operating-manual/10-model-dispatch.md"
require_file "$INSTALLED_CHANGE"
require_file "$INSTALLED_DISPATCH"

require_contains "$INSTALLED_CHANGE" '## §3.4 Reviewed-Range Carry-Forward And Universal Fresh Gate Discipline'
require_contains "$INSTALLED_CHANGE" 'Carry-forward transfers review only; it never transfers approval.'
require_contains_normalized "$INSTALLED_CHANGE" 'Input-object approvals name a fully known input object and may create platform-assigned output identifiers that are recorded after execution.'
require_contains "$INSTALLED_CHANGE" 'Unknown future objects remain hard stops before approval.'
require_contains_normalized "$INSTALLED_CHANGE" '`freshness-unverified` is the only freshness-gap outcome label.'
require_contains "$INSTALLED_CHANGE" 'Publication actions may not proceed under `freshness-unverified`.'
require_not_contains "$INSTALLED_CHANGE" 'freshness_unavailable'
require_not_contains "$INSTALLED_CHANGE" 'freshness_unknown'
require_contains_normalized "$INSTALLED_DISPATCH" 'Reviewed-range carry-forward, approval menus, merge-shape policy, and universal fresh gates live in `25-change-discipline.md` §3.4.'

[ "$(cat "$TMP/target/.agent-skills/pin")" = "CCC0509/agent-skills@v0.5.13" ] \
  || fail "pin did not resolve v0.5.12"

echo "public train fresh gate smoke ok"
