#!/usr/bin/env bash
# POST precommit gate: I1 (append-only) + I4 (no secrets/paths) + I12 (minimalism)
set -euo pipefail

fail() { echo "FAIL: $*" >&2; exit 1; }
ok()   { echo "OK:   $*"; }

echo "=== I4: secrets & paths sweep ==="
PATTERNS='(/home/|/Users/|C:\\|ghp_|sk-|Bearer |AKIA[0-9A-Z]{16})'
HITS=$(git grep -nE "$PATTERNS" -- . ':(exclude)scripts/precommit-checks.sh' 2>/dev/null || true)
if [ -n "$HITS" ]; then echo "$HITS"; fail "I4: secrets/paths found"; fi
ok "I4: no secrets/paths"

EMAIL_ALLOW='(@t_cortex|@arxiv\.org|@t\.me|@github\.com|@youtube\.com|noreply@)'
EHITS=$(git grep -nEo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' -- . ':(exclude)scripts/precommit-checks.sh' 2>/dev/null | grep -vE "$EMAIL_ALLOW" || true)
if [ -n "$EHITS" ]; then echo "$EHITS"; fail "I4: unexpected email addresses"; fi
ok "I4: email addresses allow-listed"

echo "=== I1: append-only guard for records/ ==="
CHANGED=$(git diff --name-only HEAD -- 'records/2026/*.md' 2>/dev/null || true)
for f in $CHANGED; do
  OLD=$(git show "HEAD:$f" 2>/dev/null | awk '/^## 1\. INPUT/{g=1} /^## 3\./{g=0} g' || true)
  NEW=$(awk '/^## 1\. INPUT/{g=1} /^## 3\./{g=0} g' "$f" 2>/dev/null || true)
  if [ "$OLD" != "$NEW" ]; then fail "I1: $f has modified INPUT/SOURCE block"; fi
done
ok "I1: no immutable block changes in records/"

echo "=== I12: minimalism guard for post-I12 records ==="
for f in records/2026/*.md; do
  [ -e "$f" ] || continue
  case "$(basename "$f")" in
    001_*|002_*|003_*) continue ;;
  esac
  if grep -qE '(Telegram Draft|Визуальная метафора|Суть простыми словами|Честные ограничения)' "$f"; then
    fail "I12: $f contains forbidden full-text or cover sections"
  fi
  LINES=$(wc -l < "$f")
  if [ "$LINES" -gt 60 ]; then
    fail "I12: $f exceeds 60 lines ($LINES lines)"
  fi
done
ok "I12: post-I12 records comply with minimalism rule"

echo "=== I1: JSONL validity ==="
if [ -f logs/events.jsonl ]; then
  jq -c . logs/events.jsonl >/dev/null || fail "I1: events.jsonl has invalid JSON line"
  ok "I1: events.jsonl every line is valid JSON"
fi

echo "=== ALL GATES PASSED ==="
