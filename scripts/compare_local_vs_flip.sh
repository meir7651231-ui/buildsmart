#!/bin/bash
# P5.68 (§8 Phase-3, 📈) — compare the LOCAL (flags-OFF, shipped default) build
# against the FLIP (Pillar-5 server flags ON) build, so a dev can eyeball that
# turning the backend ON did not regress the offline experience before cutover.
#
# This is a DEV helper — it is NOT a CI gate (the CI gate is the flags-OFF
# `backend_flag_test.dart` + the deploy-ordering selftest). It runs two builds
# and reports drift; the shipped default MUST stay byte-identical with flags OFF.
#
# Usage:  scripts/compare_local_vs_flip.sh [CATALOG_BASE_URL]
#   CATALOG_BASE_URL — optional; the flip build's server base (defaults to a
#                      placeholder so the build resolves without a live backend).
#
# Do NOT run this in CI — it is slow (two full web builds) and needs a Flutter SDK.
set -euo pipefail

REPO="$(git rev-parse --show-toplevel)"
APP="$REPO/app_flutter"
OUT="$REPO/.compare-local-vs-flip"
BASE_URL="${1:-https://catalog.example.invalid}"

echo "════════════════════════════════════════════════════════"
echo "  compare_local_vs_flip — Pillar-5 Phase-3 (dev only)"
echo "════════════════════════════════════════════════════════"

command -v flutter >/dev/null 2>&1 || { echo "❌ flutter not on PATH"; exit 1; }
mkdir -p "$OUT"
cd "$APP"

# 0 · The zero-regression PROOF: the flag-off suite must be green (this is what
#     guarantees the LOCAL build is byte-identical to today regardless of the
#     Pillar-5 code that now exists behind the flags).
echo "── [0/3] flag-off invariant (flutter test backend_flag_test) ──"
flutter test test/backend_flag_test.dart

# 1 · LOCAL build — no dart-defines → the shipped default (bundled catalog,
#     in-memory demo, no server).
echo "── [1/3] LOCAL build (flags OFF) ──"
flutter build web --release
cp build/web/flutter_service_worker.js "$OUT/local.sw.js" 2>/dev/null || true
find build/web -maxdepth 2 -type f -printf '%P\t%s\n' | sort > "$OUT/local.manifest.txt"
LOCAL_MAIN="$(stat -c%s build/web/main.dart.js 2>/dev/null || echo '?')"

# 2 · FLIP build — Pillar-5 server flags ON.
echo "── [2/3] FLIP build (USE_FIREBASE_BACKEND + STUDIO_LIVE + CATALOG_SERVER_SEARCH) ──"
flutter build web --release \
  --dart-define=USE_FIREBASE_BACKEND=true \
  --dart-define=STUDIO_LIVE=true \
  --dart-define=CATALOG_SERVER_SEARCH=true \
  --dart-define=CATALOG_BASE_URL="$BASE_URL"
find build/web -maxdepth 2 -type f -printf '%P\t%s\n' | sort > "$OUT/flip.manifest.txt"
FLIP_MAIN="$(stat -c%s build/web/main.dart.js 2>/dev/null || echo '?')"

# 3 · Report drift. The asset MANIFEST (which files ship) should be identical;
#     only main.dart.js content/size may differ (the flip pulls in the live code
#     paths). A change in the manifest between OFF and ON is a red flag.
echo "── [3/3] drift report ──"
echo "main.dart.js  local=${LOCAL_MAIN}B  flip=${FLIP_MAIN}B"
if diff -q "$OUT/local.manifest.txt" "$OUT/flip.manifest.txt" >/dev/null 2>&1; then
  echo "✅ asset manifest identical (only main.dart.js content differs — expected)"
else
  echo "⚠️  asset manifest DIFFERS between local and flip — investigate:"
  diff "$OUT/local.manifest.txt" "$OUT/flip.manifest.txt" || true
fi

# EXTENSION POINT (§8): a semantic catalog / search-top-N / card-flow diff would
# run an integration harness against each build and compare answers. Wire it here
# when the flip is exercised against a live/emulated backend; today the offline
# `search_parity_golden_test` already asserts Layer-A ≡ Layer-B answer-equivalence.
echo "Done. Artifacts in $OUT/"
