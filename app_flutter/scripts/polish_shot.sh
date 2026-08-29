#!/bin/bash
# Polish screenshot pipeline (ליטוש) — headless REAL-app capture for before/after.
#
# Why this shape: gstatic.com (canvaskit + fonts CDN) is blocked by the sandbox
# network policy, so the web build must bundle canvaskit LOCALLY
# (--no-web-resources-cdn). Then a local static server + Playwright headless
# chromium (ignoreHTTPSErrors) screenshots the actual rendered app.
#
# Usage: scripts/polish_shot.sh [out.png] [waitMs] [url-path]
#   out.png   default /tmp/polish/app.png
#   waitMs    canvaskit render wait, default 13000
#   url-path  default '/'
#
# Re-run after a UI change to capture "after"; compare to the saved "before".
set -euo pipefail
export PATH="/home/user/flutter/bin:$PATH"
HERE="$(cd "$(dirname "$0")" && pwd)"
APP="$(cd "$HERE/.." && pwd)"
OUT="${1:-/tmp/polish/app.png}"
WAIT="${2:-13000}"
URLPATH="${3:-/}"
mkdir -p /tmp/polish "$(dirname "$OUT")"

cd "$APP"
if [ ! -f build/web/canvaskit/canvaskit.js ]; then
  echo "[polish_shot] building web with local canvaskit…"
  flutter build web --release --no-web-resources-cdn >/tmp/polish/build.log 2>&1
fi

cd build/web
python3 -m http.server 8099 >/tmp/polish/srv.log 2>&1 &
SRV=$!
trap 'kill $SRV 2>/dev/null || true' EXIT
sleep 2
NODE_PATH=/opt/node22/lib/node_modules node "$HERE/polish_shot.js" \
  "http://localhost:8099${URLPATH}" "$OUT" "$WAIT"
