#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "WORKFLOW ADOPTION FRAMEWORK SMOKE FAIL: $1" >&2
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

CHANGE="skills/agent-operating-manual/25-change-discipline.md"
RELAY="skills/handoff-relay/SKILL.md"
WORK="skills/work-discipline/SKILL.md"
CHANGELOG="CHANGELOG.md"

require_file "$CHANGE"
require_file "$RELAY"
require_file "$WORK"
require_file "$CHANGELOG"

require_contains "$CHANGE" '## §3.5 Workflow Adoption Framework'
require_contains "$CHANGE" 'Workflow adoption applies before an agent first plans or performs approval-bound PR publication or update, merge, tag, release, deploy, publish, rollback, cleanup, promotion, install, plugin refresh, imported-copy update, or cross-agent workflow handoff work in an adopting repo, and before review handoffs that change workflow authority.'
require_contains "$CHANGE" 'Task 0 incident capture'
require_contains "$CHANGE" 'No workflow found is not permission to proceed.'
require_contains "$CHANGE" 'Minimum repo-local evidence'
require_contains "$CHANGE" 'remote or credentialed evidence remains unverified'
require_contains "$CHANGE" 'adopting repo'\''s canonical playbook section'
require_contains "$CHANGE" '`lifecycle/workflow-profile.md`'
require_contains "$CHANGE" 'Canonical gate map'
require_contains "$CHANGE" 'PR, review, branch, and merge'
require_contains "$CHANGE" 'tag, release, publish, package, marketplace, and app-store'
require_contains "$CHANGE" 'deploy, production command, environment switch, and rollback'
require_contains "$CHANGE" 'cleanup for branches, worktrees, generated residue, temp consumers, private evidence, outcome stores, and artifacts'
require_contains "$CHANGE" 'install, plugin refresh, imported-copy update, and runtime tool setup'
require_contains "$CHANGE" 'private evidence, public-safe attestation, and promotion'
require_contains "$CHANGE" 'Surface-sensitive workflow actions must call capability/surface preflight before route or execution decisions.'
require_contains "$CHANGE" 'If preflight fails or is unavailable, record the gap and stop; do not broaden to another surface.'
require_contains "$CHANGE" 'Receiver-specific handoff splitting is mandatory'
require_contains "$CHANGE" 'one packet is approval-bound'
require_contains "$CHANGE" 'Session provenance minimum'
require_contains "$CHANGE" 'source evidence received'
require_contains "$CHANGE" 'authority held'
require_contains "$CHANGE" 'public-safe attestation and an adopting-repo-owned promotion ledger or equivalent'
require_contains "$CHANGE" 'Never store secret values, tokens, keys, raw credential-store output, private account identifiers, or raw private logs as durable workflow evidence.'
require_contains "$CHANGE" 'Do not put private workspace paths, raw private review blocks, organization identifiers, or absolute local paths in public doctrine or public attestations.'
require_contains "$CHANGE" 'Structured fixtures, validators, closeout capture, copy-block lint, generated trigger-layer support, and durable taxonomy belong to a later reviewed mechanism plan.'

require_not_contains "$CHANGE" 'docs/status/2026-07-09-process-improvement-intake-next-session.md'
require_not_contains "$CHANGE" 'toolchain-workspace'
require_not_contains "$CHANGE" '/Users/'
require_not_contains "$CHANGE" '/private/'

require_contains "$RELAY" 'workflow adoption'
require_contains "$RELAY" 'packet splitting'
require_contains "$RELAY" '25-change-discipline.md'
require_contains "$WORK" 'workflow profiles'
require_contains "$WORK" 'workflow adoption'
require_contains "$WORK" '25-change-discipline.md'

require_contains "$CHANGELOG" 'v0.5.15: Workflow adoption framework'
require_contains .claude-plugin/plugin.json '"version": "0.5.15"'
require_contains .claude-plugin/marketplace.json '"version": "0.5.15"'

copy_current_source_to_tmp_repo
VER="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  "$TMP/src/.claude-plugin/plugin.json" | head -1)"
git -C "$TMP/src" tag -f "v$VER" >/dev/null

mkdir "$TMP/target"
git -C "$TMP/target" init -q
printf '# AGENTS.md\nexisting content\n' > "$TMP/target/AGENTS.md"
bash "$TMP/src/install.sh" "$TMP/target" \
  --skills agent-operating-manual,handoff-relay,multi-angle-review,work-discipline

INSTALLED_CHANGE="$TMP/target/docs/imported-skills/agent-operating-manual/25-change-discipline.md"
INSTALLED_RELAY="$TMP/target/docs/imported-skills/handoff-relay/SKILL.md"
INSTALLED_WORK="$TMP/target/docs/imported-skills/work-discipline/SKILL.md"
require_file "$INSTALLED_CHANGE"
require_file "$INSTALLED_RELAY"
require_file "$INSTALLED_WORK"

require_contains "$INSTALLED_CHANGE" '## §3.5 Workflow Adoption Framework'
require_contains "$INSTALLED_CHANGE" 'No workflow found is not permission to proceed.'
require_contains "$INSTALLED_CHANGE" 'Minimum repo-local evidence'
require_contains "$INSTALLED_CHANGE" 'Canonical gate map'
require_contains "$INSTALLED_CHANGE" 'Surface-sensitive workflow actions must call capability/surface preflight before route or execution decisions.'
require_contains "$INSTALLED_CHANGE" 'Receiver-specific handoff splitting is mandatory'
require_contains "$INSTALLED_CHANGE" 'Session provenance minimum'
require_contains "$INSTALLED_CHANGE" 'public-safe attestation and an adopting-repo-owned promotion ledger or equivalent'
require_contains "$INSTALLED_RELAY" 'workflow adoption'
require_contains "$INSTALLED_WORK" 'workflow profiles'

[ "$(cat "$TMP/target/.agent-skills/pin")" = "CCC0509/agent-skills@v0.5.15" ] \
  || fail "pin did not resolve v0.5.15"

echo "workflow adoption framework smoke ok"
