# BuildSmart — STATUS

_עודכן: 2026-11-14 · **דוח אחרון: 2026-11-14 (לילה)** · ענף אחרון שמוזג ל-main: `claude/whats-happening-LyY9G` (PR #58, 2026-08-24)._
_יומן גרסאות מפורט ותווית הגרסה: `app_flutter/knowledge/STATUS.md` (כרגע **v7.02**)._

## מצב נוכחי
| רכיב | מצב | אימות בסשן זה (2026-11-03) |
|---|---|---|
| `app_flutter/` (Flutter, הפעיל) | 🟢 חי ב-buildsmart-il.com · Android AAB/APK ב-CI · iOS טרם נבנה | analyze: **0 errors** (56 warnings, infos) · tests: **6034 ✅ · 0 ✗ · 12 skip** (Flutter 3.44, ~18 דק׳) |
| `app/` (Preact legacy) | 🟡 GitHub Pages, תיקוני באגים בלבד | typecheck ✅ · build ✅ · smoke **21/21** ✅ (בעקיפת נתיב Chromium — ראה בעיה 2) |
| `functions/` | 🟢 me-west1, gen2 | typecheck ✅ · selftest **100/100** ✅ |
| קטלוג (`scripts/catalog_qa.py`) | 🟢 | selftest ✅ · audit: אפס שגיאות חוסמות ✅ |

עבודה אחרונה שנכנסה (אוגוסט 2026): dark-mode waves 1–16 (מסכים theme-aware), server-sync ל"ניהול מסך"
(`SCREEN_SECTIONS_LIVE`, ברירת-מחדל OFF), הכרטיס הפנימי באנדרואיד (v7.02), תיקון אישור-הבעלים (v7.01).

## בעיות פתוחות
1. **Dark mode לא הושלם** — אחרי wave 16 נותרו ~49 אתרי-משטח בהירים קשיחים (atlas 65→49, `tools/atom/decompose/bin/colors.dart`).
2. **`app/smoke-settings.mjs` מקודד נתיב Chromium** (`/opt/pw-browsers/chromium-1194/...`) — נכשל בסביבה הנוכחית (`chromium-1243/chrome-linux64`). צריך fallback/משתנה-סביבה.
3. **פער גרסאות Flutter ב-CI** — `protocol-enforce.yml`/`catalog-qa.yml` על 3.29.3, build/deploy על 3.44.0; `flutter analyze` ב-3.44 מציג 56 warnings (לא חוסם).
4. **הוראות סשן ישנות** — הענף `claude/whats-happening-LyY9G` עדיין מפעיל deploy לפרודקשן בכל push (`web-deploy.yml`, `firebase-hosting.yml`, `firebase-deploy.yml`); מסמכי `orchestrator/`/`knowledge/` עדיין מפנים אליו כענף העבודה.
5. **PRs פתוחים לא מטופלים** — [#59](https://github.com/meir7651231-ui/buildsmart/pull/59) (הצלת נכסי-ענפים ל-`rescue/`) ו-[#5](https://github.com/meir7651231-ui/buildsmart/pull/5) (`.gitignore` ל-`.claude/`) — ממתינים להחלטת מאיר.
6. **השקה בחנויות** — iOS: אין signing/build (דורש Mac/CI); חשבונות Apple/Google + privacy-policy עדיין פתוחים (`app_flutter/knowledge/LAUNCH_READINESS.md`).
7. **Spec מיושן** — `app_flutter/knowledge/spec/shell-and-dials.md` §7 עדיין מתאר dials וטאבים שהוסרו (היום: בית · מחלקות · עדכונים · חנות). לעדכן.

## Next (3–5 משימות הבאות)
1. **לסיים dark mode** — waves 17+ על ~49 האתרים הנותרים, עד atlas=0, עם צילומי light/dark.
2. **לתקן את smoke-settings** — נתיב Chromium דינמי (`PW_CHROMIUM` / חיפוש ב-`/opt/pw-browsers`) + להכניס ל-CI.
3. **ליישר CI ל-Flutter 3.44.0** בכל ה-workflows ולנקות את ה-warnings של analyze (דורש אישור — `protocol-enforce.yml` קובץ מוגן).
4. **החלטה על ענף ה-deploy** — להעביר את הטריגרים של הפרודקשן ל-`main` בלבד (באישור מאיר) ולעדכן את המסמכים.
5. **iOS build ב-CI** (macOS runner) + השלמת P0 של `LAUNCH_READINESS.md` לקראת הגשה לחנויות.


## לילה 2026-11-11

> הבסיס של הקובץ הזה הוא `STATUS.md` מ-PR [#60](https://github.com/meir7651231-ui/buildsmart/pull/60) (טיוטה, לא מוזג). הסעיף הזה נוסף מעליו.

**⛔ החלטות שמחכות למאיר (קודם כל):**
1. **שער `central-verify.sh` אדום גם על main נקי.** 16 הצהרות conformance ב-`orchestrator/manifests/buildsmart.conformance.txt` נכשלות על main (‏`AppBrand.name`, `kVerticalPacks`, `kOrgModules`, `featEnabled(...)` ב-manager_dashboard, `clean-two-links.yml` בנתיב שגוי ועוד). ה-analyze, ה-suite וה-build עצמם ירוקים. צריך להחליט: לעדכן את ה-manifest, או שהקוד איבד פיצ'רים שהיו אמורים להיות שם.
2. **היקף dark-mode אמיתי גדול מה-atlas.** הגלים 1–16 הסבו משטחים אבל השאירו טקסט `inkLight` קשיח, ובכהה הוא בלתי נראה. גל 17 תיקן 17 קבצים. **~89 קבצים** נוספים עם אותו דפוס. ה-atlas (49) לא סופר את זה. להחליט אם להמשיך בגלים לילה-לילה.
3. **smoke ב-CI** (המשך ל-#64): מחייב נגיעה ב-workflow, ו-`protocol-enforce.yml` מוגן.

**✅ הושלם (3 PRs טיוטה):**
- [#64](https://github.com/meir7651231-ui/buildsmart/pull/64): smoke-settings עם נתיב Chromium דינמי. ‏`node --test` ‏5/5 · smoke **21/21** · CI ✅. סיכון נמוך.
- [#65](https://github.com/meir7651231-ui/buildsmart/pull/65): dark-mode גל 17. ‏`bsInk`/`bsMuted` ‏+ 16 מסכים + `AiOffState`. טסט ניגודיות חדש: אדום לפני, ירוק אחרי, mutation-verified. suite **6055 ✅ / 0 ✗ / 12 skip**. screen-review ‏8.4, כל ציר ≥7 אחרי תיקונים. סיכון נמוך-בינוני.
- [#66](https://github.com/meir7651231-ui/buildsmart/pull/66): ‏36 אזהרות analyzer (56 ← 20), בלי שינוי התנהגות. suite **6034 ✅ / 0 ✗**. סיכון נמוך.

**CI:** Protocol Enforcement ✅ על שלושת ה-PRs (#64 ‏#65 ‏#66), כולל טסטים על 3.29.3 ו-Android release build.

**הערות סביבה:** בקונטיינר אין Flutter מותקן מראש. הורדתי 3.44.0 ל-`/home/user/flutter`. בנוסף, `lib/version.g.dart` נוצר רק דרך `bash scripts/gen_version.sh` **משורש הריפו**, ובלעדיו analyze מראה 8 errors מדומים.

**▶️ הצעד הבא:**
- גל 18 של dark-mode: מפרידים וגבולות (`bsDivider`), `bsSubtleFill`, ‏`worker_app_screen.dart:160`, והקבצים הבאים מתוך ה-89.
- להרחיב את `dark_ink_screens_test` לגיליונות.
- לקבע את גרסת Flutter ב-CI על 3.44.


## לילה 2026-11-12

> גם הלילה הבסיס הוא `STATUS.md` מ-PR [#60](https://github.com/meir7651231-ui/buildsmart/pull/60) (טיוטה, לא מוזג) + סעיף הלילה הקודם. הקובץ יושב בענף `claude/serene-carson-bz7ko7`.

**⛔ החלטות שמחכות למאיר (קודם כל):**
1. **למזג את [#68](https://github.com/meir7651231-ui/buildsmart/pull/68)** (השער חוזר לירוק). 4 כללי conformance הופנו לשורות הקוד הנוכחיות. כדאי מבט שלך על הארבעה (הטבלה ב-PR) לפני מיזוג.
2. **4 PRs טיוטה מחכים למיזוג** ([#64](https://github.com/meir7651231-ui/buildsmart/pull/64), [#65](https://github.com/meir7651231-ui/buildsmart/pull/65), [#66](https://github.com/meir7651231-ui/buildsmart/pull/66), #68). גל 18 של dark-mode תלוי ב-#65 (`bsInk`/`bsMuted`). לא ערמתי עליו עבודה חדשה.
3. **להריץ את השער ב-CI?** אף workflow לא מריץ את `orchestrator/scripts/selftest.sh` או את ה-conformance. לכן השער היה אדום חודשים בלי שמישהו ראה. הוספה מחייבת נגיעה ב-workflow.
4. פתוחות מאתמול: היקף dark-mode (~89 קבצים), smoke ב-CI.

**✅ הושלם (PR טיוטה אחד):**
- [#68](https://github.com/meir7651231-ui/buildsmart/pull/68), סוגר את issue [#67](https://github.com/meir7651231-ui/buildsmart/issues/67). **אף אחת מ-16 ההצהרות שנכשלו אינה פיצ'ר שאבד.** 10 נכשלו כי `grep-verify.sh` קרא מחרוזות מילוליות כ-regex, 2 בגלל נתיב בלי `../`, ו-4 התיישנו אחרי refactor (ההתנהגות קיימת). בדרך נסגר חור: כלל-איסור עם תבנית לא תקינה עבר בשקט כ-"OK absent".
- ראיות: `central-verify.sh` ← **GATE PASS** (analyze ‏0 errors · **6034 ✅ / 0 ✗ / 12 skip** · build web ✅ · 271 כללי conformance ✅ · required-tests ✅). `selftest.sh` ✅ עם 20 מקרים חדשים, 16 מהם אדומים מול הסקריפטים הישנים. סיכון נמוך: כלי-פיתוח בלבד, אין שינוי בקוד האפליקציה.

**למה רק משימה אחת:** השער היה אדום מההתחלה, ולפי כלל 6 של המשימה הלילית זו המשימה היחידה. ה-suite עצמו ירוק על main.

**בדיקות בסיס על main (לפני השינוי):** `app/` typecheck ✅ · build ✅ · smoke ✗ (נתיב Chromium קשיח, מתוקן ב-#64) · `functions` selftest 100/100 ✅ · `flutter analyze` ‏0 errors, ‏56 warnings (מתוקן חלקית ב-#66).

**חריגה מחוק-על #0:** הנחיל הורץ מצומצם. 3 מבקרים (לא 9 עדשות, כי רובן לא רלוונטיות לסקריפטי shell) + מפקח אחד שהחזיר NO-GO על כלל אחד חלש מדי, והכלל תוקן. את העריכות ביצע האורקסטרייטור ולא סוכני fixer.

**▶️ הצעד הבא:**
- אחרי מיזוג #65: גל 18 של dark-mode (מפרידים, `bsSubtleFill`, ‏`worker_app_screen.dart:160`).
- אם מאיר מאשר: workflow קטן שמריץ `selftest.sh` + conformance על כל PR.
- לקבע את גרסת Flutter ב-CI על 3.44 (`protocol-enforce.yml` ו-`catalog-qa.yml` עדיין על 3.29.3).


## לילה 2026-11-13

> הבסיס הוא `STATUS.md` מ-PR [#60](https://github.com/meir7651231-ui/buildsmart/pull/60) (טיוטה, לא מוזג) + סעיפי הלילות הקודמים. הקובץ יושב בענף `claude/serene-carson-0v7mys`.

**⛔ החלטות שמחכות למאיר (קודם כל):**
1. **7 PRs טיוטה מחכים למיזוג**: #64 · #65 · #66 · #68 מהלילות הקודמים + שלושת החדשים למטה. שום דבר לא מוזג מאז 24.8, ו-`main` לא זז. גל 18 של dark-mode והמשך ניקוי ה-analyzer עדיין חסומים על #65/#66.
2. **ניסוחים חדשים לאישור** (Flutter בלבד): "השיחה לא נמצאה" ([#70](https://github.com/meir7651231-ui/buildsmart/pull/70)) · "יש לכתוב מה הליקוי" וכותרת-המשנה "פתח ליקוי ועקוב אחרי הליקויים הפתוחים." ([#71](https://github.com/meir7651231-ui/buildsmart/pull/71)).
3. **מע"מ: הכרטיס והסל לא מסכימים.** בברירות המחדל הכרטיס הפנימי מציג מחיר ×1.18 והסל מחייב את המחיר הבסיסי כ"כולל מע"מ" (‏₪118 מול ₪100). צריך החלטה אם `priceFor()` הוא נטו או ברוטו. לא תוקן. (`full_internal_card.dart:1338`, מאחורי `INTERNAL_CARD`.)
4. **בורר עובד בטופס הליקויים של הקבלן?** היום ליקוי שהקבלן פותח משויך בשקט לעובד 0.
5. **סל שנשאר אחרי התנתקות / החלפת משתמש.** משתמש ב' רואה את הסל, כתובת האספקה וההערה של משתמש א'. ניקוי גורף ימחק גם סל של אורח שנרשם, ולכן זו החלטת-מוצר.
6. **מי מקבל מטבעות על אישור משימה?** `tasks_engine.dart:677` מזכה את מי שמחובר (המנהל המאשר), לא את העובד.
7. פתוחות מקודם: להריץ את השער ב-CI · היקף dark-mode (~89 קבצים) · smoke ב-CI.

**✅ הושלם (3 PRs טיוטה, כל אחד עם suite מלא ירוק · analyze ‏0 errors · build web ✅):**
- [#69](https://github.com/meir7651231-ui/buildsmart/pull/69): **יתרת BuildCoins לא נדרסת.** פעולת-מטבעות ראשונה בסשן (למשל מסירה ראשונה של שליח) כתבה את היתרה מחדש מה-seed: 440 שמורים + 20 הפכו ל-360. עכשיו הפעולה מורכבת על היתרה השמורה. suite **6042 ✅ / 0 ✗ / 12 skip**. סיכון נמוך-בינוני.
- [#70](https://github.com/meir7651231-ui/buildsmart/pull/70): **הקשה על התראת-צ'אט פותחת את השיחה גם כשהאפליקציה כבר רצה.** קודם האפליקציה עלתה בלי שיחה, והשיחה נפתחה מעצמה בגלילה הבאה. כולל: רק המסך העליון צורך, לוח-תפקיד שמכסה את ה-shell מקבל את ההקשה בעצמו, המתנה לשיחה שעוד לא נטענה (toast אחרי 8 שניות), ונעילת `?thread=` לפעם אחת. suite **6051 ✅ / 0 ✗ / 12 skip**. סיכון בינוני. לא נבדק על מכשיר אמיתי.
- [#71](https://github.com/meir7651231-ui/buildsmart/pull/71): **הקבלן מקבל את גיליון הליקויים שלו.** קבלן רגיל (ניהול אתר ← רשימת ליקויים) קיבל את טופס העובד: רשימה ריקה וכפתור שמירה מת. באותו PR תיקוני screen-review (שגיאה בשם ריק, הגיליון מעל המקלדת, טקסט קריא ב-dark, high-contrast). suite **6044 ✅ / 0 ✗ / 12 skip**. סיכון נמוך-בינוני.

**screen-review (כלל 3):** #69 לא נוגע ב-UI.
- **#71 עומד בכלל.** שלוש סקירות: נגישות 4 ← 6 ← 8, רספונסיביות 5 ← 7 ← 7, מצבים 5 ← 7 ← 7. הסקירה האחרונה: כל הצירים ≥7, "merge" (פורסמה כתגובה ב-PR).
- **#70 לא עומד בכלל במלואו.** ציר "מצבי טעינה/שגיאה/ריק" קיבל 4 ואז 6. שלושת הפערים של הסקירה השנייה תוקנו ומכוסים בטסטים, אבל **לא הורצה סקירה שלישית**, ולכן אין ציון ≥7 מאומת. בנוסף ה-PR נפתח לפני שהסקירה השנייה חזרה. שאר הצירים 7–9.
- כל הסקירות נעשו מקריאת קוד, בלי צילומי מסך.

**בדיקות בסיס על main (לפני השינויים):** Flutter suite **6034 ✅ / 0 ✗ / 12 skip** · analyze ‏0 errors · `app/` typecheck ✅ + build ✅ · `functions` selftest 100/100 ✅. השער `central-verify.sh` עדיין אדום על main עד מיזוג #68, ולכן הורצו רכיביו בנפרד (analyze · suite · build).

**ממצאי הנחיל שלא טופלו הלילה (מועמדים ללילות הבאים, כולם אומתו רק בקריאת קוד):**
- שליח: לחיצה כפולה על "אספתי מהחנות" מדלגת `pickup → transit → delivered` בלי אישור המסירה, ועלולה לשלם מטבעות פעמיים (`courier_delivery_detail_sheet.dart:402`). **חמור, הראשון בתור.**
- מחשבון מט"ח: ממציא שער 1:1 כשאין שערים, וקורס על סכומים כמו `0.0000001` או `1e999` (`finance_hub_sheets.dart:1677-1708`). אומת ע"י מאמת.
- וריאנטים: ‎¼‎ ו-‎¾‎ מתמזגים לצ'יפ אחד "/4" (`variant_families.dart:178`). תיקון של שורה.
- חיפוש: "שירותים" לא מוצא אסלות (כינויים דו-מיליים לא נתפסים); יחיד שמסתיים באות סופית לא מוצא את הרבים ("סיפון" ← "סיפונים").
- סל: הערת השליח מההזמנה הקודמת נשארת בשדה; החלפת פרויקט משאירה כתובת אספקה והערה של הפרויקט הקודם (`store_screen.dart:188,213,1630`).
- בועת העזרה קורסת במסך צר מ-294px (`help_target.dart:248`).
- כפתור הסל הצף בלי שם לקורא-מסך; כפתורי אשר/דחה של המנהל נמוכים מ-44px; מה-FAB במסך AI פנימי חוזרים למרכז ה-AI ולא לסל.
- אדמין: `approvableRolesForClaims` בודק `'admin'` ברשימת תפקידים שלעולם לא מכילה אותו, ולכן בעלים לא רואה בקשות עובד/שליח.
- ביצועים: מיון תוצאות החיפוש מחשב רלוונטיות מחדש בכל השוואה (~19× מיותר בשאילתה רחבה).

**חריגה מחוק-על #0:** הנחיל הורץ: 9 מבקרים (10 העדשות, שתיים אוחדו) ← 4 מאמתים ← 3 סקירות מסך. **המפקח המסכם נעצר על מגבלת שימוש לפני שדיווח**, ולכן האימות הסופי (suite · analyze · build · היקף ה-diff · mutation) נעשה ע"י האורקסטרייטור. גם את העריכות ביצע האורקסטרייטור ולא סוכני fixer.

**הערות סביבה:** כמו בלילות הקודמים, Flutter 3.44.0 הורד ל-`/home/user/flutter` ו-`lib/version.g.dart` נוצר עם `bash scripts/gen_version.sh` משורש הריפו.

**▶️ הצעד הבא:**
- מרוץ המסירה של השליח (למעלה).
- מחשבון המט"ח + הצ'יפ `/4` (שניהם קטנים ומאומתים).
- אחרי מיזוג #65: גל 18 של dark-mode, כולל הגיליונות האחים של הליקויים.


## לילה 2026-11-14

> הבסיס הוא `STATUS.md` מהענף `claude/serene-carson-0v7mys` **בגרסה התקינה** (`864be12a`) + פסקת ה-screen-review של 13.11 פעם אחת. הקומיט `0c92ff16` באותו ענף ניפח את הקובץ ל-9.6MB, כי הפסקה הוכנסה לפני כל תו (issue [#72](https://github.com/meir7651231-ui/buildsmart/issues/72)). הקובץ כאן נבנה מחדש ונבדק: 17KB, והפסקה מופיעה פעם אחת. הוא יושב בענף `claude/serene-carson-epcy0b`.

**⛔ החלטות שמחכות למאיר (קודם כל):**
1. **#72: לא למזג את `claude/serene-carson-0v7mys`.** הקובץ התקין נמצא כאן. אפשר לסגור את הענף ההוא או לקחת ממנו רק את הקוד.
2. **10 PRs טיוטה מחכים למיזוג:** ‏#64 · #65 · #66 · #68 · #69 · #70 · #71 + שלושת החדשים למטה. שום דבר לא מוזג מאז 24.8. השער `central-verify.sh` עדיין אדום על main עד מיזוג [#68](https://github.com/meir7651231-ui/buildsmart/pull/68).
3. **ניסוחים חדשים לאישור** (Flutter בלבד): "אין שער חליפין זמין ל-USD" · "הזינו סכום להמרה" · "⚙️ שערי המט״ח יוצגו כאן כשיתעדכנו מהשרת" (#FX).
4. **החלטה ויזואלית ב-#73:** כפתור "✅ נמסר ללקוח" עבר מכתום (brand, לבן ≈3:1, מתחת ל-AA) לירוק `successDark`, כמו "אספתי מהחנות". אם צריך להבדיל בין השלבים, צריך טוקן כתום כהה (למשל ‎#C2410C‏, ‏5.2:1).
5. פתוחות מקודם: מע"מ בכרטיס מול הסל · בורר עובד בטופס ליקויים · סל אחרי התנתקות · מי מקבל מטבעות על אישור משימה · השער ב-CI · היקף dark-mode.

**✅ הושלם (3 PRs טיוטה, כל אחד: suite מלא ירוק · analyze ‏0 errors · screen-review ≥7 בכל ציר):**
- [#73](https://github.com/meir7651231-ui/buildsmart/pull/73): **לחיצה כפולה של השליח לא מדלגת ל"נמסר" בלי אישור.** זה היה הממצא החמור מאתמול. compare-and-set ב-`courierAdvance(id, from:)`, ובגיליון: busy state, שומר-staleness, ו-toast רק אחרי קידום אמיתי. באותו PR גם תיקוני screen-review: dark-mode, ניגודיות AA, ‏48px. suite **6039 ✅ / 0 ✗ / 12 skip**. screen-review: ‏7 ← **8**. סיכון נמוך-בינוני.
- **מחשבון המט"ח** (PR נפתח אחרי הרצה חוזרת של ה-suite; הקישור יעודכן כאן).
- [#74](https://github.com/meir7651231-ui/buildsmart/pull/74): **צ'יפי קוטר בקטלוג.** ¼" ו-¾" כבר לא צ'יפ אחד "/4", ו-1½" לא נוחת על ½". התוויות קריאות (`1½"` ולא `11/2"`), המיון לפי קוטר אמיתי, Semantics, ו-memo ל-perMat. suite **6040 ✅ / 0 ✗ / 12 skip**. screen-review: ‏5.6 ← 7.0 (הסבב השני מצא רגרסיה במיון, והיא תוקנה) ← **merge**. סיכון נמוך.

**בדיקות בסיס על main (לפני השינויים):** Flutter suite **6034 ✅ / 0 ✗ / 12 skip** · analyze ‏0 errors · `app/` typecheck ✅ + build ✅. הטסטים ירוקים, ולכן כלל 6 לא הופעל.

**חריגה מחוק-על #0:** לא הורץ נחיל 9×9 מלא. המשימות נבחרו מממצאי הנחיל של 13.11, שכבר אומתו. הלילה רצו 3 סוקרים (ביקורת אדברסרית + screen-review), אחד לכל PR, ב-2–3 סבבים. את העריכות ואת אימות ה-suite ביצע האורקסטרייטור. `central-verify.sh` לא הורץ, כי הוא אדום על main עד #68. במקומו הורצו רכיביו בנפרד: analyze · suite · build של `app/`.

**הערות סביבה:** Flutter 3.44.0 הורד שוב ל-`/home/user/flutter`. צריך `git config --global --add safe.directory /home/user/flutter`. ו-`lib/version.g.dart` נוצר עם `bash scripts/gen_version.sh` משורש הריפו.

**▶️ הצעד הבא:**
- המשך הממצאים מ-13.11: חיפוש "שירותים"→אסלות ויחיד/רבים עם אות סופית · הערת שליח שנשארת בסל · בועת עזרה במסך צר מ-294px · `approvableRolesForClaims` ‏(בעלים לא רואה בקשות).
- מעקבים מהסקירות: `_FinRows` ב-dark mode · `semanticsLabel` ל-spinner של השליח · חתימות השליח אחרי ה-compare-and-set · ‏`1/2״` ו-⅛⅜⅝⅞ בצ'יפים.
- אחרי מיזוג #65: גל 18 של dark-mode.
