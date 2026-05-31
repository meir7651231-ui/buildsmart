#!/bin/bash
# Re-applies the canvasKit config to build/web/flutter_bootstrap.js so that
# local serving (puppeteer / `python3 -m http.server`) loads canvaskit from
# the bundled `canvaskit/` instead of the gstatic CDN.
#
# `flutter build web --release` regenerates flutter_bootstrap.js on every run,
# wiping our local override — run this immediately after each build.
#
# Usage:
#   cd app_flutter
#   flutter build web --release
#   scripts/post_build.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOOTSTRAP="$ROOT/build/web/flutter_bootstrap.js"

if [ ! -f "$BOOTSTRAP" ]; then
  echo "post_build: $BOOTSTRAP not found (did flutter build web succeed?)" >&2
  exit 1
fi

# Idempotent: skip if already patched
if grep -q 'canvasKitBaseUrl: "canvaskit/"' "$BOOTSTRAP"; then
  echo "post_build: canvaskit patch already applied"
  exit 0
fi

# Replace the default _flutter.loader.load(...) block with one that includes
# the canvasKitBaseUrl config (both top-level and in initializeEngine).
python3 - "$BOOTSTRAP" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
s = p.read_text()
old = (
    "_flutter.loader.load({\n"
    "  onEntrypointLoaded: async function(engineInitializer) {\n"
    "    let appRunner = await engineInitializer.initializeEngine({\n"
    "      useColorEmoji: true,\n"
    "    });\n"
    "    await appRunner.runApp();\n"
    "  }\n"
    "});"
)
new = (
    "_flutter.loader.load({\n"
    "  config: { canvasKitBaseUrl: \"canvaskit/\" },\n"
    "  onEntrypointLoaded: async function(engineInitializer) {\n"
    "    let appRunner = await engineInitializer.initializeEngine({\n"
    "      useColorEmoji: true,\n"
    "      canvasKitBaseUrl: \"canvaskit/\",\n"
    "    });\n"
    "    await appRunner.runApp();\n"
    "  }\n"
    "});"
)
if old not in s:
    print("post_build: expected _flutter.loader.load(...) block not found — bootstrap shape changed?", file=sys.stderr)
    sys.exit(2)
p.write_text(s.replace(old, new))
print("post_build: canvasKit patch applied")
PY
