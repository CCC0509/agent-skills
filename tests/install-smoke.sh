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
[ "$(cat "$TMP/target/.agent-skills/pin")" = "CCC0509/agent-skills@v$VER" ] || fail "pin content"
for f in CLAUDE.md AGENTS.md GEMINI.md; do
  [ "$(grep -Fc '<!-- agent-skills:begin -->' "$TMP/target/$f")" = 1 ] || fail "$f begin marker"
  [ "$(grep -Fc '<!-- agent-skills:end -->' "$TMP/target/$f")" = 1 ] || fail "$f end marker"
  grep -q 'existing content' "$TMP/target/$f" || fail "$f lost existing content"
done

# 2) idempotency: second run must be byte-identical
SNAP1="$(cd "$TMP/target" && find . -path ./.git -prune -o -type f -print0 | sort -z | xargs -0 shasum)"
bash "$TMP/src/install.sh" "$TMP/target"
SNAP2="$(cd "$TMP/target" && find . -path ./.git -prune -o -type f -print0 | sort -z | xargs -0 shasum)"
[ "$SNAP1" = "$SNAP2" ] || fail "second install not idempotent"

# 3) dirty source fails even with --dev
touch "$TMP/src/dirty.tmp"
if bash "$TMP/src/install.sh" "$TMP/target" --dev 2>"$TMP/err" ; then fail "dirty source accepted"; fi
grep -q source_dirty "$TMP/err" || fail "expected source_dirty"
rm "$TMP/src/dirty.tmp"

# 4) untagged without --dev fails; with --dev pins dev-<sha>
git -C "$TMP/src" commit -q --allow-empty -m tmp
if bash "$TMP/src/install.sh" "$TMP/target" 2>"$TMP/err"; then fail "untagged accepted"; fi
grep -q source_untagged "$TMP/err" || fail "expected source_untagged"
mktarget
bash "$TMP/src/install.sh" "$TMP/target" --dev 2>/dev/null
grep -q '@dev-' "$TMP/target/.agent-skills/pin" || fail "dev pin format"

# 5) release metadata mismatch fails
git -C "$TMP/src" tag -f v9.9.9 >/dev/null
if bash "$TMP/src/install.sh" "$TMP/target" 2>"$TMP/err"; then fail "metadata mismatch accepted"; fi
grep -q release_metadata_mismatch "$TMP/err" || fail "expected release_metadata_mismatch"

# 6) unmanaged destination fails
git -C "$TMP/src" tag -d v9.9.9 >/dev/null; git -C "$TMP/src" reset -q --hard HEAD~1
git -C "$TMP/src" tag -f "v$VER" >/dev/null
mktarget
mkdir -p "$TMP/target/docs/imported-skills/agent-operating-manual"
touch "$TMP/target/docs/imported-skills/agent-operating-manual/hand-authored.md"
if bash "$TMP/src/install.sh" "$TMP/target" 2>"$TMP/err"; then fail "unmanaged dest accepted"; fi
grep -q destination_exists_unmanaged "$TMP/err" || fail "expected destination_exists_unmanaged"

echo "install smoke ok"
