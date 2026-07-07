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
  section="$(awk '/^## Must Read/{flag=1; next} flag && /^[[:space:]]*$/{exit} flag{print}' "$file")"
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
