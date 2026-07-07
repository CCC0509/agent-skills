#!/usr/bin/env bash
set -euo pipefail

REPO_SLUG="CCC0509/agent-skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SKILLS="agent-operating-manual,handoff-relay,multi-angle-review"
ENTRY_FILES=("CLAUDE.md" "AGENTS.md" "GEMINI.md")
MARKER_BEGIN="<!-- agent-skills:begin -->"
MARKER_END="<!-- agent-skills:end -->"
MEMORY_INDEX="docs/agent-memory-index.md"

usage() {
  cat <<'EOF'
usage: install.sh <target-repo-path> [--dest docs/imported-skills]
                  [--skills a,b] [--dev] [--create-entry <CLAUDE.md|AGENTS.md|GEMINI.md>]
EOF
}

TARGET="" DEST="docs/imported-skills" SKILLS="$DEFAULT_SKILLS" DEV=0
CREATE_ENTRIES=()
while [ $# -gt 0 ]; do
  case "$1" in
    --dest) DEST="$2"; shift 2 ;;
    --skills) SKILLS="$2"; shift 2 ;;
    --dev) DEV=1; shift ;;
    --create-entry)
      case "$2" in
        CLAUDE.md|AGENTS.md|GEMINI.md) CREATE_ENTRIES+=("$2") ;;
        *) echo "invalid --create-entry: $2" >&2; exit 1 ;;
      esac; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown flag: $1" >&2; usage >&2; exit 1 ;;
    *)
      if [ -n "$TARGET" ]; then echo "unexpected arg: $1" >&2; exit 1; fi
      TARGET="$1"; shift ;;
  esac
done
[ -n "$TARGET" ] || { usage >&2; exit 1; }
[ -d "$TARGET" ] || { echo "target not a directory: $TARGET" >&2; exit 1; }

# --- Input validation: keep all write paths inside the target repo ---
case "$DEST" in
  /*|*..*) echo "invalid --dest: $DEST (absolute paths and '..' not allowed)" >&2; exit 1 ;;
esac
[ -n "$SKILLS" ] || { echo "invalid --skills entry: empty" >&2; exit 1; }
IFS=',' read -r -a SKILL_ARR <<<"$SKILLS"
for name in "${SKILL_ARR[@]+"${SKILL_ARR[@]}"}"; do
  case "$name" in
    ""|*/*|*..*) echo "invalid --skills entry: '$name' (empty, '/', and '..' not allowed)" >&2; exit 1 ;;
  esac
done

# --- Source gate: clean worktree always; exact tag unless --dev ---
if [ -n "$(git -C "$SCRIPT_DIR" status --porcelain)" ]; then
  echo "source_dirty: install requires a clean agent-skills checkout" >&2
  exit 1
fi
TAG="$(git -C "$SCRIPT_DIR" describe --exact-match --tags 2>/dev/null || true)"
if [ -n "$TAG" ]; then
  VER="${TAG#v}"
  for mf in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
    MFV="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
      "$SCRIPT_DIR/$mf" | head -1)"
    if [ "$MFV" != "$VER" ]; then
      echo "release_metadata_mismatch: $mf version=$MFV tag=$TAG" >&2
      exit 1
    fi
  done
  PIN="$REPO_SLUG@$TAG"
elif [ "$DEV" = 1 ]; then
  PIN="$REPO_SLUG@dev-$(git -C "$SCRIPT_DIR" rev-parse --short HEAD)"
  echo "WARNING verification-gap: dev install ($PIN); consumer closeout must list this" >&2
else
  echo "source_untagged: HEAD is not at an exact tag (use --dev for a dev install)" >&2
  exit 1
fi

# --- Copy skills (managed replace) ---
POINTER_LINES="Repo memory index: [$MEMORY_INDEX]($MEMORY_INDEX).
"
for name in "${SKILL_ARR[@]}"; do
  SRC="$SCRIPT_DIR/skills/$name"
  [ -d "$SRC" ] || { echo "unknown skill: $name" >&2; exit 1; }
  DST="$TARGET/$DEST/$name"
  if [ -d "$DST" ] && [ ! -f "$DST/.managed-by-agent-skills" ]; then
    echo "destination_exists_unmanaged: $DST" >&2
    exit 1
  fi
  rm -rf "$DST"
  mkdir -p "$DST"
  cp -R "$SRC/." "$DST/"
  printf '%s\n' "$PIN" > "$DST/.managed-by-agent-skills"
  case "$name" in
    agent-operating-manual)
      POINTER_LINES="${POINTER_LINES}非 trivial 任務（委派、選模型、驗證、何時停）先讀 [$DEST/agent-operating-manual/SKILL.md]($DEST/agent-operating-manual/SKILL.md)。
