# W1-B2 · חבילת-החלטה — טריגרי-פרודקשן + גורל PR #5 / #59

> יעד: B1/B2 (שרשרת-השחרור). סטטוס: **טיוטה להחלטת-מאיר**. שום דבר לא הופעל, לא מוזג, לא נמחק.
> נבדק מול `origin/main` @ `1d09aa8` · 2026-11-06.

---

## חלק א׳ — טריגרי-פרודקשן: מ-`main` בלבד

### המצב היום (מאומת בקבצים)

| workflow | יעד | טריגר push היום | בעיה |
|---|---|---|---|
| `firebase-hosting.yml` | Firebase Hosting **live** | `claude/whats-happening-LyY9G` | פרודקשן מענף-פיתוח |
| `web-deploy.yml` | Firebase Hosting **live** (אותו אתר) | `claude/whats-happening-LyY9G` | **מרוץ** מול `firebase-hosting.yml` — שניהם כותבים ל-live; ההערות בקובץ עצמו ("same race") מודות בזה |
| `firebase-deploy.yml` | Firestore rules + indexes + Functions | `claude/whats-happening-LyY9G` | חוקי-אבטחה בפרודקשן מענף-פיתוח |
| `deploy.yml` | GitHub Pages | `main` **וגם** `claude/whats-happening-LyY9G` | שני מקורות-אמת לאותו אתר |
| `firebase-preview-backend.yml` | Hosting preview channel | dev branch | preview — תקין |
| `wizard-preview.yml` | Hosting channel `wizard` | dev branch | preview — תקין |
| `android-*.yml` (package/test/google/emulator) | artifacts בלבד | dev branch | לא פרודקשן — תקין |

מאז PR #58 (2026-08-23) `main` = קו-האמת. אבל 4 הפריסות לפרודקשן עדיין מאזינות לענף-הפיתוח —
כלומר כל push לענף שאינו עובר review מגיע ישר למשתמשים, ו-`main` בכלל לא מפרס את Firebase.

### ההמלצה

1. **4 פריסות-הפרודקשן מאזינות ל-`main` בלבד** (+ `workflow_dispatch` ידני). ענף-הפיתוח ממשיך
   להפעיל רק preview / artifacts.
2. **לבטל את המרוץ:** `web-deploy.yml` ו-`firebase-hosting.yml` פורסים לאותו live. להשאיר **אחד**
   (המלצה: `firebase-hosting.yml`, הוא מקור-הדגלים שהשני מעתיק) ולהפוך את `web-deploy.yml`
   ל-`workflow_dispatch` בלבד.
3. **`deploy.yml` (Pages):** להסיר את ענף-הפיתוח מהטריגר.
4. **הגנת-ענף על `main`** (הגדרה ב-GitHub, לא קוד): PR חובה + בדיקת `Protocol Enforcement` ירוקה.
   בלי זה "פרודקשן מ-main בלבד" שווה מעט.
5. **GitHub Environment `production`** עם ה-secrets של Firebase (`FIREBASE_SERVICE_ACCOUNT`) ושל
   חתימת-Android — כך שרק jobs שרצים מ-`main` רואים אותם. אופציונלי: אישור-ידני לפני פריסה.

**למה:** פרודקשן = רק קוד שעבר PR + 6,034 בדיקות; סוף למרוץ שני-workflows-על-אותו-אתר; ה-secrets
של הפרודקשן לא זמינים לכל ענף.

**הסיכון / מה צריך לדעת:** אחרי השינוי, עבודה שנדחפת לענף-הפיתוח **לא** תגיע לאתר החי עד מיזוג
ל-`main`. זה השינוי המכוון — אבל זה משנה את הקצב שאליו התרגלת. גלגול-אחורה = להחזיר את שורת-הענף.

### הטלאי המוכן (לא הופעל — מחכה ל-GO)

הקובץ `docs/launch/W1-B2-triggers.patch` מכיל את השינוי המדויק ל-4 הקבצים. החלה:
`git apply docs/launch/W1-B2-triggers.patch` בענף, PR, ואז מיזוג באישורך.

> ה-workflows החדשים של חבילה זו (`android-release.yml`, `ios-unsigned.yml`) כבר בנויים כך:
> push רק מ-`main` / tags, ו-PR ל-`main` לאימות בלבד.

---

## חלק ב׳ — PR #5 (`claude/nice-volta-BSbVm`)

