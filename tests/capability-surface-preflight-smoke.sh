#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "CAPABILITY SURFACE PREFLIGHT SMOKE FAIL: $1" >&2
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
CHANGELOG="CHANGELOG.md"

require_file "$AOM"
require_file "$RELAY"
require_file "$CHANGELOG"

require_contains "$AOM" 'Capability/surface preflight'
require_contains "$AOM" 'Handoff surface parse'
require_contains "$AOM" 'Capability inventory'
require_contains "$AOM" 'Runtime smoke where safe'
require_contains "$AOM" 'Presence-only auth visibility'
require_contains "$AOM" 'Policy and egress check'
require_contains "$AOM" 'Execution disposition'
require_contains "$AOM" 'host or sandbox checks are also surface-sensitive, and relay text is another source of one-surface requirements'
require_contains "$AOM" 'Organization names are also forbidden in `Execution surface:`'
require_contains "$AOM" 'status visible: a status-only check is available and safe from the executing surface, but has not yet produced a `present` or `missing` result'
require_contains "$AOM" 'Missing capability is a capability gap, not agent error.'
require_contains "$AOM" 'Help text, binary discovery, a command path, or launcher presence proves only presence.'
require_contains "$AOM" 'Host auth does not prove sandbox auth.'
require_contains "$AOM" 'External-service egress is route authorization, not merely login status.'
require_contains "$AOM" 'Single-surface fallback requires a reviewed plan, reviewed plan amendment, or explicit user route decision naming the replacement surface.'
require_contains "$AOM" 'One multi-surface role passing does not satisfy another role.'
require_contains "$AOM" 'Preflight results are immediate, surface-bound, and time-bound.'
require_contains "$AOM" 'No new machine-readable outcome tokens are introduced by capability/surface preflight.'
require_contains "$AOM" '`Execution route:` remains governed by the existing route display rule.'
require_contains "$AOM" 'Ordinary low-risk docs work does not need a full capability/surface preflight'
require_not_contains "$AOM" 'not_logged_in'
require_not_contains "$AOM" 'present, missing, visible, blocked, or planned'

require_contains "$RELAY" 'capability/surface preflight'
require_contains "$RELAY" 'surface-sensitive'
require_contains "$RELAY" '10-model-dispatch.md'

require_contains "$CHANGELOG" 'v0.5.14: Capability/surface preflight'
require_contains .claude-plugin/plugin.json '"version": "0.5.15"'
require_contains .claude-plugin/marketplace.json '"version": "0.5.15"'

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

require_contains "$INSTALLED_AOM" 'Capability/surface preflight'
require_contains "$INSTALLED_AOM" 'Handoff surface parse'
require_contains "$INSTALLED_AOM" 'Capability inventory'
require_contains "$INSTALLED_AOM" 'Runtime smoke where safe'
require_contains "$INSTALLED_AOM" 'Presence-only auth visibility'
require_contains "$INSTALLED_AOM" 'Policy and egress check'
require_contains "$INSTALLED_AOM" 'Execution disposition'
require_contains "$INSTALLED_AOM" 'host or sandbox checks are also surface-sensitive, and relay text is another source of one-surface requirements'
require_contains "$INSTALLED_AOM" 'Organization names are also forbidden in `Execution surface:`'
require_contains "$INSTALLED_AOM" 'status visible: a status-only check is available and safe from the executing surface, but has not yet produced a `present` or `missing` result'
require_contains "$INSTALLED_AOM" 'Missing capability is a capability gap, not agent error.'
require_contains "$INSTALLED_AOM" 'External-service egress is route authorization, not merely login status.'
require_contains "$INSTALLED_AOM" 'Single-surface fallback requires a reviewed plan, reviewed plan amendment, or explicit user route decision naming the replacement surface.'
require_contains "$INSTALLED_AOM" 'One multi-surface role passing does not satisfy another role.'
require_contains "$INSTALLED_AOM" 'Preflight results are immediate, surface-bound, and time-bound.'
require_contains "$INSTALLED_AOM" 'No new machine-readable outcome tokens are introduced by capability/surface preflight.'
require_contains "$INSTALLED_AOM" '`Execution route:` remains governed by the existing route display rule.'
require_contains "$INSTALLED_AOM" 'Ordinary low-risk docs work does not need a full capability/surface preflight'
require_not_contains "$INSTALLED_AOM" 'not_logged_in'
require_not_contains "$INSTALLED_AOM" 'present, missing, visible, blocked, or planned'
require_contains "$INSTALLED_RELAY" 'capability/surface preflight'
require_contains "$INSTALLED_RELAY" 'surface-sensitive'

[ "$(cat "$TMP/target/.agent-skills/pin")" = "CCC0509/agent-skills@v0.5.15" ] \
  || fail "pin did not resolve v0.5.15"

echo "capability surface preflight smoke ok"
