#!/bin/bash
# preflight.sh — בדיקות מהירות לפני commit (ללא Flutter)
# מריץ את כל השערים הזולים (bash בלבד) שרצים לפני Flutter.
# כוונה: הרץ לפני git commit כדי לתפוס כשלים ב-30 שניות במקום 13 דק'.
#
# שימוש: bash scripts/preflight.sh
# מה זה לא: לא מחליף את ה-hook. ה-hook יריץ flutter analyze/test/build בנוסף.
#
# לקח #68 (בנצי 2026-06-02): 4 מחזורי Flutter לחינם בגלל שערים 59/81 שנכשלו אחרי.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
FLUTTER_DIR="$REPO_ROOT/app_flutter"

cd "$FLUTTER_DIR" || { echo "❌ לא נמצא app_flutter"; exit 1; }

FAIL=0
err()  { echo "❌ [שער $1] $2 → $3"; FAIL=$((FAIL+1)); }
warn() { echo "⚠️  [שער $1] $2"; }

echo ""
echo "══════════════════════════════════════════════"
echo "  BuildSmart — Preflight (שערים מהירים)"
echo "══════════════════════════════════════════════"

# ── ענף ──
BRANCH=$(git branch --show-current)
[[ "$BRANCH" == claude/* ]] || err "1" "ענף שגוי: $BRANCH" "עבור לענף claude/*"

# ── hooks פעילים ──
HOOK_PATH=$(git config --get core.hooksPath 2>/dev/null || echo "")
[[ "$HOOK_PATH" == ".githooks" ]] || err "15/83" "hooks לא מופעלים מהריפו" "git config core.hooksPath .githooks"
[[ -x "$REPO_ROOT/.githooks/pre-commit" ]] || err "16" "pre-commit לא executable" "chmod +x .githooks/pre-commit"

# ── hook integrity ──
CURRENT_HOOK_HASH=$(sha256sum "$REPO_ROOT/.githooks/pre-commit" | cut -d' ' -f1)
if [[ -f "$REPO_ROOT/.git/hooks/pre-commit" ]]; then
    LOCAL_HOOK_HASH=$(sha256sum "$REPO_ROOT/.git/hooks/pre-commit" 2>/dev/null | cut -d' ' -f1)
    [[ "$LOCAL_HOOK_HASH" == "$CURRENT_HOOK_HASH" ]] || \
        err "81" "hook מקומי שונה מ-.githooks/" "cp .githooks/pre-commit .git/hooks/"
fi

# ── גרסאות מסונכרנות ──
V_SHELL=$(grep -oE "v[0-9]+\.[0-9]+" lib/screens/home_shell.dart 2>/dev/null | head -1)
V_STATUS=$(grep -oE "v[0-9]+\.[0-9]+" knowledge/STATUS.md 2>/dev/null | head -1)
[[ "$V_SHELL" == "$V_STATUS" ]] || \
    err "12" "גרסאות לא מסונכרנות: home_shell=$V_SHELL, STATUS=$V_STATUS" "סנכרן"

# ── שינויים staged ──
STAGED_LIB=$(git diff --cached --name-only | grep -E "^app_flutter/lib/(screens|state|logic)/" | head -1)
STAGED_WIRING=$(git diff --cached --name-only | grep "WIRING.md" | head -1)

# ── שער 59: גרסה עלתה אם נגעת בקוד ──
if [[ -n "$STAGED_LIB" ]]; then
    SHELL_DIFF=$(git diff --cached lib/screens/home_shell.dart 2>/dev/null | grep "^+" | grep -oE "v[0-9]+\.[0-9]+" | head -1)
    if [[ -z "$SHELL_DIFF" ]]; then
        err "59" "גרסה לא עלתה (${V_SHELL:-?})" \
            "bump ב-3 מקומות: home_shell.dart · knowledge/STATUS.md · pubspec.yaml (build number)"
    fi
    [[ -n "$STAGED_WIRING" ]] || err "24" "WIRING.md לא עודכן" "עדכן WIRING.md"
fi

# ── WIRING קיים ──
[[ -f "WIRING.md" ]] || err "3" "WIRING.md חסר" "צור app_flutter/WIRING.md"

# ── אין קבצים binaries ──
STAGED_BINARY=$(git diff --cached --name-only | grep -E "\.(exe|dll|so|dylib)$" | head -1)
[[ -z "$STAGED_BINARY" ]] || err "78" "binary ב-staging: $STAGED_BINARY" "לא לשמור binaries"

# ── אין משטחים כהים חדשים ──
DARK_NEW=$(git diff --cached lib/ 2>/dev/null | grep "^+" | grep -v "^+++" | grep -E "0xFF111111|BsTokens\.bgDark" | grep -v "_test\|//" | head -1)
[[ -z "$DARK_NEW" ]] || err "46" "משטח כהה חדש: $DARK_NEW" "השתמש בטוקן מ-BsTokens"

# ── סיכום ──
echo ""
echo "══════════════════════════════════════════════"
if [[ "$FAIL" -gt 0 ]]; then
    echo "  ❌ $FAIL בעיות — תקן לפני git commit"
    echo "══════════════════════════════════════════════"
    exit 1
else
    echo "  ✅ Preflight עבר — בטוח לרוץ git commit"
    echo "  (git commit יריץ גם flutter analyze/test/build)"
    echo "══════════════════════════════════════════════"
    exit 0
fi
