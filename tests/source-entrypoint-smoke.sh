#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "SOURCE ENTRYPOINT SMOKE FAIL: $1" >&2
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

require_exact_line() {
  local file="$1"
  local line="$2"
  grep -Fxq "$line" "$file" || fail "$file missing exact line: $line"
}

require_not_contains() {
  local file="$1"
  local token="$2"
  ! grep -Fq "$token" "$file" || fail "$file contains forbidden token: $token"
}

require_max_lines() {
  local file="$1"
  local max="$2"
  local count
  count="$(wc -l < "$file" | tr -d ' ')"
  [ "$count" -le "$max" ] || fail "$file has $count lines, expected at most $max"
}

for entry in AGENTS.md CLAUDE.md GEMINI.md; do
  require_file "$entry"
  require_not_contains "$entry" '<!-- agent-skills:begin -->'
  require_not_contains "$entry" '<!-- agent-skills:end -->'
done

require_contains AGENTS.md 'This checkout is the `agent-skills` source repo'
require_contains AGENTS.md 'not an adopting repo'
require_contains AGENTS.md 'not an install target'
require_contains AGENTS.md 'Source doctrine lives under `skills/**`'
require_contains AGENTS.md 'Design specs and implementation plans live under `docs/superpowers/**`'
require_contains AGENTS.md 'Release metadata lives under `.claude-plugin/**`'
require_contains AGENTS.md 'Do not run `./install.sh` against this repo'
require_contains AGENTS.md 'Do not edit generated imported copies in adopting repos'
require_contains AGENTS.md 'plan-first'
require_contains AGENTS.md 'fresh review before merge'
require_contains AGENTS.md 'last merged doctrine on `main`'
require_contains AGENTS.md 'proposal text inside the branch'
require_contains AGENTS.md 'git diff --name-only "$(git merge-base HEAD origin/main)"..HEAD -- skills/ AGENTS.md CLAUDE.md GEMINI.md'
require_contains AGENTS.md '/tmp/<repo>-<branch>'
require_contains AGENTS.md '.worktrees/'
require_contains AGENTS.md '.claude/worktrees/'
require_contains AGENTS.md 'git status -sb'
require_contains AGENTS.md 'git rev-parse --show-toplevel'
require_contains AGENTS.md 'edit tool'
require_contains AGENTS.md 'git restore <path>'
require_contains AGENTS.md 'git checkout -- <path>'
require_contains AGENTS.md 'never delete pre-existing or user-authored content'
require_contains AGENTS.md 'agent-trigger-kit session-check'
require_contains AGENTS.md 'agent-skills: plugin directory missing'
require_contains AGENTS.md 'root-level plugin layout'
require_contains AGENTS.md 'source: "./"'
require_contains AGENTS.md 'ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up'
require_contains AGENTS.md 'Verification notes may add detail, but they are not a substitute for `Accepted residuals`'

require_contains CLAUDE.md 'See [AGENTS.md](AGENTS.md)'
require_contains CLAUDE.md 'thin pointer for Claude Code'
require_contains GEMINI.md 'See [AGENTS.md](AGENTS.md)'
require_contains GEMINI.md 'thin pointer for Gemini'
require_max_lines CLAUDE.md 6
require_max_lines GEMINI.md 6

require_file .gitignore
require_exact_line .gitignore '.claude/worktrees/'
require_exact_line .gitignore '/.worktrees/'
require_exact_line .gitignore '/worktrees/'

echo "source entrypoint smoke ok"
