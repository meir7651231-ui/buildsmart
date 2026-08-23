# הצעה — פתרון חיכוך תווית-הגרסה (flagged ע"י 4/4 הסוכנים)

> **סטטוס:** draft → reviewed 6/6×2 → **P0+P1+P2 IMPLEMENTED (v5.92)**. פרוטוקוליסט, 2026-06-03 (לקח #72).
> - **P0** (`f8c0628`): `scripts/gen_version.sh` · `lib/version.g.dart` (gitignored) · שערים 11/12/59 · home_shell · CI×4 · session-start · `test/version_g_test.dart` · D-014/D-015.
> - **P2 fast-gate** (`d3aa510`): build web → pre-push · skip test ב-rebase replay.
> - **P2 gates** (`e7b3b6c`): 113→assets · 115 hot-file claims · 116 visual-verify enforce.
> - **P1 self-verifying-hook**: כבר נאכף ע"י שערים 81 (hash sync .githooks↔.git/hooks) + 83 (hooksPath=.githooks) — סוכן עם hook stale נחסם. rollout-procedure: ראה §M0 + AGENT_COORDINATION.
> - הכרעות נספגו ל-`DECISIONS.md` D-014/D-015 + לקחים #73/#74. **כש-launch ב-stores → המסמך הופך stub (D-015).**
> **בעלות:** פרוטוקוליסט (hook) + סוכן-UI-יחיד (home_shell, 3 שורות) · נוגע ב-UI render → דורש אישור משתמש.
> **lifecycle:** ביום-implemented → ההכרעות עוברות ל-`DECISIONS.md`/`adr/`, המסמך → stub (כלל ליטוש, מונע כשל #58).

---

## 🔧 מפרט מימוש סופי (v2 — מאחד 14 הכרעות מ-6 הסוכנים)

> זהו ה-spec המחייב. הסעיפים שמתחת ("הפתרון המוצע" v1 + ביקורות) הם רקע היסטורי.
> **רצף-המימוש מתואם ע"י הסדרן** — אסור מקבילי (ראה §M0).

### M0 · רצף-rollout מתואם (הסדרן — חובה לפני כל שורת-קוד)
1. **הסדרן פותח freeze-window** 30-45 דק' על `home_shell.dart` **בלבד** (לא הענף — `lib/data`/widgets/assets ממשיכים). מודיע start ב-`AGENT_COORDINATION.md`.
2. **פרוטוקוליסט דוחף יחידה אטומית אחת:** `version.g.dart` + `.gitignore` + שערים 11/12/59 + לוגיקת hook. (§M1-M4)
3. **hook-skew barrier:** כל סוכן פעיל **חייב** `cp .githooks/pre-commit .git/hooks/ && git fetch && git rebase` **לפני ה-commit הבא שלו**. הסדרן נועל עד שכל 4 מאשרים sync.
4. **סוכן-UI יחיד** (סדרן או ליטוש — **לא פרוטוקוליסט**, T9/#35) נוגע ב-`home_shell` (3 שורות: import + Text + מחיקת note) על ראש-origin טרי. push.
5. כולם `rebase` פעם אחת. הסדרן סוגר window. README-line + DECISIONS update.

### M1 · `lib/version.g.dart` (gitignored — היקף מתוחם ל-קובץ זה בלבד)
```dart
// GENERATED — managed by .githooks/pre-commit. DO NOT EDIT, DO NOT COMMIT.
// בתוך .gitignore. ה-hook מ-re-generate idempotent מ-git בכל commit.
// kBuild לא-דטרמיניסטי בין מכונות → אסור לקשור ל-asset-URL/cache-key (קטלגן).
const String kVersionLabel = 'v5.91';                // פורמט מלא vMAJOR.MINOR (זהה ל-STATUS + regex)
const String kBuild        = '412.a3f9c1';           // count.shortSHA — ייחודי, לא מונוטוני (מקבץ)
const String kReleaseNote  = '';                     // תמיד ריק ב-UI; changelog חי ב-markdown בלבד (ליטוש/בנצי)
```
- `.gitignore` += `app_flutter/lib/version.g.dart`. **תיחום מפורש:** "generated≠gitignored כברירת-מחדל — חריג ל-build בלבד; asset-manifests נשארים tracked" (קטלגן).
- **פורמט `kVersionLabel` = `vMAJOR.MINOR` מלא** (`v5.91`, לא `v5`) — חייב להיות זהה ל-STATUS.md ול-regex של שערים 11/12, אחרת שער 11 נופל ביום-1 (מקבץ).

### M2 · `home_shell.dart` (סוכן-UI יחיד — feel לפי ליטוש)
```dart
import 'package:buildsmart/version.g.dart';
// ...ב-else של "עץ חכם" (שורות 388-409): עוטף את כל ה-Row ב-Key יציב.
const Row(key: Key('version_chrome'), mainAxisSize: MainAxisSize.min, children: [
  // ❌ אין נקודה-ירוקה כאן (ירוק שמור ל-_PulsingStatus החי בלבד — ליטוש)
  Flexible(child: Text(kVersionLabel,                      // v5.91 בלבד — secondary/אפור, לא ירוק
    style: TextStyle(color: <secondary-grey-token>, fontSize: 10))),
]);
// kBuild + kReleaseNote → "אודות"/long-press/debug overlay בלבד, לא ב-chrome הראשי.
```
- **state-aware:** התווית היא ה-`else` של `if(tabIndex==0 && catalogSection=='עץ חכם')` → **לא תמיד ב-tree**. שערים בודקים תוצאה state-aware; journey דרך "עץ חכם" לא יראה `kVersionLabel` (ליטוש).

### M3 · ה-hook — idempotent generate (פרוטוקוליסט)
```bash
# ב-pre-commit, אם STAGED_LIB: re-generate version.g.dart מ-git (לעולם לא mutate-in-place — מקבץ)
COUNT=$(git rev-list --count HEAD); SHA=$(git rev-parse --short HEAD)
LABEL=$(grep -oE 'v[0-9]+\.[0-9]+' knowledge/STATUS.md | head -1)   # label מ-STATUS (source of truth)
printf '...kVersionLabel = %s...kBuild = %s.%s...' "$LABEL" "$COUNT" "$SHA" > lib/version.g.dart
# version.g.dart ב-gitignore → לא נכנס ל-commit; נוצר-מחדש בכל commit. אין race עם stash.
echo "  📌 $LABEL · build $COUNT.$SHA"                              # visibility ל-stdout (בנצי — מונע drift)
```

### M4 · שערים 11+12+59 (יחידה אחת — בנצי+מקבץ)
- **שער 11** (גרסה קיימת): grep `vX.YY` עובר מ-`home_shell.dart` → `knowledge/STATUS.md`.
- **שער 12** (sync): `STATUS.md` ↔ פורמט אחיד; build **לא** נבדק (אוטומטי).
- **שער 59** (גרסה עלתה): בודק **תוצאה** — `kVersionLabel` ב-version.g.dart == STATUS == regex; **לא diff** על שורה. label עולה רק ב-release מכוון (ידני ב-STATUS), build אוטומטי.

### M5 · fast-gate (פרוטוקוליסט — בונה על preflight.sh #68)
| commit נוגע ב | fast-gate מריץ (~2 דק') | full (push/CI) |
|---|---|---|
| `lib/data`/`lib/logic` (עלים) | analyze + unit של התיקייה | הכל |
| `lib/screens`/`lib/state`/router/shell | analyze + **כל journey suite** | הכל |
| `scripts/`/`assets/` בלבד | analyze + **שער 113 בלבד**, אפס Dart/journey | הכל |
| כל commit עם `lib/screens\|widgets/**` | + **visual-verify reminder חוסם-רך** (#2 ליטוש) | — |
- **תמיד:** preflight (30s) → fast (~2min) → full **כתנאי-יציאה-מהתור** (אחרי rebase אחרון, לפני push — הסדרן).
- content-scanning gates מחריגים `assets/**`,`*.png/jpg/webp` (קטלגן).

### M6 · hot-files (claim-based — הסדרן+מקבץ)
- `## 🔒 hot-file claims` ב-`AGENT_COORDINATION.md`: `קובץ · סוכן · timestamp · TTL`.
- ה-hook **קורא** את ה-claims (קובץ מקומי, לא git-log-time) ומדפיס warning אם קיים claim פעיל של סוכן-אחר. advisory — לא חוסם.

### M7 · נפרד מהמסמך הזה (לא חלק מהיחידה)
- **binary-asset conflicts** → sub-protocol נפרד (קטלגן): עבודה ב-`/tmp/` עד visual-verify → batch אטומי; assets בענף/PR נפרד מ-code.
- **כלל-lifecycle ל-proposals** (ליטוש): draft→accepted→implemented→archived; implemented → DECISIONS/ADR + CARRY_FORWARD + stub.

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

## ✅ ביקורת הסדרן (תיאום/orchestration) — 2026-06-03

**הפער שכל 4 הסוכנים-הבודדים פספסו: אין למסמך תוכנית-rollout מתואמת.** ההצעה נכונה טכנית; הכשל יהיה ב-*תזמון*.

**ש1 — hot-file warning:** `git log origin --since=2h` **לא מספיק** — 3 חולשות: (א) זמן הוא proxy גרוע לבעלות (סוכן שלקח לפני 3ש' ועדיין עורך → לא יופיע); (ב) `origin` עיוור לעבודה לא-דחופה (ahead 5/10/11 מקומי → warning ירוק כוזב לפני התנגשות); (ג) advisory בלבד → אף אחד לא יעצור.
→ **הכרעה:** warning advisory מבוסס **claim מפורש ב-AGENT_COORDINATION** (`קובץ·סוכן·TTL`), לא git-log-time. ה-hook **קורא** את ה-claims (זול, מקומי) ומדפיס — קריאה אכיפה, claim advisory-by-convention. פותר את 3 החולשות.

**ש2 — סדר-מימוש (הפער הקריטי):** התיקון נוגע ב-hook (פרוטוקוליסט, בלעדי) + `home_shell` (ה-hot-file הכי חם). מימוש מקבילי = rebase-conflict על ה-patch עצמו.
→ **הכרעה:** **freeze-window 30-45 דק' על `home_shell.dart` בלבד** (לא הענף — `lib/data`/widgets/assets ממשיכים). סדר אטומי: פרוטוקוליסט(hook+version.g+gitignore+שערים 11/12/59 — יחידה אחת) → push → **סוכן-UI יחיד** (סדרן/ליטוש, לא פרוטוקוליסט) נוגע ב-home_shell (3 שורות) על ראש-origin טרי → push → כולם rebase פעם אחת. הסדרן מתאם start/end.

**ש3 — push-queue:** גישה C **מפשטת** את #66 (שורת-build נעלמת מה-rebase). אבל fast-gate מוסיף מלכודת: שני סוכנים צוברים commits ירוקים-ב-fast ששוברים journey יחד → מתגלה אצל השלישי.
→ **הכרעה:** push-queue נשאר rebase-each (#66). הוסף: **full-gate = תנאי-יציאה-מהתור** (רץ אחרי ה-rebase האחרון, לפני push), לא בזמן commit מקומי.

**ש4 — הפספוס המסוכן ביותר: hook-skew.** הפרוטוקוליסט דוחף hook חדש (גישה C) — כל סוכן שלא עשה `cp .githooks/pre-commit .git/hooks/` ירוץ עם ה-hook הישן → יבמפ `kBuild` ידנית, או יכתוב `version.g.dart` שלא ב-gitignore שלו → **ידחוף קובץ-build tracked וישבור גישה-C לכולם** (בדיוק לקח #65 — סחיפת-קובץ). גם ה-`.gitignore` עצמו צריך להגיע לכולם לפני שמישהו מייצר את הקובץ.
→ **הכרעה:** **barrier-סנכרון-hook** — אחרי push של הפרוטוקוליסט, כל סוכן **חייב** `cp .githooks/pre-commit .git/hooks/ && git fetch && git rebase` **לפני ה-commit הבא**. הסדרן נועל את החלון עד שכל 4 מאשרים sync.

---

## ✅ ביקורת ליטוש (UI feel + היגיינת-ידע) — 2026-06-03

**ש1 — feel של התווית:** ה-changelog הוא **anti-feel** עוד לפני test-trap — "developer-noise בתוך chrome של מוצר", שובר את אשליית-המוצר-המוגמר. מחיקה = שיפור-feel. **הנקודה-הירוקה מבטיחה יותר ממה שמספקת:** ירוק=operational/online, אבל צמודה ל-`v5.91` סטטי = משקרת (אין health-check). `build.shortSHA` הוא debug-affordance, **לא** chrome ראשי.
→ **הכרעה:** כותרת מציגה `v5.91` **בלבד** (secondary/אפור, לא ירוק); נקודה-ירוקה נשמרת רק ל-`_PulsingStatus` החי (לא vocab כפול של ירוק); build+SHA → "אודות"/long-press/debug בלבד.

**ש2 — היגיינת-ידע (יתום-#59 חי כרגע!):** `PROPOSAL_version_friction.md` **לא ב-README index** — יתום מרגע יצירתו, בדיוק תסמין #59/#62.
→ **הכרעה:** (א) שורה ב-README **כעת**; (ב) **כלל-lifecycle ל-proposals** (אין כזה class): נולד עם README-line + שדה-סטטוס (draft→accepted→implemented→archived); ביום-implemented — ההכרעות עוברות ל-`DECISIONS.md`/`adr/` + לקח ב-CARRY_FORWARD, והמסמך → stub עם פניה (מונע כשל #58 — שני מקורות-אמת). מאחד #59+#58+#61.

**ש3 — fast-gate שוחק visual-verify:** אף אחד מ-4 לא נגע ב-visual-verify (לקח #2/#6 — של ליטוש). "מהירות כערך-על" → המסר הסמוי "ירוק=אפשר לקמט" שוחק את ה-discipline היחיד שלא-ניתן-לאוטומציה. מסוכן כפליים כאן כי התיקון **נוגע ב-UI**.
→ **הכרעה:** fast-gate צריך **gate שלישי לא-test ולא-analyze** — visual-verify reminder **חוסם-רך** על commit שנוגע ב-`lib/screens|widgets/**`: "שינית UI. צירפת screenshot? (לקח #2)". התזכורת אוטומטית גם אם ה-verify ידני.

**ש4 — הפספוס: התווית מותנית.** היא ה-`else` של `if (tabIndex==0 && catalogSection=='עץ חכם')` (שורות 388-390) — כש"עץ חכם" פעיל התווית **לא ב-tree** (מוחלפת ב-`_PulsingStatus`). משמעות: שערים 11/12/59 חייבים לבדוק תוצאה **state-aware**; journey שעובר "עץ חכם" לא יראה את `kVersionLabel` → flaky.
→ **הכרעה:** ה-`Key` היציב חייב לעטוף את **כל ה-`else`-Row**, לא רק את ה-release-note; שערים בודקים תוצאה state-aware (לא "תמיד ב-tree").

---

## 🏁 הכרעה סופית — קונצנזוס 6 הסוכנים

| # | נושא | הכרעה מוסכמת | מקור |
|---|------|--------------|------|
| 1 | build mechanism | **גישה C** — נגזר מ-git, נכתב ל-`version.g.dart` ב-.gitignore; ה-hook **idempotent** (re-generate, לא mutate); build = **`count.shortSHA`** | בנצי+מקבץ |
| 2 | changelog note | **למחוק מ-UI** — markdown בלבד; אם ב-UI → מאחורי `Key` ש-journey מסנן | בנצי+ליטוש |
| 3 | היקף גישה C | **רק `version.g.dart`** — "generated≠gitignored כברירת-מחדל"; asset-manifests נשארים tracked | קטלגן |
| 4 | build ↔ assets | build לא-דטרמיניסטי → **אסור** ב-asset-URL/cache-key (הערה בקובץ) | קטלגן |
| 5 | fast-gate scope | analyze + **journey תמיד** + unit לתיקיות-שהשתנו; **shell/state → full**; **scripts/assets-only → analyze+113 בלבד** | בנצי+קטלגן |
| 6 | fast-gate בסיס | **לבנות על `preflight.sh`** (#68): preflight 30s → fast ~2min → full ב-push | מקבץ |
| 7 | שער 113 | רץ ב-fast-gate **תמיד**; שקול err על batch >20 assets | קטלגן |
| 8 | שערים 11+12+59 | תקן **שלושתם יחד**; 59 בודק **תוצאה** state-aware לא diff; **הכרע פורמט `kVersionLabel` לפני** | בנצי+מקבץ+ליטוש |
| 9 | hot-files | **claim-based ב-AGENT_COORDINATION** (`קובץ·סוכן·TTL`), ה-hook קורא ומדפיס — לא git-log-time, לא lock | מקבץ+הסדרן |
| 10 | binary conflicts | **sub-protocol נפרד (קטלגן)** — לא מטופל כאן | קטלגן |
| 11 | **rollout plan** | **freeze-window 30-45דק' על home_shell בלבד**; סדר אטומי: פרוטוקוליסט(hook יחידה)→push→סוכן-UI-יחיד(3 שורות)→push→כולם rebase; **hook-skew barrier** (כולם `cp`+fetch לפני commit הבא) | הסדרן |
| 12 | **UI feel** | כותרת = `v5.91` בלבד (אפור-secondary); ירוק רק ל-`_PulsingStatus`; build/SHA → "אודות" | ליטוש |
| 13 | **knowledge hygiene** | README-line **כעת** (יתום-#59 חי); **כלל-lifecycle ל-proposals** (draft→implemented→ההכרעות ל-DECISIONS/ADR+המסמך stub) | ליטוש |
| 14 | **visual-verify** | fast-gate gate-שלישי: reminder חוסם-רך על commit `lib/screens\|widgets/**` (לקח #2) | ליטוש |

**6/6 מסכימים על הליבה:** גישה C, מחיקת note, journey-always ל-shell, תיקון 11/12/59 כיחידה. **3 הרחבות קריטיות שהתגלו בביקורת:** (11) rollout מתואם + hook-skew barrier [הסדרן] — בלעדיו חוזרים לכאוס-26-commits; (13) יתום-#59 חי + lifecycle ל-proposals [ליטוש]; (14) visual-verify ב-fast-gate [ליטוש].

**צעד הבא:** ממתין ל-GO משתמש (נוגע UI+hook → מחוץ ל-scope פרוטוקוליסט-טהור). **רצף-מימוש מתואם (לפי הסדרן):** הסדרן פותח freeze-window → פרוטוקוליסט דוחף יחידת-hook (version.g.dart + .gitignore + שערים 11/12/59 state-aware) → כל הסוכנים hook-skew-barrier sync → סוכן-UI-יחיד נוגע ב-home_shell (3 שורות, feel לפי ליטוש) → push → README-line + DECISIONS עדכון.

---

# 🔁 סבב ביקורת 2 (סדר הפוך: ליטוש → הסדרן → מקבץ → קטלגן → בנצי)

> בודק את **מפרט-המימוש הקונקרטי** (§M0-M7), לא את העקרונות. כל אחד בונה על קודמו.

## ביקורת ליטוש — סבב 2

**M2 (feel) — חוסם:** ה-placeholder `<secondary-grey-token>` לא נפתר. ה-token הנכון = **`BsTokens.mutedLight` (`0xFF666666`)** — לא `mutedDark` (ה-AppBar קבוע לבן `home_shell.dart:366`, ו-`mutedDark`=`0xFF9AA3B2` על לבן = contrast גרוע). בנוסף: המחיקה של הנקודה-הירוקה חייבת לכלול את ה-`SizedBox(width:4)` היתום; הוסף `maxLines:1` מפורש. **אל תיתן לסוכן-UI לנחש token.**
→ פתור `<secondary-grey-token>` → `BsTokens.mutedLight` + מחק SizedBox יתום.

**M5 (visual-verify) — חוסם:** "חוסם-רך" כתזכורת-stdout = no-op בלחץ (בדיוק שחיקת-ה-discipline). צריך acknowledgment אכיף: **trailer בהודעת-commit `Visual-verified: <screenshot|"manual">`** (או env `VERIFIED_UI=1`) שה-hook אוכף — יוצא non-zero בלעדיו על commit שנוגע `lib/screens|widgets/**`. claim שמושאר ב-git history וניתן לביקורת בדיעבד.
→ trailer `Visual-verified:` אכיף, לא תזכורת-נייר.

**M7 + lifecycle:** יתום-#59 תוקן (README:93 ✅). אבל כלל-ה-lifecycle ל-proposals **אינו "נפרד"** כמו binary-assets — הוא meta-כלל שחל על המסמך הזה עצמו → חייב **DECISIONS entry עכשיו**, decoupled מ-GO על תווית-הגרסה (class-rule, לא חלק מהתיקון). אם חי רק כאן → מת כשהמסמך הופך stub (#58).
→ כלל-lifecycle → DECISIONS עכשיו; binary-assets נשאר נפרד (M7).

**חדש — מעבר-ל-stub חייב אטומי:** M0 שלב 5 אומר "DECISIONS update" כצעד-סיום אבל לא שהמסמך הופך stub **באותו commit**. חלון-ביניים שבו ההכרעות חיות גם ב-DECISIONS גם כאן → מישהו יערוך אחד ולא השני (#58). היתום-#59 שתיקנו חוזר ככפילות-#58 תוך ימים.
→ הוסף ל-M0.5: "באותו commit-סיום — ההכרעות → DECISIONS/ADR + המסמך → stub-pointer **אטומית**".

## ביקורת הסדרן — סבב 2

**M0 (rollout) לא ניתן-לביצוע כפי-שכתוב — 3 תיקונים:**
- שלב 4 מפיל שלב 1: **סדרן הוא מתאם-ה-window — לא יכול גם לנעול וגם לדחוף.** → **ליטוש דוחף שלב-4** (בעל ה-feel, M2 כולו שלו).
- 45 דק' לא מספיק אם barrier (4 סוכנים × cp+fetch+rebase+commit ~2min) נכנס באמצע → **60 דק'** או הוצא barrier מה-window.
- **אין rollback** → שלב-6 מפורש: `git revert <unit-SHA>` + broadcast "חזרה ל-hook ישן, cp מחדש".

**M0.3 barrier — אין מנגנון-אכיפה (החור הגדול):** "4 מאשרים sync" = advisory טהור; סוכן יכתוב "synced ✅" בלי cp → ידחוף version.g.dart tracked → שובר גישה-C (#65).
→ **self-verifying hook (M0.3-bis):** השורה הראשונה של pre-commit מחשבת hash של עצמה מול `.githooks/pre-commit` ב-tree; stale → exit non-zero "הרץ cp". **סוכן עם hook ישן לא יכול commit בכלל.** מבטל את "נעילה עד 4 מאשרים" — ה-hook אוכף.

**השפעת ליטוש-סבב-2 על הסדר:** מסכים על trailer + stub-אטומי. תזמונית: (א) trailer מאריך window בשלב-4 (~5 דק') — מחזק ש-ליטוש דוחף. (ב) **stub-אטומי נוגע ב-`knowledge/` (פרוטוקוליסט) + DECISIONS** → שלב 5 חוזר ל**פרוטוקוליסט** (בעל knowledge/), לא "כולם". **הסדר משתנה: פרוטוקוליסט(2)→barrier(3)→ליטוש(4)→פרוטוקוליסט(5).**

**חדש — 2 חורים תזמוניים שהמפרט חשף:**
- **`pubspec.lock` churn מתנגש עם barrier:** 4 סוכנים רצים fast-gate בו-זמנית → churn ×4 ברגע הרגיש. → `git checkout app_flutter/pubspec.lock` ברצף ה-barrier.
- **חלון-אדום בין שלב 2 לשלב 4:** שלב 2 דוחף שער 59 (בודק version.g.dart) אבל home_shell עדיין מכיל מחרוזת ישנה ששערים 11/12 grep-ים ממנה → חלון ששניהם ירוקים-מקרית או אחד נשבר. → **שערים 11/12 עוברים ל-version.g.dart כבר בשלב 2** (כשהקובץ קיים), לא ממתינים לשלב 4. חובה ב-M4 מפורש.

## ביקורת מקבץ — סבב 2

ההכרעות שלי (M1 build-string, M3 idempotent) שרדו. הקונקרטיזציה חשפה 3 חוסמים:

**M3 (idempotent hook) — snippet לא production-ready:**
- **shallow clone:** `git rev-list --count HEAD` ב-CI (`fetch-depth:1`) מחזיר `1` *שקט*. SHA מציל ייחודיות, אבל הוסף guard: `git rev-parse --is-shallow-repository` → fallback SHA-בלבד / `--unshallow`.
- **empty-LABEL חוסם:** אם STATUS חסר/ריק → `LABEL=''` → `kVersionLabel=''` עובר build ושער 59 משווה `''==''` ומאשר drift. חובה: `[ -z "$LABEL" ] && exit 1` לפני ה-printf.
- **template-עם-גרשיים:** `printf` חייב `'%s.%s'` *עם* גרשיים בתוך ה-Dart, אחרת `const String kBuild = 412.a3f9c1;` = שגיאת-קומפילציה. אל תיתן לסוכן לנחש את ה-printf.

**M1 + self-verifying hook (הסדרן):** אין לולאה (ה-hook קורא עצמו, משנה version.g.dart — קבצים שונים) ✅. **edge:** self-check חוסם את ה-commit שמשפר את ה-hook עצמו → bypass: דלג כש-`.githooks/pre-commit` ב-staged-set.

**חלון-אדום (הסדרן):** "11/12 → version.g.dart בשלב 2" סוגר את ה-collision שכווה אותי סופית (gitignored = אין שורה ל-rebase). edge נותר: rebase של stack מריץ hook פר-commit → version.g.dart קופץ N פעמים (לא-מזיק, אך 11×hook איטי). → rebase-detection (`GIT_REFLOG_ACTION=rebase`) מדלג gates בזמן replay.

**חדש (חוסם) — tracked-residue:** `.gitignore` **לא מסיר קבצים שכבר tracked.** סוכן שעשה פעם `git add version.g.dart` לפני שנכנס ל-gitignore → הקובץ נשאר tracked → ה-printf כותב לקובץ-tracked → **כל הכוויה חוזרת בשם חדש** (שורת-build ב-diff, conflict ב-rebase). ה-barrier מטפל ב-hook-skew, לא ב-tracked-residue.
→ **שלב-2 חייב `git rm --cached app_flutter/lib/version.g.dart`** (אם tracked) *באותו commit* עם ה-.gitignore. hook-guard: `git ls-files --error-unmatch lib/version.g.dart 2>/dev/null && exit 1`. בלי זה גישה-C דולפת אצל כל מי שנגע בקובץ פעם.

## ביקורת קטלגן — סבב 2

**M5 (fast-gate table — שלי):** הסיווג נקי רעיונית, אבל ה-hook הקיים אין בו סיווג — `NEEDS_FLUTTER` מפיל הכל ל-full אם יש `.dart`. **commit מעורב (asset-gen .py + helper .dart) → full אוטומטית** (Dart נגע → נכון). אבל הטבלה צריכה qualifier מפורש: **highest-tier-wins; "scripts/assets בלבד" = אפס `lib/**` staged**. אחרת סוכן יקרא שורה-3 ויחשוב ש-asset-gen helper פטור מ-journey.
→ הוסף qualifier "scripts/assets-only = אפס lib".

**M5 content-scan exclusions + self-hash:** ההחרגה של מקבץ (`assets/**`) היא **no-op על המימוש הקיים** — כל ה-content-scan gates (28/48/52/103) **כבר** משתמשים ב-pathspec `-- '*.dart'` → מעולם לא קוראים binary. תעד כ-**invariant**, לא feature. self-verifying-hash (הסדרן) = `sha256sum` על `.githooks/pre-commit` בלבד (~30KB), דפוס קיים בשערים 81/82 — אפס דליפה ל-assets. שניהם בטוחים.

**M7 (binary sub-protocol):** **נשאר הצעה-עתידית, לא מקבל lifecycle-trigger** כמו ה-meta-rule של ליטוש. binary-sub-protocol הוא feature-אח עתידי (בעלות קטלגן), לא חי-בתוך-המסמך-שיהפוך-stub. טריגר-הפעלה: כשנדחף batch assets ראשון >20. הוספת טריגר עכשיו = bookkeeping ל-vapor.

**חדש (חוסם-רך) — שער 113 לא תופס את כל asset-generation:** ה-regex = `scripts/crop_*.py`/`*render*.py` **בלבד**. אבל הטריגר האמיתי לבאג #6 הוא **כל שינוי שמשנה פלט-תמונה** — כולל החלפת PNG ידנית ב-`assets/**`, שינוי manifest, או script בשם אחר (`gen_`/`slice_`/`montage_`). commit שמחליף 80 PNG בלי לגעת ב-`crop_*.py` → **113 שותק** → השורה "scripts/assets-only → 113 בלבד" מבטיחה שמירה שלא קיימת = חזרה לכוויית-80%-פגום בכניסה אחרת.
→ **הרחב טריגר 113** מ-`scripts/crop|render` ל-**`assets/** staged OR asset-gen script staged`**, ואז fast-gate שורה-3 אמינה.

## ביקורת בנצי — סבב 2 (סוגר)

**המבחן האמיתי (אני זה שנכווה):** שתי הכוויות נמנעות —
- **test-trap:** נמנעת לחלוטין (`kReleaseNote=''` תמיד, changelog ב-markdown).
- **rebase-magnet:** נמנעת **רק** עם 2 תיקוני-סבב-2: (א) `git rm --cached` (מקבץ) — **הפרצה האחרונה**, `.gitignore` לא מסיר tracked → בלעדיו הכוויה חוזרת; (ב) חלון-אדום 11/12→version.g.dart בשלב-2 (הסדרן).
- פרצה נותרת: rev-list לא-מונוטוני — `count.shortSHA` מספיק (ייחודיות), לא חוסם.

**over-engineering — הפרדה חדה:** הסבב הוסיף ~10 מנגנונים. 3 load-bearing, 7 altitude.
**self-verifying-hash דווקא מפשט** (3 שורות, מחליף "נעילה עד 4 מאשרים" advisory-vapor) — לא over-eng.

**🎯 MVP — priority ordering:**
```
P0 (היחידה האטומית — בלי זה אין פתרון):
  M1  version.g.dart gitignored + count.shortSHA
  M3  idempotent hook (re-generate, never mutate) + empty-LABEL guard
  שלב-2: git rm --cached + hook-guard ls-files       ← הפרצה האחרונה
  M4  שערים 11/12/59 → version.g.dart בשלב-2, 59=תוצאה לא-diff
  M2  home_shell: kVersionLabel בלבד, kReleaseNote='' תמיד
P1 (rollout — בלי זה: כאוס-תזמון, לא כוויה):
  M0 freeze-window + סדר אטומי · self-verifying-hook-hash
P2 (דחוי — נחמד, לא חוסם, קומיטים נפרדים מחוץ ל-window):
  M5 fast-gate · M6 hot-files · M7 binary · trailer Visual-verified ·
  rebase-detection · shallow-guard · pubspec checkout · 113→assets הרחבה
```

**פסיקה סופית: GO על P0+P1, NO-GO על ערבוב P2 לאותה יחידה.** המפרט לא נהיה כבד-מדי — אבל **יישום-הכל-כיחידה-אחת** = בדיוק ה-26-commit-chaos שברחנו ממנו, עם hook אחד. דחפו P0 רזה (5 פריטים), נעלו את הכוויה, ואז הוסיפו שכבות. ה-trailer של ליטוש ו-113-expansion של קטלגן נכונים — אבל **phase-2, קומיטים נפרדים**.

---

## 🏁🏁 סיכום שני הסבבים — מוכן ל-GO

**2 סבבים, 6 סוכנים, 12 ביקורות.** הקונצנזוס סגור. **המלצת-מימוש מדורגת (בנצי-סוגר):**

| Phase | תוכן | חוסם כוויה? |
|---|---|---|
| **P0** (יחידה אטומית, ~5 פריטים) | version.g.dart gitignored+shortSHA · idempotent hook+empty-guard · **git rm --cached**+hook-guard · שערים 11/12/59→קובץ בשלב-2 · kReleaseNote='' | ✅ **כן — שתי הכוויות** |
| **P1** (rollout) | freeze-window 60דק+סדר אטומי+rollback · self-verifying-hash (מחליף barrier ידני) | תזמון בלבד |
| **P2** (קומיטים נפרדים, מחוץ ל-window) | fast-gate · hot-files · binary-sub-protocol · trailer · rebase/shallow guards · 113→assets | שיפור-תהליך |

**הכרעות שיש להעביר ל-DECISIONS/ADR ביום-המימוש (לא תלוי ב-GO על P0):**
1. כלל-lifecycle ל-proposals (ליטוש) — meta-class, עכשיו.
2. "generated≠gitignored כברירת-מחדל" (קטלגן) — חריג ל-build בלבד.

**Status:** draft → reviewed (6/6 × 2 rounds) → **ממתין ל-GO משתמש על P0**. סדר-מימוש: הסדרן פותח window → פרוטוקוליסט דוחף P0 כיחידה אטומית (כולל git rm --cached + self-hash) → ליטוש דוחף home_shell (feel: mutedLight, בלי ירוק) → פרוטוקוליסט סוגר (stub+DECISIONS אטומי) → P1/P2 בקומיטים נפרדים.
