#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "EXECUTION SURFACE RELAY SMOKE FAIL: $1" >&2
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

AOM="skills/agent-operating-manual/11-relay-fields.md"
RELAY="skills/handoff-relay/SKILL.md"
CHANGELOG="CHANGELOG.md"

require_file "$AOM"
require_file "$RELAY"
require_file "$CHANGELOG"

require_contains "$AOM" 'Execution surface: <any | codex-current-session | codex-fresh-session | codex-host-cli | claude-code-current-session | claude-code-fresh-session | claude-code-host-cli | user-executed | multi-surface: ...>'
require_contains "$AOM" 'Execution surface routes surface-sensitive work to the required runtime, sandbox, auth, or user-execution boundary.'
require_contains "$AOM" 'The field is optional for ordinary relay blocks and mandatory for new surface-sensitive handoffs.'
require_contains "$AOM" 'Missing, ambiguous, or conflicting `Execution surface:` is a blocker for surface-sensitive work.'
require_contains "$AOM" 'Older relay blocks without `Execution surface:` remain valid.'
require_contains "$AOM" 'Do not put model names, model aliases, intelligence labels, effort names, account names, or cost tiers in `Execution surface:`.'
require_contains "$AOM" 'Model choice belongs to capability-based model routing and the relevant model adapter.'
require_contains "$AOM" 'Single-surface requirements must not be broadened into multi-surface fallback without a reviewed plan or later user decision.'
require_contains "$AOM" 'If the named surface reports `tool_unavailable` or `blocked_by_policy`, record the evidence and stop at the appropriate route decision or blocker.'
require_contains "$AOM" 'User-observed GUI concerns about repeated auth failures, surprising retries, or no-progress loops are valid control-contract input.'
require_contains "$AOM" 'codex-current-session'
require_contains "$AOM" 'codex-fresh-session'
require_contains "$AOM" 'codex-host-cli'
require_contains "$AOM" 'claude-code-current-session'
require_contains "$AOM" 'claude-code-fresh-session'
require_contains "$AOM" 'claude-code-host-cli'
require_contains "$AOM" 'user-executed'
require_contains "$AOM" 'multi-surface:'
require_not_contains "$AOM" 'not_logged_in'

require_contains "$RELAY" 'Execution surface'
require_contains "$RELAY" 'surface-sensitive'
require_contains "$RELAY" '11-relay-fields.md'

require_contains "$CHANGELOG" 'v0.5.11: Execution surface relay field'
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

INSTALLED_AOM="$TMP/target/docs/imported-skills/agent-operating-manual/11-relay-fields.md"
INSTALLED_RELAY="$TMP/target/docs/imported-skills/handoff-relay/SKILL.md"
require_file "$INSTALLED_AOM"
require_file "$INSTALLED_RELAY"

require_contains "$INSTALLED_AOM" 'Execution surface: <any | codex-current-session | codex-fresh-session | codex-host-cli | claude-code-current-session | claude-code-fresh-session | claude-code-host-cli | user-executed | multi-surface: ...>'
require_contains "$INSTALLED_AOM" 'Execution surface routes surface-sensitive work to the required runtime, sandbox, auth, or user-execution boundary.'
require_contains "$INSTALLED_AOM" 'The field is optional for ordinary relay blocks and mandatory for new surface-sensitive handoffs.'
require_contains "$INSTALLED_AOM" 'Do not put model names, model aliases, intelligence labels, effort names, account names, or cost tiers in `Execution surface:`.'
require_contains "$INSTALLED_AOM" 'Model choice belongs to capability-based model routing and the relevant model adapter.'
require_contains "$INSTALLED_AOM" 'If the named surface reports `tool_unavailable` or `blocked_by_policy`, record the evidence and stop at the appropriate route decision or blocker.'
require_contains "$INSTALLED_AOM" 'User-observed GUI concerns about repeated auth failures, surprising retries, or no-progress loops are valid control-contract input.'
require_contains "$INSTALLED_RELAY" 'Execution surface'
require_contains "$INSTALLED_RELAY" 'surface-sensitive'
require_not_contains "$INSTALLED_AOM" 'not_logged_in'

[ "$(cat "$TMP/target/.agent-skills/pin")" = "CCC0509/agent-skills@v0.5.16" ] \
  || fail "pin did not resolve v0.5.16"

echo "execution surface relay smoke ok"
