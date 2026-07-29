#!/bin/bash
# BuildSmart — אתחול סביבה מלא לקונטיינר טרי (Claude Code on the web).
# בטוח להרצה חוזרת: כל צעד מדלג אם כבר בוצע. נקרא מ-session-start.sh,
# וניתן להריץ ידנית: bash scripts/bootstrap-env.sh
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_DIR="${FLUTTER_HOME:-/home/user/flutter}"
FLUTTER_VERSION="$(tr -d '[:space:]' < "$REPO/FLUTTER_VERSION")"

# ─── Flutter SDK — הורדה רק אם חסר (הקונטיינר זמני; ה-cache שורד בין סשנים) ───
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "⬇️  Flutter $FLUTTER_VERSION חסר — מוריד (~700MB, פעם אחת לקונטיינר)…"
  TARBALL="/tmp/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  curl -sSL -o "$TARBALL" \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  mkdir -p "$(dirname "$FLUTTER_DIR")"
  tar -xJf "$TARBALL" -C "$(dirname "$FLUTTER_DIR")"
  rm -f "$TARBALL"
  echo "✅ Flutter הותקן ב-$FLUTTER_DIR"
fi

# git דורש safe.directory כשה-SDK בבעלות משתמש אחר (קונטיינר root)
git config --global --add safe.directory "$FLUTTER_DIR" 2>/dev/null || true

export PATH="$FLUTTER_DIR/bin:$PATH"
INSTALLED="$("$FLUTTER_DIR/bin/flutter" --version 2>/dev/null | grep -oE 'Flutter [0-9.]+' | head -1 || true)"
if [ "$INSTALLED" != "Flutter $FLUTTER_VERSION" ]; then
  echo "⚠️  גרסת Flutter מותקנת ($INSTALLED) שונה מהמוצמדת ($FLUTTER_VERSION) — ראה FLUTTER_VERSION"
fi

# ─── תלויות ───
if [ ! -d "$REPO/app/node_modules" ]; then
  echo "📦 מתקין תלויות Preact (app/)…"
  (cd "$REPO/app" && npm install --no-audit --no-fund 2>&1 | tail -1)
fi

(cd "$REPO/app_flutter" && flutter pub get --no-example 2>&1 | tail -1)

echo "✅ סביבה מוכנה: Flutter $FLUTTER_VERSION · node $(node --version) · chromium $([ -x /opt/pw-browsers/chromium-1194/chrome-linux/chrome ] && echo OK || echo חסר)"