" ;;
    handoff-relay)
      POINTER_LINES="${POINTER_LINES}Agent handoff / relay / approval / reviewer forwarding 時讀 [$DEST/handoff-relay/SKILL.md]($DEST/handoff-relay/SKILL.md)。
" ;;
    multi-angle-review)
      POINTER_LINES="${POINTER_LINES}Read-only review（PR / commit range / plan/rule-review / fix-confirmation）套 [$DEST/multi-angle-review/SKILL.md]($DEST/multi-angle-review/SKILL.md)。
" ;;
    skill-authoring)
      POINTER_LINES="${POINTER_LINES}撰寫 / 萃取 / 發佈可攜 agent skill 或 plugin doctrine 時讀 [$DEST/skill-authoring/SKILL.md]($DEST/skill-authoring/SKILL.md)。
" ;;
  esac
done

# --- Pin ---
mkdir -p "$TARGET/.agent-skills"
printf '%s\n' "$PIN" > "$TARGET/.agent-skills/pin"

# --- Repo-owned memory index ---
MEMORY_INDEX_PATH="$TARGET/$MEMORY_INDEX"
if [ ! -e "$MEMORY_INDEX_PATH" ] && [ ! -L "$MEMORY_INDEX_PATH" ]; then
  mkdir -p "$(dirname "$MEMORY_INDEX_PATH")"
  cat > "$MEMORY_INDEX_PATH" <<'EOF'
# Agent Memory Index

This repo owns this file. agent-skills creates it once as a starter index and
does not overwrite local edits.

## Canonical Memory

- `LESSONS.md`: not created yet; create it at the repo's chosen lesson-memory path when the first reusable lesson appears.
- Status memory: repo-owned todo / diagnosis / future-session notes.
- Audit memory: repo-owned review log, done log, observations, or release notes.

## Not Canonical Memory

- Imported skill copies under `docs/imported-skills/**`.
- Agent Trigger Kit outcome stores.
- MCP graph caches.
- Local scratch files.
EOF
fi

# --- Pointer block injection ---
BLOCK="$MARKER_BEGIN
<!-- managed by agent-skills ${PIN}；升級時重跑 install.sh 會替換本區塊；手動編輯會在下次 install 被覆蓋 -->
${POINTER_LINES}$MARKER_END"

for entry in "${CREATE_ENTRIES[@]+"${CREATE_ENTRIES[@]}"}"; do
  [ -f "$TARGET/$entry" ] || printf '%s\n' "$BLOCK" > "$TARGET/$entry"
done

SKIPPED=""
for entry in "${ENTRY_FILES[@]}"; do
  F="$TARGET/$entry"
  if [ ! -f "$F" ]; then SKIPPED="$SKIPPED $entry"; continue; fi
  NB="$(grep -Fc "$MARKER_BEGIN" "$F" || true)"
  NE="$(grep -Fc "$MARKER_END" "$F" || true)"
  if [ "$NB" = 0 ] && [ "$NE" = 0 ]; then
    printf '\n%s\n' "$BLOCK" >> "$F"
  elif [ "$NB" = 1 ] && [ "$NE" = 1 ]; then
    # index() substring match keeps the transform consistent with the grep -Fc
    # detection above (tolerates CRLF or indented marker lines).
    BLOCK="$BLOCK" awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" '
      index($0, begin) { print ENVIRON["BLOCK"]; skipping = 1; next }
      index($0, end) { skipping = 0; next }
      !skipping { print }
    ' "$F" > "$F.agent-skills.tmp"
    if ! grep -Fq "$MARKER_BEGIN" "$F.agent-skills.tmp" || \
       ! grep -Fq "$MARKER_END" "$F.agent-skills.tmp"; then
      rm -f "$F.agent-skills.tmp"
      echo "marker_replace_failed: $entry" >&2
      exit 1
    fi
    mv "$F.agent-skills.tmp" "$F"
  else
    echo "marker_mismatch: $entry begin=$NB end=$NE" >&2
    exit 1
  fi
done

echo "installed $PIN -> $TARGET/$DEST (${SKILLS})"
[ -z "$SKIPPED" ] || echo "skipped missing entry files:$SKIPPED (use --create-entry to create)"
