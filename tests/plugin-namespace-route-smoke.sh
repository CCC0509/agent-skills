#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "PLUGIN NAMESPACE ROUTE SMOKE FAIL: $1" >&2
  exit 1
}

OLD_ID='agent-skills@''agent-skills'

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

first_name_value() {
  local file="$1"
  sed -n 's/^[[:space:]]*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$file" \
    | head -1
}

first_version_value() {
  local file="$1"
  sed -n 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$file" \
    | head -1
}

marketplace_plugin_name() {
  awk '
    /"plugins"[[:space:]]*:/ { in_plugins=1; next }
    in_plugins && /"name"[[:space:]]*:/ {
      line=$0
      sub(/^.*"name"[[:space:]]*:[[:space:]]*"/, "", line)
      sub(/".*$/, "", line)
      print line
      exit
    }
  ' .claude-plugin/marketplace.json
}

marketplace_plugin_version() {
  awk '
    /"plugins"[[:space:]]*:/ { in_plugins=1; next }
    in_plugins && /"version"[[:space:]]*:/ {
      line=$0
      sub(/^.*"version"[[:space:]]*:[[:space:]]*"/, "", line)
      sub(/".*$/, "", line)
      print line
      exit
    }
  ' .claude-plugin/marketplace.json
}

[ "$(first_name_value .claude-plugin/marketplace.json)" = "ccc-agent-skills" ] \
  || fail "marketplace top-level name is not ccc-agent-skills"
[ "$(marketplace_plugin_name)" = "agent-skills" ] \
  || fail "marketplace plugin entry name changed"
[ "$(first_name_value .claude-plugin/plugin.json)" = "agent-skills" ] \
  || fail "plugin entry name changed"
[ "$(first_version_value .claude-plugin/plugin.json)" = "0.5.16" ] \
  || fail "plugin manifest version is not 0.5.16"
[ "$(marketplace_plugin_version)" = "0.5.16" ] \
  || fail "marketplace plugin version is not 0.5.16"

require_contains README.md 'claude plugin marketplace add CCC0509/agent-skills --scope project'
require_contains README.md 'claude plugin install agent-skills@ccc-agent-skills --scope project'
require_not_contains README.md "$OLD_ID"
require_contains CHANGELOG.md 'v0.5.16: Claude plugin namespace route repair'
require_contains .claude-plugin/marketplace.json '"name": "ccc-agent-skills"'
require_contains .claude-plugin/marketplace.json '"name": "agent-skills"'
require_contains .claude-plugin/plugin.json '"name": "agent-skills"'
require_not_contains .claude-plugin/plugin.json '"name": "ccc-agent-skills"'

if grep -RFn -- "$OLD_ID" README.md AGENTS.md CLAUDE.md GEMINI.md .claude-plugin tests skills; then
  fail "old installed id remains in live source"
fi

echo "plugin namespace route smoke ok"
