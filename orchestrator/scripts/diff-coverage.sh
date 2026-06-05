#!/usr/bin/env bash
# Diff-coverage gate — every CHANGED source file must appear in the coverage report.
# This is the red-team's T2 false-green killer: when lcov paths and git paths don't line up, the naive
# intersection is empty and the gate "passes" having actually checked nothing. Here a zero-overlap
# (coverage and changes BOTH non-empty, yet no path in common) is itself a hard BLOCK — a path mismatch
# is never allowed to read as a pass. Only test files are excluded (they aren't in lib coverage).
# usage: diff-coverage.sh <lcov.info> <changed-files-list> [strip-prefix]
#   strip-prefix: pass the worktree abs path so lcov absolute SF: paths align with git relative paths.
set -uo pipefail
LCOV="${1:?lcov.info}"; CHANGED="${2:?changed-files list}"; PFX="${3:-}"
[ -f "$LCOV" ]    || { echo "FAIL: lcov file not found: $LCOV"; exit 2; }
[ -f "$CHANGED" ] || { echo "FAIL: changed-files list not found: $CHANGED"; exit 2; }

norm(){  # stdin -> normalized relative .dart source paths (sorted-unique); strips ./, leading /, prefix; drops tests
  local data; data=$(cat)
  data=$(printf '%s\n' "$data" | sed -e 's#^\./##' -e 's#^/##')
  if [ -n "$PFX" ]; then
    local p="${PFX#/}"; p="${p%/}"
    local pe; pe=$(printf '%s' "$p" | sed 's/[][\.*^$/&]/\\&/g')
    data=$(printf '%s\n' "$data" | sed "s/^${pe}\///")
  fi
  printf '%s\n' "$data" | grep -E '\.dart$' | grep -vE '(^|/)test/|_test\.dart$' | sort -u
}
covered=$(grep -E '^SF:' "$LCOV" | sed 's/^SF://' | norm)
changed=$(grep -vE '^[[:space:]]*(#|$)' "$CHANGED" | norm)

nc=$(printf '%s\n' "$changed" | grep -c . || true)
if [ "$nc" -eq 0 ]; then echo "OK: no changed .dart source files to cover"; exit 0; fi
nv=$(printf '%s\n' "$covered" | grep -c . || true)
if [ "$nv" -eq 0 ]; then echo "BLOCK: changed files exist but coverage report has no SF: entries (no coverage produced)"; exit 1; fi

# overlap guard: if NOTHING lines up, it's a path mismatch, not real coverage — never a silent pass.
overlap=$(comm -12 <(printf '%s\n' "$covered") <(printf '%s\n' "$changed") | grep -c . || true)
if [ "$overlap" -eq 0 ]; then
  echo "BLOCK: zero path-overlap between coverage and changed files — likely an lcov/git path-prefix mismatch."
  echo "       Pass the worktree path as the 3rd arg <strip-prefix> so lcov abs-paths align with git rel-paths."
  echo "  e.g. covered: $(printf '%s\n' "$covered" | head -1)"
  echo "       changed: $(printf '%s\n' "$changed" | head -1)"
  exit 1
fi

missing=$(comm -23 <(printf '%s\n' "$changed") <(printf '%s\n' "$covered"))
if [ -n "$missing" ]; then
  echo "BLOCK: changed source file(s) NOT in coverage:"
  printf '%s\n' "$missing" | sed 's/^/  - /'
  exit 1
fi
echo "OK: all $nc changed .dart source file(s) present in coverage"
