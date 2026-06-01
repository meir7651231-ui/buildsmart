#!/bin/bash
# mutation_verify.sh — אימות-מוטציה בטוח (דיווח קטלגן 2026-06-01)
#
# מה הבעיה שזה פותר: סקריפטים שסיימו ב-`git checkout <file>` מחקו עריכות
# לא-מקומיטות באותו קובץ ("reset to HEAD"). כאן משחזרים מ-backup byte-exact,
# לא מ-git — אז עריכות שלא נשמרו ב-commit שורדות.
#
# שימוש:
#   scripts/mutation_verify.sh <file> '<sed-expr>' '<test-path-or-name>'
# דוגמה:
#   scripts/mutation_verify.sh lib/data/chip_hierarchy.dart \
#       "s/'לוחית'/'ZZZ'/" test/chip_structure_test.dart
#
# מה הוא עושה: (1) גיבוי byte-exact → (2) הזרקת מוטציה → (3) test מצופה אדום →
# (4) שחזור מה-גיבוי → (5) test מצופה ירוק → (6) רישום אוטומטי ל-mutation_log.md.
# כל יציאה (גם קריסה/Ctrl-C) משחזרת דרך trap.
set -u

if [[ $# -ne 3 ]]; then
    echo "שימוש: $0 <file> '<sed-expr>' '<test-filter>'" >&2
    exit 2
fi
file="$1"; sed_expr="$2"; test_filter="$3"

# רוץ מ-app_flutter (כמו generate_stuck_regression.sh)
REPO_ROOT="$(git rev-parse --show-toplevel)" || exit 1
cd "$REPO_ROOT/app_flutter" || exit 1
command -v flutter >/dev/null 2>&1 || { echo "❌ flutter לא ב-PATH" >&2; exit 1; }

[[ -f "$file" ]] || { echo "❌ קובץ לא קיים: $file" >&2; exit 1; }

# 1. גיבוי byte-exact (לא משתנה — שומר trailing newline / כל בית)
backup="$(mktemp)"
cp "$file" "$backup"
restore() { cp "$backup" "$file"; }
trap 'restore; rm -f "$backup"' EXIT INT TERM

# 2. הזרקת מוטציה
sed -i "$sed_expr" "$file"
if cmp -s "$file" "$backup"; then
    echo "⚠️  המוטציה לא שינתה דבר — בדוק את ה-sed-expr" >&2
    exit 1   # trap משחזר ומנקה
fi

# 3. test מצופה אדום (המוטציה חייבת להיתפס)
if flutter test "$test_filter" >/dev/null 2>&1; then
    echo "❌ המוטציה לא נתפסה — הבדיקה עברה למרות קוד שבור. חור בכיסוי!" >&2
    exit 1
fi
echo "✅ אדום: המוטציה נתפסה ע\"י $test_filter"

# 4. שחזור מה-גיבוי (לא git checkout — עריכות לא-מקומיטות אחרות שורדות)
restore

# 5. test מצופה ירוק
if ! flutter test "$test_filter" >/dev/null 2>&1; then
    echo "❌ אחרי שחזור הבדיקה עדיין נכשלת — השחזור לא תקין?" >&2
    exit 1
fi
echo "✅ ירוק: שוחזר, הבדיקה עוברת"

# 6. רישום אוטומטי ל-mutation_log.md
ts="$(date -Iseconds)"
{
    echo ""
    echo "### $file — $ts (mutation_verify.sh)"
    echo "- תקלה שהוזרקה: \`$sed_expr\`"
    echo "- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע\"י $test_filter)"
    echo "- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅"
    echo "- מסקנה: הבדיקה חזקה — תפסה את המוטציה."
} >> knowledge/mutation_log.md
echo "📝 נרשם ל-knowledge/mutation_log.md"
