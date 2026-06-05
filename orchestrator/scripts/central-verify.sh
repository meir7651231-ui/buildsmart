#!/usr/bin/env bash
# THE GATE. Returns 0 only if static-analysis is clean, tests pass, and the build succeeds.
# Project-specific adapter (current: Flutter). Swap the three command blocks for another stack.
# Hardened (red-team): asserts the target fingerprint, prints what it aimed at, no longer swallows
# failures, and trusts the analyzer's exit code (not only a regex). usage: central-verify.sh <app-dir>
set -uo pipefail
APP="${1:?app dir (e.g. .../app_flutter)}"
export PATH="/home/user/flutter/bin:$PATH"

# Fingerprint: confirm the gate is aimed at the right scope+stack, and PRINT it so the orchestrator can
# confirm it matches the worktree where the fixes were applied (red-team: scope-targeting trap).
if [ ! -f "$APP/pubspec.yaml" ]; then
  echo "GATE FAIL: '$APP' has no pubspec.yaml — wrong app dir, or this (Flutter) adapter doesn't match the stack."
  exit 1
fi
echo "gate target: $APP  ·  HEAD: $(git -C "$APP" rev-parse --short HEAD 2>/dev/null || echo '?')  ·  $(grep -m1 '^name:' "$APP/pubspec.yaml")"

echo "== deps =="
( cd "$APP" && flutter pub get ) || { echo "GATE FAIL: pub get (deps unresolved — analyze/test would run on a bad state)"; exit 1; }

echo "== analyze =="
out=$( cd "$APP" && flutter analyze --no-fatal-infos --no-fatal-warnings 2>&1 ); aec=$?
ec=$( printf '%s\n' "$out" | grep -icE 'error •' )
echo "analyze: exit=$aec  error-lines=$ec"
if [ "$aec" -ne 0 ] || [ "$ec" -ne 0 ]; then printf '%s\n' "$out" | grep -iE 'error' | head -40; echo "GATE FAIL: analyze"; exit 1; fi

echo "== test =="
( cd "$APP" && flutter test --reporter=compact ); tec=$?
if [ "$tec" -ne 0 ]; then echo "GATE FAIL: tests"; exit 1; fi

echo "== build =="
bout=$( cd "$APP" && flutter build web --release 2>&1 ); bec=$?
if [ "$bec" -ne 0 ]; then printf '%s\n' "$bout" | tail -20; echo "GATE FAIL: build"; exit 1; fi

echo "GATE PASS (analyze 0 · tests green · build ok)  target=$APP"
