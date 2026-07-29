#!/bin/bash
# BuildSmart — שער אימות מלא ל-app (Preact, ה-live) בפקודה אחת:
#   bash scripts/verify-preact.sh
# typecheck → build → הגשת dist על :8123 → smoke 21/21. מנקה אחריו את השרת.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT=8123

cd "$REPO/app"
[ -d node_modules ] || npm install --no-audit --no-fund 2>&1 | tail -1

echo "═══ 1/3 typecheck ═══"
npx tsc -b --noEmit

echo "═══ 2/3 build ═══"
npm run build >/dev/null 2>&1 || { echo "❌ build נכשל"; npm run build 2>&1 | tail -10; exit 1; }
[ -d dist ] || { echo "❌ אין dist אחרי build"; exit 1; }

echo "═══ 3/3 smoke 21/21 ═══"
# stdout/stderr מנותקים — אחרת השרת מחזיק את ה-pipe של הסקריפט פתוח גם אחרי סיום
npx -y http-server "$REPO/app/dist" -p "$PORT" -s >/dev/null 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2>/dev/null; pkill -f "http-server.*$PORT" 2>/dev/null || true' EXIT
for _ in $(seq 1 30); do
  curl -sf -o /dev/null "http://localhost:$PORT/" && break
  sleep 0.5
done
curl -sf -o /dev/null "http://localhost:$PORT/" || { echo "❌ שרת ה-smoke לא עלה על :$PORT"; exit 1; }

cd "$REPO"
node app/smoke-settings.mjs | tail -4
SMOKE_EXIT=${PIPESTATUS[0]}
[ "$SMOKE_EXIT" -eq 0 ] || { echo "❌ smoke נכשל"; exit 1; }

echo "✅ verify-preact עבר במלואו (typecheck + build + smoke 21/21)"
