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

---

## ✅ ביקורת בנצי (2026-06-03) — הכרעות מעודכנות

בנצי (שנכווה ישירות) ביקר את ההצעה. **התובנות שלו גוברות על המלצותיי המקוריות** — הוא הפריד שתי כוויות שערבבתי:
- **כוויה 1 (test-trap):** טקסט-כפתור במחרוזת מרונדרת → 10 journey tests מתו.
- **כוויה 2 (rebase-magnet):** הענף זז +11, כל קונפליקט על שורת-הגרסה.

### ש1 — גישה C (לא A): build נגזר מ-git → קובץ gitignored
בנצי דחה את A: ב-**rebase** של commit-stack, כל commit שינה `kBuild` (47→48→49) ו-origin כבר ב-52 → קונפליקט על **כל** commit ב-stack. בדיוק מה שכווה אותו. B (`rev-list --count`) אפס-conflict אבל `build=0` ב-dev מאבד את ה-signal.
**גישה C המנצחת:** ה-hook מחשב `kBuild=$(git rev-list --count HEAD)` וכותב ל-`version.g.dart` ש**ב-.gitignore** (לא tracked). אפס-conflict (אין שורה למזג) + אין build=0 (תמיד נגזר). CI/build עם fallback אם הקובץ חסר. build לא-דטרמיניסטי בין מכונות לפני push — אבל זה build-number, לא נכונות.

### ש2 — למחוק `kReleaseNote` מה-UI לחלוטין
בנצי נחרץ: `kReleaseNote` הוא אותו tar-pit בקובץ אחר. שדה-טקסט-חופשי מרונדר → סוכן ישים שם טקסט-כפתור שוב → journey tests יישברו שוב. **changelog חי רק ב-markdown** (`STATUS.md`/`CARRY_FORWARD.md`). אם UI-changelog נדרש מוצרית — מאחורי `Key('release_note')` ש-journey tests **מסננים במפורש**.

### ש3 — fast-gate = analyze + כל ה-journey suite **תמיד**
scope-by-directory **מסוכן** ובדיוק יפספס את הבאג של בנצי: הוא נגע ב-`home_shell` (shell) ושבר journey tests חוצי-מודול. fast-gate שרץ רק על "screens/" היה מאשר ירוק → 10 כשלים מתגלים רק ב-push.
**כלל:** (1) תמיד analyze מלא; (2) תמיד **כל ה-journey/integration suite** (cross-module guard, בד"כ מיעוט); (3) unit/widget — רק תיקיות שהשתנו; (4) shell/router/state-גלובלי (`home_shell`, providers משותפים) → **תמיד מפעיל full journey**, אף פעם לא scope מצומצם.

### ש4 — הפספוס הקריטי: לתקן שערים 11+12+59 **יחד**
1. **שער 59 הוא ה-conflict-magnet האמיתי** — הוא דורש שורת `+...vX.YY` ב-diff של `home_shell`, וזה מה שמאלץ עריכה ידנית בכל commit. בגישה C הקובץ gitignored → שער 59 חייב לבדוק **תוצאה** (build נגזר תקין), לא **diff**. שער שדורש diff = החזרת כל הבעיה בשם חדש.
2. **שערים 11+12 grep-ים `vX.YY` מ-`home_shell.dart`** (שורות 139-142). אחרי ההפרדה ל-`version.g.dart` המחרוזת תזוז → 11/12 יישברו/יתפסו match שגוי. ה-grep חייב לעבור ל-`version.g.dart`. **חייבים לתקן את שלושת השערים באותו patch.**
3. **drift שקט חדש:** build אוטומטי-נסתר → סוכן ישכח לבמפ `kVersionLabel` ב-release מכוון. שער 12 (label↔STATUS) חייב להישאר חזק + ה-hook ידפיס את ה-label ל-stdout בכל commit (לשמר visibility שאיבדנו).

### TL;DR — העיצוב הסופי המוסכם
| נושא | הכרעה |
|---|---|
| build | **גישה C** — git-derived → `version.g.dart` ב-.gitignore |
| changelog | **למחוק מ-UI** — markdown בלבד (או `Key` מסונן) |
| fast-gate | analyze + **כל journey תמיד** + unit לתיקיות-שהשתנו; shell/state → full |
| שערים | תקן **11+12+59 יחד**; 59 בודק תוצאה לא diff; 11/12 grep ל-version.g.dart |
| visibility | hook מדפיס `kVersionLabel` ל-stdout בכל commit |

**נימוק-על (בנצי):** הכאב לא מ-render ולא מ-git — אלא מ**שער שאילץ עריכה ידנית של שורה משותפת** + **טקסט-מוצר בעץ-ה-tests**. כל פתרון שמשאיר אחד מהשניים — מחזיר את הכוויה בשם חדש.
