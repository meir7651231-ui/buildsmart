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

---

## ✅ ביקורת קטלגן (assets/crops) — 2026-06-03

**ש1 — fast-gate ו-asset work:** crop scripts (`scripts/crop_*.py`) לא מפעילים את בלוק `STAGED_LIB` — הם נכנסים ל"לא נגעתי בקוד". fast-gate שמסנן "unit לפי תיקייה" ירוץ 0 Dart tests על commit-של-crop — זה **טוב**, אבל "journey תמיד" של בנצי עיוור על asset-commit = 15-דק'-לחינם שהרגו לי איטרציה. הסיכון ההפוך (תמונות מאיטות) הוא דרך ה-**git layer**, לא ה-tests: שער שעושה `git diff --cached` content-scan בלי `:(exclude)` יקרא מגה-בייטים.
→ **הכרעה:** שורה רביעית בטבלת fast-gate: **"commit שכולו scripts/assets → analyze + שער 113 בלבד, אפס Dart/journey"** + content-scanning gates מחריגים `assets/**` ו-`*.png/jpg/webp`.

**ש2 — גישה C ו-R2:** הזרימה שלי לא תלויה ב-`kBuild`. מסכים עם בנצי על C. **מלכודת:** אם אי-פעם cache-busting לפי build (`?v=$kBuild`) — C שובר אותו שקט (build לא-דטרמיניסטי בין מכונות → cache-miss/asset כפול). כרגע אין coupling כזה (`kImageBaseUrl` סטטי).
→ **הכרעה:** C מאושר. הערה ב-`version.g.dart`: "kBuild לא-דטרמיניסטי — אסור לקשור ל-asset-URL/cache-key."

**ש3 — binary-repo = בעיה נפרדת:** ההצעה פותרת **text**-conflict על `home_shell`; לא נוגעת ב-**binary**-conflict על `assets/` (89-172 תמונות ש-git לא ממזג). אל תיצור אשליית-פתרון.
→ **הכרעה:** משפט מפורש "binary-asset conflicts = sub-protocol נפרד (קטלגן)". קטלגן יכתוב asset-staging sub-protocol (עבודה ב-`/tmp/` עד visual-verify → batch אטומי; assets בענף/PR נפרד מ-code).

**ש4 — פספוס:** (1) **שער 113 הוא `warn` ולא חוסם** — אם fast-gate ידלג על warn-gates למהירות, 113 ייעלם בדיוק ב-crop-commit. **113 חייב לרוץ ב-fast-gate תמיד** (זול — רק `git diff --name-only`); שקול שדרוג ל-err על batch >20 assets. (2) **תקדים מסוכן:** `version.g.dart` ב-gitignore → מישהו יחיל "generated→gitignore" על **asset-manifest** שחייב להיות tracked (ה-app טוען ממנו).
→ **הכרעה:** (א) שער 113 רץ ב-fast-gate תמיד; (ב) **תחם את גישה-C ל-`version.g.dart` בלבד** במפורש — "generated≠gitignored כברירת-מחדל; חריג ל-build-number בלבד".

---

## ✅ ביקורת מקבץ (bug-fixer, hot-files) — 2026-06-03

**ש1 — התנגשות-גרסה (גישה C):** פותר את הכוויה שלי כמעט לגמרי (השורש = re-number ידני של stack כש-origin קפץ). **edge-case שבנצי פספס:** `git rev-list --count HEAD` **לא מונוטוני בין branches** ומשתנה רטרואקטיבית ב-rebase → שני builds מקבילים יכולים לקבל **אותו מספר**. שובר את ההבטחה ש-build עולה מונוטונית (QA: "באג ב-build 412" → יש שניים).
→ **הכרעה:** C, אבל build = **`count.shortSHA`** (`412.a3f9c1`), לא count לבד — SHA נותן ייחודיות במקום מונוטוניות בלתי-אפשרית.

**ש2 — עץ-עבודה משותף (הכוויה הקשה ביותר):** ההצעה לא נוגעת בזה. תווית-הגרסה היא רק התסמין הגלוי; השורש = `home_shell` בעלות-משותפת. C **מקטין** שטח-מגע (מסיר שורת-גרסה) אבל ה-shell עדיין hot (router/tabs/FAB).
→ **הכרעה:** צריך שכבה נוספת — **לא lock פורמלי** (כבד). מינימום: **advisory hot-file warning ב-hook** — `git log origin/<branch> --since=2h -- <hot-files>`; אם סוכן אחר נגע ב-2 שעות → `⚠️ בנצי נגע ב-home_shell לפני 18 דק' — rebase לפני שתמשיך`. לא חוסם, מאיר לפני commit. עתידי: לפצל `home_shell` לאזורים (tabs/FAB/router נפרדים).