| עובדה | ערך |
|---|---|
| כותרת | "chore: ignore .claude/ worktree metadata directory" |
| בפועל | 388 קומיטים שלא ב-main · 314 קבצים · +60,095 |
| בסיס | 2026-05-21 (לפני כל קו-ה-Flutter הנוכחי) · `mergeable_state: dirty` (קונפליקטים) |
| המטרה המוצהרת | **כבר ב-main** — `.gitignore` שורות 1-2: `.claude/worktrees/`, `.claude/settings.local.json` |
| מה שאין ב-main | 199 קבצים, כמעט כולם ידע: `knowledge/archive` 70 · `knowledge/screens` 57 · `knowledge/reference` 24 · `knowledge/_catalog` 21 · 4 קבצי `app_flutter/lib` |

**המלצה: לסגור בלי מיזוג (לא למחוק את הענף).**
**סיבה:** המטרה שלו הושגה; השאר הוא קו-היסטוריה ישן מלפני ה-Flutter הנוכחי, עם קונפליקטים, ומיזוגו
יחזיר קבצי `app/` ו-`app_flutter/` ישנים מעל קוד שעבר 6,034 בדיקות. אם יש ערך במסמכי-הידע
(`knowledge/archive|screens|reference|_catalog`) — PR קטן נפרד שמעתיק **רק** אותם, אחרי בדיקה שהם
לא כפולים לתיקיית `knowledge/` הקיימת. הענף נשאר ככתובת-היסטוריה.

## חלק ג׳ — PR #59 (`claude/mah-kora-0by8kw`)

| עובדה | ערך |
|---|---|
| כותרת | "הצלה · חילוץ 5 נכסי-ענפים לתיקיית rescue/" |
| בפועל | 154 קומיטים · **2,766 קבצים** · +135,844 · `mergeable_state: unstable` |
| `rescue/` (המטרה המוצהרת) | 70 קבצים: catalog-exports 4 · protocol-v10 11 · maor-mockups 26 · kiosk-v8 25 · owner-patches 2 |
| מה עוד נכנס | **2,694 קבצים ב-`app_flutter/lib/genesis/`** (פלט-מנועים: dart-maor 665 · dart-data-maor 530 · dart 337 · dart-ui-bs/auto 263 …) + 2 workflows חדשים (`genesis-compile.yml`, `genesis-preview.yml`) — מקומיט "מבחן-הקומפילציה של המחצב" שנוסף לענף **אחרי** תיאור ה-PR |
| CI | Vercel נכשל (מכסה יומית) — לא אינדיקציה לקוד |

**המלצה: לא למזג כמו שהוא. לפצל.**
**סיבה:**
1. ה-PR כבר לא מה שהכותרת אומרת — 97% מהקבצים הם קוד-מחולל בתוך `app_flutter/lib`, כלומר בתוך
   האפליקציה שהולכת לחנות. זה מנפח את הבילד/ה-analyze ומוסיף מסכים שלא עברו את שער-הפרויקט, ממש
   לפני השקה. זה בדיוק "פיצ'ר חדש" שהתוכנית מקפיאה.
2. `rescue/kiosk-v8` ו-`rescue/maor-mockups` שייכים למוצרים אחרים (קיוסק / מאור), לא ל-BuildSmart.
   ה-README של ה-PR עצמו מציין שמפתח-הקיוסק **דלף** בהיסטוריית הענף המקורי — עדיף שהעותק "הנקי"
   לא יחיה בריפו ציבורי של אפליקציה אחרת.

**צעדים מוצעים (כל אחד באישורך):**
- (א) `rescue/catalog-exports` + `rescue/owner-patches` (6 קבצים, BuildSmart) → PR קטן משלהם ל-main.
- (ב) `rescue/protocol-v10` → PR קטן, או לריפו של ה-orchestrator.
- (ג) `rescue/kiosk-v8`, `rescue/maor-mockups` → לריפו המתאים (מאור / קיוסק), **לא** ל-buildsmart.
- (ד) `app_flutter/lib/genesis/**` + 2 ה-workflows → נשארים על הענף כניסוי; חוזרים לדיון אחרי ההשקה.
- (ה) אחרי (א)-(ד): לסגור את #59 בלי מיזוג. הענף **לא נמחק**.

---

## סיכום החלטות שמחכות לך

| # | החלטה | המלצה |
|---|---|---|
| 1 | פרודקשן מ-`main` בלבד (החלת הטלאי) | ✅ כן |
| 2 | ביטול `web-deploy.yml` כפריסה אוטומטית (מרוץ) | ✅ כן |
| 3 | הגנת-ענף על `main` + Environment `production` | ✅ כן (הגדרה ידנית שלך ב-GitHub) |
| 4 | PR #5 | סגירה בלי מיזוג |
| 5 | PR #59 | פיצול לפי (א)-(ה), סגירה בלי מיזוג |
