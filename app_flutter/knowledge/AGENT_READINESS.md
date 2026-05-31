# AGENT_READINESS — רשימת בדיקות לפני מסירת שליטה לסוכן

> עדכון אחרון: 2026-05-31 | גרסה: v1.0

## מה זה אומר "מוכן לסוכן"?

הפרוטוקול רץ לבד בלי התערבות אנושית לפעולות שגרתיות.
הסוכן יכול לכתוב קוד, לבדוק, לתקן — **הפרוטוקול עוצר אותו לפני כל נזק.**

## רשימת בדיקה לפני מסירה (run this before handing off)

### שלב 1 — בדוק שהסביבה תקינה

```bash
cd /home/user/buildsmart

# 1.1 ענף נכון
git branch --show-current   # חייב: claude/*

# 1.2 hooks פעילים
git config --get core.hooksPath   # חייב: .githooks
ls -la .githooks/                 # חייב: pre-commit pre-push commit-msg (כולם executable)

# 1.3 pre-tool hook קיים
ls -la .claude/hooks/pre-tool.sh  # חייב להיות קיים
cat .claude/settings.json | grep -c '"PreToolUse"'   # חייב: 1

# 1.4 Flutter זמין
export PATH="/home/user/flutter/bin:$PATH"
flutter --version                 # חייב לעבוד
```

### שלב 2 — בדוק שהפרוטוקול חוסם

```bash
cd /home/user/buildsmart

# 2.1 חסימת דחיפה ל-main
git checkout main 2>/dev/null && echo "❌ עברת ל-main" || echo "✅ נחסמת"

# 2.2 חסימת --no-verify (pre-tool.sh)
# נסה: echo '{"tool_name":"Bash","tool_input":{"command":"git commit --no-verify -m x"}}' | .claude/hooks/pre-tool.sh
# תוצאה צפויה: exit 2 + "🔒 חסום"

# 2.3 חסימת force push
# נסה: echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin claude/x"}}' | .claude/hooks/pre-tool.sh
# תוצאה צפויה: exit 2 + "🔒 חסום"
```

### שלב 3 — בדוק שהבדיקות עוברות

```bash
cd /home/user/buildsmart/app_flutter
export PATH="/home/user/flutter/bin:$PATH"

flutter analyze                        # 0 errors
flutter test                           # כל הבדיקות עוברות
flutter test test/stuck_regression_test.dart  # 18+ tests, 0 failures
flutter test test/knowledge_protocol_test.dart  # 11 gates, 0 failures
```

### שלב 4 — בדוק שמצב הריפו נקי

```bash
cd /home/user/buildsmart

# 4.1 אין conflicts
git status | grep -c "CONFLICT" && echo "❌ יש conflicts" || echo "✅ נקי"

# 4.2 גרסאות מסונכרנות
V_SHELL=$(grep -oE "v[0-9]+\.[0-9]+" app_flutter/lib/screens/home_shell.dart | head -1)
V_STATUS=$(grep -oE "v[0-9]+\.[0-9]+" app_flutter/knowledge/STATUS.md | head -1)
[[ "$V_SHELL" == "$V_STATUS" ]] && echo "✅ גרסאות מסונכרנות ($V_SHELL)" || echo "❌ drift: shell=$V_SHELL status=$V_STATUS"

# 4.3 session_plan תקין
grep -q "^Owner:" app_flutter/knowledge/session_plan.md && echo "✅ Owner קיים" || echo "❌ חסר Owner"
grep -q "^Scope:" app_flutter/knowledge/session_plan.md && echo "✅ Scope קיים" || echo "❌ חסר Scope"
```

### שלב 5 — ריצת dry-run על משימה קטנה

לפני מסירת משימה גדולה לסוכן, תן לו **משימה בטוחה קטנה**:
1. "תוסיף שורת הערה ל-WIRING.md" — בדוק שהוא לא פרץ פרוטוקול
2. "תעדכן את גרסה ב-STATUS.md" — בדוק שגרסה מסונכרנת
3. "תריץ flutter test" — בדוק שהוא מפרש תוצאות נכון

---

## מפת סיכונים

| סיכון | מנגנון ההגנה | סטטוס |
|-------|-------------|-------|
| סוכן דוחף ל-main | pre-push חוסם | ✅ פעיל |
| סוכן עוקף hooks (`--no-verify`) | pre-tool.sh חוסם | ✅ פעיל |
| סוכן עורך קבצי הגנה | pre-tool.sh + bypass file | ✅ פעיל (M2) |
| סוכן עושה force push | pre-tool.sh חוסם | ✅ פעיל |
| פרוטוקול עצמו תקוע (emergency) | .emergency_token | ✅ פעיל (M4) |
| אנטי-פטרן ידוע חוזר | gate 103 + regression tests | ✅ פעיל (M5) |
| קוד לא עובר tests | gate 31-45 | ✅ פעיל |
| ענף לא נכון | gate 1 | ✅ פעיל |
| Branch protection ל-main | GitHub Settings | ⚠️ דורש הגדרה ידנית (M1) |
| זיוף author | commit signing | ⬜ אופציונלי (M6) |

---

## סטטוס בשלות (מעודכן)

| # | חסם | סטטוס | הערה |
|---|-----|--------|------|
| M1 | Branch protection GitHub | ⚠️ ידני | ראה PROTOCOL_ENFORCEMENT.md |
| M2 | .allow_protocol_edit bypass | ✅ נסגר | דורש age≤24h + 30+ chars |
| M3 | לא נבדק עם סוכן אמיתי | ✅ תיעוד | רשימת בדיקה זו |
| M4 | אין emergency stop | ✅ נסגר | .emergency_token + env var |
| M5 | false positives בstuck_log | ✅ נסגר | NOTE: לא מייצר regression test |
| M6 | אין commit signing | ⬜ אופציונלי | GPG — ניתן לדלג |
| M7 | לא cross-platform | ✅ נסגר | Flutter paths: Linux/macOS/Windows |

**מסקנה:** M2, M3, M4, M5, M7 נסגרו. M1 דורש הגדרה ידנית בגיטהאב. M6 אופציונלי.

---

## הגדרת Emergency Token (פעם אחת בלבד)

```bash
# הרץ רק פעם אחת, על המכונה שלך:
python3 -c "import secrets; print(secrets.token_hex(16))" > /home/user/buildsmart/.emergency_token
echo ".emergency_token" >> /home/user/buildsmart/.gitignore  # לא לדחוף לריפו!
```

כדי להפעיל emergency disable:
```bash
export BUILDSMART_EMERGENCY_DISABLE="$(cat /home/user/buildsmart/.emergency_token)"
# ... פעולת חירום ...
unset BUILDSMART_EMERGENCY_DISABLE
```

> ⚠️ לא לשתף את ה-token, לא לדחוף לריפו, לא להכניס לסביבות CI.
