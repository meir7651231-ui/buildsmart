# הצעה — פתרון חיכוך תווית-הגרסה (flagged ע"י 4/4 הסוכנים)

> **סטטוס:** טיוטה לביקורת בנצי. לא מיושם. פרוטוקוליסט, 2026-06-03 (לקח #72).
> **בעלות:** פרוטוקוליסט (hook + gate 59/12) · נוגע ב-UI render → דורש אישור משתמש.

---

## הבעיה (verbatim מהדוחות)

השורה היום (`home_shell.dart:399`):
```dart
'v5.91 · 1.6.48 · 🚚 בנצי #4 — חלונית "לאן לשלוח" לא-מחייבת בראש סיכום-ההזמנה...'
```
מערבבת **3 concerns** במחרוזת אחת שמרונדרת בכל מסך:

1. **`v5.91`** — תווית-גרסה human (semantic).
2. **`1.6.48`** — build number.
3. **`🚚 בנצי #4 — ...`** — changelog חופשי.

→ **שני כשלים:**
- **conflict-magnet:** כל סוכן עורך את אותה שורה בכל commit. rebase מתנגש (v5.84/85/86/87 re-number ידני).
- **test-trap:** ה-changelog מרונדר בכל מסך → בנצי שם "הזמן עכשיו"/"אישור הזמנה" → שבר 10 journey tests.

---

## הפתרון המוצע — הפרדת 3 ה-concerns + הסרת העריכה הידנית

### שלב 1 — קובץ נפרד `lib/version.g.dart`
```dart
// GENERATED — managed by .githooks/pre-commit.
// kBuild נכתב אוטומטית ע"י ה-hook. אל תערוך ידנית.
// kVersionLabel + kReleaseNote — עריכה מכוונת בלבד (release), לא בכל commit.
const String kVersionLabel = 'v5';        // major.minor — bump רק ב-release מכוון
const int    kBuild        = 48;          // hook מבמפ אוטומטית (+1) — אף סוכן לא נוגע
const String kReleaseNote  = '';          // ריק by default; טקסט-release קצר בלבד
```

### שלב 2 — `home_shell.dart` קורא, לא מכיל
```dart
import 'package:buildsmart/version.g.dart';
// ...
Text('$kVersionLabel · build $kBuild${kReleaseNote.isEmpty ? '' : ' · $kReleaseNote'}', ...)
```

### שלב 3 — ה-hook מבמפ `kBuild` אוטומטית
ב-`.githooks/pre-commit`, אם יש `STAGED_LIB` (נגעת בקוד):
```bash
# קרא kBuild נוכחי, +1, כתוב חזרה, stage את version.g.dart
CUR=$(grep -oE 'kBuild *= *[0-9]+' lib/version.g.dart | grep -oE '[0-9]+')
NEW=$((CUR + 1))
sed -i "s/kBuild *= *[0-9]*/kBuild = $NEW/" lib/version.g.dart
git add lib/version.g.dart
```

### שלב 4 — שער 59 משתנה
**במקום** "האם `v5.XX` עלה ב-home_shell" (ידני, conflict-prone)
**ל-** "האם `version.g.dart` staged + kBuild עלה" (אוטומטי).
שער 12 (sync): `kVersionLabel` ↔ STATUS.md בלבד (לא build — build אוטומטי).

---

## ה-tradeoff הפתוח (לביקורת בנצי)

**גישה A — stored + hook auto-bump (לעיל):** `kBuild` נשמר בקובץ, hook מבמפ.
- ✅ פשוט, גלוי בקוד, אין תלות ב-build-time injection.
- ⚠️ ב-rebase של commits מרובים, שורת `kBuild` עדיין יכולה להתנגש (כל commit שינה אותה). פחות חמור מהיום (שורה ייעודית, לא מעורבת ב-UI), אבל לא אפס.

**גישה B — derived from git (`git rev-list --count HEAD`):** build מחושב ב-build-time דרך `--dart-define`, **לא נשמר** בקובץ.
- ✅ **אפס conflict** — אין שורה לשמור.
- ⚠️ דורש `--dart-define=BUILD=$(git rev-list --count HEAD)` בכל `flutter build/run` → צריך wrapper script, ו-dev שמריץ ידנית בלי הflag יראה build=0.

**המלצת פרוטוקוליסט:** גישה A. ה-conflict על שורת-build בודדת בקובץ ייעודי הוא טריוויאלי (תמיד "קח את הגבוה"), בעוד גישה B מוסיפה תלות-build שתשבור dev-loop ידני. אבל — שאלה לבנצי: האם ה-rebase-conflict על kBuild עדיין מטריד מספיק כדי להצדיק את גישה B?

---

## פתרון נלווה — fast pre-gate (flagged ע"י 3 סוכנים)

שער מלא = ~15-20 דק'/commit (935 כרטיסים + build). הצעה:
- **fast pre-gate (commit מקומי):** `flutter analyze` + בדיקות-האזור-שהשתנה בלבד (~2 דק').
- **full gate (push/CI):** כל הסוויטה + build web + appbundle.
- מימוש: ה-hook מזהה אם זה commit מקומי (`FAST=1`) או push (`pre-push` hook / CI) ובוחר היקף.

---

## שאלות ממוקדות לבנצי
1. גישה A (stored auto-bump) או B (derived from git)? מה שובר פחות?
2. ה-changelog note — להשאיר `kReleaseNote` (קצר, מכוון) או למחוק לגמרי מה-UI?
3. fast pre-gate — איזה "אזור שהשתנה" tests להריץ? לפי תיקיית-הקובץ-שהשתנה? יש סיכון לפספס רגרסיה חוצת-מודולים?
4. האם פספסתי concern שראית בשטח (אתה הכי נכווית מזה)?
