#!/usr/bin/env bash
# THE GATE. Returns 0 only if static-analysis is clean, tests pass, and the build succeeds.
# Project-specific adapter (current: Flutter). Swap the three blocks for another stack.
# usage: central-verify.sh <app-dir>
set -uo pipefail
APP="${1:?app dir (e.g. .../app_flutter)}"
export PATH="/home/user/flutter/bin:$PATH"

( cd "$APP" && flutter pub get ) >/dev/null 2>&1

echo "== analyze =="
out=$( cd "$APP" && flutter analyze --no-fatal-infos --no-fatal-warnings 2>&1 )
ec=$( printf '%s\n' "$out" | grep -icE 'error •' )
echo "analyze errors: $ec"
if [ "$ec" -ne 0 ]; then printf '%s\n' "$out" | grep -iE 'error •' | head -40; echo "GATE FAIL: analyze"; exit 1; fi

echo "== test =="
( cd "$APP" && flutter test --reporter=compact ); tec=$?
if [ "$tec" -ne 0 ]; then echo "GATE FAIL: tests"; exit 1; fi

echo "== build =="
( cd "$APP" && flutter build web --release ) >/dev/null 2>&1; bec=$?
if [ "$bec" -ne 0 ]; then echo "GATE FAIL: build"; exit 1; fi

echo "GATE PASS (analyze 0 · tests green · build ok)"
