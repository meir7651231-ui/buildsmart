#!/bin/bash
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

export PATH="/home/user/flutter/bin:$PATH"
REPO="$CLAUDE_PROJECT_DIR"

# ─── שכבה 3: שחזור אוטומטי של hooks ───
# אם מישהו מחק או שינה — משחזר מהריפו
if [[ -d "$REPO/.githooks" ]]; then
    git -C "$REPO" config core.hooksPath .githooks
    chmod +x "$REPO/.githooks/"* 2>/dev/null || true
    echo "🔒 שערי הפרוטוקול הופעלו מהריפו"
fi

# ─── תלויות ───
cd "$REPO/app_flutter"
flutter pub get --no-example 2>&1 | tail -3

# ─── סיכום פרוטוקול ───
echo ""
echo "════════════════════════════════════════════"
echo "  BuildSmart Flutter — סיכום פרוטוקול"
echo "════════════════════════════════════════════"
echo ""

VERSION=$(grep -oE "v[0-9]+\.[0-9]+" knowledge/STATUS.md 2>/dev/null | head -1 || echo "לא ידוע")
echo "📌 גרסה נוכחית: $VERSION"

BRANCH=$(git branch --show-current 2>/dev/null || echo "לא ידוע")
if [[ "$BRANCH" == claude/* ]]; then
    echo "✅ ענף: $BRANCH"
else
    echo "⚠️  ענף שגוי: $BRANCH"
fi

UNPUSHED=$(git rev-list "origin/$BRANCH..HEAD" --count 2>/dev/null || echo "0")
if [[ "$UNPUSHED" -gt 0 ]]; then
    echo "📦 $UNPUSHED שמירות ממתינות לדחיפה (דורש אישור מפורש)"
fi

echo ""
echo "📋 צעדים הבאים (קבוצה א׳):"
grep -A2 "Group A" knowledge/SMARTPRODUCT_ROADMAP.md 2>/dev/null | head -5 || echo "  76 · 25 · 46 · 74 · 89 · 82 · 85 · 57"

echo ""
echo "🚫 לא לדחוף ללא 'תדחוף' מפורש מהמשתמש"
echo "🔒 ה-hooks אוכפים אוטומטית — אסור לעקוף"
echo "🔁 6 כללים: מצא → helper → בדיקה → analyze → test → build"
echo ""
echo "════════════════════════════════════════════"
