#!/usr/bin/env bash
# stage-4 · build the CLEAN profile — the generic white-label base
# (PLAN-buildsmart-clean-master §4: one code → many apps).
#
# What APP_PROFILE=clean means (lib/state/app_profile.dart, pinned by
# app_profile_flags_test):
#   • every shipped-UX capability ON (word-finder, keyboard, dives, global
#     search, store comparison, smart-input);
#   • NO company server (CATALOG_BASE_URL='') and NO company CDN
#     (IMAGE_BASE_URL='') — bundled assets only;
#   • the buildsmart-only Studio publish mirror OFF;
#   • the arming layer (backend flags) untouched — a clean deployment arms
#     its own backend per the STUDIO_GA runbook when it gets one.
#
# Company identity: edit lib/config/app_brand.dart (one file) + the platform
# shells per app_flutter/knowledge/BRAND_SWAP_CHECKLIST.md.
#
# usage:            bash scripts/build_clean.sh
# deploy (OWNER — creates the separate live link, never touches the main site):
#   firebase hosting:channel:deploy clean --project buildsmart-b0b78
#   (or a dedicated site/project per company — see LAUNCH_READINESS stage-4.)
set -euo pipefail
cd "$(dirname "$0")/../app_flutter"
export PATH="$HOME/flutter/bin:$PATH"

echo "== building APP_PROFILE=clean =="
flutter build web --release --dart-define=APP_PROFILE=clean

echo "== done =="
echo "output: app_flutter/build/web  (deploy via the hosting-channel command above)"