**ש3 — fast-gate ובידוד:** הבידוד-הכושל שלי = `stash בלי path-filter` (בעיית-זרימה, לא מהירות). fast-gate לא מתקן את ה-stash — **אבל** השער-האיטי **החמיר** את הבידוד (כל ניסיון = רבע-שעה → ניחשתי במקום לבדוק). מסכים עם בנצי: shell/state → full journey.
→ **הכרעה:** fast-gate שווה כ**מאיץ-בידוד**. חייב **לבנות על `scripts/preflight.sh` הקיים** (לקח #68), לא מקביל: preflight (30s) → fast-gate (analyze+journey ~2min) → full (push).

**ש4 — פספוס (קריטי):** (1) ה-hook ינסה לכתוב `version.g.dart` **באמצע `git commit`** — ריצת-מירוץ עם stash/partial-tree. אם הקובץ קיים-אבל-stale, C לא הגדיר מה קורה.
→ **הכרעה:** ה-hook **idempotent — תמיד re-generate מ-git, לעולם לא mutate-in-place**. (2) **שער 12 ישבר ביום-1:** אם `kVersionLabel='v5'` (בלי minor) אבל STATUS='v5.91', ה-regex `v[0-9]+\.[0-9]+` לא יתפוס → שער 11 "גרסה חסרה". בנצי אמר "תקנו 11+12 יחד" אבל לא ראה שה-**פורמט** משתנה.
→ **הכרעה:** הכרע פורמט `kVersionLabel` (`v5` או `v5.91`) **לפני** כתיבת השערים; regex 11/12 + STATUS + הקובץ — כולם אותו פורמט באותו patch.

---

## 🏁 הכרעה סופית — קונצנזוס 4 הסוכנים

| # | נושא | הכרעה מוסכמת | מקור |
|---|------|--------------|------|
| 1 | build mechanism | **גישה C** — נגזר מ-git, נכתב ל-`version.g.dart` ב-.gitignore; ה-hook **idempotent** (re-generate, לא mutate); build = **`count.shortSHA`** | בנצי+מקבץ |
| 2 | changelog note | **למחוק מ-UI** — markdown בלבד; אם ב-UI → מאחורי `Key('release_note')` ש-journey מסנן | בנצי |
| 3 | היקף גישה C | **רק `version.g.dart`** — "generated≠gitignored כברירת-מחדל"; asset-manifests נשארים tracked | קטלגן |
| 4 | build ↔ assets | build לא-דטרמיניסטי → **אסור** ב-asset-URL/cache-key (הערה בקובץ) | קטלגן |
| 5 | fast-gate scope | analyze + **journey תמיד** + unit לתיקיות-שהשתנו; **shell/state → full journey**; **scripts/assets-only → analyze+113 בלבד** | בנצי+קטלגן |
| 6 | fast-gate בסיס | **לבנות על `preflight.sh`** (לקח #68): preflight 30s → fast-gate ~2min → full ב-push | מקבץ |
| 7 | שער 113 | רץ ב-fast-gate **תמיד**; שקול err על batch >20 assets | קטלגן |
| 8 | שערים 11+12+59 | תקן **שלושתם יחד**; 59 בודק **תוצאה** לא diff; **הכרע פורמט `kVersionLabel` לפני** (regex+STATUS+קובץ זהים) | בנצי+מקבץ |
| 9 | hot-files | **advisory warning ב-hook** (`git log origin --since=2h -- home_shell`) — לא lock; עתידי: פיצול shell | מקבץ |
| 10 | binary conflicts | **sub-protocol נפרד (קטלגן)** — לא מטופל כאן; אל תיצור אשליית-פתרון | קטלגן |

**4/4 הסוכנים מסכימים:** גישה C (לא A), מחיקת note מ-UI, journey-always ל-shell, ותיקון שערים 11/12/59 כיחידה אחת. שתי הרחבות מעבר ל-scope המקורי: (ט) advisory hot-files, (י) asset sub-protocol — שתיהן נפרדות מהתיקון הזה.

**צעד הבא:** ממתין לאישור משתמש לתחילת מימוש (נוגע ב-UI + hook → מחוץ ל-scope פרוטוקוליסט-טהור, דורש GO). סדר-מימוש מומלץ: שערים 11/12/59 כיחידה → `version.g.dart` + idempotent hook → מחיקת note → fast-gate על preflight.
